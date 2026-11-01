/* machine.h: the emulated PC that runs NHL '94 PC's 16-bit code.
 *
 * The game (HOCKEY.EXE, its RTLink overlays and the EA sound drivers *.BGP) is real-mode code, so it runs on a CPU core
 * (libx86emu) instead of natively as in the NHL 95 PC port. Everything around the CPU is answered by the host:
 * DOS (dos.c), the BIOS and the mouse and EMS drivers (bios.c), the VGA (vga.c), the timer, interrupt controller and
 * keyboard controller (pc.c), and the window (main.c). */
#ifndef MACHINE_H
#define MACHINE_H

#include <stdint.h>
#include <stddef.h>

#define MEM_SIZE    0x110000u          /* 1 MB + the HMA */
#define ROM_SEG     0xF000u            /* our BIOS stubs live at F000:xxxx */
#define EMS_FRAME   0xE000u            /* EMS page frame segment (4 x 16 KB) */
#define EMS_PAGES   512u               /* 8 MB of EMS */

extern uint8_t *mem;                   /* conventional memory, flat, MEM_SIZE bytes */
extern uint8_t *ems;                   /* EMS pool, EMS_PAGES * 16 KB */
extern int ems_map[4];                 /* logical page mapped into each physical page, -1 = none */

/* registers, valid inside an interrupt service routine (set up by cpu.c) */
typedef struct x86emu_s x86emu_t;
extern x86emu_t *cpu;

uint32_t r_eax(void); uint16_t r_ax(void); uint16_t r_bx(void); uint16_t r_cx(void); uint16_t r_dx(void);
uint16_t r_si(void); uint16_t r_di(void); uint16_t r_bp(void); uint16_t r_sp(void);
uint16_t r_ds(void); uint16_t r_es(void); uint16_t r_ss(void); uint16_t r_cs(void); uint16_t r_ip(void);
void s_ax(uint16_t v); void s_bx(uint16_t v); void s_cx(uint16_t v); void s_dx(uint16_t v);
void s_si(uint16_t v); void s_di(uint16_t v); void s_bp(uint16_t v); void s_es(uint16_t v); void s_ds(uint16_t v);
uint8_t r_ah(void); uint8_t r_al(void); uint8_t r_bh(void); uint8_t r_bl(void);
uint8_t r_ch(void); uint8_t r_cl(void); uint8_t r_dh(void); uint8_t r_dl(void);
void s_al(uint8_t v); void s_ah(uint8_t v); void s_bl(uint8_t v); void s_bh(uint8_t v);
void s_cl(uint8_t v); void s_ch(uint8_t v); void s_dl(uint8_t v); void s_dh(uint8_t v);
void set_cf(int on); void set_zf(int on);

static inline uint32_t lin(uint16_t seg, uint16_t off) { return ((uint32_t)seg << 4) + off; }
uint8_t  rd8(uint32_t a);  void wr8(uint32_t a, uint8_t v);
uint16_t rd16(uint32_t a); void wr16(uint32_t a, uint16_t v);
uint32_t rd32(uint32_t a); void wr32(uint32_t a, uint32_t v);
static inline uint8_t *ptr(uint16_t seg, uint16_t off) { return mem + lin(seg, off); }

/* cpu.c */
void cpu_init(void);
void cpu_reset_to(uint16_t cs, uint16_t ip, uint16_t ss, uint16_t sp, uint16_t ds, uint16_t es);
int  cpu_run(unsigned instructions);   /* returns 1 when the CPU halted (hlt) */
uint64_t cpu_instr_count(void);
/* put a hook on the game's code at cs:ip when the bytes there are `expect` (one instruction, see cpu.c); each time it runs, *hit
 * gets the time and the DS, SS and SP of that moment (before the instruction). 0 if the bytes differ. */
struct hook_hit { double t; uint16_t ds, ss, sp; unsigned count; };
int cpu_hook(uint16_t cs, uint16_t ip, const uint8_t *expect, int len, struct hook_hit *hit);
void cpu_set_vector(int n, uint16_t seg, uint16_t off);
void cpu_get_vector(int n, uint16_t *seg, uint16_t *off);
uint16_t rom_stub(int vector);         /* offset of the ROM stub for this vector */
extern volatile int cpu_quit;
void cpu_retry(void);               /* run the int again later (a blocking call with nothing to return yet) */
void cpu_dump(const char *why);

/* pc.c: PIT, PIC, keyboard controller, game port, misc ports */
void pc_init(void);
uint32_t port_in(uint16_t port, int size);
void port_out(uint16_t port, uint32_t val, int size);
void pic_raise(int irq);
int  pic_pending(void);                /* vector to deliver, or -1 */
void pic_ack(int vector);
double pit_hz(void);                   /* channel 0 rate */
void pit_advance(double seconds);      /* host clock moved: raise IRQ 0 as needed */
void kbd_scancode(uint8_t code);       /* queue a make or break code from the host keyboard */
double host_time(void);                /* seconds, monotonic */

/* vga.c */
void vga_init(void);
uint8_t vga_read(uint32_t addr);
void vga_write(uint32_t addr, uint8_t v);
uint8_t vga_in(uint16_t port);
void vga_out(uint16_t port, uint8_t v);
void vga_set_mode(int mode);
int  vga_mode(void);
/* renders the visible picture as 8-bit indices; returns width/height */
void vga_render(uint8_t *dst, int *w, int *h, uint32_t pal[256]);
extern int vga_dirty;

/* dos.c */
void dos_init(const char *root, const char *exe_name, const char *args);
int  dos_load_exe(const char *host_path, const char *dos_path, const char *args, uint16_t *cs, uint16_t *ip,
                  uint16_t *ss, uint16_t *sp, uint16_t *psp);
int  dos_int21(void);
int  dos_int2f(void);
extern char game_root[1024];
int host_path(const char *dospath, char *out, size_t outsz, int must_exist);

/* bios.c */
void bios_init(void);
int  bios_int(int n);                  /* service a vector whose IVT entry is still our stub */
void mouse_move(int dx, int dy);       /* host mouse moved (mickeys) */
void mouse_set_pos(int x, int y);
void mouse_buttons(int mask);
int  ems_int67(void);

/* host side (main.c) */
void host_poll(void);                  /* pump SDL events */
void host_present(void);
extern int trace;
void logf_(const char *fmt, ...);
#define LOG(...) do { if (trace) logf_(__VA_ARGS__); } while (0)

#endif
