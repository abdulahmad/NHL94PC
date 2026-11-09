/* cpu.c: the CPU (libx86emu) wired to the emulated PC.
 *
 * Memory: one flat array for the first 1 MB + HMA. The VGA window (A0000-AFFFF) goes to vga.c (planes, latches),
 * the EMS page frame (E0000-EFFFF) to the EMS pool. I/O goes to pc.c.
 *
 * Interrupts: every vector starts pointing at a stub in our ROM segment (F000). The stub for vector n is
 * `int n` / `retf 2`: when an `int n` runs and the vector still points at our stub, the host services it in C
 * (dos.c, bios.c) and the instruction ends there; when the game has hooked the vector, the CPU follows the
 * vector as usual, and the game's handler reaching our stub (chaining to the old vector) lands on that same
 * `int n`, which the host then services. Hardware interrupts are delivered between instruction slices. */
#include "machine.h"
#include "include/x86emu_int.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

x86emu_t *cpu;
uint8_t *mem;
uint8_t *ems;
int ems_map[4] = { -1, -1, -1, -1 };
volatile int cpu_quit;

static inline uint8_t *ems_byte(uint32_t a)
{
  int p = (a - 0xE0000u) >> 14;
  if (ems_map[p] < 0) return NULL;
  return ems + (size_t)ems_map[p] * 16384u + (a & 0x3FFFu);
}

uint8_t rd8(uint32_t a)
{
  if (a >= MEM_SIZE) a &= 0xFFFFF;
  if (a >= 0xA0000u && a < 0xB0000u) return vga_read(a);
  if (a >= 0xE0000u && a < 0xF0000u) { uint8_t *p = ems_byte(a); return p ? *p : 0xFF; }
  return mem[a];
}

void wr8(uint32_t a, uint8_t v)
{
  if (a >= MEM_SIZE) a &= 0xFFFFF;
  if (a >= 0xA0000u && a < 0xB0000u) { vga_write(a, v); return; }
  if (a >= 0xE0000u && a < 0xF0000u) { uint8_t *p = ems_byte(a); if (p) *p = v; return; }
  if (a >= 0xF0000u && a < 0x100000u) return; /* ROM */
  mem[a] = v;
}

static inline int plain(uint32_t a, int n)
{
  uint32_t e = a + n - 1;
  return e < 0xA0000u || (a >= 0xB0000u && e < 0xE0000u) || (a >= 0x100000u && e < MEM_SIZE);
}

uint16_t rd16(uint32_t a) { if (plain(a, 2)) return mem[a] | mem[a + 1] << 8; return rd8(a) | rd8(a + 1) << 8; }
uint32_t rd32(uint32_t a) { return rd16(a) | (uint32_t)rd16(a + 2) << 16; }
void wr16(uint32_t a, uint16_t v) { if (plain(a, 2)) { mem[a] = v; mem[a + 1] = v >> 8; return; } wr8(a, v); wr8(a + 1, v >> 8); }
void wr32(uint32_t a, uint32_t v) { wr16(a, v); wr16(a + 2, v >> 16); }

static unsigned memio(x86emu_t *emu, u32 addr, u32 *val, unsigned type)
{
  unsigned bits = type & 0xFF;
  (void)emu;
  switch (type & ~0xFFu) {
  case X86EMU_MEMIO_R:
  case X86EMU_MEMIO_X:
    if (bits == X86EMU_MEMIO_8 || bits == X86EMU_MEMIO_8_NOPERM) *val = rd8(addr);
    else if (bits == X86EMU_MEMIO_16) *val = rd16(addr);
    else *val = rd32(addr);
    return 0;
  case X86EMU_MEMIO_W:
    if (bits == X86EMU_MEMIO_8 || bits == X86EMU_MEMIO_8_NOPERM) wr8(addr, *val);
    else if (bits == X86EMU_MEMIO_16) wr16(addr, *val);
    else wr32(addr, *val);
    return 0;
  case X86EMU_MEMIO_I:
    *val = port_in(addr, bits == X86EMU_MEMIO_8 ? 1 : bits == X86EMU_MEMIO_16 ? 2 : 4);
    return 0;
  case X86EMU_MEMIO_O:
    port_out(addr, *val, bits == X86EMU_MEMIO_8 ? 1 : bits == X86EMU_MEMIO_16 ? 2 : 4);
    return 0;
  }
  return 0;
}

