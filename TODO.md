# TODO

- Done: seg056 (resident RTLink manager, `__astart`, overlay thunks). seg057 was the thunk tail and is part of seg056.
- seg000, seg005, seg001, seg002, and seg003 are done. seg004 is in progress through `Expand`. seg006 waits until seg004 is source. seg007 is not started.
- Merge the remaining false split when that segment is disassembled: `seg011` into `seg010`. See `docs/HANDOFF.md`.
- The bytes after the load module are one RTLink segment (relocation list, then the image). The `ovl_*` files are arbitrary 4KB cuts of it. Reslice them to that structure when that area becomes source. Do not disassemble the external `.OVL` files in this repo; they are loaded, not linked into `HOCKEY.EXE`.
- Relocation table as source once the words it points to are labelled.
- Name EACLIB functions from their error-string xrefs.
