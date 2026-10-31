/* pc.c: the PC's own chips. 8259 PIC pair, 8253 PIT, 8042 keyboard controller, port 61h, game port, and the
 * I/O dispatch to the VGA and the sound cards. */
#include "machine.h"
#include "sound.h"
#include "audio.h"
#include <stdio.h>
#include <string.h>
#include <time.h>

/* ---- PIC ---- */
typedef struct { uint8_t irr, isr, imr, base, icw_step, read_isr, icw4; } pic_t;
static pic_t pic[2];

void pic_raise(int irq)
{
  pic[irq >> 3].irr |= 1 << (irq & 7);
  if (irq >= 8) pic[0].irr |= 1 << 2;
}

static int pic_best(pic_t *p)
{
  uint8_t req = p->irr & ~p->imr;
  for (int i = 0; i < 8; i++) {
    if (p->isr & (1 << i)) return -1;          /* a higher or equal priority one is in service */
    if (req & (1 << i)) return i;
  }
  return -1;
}

static volatile uint32_t irq_async;
void irq_raise(int irq) { __atomic_or_fetch(&irq_async, 1u << irq, __ATOMIC_SEQ_CST); }

int pic_pending(void)
{
  uint32_t a = __atomic_exchange_n(&irq_async, 0, __ATOMIC_SEQ_CST);
  for (int i = 0; a; i++, a >>= 1) if (a & 1) pic_raise(i);
  int i = pic_best(&pic[0]);
  if (i < 0) return -1;
  if (i == 2) {
    int j = pic_best(&pic[1]);
    if (j < 0) { pic[0].irr &= ~4; return -1; }
    return pic[1].base + j;
  }
  return pic[0].base + i;
}

void pic_ack(int vector)
{
  if (vector >= pic[0].base && vector < pic[0].base + 8) {
    int i = vector - pic[0].base;
    pic[0].irr &= ~(1 << i); pic[0].isr |= 1 << i;
  } else {
    int i = vector - pic[1].base;
    pic[1].irr &= ~(1 << i); pic[1].isr |= 1 << i;
    pic[0].isr |= 4;
    if (!(pic[1].irr & ~pic[1].imr)) pic[0].irr &= ~4;
  }
}

static void pic_out(int n, int a0, uint8_t v)
{
  pic_t *p = &pic[n];
  if (!a0) {
    if (v & 0x10) { p->icw_step = 1; p->imr = 0; p->icw4 = v & 1; return; }  /* ICW1 */
    if ((v & 0x18) == 0x08) { if ((v & 3) >= 2) p->read_isr = v & 1; return; } /* OCW3 */
    if (v & 0x20) {                                                         /* EOI */
      if (v & 0x40) p->isr &= ~(1 << (v & 7));
      else for (int i = 0; i < 8; i++) if (p->isr & (1 << i)) { p->isr &= ~(1 << i); break; }
    }
    return;
  }
  switch (p->icw_step) {
  case 1: p->base = v & 0xF8; p->icw_step = 2; return;
  case 2: p->icw_step = p->icw4 ? 3 : 0; return;
  case 3: p->icw_step = 0; return;
  }
  p->imr = v;
}

static uint8_t pic_in(int n, int a0)
{
  pic_t *p = &pic[n];
  if (a0) return p->imr;
  return p->read_isr ? p->isr : p->irr;
}

/* ---- PIT ---- */
typedef struct { uint16_t reload; uint8_t mode, access, wlow, rlow, latched; uint16_t latch; uint8_t wbyte; double phase; } pit_ch_t;
static pit_ch_t pit[3];
#define PIT_CLOCK 1193181.6667

double host_time(void)
{
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return ts.tv_sec + ts.tv_nsec * 1e-9;
}

static double pit_period(int c) { return (pit[c].reload ? pit[c].reload : 65536) / PIT_CLOCK; }
double pit_hz(void) { return 1.0 / pit_period(0); }

static double pit_acc;
void pit_advance(double dt)
{
  double per = pit_period(0);
  pit_acc += dt;
  if (pit_acc > per * 8) pit_acc = per * 8;        /* do not storm after a pause */
  if (pit_acc >= per) { pit_acc -= per; pic_raise(0); }
  pit[0].phase = pit_acc / per;
}

static uint16_t pit_count(int c)
{
  double per = pit_period(c), ph;
  if (c == 0) ph = pit[0].phase;
  else { double t = host_time(); ph = t / per - (long long)(t / per); }
  uint32_t r = pit[c].reload ? pit[c].reload : 65536;
  uint32_t v = r - (uint32_t)(ph * r);
  if (v == 0) v = 1;
  return v;
}

