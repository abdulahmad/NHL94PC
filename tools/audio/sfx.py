#!/usr/bin/env python3
"""NHL Hockey '94 (PC) sound banks: PCFFnnn.PAT / .TIM / .DIG.

Reads the retail sound files and exports the Sound Blaster digital samples to WAV.
Format notes are in docs/SFX_FORMAT.md.

  python3 tools/audio/sfx.py list   [GAMEDIR]            # banks, timbres, patch maps
  python3 tools/audio/sfx.py export [GAMEDIR] [OUTDIR]   # PCFF001.DIG -> WAV files

GAMEDIR defaults to lst/game, OUTDIR to output/sfx (both relative to the repo root).
Standard library only.
"""
import os
import struct
import sys
import wave

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Bank number = the nnn in PCFFnnn.TIM. What each bank holds (from its timbre type byte).
BANK_NAMES = {0: "FM (OPL2) instruments", 1: "Sound Blaster digital samples",
              2: "FM (OPL2) extras for AdLib", 3: "PC speaker timbres"}
TIMBRE_TYPES = {0x04: "FM", 0x06: "DIG", 0x08: "BEEP"}  # first byte of each timbre record
# PCFFnnn.PAT: the patch map number is byte 1 of each card's .SCN file.
PAT_NAMES = {1: "Sound Blaster (FM bank 0 + digital bank 1, SBDAC.SCN and MT32SBDA.SCN)", 2: "Roland MT-32 (MT32.SCN)",
             3: "PC speaker (bank 3, PCBEEP.SCN)", 4: "AdLib (FM bank 0 + FM bank 2, ADLIB.SCN)", 5: "AdLib variant (FM bank 0 + FM bank 2), no .SCN selects it"}


def read_table(data):
    """Shared container used by .TIM and .DIG: u32 size, u16 count, count x 4-byte ids, count x u32 offsets, data."""
    size, count = struct.unpack_from("<IH", data, 0)
    ids = [data[6 + 4 * i:10 + 4 * i] for i in range(count)]
    offs = list(struct.unpack_from("<%dI" % count, data, 6 + 4 * count))
    base = 6 + 8 * count
    # A terminator slot has offset ffffffff; every other item runs to the next valid offset.
    valid = sorted(o for o in offs if o != 0xFFFFFFFF) + [len(data) - base]
    items = []
    for o in offs:
        if o == 0xFFFFFFFF:
            items.append(b"")
        else:
            items.append(data[base + o:base + valid[valid.index(o) + 1]])
    return size, ids, items


def load_tim(path):
    data = open(path, "rb").read()
    size, ids, items = read_table(data)
    # ids are 80 bb 00 nn (bank bb, timbre nn = slot + 1). The last slot is a terminator
    # (ffffffff) or, in the digital bank, the tag ".dig" with the DIG file name as its data.
    timbres, extra = {}, None
    for tid, item in zip(ids, items):
        if tid[0] == 0x80:
            timbres[tid[3] | (tid[2] << 8)] = item
        else:
            extra = (tid, item)
    return timbres, extra


def parse_dig_timbre(t):
    """32-byte digital timbre record (type 06)."""
    return {
        "type": t[0],
        "b1": t[1],
        "sample_id": t[2:6],
        "loop": t[0x11],
        "rate": struct.unpack_from("<H", t, 0x12)[0],
        "length": struct.unpack_from("<I", t, 0x14)[0],
        "loop_start": struct.unpack_from("<I", t, 0x18)[0],
        "loop_end": struct.unpack_from("<I", t, 0x1C)[0],
    }


def load_dig(path):
    data = open(path, "rb").read()
    size, ids, items = read_table(data)
    if size != len(data):
        print("warning: %s header size %d != file size %d" % (path, size, len(data)), file=sys.stderr)
    return dict(zip(ids, items)), ids


