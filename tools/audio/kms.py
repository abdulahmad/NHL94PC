#!/usr/bin/env python3
"""NHL Hockey ('94 PC) music: .KMS songs and their .CFG track setup.

  kms.py list                         every song: tempo, tracks, channels, programs, length
  kms.py dump SONG                    the events of one song, decoded
  kms.py mid SONG [-o out.mid]        a Standard MIDI File (notes as the game sends them, +24)
  kms.py vgm SONG [-o out.vgm]        AdLib (OPL2) register log, made by running the game's own YM30 driver
  kms.py wav SONG [-o out.wav]        the same, rendered with Nuked OPL3 (run fetch-deps.sh once)
  kms.py wav all                      every AD*/team song to output/music/
  kms.py play SONG                    render to a temporary WAV and play it (aplay, paplay, afplay or ffplay)

SONG is a name (TITLE, ADTITLE, BOS1, ...) or a path to a .KMS; the .CFG next to it is used.
The game folder defaults to lst/game/ (or set NHL94_GAME). Options: --loops N (how many times a looping song
plays, default 1), --max SECONDS (default 600), --pat N (patch map, default 4 = AdLib), --vol 0-127.

Everything here comes from HOCKEY.EXE (the EA sound library in the root image, segment 0x1630) and from the
YM30.BGP driver. See docs/MUSIC_FORMAT.md.
"""
import os, sys, struct, argparse

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
GAME = os.environ.get('NHL94_GAME', os.path.join(REPO, 'lst', 'game'))
TIMER_HZ = 100          # PIT divisor 0x2E9C: the game's timer interrupt, which runs the music every time
OPL_RATE = 49716        # native OPL2 output rate (3.579545 MHz / 72)

# ---------------------------------------------------------------- files

def btree_unpack(s):
    """EA 'BTree' packing (magic 46 FB / 47 FB): a byte-pair dictionary. Used by the *30.BGP drivers."""
    t = (s[0] << 8) | s[1]
    if t & 0xFEFF != 0x46FB:
        raise ValueError('not a BTree-packed file')
    p = 2 + (3 if t & 0x100 else 0)
    ulen = (s[p] << 16) | (s[p + 1] << 8) | s[p + 2]; p += 3
    clue = s[p]; n = s[p + 1]; p += 2
    kind = [0] * 256; L = [0] * 256; R = [0] * 256
    for _ in range(n):
        c = s[p]; kind[c] = 1; L[c] = s[p + 1]; R[c] = s[p + 2]; p += 3
    kind[clue] = 2
    out = bytearray()
    while p < len(s):
        c = s[p]; p += 1
        if kind[c] == 2:                       # escape: next byte is a literal, 0 ends the data
            c = s[p]; p += 1
            if c == 0: break
            out.append(c); continue
        st = [c]
        while st:
            c = st.pop()
            if kind[c] == 1: st.append(R[c]); st.append(L[c])
            else: out.append(c)
    if len(out) != ulen:
        raise ValueError('BTree: unpacked %d bytes, header says %d' % (len(out), ulen))
    return bytes(out)

def find_song(name):
    if os.path.exists(name):
        return name
    for cand in (name, name.upper(), name.upper() + '.KMS', name + '.KMS', name + '.kms'):
        p = os.path.join(GAME, cand)
        if os.path.isfile(p):
            return p
    sys.exit('no song %r in %s' % (name, GAME))

def read_vlq(d, p):
    v = 0
    while True:
        b = d[p]; p += 1
        v = (v << 7) | (b & 0x7F)
        if not b & 0x80:
            return v, p

class Event:
    __slots__ = ('pos', 'delta', 'cmd', 'a1', 'a2', 'data', 'len')

