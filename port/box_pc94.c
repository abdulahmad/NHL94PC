/* SPDX-License-Identifier: MIT
 * Copyright (c) 2026 abdulahmad and contributors
 *
 * The box (overbar/box.h, docs/BOX.md in Overbar) for NHL 94 PC: the sleeve, the guide and the inner box (the mockup's pc3d.js, in C). States: sleeve -> out -> guide | box -> arranged -> tech. */
#include "box_pc94.h"
#include <math.h>
#include <stdio.h>
#include <string.h>

#define SW 8.44f
#define SH 10.9f
#define GT .54f
#define BT 1.5f
#define DD (GT + BT + .55f)

enum { S_SLEEVE, S_OUT, S_GUIDE, S_BOX, S_ARRANGED, S_TECH };
static int st, busy, focus = -1;
static int rig, pair, sleeve, guide, inbox, lid, tray, trayItems;
static int it_disk[5], it_tech, it_reg, it_line;
typedef struct { int root, g, leaf[64], n, blk, bc, sp; float w, t, flip; } book;
static book gB, tB;
static struct { int root, g, A, B; float flip; } lineF;
static struct { int root, g; float flip; } regF;
static int items[8], nitems;
static float homes[8][3];
static int ready;

static void find_book(book *b, const char *n, float w, float t)
{
    char k[64];
    b->root = bx_node(n);
    snprintf(k, sizeof k, "%s.g", n); b->g = bx_node(k);
    snprintf(k, sizeof k, "%s.blk", n); b->blk = bx_node(k);
    snprintf(k, sizeof k, "%s.bc", n); b->bc = bx_node(k);
    snprintf(k, sizeof k, "%s.sp", n); b->sp = bx_node(k);
    b->n = 0;
    for (int i = 0; i < 64; i++) { snprintf(k, sizeof k, "%s.leaf%d", n, i); int x = r3_find(BX_S, k); if (x < 0) break; b->leaf[b->n++] = x; }
    b->w = w; b->t = t;
}
static float clamp01(float v) { return v < 0 ? 0 : v > 1 ? 1 : v; }
static void book_set(book *b)
{
    float f = b->flip;
    for (int k = 0; k < b->n; k++) {
        float a = bx_ease(clamp01(f - k));
        r3_node *L = bx_n(b->leaf[k]);
        L->rot[1] = -PI_F * a;
        float zc = k == 0 ? b->t / 2 : -k * .002f, zo = k * .002f;
        L->pos[2] = zc + (zo - zc) * a + sinf(a * PI_F) * .12f;
    }
    bx_n(b->g)->pos[0] = f <= 1 ? (-b->w / 2 + (b->w / 2) * f) : (f >= b->n - 1 ? (b->w / 2) * (f - (b->n - 1)) : 0);
    bx_n(b->blk)->vis = f < .001f;
    bx_n(b->bc)->vis = f < b->n - .5f;
    bx_n(b->sp)->vis = f < b->n - .5f;
}
static void fold_set(void)
{
    float f = lineF.flip, w = 5.5f;
    float pa = PI_F * (1 - clamp01(f)), pb = PI_F * clamp01(f - 1);
    bx_n(lineF.A)->rot[1] = pa; bx_n(lineF.B)->rot[1] = -pb;
    bx_n(lineF.A)->pos[2] = .012f * (pa / PI_F); bx_n(lineF.B)->pos[2] = .012f * (pb / PI_F);
    bx_n(lineF.g)->pos[0] = f <= 1 ? (-w / 2) * (1 - f) : (w / 2) * (f - 1);
}
static void flip_set(void) { bx_n(regF.g)->rot[1] = -PI_F * clamp01(regF.flip); }

