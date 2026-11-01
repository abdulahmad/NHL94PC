/* vga.c: a register-level VGA. Four 64 KB planes, the sequencer, graphics controller (latches, write modes 0-3,
 * read modes 0-1), CRTC start address / offset / addressing modes, attribute controller and DAC. Chained (mode 13h)
 * and unchained 256-colour pictures and the 16-colour planar modes are drawn from the planes the way the CRTC
 * scans them, so page flipping and split addressing work as on the card. */
#include "machine.h"
#include <string.h>
#include <stdio.h>

static uint8_t plane[4][65536];
static uint8_t latch[4];
static uint8_t seq[8], seq_idx, gc[16], gc_idx, crtc[32], crtc_idx, attr[32], attr_idx, attr_ff, misc = 0x63;
static uint8_t dac[256][3], dac_widx, dac_ridx, dac_comp, dac_rcomp, dac_mask = 0xFF;
static int cur_mode = 3;
int vga_dirty = 1;
int vga_flips, vga_status_reads;                     /* page flips (start address changes), for NHL94_STATS */
uint8_t text_mem[0x8000];          /* B8000 text, kept in conventional memory by cpu.c; unused here */

int vga_mode(void) { return cur_mode; }

static uint32_t offs(uint32_t a, int *pl)
{
  uint32_t o;
  switch ((gc[6] >> 2) & 3) {
  case 0: o = a - 0xA0000; break;
  case 1: if (a >= 0xB0000) return 0xFFFFFFFF; o = a - 0xA0000; break;
  default: return 0xFFFFFFFF;
  }
  if (seq[4] & 8) { *pl = o & 3; return o & 0xFFFC; }          /* chain 4 */
  if (gc[5] & 0x10) { *pl = o & 1; return o & 0xFFFE; }        /* odd/even */
  *pl = -1;
  return o & 0xFFFF;
}

uint8_t vga_read(uint32_t a)
{
  int pl; uint32_t o = offs(a, &pl);
  if (o == 0xFFFFFFFF) return 0xFF;
  for (int i = 0; i < 4; i++) latch[i] = plane[i][o];
  if (pl >= 0) return plane[pl][o];
  if (gc[5] & 8) {                                             /* read mode 1: colour compare */
    uint8_t r = 0;
    for (int b = 0; b < 8; b++) {
      int ok = 1;
      for (int i = 0; i < 4; i++)
        if ((gc[7] >> i) & 1) if ((((latch[i] >> b) & 1)) != ((gc[2] >> i) & 1)) ok = 0;
      if (ok) r |= 1 << b;
    }
    return r;
  }
  return latch[gc[4] & 3];
}

static inline uint8_t alu(uint8_t v, uint8_t l)
{
  switch ((gc[3] >> 3) & 3) {
  case 1: return v & l;
  case 2: return v | l;
  case 3: return v ^ l;
  }
  return v;
}

void vga_write(uint32_t a, uint8_t v)
{
  int pl; uint32_t o = offs(a, &pl);
  if (o == 0xFFFFFFFF) return;
  vga_dirty = 1;
  if (pl >= 0) {
    if (seq[2] & (1 << pl)) plane[pl][o] = v;
    if ((seq[4] & 8) == 0 && (gc[5] & 0x10)) { /* odd/even writes the pair */ }
    return;
  }
  int wm = gc[5] & 3, rot = gc[3] & 7;
  uint8_t mask = gc[8];
  if (wm != 1 && rot) v = (v >> rot) | (v << (8 - rot));
  for (int i = 0; i < 4; i++) {
    if (!(seq[2] & (1 << i))) continue;
    uint8_t d;
    switch (wm) {
    case 0:
      d = (gc[1] & (1 << i)) ? ((gc[0] & (1 << i)) ? 0xFF : 0) : v;
      d = alu(d, latch[i]);
      d = (d & mask) | (latch[i] & ~mask);
      break;
    case 1: d = latch[i]; break;
    case 2:
      d = (v & (1 << i)) ? 0xFF : 0;
      d = alu(d, latch[i]);
      d = (d & mask) | (latch[i] & ~mask);
      break;
    default: {
      uint8_t m = mask & v;
      d = (gc[0] & (1 << i)) ? 0xFF : 0;
      d = alu(d, latch[i]);
      d = (d & m) | (latch[i] & ~m);
      break; }
    }
    plane[i][o] = d;
  }
}

