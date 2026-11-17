#!/usr/bin/env python3
# make_ovlmap.py: write ovlmap.json, the layout of the 20 external RTLink overlays (.OVL), from the section table in
# HOCKEY.EXE and the overlay files in lst/game/.
#   python3 tools/disasm/make_ovlmap.py
# For each overlay: its file, load paragraph, relocation count, where the image starts (the paragraph after the
# relocation list), the memory size, the linker segments inside it (every paragraph a relocation is framed at or
# points to, and every paragraph a resident thunk jumps to) and the far entries other code uses (thunks, other
# overlays). Segment names and files keep what an existing ovlmap.json gives them.
import hashlib, json, os, struct

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
EXE = open(os.path.join(ROOT, 'lst', 'HOCKEY.EXE'), 'rb').read()
MGR = 0x1C00 + 0x1B35 * 16          # file offset of the overlay manager segment
TABLE, NREC, RECSZ = 0xD33, 20, 18  # 21 records; the last one is the segment stored in HOCKEY.EXE
# overlays that are resident together, so one far-calls the other directly: GAME stays loaded under AI and INIT,
# FADES under each FADESn
COEXIST = {'GAME': {'AI', 'INIT'}, 'FADES': {f'FADES{n}' for n in range(1, 13)}}


def records():
    out = []
    for i in range(NREC):
        para, name_ptr, pos, flags, mem, nrel, ret, sec, img = struct.unpack_from('<9H', EXE, MGR + TABLE + RECSZ * i)
        name = EXE[MGR + name_ptr + 1:MGR + name_ptr + 41].split(b'\0')[0].decode('latin1').upper()
        path = os.path.join('lst', 'game', name)
        data = open(os.path.join(ROOT, path), 'rb').read()
        image = (4 * nrel + 15) // 16 * 16
        rel = [struct.unpack_from('<HH', data, 4 * k) for k in range(nrel)]
        out.append(dict(index=i, name=name.split('.')[0], file=path, para=para, mem=mem, relocs=nrel, image=image,
                        img=data[image:], rel=rel, size=len(data), sha1=hashlib.sha1(data).hexdigest()))
    return out


def thunks():
    seg = EXE[MGR:MGR + 0x3000]
    out = []
    for k in range(len(seg) - 9):
        if seg[k] == 0xE8 and seg[k + 3] == 0xEA:
            off, para, idx = struct.unpack_from('<HHH', seg, k + 4)
            out.append((idx, para, off))
    return out


def main():
    R = records()
    T = thunks()
    old = {}
    p = os.path.join(ROOT, 'ovlmap.json')
    if os.path.exists(p):
        old = {o['name']: o for o in json.load(open(p))['overlays']}
    far = {}                      # (para, off) far calls from any overlay
    for o in R:
        for off, f in o['rel']:
            q = (f - o['para']) * 16 + off
            v, w = struct.unpack_from('<H', o['img'], q)[0], struct.unpack_from('<H', o['img'], q - 2)[0]
            if q >= 3 and o['img'][q - 3] in (0x9A, 0xEA):
                far.setdefault((v, w), set()).add(o['name'])
    ovls = []
    for o in R:
        end = o['para'] + (len(o['img']) + 15) // 16
        ent = {(pa, off) for idx, pa, off in T if idx == o['index'] and o['para'] <= pa < end}
        paras = {o['para']}
        for off, f in o['rel']:
            paras.add(f)
            v = struct.unpack_from('<H', o['img'], (f - o['para']) * 16 + off)[0]
            if o['para'] <= v < end:
                paras.add(v)
        paras |= {pa for pa, _ in ent}
        segs = sorted(x for x in paras if o['para'] <= x < end)
        # far calls from another overlay into one of this overlay's own segments (GAME from AI and INIT, FADES
        # from FADES1-12): those overlays are resident together
        for (pa, off), who in far.items():
            if pa in segs and who & COEXIST.get(o['name'], set()):
                ent.add((pa, off))
        lo = o['name'].lower()
        prev = {s['para']: s for s in old.get(o['name'], {}).get('segments', [])}
        segments = []
        for k, pa in enumerate(segs):
            nxt = segs[k + 1] if k + 1 < len(segs) else None
            size = ((nxt - pa) * 16) if nxt else len(o['img']) - (pa - o['para']) * 16
            nm = prev.get(pa, {}).get('name', f'{lo}_{k:02d}')
            fl = prev.get(pa, {}).get('file', f'ovl/{lo}/{nm}.asm')
            segments.append(dict(name=nm, para=pa, size=size, file=fl))
        ovls.append(dict(name=o['name'], file=o['file'], index=o['index'], para=o['para'], mem=o['mem'],
                         relocs=o['relocs'], image=o['image'], size=o['size'], sha1=o['sha1'], segments=segments,
                         entries=sorted([list(e) for e in ent])))
    json.dump({'overlays': ovls}, open(p, 'w'), indent=1)
    for o in ovls:
        print(f"{o['name']:8} para {o['para']:04X} {len(o['segments']):2} segments, {len(o['entries']):3} entries")


if __name__ == '__main__':
    main()