static void init(void)
{
    if (ready) return;
    rig = bx_node("rig"); pair = bx_node("pair"); sleeve = bx_node("sleeve"); guide = bx_node("guide"); inbox = bx_node("inbox");
    lid = bx_node("lid"); tray = bx_node("tray"); trayItems = bx_node("trayItems");
    find_book(&gB, "gBook", 8.37f, GT); find_book(&tB, "techBook", 5.54f, .12f);
    lineF.root = bx_node("lineBook"); lineF.g = bx_node("lineBook.g"); lineF.A = bx_node("lineBook.A"); lineF.B = bx_node("lineBook.B");
    regF.root = bx_node("regFlip"); regF.g = bx_node("regFlip.g");
    nitems = 0;
    for (int i = 1; i <= 4; i++) { char k[32]; snprintf(k, sizeof k, "item.disk%d", i); it_disk[i] = bx_node(k); items[nitems++] = it_disk[i]; }
    it_tech = bx_node("item.tech"); it_reg = bx_node("item.reg"); it_line = bx_node("item.line");
    items[nitems++] = it_tech; items[nitems++] = it_reg; items[nitems++] = it_line;
    ready = 1;
}
static int item_index(int node) { for (int i = 0; i < nitems; i++) if (items[i] == node) return i; return -1; }
static const char *item_id(int node) { return bx_n(node)->id; }
static void grid(int node, float *x, float *y)
{
    const float y1 = 4.8f, y2 = -4.2f;
    *x = 0; *y = 0;
    if (node == it_disk[1]) { *x = -10.5f; *y = y1; } else if (node == it_disk[2]) { *x = -3.5f; *y = y1; }
    else if (node == it_disk[3]) { *x = 3.5f; *y = y1; } else if (node == it_disk[4]) { *x = 10.5f; *y = y1; }
    else if (node == it_tech) { *x = -9; *y = y2 + .2f; } else if (node == it_reg) { *x = -1.5f; *y = y2; } else if (node == it_line) { *x = 7; *y = y2 + .2f; }
}

static void caption(void)
{
    static const char *t[] = { "Outer sleeve", "Guide and inner box", "Manual", "Inner box", "Everything in the box", "Look closer" };
    snprintf(BX.title, sizeof BX.title, "%s", t[st]);
    switch (st) {
    case S_SLEEVE: bx_say("<b>The outer sleeve.</b> Drag to spin it, pick it to slide the contents out."); break;
    case S_OUT: bx_say("<b>Manual on the left, inner box on the right.</b> Pick either one. Pick the sleeve to put them back."); break;
    case S_GUIDE: bx_say("<b>Manual.</b> Pick the right or left page, or use the buttons, to turn pages."); break;
    case S_BOX: bx_say(""); break;
    case S_ARRANGED: bx_say(BX.first ? "<b>Everything that came in the box.</b> To install, pick Disk 1." : "<b>Everything that came in the box.</b> Pick an item to look at it."); break;
    case S_TECH:
        bx_say(focus == it_line ? "<b>Pick the card to unfold it, again to fold it closed toward the back.</b>" : focus == it_reg ? "<b>Pick the card to flip it over.</b>" : "<b>Pick the card to turn pages.</b>");
        break;
    }
}

