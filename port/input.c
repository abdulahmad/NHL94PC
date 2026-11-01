/* input.c: the keyboard, the mouse and the game controllers, the scripted input of the tests, and what the game is doing.
 *
 * Keyboard: SDL scancodes become XT set 1 codes on the emulated keyboard controller. During play the bindings (bindings.c) may send
 * other keys of the game for a key. Mouse: the game's pointer follows the host's pointer (the window maps onto the driver's 640x200
 * screen); during play the bound mouse buttons are the game's. Controllers: the first two SDL game controllers are the PC joysticks A and B
 * on the game port (201h), with their buttons as bound, and the other bound buttons send the game's keys.
 *
 * What the game is doing comes from two hooks on its code (cpu_hook): ReadPad (seg007:0224), which play calls for each team's
 * device every frame, and GetInputEvent (seg025:000E), which the menus with the glove pointer call all the time. The rules for the system
 * pointer follow the NHL 95 port: hidden over the picture where the game draws its glove, and while the mouse plays (then also kept on the
 * picture), shown elsewhere; Display > Windows pointer can force it. */
#include "machine.h"
#include "host.h"
#include "audio.h"
#include "bindings.h"
#include <SDL.h>

/* ---- what the game is doing ---- */
#define SEG(p) (0x0732 + (p))                   /* the load segment plus a segment's paragraph in segmap.json */
static struct hook_hit hit_pad, hit_menu;
static int mouse_plays;                         /* a team plays with the mouse (ReadPad saw device 1) */
static double mouse_plays_at;

void input_hooks(void)
{
  static const uint8_t push_bp = 0x55, cmp_a3e[5] = { 0x83, 0x3E, 0x3E, 0x0A, 0x00 };
  if (!cpu_hook(SEG(2409), 0x0224, &push_bp, 1, &hit_pad)) fprintf(stderr, "input: ReadPad not found (another HOCKEY.EXE?)\n");
  if (!cpu_hook(SEG(3993), 0x000E, cmp_a3e, 5, &hit_menu)) fprintf(stderr, "input: GetInputEvent not found (another HOCKEY.EXE?)\n");
}

int input_in_game(void) { return hit_pad.t > 0 && host_time() - hit_pad.t < 0.5; }
int input_glove(void) { return !input_in_game() && hit_menu.t > 0 && host_time() - hit_menu.t < 0.3; }

/* ReadPad(team) looks at the team's device, a byte at DS:052Ch + team: 8 keyboard, 2 joystick A, 4 joystick B, 1 mouse */
static void pad_check(void)
{
  static unsigned seen;
  if (hit_pad.count == seen) return;
  seen = hit_pad.count;
  int team = rd16(lin(hit_pad.ss, hit_pad.sp + 4));
  if (team >= 0 && team < 2 && rd8(lin(hit_pad.ds, 0x52C + team)) == 1) { mouse_plays = 1; mouse_plays_at = hit_pad.t; }
  if (mouse_plays && hit_pad.t - mouse_plays_at > 1.0) mouse_plays = 0;
}

/* ---- keyboard: SDL scancode -> XT set 1 (0x100 = E0 prefix) ---- */
int xt_code(SDL_Scancode s)
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

static void key_xt(int code, int down)
{
  if (!code) return;
  if (code & 0x100) kbd_scancode(0xE0);
  kbd_scancode((code & 0x7F) | (down ? 0 : 0x80));
}

/* a key of the keyboard: during play the bindings may send other keys of the game for it; the release lets go of what the press sent */
static void key_physical(SDL_Scancode s, int down)
{
  static int sent[SDL_NUM_SCANCODES][4], nsent[SDL_NUM_SCANCODES];
  int xt = xt_code(s), out[4], n;
  if (!xt) return;
  if (!down) {
    for (int i = 0; i < nsent[s]; i++) key_xt(sent[s][i], 0);
    nsent[s] = 0;
    return;
  }
  n = input_in_game() ? bindings_kb(xt, out) : -1;
  if (n < 0) { out[0] = xt; n = 1; }
  for (int i = 0; i < nsent[s]; i++) key_xt(sent[s][i], 0);   /* (a key held through a change of bindings) */
  for (int i = 0; i < n; i++) { key_xt(out[i], 1); sent[s][i] = out[i]; }
  nsent[s] = n;
}

/* ---- mouse ---- */
static unsigned char mdown[8];
static void mouse_update_buttons(void)
{
  int b;
  if (input_in_game()) b = bindings_mouse(mdown);
  else b = (mdown[SDL_BUTTON_LEFT] ? 1 : 0) | (mdown[SDL_BUTTON_RIGHT] ? 2 : 0) | (mdown[SDL_BUTTON_MIDDLE] ? 4 : 0);
  mouse_buttons(b);
}