/* ---- registers ---- */
uint32_t r_eax(void) { return cpu->x86.R_EAX; }
#define REG16(n, R) uint16_t r_##n(void) { return cpu->x86.R; }
REG16(ax, R_AX) REG16(bx, R_BX) REG16(cx, R_CX) REG16(dx, R_DX) REG16(si, R_SI) REG16(di, R_DI) REG16(bp, R_BP)
REG16(sp, R_SP) REG16(ip, R_IP)
uint16_t r_ds(void) { return cpu->x86.R_DS; }
uint16_t r_es(void) { return cpu->x86.R_ES; }
uint16_t r_ss(void) { return cpu->x86.R_SS; }
uint16_t r_cs(void) { return cpu->x86.R_CS; }
#define SREG16(n, R) void s_##n(uint16_t v) { cpu->x86.R = v; }
SREG16(ax, R_AX) SREG16(bx, R_BX) SREG16(cx, R_CX) SREG16(dx, R_DX) SREG16(si, R_SI) SREG16(di, R_DI) SREG16(bp, R_BP)
void s_es(uint16_t v) { x86emu_set_seg_register(cpu, cpu->x86.R_ES_SEL, v); }
void s_ds(uint16_t v) { x86emu_set_seg_register(cpu, cpu->x86.R_DS_SEL, v); }
#define REG8(n, R) uint8_t r_##n(void) { return cpu->x86.R; } void s_##n(uint8_t v) { cpu->x86.R = v; }
REG8(ah, R_AH) REG8(al, R_AL) REG8(bh, R_BH) REG8(bl, R_BL) REG8(ch, R_CH) REG8(cl, R_CL) REG8(dh, R_DH) REG8(dl, R_DL)

/* Flags set by a service land in the caller's flags: our stubs end with retf 2, so the live FLAGS are returned. */
void set_cf(int on) { if (on) cpu->x86.R_FLG |= F_CF; else cpu->x86.R_FLG &= ~F_CF; }
void set_zf(int on) { if (on) cpu->x86.R_FLG |= F_ZF; else cpu->x86.R_FLG &= ~F_ZF; }

/* ---- vectors and the ROM ---- */
uint16_t rom_stub(int v) { return 0x1000 + v * 8; }

void cpu_set_vector(int n, uint16_t seg, uint16_t off) { wr16(n * 4, off); wr16(n * 4 + 2, seg); }
void cpu_get_vector(int n, uint16_t *seg, uint16_t *off) { *off = rd16(n * 4); *seg = rd16(n * 4 + 2); }

static void push16(uint16_t v)
{
  cpu->x86.R_SP -= 2;
  wr16(lin(cpu->x86.R_SS, cpu->x86.R_SP), v);
}

static int intr(x86emu_t *emu, u8 num, unsigned type)
{
  uint16_t seg, off;
  (void)emu;
  if ((type & 0xFF) != INTR_TYPE_SOFT) {
    uint16_t s, o;
    cpu_get_vector(num, &s, &o);
    if (s == ROM_SEG) {
      fprintf(stderr, "CPU exception %02X at %04X:%04X\n", num, cpu->x86.saved_cs, cpu->x86.saved_eip);
      cpu_dump("exception");
      cpu_quit = 1;
      x86emu_stop(cpu);
      return 1;
    }
    return 0; /* follow the vector (the C runtime hooks int 0) */
  }
  cpu_get_vector(num, &seg, &off);
  /* an int inside our ROM is always a service request; otherwise only while the vector is still our plain stub */
  if (cpu->x86.R_CS != ROM_SEG && (seg != ROM_SEG || off != rom_stub(num))) return 0;
  switch (num) {
  case 0x21: return dos_int21() || 1;
  case 0x2F: dos_int2f(); return 1;
  case 0x67: ems_int67(); return 1;
  default: return bios_int(num) || 1;
  }
}