/* ---- poses ---- */
static void reset_pose(void)
{
    bx_time_clear();
    r3_node *r = bx_n(rig);
    bx_set3(r->pos, 0, 0, 0); bx_set3(r->rot, .12f, -.5f, 0); bx_set3(r->scale, 1, 1, 1); r->vis = 1;
    bx_parent(guide, rig); bx_parent(inbox, rig);
    bx_set3(bx_n(guide)->pos, 0, 0, -DD / 2 + GT / 2 + .14f); bx_set3(bx_n(guide)->rot, 0, PI_F, 0); bx_set3(bx_n(guide)->scale, 1, 1, 1);
    bx_set3(bx_n(inbox)->pos, 0, 0, DD / 2 - BT / 2 - .14f); bx_set3(bx_n(inbox)->rot, 0, PI_F, 0); bx_set3(bx_n(inbox)->scale, 1, 1, 1);
    bx_parent(lid, inbox); bx_set3(bx_n(lid)->pos, 0, 0, 0); bx_set3(bx_n(lid)->rot, 0, 0, 0); bx_set3(bx_n(lid)->scale, 1, 1, 1); bx_n(lid)->vis = 1;
    bx_n(tray)->vis = 1;
    for (int i = 0; i < nitems; i++) {
        r3_node *m = bx_n(items[i]);
        bx_parent(items[i], trayItems); m->vis = 0; bx_set3(m->scale, .01f, .01f, .01f); bx_set3(m->pos, 0, 0, -.2f); bx_set3(m->rot, 0, 0, 0);
    }
    gB.flip = tB.flip = lineF.flip = regF.flip = 0;
    bx_set3(bx_n(pair)->pos, 0, 0, 0); bx_set3(bx_n(pair)->rot, 0, 0, 0);
    bx_n(sleeve)->vis = 1;
    bx_cam(0, 0, 30);
    busy = 0; focus = -1;
}
static void arranged_now(void)
{
    /* the pose after sleeve -> out -> box, without the moves (coming back from the install) */
    reset_pose();
    bx_attach(guide, -1); bx_attach(inbox, -1);
    r3_node *r = bx_n(rig);
    bx_set3(r->pos, -40, 0, -9); bx_set3(r->rot, .1f, .45f, 0); bx_set3(r->scale, .62f, .62f, .62f);
    bx_set3(bx_n(guide)->pos, -30, 0, 0); bx_set3(bx_n(guide)->rot, 0, 0, 0);
    bx_set3(bx_n(inbox)->pos, 16.5f, -1, -2); bx_set3(bx_n(inbox)->rot, .1f, -.55f, 0); bx_set3(bx_n(inbox)->scale, .55f, .55f, .55f);
    bx_parent(lid, -1); bx_set3(bx_n(lid)->pos, -16.5f, -1, -2); bx_set3(bx_n(lid)->rot, .1f, .55f, 0); bx_set3(bx_n(lid)->scale, .55f, .55f, .55f);
    for (int i = 0; i < nitems; i++) {
        float x, y; grid(items[i], &x, &y);
        r3_node *m = bx_n(items[i]);
        bx_parent(items[i], -1); m->vis = 1; bx_set3(m->pos, x, y, .4f); bx_set3(m->scale, 1, 1, 1); bx_set3(m->rot, 0, 0, 0);
    }
    bx_cam(0, 0, 40);
    st = S_ARRANGED;
}

