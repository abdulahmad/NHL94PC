/* main.c: the SDL2 host. Opens the window, loads HOCKEY.EXE into the emulated PC, runs the CPU against the host
 * clock (the PIT's interrupts follow real time), turns SDL keys and mouse into the PC's keyboard and mouse, and
 * shows the VGA picture about 70 times a second.
 *
 * Environment: NHL94_ROOT (the game folder, default: the folder of the program, then the current folder),
 * NHL94_EXE (HOCKEY.EXE, default: in the game folder), NHL94_TRACE=1 (log), NHL94_DUMP=dir (write a PPM of the
 * screen twice a second), NHL94_KEYS="ms:Key[/hold] ..." (scripted keys), NHL94_MIPS (instructions per second to
 * aim for; default: as fast as the host). */
#include "machine.h"
#include "sound.h"
#include <SDL.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

int trace;
volatile int intro_skip;
void video_set_title(const char *t);
static SDL_Window *win;
static SDL_Renderer *ren;
static SDL_Texture *tex;
static int tex_w, tex_h;
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

void video_set_title(const char *t) { if (win) SDL_SetWindowTitle(win, t); }

/* ---- joystick: SDL game controllers on the game port (201h) ----
 * The first controller is joystick A (axes bits 0-1, buttons bits 4-5, plus X/Y as buttons 3-4 of a four-button stick
 * on bits 6-7 when there is no second controller); the second is joystick B (bits 2-3, 6-7). A write to 201h starts
 * the four one-shots; each axis bit stays 1 for a time that grows with the stick position. The game times them with a
 * counting loop and calibrates, so the time is counted in emulated instructions, which keeps it independent of the
 * host's speed. */
static SDL_GameController *pad[2];
static uint64_t joy_t0; static unsigned joy_len[4];

static void pads_open(void)
{
  for (int i = 0; i < 2; i++)
    if (pad[i] && !SDL_GameControllerGetAttached(pad[i])) { SDL_GameControllerClose(pad[i]); pad[i] = NULL; }
  for (int j = 0; j < SDL_NumJoysticks(); j++) {
    if (!SDL_IsGameController(j)) continue;
    SDL_JoystickID id = SDL_JoystickGetDeviceInstanceID(j);
    int used = 0;
    for (int i = 0; i < 2; i++) if (pad[i] && SDL_JoystickInstanceID(SDL_GameControllerGetJoystick(pad[i])) == id) used = 1;
    if (used) continue;
    for (int i = 0; i < 2; i++) if (!pad[i]) { pad[i] = SDL_GameControllerOpen(j); break; }
  }
}

/* -1..1 from the left stick, with the d-pad pushing it all the way */
static double pad_axis(SDL_GameController *c, SDL_GameControllerAxis a, SDL_GameControllerButton lo, SDL_GameControllerButton hi)
{
  if (SDL_GameControllerGetButton(c, lo)) return -1;
  if (SDL_GameControllerGetButton(c, hi)) return 1;
  double v = SDL_GameControllerGetAxis(c, a) / 32767.0;
  return v < -1 ? -1 : v;
}

void joy_trigger(void)
{
  joy_t0 = cpu_instr_count();
  for (int i = 0; i < 2; i++) {
    joy_len[2 * i] = joy_len[2 * i + 1] = 0;
    if (!pad[i]) continue;
    double x = pad_axis(pad[i], SDL_CONTROLLER_AXIS_LEFTX, SDL_CONTROLLER_BUTTON_DPAD_LEFT, SDL_CONTROLLER_BUTTON_DPAD_RIGHT);
    double y = pad_axis(pad[i], SDL_CONTROLLER_AXIS_LEFTY, SDL_CONTROLLER_BUTTON_DPAD_UP, SDL_CONTROLLER_BUTTON_DPAD_DOWN);
    joy_len[2 * i] = 300 + (unsigned)((x + 1) * 2000);     /* centre about 2300 instructions, ~330 turns of the loop */
    joy_len[2 * i + 1] = 300 + (unsigned)((y + 1) * 2000);
  }
}