def decode_event(d, p):
    """One event, as the game's decoder (1630:0A90) reads it: VLQ delta, command byte, arguments."""
    e = Event(); e.pos = p; e.a1 = 0; e.a2 = 0; e.data = b''
    e.delta, p = read_vlq(d, p)
    c = d[p]; p += 1; e.cmd = c
    if c < 0xD9:                               # a note: 0x80|n carries a velocity byte, then a VLQ duration
        if c > 0x80:
            e.a1 = d[p]; p += 1
        e.a2, p = read_vlq(d, p)
    elif c in (0xDC, 0xDD, 0xDE, 0xE0, 0xE1, 0xE2, 0xE4, 0xE9, 0xEA):
        e.a1 = d[p]; p += 1
    elif c == 0xDF:                            # controller: number, value
        e.a1 = d[p]; e.a2 = d[p + 1]; p += 2
    elif c == 0xE5:                            # pitch bend, 16-bit little-endian, centre 0x4000
        e.a2 = d[p] | (d[p + 1] << 8); p += 2
    elif c == 0xE6:                            # call: one byte, then a 32-bit target
        e.a1 = d[p]; e.a2 = struct.unpack_from('<I', d, p + 1)[0]; p += 5
    elif c == 0xE7:                            # text (track name), length-prefixed
        n = d[p]; e.data = d[p + 1:p + 1 + n]; p += 1 + n
    elif c == 0xE8:                            # system exclusive, length-prefixed (MT-32 only)
        n = d[p]; e.data = d[p + 1:p + 1 + n]; p += 1 + n
    # D9 DA DB E3 (and anything above EA) have no arguments
    e.len = p - e.pos
    return e

class Song:
    def __init__(self, path):
        self.path = path
        self.name = os.path.splitext(os.path.basename(path))[0].upper()
        self.kms = open(path, 'rb').read()
        cfgp = os.path.splitext(path)[0] + '.CFG'
        if not os.path.exists(cfgp):
            cfgp = os.path.splitext(path)[0] + '.cfg'
        self.cfg = open(cfgp, 'rb').read()
        k = self.kms
        self.version = k[0]
        self.tempo = k[1]
        self.ntracks = struct.unpack_from('<H', k, 6)[0]
        self.offsets = [struct.unpack_from('<H', k, 8 + 2 * i)[0] for i in range(self.ntracks)]
        self.tracks = []
        for i in range(self.ntracks):
            r = self.cfg[16 * i:16 * i + 24]           # the game reads record i at cfg + 16*i, fields from +8
            mask, = struct.unpack_from('<H', r, 8)
            self.tracks.append(dict(mask=mask, chan=lowest_bit(mask), vol=r[0xE], pan=r[0xF],
                                    program=r[0x14], res=r[0xA:0xE]))

    def events(self, i):
        d = self.kms; p = self.offsets[i]
        while p < len(d):
            e = decode_event(d, p); yield e
            p += e.len
            if e.cmd in (0xD9, 0xDA, 0xDB): break

    def track_name(self, i):
        for e in self.events(i):
            if e.cmd == 0xE7: return e.data.rstrip(b'\0').decode('latin-1')
        return ''

def lowest_bit(m):
    for b in range(16):
        if m >> b & 1: return b
    return 0

# ---------------------------------------------------------------- the sequencer (HOCKEY.EXE 1630:01D2 and friends)

NOTE_OFFSET = 24        # 1844:022E adds 18h to the note byte of every 8x/9x message it sends to a driver

class Track:
    pass