static void unbusy(int a) { (void)a; busy = 0; }
static void out_step2(int a)
{
    (void)a;
    bx_attach(guide, -1); bx_attach(inbox, -1);
    bx_set3(bx_n(pair)->pos, 0, 0, 0); bx_set3(bx_n(pair)->rot, 0, 0, 0);
    float ms = 1100;
    bx_tw3(bx_n(rig)->pos, -14.5f, 0, -9, ms, 0); bx_tw3(bx_n(rig)->rot, .1f, .45f, 0, ms, 0); bx_tw3(bx_n(rig)->scale, .62f, .62f, .62f, ms, 0);
    bx_tw3(bx_n(guide)->pos, -5.2f, 0, 0, ms, 0); bx_tw3(bx_n(guide)->rot, 0, 0, 0, ms, 0);
    bx_tw3(bx_n(inbox)->pos, 5.2f, 0, 0, ms, 150); bx_tw3(bx_n(inbox)->rot, 0, 0, 0, ms, 150);
    bx_cam_to(0, 0, 32, ms);
    bx_after(ms + 200, unbusy, 0);
}
static void to_out(void)
{
    busy = 1; st = S_OUT; caption();
    bx_set3(bx_n(pair)->pos, 0, 0, 0); bx_set3(bx_n(pair)->rot, 0, 0, 0);
    bx_parent(guide, pair); bx_parent(inbox, pair);
    bx_sfx(SFX_SLIDE, 0);
    bx_tw1(&bx_n(pair)->pos[0], 10.5f, 750, 0);
    bx_tw1(&bx_n(pair)->rot[1], PI_F, 850, 850);
    bx_after(750 + 850 + 300, out_step2, 0);
}
static void sleeve_step3(int a)
{
    (void)a;
    bx_attach(guide, rig); bx_attach(inbox, rig);
    bx_set3(bx_n(pair)->pos, 0, 0, 0); bx_set3(bx_n(pair)->rot, 0, 0, 0);
    bx_set3(bx_n(guide)->rot, 0, PI_F, 0); bx_set3(bx_n(inbox)->rot, 0, PI_F, 0);
    busy = 0;
}
static void sleeve_slide(int a) { (void)a; bx_tw1(&bx_n(pair)->pos[0], 0, 750, 0); bx_sfx(SFX_SLIDE, 0); }
static void sleeve_step2(int a)
{
    (void)a;
    bx_set3(bx_n(pair)->pos, 10.5f, 0, 0); bx_set3(bx_n(pair)->rot, 0, PI_F, 0);
    bx_attach(guide, pair); bx_attach(inbox, pair);
    bx_sfx(SFX_SLIDE, 0);
    bx_tw1(&bx_n(pair)->rot[1], 0, 850, 0);
    bx_after(950, sleeve_slide, 0);
    bx_after(1800, sleeve_step3, 0);
}
static void to_sleeve(void)
{
    busy = 1; st = S_SLEEVE; caption();
    bx_attach(guide, rig); bx_attach(inbox, rig);
    bx_tw3(bx_n(rig)->pos, 0, 0, 0, 1000, 0); bx_tw3(bx_n(rig)->rot, .12f, -.5f, 0, 1000, 0); bx_tw3(bx_n(rig)->scale, 1, 1, 1, 1000, 0);
    float pz[2] = { -DD / 2 + GT / 2 + .14f, DD / 2 - BT / 2 - .14f };
    int o[2] = { guide, inbox };
    for (int i = 0; i < 2; i++) {
        r3_node *n = bx_n(o[i]);
        bx_tw3(n->rot, 0, 0, 0, 500, 0); bx_tw3(n->scale, 1, 1, 1, 500, 0);
        float yz[2] = { 0, -pz[i] };
        bx_tw(&n->pos[1], 2, yz, 500, 0);
        bx_tw1(&n->pos[0], 10.5f, 650, 450);
    }
    bx_cam_to(0, 0, 30, 1000);
    bx_after(1150, sleeve_step2, 0);
}
static void to_guide(void)
{
    st = S_GUIDE; gB.flip = 0;
    bx_tw3(bx_n(guide)->pos, 0, 0, 0, 900, 0); bx_tw3(bx_n(guide)->rot, 0, 0, 0, 900, 0);
    bx_tw3(bx_n(inbox)->pos, 16, 0, -6, 900, 0); bx_cam_to(0, 0, 25, 900);
    bx_tw3(bx_n(rig)->pos, -30, 0, -9, 900, 0);
    caption();
}
static void back_from_guide(void)
{
    st = S_OUT;
    bx_tw3(bx_n(guide)->pos, -5.2f, 0, 0, 900, 0); bx_tw3(bx_n(inbox)->pos, 5.2f, 0, 0, 900, 0);
    bx_tw3(bx_n(rig)->pos, -14.5f, 0, -9, 900, 0); bx_tw1(&gB.flip, 0, 700, 0); bx_cam_to(0, 0, 32, 900);
    caption();
}
static void set_flip(float *f, float to) { bx_sfx(SFX_PAGE, 0); bx_tw1(f, to, 800, 0); }

