# Archived tools

These tools turned the extracted segments into labelled source. That work is finished: every segment under `src/`
is now kept by hand, so the tools no longer run against the current layout (they expect `src/seg/segNNN.asm`).
They are kept to show how the source was made.

- `disasm/`: the generator (`gen_root.py`, `gen_data.py`, `regen.sh`) that wrote the segments and DGROUP files.
- `localize.py`: turned address-named labels and numeric branch targets into local labels.
- `label_dgroup.py`: wrote raw DGROUP operands as their labels.

`docs/archive/` holds the per-segment prompt and queue that drove the first pass.