class Sequencer:
    """Plays one song the way the game's timer callback does: every interrupt each track adds 0x80 to an
    accumulator and runs one tick for every 32000/tempo it holds."""
    def __init__(self, song, send, loops=1, volume=0x7F, pan=0x3F, transpose=0):
        self.song = song; self.send = send
        self.vol = volume; self.pan = pan; self.transpose = transpose
        self.loops = loops; self.loop_count = 0
        self.notes = []                      # pending note-offs: [track, chan, note, ticks left]
        self.tracks = []
        rate = 32000 // song.tempo
        for i, tc in enumerate(song.tracks):
            t = Track(); t.idx = i; t.cfg = tc
            t.pos = song.offsets[i]; t.start = t.pos
            t.delta = 0; t.acc = 0; t.rate = rate
            t.chan = tc['chan']; t.vel = 0; t.loopdepth = 0; t.calldepth = 0
            t.loops = []; t.calls = []; t.prog = tc['program']; t.looped = 0
            self.tracks.append(t)
            # song start (1630:17E6): program, modulation 0, volume, pan, pitch bend centre
            self.midi(bytes([0xC0 | t.chan, tc['program']]))
            self.controller(t, 1, 0)
            self.controller(t, 7, tc['vol'])
            self.controller(t, 10, tc['vol'])  # the game passes the volume byte (+0Eh) here too, not +0Fh
            self.midi(bytes([0xE0 | t.chan, 0, 0x40]))

    def midi(self, msg):
        self.send(msg)

    def controller(self, t, num, val):           # 1630:03C2
        if num == 7:
            val = min(val * self.vol // 0x7F, 0x7F)
        elif num == 10:
            c = 0x7F - val if self.pan > 0x3F else val
            val = (val + (self.pan - 0x3F) * c // 0x3F) & 0xFF
        self.midi(bytes([0xB0 | t.chan, num, val]))

    def done(self):
        return all(t.pos is None for t in self.tracks)

    def interrupt(self):
        for t in self.tracks:
            if t.pos is None: continue
            t.acc += 0x80
            while t.acc >= t.rate and t.pos is not None:
                self.tick(t)
                t.acc -= t.rate

    def tick(self, t):
        # note-offs that are due for this track
        for n in self.notes[:]:
            if n[0] is t:
                n[3] -= 1
                if n[3] <= 0:
                    self.midi(bytes([0x80 | n[1], n[2], 0])); self.notes.remove(n)
        if t.delta:
            t.delta -= 1; return
        d = self.song.kms
        while True:
            e = decode_event(d, t.pos)
            t.pos += e.len
            self.execute(t, e)
            if t.pos is None: return
            t.delta = decode_event(d, t.pos).delta
            if t.delta:
                t.delta -= 1; return

    def execute(self, t, e):
        c = e.cmd
        if c < 0xD9:                                   # note
            vel = e.a1 if c > 0x80 else t.vel          # bytes below 81h use the E4 default velocity
            note = c & 0x7F
            if t.chan != 9: note = (note + self.transpose) & 0xFF
            if len(self.notes) >= 32: return           # the game has 32 note slots
            self.notes.append([t, t.chan, (note + NOTE_OFFSET) & 0x7F, e.a2 or 1])
            self.midi(bytes([0x90 | t.chan, (note + NOTE_OFFSET) & 0x7F, vel]))
        elif c in (0xD9, 0xDA):                        # end of track, or return from a call
            if t.calldepth:
                t.pos = t.calls.pop(); t.calldepth -= 1
            else:
                t.pos = None
        elif c == 0xDB:                                # restart the track from the top (the songs loop with this)
            t.looped += 1
            if t.idx == 0: self.loop_count += 1
            if self.loop_count >= self.loops and t.looped >= self.loops:
                t.pos = None; return
            t.loopdepth = t.calldepth = 0; t.loops = []; t.calls = []
            t.pos = t.start
        elif c == 0xDC:                                # program change
            t.prog = e.a1
            self.midi(bytes([0xC0 | t.chan, e.a1]))
        elif c == 0xDD:                                # tempo for the whole song
            for u in self.tracks: u.rate = 32000 // max(e.a1, 1)
        elif c == 0xDF:
            self.controller(t, e.a1, e.a2)
        elif c == 0xE2:                                # loop start, count-1 kept
            t.loops.append([t.pos, (e.a1 - 1) & 0xFF]); t.loopdepth += 1
        elif c == 0xE3:                                # loop end (the game jumps back once more after the count runs out)
            if t.loopdepth:
                top = t.loops[-1]; t.pos = top[0]
                n = top[1]; top[1] = (top[1] - 1) & 0xFF
                if n == 0: t.loops.pop(); t.loopdepth -= 1
        elif c == 0xE4:
            t.vel = e.a1
        elif c == 0xE5:
            self.midi(bytes([0xE0 | t.chan, 0, (e.a2 >> 8) & 0x7F]))
        elif c == 0xE6:                                # call (unused by the retail songs)
            t.calls.append(t.pos); t.calldepth += 1
            t.pos = e.a2 + 4
        # DE E0 E1 E7 E9: nothing; E8 sysex goes to the MT-32 only; EA sets a byte nothing here reads

    def all_off(self):
        for n in self.notes: self.midi(bytes([0x80 | n[1], n[2], 0]))
        self.notes = []

# ---------------------------------------------------------------- the YM30 driver, run in an x86 emulator

class TimBank:
    def __init__(self, path):
        d = open(path, 'rb').read()
        n, = struct.unpack_from('<H', d, 4)
        ids = [d[6 + 4 * i:10 + 4 * i] for i in range(n)]
        offs = list(struct.unpack_from('<%dI' % n, d, 6 + 4 * n))
        base = 6 + 8 * n
        self.items = {}
        for i in range(n):
            if offs[i] == 0xFFFFFFFF or ids[i][0] != 0x80: continue
            nxt = min([o for o in offs if o != 0xFFFFFFFF and o > offs[i]] + [len(d) - base])
            self.items[ids[i][3]] = d[base + offs[i]:base + nxt]

class YM30:
    """YM30.BGP, the AdLib driver ('YM3801 Sound Driver, Brian Plank, EA Canada 1992'), loaded and called the
    way HOCKEY.EXE does. OUT to 388h/389h is recorded as OPL2 register writes."""
    DRV_SEG = 0x1000; DAT_SEG = 0x3000; BUF_SEG = 0x5000; STUB_SEG = 0x6000; STK_SEG = 0x7000

    def __init__(self, pat=4):
        from unicorn import Uc, UC_ARCH_X86, UC_MODE_16, UC_HOOK_INSN, UC_HOOK_CODE
        from unicorn.x86_const import UC_X86_INS_OUT, UC_X86_INS_IN
        import unicorn.x86_const as X
        self.X = X
        mu = self.mu = Uc(UC_ARCH_X86, UC_MODE_16)
        mu.mem_map(0, 0x100000)
        exe = btree_unpack(open(os.path.join(GAME, 'YM30.BGP'), 'rb').read())
        hdr = struct.unpack_from('<14H', exe, 0)
        size = (hdr[2] - 1) * 512 + hdr[1] if hdr[1] else hdr[2] * 512
        img = bytearray(exe[hdr[4] * 16:size])
        for i in range(hdr[3]):
            off, seg = struct.unpack_from('<HH', exe, hdr[12] + 4 * i)
            a = seg * 16 + off
            v, = struct.unpack_from('<H', img, a)
            struct.pack_into('<H', img, a, (v + self.DRV_SEG) & 0xFFFF)
        mu.mem_write(self.DRV_SEG * 16, bytes(img))
        toff, tseg = struct.unpack_from('<HH', img, 0)
        tab = tseg * 16 + toff                          # the driver's far-pointer function table
        self.fn = [struct.unpack_from('<HH', mu.mem_read(tab + 4 * i, 4)) for i in range(13)]
        self.ds = tseg
        # patch map and timbre banks
        patd = bytearray(open(os.path.join(GAME, 'PCFF%03d.PAT' % pat), 'rb').read())
        banks = {}
        blob = bytearray(); itemaddr = {}
        for r in range(0x102, len(patd) - 19, 20):
            b, n = patd[r], patd[r + 1]
            if b not in banks:
                p = os.path.join(GAME, 'PCFF%03d.TIM' % b)
                banks[b] = TimBank(p) if os.path.exists(p) else None
            item = banks[b].items.get(n) if banks[b] else None
            ptr = 0
            if item:
                if (b, n) not in itemaddr:
                    itemaddr[(b, n)] = 0x10000 + len(blob); blob += item + bytes(-len(item) % 16)
                a = itemaddr[(b, n)]
                ptr = ((self.DAT_SEG + (a >> 4)) << 16) | (a & 15)
            struct.pack_into('<I', patd, r + 0x10, ptr)   # the game fills this at load: far pointer to the timbre
        mu.mem_write(self.DAT_SEG * 16, bytes(patd))
        mu.mem_write(self.DAT_SEG * 16 + 0x10000, bytes(blob))
        self.pat = patd
        # stubs: +0 timbre callback, +8 patch callback (both RETF 2), +16 return-to-host
        mu.mem_write(self.STUB_SEG * 16, bytes([0xCA, 2, 0] + [0x90] * 5 + [0xCA, 2, 0] + [0x90] * 5 + [0x90] * 4))
        self.writes = []; self.idx = 0; self.time = 0
        mu.hook_add(UC_HOOK_INSN, self._out, None, 1, 0, UC_X86_INS_OUT)
        mu.hook_add(UC_HOOK_INSN, self._in, None, 1, 0, UC_X86_INS_IN)
        mu.hook_add(UC_HOOK_CODE, self._cb, None, self.STUB_SEG * 16, self.STUB_SEG * 16 + 8)
        # init as the game does: fn0 (port), the delays fn1 would set, fn2 (callbacks, port, chip reset)
        port = self.call(0)
        mu.mem_write(self.ds * 16 + 0xCA, struct.pack('<HHH', 0x388, 1, 1))
        self.call(2, [port >> 16, port & 0xFFFF, (self.STUB_SEG, 0), (self.STUB_SEG, 8)])

    def _cb(self, mu, addr, size, user):
        X = self.X
        sp = mu.reg_read(X.UC_X86_REG_SP); ss = mu.reg_read(X.UC_X86_REG_SS)
        prog = mu.mem_read(ss * 16 + sp + 4, 1)[0]
        rec = 0x102 + 20 * self.pat[2 + prog]
        if addr == self.STUB_SEG * 16:                    # timbre: the far pointer kept in the record
            ptr, = struct.unpack_from('<I', self.pat, rec + 0x10)
            mu.reg_write(X.UC_X86_REG_AX, ptr & 0xFFFF); mu.reg_write(X.UC_X86_REG_DX, ptr >> 16)
        elif addr == self.STUB_SEG * 16 + 8:              # patch record
            mu.reg_write(X.UC_X86_REG_AX, rec); mu.reg_write(X.UC_X86_REG_DX, self.DAT_SEG)

    def _out(self, mu, port, size, val, user):
        if port == 0x388: self.idx = val & 0xFF
        elif port == 0x389: self.writes.append((self.time, self.idx, val & 0xFF))

    def _in(self, mu, port, size, user):
        return 0

    def call(self, n, args=()):
        """Far call to driver function n, Pascal convention: args pushed first to last, words or (seg, off)."""
        X = self.X; mu = self.mu
        words = []
        for a in args:
            if isinstance(a, tuple): words += [a[0], a[1]]
            else: words.append(a)
        sp = 0xFFF0
        for w in words:
            sp -= 2; mu.mem_write(self.STK_SEG * 16 + sp, struct.pack('<H', w & 0xFFFF))
        sp -= 4; mu.mem_write(self.STK_SEG * 16 + sp, struct.pack('<HH', 16, self.STUB_SEG))
        mu.reg_write(X.UC_X86_REG_SS, self.STK_SEG); mu.reg_write(X.UC_X86_REG_SP, sp)
        mu.reg_write(X.UC_X86_REG_DS, self.ds); mu.reg_write(X.UC_X86_REG_ES, self.ds)
        seg, off = self.fn[n][1], self.fn[n][0]
        mu.reg_write(X.UC_X86_REG_CS, seg)
        mu.emu_start(seg * 16 + off, self.STUB_SEG * 16 + 16, count=5000000)
        return (mu.reg_read(X.UC_X86_REG_DX) << 16) | mu.reg_read(X.UC_X86_REG_AX)

    def midi(self, msg):                                   # fn 11: MIDI bytes (far pointer, count)
        self.mu.mem_write(self.BUF_SEG * 16, bytes(msg))
        self.call(11, [len(msg), (self.BUF_SEG, 0)])

    def tick(self):                                        # fn 5: the per-interrupt envelope update
        self.call(5)

def render_song(song, loops=1, maxsec=600, pat=4, vol=0x7F, tail=2.0):
    """Run the song through the sequencer and the YM30 driver. Returns [(sample, reg, val)] at OPL_RATE."""
    drv = YM30(pat)
    seq = Sequencer(song, drv.midi, loops=loops, volume=vol)
    n = 0
    while not seq.done() and n < maxsec * TIMER_HZ:
        drv.time = n * OPL_RATE // TIMER_HZ
        drv.tick()                                         # the game's callback: drivers first, then the tracks
        seq.interrupt()
        n += 1
    drv.time = n * OPL_RATE // TIMER_HZ
    seq.all_off()
    for k in range(int(tail * TIMER_HZ)):
        drv.time = (n + k) * OPL_RATE // TIMER_HZ
        drv.tick()
    return drv.writes, (n + int(tail * TIMER_HZ)) * OPL_RATE // TIMER_HZ, n / TIMER_HZ

# ---------------------------------------------------------------- output

def write_vgm(path, writes, total):
    body = bytearray(); t = 0
    for (s, r, v) in writes:
        wait = int(s * 44100 / OPL_RATE) - t
        while wait > 0:
            w = min(wait, 65535); body += bytes([0x61]) + struct.pack('<H', w); wait -= w; t += w
        body += bytes([0x5A, r, v])
    end = int(total * 44100 / OPL_RATE)
    while end - t > 0:
        w = min(end - t, 65535); body += bytes([0x61]) + struct.pack('<H', w); t += w
    body += b'\x66'
    hdr = bytearray(0x100)
    hdr[0:4] = b'Vgm '
    struct.pack_into('<I', hdr, 0x04, 0x100 + len(body) - 4)
    struct.pack_into('<I', hdr, 0x08, 0x151)
    struct.pack_into('<I', hdr, 0x18, t)
    struct.pack_into('<I', hdr, 0x34, 0x100 - 0x34)
    struct.pack_into('<I', hdr, 0x50, 3579545)          # YM3812
    open(path, 'wb').write(hdr + body)

def nuked():
    import ctypes, subprocess
    tp = os.path.join(HERE, 'third_party', 'nuked-opl3')
    lib = os.path.join(tp, 'libnukedopl3.so')
    if not os.path.exists(os.path.join(tp, 'opl3.c')):
        sys.exit('Nuked OPL3 is missing: run tools/audio/fetch-deps.sh once (it clones it into tools/audio/third_party/)')
    if not os.path.exists(lib):
        subprocess.check_call(['cc', '-O2', '-shared', '-fPIC', '-o', lib, os.path.join(tp, 'opl3.c')])
    return ctypes.CDLL(lib)

def write_wav(path, writes, total):
    import ctypes
    L = nuked()
    chip = ctypes.create_string_buffer(1 << 16)           # opl3_chip is well under 64 KB
    L.OPL3_Reset(chip, OPL_RATE)
    buf = (ctypes.c_int16 * 2)()
    out = bytearray()
    BLOCK = 4096
    blk = (ctypes.c_int16 * (2 * BLOCK))()
    s = 0; i = 0
    while s < total:
        while i < len(writes) and writes[i][0] <= s:
            L.OPL3_WriteReg(chip, writes[i][1], writes[i][2]); i += 1
        nxt = writes[i][0] if i < len(writes) else total
        n = max(1, min(BLOCK, nxt - s, total - s))
        L.OPL3_GenerateStream(chip, blk, n)
        out += bytes(memoryview(blk).cast('B')[:4 * n]); s += n
    with open(path, 'wb') as f:
        f.write(b'RIFF' + struct.pack('<I', 36 + len(out)) + b'WAVEfmt ' +
                struct.pack('<IHHIIHH', 16, 1, 2, OPL_RATE, OPL_RATE * 4, 4, 16) + b'data' + struct.pack('<I', len(out)))
        f.write(out)

def write_mid(path, song, loops=1, maxsec=600):
    ev = []; now = [0]
    seq = Sequencer(song, lambda m: ev.append((now[0], bytes(m))), loops=loops)
    n = 0
    while not seq.done() and n < maxsec * TIMER_HZ:
        seq.interrupt(); n += 1; now[0] = n
    seq.all_off()
    # 100 interrupts a second: write the file at 100 ticks per quarter at 60 BPM, so one MIDI tick is one interrupt
    trk = bytearray(b'\x00\xFF\x51\x03' + (1000000).to_bytes(3, 'big'))
    last = 0
    for t, m in ev:
        trk += vlq(t - last) + m; last = t
    trk += b'\x00\xFF\x2F\x00'
    open(path, 'wb').write(b'MThd' + struct.pack('>IHHH', 6, 0, 1, 100) + b'MTrk' + struct.pack('>I', len(trk)) + trk)

def vlq(v):
    b = [v & 0x7F]; v >>= 7
    while v: b.append(0x80 | (v & 0x7F)); v >>= 7
    return bytes(reversed(b))

# ---------------------------------------------------------------- commands

CMD = {0xD9: 'end', 0xDA: 'return', 0xDB: 'restart', 0xDC: 'program', 0xDD: 'tempo', 0xDF: 'controller',
       0xE2: 'loop', 0xE3: 'loop-end', 0xE4: 'velocity', 0xE5: 'bend', 0xE6: 'call', 0xE7: 'text', 0xE8: 'sysex',
       0xEA: 'set-4A'}
NOTES = 'C C# D D# E F F# G G# A A# B'.split()

def cmd_list(a):
    import glob
    for p in sorted(glob.glob(os.path.join(GAME, '*.KMS'))):
        s = Song(p)
        ticks = max(sum(e.delta for e in s.events(i)) for i in range(s.ntracks))
        tps = TIMER_HZ * 0x80 / (32000 // s.tempo)
        print('%-9s tempo %3d  %2d tracks  %6.1f s  ' % (s.name, s.tempo, s.ntracks, ticks / tps) +
              ' '.join('%s:ch%d/p%s' % (s.track_name(i) or '-', t['chan'], 'ff' if t['program'] == 0xFF else t['program'])
                       for i, t in enumerate(s.tracks)))

def cmd_dump(a):
    s = Song(find_song(a.song))
    print('%s  version %d  tempo %d (%.2f ticks/s)  %d tracks' % (s.name, s.version, s.tempo,
          TIMER_HZ * 0x80 / (32000 // s.tempo), s.ntracks))
    for i, t in enumerate(s.tracks):
        print('\ntrack %d "%s" at %04X: channel %d (mask %04X), volume %d, pan %d, program %s' % (
            i, s.track_name(i), s.offsets[i], t['chan'], t['mask'], t['vol'], t['pan'],
            'none' if t['program'] == 0xFF else t['program']))
        tick = 0
        for e in s.events(i):
            tick += e.delta
            if e.cmd < 0xD9:
                n = (e.cmd & 0x7F) + NOTE_OFFSET
                txt = 'note %-3s%d (%3d) vel %3s dur %d' % (NOTES[n % 12], n // 12 - 1, n, e.a1 if e.cmd > 0x80 else 'dfl', e.a2)
            else:
                name = CMD.get(e.cmd, 'cmd %02X' % e.cmd)
                if e.cmd in (0xE7,): txt = '%s %r' % (name, e.data.rstrip(b'\0').decode('latin-1'))
                elif e.cmd == 0xE8: txt = '%s %s' % (name, e.data.hex())
                elif e.cmd == 0xDF: txt = '%s %d = %d' % (name, e.a1, e.a2)
                elif e.cmd == 0xE5: txt = '%s %04X' % (name, e.a2)
                elif e.cmd in (0xD9, 0xDA, 0xDB, 0xE3): txt = name
                else: txt = '%s %d' % (name, e.a1)
            if a.raw: txt = '%-44s %s' % (txt, s.kms[e.pos:e.pos + e.len].hex(' '))
            print('  %6d  %s' % (tick, txt))

def outname(a, song, ext):
    if a.o: return a.o
    d = os.path.join(REPO, 'output', 'music'); os.makedirs(d, exist_ok=True)
    return os.path.join(d, song.name + ext)

def songs_for(a):
    import glob
    if a.song.lower() != 'all':
        return [Song(find_song(a.song))]
    out = []
    for p in sorted(glob.glob(os.path.join(GAME, '*.KMS'))):
        n = os.path.basename(p).upper()
        if n.startswith('MT') or n in ('TITLE.KMS',): continue     # MT-32 versions (and the MT-32 TITLE)
        out.append(Song(p))
    return out

def cmd_render(a, kind):
    for s in songs_for(a):
        if kind == 'mid':
            p = outname(a, s, '.mid'); write_mid(p, s, a.loops, a.max); print(p); continue
        writes, total, secs = render_song(s, a.loops, a.max, a.pat, a.vol)
        p = outname(a, s, '.' + kind)
        (write_vgm if kind == 'vgm' else write_wav)(p, writes, total)
        print('%s  %.1f s, %d OPL writes' % (p, secs, len(writes)))

def cmd_play(a):
    import tempfile, shutil, subprocess
    s = Song(find_song(a.song))
    writes, total, secs = render_song(s, a.loops, a.max, a.pat, a.vol)
    p = os.path.join(tempfile.gettempdir(), 'nhl94-%s.wav' % s.name)
    write_wav(p, writes, total)
    for player in (['aplay', '-q'], ['paplay'], ['afplay'], ['ffplay', '-nodisp', '-autoexit', '-loglevel', 'quiet']):
        if shutil.which(player[0]):
            print('playing %s (%.1f s) with %s' % (s.name, secs, player[0]))
            return subprocess.call(player + [p])
    print('no audio player found; the WAV is at', p)

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('cmd', choices=['list', 'dump', 'mid', 'vgm', 'wav', 'play'])
    ap.add_argument('song', nargs='?')
    ap.add_argument('-o')
    ap.add_argument('--raw', action='store_true', help='dump: show the bytes of each event')
    ap.add_argument('--loops', type=int, default=1)
    ap.add_argument('--max', type=float, default=600)
    ap.add_argument('--pat', type=int, default=4)
    ap.add_argument('--vol', type=int, default=0x7F)
    a = ap.parse_args()
    if a.cmd == 'list': return cmd_list(a)
    if not a.song: ap.error('which song?')
    if a.cmd == 'dump': return cmd_dump(a)
    if a.cmd == 'play': return cmd_play(a)
    cmd_render(a, a.cmd)

if __name__ == '__main__':
    main()
