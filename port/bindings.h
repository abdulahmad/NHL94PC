#ifndef BINDINGS_H
#define BINDINGS_H
#include <stdio.h>

/* What the player can bind (taken from the NHL 95 port). In play NHL '94 reads, for each team, the keyboard, a game port joystick or the
 * mouse (seg007): on the keyboard button A (pass / change player) is Alt or Ins, button B (shoot / speed burst) Space or Enter, and button C
 * (hold / change line) both together; then Esc, Tab, R, F1-F10, Ctrl+S and Ctrl+M. A binding says which key, mouse button or controller
 * button stands for one of these. The keys are XT scan codes (0x100 = extended), what the game reads from port 60h. */
enum { ACT_UP, ACT_DOWN, ACT_LEFT, ACT_RIGHT, ACT_PASS, ACT_SHOOT, ACT_HOLD, ACT_NUMBERS,
       ACT_HOME1, ACT_HOME2, ACT_HOME3, ACT_HOME4, ACT_AWAY1, ACT_AWAY2, ACT_AWAY3, ACT_AWAY4, ACT_PAUSE, ACT_REPLAY, NACT };

#define PAD_NONE 0
#define PAD_DEFAULT 1                           /* pass: A or X, shoot: B or Y (the first ones: nothing was bound) */
#define PAD_VALUE(id) ((id) + 2)                /* a controller button: SDL_CONTROLLER_BUTTON_* (0-14), 20 left trigger, 21 right trigger */
#define PAD_ID(v) ((v) - 2)

struct bindings {
    int kb[NACT];                               /* XT scan code of the key that does the action; 0 none */
    int ms[3];                                  /* SDL mouse button (1 left, 2 middle, 3 right, 4, 5) for pass, shoot, hold; 0 none */
    int joy[2][NACT];                           /* Joystick One and Two: PAD_NONE, PAD_DEFAULT or PAD_VALUE(button) */
};

extern struct bindings bind;

const char *act_name(int a);                    /* the name in the ini file */
const char *act_label(int a);                   /* the name on the screen */
int act_default_key(int a);                     /* the game's own key for the action (0 for hold: it is two keys) */
void bindings_defaults(struct bindings *b);
void bindings_load(void);                       /* from hockey94.ini */
void bindings_save(FILE *f);                    /* into the ini file the video settings are written to (video.c) */
void settings_save_all(void);                   /* video.c: rewrite the ini file */

/* a physical key while a game is on: the game's keys to send (at most 4), or -1 if the key is not bound and goes through as it is */
int bindings_kb(int xt, int *out);
/* the game's mouse buttons (bit 1 left, 2 right) for the physical buttons that are down (index 1-5) */
int bindings_mouse(const unsigned char *down);

#ifdef _WIN32
void bindings_dialog_open(void *parent_hwnd);   /* bindings_win.c */
#endif
#endif