/* No FPU: an ESC (x87) instruction does nothing, as on a PC without a coprocessor. The game's C runtime tests
 * for an FPU with fninit / fnstcw and uses its own floating point emulator when the control word stays 0. */
static void esc_nofpu(x86emu_t *emu, u8 op1)
{
  int mod, rh, rl;
  (void)op1;
  fetch_decode_modrm(emu, &mod, &rh, &rl);
  if (mod != 3) decode_rm_address(emu, mod, rl);
}

/* ins / outs (6Ch-6Fh), replacing libx86emu's: its outs reads ES:SI instead of DS:SI (or the segment override) and
 * both step the index by 1 for words. The game writes the VGA palette with rep outsb. */
static void string_io(x86emu_t *emu, u8 op1)
{
  int size = (op1 & 1) ? (MODE_DATA32 ? 4 : 2) : 1, out = op1 >= 0x6E;
  int a32 = MODE_ADDR32 ? 1 : 0;
  s32 inc = (ACCESS_FLAG(F_DF) ? -1 : 1) * size;
  u32 count = MODE_REP ? (a32 ? emu->x86.R_ECX : emu->x86.R_CX) : 1;
  sel_t *src = emu->x86.default_seg ? emu->x86.default_seg : emu->x86.seg + R_DS_INDEX;
  while (count--) {
    if (out) {
      u32 si = a32 ? emu->x86.R_ESI : emu->x86.R_SI;
      if (size == 1) store_io_byte(emu, emu->x86.R_DX, fetch_data_byte_abs(emu, src, si));
      else if (size == 2) store_io_word(emu, emu->x86.R_DX, fetch_data_word_abs(emu, src, si));
      else store_io_long(emu, emu->x86.R_DX, fetch_data_long_abs(emu, src, si));
      if (a32) emu->x86.R_ESI += inc; else emu->x86.R_SI += inc;
    } else {
      u32 di = a32 ? emu->x86.R_EDI : emu->x86.R_DI;
      sel_t *es = emu->x86.seg + R_ES_INDEX;
      if (size == 1) store_data_byte_abs(emu, es, di, fetch_io_byte(emu, emu->x86.R_DX));
      else if (size == 2) store_data_word_abs(emu, es, di, fetch_io_word(emu, emu->x86.R_DX));
      else store_data_long_abs(emu, es, di, fetch_io_long(emu, emu->x86.R_DX));
      if (a32) emu->x86.R_EDI += inc; else emu->x86.R_DI += inc;
    }
  }
  if (MODE_REP) { if (a32) emu->x86.R_ECX = 0; else emu->x86.R_CX = 0; }
}

/* ---- game hooks ----
 * A few of the game's routines tell the host what the game is doing: an int3 (CCh) is written over the first instruction of each
 * (in memory only, after the EXE is loaded, and only when the bytes there are the expected ones). When the CPU reaches one, the host
 * notes the time and does that instruction itself, then the game goes on. The instructions replaced are simple: push r16, mov r8 from
 * [imm16] (DS), cmp word [imm16] (DS) with a sign-extended byte. */
static struct { uint32_t lin; uint8_t orig[5]; int len; struct hook_hit *hit; } hooks[8];
static int nhooks;
static void (*cc_orig)(x86emu_t *, u8);
static struct hook_hit text_in, text_out;               /* the game's line editor (cpu_text_find) */