static double retrace_t0;
uint8_t vga_in(uint16_t port)
{
  switch (port) {
  case 0x3C0: return attr_idx;
  case 0x3C1: return attr[attr_idx & 0x1F];
  case 0x3C2: return 0x10;
  case 0x3C4: return seq_idx;
  case 0x3C5: return seq[seq_idx & 7];
  case 0x3C6: return dac_mask;
  case 0x3C7: return 0;
  case 0x3C8: return dac_widx;
  case 0x3C9: { uint8_t r = dac[dac_ridx][dac_rcomp]; if (++dac_rcomp == 3) { dac_rcomp = 0; dac_ridx++; } return r; }
  case 0x3CC: return misc;
  case 0x3CE: return gc_idx;
  case 0x3CF: return gc[gc_idx & 15];
  case 0x3D4: case 0x3B4: return crtc_idx;
  case 0x3D5: case 0x3B5: return crtc[crtc_idx & 31];
  case 0x3DA: case 0x3BA: {
    vga_status_reads++;
    attr_ff = 0;
    double t = host_time() - retrace_t0;
    double per = 1.0 / 70.086, ph = t / per - (long long)(t / per);
    uint8_t r = 0;
    if (ph > 0.95) r |= 8 | 1;                 /* vertical retrace (and blank) */
    else { long long line = (long long)(t * 31469.0); if ((line & 7) == 0) r |= 1; }
    return r;
  }
  }
  return 0xFF;
}

void vga_out(uint16_t port, uint8_t v)
{
  switch (port) {
  case 0x3C0:
    if (!attr_ff) attr_idx = v; else { attr[attr_idx & 0x1F] = v; vga_dirty = 1; }
    attr_ff ^= 1; return;
  case 0x3C2: misc = v; return;
  case 0x3C4: seq_idx = v; return;
  case 0x3C5: seq[seq_idx & 7] = v; return;
  case 0x3C6: dac_mask = v; vga_dirty = 1; return;
  case 0x3C7: dac_ridx = v; dac_rcomp = 0; return;
  case 0x3C8: dac_widx = v; dac_comp = 0; return;
  case 0x3C9:
    dac[dac_widx][dac_comp] = v & 0x3F; vga_dirty = 1;
    if (++dac_comp == 3) { dac_comp = 0; dac_widx++; }
    return;
  case 0x3CE: gc_idx = v; return;
  case 0x3CF: gc[gc_idx & 15] = v; return;
  case 0x3D4: case 0x3B4: crtc_idx = v; return;
  case 0x3D5: case 0x3B5:
    if ((crtc_idx & 31) == 0x0C && crtc[0x0C] != v) vga_flips++;
    crtc[crtc_idx & 31] = v; vga_dirty = 1; return;
  }
}

/* ---- DAC access for the BIOS ---- */
void vga_dac_set(int i, uint8_t r, uint8_t g, uint8_t b) { dac[i & 255][0] = r & 63; dac[i & 255][1] = g & 63; dac[i & 255][2] = b & 63; vga_dirty = 1; }
void vga_dac_get(int i, uint8_t *r, uint8_t *g, uint8_t *b) { *r = dac[i & 255][0]; *g = dac[i & 255][1]; *b = dac[i & 255][2]; }
void vga_attr_set(int i, uint8_t v) { attr[i & 31] = v; vga_dirty = 1; }
uint8_t vga_attr_get(int i) { return attr[i & 31]; }

static const uint8_t ega_pal[16][3] = {
  {0,0,0},{0,0,42},{0,42,0},{0,42,42},{42,0,0},{42,0,42},{42,21,0},{42,42,42},
  {21,21,21},{21,21,63},{21,63,21},{21,63,63},{63,21,21},{63,21,63},{63,63,21},{63,63,63} };

static void load_default_dac(void)
{
  for (int i = 0; i < 16; i++) vga_dac_set(i, ega_pal[i][0], ega_pal[i][1], ega_pal[i][2]);
  for (int i = 16; i < 32; i++) { int g = (i - 16) * 63 / 15; vga_dac_set(i, g, g, g); }
}

void vga_set_mode(int mode)
{
  int clear = !(mode & 0x80);
  mode &= 0x7F;
  memset(seq, 0, sizeof seq); memset(gc, 0, sizeof gc); memset(crtc, 0, sizeof crtc);
  for (int i = 0; i < 16; i++) attr[i] = i;
  crtc[0x18] = 0xFF; 
  attr[0x12] = 0x0F; attr[0x13] = 0; attr[0x14] = 0;
  seq[0] = 3; seq[1] = 0x01; seq[2] = 0x0F; seq[4] = 0x06;
  gc[5] = 0; gc[6] = 0x05; gc[7] = 0x0F; gc[8] = 0xFF;
  switch (mode) {
  case 0x13:
    seq[4] = 0x0E; gc[5] = 0x40; attr[0x10] = 0x41;
    crtc[0x01] = 79; crtc[0x09] = 0x41; crtc[0x12] = 0x8F; crtc[0x07] = 0x1F; crtc[0x13] = 40; crtc[0x14] = 0x40; crtc[0x17] = 0xA3;
    break;
  case 0x12: case 0x11:
    attr[0x10] = 0x01; crtc[0x01] = 79; crtc[0x09] = 0x40; crtc[0x12] = 0xDF; crtc[0x07] = 0x3E; crtc[0x13] = 40; crtc[0x17] = 0xE3;
    break;
  case 0x10:
    attr[0x10] = 0x01; crtc[0x01] = 79; crtc[0x09] = 0x40; crtc[0x12] = 0x5D; crtc[0x07] = 0x1F; crtc[0x13] = 40; crtc[0x17] = 0xE3;
    break;
  case 0x0D:
    attr[0x10] = 0x01; crtc[0x01] = 39; crtc[0x09] = 0xC0; crtc[0x12] = 0x8F; crtc[0x07] = 0x1F; crtc[0x13] = 20; crtc[0x17] = 0xE3;
    break;
  default: /* text */
    gc[5] = 0x10; gc[6] = 0x0E; seq[4] = 0x02; seq[2] = 3;
    crtc[0x01] = 79; crtc[0x09] = 0x4F; crtc[0x12] = 0x8F; crtc[0x07] = 0x1F; crtc[0x13] = 40; crtc[0x17] = 0xA3;
    break;
  }
  if (mode == 0x13) {
    /* the BIOS's 256-colour default palette is close enough: EGA colours, greys, then a colour wheel */
    load_default_dac();
    for (int i = 32; i < 256; i++) vga_dac_set(i, (i * 7) & 63, (i * 3) & 63, (i * 5) & 63);
  } else load_default_dac();
  if (clear) for (int i = 0; i < 4; i++) memset(plane[i], 0, sizeof plane[i]);
  cur_mode = mode;
  vga_dirty = 1;
  LOG("video mode %02X\n", mode);
}

