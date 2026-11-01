/* bios.c: the BIOS services (video, keyboard, clock, equipment), the mouse driver (int 33h) and an EMS 4.0 driver
 * (int 67h) for the game. */
#include "machine.h"
#include <stdio.h>
#include <string.h>
#include <time.h>

void vga_dac_set(int i, uint8_t r, uint8_t g, uint8_t b);
void vga_dac_get(int i, uint8_t *r, uint8_t *g, uint8_t *b);
void vga_attr_set(int i, uint8_t v);
uint8_t vga_attr_get(int i);
extern uint8_t port61;

#define BDA 0x400u

/* ---- keyboard: scan code -> ASCII for the BIOS buffer ---- */
static const char kb_lo[0x60] =
  "\0\x1b" "1234567890-=\b\tqwertyuiop[]\r\0asdfghjkl;'`\0\\zxcvbnm,./\0*\0 ";
static const char kb_hi[0x60] =
  "\0\x1b" "!@#$%^&*()_+\b\tQWERTYUIOP{}\r\0ASDFGHJKL:\"~\0|ZXCVBNM<>?\0*\0 ";
static int e0_prefix;

static void kbuf_put(uint16_t w)
{
  uint16_t head = rd16(BDA + 0x1A), tail = rd16(BDA + 0x1C), next = tail + 2;
  if (next >= 0x3E) next = 0x1E;
  if (next == head) return;
  wr16(BDA + tail, w);
  wr16(BDA + 0x1C, next);
}

static void bios_kbd_irq(void)
{
  uint8_t sc = port_in(0x60, 1);
  uint8_t flags = rd8(BDA + 0x17);
  if (sc == 0xE0) { e0_prefix = 1; return; }
  int brk = sc & 0x80, code = sc & 0x7F;
  int e0 = e0_prefix; e0_prefix = 0;
  uint8_t bit = 0;
  if (code == 0x2A || code == 0x36) bit = code == 0x2A ? 2 : 1;
  else if (code == 0x1D) bit = 4;
  else if (code == 0x38) bit = 8;
  if (bit) { if (brk) flags &= ~bit; else flags |= bit; wr8(BDA + 0x17, flags); return; }
  if (brk) return;
  uint8_t ascii = 0;
  if (!e0 && code < 0x3A) ascii = (flags & 3) ? kb_hi[code] : kb_lo[code];
  if ((flags & 4) && ascii >= 'a' && ascii <= 'z') ascii -= 0x60;
  if ((flags & 4) && ascii >= 'A' && ascii <= 'Z') ascii -= 0x40;
  if (flags & 8) ascii = 0;
  kbuf_put(code << 8 | ascii);
}

static int int16(void)
{
  uint8_t ah = r_ah();
  switch (ah) {
  case 0x00: case 0x10: {
    for (;;) {
      uint16_t head = rd16(BDA + 0x1A);
      if (head != rd16(BDA + 0x1C)) {
        s_ax(rd16(BDA + head)); head += 2; if (head >= 0x3E) head = 0x1E; wr16(BDA + 0x1A, head); return 1;
      }
      /* nothing yet: run this int again once time has passed */
      cpu_retry();
      return 1;
    }
  }
  case 0x01: case 0x11: {
    uint16_t head = rd16(BDA + 0x1A);
    if (head == rd16(BDA + 0x1C)) { set_zf(1); return 1; }
    s_ax(rd16(BDA + head)); set_zf(0); return 1;
  }
  case 0x02: case 0x12: s_al(rd8(BDA + 0x17)); return 1;
  case 0x03: case 0x05: return 1;
  }
  return 1;
}