/* the host pointer drives the game's pointer directly: the 4:3 picture maps onto the driver's 640 x 200 screen of mode 13h */
static void mouse_abs(int wx, int wy)
{
  int vx, vy, vw, vh;
  video_view(&vx, &vy, &vw, &vh);
  if (vw <= 0 || vh <= 0) return;
  mouse_set_pos((wx - vx) * 640 / vw, (wy - vy) * 200 / vh);
}

static void cursor_update(void)
{
  static int hidden = -1;
  SDL_Window *w = video_window();
  int active = w && SDL_GetKeyboardFocus() == w, px, py, vx, vy, vw, vh, over, drawn, hide, play_mouse;
  pad_check();
  play_mouse = mouse_plays && input_in_game();
  drawn = input_glove() || play_mouse;
  video_confine_mouse(active && (video_is_fullscreen() || play_mouse));
  video_view(&vx, &vy, &vw, &vh);
  SDL_GetMouseState(&px, &py);
  over = active && SDL_GetMouseFocus() == w && px >= vx && px < vx + vw && py >= vy && py < vy + vh;
  hide = over && (video_pointer_mode() == 0 ? drawn : video_pointer_mode() == 2);
  if (hide != hidden) { SDL_ShowCursor(hide ? SDL_DISABLE : SDL_ENABLE); hidden = hide; }
}

/* ---- joystick: SDL game controllers on the game port (201h) ----
 * A write to 201h starts the four one-shots; each axis bit stays 1 for a time that grows with the stick position. The game times them with
 * a counting loop and calibrates itself as the stick reaches its ends, so the time is counted in emulated instructions, which keeps it
 * independent of the host's speed. Buttons are active low: bits 4-5 joystick A, 6-7 joystick B. With the default bindings A or X is
 * button 1 (pass), B or Y button 2 (shoot); hold / change line is both. */
static SDL_GameController *pad[2];
static uint64_t joy_t0; static unsigned joy_len[4];
static int joy_b1[2], joy_b2[2];

static void pads_open(void)
{
  for (int i = 0; i < 2; i++)
    if (pad[i] && !SDL_GameControllerGetAttached(pad[i])) { SDL_GameControllerClose(pad[i]); pad[i] = NULL; }
  if (getenv("NHL94_NOJOY")) return;
  for (int j = 0; j < SDL_NumJoysticks(); j++) {
    if (!SDL_IsGameController(j)) continue;
    SDL_JoystickID id = SDL_JoystickGetDeviceInstanceID(j);
    int used = 0;
    for (int i = 0; i < 2; i++) if (pad[i] && SDL_JoystickInstanceID(SDL_GameControllerGetJoystick(pad[i])) == id) used = 1;
    if (used) continue;
    for (int i = 0; i < 2; i++) if (!pad[i]) { pad[i] = SDL_GameControllerOpen(j); if (pad[i]) fprintf(stderr, "joystick %c: %s\n", 'A' + i, SDL_GameControllerName(pad[i])); break; }
  }
}

static int pad_button(SDL_GameController *g, int id)       /* a controller button of the bindings: 0-14 buttons, 20 and 21 the triggers */
{
  if (id <= 14) return SDL_GameControllerGetButton(g, (SDL_GameControllerButton)id);
  return SDL_GameControllerGetAxis(g, id == 20 ? SDL_CONTROLLER_AXIS_TRIGGERLEFT : SDL_CONTROLLER_AXIS_TRIGGERRIGHT) > 16000;
}

/* the buttons of each controller as the game's buttons 1 and 2, and the other bound buttons as the game's keys (during play) */
static void joy_update(void)
{
  static unsigned char was[2][NACT];
  for (int i = 0; i < 2; i++) {
    SDL_GameController *g = pad[i];
    int p, sh, h, pv = bind.joy[i][ACT_PASS], sv = bind.joy[i][ACT_SHOOT], hv = bind.joy[i][ACT_HOLD];
    joy_b1[i] = joy_b2[i] = 0;
    if (!g) continue;
    p = pv == PAD_DEFAULT ? (SDL_GameControllerGetButton(g, SDL_CONTROLLER_BUTTON_A) || SDL_GameControllerGetButton(g, SDL_CONTROLLER_BUTTON_X)) : pv >= 2 ? pad_button(g, PAD_ID(pv)) : 0;
    sh = sv == PAD_DEFAULT ? (SDL_GameControllerGetButton(g, SDL_CONTROLLER_BUTTON_B) || SDL_GameControllerGetButton(g, SDL_CONTROLLER_BUTTON_Y)) : sv >= 2 ? pad_button(g, PAD_ID(sv)) : 0;
    h = hv >= 2 ? pad_button(g, PAD_ID(hv)) : 0;
    joy_b1[i] = p || h; joy_b2[i] = sh || h;
    for (int a = ACT_NUMBERS; a < NACT; a++) {
      int v = bind.joy[i][a], now = v >= 2 && pad_button(g, PAD_ID(v)) && input_in_game();
      if (now != was[i][a]) { key_xt(act_default_key(a), now); was[i][a] = (unsigned char)now; }
    }
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
    joy_len[2 * i] = 300 + (unsigned)((x + 1) * 2000);     /* centre about 2300 instructions, ~330 turns of the game's loop */
    joy_len[2 * i + 1] = 300 + (unsigned)((y + 1) * 2000);
  }
}

