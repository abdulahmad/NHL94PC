# PPV shape banks (NHL 94 PC)

NHL 94 PC `.PPV` files are not the NHL 95 PC format. NHL 95 PC uses an SHPI bank of SPIT shapes, but NHL 94 PC stores Mode X planar shapes, with each plane PackBits-packed. `.QPP` files hold the same bank layout, EA-packed (`30 FB` Huffman or `46 FB`).

The decoder, BMP exporter, browser viewer and full format notes are in EA-NHL-Tools: [`PPV94-To-BMP`](https://github.com/abdulahmad/EA-NHL-Tools/tree/main/PPV94-To-BMP). All 27 retail PPVs in `lst/game/` decode exactly: every plane ends on its terminator, every shape ends at the next entry's offset, and the size field in each bank header matches. The demo's 21 PPVs decode exactly too.

## Summary

- Bank: `u32 unpackedSize`, `u16 count`, `count` × 4-char names, `count` × `u32` offsets (relative to `6 + 8*count`). Files are padded to 16 bytes.
- Shape: a 16-byte header (`s16 width/4, height, hotX, hotY, srcX?, srcY?, ?`, `u16 0x0010`), then planes 0–3. Each plane is `(width/4)*height` bytes once unpacked. Pixel `x` is in plane `x & 3`, byte `x >> 2`.
- Plane code: `00` ends the plane, `01..7F` repeats the next byte n times, `80..FF` copies `256-n` literal bytes. Index `FF` is transparent.
- `!pal` / `!bck` / `!err` entries: the same header, followed by 768 raw bytes of 6-bit VGA RGB.
- `HOMEPALS.BIN` / `AWAYPALS.BIN`: 26 × 448 bytes. Each record holds 64 colors for slots `0x80..0xBF`, a 128-byte remap for pixels `0x00..0x7F`, and a 128-byte remap for pixels `0x80..0xFF`. The record order follows the team table at file offset `0x32DE2`.

## Code

- seg028 (file `0x11AF0`), around `+0x8EE..+0xAEC`: the clipped blitter. It draws a packed shape straight to VGA, one plane at a time: it sets the map mask through `out 3C4h`, then runs `lodsb / or al,al / jg run / jl literal / jz next plane`. When this segment is disassembled, name it after that job (for example `DrawPackedShape`).
- `.PPV` and `.QPP` extension strings are at file offsets `0x24CEB` / `0x24CF0`.
- Not traced yet: the loader that expands a bank into `unpackedSize` bytes, the meaning of header words `+8`, `+10`, `+12`, and the code that loads team palettes.