/* ---- video ---- */
static int int10(void)
{
  uint8_t ah = r_ah();
  switch (ah) {
  case 0x00:
    vga_set_mode(r_al());
    wr8(BDA + 0x49, r_al() & 0x7F);
    wr16(BDA + 0x4A, (r_al() & 0x7F) == 0x13 || (r_al() & 0x7F) == 0x0D ? 40 : 80);
    wr8(BDA + 0x84, 24);
    return 1;
  case 0x0F: s_al(rd8(BDA + 0x49)); s_ah(rd16(BDA + 0x4A)); s_bh(0); return 1;
  case 0x01: case 0x02: case 0x05: case 0x06: case 0x07: return 1;
  case 0x03: s_dx(0); s_cx(0x0607); return 1;
  case 0x08: s_ax(0x0720); return 1;
  case 0x09: case 0x0A: return 1;
  case 0x0E: if (vga_mode() == 3) { putchar(r_al()); fflush(stdout); } return 1;
  case 0x0B: case 0x0C: return 1;
  case 0x0D: s_al(0); return 1;
  case 0x10:
    switch (r_al()) {
    case 0x00: vga_attr_set(r_bl(), r_bh()); return 1;
    case 0x01: vga_attr_set(0x11, r_bh()); return 1;
    case 0x02: { uint32_t a = lin(r_es(), r_dx()); for (int i = 0; i < 16; i++) vga_attr_set(i, rd8(a + i)); vga_attr_set(0x11, rd8(a + 16)); return 1; }
    case 0x03: return 1;
    case 0x07: s_bh(vga_attr_get(r_bl())); return 1;
    case 0x10: vga_dac_set(r_bx(), r_dh(), r_ch(), r_cl()); return 1;
    case 0x12: { uint32_t a = lin(r_es(), r_dx()); for (int i = 0; i < r_cx(); i++) vga_dac_set(r_bx() + i, rd8(a + i * 3), rd8(a + i * 3 + 1), rd8(a + i * 3 + 2)); return 1; }
    case 0x15: { uint8_t r, g, b; vga_dac_get(r_bl(), &r, &g, &b); s_dh(r); s_ch(g); s_cl(b); return 1; }
    case 0x17: { uint32_t a = lin(r_es(), r_dx()); for (int i = 0; i < r_cx(); i++) { uint8_t r, g, b; vga_dac_get(r_bx() + i, &r, &g, &b); wr8(a + i * 3, r); wr8(a + i * 3 + 1, g); wr8(a + i * 3 + 2, b); } return 1; }
    case 0x1B: return 1;
    }
    return 1;
  case 0x11:
    if (r_al() == 0x30) { s_es(0xC000); s_bp(0); s_cx(16); s_dl(24); }
    return 1;
  case 0x12:
    if (r_bl() == 0x10) { s_bh(0); s_bl(3); s_cx(9); }
    return 1;
  case 0x1A: if (r_al() == 0) { s_al(0x1A); s_bx(0x0008); } return 1;
  case 0x1B: return 1;
  case 0x4F: s_ax(0x0100); return 1; /* no VESA */
  }
  LOG("int 10h AX=%04X\n", r_ax());
  return 1;
}

/* ---- mouse ---- */
static int ms_x, ms_y, ms_btn, ms_show = -1, ms_xmin, ms_xmax = 639, ms_ymin, ms_ymax = 199, ms_mx, ms_my;
static int ms_press[3], ms_release[3], ms_px[3], ms_py[3], ms_rx[3], ms_ry[3];
static int ms_mick_x = 8, ms_mick_y = 16;
static double ms_fx, ms_fy;
int mouse_present = 1;

static void ms_clamp(void)
{
  if (ms_x < ms_xmin) ms_x = ms_xmin; if (ms_x > ms_xmax) ms_x = ms_xmax;
  if (ms_y < ms_ymin) ms_y = ms_ymin; if (ms_y > ms_ymax) ms_y = ms_ymax;
}

void mouse_move(int dx, int dy)
{
  ms_mx += dx; ms_my += dy;
  ms_fx += dx * 8.0 / ms_mick_x; ms_fy += dy * 8.0 / ms_mick_y;
  int ix = (int)ms_fx, iy = (int)ms_fy;
  ms_fx -= ix; ms_fy -= iy;
  ms_x += ix; ms_y += iy; ms_clamp();
}
void mouse_set_pos(int x, int y) { ms_mx += (x - ms_x) * ms_mick_x / 8; ms_my += (y - ms_y) * ms_mick_y / 8; ms_x = x; ms_y = y; ms_clamp(); }
void mouse_get_range(int *x0, int *x1, int *y0, int *y1) { *x0 = ms_xmin; *x1 = ms_xmax; *y0 = ms_ymin; *y1 = ms_ymax; }
void mouse_get_pos(int *x, int *y) { *x = ms_x; *y = ms_y; }

void mouse_buttons(int mask)
{
  for (int b = 0; b < 3; b++) {
    int was = ms_btn & (1 << b), now = mask & (1 << b);
    if (now && !was) { ms_press[b]++; ms_px[b] = ms_x; ms_py[b] = ms_y; }
    if (!now && was) { ms_release[b]++; ms_rx[b] = ms_x; ms_ry[b] = ms_y; }
  }
  ms_btn = mask;
}