static void box_step3(int a) { (void)a; st = S_ARRANGED; caption(); busy = 0; }
static void box_step2(int a)
{
    (void)a;
    for (int i = 0; i < nitems; i++) bx_attach(items[i], -1);
    for (int i = 0; i < nitems; i++) {
        float x, y; grid(items[i], &x, &y);
        bx_tw3(bx_n(items[i])->pos, x, y, .4f, 1000, i * 90.0f); bx_tw3(bx_n(items[i])->scale, 1, 1, 1, 1000, i * 90.0f);
    }
    bx_tw3(bx_n(inbox)->pos, 16.5f, -1, -2, 900, 300); bx_tw3(bx_n(inbox)->rot, .1f, -.55f, 0, 900, 300); bx_tw3(bx_n(inbox)->scale, .55f, .55f, .55f, 900, 300);
    bx_after(1300, box_step3, 0);
}
static void box_step1(int a)
{
    (void)a;
    bx_attach(lid, -1);
    bx_tw3(bx_n(lid)->pos, 0, 2.5f, 14, 700, 0);
    bx_tw3(bx_n(lid)->pos, -16.5f, -1, 14, 800, 700);
    bx_tw3(bx_n(lid)->pos, -16.5f, -1, -2, 500, 1500);
    bx_tw3(bx_n(lid)->rot, .1f, .55f, 0, 900, 900); bx_tw3(bx_n(lid)->scale, .55f, .55f, .55f, 900, 900);
    for (int i = 0; i < nitems; i++) {
        r3_node *m = bx_n(items[i]);
        m->vis = 1; bx_set3(m->scale, .01f, .01f, .01f); bx_set3(m->pos, 0, 0, .2f + i * .03f);
        bx_tw3(m->scale, .6f, .6f, .6f, 500, 700 + i * 30.0f);
    }
    bx_after(2300, box_step2, 0);
}
static void to_box(void)
{
    busy = 1; st = S_BOX; caption();
    bx_tw3(bx_n(inbox)->pos, 0, 0, 0, 1000, 0); bx_tw3(bx_n(inbox)->rot, 0, 0, 0, 1000, 0); bx_tw3(bx_n(guide)->pos, -30, 0, 0, 1000, 0);
    bx_cam_to(0, 0, 40, 1000);
    bx_tw3(bx_n(rig)->pos, -40, 0, -9, 1000, 0);
    bx_sfx(SFX_CLICK, 0);
    bx_after(1050, box_step1, 0);
}
static void back_box2(int a)
{
    (void)a;
    for (int i = 0; i < nitems; i++) { r3_node *m = bx_n(items[i]); bx_parent(items[i], trayItems); m->vis = 0; bx_set3(m->pos, 0, 0, -.2f); bx_set3(m->scale, .01f, .01f, .01f); }
    bx_attach(lid, inbox);
    bx_tw3(bx_n(lid)->pos, 0, 0, 0, 500, 0); bx_tw3(bx_n(lid)->rot, 0, 0, 0, 500, 0); bx_tw3(bx_n(lid)->scale, 1, 1, 1, 500, 0);
    bx_tw3(bx_n(inbox)->pos, 5.2f, 0, 0, 900, 0); bx_tw3(bx_n(inbox)->rot, 0, 0, 0, 900, 0); bx_tw3(bx_n(inbox)->scale, 1, 1, 1, 900, 0);
    bx_tw3(bx_n(guide)->pos, -5.2f, 0, 0, 900, 0); bx_tw3(bx_n(rig)->pos, -14.5f, 0, -9, 900, 0); bx_cam_to(0, 0, 32, 900);
    bx_after(950, unbusy, 0);
}
static void back_from_box(void)
{
    busy = 1; st = S_OUT; caption();
    float *ip = bx_n(inbox)->pos;
    for (int i = 0; i < nitems; i++) { bx_tw3(bx_n(items[i])->pos, ip[0], ip[1], 0, 700, i * 40.0f); bx_tw3(bx_n(items[i])->scale, .01f, .01f, .01f, 700, i * 40.0f); }
    bx_tw3(bx_n(lid)->pos, ip[0], ip[1], 0, 800, 300); bx_tw3(bx_n(lid)->scale, .55f, .55f, .55f, 800, 300); bx_tw3(bx_n(lid)->rot, .1f, -.55f, 0, 800, 300);
    bx_after(1150, back_box2, 0);
}
static void to_tech(int m)
{
    st = S_TECH; focus = m; caption();
    for (int i = 0; i < nitems; i++) if (items[i] != m) bx_n(items[i])->vis = 0;
    int k = item_index(m);
    if (k >= 0) memcpy(homes[k], bx_n(m)->pos, sizeof homes[k]);
    bx_tw3(bx_n(m)->pos, 0, 0, 0, 900, 0); bx_tw3(bx_n(m)->scale, 1.4f, 1.4f, 1.4f, 900, 0); bx_tw3(bx_n(m)->rot, 0, 0, 0, 900, 0);
    bx_tw3(bx_n(lid)->pos, -40, -1, -2, 700, 0); bx_cam_to(0, 0, m == it_line ? 26 : 24, 900);
}
static float *focus_flip(void) { return focus == it_tech ? &tB.flip : focus == it_line ? &lineF.flip : focus == it_reg ? &regF.flip : NULL; }
static int focus_n(void) { return focus == it_tech ? tB.n : focus == it_line ? 2 : 1; }
static void back_from_tech(void)
{
    float *f = focus_flip();
    if (f) bx_tw1(f, 0, 600, 0);
    int k = item_index(focus);
    if (k >= 0) { bx_tw3(bx_n(focus)->pos, homes[k][0], homes[k][1], homes[k][2], 900, 0); }
    bx_tw3(bx_n(focus)->scale, 1, 1, 1, 900, 0);
    for (int i = 0; i < nitems; i++) bx_n(items[i])->vis = 1;
    bx_tw3(bx_n(lid)->pos, -16.5f, -1, -2, 900, 0); bx_cam_to(0, 0, 40, 900);
    st = S_ARRANGED; caption();
}
static void next_page(int a) { (void)a; if (st == S_TECH) { float *f = focus_flip(); int c = (int)lroundf(*f); if (c < focus_n()) set_flip(f, (float)c + 1); } else { int c = (int)lroundf(gB.flip); if (c < gB.n) set_flip(&gB.flip, (float)c + 1); } }
static void prev_page(int a) { (void)a; if (st == S_TECH) { float *f = focus_flip(); int c = (int)lroundf(*f); if (c > 0) set_flip(f, (float)c - 1); } else { int c = (int)lroundf(gB.flip); if (c > 0) set_flip(&gB.flip, (float)c - 1); } }

