# TODO

- Overlays: the external `.OVL` files (the game logic) are not disassembled. Do not add them to this build; they are
  loaded, not linked into `HOCKEY.EXE`.
- The bytes after the load module are one RTLink segment (relocation list, then the image). The `ovl_*` files are
  arbitrary 4KB cuts of it. Reslice them to that structure when that area becomes source.
- `seg011` (`pc/null_far2.asm`) is a false split of the file before (`pc/random.asm`); merge them when convenient.
- Relocation table as source once the words it points to are labelled.
- Open questions on names: `docs/HANDOFF.md`, "Unsure / open".
