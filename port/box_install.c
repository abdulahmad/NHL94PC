/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 abdulahmad and contributors
 *
 * The box for NHL 94 PC: installing from the four disks on a 486 on the desk, in 3D. Each disk is picked from the desk and goes
 * into the tower's 3.5" drive; the VGA monitor shows the game's own installer (EA's Setup Program, version 1.1, 1993) as it
 * looked: its screens, colours, boxes and messages, in the 80 x 25 text mode. The text mode's 8 x 16 font is read from the
 * player's art folder (vgafont.png), like the scans; without it a plain font stands in. */
#include "box_pc94.h"
#include <overbar/vfont.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ---- the 80 x 25 text screen ---- */
enum { BLK, BLU, GRN, CYN, RED, MAG, BRN, LGR, DGR, LBL, LGN, LCY, LRD, LMG, YEL, WHT };
static const uint32_t PAL[16] = { 0x000000, 0x0000aa, 0x00aa00, 0x00aaaa, 0xaa0000, 0xaa00aa, 0xaa5500, 0xaaaaaa,
                                  0x555555, 0x5555ff, 0x55ff55, 0x55ffff, 0xff5555, 0xff55ff, 0xffff55, 0xffffff };
static uint16_t TXT[25][80];                 /* char | fg << 8 | bg << 12 */
static int cur_x = -1, cur_y, dirty = 1;
static void t_put(int x, int y, int ch, int fg, int bg)
{
    if (x < 0 || y < 0 || x >= 80 || y >= 25) return;
    uint16_t o = TXT[y][x];
    if (ch < 0) ch = o & 255;
    if (fg < 0) fg = (o >> 8) & 15;
    if (bg < 0) bg = o >> 12;
    TXT[y][x] = (uint16_t)((ch & 255) | fg << 8 | bg << 12);
    dirty = 1;
}
static void t_fill(int x, int y, int w, int h, int ch, int fg, int bg) { for (int j = y; j < y + h; j++) for (int i = x; i < x + w; i++) t_put(i, j, ch, fg, bg); }
static void t_puts(int x, int y, const char *s, int fg, int bg) { for (; *s; s++, x++) t_put(x, y, (unsigned char)*s, fg, bg); }
static void t_cls(int bg) { t_fill(0, 0, 80, 25, ' ', LGR, bg); cur_x = -1; }
/* a window: filled, a single line border, and the shadow two columns right and one row down */
static void t_win(int x, int y, int w, int h, int fg, int bg, int border)
{
    t_fill(x, y, w, h, ' ', fg, bg);
    if (border) {
        for (int i = x + 1; i < x + w - 1; i++) { t_put(i, y, 0xc4, fg, bg); t_put(i, y + h - 1, 0xc4, fg, bg); }
        for (int j = y + 1; j < y + h - 1; j++) { t_put(x, j, 0xb3, fg, bg); t_put(x + w - 1, j, 0xb3, fg, bg); }
        t_put(x, y, 0xda, fg, bg); t_put(x + w - 1, y, 0xbf, fg, bg); t_put(x, y + h - 1, 0xc0, fg, bg); t_put(x + w - 1, y + h - 1, 0xd9, fg, bg);
    }
    t_fill(x + w, y + 1, 2, h - 1, -1, -1, BLK);
    t_fill(x + 2, y + h, w, 1, -1, -1, BLK);
}
static void t_status(const char *s) { t_fill(0, 24, 80, 1, ' ', BLK, CYN); t_puts((80 - (int)strlen(s)) / 2, 24, s, BLK, CYN); }

/* the Setup Program's screens */
static void s_frame(void)
{
    t_cls(LGR);
    t_win(2, 1, 74, 3, WHT, BLU, 0);
    t_puts(32, 1, "Setup Program", WHT, BLU);
    t_puts(33, 2, "Version 1.1", WHT, BLU);
    t_puts(21, 3, "Copyright (c) 1993 Electronic Arts", WHT, BLU);
}
static void s_menu(int sel)
{
    static const char *it[3] = { "Sound option", "Install game to hard disk", "Exit" };
    s_frame();
    t_win(3, 6, 41, 5, LGR, RED, 1);
    for (int i = 0; i < 3; i++) {
        if (i == sel) t_fill(4, 7 + i, 39, 1, ' ', BLK, LGR);
        t_puts(5, 7 + i, it[i], i == sel ? BLK : LGR, i == sel ? LGR : RED);
    }
    t_status("\x18 \x19 to move highlight, ENTER to select option, ESC to exit, F1 for help");
}
static void s_drive(void)
{
    s_frame();
    t_win(17, 6, 45, 4, WHT, GRN, 1);
    t_puts(25, 7, "Enter drive to install from", WHT, GRN);
    t_fill(38, 8, 3, 1, ' ', WHT, BLK);
    t_puts(38, 8, "A:", WHT, BLK);
    cur_x = 40; cur_y = 8;
    t_status("Type new drive name or, ENTER to accept, ESC to exit");
}
static void s_dir(void)
{
    cur_x = -1;
    t_win(17, 12, 45, 4, WHT, GRN, 1);
    t_puts(29, 13, "Enter game directory", WHT, GRN);
    t_fill(19, 14, 41, 1, ' ', WHT, BLK);
    t_puts(19, 14, "c:\\hockey", WHT, BLK);
    cur_x = 28; cur_y = 14;
    t_status("Type new directory name or, ENTER to accept, ESC to exit");
}
static void s_copying(const char *file)
{
    s_frame();
    t_win(10, 18, 34, 3, WHT, RED, 1);
    t_puts(12, 19, "Copying file:", WHT, RED);
    t_fill(26, 19, 16, 1, ' ', WHT, BLK);
    t_puts(26, 19, file, WHT, BLK);
    t_status("ESC to terminate install");
}
static void s_insert(int disk)
{
    char b[32];
    s_frame();
    t_win(19, 7, 22, 6, WHT, MAG, 1);
    t_puts(26, 8, "Insert", WHT, MAG);
    snprintf(b, sizeof b, "\"NHL Hockey\" Disk %d", disk);
    t_puts(20, 9, b, WHT, MAG);
    t_puts(24, 10, "in drive A:", WHT, MAG);
    t_puts(23, 11, "and hit Enter", WHT, MAG);
    t_status("ENTER to start file transfer, ESC to exit");
}

/* the DOS prompt: lines of text from the top, scrolling */
static char dos[25][81]; static int dos_n;
static void dos_show(int bg_bar)
{
    t_cls(BLK);
    int first = bg_bar ? 1 : 0;
    if (bg_bar) { t_fill(0, 0, 80, 1, ' ', WHT, BLU); t_puts(1, 0, "Setup Program - Copyright (c) 1993 Electronic Arts", WHT, BLU); }
    int top = dos_n > 25 - first ? dos_n - (25 - first) : 0;
    for (int i = top; i < dos_n; i++) t_puts(0, first + i - top, dos[i], LGR, BLK);
    cur_x = dos_n ? (int)strlen(dos[dos_n - 1]) : 0; cur_y = first + (dos_n ? dos_n - 1 - top : 0);
}
static int dos_bar;
static void dos_line(const char *s) { if (dos_n == 25) { memmove(dos, dos + 1, sizeof dos[0] * 24); dos_n = 24; } snprintf(dos[dos_n++], 81, "%s", s); dos_show(dos_bar); }
static void dos_add(const char *s) { if (!dos_n) dos_line(""); size_t L = strlen(dos[dos_n - 1]); snprintf(dos[dos_n - 1] + L, 81 - L, "%s", s); dos_show(dos_bar); }
static void dos_clear(int bar) { dos_n = 0; dos_bar = bar; dos_show(bar); }

/* the screen as a texture: 640 x 400 (the font's pixels doubled, so the text stays crisp close up) */
#define SW 1280
#define SH 800
static int scr_tex = -1, scr_node, blink_on = -1;
static void scr_render(void)
{
    int bl = ((int)(bx_now() * 3.75)) & 1;                  /* the VGA cursor: about 1.9 blinks a second */
    if (!dirty && bl == blink_on) return;
    dirty = 0; blink_on = bl;
    uint32_t *px = (uint32_t *)malloc((size_t)SW * SH * 4);
    if (!px) return;
    const r3_tex *f = bx_art("vgafont");
    for (int y = 0; y < 25; y++)
        for (int x = 0; x < 80; x++) {
            uint16_t c = TXT[y][x];
            int ch = c & 255;
            uint32_t fg = 0xff000000u | PAL[(c >> 8) & 15], bg = 0xff000000u | PAL[c >> 12];
            for (int j = 0; j < 16; j++) {
                uint32_t *row0 = px + (size_t)(y * 32 + j * 2) * SW + x * 16, *row1 = row0 + SW;
                for (int i = 0; i < 8; i++) {
                    int on = 0;
                    if (f && f->lw[0] == 128 && f->lh[0] == 256) on = (f->lv[0][((ch >> 4) * 16 + j) * 128 + (ch & 15) * 8 + i] >> 24) > 128;
                    if (x == cur_x && y == cur_y && bl && j >= 14) on = 1;
                    uint32_t v = on ? fg : bg;
                    row0[i * 2] = row0[i * 2 + 1] = row1[i * 2] = row1[i * 2 + 1] = v;
                }
            }
            if (!(f && f->lw[0] == 128 && f->lh[0] == 256) && ch > 32 && ch < 127) {   /* no font in the art folder: a plain one */
                char s[2] = { (char)ch, 0 };
                ob_vf_draw(px, SW, SH, SW, x * 16 + 2.0f, y * 32 + 25.0f, OB_VF_MEDIUM, 26, PAL[(c >> 8) & 15], 255, s, 0, 0);
            }
        }
    for (int i = 0; i < SW * SH; i++) px[i] |= 0xff000000u;
    r3_tex_set(&BX_S->texs[scr_tex], px, SW, SH);
}

/* ---- the desk ---- */
static int ready, desk, slot, disk_n[5], led_fd, led_hdd, mat_fd = -1, mat_hdd = -1;
static float home[5][6];                  /* each disk's place on the desk: pos, rot */
static float lin(int c) { float v = c / 255.0f; return v <= .04045f ? v / 12.92f : powf((v + .055f) / 1.055f, 2.4f); }
static int own_mat(int node)
{
    int r = -1;
    for (int i = 0; i < BX_S->nmeshes; i++) if (BX_S->meshes[i].node == node) {
        if (r < 0) { r3_mat m = BX_S->mats[BX_S->meshes[i].mat]; r = r3_mat_add(BX_S, &m); }
        BX_S->meshes[i].mat_override = r;
    }
    return r;
}
static void mat_col(int m, uint32_t c) { if (m < 0) return; BX_S->mats[m].col[0] = lin(c >> 16); BX_S->mats[m].col[1] = lin((c >> 8) & 255); BX_S->mats[m].col[2] = lin(c & 255); }
static void init(void)
{
    if (ready) return;
    desk = bx_node("pcDesk"); slot = bx_node("pc.slot"); scr_node = bx_node("pc.screen");
    led_fd = bx_node("pc.ledFd"); led_hdd = bx_node("pc.ledHdd");
    for (int n = 1; n <= 4; n++) {
        char k[16]; snprintf(k, sizeof k, "pc.disk%d", n);
        disk_n[n] = bx_node(k);
        r3_node *d = bx_n(disk_n[n]);
        memcpy(home[n], d->pos, sizeof d->pos); memcpy(home[n] + 3, d->rot, sizeof d->rot);
    }
    uint32_t *px = (uint32_t *)calloc((size_t)SW * SH, 4);
    scr_tex = r3_tex_add(BX_S, px, SW, SH);
    for (int i = 0; i < BX_S->nmeshes; i++) if (BX_S->meshes[i].node == scr_node) {
        r3_mat m = BX_S->mats[BX_S->meshes[i].mat]; m.map = scr_tex; m.type = 'B'; m.col[0] = m.col[1] = m.col[2] = 1;
        BX_S->meshes[i].mat_override = r3_mat_add(BX_S, &m);
    }
    mat_fd = own_mat(led_fd); mat_hdd = own_mat(led_hdd);
    ready = 1;
}

/* the box's own nodes are put away while the desk is up */
static signed char was_vis[1024];
static void show_desk(int on)
{
    for (int i = 1; i < BX_S->nnodes && i < 1024; i++) {
        r3_node *n = &BX_S->nodes[i];
        if (n->parent > 0) continue;                        /* the scene root's children only (the lights are not nodes' children) */
        if (i == desk) { n->vis = on; continue; }
        if (on) { was_vis[i] = (signed char)n->vis; n->vis = 0; }
        else if (was_vis[i] >= 0) n->vis = was_vis[i];
    }
}

/* ---- the run ---- */
static struct {
    int up, run, disk, inserted, busy, need, used[5], moving[5];
    int hd, fd;                       /* the tower's lights: 1 on, 2 flickering */
    const char *typing; int tpos, tspeed, tnext;
    char cap[160];
    int file;                         /* the file being copied from this disk */
} I;

int box_install_up(void) { return I.up; }
static void say(const char *s) { snprintf(I.cap, sizeof I.cap, "%s", s); }
static void step(int pc);
static void later(float ms, int pc) { bx_after(ms, step, (I.run << 8) | pc); }
static void type_then(const char *s, int speed, int pc) { I.typing = s; I.tpos = 0; I.tspeed = speed; I.tnext = pc; later((float)speed, 200); }

/* the views */
static void cam_desk(float ms) { bx_cam_to(5, 23, 50, ms); }
static void cam_drive(float ms) { bx_cam_to(9.5f, 14.5f, 25, ms); }
static void cam_screen(float ms) { bx_cam_to(-3, 11.4f, 30, ms); }
static float look[3] = { 5, 5.2f, 2 };
static void look_to(float x, float y, float z, float ms) { bx_tw3(look, x, y, z, ms, 0); }
static void view_desk(float ms) { cam_desk(ms); look_to(5, 5.2f, 2, ms); }
static void view_drive(float ms) { cam_drive(ms); look_to(10, 9.5f, 3, ms); }
static void view_screen(float ms) { cam_screen(ms); look_to(-3, 8.4f, -1, ms); }

/* a disk into the drive: lifted, turned label up with its shutter first, in front of the slot, then pushed in */
static void disk_in(int n)
{
    r3_node *d = bx_n(disk_n[n]), *s = bx_n(slot);
    float sx = s->pos[0], sy = s->pos[1], sz = s->pos[2];
    bx_tw3(d->pos, (d->pos[0] + sx) / 2, sy + 3, sz + 9, 600, 0);
    bx_tw3(d->rot, -PI_F / 2, 0, PI_F, 900, 0);
    bx_tw3(d->pos, sx, sy, sz + 4.5f, 500, 600);
    bx_tw3(d->pos, sx, sy, sz - 1.85f + .12f, 450, 1250);
}
static void disk_out(int n)
{
    r3_node *d = bx_n(disk_n[n]), *s = bx_n(slot);
    float sx = s->pos[0], sy = s->pos[1], sz = s->pos[2];
    bx_tw3(d->pos, sx, sy, sz + .55f, 180, 0);                       /* the eject button pops it out */
    bx_tw3(d->pos, sx, sy, sz + 4.5f, 450, 650);
    float *h = home[n];
    bx_tw3(d->pos, h[0] - .25f, h[1], h[2] + 1.1f, 800, 1150);           /* set aside, a little askew */
    bx_tw3(d->rot, h[3], h[4], h[5] + .22f, 800, 1150);
}

static const char *files_of[5][4] = { { 0 }, { "A:SETUP.EXE", "A:FRAWDER.EXE", "A:HOCKEY.000", NULL }, { "A:HOCKEY.001", NULL }, { "A:HOCKEY.002", NULL }, { "A:HOCKEY.003", NULL } };
static float copy_ms(const char *f) { return strstr(f, "HOCKEY.") ? 3600.0f : 700.0f; }

static void step(int arg)
{
    if ((arg >> 8) != I.run || !I.up) return;
    int pc = arg & 255;
    switch (pc) {
    /* the PC starts */
    case 0: bx_sfx(SFX_BEEP, 0); I.hd = 2; dos_clear(0); dos_line("Starting MS-DOS..."); later(1300, 1); break;
    case 1: I.hd = 0; dos_line(""); dos_line("C:\\>"); say("<b>Put Disk 1 in drive A.</b> Pick the disk."); I.need = 1; I.busy = 0; break;
    /* disk 1 is in: A:, setup */
    case 10: view_screen(900); later(900, 11); break;
    case 11: type_then("a:", 140, 12); break;
    case 12: dos_line(""); dos_line("A:\\>"); I.fd = 1; bx_sfx(SFX_MOTOR, 0); bx_sfx(SFX_SEEK, 3); later(500, 13); break;
    case 13: I.fd = 0; type_then("setup", 120, 14); break;
    case 14: dos_line(""); I.fd = 1; bx_sfx(SFX_MOTOR, 0); bx_sfx(SFX_SEEK, 6); later(1400, 15); break;
    case 15: I.fd = 0; cur_x = -1; s_menu(0); later(1300, 16); break;
    case 16: bx_sfx(SFX_KEY, 0); s_menu(1); later(900, 17); break;
    case 17: bx_sfx(SFX_KEY, 0); s_drive(); later(1500, 18); break;
    case 18: bx_sfx(SFX_KEY, 0); s_dir(); later(1700, 19); break;
    case 19: bx_sfx(SFX_KEY, 0); cur_x = -1; I.file = 0; later(200, 20); break;
    /* copy this disk's files */
    case 20: {
        const char *f = files_of[I.disk][I.file];
        if (!f) { I.fd = 0; I.hd = 0; later(400, 22); break; }
        s_copying(f); I.fd = 1; I.hd = 2;
        bx_sfx(SFX_MOTOR, 0); bx_sfx(SFX_SEEK, 4);
        float ms = copy_ms(f);
        for (float t = 450; t < ms; t += 520) bx_after(t, step, (I.run << 8) | 21);
        I.file++;
        later(ms, 20);
        break;
    }
    case 21: bx_sfx(SFX_STEP, 0); if (((int)(bx_now() * 10)) % 3 == 0) bx_sfx(SFX_HDD, 0); break;
    case 22:
        if (I.disk < 4) {
            s_insert(I.disk + 1);
            later(900, 23);
        } else later(300, 30);
        break;
    case 23: {   /* the disk comes out; the next one is asked for */
        int n = I.disk;
        bx_sfx(SFX_DISK_OUT, 0);
        disk_out(n);
        I.used[n] = 1; I.inserted = 0; I.need = n + 1;
        char b[96]; snprintf(b, sizeof b, "<b>Disk %d is done.</b> Pick Disk %d.", n, n + 1); say(b);
        bx_after(1100, step, (I.run << 8) | 24);
        break;
    }
    case 24: view_desk(1000); I.busy = 0; break;
    /* the last disk: uncompress, back to the menu, Exit, then the game */
    case 30: t_cls(BLK); t_puts(0, 0, "Uncompressing Files", LGR, BLK); t_status("ESC to terminate install"); I.hd = 2; I.fd = 1;
        say("<b>Uncompressing the files...</b>");
        for (float t = 200; t < 4200; t += 380) bx_after(t, step, (I.run << 8) | 21);
        later(4400, 31); break;
    case 31: I.hd = 0; I.fd = 0; s_menu(0); later(1100, 32); break;
    case 32: bx_sfx(SFX_KEY, 0); s_menu(1); later(450, 33); break;
    case 33: bx_sfx(SFX_KEY, 0); s_menu(2); later(800, 34); break;
    case 34: bx_sfx(SFX_KEY, 0); dos_clear(1); dos_line(""); dos_line("C:\\HOCKEY>"); later(900, 35); break;
    case 35: say("<b>Installed.</b> Starting the game..."); type_then("hockey", 130, 36); break;
    case 36: dos_line(""); I.hd = 2; later(1100, 37); break;
    case 37: I.hd = 0; bx_done(); break;
    /* disks 2 to 4: in the drive, Enter at the installer's prompt */
    case 202: view_screen(900); later(900, 203); break;
    case 203: bx_sfx(SFX_KEY, 0); I.file = 0; later(300, 20); break;
    /* typing at the prompt */
    case 200:
        if (!I.typing[I.tpos]) { later(1, I.tnext); break; }
        { char s[2] = { I.typing[I.tpos], 0 }; dos_add(s); }
        I.tpos++;
        bx_sfx(SFX_KEY, 0);
        later((float)I.tspeed, 200);
        break;
    }
}

void box_install_start(void)
{
    init();
    for (int n = 1; n <= 4; n++) { r3_node *d = bx_n(disk_n[n]); memcpy(d->pos, home[n], sizeof d->pos); memcpy(d->rot, home[n] + 3, sizeof d->rot); }
    memset(I.used, 0, sizeof I.used);
    I.disk = 0; I.inserted = 0; I.need = 0; I.run++; I.busy = 1; I.hd = I.fd = 0;
    show_desk(1);
    t_cls(BLK); dirty = 1;
    look[0] = 5; look[1] = 5.2f; look[2] = 2;
    bx_cam(5, 23, 50);
    say("<b>Starting the PC...</b>");
    I.up = 1;
    snprintf(BX.title, sizeof BX.title, "Install NHL Hockey '94");
    later(900, 0);
}
void box_install_skip(int a) { (void)a; I.run++; }

static void insert_disk(int n)
{
    if (I.inserted || I.busy || I.used[n]) return;
    if (n != I.disk + 1) { char b[96]; snprintf(b, sizeof b, "<b>Not that one.</b> The installer wants Disk %d.", I.disk + 1); say(b); return; }
    I.inserted = n; I.busy = 1; I.need = 0; I.disk = n;
    view_drive(900);
    disk_in(n);
    char b[64]; snprintf(b, sizeof b, "<b>Disk %d</b> goes into drive A.", n); say(b);
}
static void back_to_box(int a) { (void)a; I.run++; I.up = 0; show_desk(0); box_pc94_arranged(); }
void box_install_back(void) { bx_fade(back_to_box, 0); }
static void back_btn(int a) { (void)a; box_install_back(); }

void box_install_activate(int node)
{
    for (int n = 1; n <= 4; n++) if (node == disk_n[n]) { insert_disk(n); return; }
}

void box_install_frame(float dt)
{
    (void)dt;
    /* a disk pushed home: the drive takes it, then the installer goes on (Enter at its prompt) */
    if (I.inserted && I.busy) {
        static int last = -1;
        int key = (I.run << 4) | I.inserted;
        r3_node *d = bx_n(disk_n[I.inserted]), *s = bx_n(slot);
        if (last != key && d->pos[2] < s->pos[2] - 1.5f) {
            last = key;
            bx_sfx(SFX_DISK_IN, 0);
            I.fd = 1;
            if (I.inserted == 1) later(700, 10);
            else { bx_after(500, step, (I.run << 8) | 202); }
        }
    }
    /* the lights */
    mat_col(mat_fd, I.fd ? 0x33ff55 : 0x123a12);
    int hd = I.hd == 1 || (I.hd == 2 && (((int)(bx_now() * 13)) % 3 != 0));
    mat_col(mat_hdd, hd ? 0xffaa33 : 0x3a2200);
    scr_render();
    if (!I.busy)
        for (int n = 1; n <= 4; n++)
            if (!I.used[n] && !(I.inserted == n)) {
                static const char *lab[5] = { "", "Insert Disk 1", "Insert Disk 2", "Insert Disk 3", "Insert Disk 4" };
                bx_hot_node(disk_n[n], lab[n]);
            }
    /* the needed disk bobs a little */
    for (int n = 1; n <= 4; n++) {
        r3_node *d = bx_n(disk_n[n]);
        if (I.need == n && !I.busy) d->pos[1] = home[n][1] + .35f * fabsf(sinf((float)bx_now() * 2.85f));
        else if (!I.inserted || I.inserted != n) { if (!I.used[n] && fabsf(d->pos[2] - home[n][2]) < .01f) d->pos[1] = home[n][1]; }
    }
    bx_look[0] = look[0]; bx_look[1] = look[1]; bx_look[2] = look[2];
}

void box_install_draw2d(void)
{
    float u = BX_C.u, sx = BX_C.sx, sy = BX_C.sy, sw = BX_C.sw, sh = BX_C.sh;
    bx_button(sx + 2 * u, sy + 1.4f * u, "< Back to the box", back_btn, 0, -1);
    bx_text(sx + sw - 2 * u, sy + 3.4f * u, 1.5f * u, 0xb5a58f, 255, BX.title, 0, 1);
    if (I.cap[0]) bx_rich(sx + sw / 2, sy + sh - 1.4f * u, 1.6f * u, I.cap, 0xb5a58f, 0xf4ecdf);
}

