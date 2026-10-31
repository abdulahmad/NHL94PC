# TODO

- Done: seg056 (resident RTLink manager, `__astart`, overlay thunks). seg057 was the thunk tail and is part of seg056.
- seg000, seg005, and seg001 are done. seg002 is in progress through `SlideDown`. seg003 is one far function and waits until seg002 is source.
- Merge the remaining false split when that segment is disassembled: `seg011` into `seg010`. See `docs/HANDOFF.md`.
- The bytes after the load module are one RTLink segment (relocation list, then the image). The `ovl_*` files are arbitrary 4KB cuts of it. Reslice them to that structure when that area becomes source. Do not disassemble the external `.OVL` files in this repo; they are loaded, not linked into `HOCKEY.EXE`.
- Relocation table as source once the words it points to are labelled.
- Name EACLIB functions from their error-string xrefs.
