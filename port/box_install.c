/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 abdulahmad and contributors
 *
 * The box for NHL 94 PC: installing from the four disks on a 486 with a VGA monitor (the mockup's p3 scene), drawn in 2D. */
#include "box_pc94.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/* the DOS screen: \x01 yellow \x02 cyan \x03 green \x04 highlight \x05 white \x0f plain; \x10-\x17 box drawing */
#define BOXTL "\x10"
#define BOXH "\x11"
#define BOXTR "\x12"
#define BOXV "\x13"
#define BOXBL "\x14"
#define BOXBR "\x15"
#define FULL "\x16"
#define SHADE "\x17"

static struct {
    int up, run, disk, inserted, busy, hd_on, cursor, pc;
    char scr[4096], log[2048];
    const char *typing; int tpos, tspeed, tnext;
    float pre;                       /* 1 -> 0: the PC and monitor pop in */
    float gone[5], used[5];          /* disk flown into the drive (0..1), greyed */
    int need;                        /* disk asked for (pulses) */
    char cap[160];
    /* copying */
    int fi, f0, f1; long done, total; char shown[9][16]; int nshown;
    int menu_sel;
} I;

typedef struct { char name[16]; long size; } file_t;
static file_t *FL; static int nfl;
static void load_files(void)
{
    if (FL) return;
    char p[1300], line[128];
    snprintf(p, sizeof p, "%s/files.txt", BX_S->dir);
    FILE *f = fopen(p, "r");
    FL = (file_t *)calloc(600, sizeof *FL);
    if (!FL) return;
    if (f) { while (nfl < 600 && fgets(line, sizeof line, f)) if (sscanf(line, "%15s %ld", FL[nfl].name, &FL[nfl].size) == 2) nfl++; fclose(f); }
    if (!nfl) { static const char *d[] = { "HOCKEY.EXE", "HOCKEY.DAT", "TEAMS.DAT", "SOUND.DAT" }; for (int i = 0; i < 4; i++) { snprintf(FL[i].name, 16, "%s", d[i]); FL[i].size = 200000; } nfl = 4; }
}

int box_install_up(void) { return I.up; }
static void set_screen(const char *t, int cursor) { snprintf(I.scr, sizeof I.scr, "%s", t); I.cursor = cursor; }
static void say(const char *s) { snprintf(I.cap, sizeof I.cap, "%s", s); }

static void step(int pc);
static void later(float ms, int pc) { bx_after(ms, step, (I.run << 8) | pc); }
/* type a string at the prompt, then go on at pc */
static void type_then(const char *s, int speed, int pc) { I.typing = s; I.tpos = 0; I.tspeed = speed; I.tnext = pc; later((float)speed, 200); }

static const char *menu_screen(int sel)
{
    static char b[1024];
    const char *it[3] = { "Install game to hard disk ", "Sound Options             ", "Exit                      " };
    int n = snprintf(b, sizeof b, "\x01  NHL HOCKEY '94  -  SETUP\x0f\n\n\x02" BOXTL);
    for (int i = 0; i < 38; i++) n += snprintf(b + n, sizeof b - n, BOXH);
    n += snprintf(b + n, sizeof b - n, BOXTR "\n" BOXV "                                      " BOXV "\x0f\n");
    for (int i = 0; i < 3; i++) n += snprintf(b + n, sizeof b - n, "\x02" BOXV "\x0f  %s%s\x0f          \x02" BOXV "\x0f\n", i == sel ? "\x04" : "", it[i]);
    n += snprintf(b + n, sizeof b - n, "\x02" BOXV "                                      " BOXV "\n" BOXBL);
    for (int i = 0; i < 38; i++) n += snprintf(b + n, sizeof b - n, BOXH);
    snprintf(b + n, sizeof b - n, BOXBR "\x0f\n\n Use arrow keys, then press ENTER.");
    return b;
}

static void copy_screen(void)
{
    int n = I.disk + 1;
    float pct = I.total ? (float)I.done / I.total : 0;
    int bars = (int)lroundf(pct * 40);
    char b[2048]; int k = snprintf(b, sizeof b, "\x01  Copying Disk %d of 4\x0f\n\n [\x03", n);
    for (int i = 0; i < bars; i++) k += snprintf(b + k, sizeof b - k, FULL);
    k += snprintf(b + k, sizeof b - k, "\x0f");
    for (int i = bars; i < 40; i++) k += snprintf(b + k, sizeof b - k, SHADE);
    k += snprintf(b + k, sizeof b - k, "] %3d%%\n\n", (int)lroundf(pct * 100));
    for (int i = 0; i < I.nshown; i++) k += snprintf(b + k, sizeof b - k, "  C:\\HOCKEY\\%s\n", I.shown[i]);
    set_screen(b, 0);
}

static void step(int arg)
{
    if ((arg >> 8) != I.run || !I.up) return;
    int pc = arg & 255;
    switch (pc) {
    case 0: bx_sfx(SFX_BEEP, 0); set_screen("\nPhoenix 486 BIOS\nCPU: 486DX2-66   Cache: 256K\nMemory Test: 8192K OK\n\n\nStarting MS-DOS...\n", 0); I.pc = 0; later(180, 1); break;
    case 1: bx_sfx(SFX_STEP, 0); if (++I.pc < 5) later(180, 1); else later(900, 2); break;
    case 2: snprintf(I.log, sizeof I.log, "\nMS-DOS Version 6.22\n\nC:\\>"); set_screen(I.log, 1); say("<b>Put Disk 1 in drive A.</b> Pick the disk."); I.need = 1; I.busy = 0; break;
    /* disk 1 in: run setup */
    case 10: type_then("A:", 90, 11); break;
    case 11: strncat(I.log, "\n", sizeof I.log - strlen(I.log) - 1); set_screen(I.log, 1); later(500, 12); break;
    case 12: bx_sfx(SFX_HDD, 0); strncat(I.log, "\nA:\\>", sizeof I.log - strlen(I.log) - 1); type_then("setup", 90, 13); break;
    case 13: strncat(I.log, "\n", sizeof I.log - strlen(I.log) - 1); set_screen(I.log, 1); I.hd_on = 2; bx_sfx(SFX_MOTOR, 0); bx_sfx(SFX_SEEK, 6); later(1100, 14); break;
    case 14: I.hd_on = 0; set_screen(menu_screen(1), 0); later(700, 15); break;
    case 15: set_screen(menu_screen(0), 0); later(1100, 16); break;
    case 16: bx_sfx(SFX_KEY, 0); set_screen("\x01  Install game to hard disk\x0f\n\nDrive containing the disk: \x03" "A:\x0f", 1); later(1300, 17); break;
    case 17: bx_sfx(SFX_KEY, 0); set_screen("\x01  Install game to hard disk\x0f\n\nDrive containing the disk: \x03" "A:\x0f\nInstall to directory:      \x03" "C:\\HOCKEY\x0f\n\nRequires approximately 10 MB free.", 1); later(1500, 20); break;
    /* copy the disk's share of the files */
    case 20: {
        bx_sfx(SFX_KEY, 0);
        int per = (nfl + 3) / 4, n = I.disk;
        I.f0 = n * per; I.f1 = (n + 1) * per; if (I.f1 > nfl) I.f1 = nfl;
        I.fi = I.f0; I.done = 0; I.total = 0; I.nshown = 0;
        for (int i = I.f0; i < I.f1; i++) I.total += FL[i].size;
        I.hd_on = 2; bx_sfx(SFX_MOTOR, 0);
        later(10, 21);
        break;
    }
    case 21: {
        if (I.fi >= I.f1) { I.hd_on = 0; later(300, 22); break; }
        file_t *f = &FL[I.fi];
        I.done += f->size;
        if (I.nshown == 9) { memmove(I.shown, I.shown + 1, sizeof I.shown[0] * 8); I.nshown = 8; }
        snprintf(I.shown[I.nshown++], 16, "%s", f->name);
        copy_screen();
        bx_sfx(SFX_HDD, 0); I.hd_on = 3;
        int i = I.fi - I.f0;
        if (i % 6 == 0) bx_sfx(SFX_SEEK, 3);
        if (i % 14 == 0) bx_sfx(SFX_STEP, 0);
        I.fi++;
        float ms = 14 + f->size / 9000.0f; if (ms > 55) ms = 55;
        later(ms, 21);
        break;
    }
    case 22: {
        int n = I.disk + 1;
        char b[256];
        if (n < 4) {
            snprintf(b, sizeof b, "\x01  Disk %d copied.\x0f\n\n  Please remove Disk %d and insert Disk %d.\n\n  Press ENTER to continue...", n, n, n + 1);
            set_screen(b, 1);
            later(1400, 23);
        } else later(500, 30);
        break;
    }
    case 23: {
        int n = I.disk + 1;
        bx_sfx(SFX_DISK_OUT, 0);
        I.gone[n] = 0; I.used[n] = 1; I.disk = n; I.inserted = 0; I.need = n + 1; I.busy = 0;
        char b[96]; snprintf(b, sizeof b, "<b>Disk %d ejected.</b> Insert Disk %d.", n, n + 1); say(b);
        break;
    }
    case 30:
        bx_sfx(SFX_DISK_OUT, 0); I.gone[4] = 0; I.used[4] = 1; I.need = 0;
        set_screen("\x01  All disks installed.\x0f\n\n  Sound Options:\n\n    Music:   \x03Sound Blaster\x0f\n    Effects: \x03Sound Blaster\x0f\n\n  Select Exit to finish.", 0);
        later(2200, 31);
        break;
    case 31: snprintf(I.log, sizeof I.log, "\nC:\\>"); set_screen(I.log, 1); type_then("C:", 90, 32); break;
    case 32: strncat(I.log, "\n\nC:\\>", sizeof I.log - strlen(I.log) - 1); type_then("cd\\hockey", 80, 33); break;
    case 33: strncat(I.log, "\n\nC:\\HOCKEY>", sizeof I.log - strlen(I.log) - 1); type_then("hockey", 90, 34); break;
    case 34: strncat(I.log, "\n", sizeof I.log - strlen(I.log) - 1); set_screen(I.log, 1); say("<b>Installed.</b> Starting the game..."); later(1200, 35); break;
    case 35: bx_done(); break;
    /* typing */
    case 200: {
        if (!I.typing[I.tpos]) { later(1, I.tnext); break; }
        size_t L = strlen(I.log);
        if (L + 2 < sizeof I.log) { I.log[L] = I.typing[I.tpos]; I.log[L + 1] = 0; }
        I.tpos++;
        set_screen(I.log, 1);
        bx_sfx(SFX_KEY, 0);
        later((float)I.tspeed, 200);
        break;
    }
    }
}

void box_install_start(void)
{
    load_files();
    memset(I.gone, 0, sizeof I.gone); memset(I.used, 0, sizeof I.used);
    I.disk = 0; I.inserted = 0; I.need = 0; I.run++; I.busy = 1; I.hd_on = 0;
    I.scr[0] = 0; I.pre = 1;
    say("<b>Setting up the PC...</b>");
    I.up = 1;
    snprintf(BX.title, sizeof BX.title, "Install NHL Hockey '94");
    later(1100, 0);
}
void box_install_skip(int a) { (void)a; I.run++; }

static void insert_disk(int n)
{
    if (I.inserted || I.busy) return;
    if (n != I.disk + 1) { char b[96]; snprintf(b, sizeof b, "<b>Not that one.</b> The installer wants Disk %d.", I.disk + 1); say(b); return; }
    I.inserted = n; I.busy = 1; I.need = 0;
    bx_sfx(SFX_DISK_IN, 0);
    char b[64]; snprintf(b, sizeof b, "<b>Disk %d</b> is in the drive.", n); say(b);
    later(700, n == 1 ? 10 : 20);
}
static void back_to_box(int a) { (void)a; I.run++; I.up = 0; box_pc94_arranged(); }
static void back_btn(int a) { (void)a; bx_fade(back_to_box, 0); }
void box_install_back(void) { back_btn(0); }
static void disk_btn(int n) { insert_disk(n); }

/* ---- drawing ---- */
static uint32_t dos_col(int c) { return c == 1 ? 0xffff55 : c == 2 ? 0x55ffff : c == 3 ? 0x55ff55 : c == 5 ? 0xffffff : 0xc8c8c8; }
static void dos_draw(float x0, float y0, float w, float h)
{
    float u = BX_C.u, fs = 1.28f * u, lh = fs * 1.18f, cw = fs * 0.6f;
    float x = x0 + 1.6f * u, y = y0 + 1.2f * u + fs;
    int col = 0, hl = 0;
    for (const unsigned char *p = (const unsigned char *)I.scr; *p; p++) {
        unsigned c = *p;
        if (c == '\n') { x = x0 + 1.6f * u; y += lh; hl = 0; continue; }
        if (c >= 1 && c <= 5) { if (c == 4) hl = 1; else col = c; continue; }
        if (c == 0x0f) { col = 0; hl = 0; continue; }
        if (y > y0 + h) break;
        uint32_t fg = hl ? 0x000000 : dos_col(col);
        if (hl) bx_rect(x, y - fs, cw + .5f, lh, 0xffc8c8c8);
        if (c >= 0x10 && c <= 0x17) {
            uint32_t a = 0xff000000u | fg;
            float cx = x + cw / 2, cy = y - fs * 0.35f, t = fmaxf(1, fs * 0.08f), g = t * 1.6f;
            float L = x, R = x + cw, T = y - fs, Bt = y - fs + lh;
            switch (c) {
            case 0x11: bx_rect(L, cy - g, cw, t, a); bx_rect(L, cy + g - t, cw, t, a); break;
            case 0x13: bx_rect(cx - g, T, t, lh, a); bx_rect(cx + g - t, T, t, lh, a); break;
            case 0x10: bx_rect(cx - g, cy - g, R - cx + g, t, a); bx_rect(cx + g - t, cy + g - t, R - cx - g + t, t, a); bx_rect(cx - g, cy - g, t, Bt - cy + g, a); bx_rect(cx + g - t, cy + g - t, t, Bt - cy - g + t, a); break;
            case 0x12: bx_rect(L, cy - g, cx + g - L, t, a); bx_rect(L, cy + g - t, cx - g - L + t, t, a); bx_rect(cx + g - t, cy - g, t, Bt - cy + g, a); bx_rect(cx - g, cy + g - t, t, Bt - cy - g + t, a); break;
            case 0x14: bx_rect(cx - g, T, t, cy + g - T, a); bx_rect(cx + g - t, T, t, cy - g - T + t, a); bx_rect(cx - g, cy + g - t, R - cx + g, t, a); bx_rect(cx + g - t, cy - g, R - cx - g + t, t, a); break;
            case 0x15: bx_rect(cx + g - t, T, t, cy + g - T, a); bx_rect(cx - g, T, t, cy - g - T + t, a); bx_rect(L, cy + g - t, cx + g - L, t, a); bx_rect(L, cy - g, cx - g - L + t, t, a); break;
            case 0x16: bx_rect(x, y - fs, cw + .5f, lh, a); break;
            case 0x17: for (float yy = y - fs; yy < y - fs + lh; yy += 2) for (float xx = x + ((int)yy & 2 ? 1 : 0); xx < x + cw; xx += 3) bx_rect(xx, yy, 1, 1, (a & 0xffffff) | 0x80000000u); break;
            }
        } else if (c >= 32 && c < 127) {
            char s[2] = { (char)c, 0 };
            bx_text(x + cw / 2, y, fs, fg, 255, s, 1, 0);
        }
        x += cw;
    }
    if (I.cursor && ((int)(bx_now() * 2) & 1) == 0) bx_rect(x, y - fs * .85f, cw * .9f, fs, 0xffc8c8c8);
}

void box_install_draw(void)
{
    float u = BX_C.u, sx = BX_C.sx, sy = BX_C.sy, sw = BX_C.sw, sh = BX_C.sh;
    /* the desk */
    bx_desk();
    if (I.pre > 0) { I.pre -= 0.03f; if (I.pre < 0) I.pre = 0; }
    float pop = bx_ease(1 - I.pre);                      /* 0 -> 1: the PC pops in */
    float sc = .2f + .8f * pop, al = pop;
    /* CRT */
    float cw = 46 * u * sc, cx = sx + .05f * sw + 23 * u * (1 - sc), cy = sy + .07f * sh + (1 - sc) * 20 * u;
    float gw = cw - 4 * u * sc, gh = gw * 3 / 4, ch = gh + 5.4f * u * sc;
    if (al > .05f) {
        bx_rrect(cx + cw * .3f, cy + ch - .2f * u, cw * .4f, 1.8f * u * sc, .8f * u, 0xff9e9886, 0, 0);
        bx_rrect(cx, cy, cw, ch, 1.4f * u * sc, 0xffc8c2af, 0, 0);
        bx_rrect(cx, cy, cw, ch * .5f, 1.4f * u * sc, 0x30ffffff, 0, 0);
        float gx = cx + 2 * u * sc, gy = cy + 2 * u * sc;
        bx_rrect(gx - .3f * u, gy - .3f * u, gw + .6f * u, gh + .6f * u, 1.7f * u * sc, 0xff6b6659, 0, 0);
        bx_rrect(gx, gy, gw, gh, 1.6f * u * sc, 0xff020402, 0, 0);
        if (sc > .99f) dos_draw(gx, gy, gw, gh);
        for (float yy = gy; yy < gy + gh; yy += .42f * u) bx_rect(gx + .6f * u, yy + .28f * u, gw - 1.2f * u, .14f * u, 0x33000000);
        bx_text(cx + 2.4f * u * sc, cy + ch - 1.1f * u * sc, 1.0f * u * sc, 0x5d584c, 255, "VGA COLOR MONITOR", 1, -1);
        ob_vf_disc(BX_C.px, BX_C.w, BX_C.h, BX_C.pitch, cx + cw - 3.4f * u * sc, cy + ch - 1.5f * u * sc, .45f * u * sc, 0xff22aa44, 0, 0);
    }
    /* tower */
    float tw = .2f * sw * sc, th = .56f * sh * sc, tx = sx + .55f * sw + (1 - sc) * 10 * u, ty = sy + .07f * sh + (1 - sc) * 20 * u;
    if (al > .05f) {
        bx_rrect(tx, ty, tw, th, .8f * u, 0xffc6c0ad, 0, 0);
        bx_rrect(tx, ty, tw, th * .4f, .8f * u, 0x22ffffff, 0, 0);
        bx_rect(tx + tw * .12f, ty + th * .06f, tw * .76f, th * .08f, 0xffbdb7a5); bx_rrect(tx + tw * .12f, ty + th * .06f, tw * .76f, th * .08f, 0, 0, 0xff8a8576, .2f * u);
        bx_rect(tx + tw * .12f, ty + th * .16f, tw * .76f, th * .08f, 0xffbdb7a5); bx_rrect(tx + tw * .12f, ty + th * .16f, tw * .76f, th * .08f, 0, 0, 0xff8a8576, .2f * u);
        float bx = tx + tw * .14f, by = ty + th * .27f, bw = tw * .72f, bh = th * .09f;
        bx_rrect(bx, by, bw, bh, .2f * u, 0xffc9c3b0, 0xff8a8576, .2f * u);
        bx_rect(bx + bw * .08f, by + bh * .42f, bw * .62f, bh * .14f, I.inserted ? 0xffcc3333 : 0xff111111);
        bx_rect(bx + bw * .80f, by + bh * .3f, bw * .14f, bh * .4f, 0xff9d978a);
        int busy_led = I.hd_on == 2 || (I.inserted && I.hd_on);
        bx_rect(bx + bw * .70f, by + bh * .14f, bw * .06f, bh * .14f, busy_led ? 0xff33ff66 : 0xff114422);
        float py = ty + th * .62f;
        ob_vf_disc(BX_C.px, BX_C.w, BX_C.h, BX_C.pitch, tx + tw * .16f, py, .4f * u, 0xff22aa44, 0, 0);
        bx_text(tx + tw * .16f + .9f * u, py + .35f * u, .9f * u, 0x5d584c, 255, "POWER", 1, -1);
        int hd = I.hd_on == 3 && ((int)(bx_now() * 14) & 1);
        ob_vf_disc(BX_C.px, BX_C.w, BX_C.h, BX_C.pitch, tx + tw * .16f, py + 1.4f * u, .4f * u, hd ? 0xffffaa33 : 0xff442200, 0, 0);
        bx_text(tx + tw * .16f + .9f * u, py + 1.75f * u, .9f * u, 0x5d584c, 255, "HDD", 1, -1);
        bx_rrect(tx + tw * .12f, ty + th * .86f, tw * .22f, th * .06f, .2f * u, 0xff8e8878, 0, 0);
        bx_text(tx + tw * .23f, ty + th * .905f, .8f * u, 0x222222, 255, "TURBO 66", 1, 0);
        bx_rrect(tx + tw * .70f, ty + th * .84f, tw * .18f, th * .08f, .2f * u, 0xff6d685b, 0, 0);
    }
    /* the disks */
    float dw = 8 * u, dh = 8.4f * u, gap = 1.6f * u, rowx = sx + (sw - 4 * dw - 3 * gap) / 2, rowy = sy + sh - 4.6f * u - dh;
    for (int n = 1; n <= 4; n++) {
        float x = rowx + (n - 1) * (dw + gap), y = rowy;
        if (I.inserted == n && I.gone[n] < 1) I.gone[n] += .04f;
        if (I.inserted != n && I.gone[n] > 0) I.gone[n] -= .06f;
        float g = I.gone[n] < 0 ? 0 : I.gone[n] > 1 ? 1 : I.gone[n];
        if (I.need == n) y -= fabsf(sinf((float)bx_now() * 2.85f)) * .8f * u;
        x += g * 46 * u; y -= g * 26 * u;
        float s = 1 - .3f * g, a = 1 - g;
        char k[8]; snprintf(k, sizeof k, "disk%d", n);
        if (a > .02f) {
            bx_image(bx_art(k), x + dw * (1 - s) / 2, y + dh * (1 - s) / 2, dw * s, dh * s, a);
            if (I.used[n] && !I.inserted) bx_rect(x, y, dw, dh, 0x99000000);
        }
    }
    /* the disks are picked where they lie */
    static const char *lab[5] = { "", "Insert Disk 1", "Insert Disk 2", "Insert Disk 3", "Insert Disk 4" };
    for (int n = 1; n <= 4; n++)
        if (!I.busy && !I.inserted && !I.used[n]) bx_hot_rect(rowx + (n - 1) * (dw + gap), rowy, dw, dh, lab[n], disk_btn, n);
    bx_button(sx + 2 * u, sy + 1.4f * u, "< Back to the box", back_btn, 0, -1);
    bx_text(sx + sw - 2 * u, sy + 3.4f * u, 1.5f * u, 0xb5a58f, 255, BX.title, 0, 1);
    if (I.cap[0]) bx_rich(sx + sw / 2, sy + sh - 1.4f * u, 1.6f * u, I.cap, 0xb5a58f, 0xf4ecdf);
}