uint8_t joy_port(void)
{
  uint64_t t = cpu_instr_count() - joy_t0;
  uint8_t v = 0xF0;
  for (int i = 0; i < 4; i++) if (t < joy_len[i]) v |= 1 << i;
  if (pad[0]) {
    if (SDL_GameControllerGetButton(pad[0], SDL_CONTROLLER_BUTTON_A)) v &= ~0x10;
    if (SDL_GameControllerGetButton(pad[0], SDL_CONTROLLER_BUTTON_B)) v &= ~0x20;
    if (!pad[1]) {
      if (SDL_GameControllerGetButton(pad[0], SDL_CONTROLLER_BUTTON_X)) v &= ~0x40;
      if (SDL_GameControllerGetButton(pad[0], SDL_CONTROLLER_BUTTON_Y)) v &= ~0x80;
    }
  }
  if (pad[1]) {
    if (SDL_GameControllerGetButton(pad[1], SDL_CONTROLLER_BUTTON_A)) v &= ~0x40;
    if (SDL_GameControllerGetButton(pad[1], SDL_CONTROLLER_BUTTON_B)) v &= ~0x80;
  }
  return v;
}

/* ---- keyboard: SDL scancode -> XT set 1 (0x100 = E0 prefix) ---- */
static int xt_code(SDL_Scancode s)
{
  if (s >= SDL_SCANCODE_A && s <= SDL_SCANCODE_Z) {
    static const uint8_t az[26] = { 0x1E,0x30,0x2E,0x20,0x12,0x21,0x22,0x23,0x17,0x24,0x25,0x26,0x32,0x31,0x18,0x19,0x10,0x13,0x1F,0x14,0x16,0x2F,0x11,0x2D,0x15,0x2C };
    return az[s - SDL_SCANCODE_A];
  }
  if (s >= SDL_SCANCODE_1 && s <= SDL_SCANCODE_0) return 0x02 + (s - SDL_SCANCODE_1);
  if (s >= SDL_SCANCODE_F1 && s <= SDL_SCANCODE_F10) return 0x3B + (s - SDL_SCANCODE_F1);
  switch (s) {
  case SDL_SCANCODE_RETURN: return 0x1C; case SDL_SCANCODE_ESCAPE: return 0x01; case SDL_SCANCODE_BACKSPACE: return 0x0E;
  case SDL_SCANCODE_TAB: return 0x0F; case SDL_SCANCODE_SPACE: return 0x39; case SDL_SCANCODE_MINUS: return 0x0C;
  case SDL_SCANCODE_EQUALS: return 0x0D; case SDL_SCANCODE_LEFTBRACKET: return 0x1A; case SDL_SCANCODE_RIGHTBRACKET: return 0x1B;
  case SDL_SCANCODE_BACKSLASH: return 0x2B; case SDL_SCANCODE_SEMICOLON: return 0x27; case SDL_SCANCODE_APOSTROPHE: return 0x28;
  case SDL_SCANCODE_GRAVE: return 0x29; case SDL_SCANCODE_COMMA: return 0x33; case SDL_SCANCODE_PERIOD: return 0x34;
  case SDL_SCANCODE_SLASH: return 0x35; case SDL_SCANCODE_CAPSLOCK: return 0x3A; case SDL_SCANCODE_F11: return 0x57;
  case SDL_SCANCODE_F12: return 0x58; case SDL_SCANCODE_LCTRL: return 0x1D; case SDL_SCANCODE_LSHIFT: return 0x2A;
  case SDL_SCANCODE_LALT: return 0x38; case SDL_SCANCODE_RSHIFT: return 0x36; case SDL_SCANCODE_RCTRL: return 0x11D;
  case SDL_SCANCODE_RALT: return 0x138; case SDL_SCANCODE_KP_MULTIPLY: return 0x37; case SDL_SCANCODE_NUMLOCKCLEAR: return 0x45;
  case SDL_SCANCODE_SCROLLLOCK: return 0x46; case SDL_SCANCODE_KP_7: return 0x47; case SDL_SCANCODE_KP_8: return 0x48;
  case SDL_SCANCODE_KP_9: return 0x49; case SDL_SCANCODE_KP_MINUS: return 0x4A; case SDL_SCANCODE_KP_4: return 0x4B;
  case SDL_SCANCODE_KP_5: return 0x4C; case SDL_SCANCODE_KP_6: return 0x4D; case SDL_SCANCODE_KP_PLUS: return 0x4E;
  case SDL_SCANCODE_KP_1: return 0x4F; case SDL_SCANCODE_KP_2: return 0x50; case SDL_SCANCODE_KP_3: return 0x51;
  case SDL_SCANCODE_KP_0: return 0x52; case SDL_SCANCODE_KP_PERIOD: return 0x53; case SDL_SCANCODE_KP_ENTER: return 0x11C;
  case SDL_SCANCODE_KP_DIVIDE: return 0x135; case SDL_SCANCODE_HOME: return 0x147; case SDL_SCANCODE_UP: return 0x148;
  case SDL_SCANCODE_PAGEUP: return 0x149; case SDL_SCANCODE_LEFT: return 0x14B; case SDL_SCANCODE_RIGHT: return 0x14D;
  case SDL_SCANCODE_END: return 0x14F; case SDL_SCANCODE_DOWN: return 0x150; case SDL_SCANCODE_PAGEDOWN: return 0x151;
  case SDL_SCANCODE_INSERT: return 0x152; case SDL_SCANCODE_DELETE: return 0x153;
  default: return 0;
  }
}