/* ---- pages for the reader ---- */
static int manual_pages(r3_tex **out)
{
    int n = 0; char k[16];
    out[n++] = bx_art("man0"); out[n++] = bx_art("blank");
    for (int i = 1; i <= 31; i++) { snprintf(k, sizeof k, "man%d", i); out[n++] = bx_art(k); }
    out[n++] = bx_art("blank"); out[n++] = bx_art("man32");
    return n;
}
/* the guide as a book: [man0, -, man1..man30, -, man31, -, man32] (the 3D book's own order) */
static r3_tex *guide_page(int i)
{
    char k[16];
    if (i == 0) return bx_art("man0");
    if (i == 1 || i == 32 || i == 34) return bx_art("blank");
    if (i >= 2 && i <= 31) { snprintf(k, sizeof k, "man%d", i - 1); return bx_art(k); }
    if (i == 33) return bx_art("man31");
    if (i == 35) return bx_art("man32");
    return NULL;
}
static void read_full(int a)
{
    (void)a;
    r3_tex *p[4]; int n = 0;
    if (st == S_TECH && focus == it_reg) { p[n++] = bx_art(regF.flip > .5f ? "regback" : "regfront"); bx_view_open("Registration card", p, n, 0, NULL); return; }
    if (st == S_TECH && focus == it_line) {
        if (lroundf(lineF.flip)) { p[n++] = bx_art("lineInLeft"); p[n++] = bx_art("lineInRight"); } else p[n++] = bx_art("lineOutFront");
        bx_view_open("EA lineup", p, n, 0, NULL); return;
    }
    int f = (int)lroundf(st == S_TECH ? tB.flip : gB.flip);
    char k[16];
    if (st == S_TECH) {
        if (f > 0) { snprintf(k, sizeof k, "tech%d", 2 * f - 1); p[n++] = bx_art(k); }
        if (2 * f < 12) { snprintf(k, sizeof k, "tech%d", 2 * f); p[n++] = bx_art(k); }
        bx_view_open("Technical reference card", p, n, 0, NULL);
    } else {
        if (f > 0) p[n++] = guide_page(2 * f - 1);
        if (2 * f < 36) p[n++] = guide_page(2 * f);
        bx_view_open("NHL Hockey '94 manual", p, n, 0, NULL);
    }
}
static void open_manual(void)
{
    r3_tex *p[40];
    int n = manual_pages(p);
    bx_view_open("NHL Hockey '94 manual", p, n, 1, BX.manual_only ? bx_manual_only_closed : NULL);
}