static int int33(void)
{
  if (r_ax() != 3 || ms_btn) LOG("int 33h AX=%04X BX=%04X CX=%04X DX=%04X at %04X:%04X ret %04X:%04X\n", r_ax(), r_bx(), r_cx(), r_dx(), r_cs(), r_ip(), rd16(lin(r_ss(), r_bp() + 4)), rd16(lin(r_ss(), r_bp() + 2)));
  if (!mouse_present) return 1;
  switch (r_ax()) {
  case 0x00: case 0x21:
    s_ax(0xFFFF); s_bx(2); ms_show = -1; ms_xmin = 0; ms_xmax = 639; ms_ymin = 0; ms_ymax = 199;
    ms_x = 320; ms_y = 100; ms_mick_x = 8; ms_mick_y = 16; return 1;
  case 0x01: if (ms_show < 0) ms_show++; return 1;
  case 0x02: ms_show--; return 1;
  case 0x03: s_bx(ms_btn); s_cx(ms_x); s_dx(ms_y); return 1;
  case 0x04: ms_x = (int16_t)r_cx(); ms_y = (int16_t)r_dx(); ms_clamp(); return 1;
  case 0x05: { int b = r_bx() & 3; s_ax(ms_btn); s_bx(ms_press[b]); s_cx(ms_px[b]); s_dx(ms_py[b]); ms_press[b] = 0; return 1; }
  case 0x06: { int b = r_bx() & 3; s_ax(ms_btn); s_bx(ms_release[b]); s_cx(ms_rx[b]); s_dx(ms_ry[b]); ms_release[b] = 0; return 1; }
  case 0x07: { int a = (int16_t)r_cx(), b = (int16_t)r_dx(); ms_xmin = a < b ? a : b; ms_xmax = a < b ? b : a; ms_clamp(); return 1; }
  case 0x08: { int a = (int16_t)r_cx(), b = (int16_t)r_dx(); ms_ymin = a < b ? a : b; ms_ymax = a < b ? b : a; ms_clamp(); return 1; }
  case 0x0B: s_cx(ms_mx); s_dx(ms_my); ms_mx = ms_my = 0; return 1;
  case 0x0F: ms_mick_x = r_cx() ? r_cx() : 8; ms_mick_y = r_dx() ? r_dx() : 16; return 1;
  case 0x1A: case 0x1D: case 0x13: case 0x0A: case 0x09: case 0x10: return 1;
  case 0x0C: case 0x14: LOG("mouse event handler %04X:%04X mask %04X (not called)\n", r_es(), r_dx(), r_cx()); return 1;
  case 0x1B: s_bx(50); s_cx(50); s_dx(50); return 1;
  case 0x24: s_bx(0x0626); s_cx(0x0400); return 1;
  }
  LOG("int 33h AX=%04X\n", r_ax());
  return 1;
}

/* ---- EMS 4.0 ---- */
#define EMS_HANDLES 32
static int ems_owner[EMS_PAGES];            /* handle owning each pool page, -1 free */
static int ems_hpages[EMS_HANDLES][EMS_PAGES / 4];
static int ems_hcount[EMS_HANDLES], ems_hused[EMS_HANDLES];
static char ems_hname[EMS_HANDLES][8];
static int ems_saved[EMS_HANDLES][4];

static int ems_free(void) { int n = 0; for (unsigned i = 0; i < EMS_PAGES; i++) if (ems_owner[i] < 0) n++; return n; }

static int ems_grow(int h, int n)
{
  while (ems_hcount[h] < n) {
    unsigned i; for (i = 0; i < EMS_PAGES; i++) if (ems_owner[i] < 0) break;
    if (i == EMS_PAGES) return -1;
    ems_owner[i] = h; ems_hpages[h][ems_hcount[h]++] = i;
  }
  while (ems_hcount[h] > n) {
    int p = ems_hpages[h][--ems_hcount[h]]; ems_owner[p] = -1;
    for (int k = 0; k < 4; k++) if (ems_map[k] == p) ems_map[k] = -1;
  }
  return 0;
}