static void key(int code, int down)
{
  if (!code) return;
  if (code & 0x100) kbd_scancode(0xE0);
  kbd_scancode((code & 0x7F) | (down ? 0 : 0x80));
}

/* ---- scripted keys (tests) ---- */
struct skey { double t; int code; int down; int mx, my, click; };
static struct skey script[256];
static int nscript, iscript;

static void script_parse(const char *s)
{
  while (s && *s && nscript < 250) {
    double ms; char name[64]; int n;
    if (sscanf(s, "%lf:%63[^ ]%n", &ms, name, &n) != 2) break;
    s += n; while (*s == ' ') s++;
    double hold = 100;
    char *slash = strchr(name, '/');
    if (slash) { hold = atof(slash + 1); *slash = 0; }
    if (name[0] == '@') {
      int x, y;
      if (!strcmp(name, "@click")) { script[nscript++] = (struct skey){ ms / 1000, 0, 0, -1, -1, 1 };
        script[nscript++] = (struct skey){ (ms + hold) / 1000, 0, 0, -1, -1, 2 }; }
      else if (sscanf(name, "@%d,%d", &x, &y) == 2) script[nscript++] = (struct skey){ ms / 1000, 0, 0, x, y, 0 };
      continue;
    }
    SDL_Scancode sc = SDL_GetScancodeFromName(name);
    int code = xt_code(sc);
    if (!code) { fprintf(stderr, "NHL94_KEYS: unknown key %s\n", name); continue; }
    script[nscript++] = (struct skey){ ms / 1000, code, 1, -1, -1, 0 };
    script[nscript++] = (struct skey){ (ms + hold) / 1000, code, 0, -1, -1, 0 };
  }
  /* sort by time */
  for (int i = 1; i < nscript; i++) for (int j = i; j > 0 && script[j].t < script[j - 1].t; j--) {
    struct skey t = script[j]; script[j] = script[j - 1]; script[j - 1] = t; }
}

static void script_run(double t)
{
  while (iscript < nscript && script[iscript].t <= t) {
    struct skey *k = &script[iscript++];
    if (k->code) { key(k->code, k->down); LOG("script key %03X %s\n", k->code, k->down ? "down" : "up"); }
    else if (k->click == 1) mouse_buttons(1);
    else if (k->click == 2) mouse_buttons(0);
    else mouse_set_pos(k->mx, k->my);
  }
}

/* ---- picture ---- */
static uint8_t frame[800 * 600];
static uint32_t rgb[800 * 600];
static int frame_w = 320, frame_h = 200;

static void dump_ppm(void)
{
  static int n;
  char path[1100];
  snprintf(path, sizeof path, "%s/shot%04d.ppm", dump_dir, n++);
  FILE *f = fopen(path, "wb");
  if (!f) return;
  fprintf(f, "P6\n%d %d\n255\n", frame_w, frame_h);
  for (int i = 0; i < frame_w * frame_h; i++) { uint32_t c = rgb[i]; fputc(c >> 16, f); fputc(c >> 8, f); fputc(c, f); }
  fclose(f);
}

/* where the picture goes: 4:3, centred, in renderer pixels */
static void view_rect(SDL_Rect *r)
{
  int ww, wh; SDL_GetRendererOutputSize(ren, &ww, &wh);
  if (ww * 3 > wh * 4) { r->h = wh; r->w = wh * 4 / 3; } else { r->w = ww; r->h = ww * 3 / 4; }
  r->x = (ww - r->w) / 2; r->y = (wh - r->h) / 2;
}

/* the host pointer drives the game's pointer directly: the window position maps onto the driver's 640 x 200 virtual
 * screen of mode 13h, the way the DOS pointer covers the picture */