static void op_cc(x86emu_t *emu, u8 op1)
{
  uint32_t a = emu->x86.R_CS_BASE + emu->x86.R_EIP - 1;
  for (int i = 0; i < nhooks; i++) {
    if (hooks[i].lin != a) continue;
    const uint8_t *o = hooks[i].orig;
    hooks[i].hit->t = host_time(); hooks[i].hit->ds = emu->x86.R_DS; hooks[i].hit->ss = emu->x86.R_SS; hooks[i].hit->sp = emu->x86.R_SP;
    hooks[i].hit->count++;
    if (getenv("NHL94_TEXTLOG") && (hooks[i].hit == &text_in || hooks[i].hit == &text_out)) fprintf(stderr, "text editor %s hit %u\n", hooks[i].hit == &text_in ? "enter" : "leave", hooks[i].hit->count);
    hooks[i].hit->tsc = emu->x86.R_TSC;
    if (o[0] >= 0x50 && o[0] <= 0x57) {                         /* push r16 */
      uint16_t v;
      switch (o[0] - 0x50) {
      case 0: v = emu->x86.R_AX; break; case 1: v = emu->x86.R_CX; break; case 2: v = emu->x86.R_DX; break;
      case 3: v = emu->x86.R_BX; break; case 4: v = emu->x86.R_SP; break; case 5: v = emu->x86.R_BP; break;
      case 6: v = emu->x86.R_SI; break; default: v = emu->x86.R_DI; break;
      }
      emu->x86.R_SP -= 2;
      wr16(lin(emu->x86.R_SS, emu->x86.R_SP), v);
    } else if (o[0] == 0xC8 && o[3] == 0) {                     /* enter imm16, 0 */
      emu->x86.R_SP -= 2;
      wr16(lin(emu->x86.R_SS, emu->x86.R_SP), emu->x86.R_BP);
      emu->x86.R_BP = emu->x86.R_SP;
      emu->x86.R_SP -= o[1] | o[2] << 8;
    } else if (o[0] == 0x0B && o[1] == 0xC0) {                  /* or ax, ax */
      uint16_t r = emu->x86.R_AX;
      emu->x86.R_FLG &= ~(F_CF | F_ZF | F_SF | F_OF | F_PF);
      if (!r) emu->x86.R_FLG |= F_ZF;
      if (r & 0x8000) emu->x86.R_FLG |= F_SF;
      if (!__builtin_parity(r & 0xFF)) emu->x86.R_FLG |= F_PF;
    } else if (o[0] == 0xC9) {                                  /* leave */
      emu->x86.R_SP = emu->x86.R_BP;
      emu->x86.R_BP = rd16(lin(emu->x86.R_SS, emu->x86.R_SP));
      emu->x86.R_SP += 2;
    } else if (o[0] == 0x8A && o[1] == 0x1E) {                  /* mov bl, [imm16] */
      emu->x86.R_BL = rd8(lin(emu->x86.R_DS, o[2] | o[3] << 8));
    } else if (o[0] == 0x83 && o[1] == 0x3E) {                  /* cmp word [imm16], simm8 */
      uint16_t x = rd16(lin(emu->x86.R_DS, o[2] | o[3] << 8)), y = (uint16_t)(int16_t)(int8_t)o[4], r = x - y;
      emu->x86.R_FLG &= ~(F_CF | F_ZF | F_SF | F_OF | F_PF | F_AF);
      if (x < y) emu->x86.R_FLG |= F_CF;
      if (!r) emu->x86.R_FLG |= F_ZF;
      if (r & 0x8000) emu->x86.R_FLG |= F_SF;
      if (((x ^ y) & (x ^ r)) & 0x8000) emu->x86.R_FLG |= F_OF;
      if (!__builtin_parity(r & 0xFF)) emu->x86.R_FLG |= F_PF;
      if ((x ^ y ^ r) & 0x10) emu->x86.R_FLG |= F_AF;
    }
    emu->x86.R_EIP += hooks[i].len - 1;
    return;
  }
  cc_orig(emu, op1);
}