int ems_int67(void)
{
  uint8_t ah = r_ah();
  int h = r_dx();
  switch (ah) {
  case 0x40: s_ah(0); return 1;
  case 0x41: s_ah(0); s_bx(EMS_FRAME); return 1;
  case 0x42: s_ah(0); s_bx(ems_free()); s_dx(EMS_PAGES); return 1;
  case 0x43: case 0x5A: {
    int n = r_bx();
    if (n > ems_free()) { s_ah(0x88); return 1; }
    for (h = 1; h < EMS_HANDLES; h++) if (!ems_hused[h]) break;
    if (h == EMS_HANDLES) { s_ah(0x85); return 1; }
    ems_hused[h] = 1; ems_hcount[h] = 0; memset(ems_hname[h], 0, 8);
    ems_grow(h, n);
    LOG("EMS alloc %d pages -> handle %d\n", n, h);
    s_dx(h); s_ah(0); return 1;
  }
  case 0x44: {
    int phys = r_al(), log = r_bx();
    if (h >= EMS_HANDLES || !ems_hused[h]) { s_ah(0x83); return 1; }
    if (phys > 3) { s_ah(0x8B); return 1; }
    if (log == 0xFFFF) { ems_map[phys] = -1; s_ah(0); return 1; }
    if (log >= ems_hcount[h]) { s_ah(0x8A); return 1; }
    ems_map[phys] = ems_hpages[h][log]; s_ah(0); return 1;
  }
  case 0x45:
    if (h >= EMS_HANDLES || !ems_hused[h]) { s_ah(0x83); return 1; }
    ems_grow(h, 0); ems_hused[h] = 0; s_ah(0); return 1;
  case 0x46: s_ax(0x0040); return 1;
  case 0x47: if (h < EMS_HANDLES) memcpy(ems_saved[h], ems_map, sizeof ems_map); s_ah(0); return 1;
  case 0x48: if (h < EMS_HANDLES) memcpy(ems_map, ems_saved[h], sizeof ems_map); s_ah(0); return 1;
  case 0x4B: { int n = 0; for (int i = 0; i < EMS_HANDLES; i++) n += ems_hused[i]; s_bx(n + 1); s_ah(0); return 1; }
  case 0x4C: if (h >= EMS_HANDLES || !ems_hused[h]) { s_ah(0x83); return 1; } s_bx(ems_hcount[h]); s_ah(0); return 1;
  case 0x4D: { uint32_t a = lin(r_es(), r_di()); int n = 0;
    for (int i = 1; i < EMS_HANDLES; i++) if (ems_hused[i]) { wr16(a + n * 4, i); wr16(a + n * 4 + 2, ems_hcount[i]); n++; }
    s_bx(n); s_ah(0); return 1; }
  case 0x4E:
    switch (r_al()) {
    case 0: case 2: { if (r_al() == 0 || 1) { uint32_t a = lin(r_es(), r_di()); for (int k = 0; k < 4; k++) wr16(a + k * 2, (uint16_t)ems_map[k]); }
      if (r_al() == 2) { uint32_t a = lin(r_ds(), r_si()); for (int k = 0; k < 4; k++) ems_map[k] = (int16_t)rd16(a + k * 2); }
      s_ah(0); return 1; }
    case 1: { uint32_t a = lin(r_ds(), r_si()); for (int k = 0; k < 4; k++) ems_map[k] = (int16_t)rd16(a + k * 2); s_ah(0); return 1; }
    case 3: s_ax(8); return 1;
    }
    s_ah(0x8F); return 1;
  case 0x50: {
    if (h >= EMS_HANDLES || !ems_hused[h]) { s_ah(0x83); return 1; }
    uint32_t a = lin(r_ds(), r_si());
    for (int i = 0; i < r_cx(); i++) {
      int log = rd16(a + i * 4), ph = rd16(a + i * 4 + 2);
      if (r_al() == 1) ph = (ph - EMS_FRAME) >> 10;
      if (ph < 0 || ph > 3) { s_ah(0x8B); return 1; }
      if (log == 0xFFFF) ems_map[ph] = -1;
      else if (log >= ems_hcount[h]) { s_ah(0x8A); return 1; }
      else ems_map[ph] = ems_hpages[h][log];
    }
    s_ah(0); return 1;
  }
  case 0x51:
    if (h >= EMS_HANDLES || !ems_hused[h]) { s_ah(0x83); return 1; }
    if (ems_grow(h, r_bx())) { s_ah(0x87); return 1; }
    s_bx(ems_hcount[h]); s_ah(0); return 1;
  case 0x52: s_ah(0); s_al(0); return 1;
  case 0x53:
    if (r_al() == 0) { uint32_t a = lin(r_es(), r_di()); for (int i = 0; i < 8; i++) wr8(a + i, ems_hname[h % EMS_HANDLES][i]); }
    else { uint32_t a = lin(r_ds(), r_si()); for (int i = 0; i < 8; i++) ems_hname[h % EMS_HANDLES][i] = rd8(a + i); }
    s_ah(0); return 1;
  case 0x58:
    if (r_al() == 0) { uint32_t a = lin(r_es(), r_di()); for (int k = 0; k < 4; k++) { wr16(a + k * 4, EMS_FRAME + k * 0x400); wr16(a + k * 4 + 2, k); } }
    s_cx(4); s_ah(0); return 1;
  case 0x59:
    if (r_al() == 1) { s_bx(ems_free()); s_dx(EMS_PAGES); s_ah(0); return 1; }
    s_ah(0xA4); return 1;
  }
  LOG("int 67h AX=%04X\n", r_ax());
  s_ah(0x84);
  return 1;
}