void vga_init(void) { vga_set_mode(3); retrace_t0 = host_time(); }

/* Draw the picture the CRTC would show. Returns its size; dst holds w*h palette indices. */
void vga_render(uint8_t *dst, int *pw, int *ph, uint32_t pal[256])
{
  int graphics = gc[6] & 1;
  int vde = crtc[0x12] | ((crtc[0x07] & 2) << 7) | ((crtc[0x07] & 0x40) << 3);
  int msl = (crtc[0x09] & 0x1F) + 1;
  if (crtc[0x09] & 0x80) msl *= 2;
  int lines = (vde + 1) / msl;
  int chars = crtc[0x01] + 1;
  uint32_t start = crtc[0x0C] << 8 | crtc[0x0D];
  uint32_t pitch = crtc[0x13] * 2;
  int shift = (crtc[0x14] & 0x40) ? 2 : (crtc[0x17] & 0x40) ? 0 : 1;
  int c256 = attr[0x10] & 0x40;
  /* line compare: the scan line after it shows memory from address 0 (a split screen, e.g. the game's score bar) */
  int lc = crtc[0x18] | ((crtc[0x07] & 0x10) << 4) | ((crtc[0x09] & 0x40) << 3);
  int split = (lc + 1 + msl - 1) / msl;
  if (lines > 600) lines = 600;
  if (lines < 1) lines = 1;
  for (int i = 0; i < 256; i++) {
    int j = i & dac_mask;
    pal[i] = (uint32_t)(dac[j][0] * 255 / 63) << 16 | (uint32_t)(dac[j][1] * 255 / 63) << 8 | (dac[j][2] * 255 / 63);
  }
  if (!graphics) {
    /* text mode: not used by the game beyond start-up and exit; show black */
    *pw = 640; *ph = 400; memset(dst, 0, 640 * 400); return;
  }
  if (c256) {
    int w = chars * 4;
    if (w > 800) w = 800;
    for (int y = 0; y < lines; y++) {
      uint32_t addr = y >= split ? (y - split) * pitch : start + y * pitch;
      uint8_t *d = dst + y * w;
      for (int c = 0; c < chars; c++, addr++) {
        uint32_t o = (addr << shift) & 0xFFFF;
        d[c * 4 + 0] = plane[0][o]; d[c * 4 + 1] = plane[1][o]; d[c * 4 + 2] = plane[2][o]; d[c * 4 + 3] = plane[3][o];
      }
    }
    *pw = w; *ph = lines;
  } else {
    int w = chars * 8;
    if (w > 800) w = 800;
    for (int y = 0; y < lines; y++) {
      uint32_t addr = y >= split ? (y - split) * pitch : start + y * pitch;
      uint8_t *d = dst + y * w;
      for (int c = 0; c < chars; c++, addr++) {
        uint32_t o = (addr << shift) & 0xFFFF;
        uint8_t p0 = plane[0][o], p1 = plane[1][o], p2 = plane[2][o], p3 = plane[3][o];
        for (int b = 0; b < 8; b++) {
          int bit = 7 - b;
          int ci = ((p0 >> bit) & 1) | ((p1 >> bit) & 1) << 1 | ((p2 >> bit) & 1) << 2 | ((p3 >> bit) & 1) << 3;
          ci &= attr[0x12];
          uint8_t a = attr[ci];
          if (attr[0x10] & 0x80) a = (a & 0x0F) | (attr[0x14] & 0x0F) << 4;
          else a = (a & 0x3F) | (attr[0x14] & 0x0C) << 4;
          d[c * 8 + b] = a;
        }
      }
    }
    *pw = w; *ph = lines;
  }
}