static int cpu_hook_at(uint32_t a, const uint8_t *expect, int len, struct hook_hit *hit);
int cpu_hook(uint16_t cs, uint16_t ip, const uint8_t *expect, int len, struct hook_hit *hit)
{
  return cpu_hook_at(lin(cs, ip), expect, len, hit);
}

static int cpu_hook_at(uint32_t a, const uint8_t *expect, int len, struct hook_hit *hit)
{
  if (nhooks >= 8 || memcmp(mem + a, expect, len)) return 0;
  hooks[nhooks].lin = a; memcpy(hooks[nhooks].orig, expect, len); hooks[nhooks].len = len; hooks[nhooks].hit = hit;
  nhooks++;
  mem[a] = 0xCC;
  return 1;
}

/* OVERBAR_PROBE=file: find a routine of the game by sampling. Every 20 ms the CPU's CS:IP and the words on top of its stack are counted
 * (segments as paragraphs from the load segment 0732, the units of segmap.json); every 3 s the ones seen in most samples go to the file. */
void cpu_probe(void)
{
  static const char *path; static int init, samples, ntab;
  static double last, report;
  static struct { uint16_t kind, seg, off; int n; } tab[1024];
  if (!init) { init = 1; path = getenv("OVERBAR_PROBE"); }
  if (!path || !cpu) return;
  double now = host_time();
  if (now - last < 0.02) return;
  last = now; if (!report) report = now;
  samples++;
  struct { uint16_t kind, seg, off; } keys[48]; int nk = 0;
  uint16_t cs = cpu->x86.R_CS - 0x0732, ss = cpu->x86.R_SS, sp = cpu->x86.R_SP;
  keys[nk].kind = 0; keys[nk].seg = cs; keys[nk++].off = cpu->x86.R_IP;
  for (int i = 0; i < 24; i++) {
    uint16_t w = rd16(lin(ss, (uint16_t)(sp + 2 * i)));
    keys[nk].kind = 1; keys[nk].seg = cs; keys[nk++].off = w;                 /* a near return address (the word, with the current segment) */
    uint16_t w2 = rd16(lin(ss, (uint16_t)(sp + 2 * i + 2)));
    if (w2 > 0x0732 && w2 < 0x7000) { keys[nk].kind = 2; keys[nk].seg = w2 - 0x0732; keys[nk++].off = w; }   /* a far one (word, then the segment) */
  }
  for (int k = 0; k < nk; k++) {
    int j; for (j = 0; j < ntab && (tab[j].kind != keys[k].kind || tab[j].seg != keys[k].seg || tab[j].off != keys[k].off); j++) ;
    if (j == ntab && ntab < 1024) { tab[j].kind = keys[k].kind; tab[j].seg = keys[k].seg; tab[j].off = keys[k].off; tab[j].n = 0; ntab++; }
    if (j < ntab) tab[j].n++;
  }
  if (now - report > 3) {
    report = now;
    FILE *f = fopen(path, "a");
    if (f) {
      fprintf(f, "probe: %d samples; seen in most samples (ip: where it is; near: a word on the stack read as an offset in the current segment; far: offset and segment); segment = paragraph from the load segment, as in segmap.json:\n", samples);
      for (int r = 0; r < 24; r++) {
        int b = -1; for (int j = 0; j < ntab; j++) if (tab[j].n > 0 && (b < 0 || tab[j].n > tab[b].n)) b = j;
        if (b < 0) break;
        fprintf(f, "  %s %04X:%04X  %d%%\n", tab[b].kind == 0 ? "ip  " : tab[b].kind == 1 ? "near" : "far ", tab[b].seg, tab[b].off, tab[b].n * 100 / samples);
        tab[b].n = -tab[b].n;
      }
      fprintf(f, "\n"); fclose(f);
    }
    ntab = 0; samples = 0;
  }
}