/* ---- the rest ---- */
int bios_int(int n)
{
  switch (n) {
  case 0x08: {
    uint32_t t = rd32(BDA + 0x6C) + 1;
    if (t >= 0x1800B0) { t = 0; wr8(BDA + 0x70, 1); }
    wr32(BDA + 0x6C, t);
    return 1;
  }
  case 0x09: bios_kbd_irq(); return 1;
  case 0x10: return int10();
  case 0x11: s_ax(rd16(BDA + 0x10)); return 1;
  case 0x12: s_ax(640); return 1;
  case 0x13: s_ah(0); set_cf(0); return 1;
  case 0x14: case 0x17: s_ah(0); return 1;
  case 0x15:
    switch (r_ah()) {
    case 0x88: s_ax(0); set_cf(0); return 1;
    case 0xC0: set_cf(1); s_ah(0x86); return 1;
    case 0x24: s_ah(0); set_cf(0); return 1;
    case 0x86: set_cf(0); return 1;
    case 0x4F: set_cf(1); return 1;
    case 0x90: case 0x91: s_ah(0); set_cf(0); return 1;
    }
    set_cf(1); s_ah(0x86); return 1;
  case 0x16: return int16();
  case 0x1A:
    switch (r_ah()) {
    case 0x00: { uint32_t t = rd32(BDA + 0x6C); s_cx(t >> 16); s_dx(t); s_al(rd8(BDA + 0x70)); wr8(BDA + 0x70, 0); return 1; }
    case 0x01: wr32(BDA + 0x6C, (uint32_t)r_cx() << 16 | r_dx()); return 1;
    case 0x02: { time_t t = time(0); struct tm *m = localtime(&t);
      #define BCD(x) ((((x) / 10) << 4) | ((x) % 10))
      s_ch(BCD(m->tm_hour)); s_cl(BCD(m->tm_min)); s_dh(BCD(m->tm_sec)); s_dl(0); set_cf(0); return 1; }
    case 0x04: { time_t t = time(0); struct tm *m = localtime(&t);
      s_ch(BCD((m->tm_year + 1900) / 100)); s_cl(BCD(m->tm_year % 100)); s_dh(BCD(m->tm_mon + 1)); s_dl(BCD(m->tm_mday)); set_cf(0); return 1; }
    }
    return 1;
  case 0x33: return int33();
  case 0x05: case 0x1B: case 0x1C: case 0x23: case 0x24: case 0x28: case 0x00: case 0x01: case 0x03: case 0x04: case 0x06:
    if (n == 0x24) s_al(3); /* critical error: fail */
    return 1;
  case 0x20: cpu_quit = 1; return 1;
  }
  LOG("int %02X AX=%04X not handled\n", n, r_ax());
  return 1;
}

void bios_init(void)
{
  memset(ems_owner, 0xFF, sizeof ems_owner);
  wr16(BDA + 0x10, 0x0026 | 0x0002);   /* VGA colour, FPU present, mouse */
  wr16(BDA + 0x13, 640);
  wr16(BDA + 0x1A, 0x1E); wr16(BDA + 0x1C, 0x1E);
  wr16(BDA + 0x80, 0x1E); wr16(BDA + 0x82, 0x3E);
  wr8(BDA + 0x49, 3); wr16(BDA + 0x4A, 80); wr16(BDA + 0x63, 0x3D4); wr8(BDA + 0x84, 24);
  wr16(BDA + 0x08, 0x378);
  wr16(BDA + 0x00, 0x3F8);
  /* the EMS driver's device name, at offset 0Ah of the int 67h vector's segment */
  memcpy(mem + lin(ROM_SEG, 0x000A), "EMMXXXX0", 8);
  {
    time_t t = time(0); struct tm *m = localtime(&t);
    wr32(BDA + 0x6C, (uint32_t)((m->tm_hour * 3600 + m->tm_min * 60 + m->tm_sec) * 18.2065));
  }
}
