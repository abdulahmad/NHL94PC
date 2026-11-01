/* host.h: the host side of the port (window, picture, settings, input, Windows menu), shared by main.c, video.c, input.c,
 * bindings*.c and menu_win.c. Most of it follows the NHL 95 PC port (branch sdl2-port of abdulahmad/nhl95pc). */
#ifndef HOST_H
#define HOST_H
#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ---- video.c: the window, the picture and its looks, the settings file ---- */
void video_init(int want_gl);                          /* settings, window (OpenGL when it can), menu bar */
void video_present(void);                              /* draw the game's current picture */
int video_changed(void);                               /* VRR: the picture the game shows changed since it was last drawn */
double video_present_interval(void);                   /* seconds between pictures at 60 or 70 Hz */
int video_vrr(void);
void video_view(int *vx, int *vy, int *vw, int *vh);   /* where the 4:3 picture is in the window (window coordinates) */
void video_mode_size(int *w, int *h);                  /* the game's screen size (320x200 or 640x480) */
void video_confine_mouse(int on);                      /* keep the host's pointer on the 4:3 picture */
void video_toggle_fullscreen(void);                    /* Alt+Enter */
int video_is_fullscreen(void);
int video_pointer_mode(void);                          /* 0 automatic, 1 always show, 2 always hide the system pointer */
void video_set_title(const char *title);
void video_dump(const char *dir);                      /* NHL94_DUMP: the screen as dir/shot%04d.ppm */
void *video_window(void);                              /* the SDL_Window */
void settings_save_all(void);                          /* rewrite the ini file (video settings and the bindings) */
const char *settings_path(void);                       /* the ini file: hockey94.ini next to the program */
enum { CMD_REFRESH_60 = 100, CMD_REFRESH_70, CMD_REFRESH_VRR, CMD_VSYNC, CMD_STATS, CMD_HIRES = 200, CMD_LORES = 300, CMD_VSCALE_HI = 400,
       CMD_VSCALE_LO = 410, CMD_POINTER = 500, CMD_MBRIGHT_HI = 600, CMD_MRESET_HI = 610, CMD_MRESET_LO = 611, CMD_MBRIGHT_LO = 620,
       CMD_MSCALE_HI = 640, CMD_MSCALE_LO = 650, CMD_MKHZ = 660, CMD_INPUT = 700, CMD_MFILE = 1000 };
#define NHIRES_ITEMS 11
#define NLORES_ITEMS 11
void video_command(int id);                            /* a menu command (or the ` key) */
int video_command_checked(int id);
void video_mister_pick(int cls, int kind, const char *rel);  /* a MiSTer look file chosen from the menu: class 0 hi-res, 1 320x200; kind 0 horizontal filter, 1 vertical, 2 gamma, 3 mask, 4 preset */
const char *video_mister_path(int cls, int kind);
int video_mister_preset_active(int cls, const char *rel);

/* ---- menu_win.c: the window's menu bar (Windows only) ---- */
#ifdef _WIN32
void menu_init(void *sdl_window);
void menu_sync(void);
void menu_show(int on);
void menu_event(void *syswm_msg);
int menu_client_size(int *w, int *h);                  /* the client area as Windows has it, 0 if unknown */
#else
static inline void menu_init(void *w) { (void)w; }
static inline void menu_sync(void) {}
static inline void menu_show(int on) { (void)on; }
static inline void menu_event(void *m) { (void)m; }
static inline int menu_client_size(int *w, int *h) { (void)w; (void)h; return 0; }
#endif

/* ---- plat.c ---- */
int plat_cpu_percent(void);                            /* this process, -1 if unknown */
int plat_gpu_percent(void);

/* ---- input.c: keyboard, mouse, game controllers (the game port), scripted input, what the game is doing ---- */
void input_init(void);
void input_hooks(void);                                /* after the EXE is loaded: the hooks that show what the game is doing */
void input_poll(void);                                 /* main thread: SDL events */
void input_script(const char *s);                      /* NHL94_KEYS */
void input_script_run(double t);
int input_in_game(void);                               /* a game is being played (the game's in-play keyboard reader ran lately) */
int input_glove(void);                                 /* the game's menus with the glove pointer are on the screen */
#endif