/* The game's line editor (the routine behind "Enter New League Name" and the other text boxes) is overlay code: it is not in memory until the
 * overlay is loaded, and it may be loaded again at another place. So once in a while the memory is searched for the routine (its first
 * and last bytes, at paragraph-aligned overlay positions) and an int3 is written over its `enter` and over the `leave` before its return;
 * the hits are counted (the keyboard is up while the entries are one more than the exits). */
static int cpu_hook_at(uint32_t a, const uint8_t *expect, int len, struct hook_hit *hit);
/* The hook on the routine's entry can be missed (the overlay is loaded just before it runs, and the int3 is written afterwards), so the
 * editing state comes from the loop that waits for keys (it runs all the time while the box is up, hits are counted) and from the leave. */
int cpu_text_editing(void)
{
  static unsigned in_seen, out_seen;
  static int inside;
  if (text_out.count != out_seen) { out_seen = text_out.count; in_seen = text_in.count; inside = 0; }
  else if (text_in.count != in_seen) { in_seen = text_in.count; inside = 1; }
  return inside;
}
void cpu_text_find(void)
{
  static const uint8_t head[12] = { 0xC8, 0x0A, 0x00, 0x00, 0x57, 0x56, 0x8B, 0x76, 0x18, 0x9A, 0xA6, 0x01 };
  static const uint8_t tail[8] = { 0x5E, 0x5F, 0xC9, 0xCB, 0xC8, 0x92, 0x01, 0x00 };
  static const uint8_t orax[2] = { 0x0B, 0xC0 }, leave1[1] = { 0xC9 };
  static double last;
  double now = host_time();
  if (now - last < 0.01) return;
  last = now;
  for (uint32_t a = 12; a + 0x330 < 0xA0000; a += 16) {            /* a: 12 modulo 16 (the routine is 0x25C into a paragraph-aligned overlay) */
    if (mem[a] != 0xC8 || memcmp(mem + a, head, sizeof head) || memcmp(mem + a + 0x328, tail, sizeof tail)) continue;
    int have = 0;
    for (int i = 0; i < nhooks; i++) if (hooks[i].lin == a + 0x6B) have = 1;
    if (have) { if (mem[a + 0x6B] == 0xCC && mem[a + 0x32A] == 0xCC) continue; mem[a + 0x6B] = 0xCC; mem[a + 0x32A] = 0xCC; if (getenv("NHL94_TEXTLOG")) fprintf(stderr, "text editor at %05X loaded again, hooks written again (in %u out %u)\n", a, text_in.count, text_out.count); continue; }   /* loaded again: the int3s are gone */
    int r1 = cpu_hook_at(a + 0x6B, orax, 2, &text_in), r2 = cpu_hook_at(a + 0x32A, leave1, 1, &text_out);
    if (getenv("NHL94_TEXTLOG")) fprintf(stderr, "text editor found at %05X, hooks %d %d, %d hooks\n", a, r1, r2, nhooks);
  }
}

