# TODO

- Merge the two false splits when those segments are disassembled: `seg011` into `seg010`, `seg057` into `seg056`. They are still separate incbin slices. See `docs/HANDOFF.md`.
- The bytes after the load module are one RTLink segment (relocation list, then the image). The `ovl_*` files are arbitrary 4KB cuts of it. Reslice them to that structure when that area becomes source. Do not disassemble the external `.OVL` files in this repo; they are loaded, not linked into `HOCKEY.EXE`.
- Relocation table as source once the words it points to are labelled.
- Name EACLIB functions from their error-string xrefs.
