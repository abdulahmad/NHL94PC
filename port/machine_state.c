/* machine_state.c: the state of the emulated PC as regions of memory (overbar/snap.h), for rollback and its tests.
 * The CPU's registers, the 1 MB of memory, the EMS pool and the devices' variables (pc.c, vga.c, bios.c, dos.c, speaker.c, opl.c each
 * list theirs), and the positions of the files the game has open as a blob. Not in it: the sound cards (sb.c, mpu.c, opl's chip, the
 * audio mixer), which make the sound and only the sound, and the host's mouse and keyboard. */
#include "machine.h"
#include "include/x86emu_int.h"
#include "overbar/snap.h"
#include <string.h>

void pc_state(void (*add)(void *, size_t));
void vga_state(void (*add)(void *, size_t));
void bios_state(void (*add)(void *, size_t));
void dos_state(void (*add)(void *, size_t));
void speaker_state(void (*add)(void *, size_t));
void opl_state(void (*add)(void *, size_t));
void dos_positions(int64_t out[64]);
void dos_seek_back(const int64_t in[64]);

#define MAXR 128
static ob_snap_region regs[MAXR];
static int nregs;
static void add(void *p, size_t n) { if (nregs < MAXR) { regs[nregs].p = p; regs[nregs].n = n; nregs++; } }

int machine_regions(const ob_snap_region **out)
{
  nregs = 0;
  add(&cpu->x86, sizeof cpu->x86);
  add(cpu->x86.msr, X86EMU_MSRS * sizeof *cpu->x86.msr);   /* (the instruction counter is in it) */
  add(mem, MEM_SIZE);
  add(ems, (size_t)EMS_PAGES * 16384u);
  add(ems_map, sizeof ems_map);
  pc_state(add); vga_state(add); bios_state(add); dos_state(add); speaker_state(add); opl_state(add);
  *out = regs;
  return nregs;
}

size_t machine_blob(void *buf, size_t cap)
{
  int64_t p[64];
  if (cap < sizeof p) return 0;
  dos_positions(p);
  memcpy(buf, p, sizeof p);
  return sizeof p;
}

void machine_unblob(const void *buf, size_t n)
{
  int64_t p[64];
  if (n < sizeof p) return;
  memcpy(p, buf, sizeof p);
  dos_seek_back(p);
}

uint64_t machine_hash(void)
{
  const ob_snap_region *r;
  int n = machine_regions(&r), i;
  uint64_t h = 1469598103934665603ULL;
  for (i = 0; i < n; i++) {
    const uint8_t *q = r[i].p;
    size_t k;
    for (k = 0; k < r[i].n; k++) { h ^= q[k]; h *= 1099511628211ULL; }
  }
  return h;
}