uint8_t joy_port(void)
{
  uint64_t t = cpu_instr_count() - joy_t0;
  uint8_t v = 0xF0;
  for (int i = 0; i < 4; i++) if (t < joy_len[i]) v |= 1 << i;
  for (int i = 0; i < 2; i++) {
    if (joy_b1[i]) v &= ~(0x10 << (2 * i));
    if (joy_b2[i]) v &= ~(0x20 << (2 * i));
  }
  return v;
}

/* ---- scripted input (tests): NHL94_KEYS="ms:Key[/hold] ms:@x,y ms:@click[/hold]" ---- */
struct skey { double t; int code; int down; int mx, my, click; };
static struct skey script[256];
static int nscript, iscript;

void input_script(const char *s)
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
    if (sc == SDL_SCANCODE_UNKNOWN || !xt_code(sc)) { fprintf(stderr, "NHL94_KEYS: unknown key %s\n", name); continue; }
    script[nscript++] = (struct skey){ ms / 1000, sc, 1, -1, -1, 0 };
    script[nscript++] = (struct skey){ (ms + hold) / 1000, sc, 0, -1, -1, 0 };
  }
  for (int i = 1; i < nscript; i++) for (int j = i; j > 0 && script[j].t < script[j - 1].t; j--) {
    struct skey t = script[j]; script[j] = script[j - 1]; script[j - 1] = t; }
}

void input_script_run(double t)
{
  while (iscript < nscript && script[iscript].t <= t) {
    struct skey *k = &script[iscript++];
    if (k->code) { key_physical((SDL_Scancode)k->code, k->down); LOG("script key %s %s\n", SDL_GetScancodeName(k->code), k->down ? "down" : "up"); }
    else if (k->click) { mdown[SDL_BUTTON_LEFT] = k->click == 1; mouse_update_buttons(); }
    else mouse_set_pos(k->mx, k->my);
  }
}

/* ---- SDL events ---- */
void input_init(void)
{
  if (getenv("NHL94_VPAD"))                     /* testing: a virtual controller with nothing pressed */
    SDL_JoystickAttachVirtual(SDL_JOYSTICK_TYPE_GAMECONTROLLER, SDL_CONTROLLER_AXIS_MAX, SDL_CONTROLLER_BUTTON_MAX, 0);
  pads_open();
}

void input_poll(void)
{
  SDL_Event e;
  joy_update();
  cursor_update();
  while (SDL_PollEvent(&e)) {
    switch (e.type) {
    case SDL_QUIT: cpu_quit = 1; break;
    case SDL_KEYDOWN:
      if (e.key.keysym.scancode == SDL_SCANCODE_RETURN && (e.key.keysym.mod & KMOD_ALT)) {     /* Alt+Enter: fullscreen */
        if (!e.key.repeat) video_toggle_fullscreen();
        break;
      }
      if (e.key.keysym.scancode == SDL_SCANCODE_F11 && (e.key.keysym.mod & KMOD_CTRL)) {        /* Ctrl+F11: record the sound */
        if (!e.key.repeat) audio_capture_toggle();
        break;
      }
      if (e.key.keysym.scancode == SDL_SCANCODE_GRAVE && !(e.key.keysym.mod & (KMOD_CTRL | KMOD_ALT))) {   /* ` : the stats display */
        if (!e.key.repeat) video_command(CMD_STATS);
        break;
      }
      if (!e.key.repeat) key_physical(e.key.keysym.scancode, 1);
      break;
    case SDL_KEYUP:
      if (e.key.keysym.scancode == SDL_SCANCODE_GRAVE) break;
      key_physical(e.key.keysym.scancode, 0);
      break;
    case SDL_SYSWMEVENT: menu_event(e.syswm.msg); break;
    case SDL_CONTROLLERDEVICEADDED: case SDL_CONTROLLERDEVICEREMOVED: pads_open(); break;
    case SDL_MOUSEMOTION: mouse_abs(e.motion.x, e.motion.y); break;
    case SDL_MOUSEBUTTONDOWN: case SDL_MOUSEBUTTONUP:
      if (e.button.button >= 1 && e.button.button <= 5) mdown[e.button.button] = e.type == SDL_MOUSEBUTTONDOWN;
      mouse_update_buttons();
      break;
    }
  }
}