/* ---- the scene interface ---- */
static void enter(int mode)
{
    init();
    if (mode == 99) { reset_pose(); arranged_now(); caption(); return; }
    reset_pose();
    st = S_SLEEVE;
    caption();
}
void box_pc94_arranged(void) { enter(99); }

static void frame(float dt)
{
    book_set(&gB); book_set(&tB); fold_set(); flip_set();
    float k = powf(.9f, dt / 16.7f);
    int hv = bx_hovered_node();
    if (st == S_ARRANGED || st == S_TECH)
        for (int i = 0; i < nitems; i++) { r3_node *m = bx_n(items[i]); m->rot[0] *= k; m->rot[1] *= k; }
    if (st == S_ARRANGED) {
        for (int i = 0; i < nitems; i++) {
            r3_node *m = bx_n(items[i]);
            if (items[i] == hv) m->pos[2] = .9f;
            else if (m->pos[2] > .4f) m->pos[2] = fmaxf(.4f, m->pos[2] - .05f * dt / 16.7f);
        }
    }
    /* hot spots, left to right as they sit */
    if (!busy) {
        if (st == S_SLEEVE) { bx_hot_node(sleeve, "Outer sleeve: pick to slide the contents out"); }
        if (st == S_OUT) { bx_hot_node(guide, "Manual: pick to open"); bx_hot_node(sleeve, "Put them back in the sleeve"); bx_hot_node(inbox, "Inner box: pick to open"); }
        if (st == S_GUIDE) bx_hot_node(guide, "Manual: pick a page to turn it");
        if (st == S_ARRANGED) {
            static const char *lab[] = { "", "Insert Disk 1", "Insert Disk 2", "Insert Disk 3", "Insert Disk 4" };
            for (int i = 1; i <= 4; i++) bx_hot_node(it_disk[i], BX.first ? lab[i] : (i == 1 ? "Disk 1" : i == 2 ? "Disk 2" : i == 3 ? "Disk 3" : "Disk 4"));
            bx_hot_node(it_tech, "Technical reference card"); bx_hot_node(it_reg, "Registration card"); bx_hot_node(it_line, "EA lineup (folded card)");
        }
        if (st == S_TECH) bx_hot_node(focus, bx_n(focus)->label);
    }
    bx_look[0] = BX_S->cam[0]; bx_look[1] = BX_S->cam[1]; bx_look[2] = 0;
}
static void back(void)
{
    if (box_install_up()) { box_install_back(); return; }
    if (busy) return;
    if (st == S_GUIDE) back_from_guide();
    else if (st == S_TECH) back_from_tech();
    else if (st == S_ARRANGED || st == S_BOX) back_from_box();
    else if (st == S_OUT) to_sleeve();
    else if (st == S_SLEEVE && !BX.first) bx_done();
}
static void back_btn(int a) { (void)a; back(); }
static void draw2d(void)
{
    float u = BX_C.u, top = BX_C.sy + 1.4f * u;
    if (!(st == S_SLEEVE && BX.first)) bx_button(BX_C.sx + 2 * u, top, st == S_SLEEVE ? "< Back to the game" : "< Back", back_btn, 0, -1);
    bx_text(BX_C.sx + BX_C.sw - 2 * u, top + 2.0f * u, 1.5f * u, 0xb5a58f, 255, BX.title, 0, 1);
    if (st == S_GUIDE || st == S_TECH) {
        float y = BX_C.sy + BX_C.sh - 4.6f * u - 3 * u, cx = BX_C.sx + BX_C.sw / 2;
        bx_button(cx - 1.2f * u - 7 * u, y, "< Turn back", prev_page, 0, 1);
        bx_button(cx - 7 * u, y, "Turn page >", next_page, 0, -1);
        bx_button(cx + 7.5f * u, y, "Read full size", read_full, 0, -1);
    }
    if (BX.cap[0]) bx_rich(BX_C.sx + BX_C.sw / 2, BX_C.sy + BX_C.sh - 1.6f * u, 1.6f * u, BX.cap, 0xb5a58f, 0xf4ecdf);
}
static void install_cb(int a) { (void)a; box_install_start(); }
static void disk_pick(int n)
{
    int need = BX.first && !BX.from_menu;
    if (!need) {
        char k[8]; snprintf(k, sizeof k, "disk%d", n);
        r3_tex *p = bx_art(k); char t[16]; snprintf(t, sizeof t, "Disk %d", n);
        bx_view_open(t, &p, 1, 0, NULL);
        return;
    }
    if (n != 1) { bx_say("<b>Start with Disk 1.</b>"); return; }
    bx_fade(install_cb, 0);
}
static void activate(int node, float sx, float sy)
{
    (void)sy;
    if (busy || node < 0) return;
    if (node == sleeve) { if (st == S_SLEEVE) to_out(); else if (st == S_OUT) to_sleeve(); return; }
    if ((node == guide || node == inbox) && st == S_SLEEVE) { to_out(); return; }
    if (node == guide) {
        if (st == S_OUT) to_guide();
        else if (st == S_GUIDE) {
            float x, y, p[3]; r3_world_pos(BX_S, gB.root, p);
            if (r3_project(BX_S, &(r3_target){ .w = BX_C.w, .h = BX_C.h }, p, &x, &y) && sx < x) prev_page(0); else next_page(0);
        }
        return;
    }
    if (node == inbox) { if (st == S_OUT) to_box(); return; }
    if (st == S_ARRANGED) {
        if (node == it_tech || node == it_reg || node == it_line) { to_tech(node); return; }
        for (int i = 1; i <= 4; i++) if (node == it_disk[i]) { disk_pick(i); return; }
        return;
    }
    if (st == S_TECH && node == focus) {
        int root = focus == it_tech ? tB.root : focus == it_line ? lineF.root : regF.root;
        float x, y, p[3]; r3_world_pos(BX_S, root, p);
        if (focus == it_reg) { set_flip(&regF.flip, regF.flip > .5f ? 0 : 1); return; }
        if (r3_project(BX_S, &(r3_target){ .w = BX_C.w, .h = BX_C.h }, p, &x, &y) && sx < x) prev_page(0); else next_page(0);
    }
    (void)item_id;
}
static void drag(int node, float dx, float dy)
{
    int t = -1;
    if (st == S_SLEEVE || node == sleeve) t = rig;
    else if (node >= 0 && !(st == S_TECH && node == focus)) t = node;
    if (t < 0 || busy) return;
    r3_node *n = bx_n(t);
    n->rot[1] += dx * .012f;
    n->rot[0] += dy * .012f;
    if (n->rot[0] > 1.3f) n->rot[0] = 1.3f;
    if (n->rot[0] < -1.3f) n->rot[0] = -1.3f;
}
static int draws_3d(void) { return !box_install_up(); }
static void key(int k) { (void)k; }

static void skip(void) { box_install_skip(0); }
const bx_scene BOX_PC94 = { "pc94", enter, frame, draw2d, activate, back, drag, open_manual, draws_3d, box_install_draw, key, skip };