def load_pat(path):
    """u16 version (6), 256-byte program map (program -> record, 0 = none), then 20-byte records."""
    data = open(path, "rb").read()
    version = struct.unpack_from("<H", data, 0)[0]
    pmap = data[2:0x102]
    recs = [data[0x102 + 20 * i:0x122 + 20 * i] for i in range((len(data) - 0x102) // 20)]
    return version, pmap, recs


def s8(b):
    return b - 256 if b > 127 else b


def write_wav(path, pcm_signed8, rate):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(1)  # WAV 8-bit is unsigned
        w.setframerate(rate)
        w.writeframes(bytes((b ^ 0x80) for b in pcm_signed8))


def cmd_list(gamedir):
    for bank in range(4):
        p = os.path.join(gamedir, "PCFF%03d.TIM" % bank)
        if not os.path.exists(p):
            continue
        timbres, extra = load_tim(p)
        kinds = sorted({TIMBRE_TYPES.get(t[0], "%02x" % t[0]) for t in timbres.values()})
        print("PCFF%03d.TIM  bank %d  %3d timbres  %s  [%s]" % (bank, bank, len(timbres), BANK_NAMES.get(bank, "?"), ",".join(kinds)))
        if extra and extra[0] == b".dig":
            print("              digital data file: %s" % extra[1].rstrip(b"\0").decode("ascii"))
    for n in range(1, 6):
        p = os.path.join(gamedir, "PCFF%03d.PAT" % n)
        if not os.path.exists(p):
            continue
        ver, pmap, recs = load_pat(p)
        used = sum(1 for b in pmap if b)
        print("PCFF%03d.PAT  version %d  %3d programs  %3d records  %s" % (n, ver, used, len(recs), PAT_NAMES.get(n, "?")))

    timp = os.path.join(gamedir, "PCFF001.TIM")
    digp = os.path.join(gamedir, "PCFF001.DIG")
    timbres, _ = load_tim(timp)
    samples, _ = load_dig(digp)
    ver, pmap, recs = load_pat(os.path.join(gamedir, "PCFF001.PAT"))
    users = {}
    for prog in range(256):
        r = pmap[prog]
        if r and recs[r][0] == 1:
            users.setdefault(recs[r][1], []).append("%d(%+d)" % (prog, s8(recs[r][7])))
    print()
    print("Digital timbres (bank 1), with the Sound Blaster programs that use them (transpose in semitones):")
    print("  tim  sample-id  rate   length   secs  loop          programs")
    for n in sorted(timbres):
        d = parse_dig_timbre(timbres[n])
        pcm = samples.get(d["sample_id"], b"")
        loop = "%d-%d" % (d["loop_start"], d["loop_end"]) if d["loop"] else "-"
        print("  %3d  %s  %5d  %6d  %5.2f  %-12s  %s" % (n, d["sample_id"].hex(), d["rate"], len(pcm),
                                                        len(pcm) / float(d["rate"]), loop, " ".join(users.get(n, []))))


def cmd_export(gamedir, outdir):
    os.makedirs(outdir, exist_ok=True)
    timbres, _ = load_tim(os.path.join(gamedir, "PCFF001.TIM"))
    samples, order = load_dig(os.path.join(gamedir, "PCFF001.DIG"))
    seen = set()
    for n in sorted(timbres):
        d = parse_dig_timbre(timbres[n])
        pcm = samples[d["sample_id"]]
        if d["length"] != len(pcm):
            print("warning: timbre %d length %d != sample length %d" % (n, d["length"], len(pcm)), file=sys.stderr)
        name = "tim%02d_%s_%dhz.wav" % (n, d["sample_id"].hex(), d["rate"])
        write_wav(os.path.join(outdir, name), pcm, d["rate"])
        seen.add(d["sample_id"])
        if d["loop"]:
            # A few seconds of the looped sound, as the driver would play it while the note is held.
            body = pcm[:d["loop_end"]]
            loop = pcm[d["loop_start"]:d["loop_end"]]
            while len(body) < 4 * d["rate"]:
                body += loop
            write_wav(os.path.join(outdir, name[:-4] + "_looped.wav"), body, d["rate"])
        print(name)
    for sid in order:  # samples no timbre points at (none in retail, but keep them if a mod adds some)
        if sid not in seen:
            name = "dig_%s_11025hz.wav" % sid.hex()
            write_wav(os.path.join(outdir, name), samples[sid], 11025)
            print(name, "(no timbre; rate assumed)")


def main(argv):
    if len(argv) < 2 or argv[1] not in ("list", "export"):
        print(__doc__)
        return 1
    gamedir = argv[2] if len(argv) > 2 else os.path.join(ROOT, "lst", "game")
    if argv[1] == "list":
        cmd_list(gamedir)
    else:
        cmd_export(gamedir, argv[3] if len(argv) > 3 else os.path.join(ROOT, "output", "sfx"))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