/* NHL94_BREAK="cs:ip,cs:ip": print the registers (and 8 bytes at DS:AX) each time one of these runs (debugging) */
static uint32_t brk[16]; static int nbrk;
static double cov_t; static uint8_t *cov;
static int code_check(x86emu_t *emu)
{
  uint32_t a = emu->x86.R_CS_BASE + emu->x86.R_EIP;
  /* NHL94_COVER=seconds: from then on, print each code address reached for the first time (debugging) */
  if (cov && a < 0x110000 && !cov[a] && host_time() >= cov_t) {
    cov[a] = 1; fprintf(stderr, "cover %04X:%04X\n", emu->x86.R_CS, emu->x86.R_IP);
  }
  for (int i = 0; i < nbrk; i++) if (a == brk[i]) {
    uint32_t p = lin(emu->x86.R_DS, emu->x86.R_AX);
    uint32_t q = getenv("NHL94_BREAK_DI") ? lin(emu->x86.R_ES, emu->x86.R_DI - 8) : lin(emu->x86.R_SS, emu->x86.R_BP + (getenv("NHL94_BREAK_BP") ? (int)strtol(getenv("NHL94_BREAK_BP"), 0, 0) : -8));
    fprintf(stderr, "break %04X:%04X  [ds:ax] %02X %02X %02X %02X %02X %02X %02X %02X  [bp-8] %02X %02X %02X %02X %02X %02X %02X %02X  ",
            emu->x86.R_CS, emu->x86.R_IP, rd8(p), rd8(p + 1), rd8(p + 2), rd8(p + 3), rd8(p + 4), rd8(p + 5), rd8(p + 6), rd8(p + 7),
            rd8(q), rd8(q + 1), rd8(q + 2), rd8(q + 3), rd8(q + 4), rd8(q + 5), rd8(q + 6), rd8(q + 7));
    cpu_dump("");
    fprintf(stderr, "  return %04X:%04X\n", rd16(lin(emu->x86.R_SS, emu->x86.R_SP + 2)), rd16(lin(emu->x86.R_SS, emu->x86.R_SP)));
    const char *dm = getenv("NHL94_BREAK_MEM");
    if (dm) { FILE *f = fopen(dm, "wb"); if (f) { fwrite(mem, 1, 0xA0000, f); fclose(f); } }
  }
  return 0;
}

void cpu_init(void)
{
  const char *b = getenv("NHL94_BREAK");
  while (b && *b && nbrk < 16) {
    unsigned cs, ip; int n;
    if (sscanf(b, "%x:%x%n", &cs, &ip, &n) != 2) break;
    brk[nbrk++] = lin(cs, ip); b += n; if (*b == ',') b++;
  }
  for (int i = 0x6C; i <= 0x6F; i++) x86emu_optab[i] = string_io;
  for (int i = 0xD8; i <= 0xDF; i++) x86emu_optab[i] = esc_nofpu;
  cc_orig = x86emu_optab[0xCC]; x86emu_optab[0xCC] = op_cc;
  mem = calloc(1, MEM_SIZE + 16);
  ems = calloc(EMS_PAGES, 16384);
  cpu = x86emu_new(X86EMU_PERM_RWX, X86EMU_PERM_RW);
  x86emu_set_memio_handler(cpu, memio);
  x86emu_set_intr_handler(cpu, intr);
  if (getenv("NHL94_COVER")) { cov_t = host_time() + atof(getenv("NHL94_COVER")); cov = calloc(1, 0x110000); }
  if (nbrk || cov) x86emu_set_code_handler(cpu, code_check);
  /* ROM stubs: int n / retf 2 */
  for (int v = 0; v < 256; v++) {
    uint32_t a = lin(ROM_SEG, rom_stub(v));
    mem[a] = 0xCD; mem[a + 1] = v; mem[a + 2] = 0xCA; mem[a + 3] = 0x02; mem[a + 4] = 0x00;
    cpu_set_vector(v, ROM_SEG, rom_stub(v));
  }
  /* IRQ 0: tick the BIOS clock (int 8 service), call int 1Ch, end of interrupt, iret */
  {
    static const uint8_t irq0[] = { 0xCD, 0x08, 0xCD, 0x1C, 0x50, 0xB0, 0x20, 0xE6, 0x20, 0x58, 0xCF };
    memcpy(mem + lin(ROM_SEG, 0x0800), irq0, sizeof irq0);
    cpu_set_vector(8, ROM_SEG, 0x0800);
    static const uint8_t irq1[] = { 0xCD, 0x09, 0x50, 0xB0, 0x20, 0xE6, 0x20, 0x58, 0xCF };
    memcpy(mem + lin(ROM_SEG, 0x0820), irq1, sizeof irq1);
    cpu_set_vector(9, ROM_SEG, 0x0820);
    /* other IRQs (2-7, 70h-77h): EOI and iret */
    static const uint8_t eoi[] = { 0x50, 0xB0, 0x20, 0xE6, 0xA0, 0xE6, 0x20, 0x58, 0xCF };
    memcpy(mem + lin(ROM_SEG, 0x0840), eoi, sizeof eoi);
    for (int i = 0x0A; i <= 0x0F; i++) cpu_set_vector(i, ROM_SEG, 0x0840);
    for (int i = 0x70; i <= 0x77; i++) cpu_set_vector(i, ROM_SEG, 0x0840);
    mem[lin(ROM_SEG, 0x0860)] = 0xCF; /* iret */
    cpu_set_vector(0x1C, ROM_SEG, 0x0860);
    cpu_set_vector(0x23, ROM_SEG, 0x0860);
  }
  mem[0xFFFF0] = 0xF4;
  mem[0xFFFFE] = 0xFC; /* model byte: AT */
}