static void mouse_abs(int wx, int wy)
{
  int ww, wh, ow, oh; SDL_GetWindowSize(win, &ww, &wh); SDL_GetRendererOutputSize(ren, &ow, &oh);
  SDL_Rect r; view_rect(&r);
  double x = (wx * (double)ow / ww - r.x) / r.w, y = (wy * (double)oh / wh - r.y) / r.h;
  mouse_set_pos((int)(x * 640), (int)(y * 200));
}

void host_present(void)
{
  uint32_t pal[256];
  vga_render(frame, &frame_w, &frame_h, pal);
  for (int i = 0; i < frame_w * frame_h; i++) rgb[i] = pal[frame[i]];
  if (!ren) return;
  if (!tex || tex_w != frame_w || tex_h != frame_h) {
    if (tex) SDL_DestroyTexture(tex);
    tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, frame_w, frame_h);
    tex_w = frame_w; tex_h = frame_h;
  }
  SDL_UpdateTexture(tex, NULL, rgb, frame_w * 4);
  SDL_Rect r; view_rect(&r);
  SDL_SetRenderDrawColor(ren, 0, 0, 0, 255);
  SDL_RenderClear(ren);
  SDL_RenderCopy(ren, tex, NULL, &r);
  SDL_RenderPresent(ren);
}

void host_poll(void)
{
  SDL_Event e;
  while (SDL_PollEvent(&e)) {
    switch (e.type) {
    case SDL_QUIT: cpu_quit = 1; break;
    case SDL_KEYDOWN: case SDL_KEYUP:
      if (e.key.repeat) break;
      if (e.type == SDL_KEYDOWN && e.key.keysym.sym == SDLK_RETURN && (e.key.keysym.mod & KMOD_ALT)) {
        Uint32 fl = SDL_GetWindowFlags(win);
        SDL_SetWindowFullscreen(win, (fl & SDL_WINDOW_FULLSCREEN_DESKTOP) ? 0 : SDL_WINDOW_FULLSCREEN_DESKTOP);
        break;
      }
      key(xt_code(e.key.keysym.scancode), e.type == SDL_KEYDOWN);
      break;
    case SDL_CONTROLLERDEVICEADDED: case SDL_CONTROLLERDEVICEREMOVED: pads_open(); break;
    case SDL_MOUSEMOTION: mouse_abs(e.motion.x, e.motion.y); break;
    case SDL_MOUSEBUTTONDOWN: case SDL_MOUSEBUTTONUP: {
      int m = SDL_GetMouseState(NULL, NULL), b = 0;
      if (m & SDL_BUTTON_LMASK) b |= 1; if (m & SDL_BUTTON_RMASK) b |= 2; if (m & SDL_BUTTON_MMASK) b |= 4;
      mouse_buttons(b); break; }
    }
  }
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
  win = SDL_CreateWindow("NHL Hockey '94", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 960, 720, SDL_WINDOW_RESIZABLE);
  if (win) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_PRESENTVSYNC * 0);
  if (ren) SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");
  SDL_ShowCursor(SDL_DISABLE);                 /* the game draws its own pointer */

  if (getenv("NHL94_VPAD"))                     /* testing: a virtual controller with nothing pressed */
    SDL_JoystickAttachVirtual(SDL_JOYSTICK_TYPE_GAMECONTROLLER, SDL_CONTROLLER_AXIS_MAX, SDL_CONTROLLER_BUTTON_MAX, 0);
  pads_open();
  cpu_init();
  pc_init();
  vga_init();
  bios_init();
  sound_init();
  dos_init(root, exe, args);
  uint16_t cs, ip, ss, sp, psp;
  if (dos_load_exe(exe, "C:\\HOCKEY.EXE", args, &cs, &ip, &ss, &sp, &psp)) return 1;
  cpu_reset_to(cs, ip, ss, sp, psp, psp);
  script_parse(getenv("NHL94_KEYS"));

  double last = host_time(), next_frame = last, next_dump = last + 0.5, next_stat = last + 2;
  uint64_t last_instr = 0;
  int stats = getenv("NHL94_STATS") != NULL;
  while (!cpu_quit) {
    int halted = cpu_run(20000);
    double now = host_time();
    pit_advance(now - last);
    last = now;
    kbd_pump();
    sound_pump(now);
    script_run(now - t_start);
    if (now >= next_frame) {
      host_poll();
      host_present();
      next_frame += 1.0 / 70;
      if (next_frame < now) next_frame = now + 1.0 / 70;
    }
    if (dump_dir && now >= next_dump) { dump_ppm(); next_dump += 0.5; }
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
