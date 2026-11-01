/* main.c: the SDL2 host. Loads HOCKEY.EXE into the emulated PC and runs the CPU against the host clock (the PIT's
 * interrupts follow real time). The window and picture are in video.c, keyboard, mouse and controllers in input.c.
 *
 * Environment: NHL94_ROOT (the game folder, default: the folder of the program, then the current folder),
 * NHL94_EXE (HOCKEY.EXE, default: in the game folder), NHL94_TRACE=1 (log), NHL94_DUMP=dir (write a PPM of the
 * screen twice a second), NHL94_KEYS="ms:Key[/hold] ..." (scripted keys), NHL94_STATS=1 (speed every 2 s). */
#include "machine.h"
#include "sound.h"
#include "host.h"
#include <SDL.h>
#include <stdarg.h>
#include <sys/stat.h>

int trace;
volatile int intro_skip;
static const char *dump_dir;
static double t_start;
void kbd_pump(void);

void logf_(const char *fmt, ...)
{
  va_list ap; va_start(ap, fmt);
  fprintf(stderr, "[%9.3f] ", host_time() - t_start);
  vfprintf(stderr, fmt, ap);
  va_end(ap);
}

static int file_exists(const char *p) { struct stat st; return !stat(p, &st) && S_ISREG(st.st_mode); }

int main(int argc, char **argv)
{
  t_start = host_time();
  trace = getenv("NHL94_TRACE") != NULL;
  dump_dir = getenv("NHL94_DUMP");
  char root[1024], exe[1100];
  const char *r = getenv("NHL94_ROOT");
  if (r) snprintf(root, sizeof root, "%s", r);
  else {
    char *base = SDL_GetBasePath();
    snprintf(root, sizeof root, "%s", ".");
    if (base) {
      char t[1100]; snprintf(t, sizeof t, "%sHOCKEY.EXE", base);
      if (file_exists(t)) snprintf(root, sizeof root, "%s", base);
      SDL_free(base);
    }
  }
  const char *e = getenv("NHL94_EXE");
  if (e) snprintf(exe, sizeof exe, "%s", e);
  else {
    dos_init(root, "", "");
    if (host_path("HOCKEY.EXE", exe, sizeof exe, 1)) {
      fprintf(stderr, "HOCKEY.EXE not found in %s (set NHL94_ROOT to the game folder, or NHL94_EXE)\n", root);
      return 1;
    }
  }
  char args[128] = "";
  for (int i = 1; i < argc; i++) { strncat(args, " ", sizeof args - strlen(args) - 1); strncat(args, argv[i], sizeof args - strlen(args) - 1); }

  if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER | SDL_INIT_EVENTS | SDL_INIT_GAMECONTROLLER) < 0) { fprintf(stderr, "SDL: %s\n", SDL_GetError()); return 1; }
  video_init(!dump_dir);                        /* settings (hockey94.ini next to the program), window, menu bar */
  input_init();
  cpu_init();
  pc_init();
  vga_init();
  bios_init();
  sound_init();
  dos_init(root, exe, args);
  uint16_t cs, ip, ss, sp, psp;
  if (dos_load_exe(exe, "C:\\HOCKEY.EXE", args, &cs, &ip, &ss, &sp, &psp)) return 1;
  cpu_reset_to(cs, ip, ss, sp, psp, psp);
  input_hooks();
  input_script(getenv("NHL94_KEYS"));

  double last = host_time(), next_frame = last, next_poll = last, next_dump = last + 0.5, next_stat = last + 2;
  uint64_t last_instr = 0;
  int stats = getenv("NHL94_STATS") != NULL;
  while (!cpu_quit) {
    int halted = cpu_run(20000);
    double now = host_time();
    pit_advance(now - last);
    last = now;
    kbd_pump();
    sound_pump(now);
    input_script_run(now - t_start);
    if (now >= next_poll) { input_poll(); next_poll = now + 1.0 / 250; }
    if (video_vrr()) {                          /* VRR: draw each new picture as the game finishes it (at least every 0.1 s) */
      if (video_changed() || now >= next_frame) { video_present(); next_frame = now + 0.1; }
    } else if (now >= next_frame) {             /* 60 or 70 Hz on schedule */
      video_present();
      next_frame += video_present_interval();
      if (next_frame < now - 0.1) next_frame = now;
    }
    if (dump_dir && now >= next_dump) { video_dump(dump_dir); next_dump += 0.5; }
    if (stats && now >= next_stat) {
      uint64_t n = cpu_instr_count();
      extern int vga_flips, vga_status_reads;
      fprintf(stderr, "%.1f MIPS, PIT %.1f Hz, mode %02X, %.1f page flips/s, %d retrace polls/s\n", (n - last_instr) / 2e6, pit_hz(),
              vga_mode(), vga_flips / 2.0, vga_status_reads / 2);
      vga_flips = vga_status_reads = 0;
      last_instr = n; next_stat += 2;
    }
    if (halted) {
      /* waiting for an interrupt: sleep until the next timer tick */
      if (pic_pending() < 0) SDL_Delay(1);
    }
  }
  if (getenv("NHL94_EXITDUMP")) cpu_dump("at exit");
  SDL_Quit();
  return 0;
}