void cpu_reset_to(uint16_t cs, uint16_t ip, uint16_t ss, uint16_t sp, uint16_t ds, uint16_t es)
{
  x86emu_reset(cpu);
  x86emu_set_seg_register(cpu, cpu->x86.R_CS_SEL, cs);
  x86emu_set_seg_register(cpu, cpu->x86.R_SS_SEL, ss);
  x86emu_set_seg_register(cpu, cpu->x86.R_DS_SEL, ds);
  x86emu_set_seg_register(cpu, cpu->x86.R_ES_SEL, es);
  cpu->x86.R_EIP = ip;
  cpu->x86.R_ESP = sp;
  cpu->x86.R_EFLG = 0x0202;
}

static void deliver_irq(void)
{
  if (!(cpu->x86.R_FLG & F_IF)) return;
  int v = pic_pending();
  if (v < 0) return;
  pic_ack(v);
  uint16_t seg, off;
  cpu_get_vector(v, &seg, &off);
  push16(cpu->x86.R_FLG);
  push16(cpu->x86.R_CS);
  push16(cpu->x86.R_IP);
  cpu->x86.R_FLG &= ~(F_IF | F_TF);
  x86emu_set_seg_register(cpu, cpu->x86.R_CS_SEL, seg);
  cpu->x86.R_EIP = off;
  cpu->x86.mode &= ~_MODE_HALTED;
}

void cpu_retry(void)
{
  cpu->x86.R_IP -= 2;
  cpu->x86.R_FLG |= F_IF;
  x86emu_stop(cpu);
}

uint64_t cpu_instr_count(void) { return cpu->x86.R_TSC; }

int cpu_run(unsigned n)
{
  deliver_irq();
  if (cpu->x86.mode & _MODE_HALTED) return 1;
  cpu->max_instr = cpu->x86.R_TSC + n;
  unsigned rs = x86emu_run(cpu, X86EMU_RUN_MAX_INSTR);
  if (cpu->x86.mode & _MODE_HALTED) {
    /* hlt leaves IP after the instruction, waiting for an interrupt */
    if (!(rs & X86EMU_RUN_MAX_INSTR) && !(cpu->x86.R_FLG & F_IF) && !cpu_quit) {
      cpu_dump("hlt with interrupts off");
    }
    return 1;
  }
  return 0;
}

void cpu_dump(const char *why)
{
  fprintf(stderr, "CPU %s: CS:IP=%04X:%04X AX=%04X BX=%04X CX=%04X DX=%04X SI=%04X DI=%04X BP=%04X SP=%04X DS=%04X ES=%04X SS=%04X FL=%04X\n",
          why, cpu->x86.R_CS, cpu->x86.R_IP, cpu->x86.R_AX, cpu->x86.R_BX, cpu->x86.R_CX, cpu->x86.R_DX, cpu->x86.R_SI,
          cpu->x86.R_DI, cpu->x86.R_BP, cpu->x86.R_SP, cpu->x86.R_DS, cpu->x86.R_ES, cpu->x86.R_SS, cpu->x86.R_FLG);
}