static void pit_out(int port, uint8_t v)
{
  if (port == 0x43) {
    int c = v >> 6;
    if (c == 3) return;
    if (((v >> 4) & 3) == 0) { pit[c].latched = 1; pit[c].latch = pit_count(c); pit[c].rlow = 0; return; }
    pit[c].access = (v >> 4) & 3; pit[c].mode = (v >> 1) & 7; pit[c].wlow = 0; pit[c].rlow = 0;
    return;
  }
  pit_ch_t *p = &pit[port - 0x40];
  switch (p->access) {
  case 1: p->reload = (p->reload & 0xFF00) | v; break;
  case 2: p->reload = (p->reload & 0x00FF) | v << 8; break;
  case 3:
    if (!p->wlow) { p->wbyte = v; p->wlow = 1; return; }
    p->reload = p->wbyte | v << 8; p->wlow = 0; break;
  }
  if (port == 0x40) LOG("PIT0 reload %u (%.2f Hz)\n", p->reload, pit_hz());
}

static uint8_t pit_in(int port)
{
  pit_ch_t *p = &pit[port - 0x40];
  uint16_t v = p->latched ? p->latch : pit_count(port - 0x40);
  uint8_t r;
  if (p->access == 1) { r = v; p->latched = 0; }
  else if (p->access == 2) { r = v >> 8; p->latched = 0; }
  else { if (!p->rlow) { r = v; p->rlow = 1; } else { r = v >> 8; p->rlow = 0; p->latched = 0; } }
  return r;
}

/* ---- keyboard controller ---- */
static uint8_t kq[64]; static int kq_head, kq_tail; static uint8_t k60;
uint8_t port61;

void kbd_scancode(uint8_t code)
{
  int n = (kq_tail + 1) & 63;
  if (n == kq_head) return;
  kq[kq_tail] = code; kq_tail = n;
}

/* hand the next queued code to the game, one per interrupt */
void kbd_pump(void)
{
  if (kq_head == kq_tail) return;
  if ((pic[0].irr | pic[0].isr) & 2) return;
  k60 = kq[kq_head]; kq_head = (kq_head + 1) & 63;
  pic_raise(1);
}

/* ---- game port ---- */
uint8_t joy_port(void);
void joy_trigger(void);

/* ---- dispatch ---- */
static uint8_t in8(uint16_t port)
{
  if (port >= 0x3B0 && port <= 0x3DF) return vga_in(port);
  switch (port) {
  case 0x20: case 0x21: return pic_in(0, port & 1);
  case 0xA0: case 0xA1: return pic_in(1, port & 1);
  case 0x40: case 0x41: case 0x42: return pit_in(port);
  case 0x60: return k60;
  case 0x61: { static int t; t ^= 0x10; return (port61 & 0x0F) | t | ((port61 & 1) ? 0x20 : 0); }
  case 0x64: return 0x1C | (kq_head != kq_tail ? 1 : 0);
  case 0x201: return joy_port();
  }
  int r;
  if (sound_in(port, &r)) return r;
  LOG("in %04X\n", port);
  return 0xFF;
}

static void out8(uint16_t port, uint8_t v)
{
  if (port >= 0x3B0 && port <= 0x3DF) { vga_out(port, v); return; }
  switch (port) {
  case 0x20: case 0x21: pic_out(0, port & 1, v); return;
  case 0xA0: case 0xA1: pic_out(1, port & 1, v); return;
  case 0x40: case 0x41: pit_out(port, v); return;
  case 0x42: case 0x43: pit_out(port, v); speaker_out(port, v); return;
  case 0x61: port61 = v; speaker_out(0x61, v); return;
  case 0x60: case 0x64: return;
  case 0x201: joy_trigger(); return;
  }
  if (sound_out(port, v)) return;
  LOG("out %04X,%02X\n", port, v);
}

uint32_t port_in(uint16_t port, int size)
{
  if (size == 1) return in8(port);
  if (size == 2) return in8(port) | in8(port + 1) << 8;
  return in8(port) | in8(port + 1) << 8 | (uint32_t)in8(port + 2) << 16 | (uint32_t)in8(port + 3) << 24;
}

void port_out(uint16_t port, uint32_t val, int size)
{
  for (int i = 0; i < size; i++) out8(port + i, val >> (8 * i));
}

void pc_init(void)
{
  memset(pic, 0, sizeof pic);
  pic[0].base = 0x08; pic[1].base = 0x70;
  pic[0].imr = 0xB8; pic[1].imr = 0xFF;   /* timer, keyboard, cascade, IRQ 2 open as after the BIOS */
  pic[0].imr = 0x00; pic[1].imr = 0x00;
  pit[0].reload = 0; pit[0].access = 3; pit[0].mode = 3;
  pit[2].access = 3; pit[2].mode = 3;
}
