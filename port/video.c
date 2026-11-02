/* video.c: the window and the picture. The VGA (vga.c) gives the game's screen as 8-bit pixels and a palette; this file turns it
 * into ARGB and draws it with OpenGL (video_gl.c: sharp scaling, CRT scanlines, soft CRT, MiSTer and custom looks) or with SDL's
 * renderer, keeps the settings in hockey94.ini next to the program, and answers the menu commands. Taken from the NHL 95 PC port
 * (port/video.c of its sdl2-port branch) without its VESA emulation: here the screens are 320x200 (class 1, "lo-res") and, rarely,
 * 640x480 (class 0, "hi-res"). */
#include "machine.h"
#include "host.h"
#include "bindings.h"
#include <ctype.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <SDL.h>

static SDL_Window *win;
static SDL_Renderer *ren;
static SDL_Texture *tex;
static int tex_w, tex_h;
static int use_gl;
int vgl_init(SDL_Window *win);
void vgl_draw(SDL_Window *win, const uint32_t *argb, int w, int h, int vx, int vy, int vw, int vh);
void vgl_quit(void);
void vgl_set_vsync(int on);
void vgl_set_look(int pre, float sigma, float gain, float center, int period, int style);
void vgl_set_target(int w, int h);
void vgl_mister_tables(const float horiz[64][4], const float vert[2][256][4], const float gamma[256]);
void vgl_mister_mask(const float *rgb, int w, int h);
void vgl_set_custom(float dark, float gamma, float mask, float sharp);
void vgl_set_bright(float b, float maskscale);
void vgl_osd_set(const char *l1, const char *l2, const char *l3);
extern const char *vgl_filter;

static uint8_t pix[800 * 600];
static uint32_t argb[800 * 600];
static int mode_w = 320, mode_h = 200;

/* ---- the settings ---- */
static int present_hz = 70, vsync_on = 0, osd_on, vrr_on = 1;      /* by default: draw each new image, vsync off */
static void title_refresh(void);
static int hires_mode, lores_mode, vscale_hi, vscale_lo;
#define NHIRES NHIRES_ITEMS
#define NLORES NLORES_ITEMS
static const char *hires_names[NHIRES] = { "1x", "2x", "3x", "4x", "crt-light", "crt-medium", "crt-strong", "crt-soft", "crt-soft-grille", "mister", "custom" };
static const char *lores_names[NLORES] = { "3x", "5x", "7x", "11x", "crt-light", "crt-medium", "crt-strong", "crt-soft", "crt-soft-grille", "mister", "custom" };
static const float scan_strength[3] = { 0.80f, 0.60f, 0.45f };   /* the sigma of the scanline profile: the smaller, the darker the gaps */
static const char *ptr_names[3] = { "auto", "show", "hide" };
static int ptr_mode;
static const char *vscale_names[4] = { "fit", "integer", "overscan", "auto-crop" };

/* ---- the MiSTer look ----
 * It uses the scaler's own files, as on the MiSTer: a horizontal filter (64 phases of 4 taps), an adaptive vertical (scanline) filter (256 phases of
 * 4 taps, for dark and for bright pixels), a gamma curve (256 values) and a shadow mask (cells of 3 hex digits: colour, intensity on, intensity off,
 * with a pattern for each output resolution). The paths are in the ini, relative to the program's folder (the files come from the MiSTer's
 * filters, gamma and Shadow_Masks folders). A file that is missing is replaced by a plain stand-in. */
#define DEF_HORIZ "mister/Filters/Upscaling - Recommended/GS_Sharpness_060.txt"
#define DEF_VERT "mister/Filters/Scanlines - Adaptive/SLA_Dk_030_Br_070.txt"
#define DEF_GAMMA "mister/Gamma/Pure_Gamma/gamma_113.txt"
#define DEF_MASK "mister/Shadow_Masks/Simple (Monochrome)/JVC 001 (Generic).txt"
static struct { char horiz[260], vert[260], gamma[260], mask[260]; int mask_scale; float bright; } mcfg[2];
static int lores_khz31;                          /* the 320x200 screens: 0 single scan (15 kHz, TV), 1 double scan (31 kHz, VGA) for every CRT look */
static float c_dark = 0.30f, c_gamma = 1.13f, c_mask = 0.12f, c_sharp = 0.60f;   /* the custom look: in the ini */
static float m_horiz[2][64][4], m_vert[2][2][256][4], m_gamma[2][256];
static struct { int res, w, h; float rgb[16 * 16 * 3]; } m_masks[2][8];
static int m_nmasks[2], m_dirty[2] = { 1, 1 }, m_mask_for = -1, m_class_up = -1;

static void mister_defaults(int c)
{
  snprintf(mcfg[c].horiz, sizeof mcfg[c].horiz, "%s", DEF_HORIZ); snprintf(mcfg[c].vert, sizeof mcfg[c].vert, "%s", DEF_VERT);
  snprintf(mcfg[c].gamma, sizeof mcfg[c].gamma, "%s", DEF_GAMMA); snprintf(mcfg[c].mask, sizeof mcfg[c].mask, "%s", DEF_MASK);
  mcfg[c].mask_scale = 1; mcfg[c].bright = 1.0f;
  m_dirty[c] = 1;
}

static FILE *open_rel(const char *path)
{
  char full[1100];
  FILE *f;
  char *base = SDL_GetBasePath();
  if (path[0] == '/' || (path[0] && path[1] == ':')) snprintf(full, sizeof full, "%s", path);
  else snprintf(full, sizeof full, "%s%s", base ? base : "", path);
  SDL_free(base);
  f = fopen(full, "r");
  if (!f) f = fopen(path, "r");
  return f;
}

/* the numbers of a coefficient file (lines starting with # are comments; the words 10bit and adaptive set flags) */
static int read_numbers(const char *path, float *vals, int max, int *adaptive, int *tenbit)
{
  char line[512];
  int n = 0;
  FILE *f = open_rel(path);
  if (!f) return 0;
  *adaptive = *tenbit = 0;
  while (fgets(line, sizeof line, f)) {
    char *q = line;
    while (*q == ' ' || *q == '\t') q++;
    if (*q == '#' || *q == '\n' || *q == '\r' || !*q) continue;
    if (!strncmp(q, "10bit", 5)) { *tenbit = 1; continue; }
    if (isalpha((unsigned char)*q)) { if (!strncmp(q, "adaptive", 8)) *adaptive = 1; if (!strncmp(q, "10bit", 5)) *tenbit = 1; continue; }
    while (*q) {
      char *e;
      long v;
      while (*q && *q != '-' && !isdigit((unsigned char)*q)) q++;
      if (!*q) break;
      v = strtol(q, &e, 10);
      if (e == q) break;
      if (n < max) vals[n++] = (float)v;
      q = e;
    }
  }
  fclose(f);
  return n;
}

static void load_mask(const char *path, int cls)
{
  char line[512];
  int res = 0, w = 0, h = 0, y = 0, want = 0;
  FILE *f = open_rel(path);
  m_nmasks[cls] = 0;
  if (f) {
    while (fgets(line, sizeof line, f) && m_nmasks[cls] < 8) {
      char *q = line;
      while (*q == ' ' || *q == '\t') q++;
      if (*q == '#' || *q == '\n' || *q == '\r' || !*q) continue;
      if (!strncmp(q, "Resolution=", 11)) { res = atoi(q + 11); want = 0; continue; }
      if (!strncmp(q, "v2", 2)) { want = 1; continue; }
      if (want == 1) {
        if (sscanf(q, "%d,%d", &w, &h) != 2 || w < 1 || h < 1 || w > 16 || h > 16) { want = 0; continue; }
        m_masks[cls][m_nmasks[cls]].res = res; m_masks[cls][m_nmasks[cls]].w = w; m_masks[cls][m_nmasks[cls]].h = h;
        y = 0; want = 2;
        continue;
      }
      if (want == 2) {                         /* a row of cells: colour (0-7: bit 1 blue, 2 green, 4 red), intensity on, intensity off */
        for (int x = 0; x < w; x++) {
          unsigned c = 0, on = 0, off = 0;
          if (sscanf(q, "%1x%1x%1x", &c, &on, &off) != 3) break;
          for (int ch = 0; ch < 3; ch++) {
            int bit = ch == 0 ? 4 : ch == 1 ? 2 : 1;
            m_masks[cls][m_nmasks[cls]].rgb[(y * w + x) * 3 + ch] = (c & bit) ? 1.0f + on / 16.0f : off / 16.0f;
          }
          q = strchr(q, ',');
          if (!q) break;
          q++;
        }
        if (++y == h) { m_nmasks[cls]++; want = 0; }
      }
    }
    fclose(f);
  }
  if (!m_nmasks[cls]) {
    m_masks[cls][0].res = 0; m_masks[cls][0].w = m_masks[cls][0].h = 1;
    m_masks[cls][0].rgb[0] = m_masks[cls][0].rgb[1] = m_masks[cls][0].rgb[2] = 1.0f;
    m_nmasks[cls] = 1;
  }
}

static void mister_load(int cls)
{
  static float v[2 * 256 * 4 + 16];
  int n, ad, tb, i, p, k;
  m_dirty[cls] = 0; m_class_up = -1;
  n = read_numbers(mcfg[cls].horiz, v, 2 * 256 * 4, &ad, &tb);
  if (n == 64 * 4 || n == 256 * 4 || n == 2 * 256 * 4) {
    int phases = n == 64 * 4 ? 64 : 256;
    for (p = 0; p < 64; p++) {
      const float *r = v + (size_t)(p * phases / 64) * 4;
      float sum = r[0] + r[1] + r[2] + r[3];
      for (k = 0; k < 4; k++) m_horiz[cls][p][k] = sum > 0 ? r[k] / sum : 0;
    }
  } else {                                     /* a Gaussian, sigma 0.42 pixels: what GS_Sharpness_060 is */
    for (p = 0; p < 64; p++) {
      float sum = 0;
      for (k = 0; k < 4; k++) { float d = (k - 1) - p / 64.0f; m_horiz[cls][p][k] = expf(-d * d / (2 * 0.42f * 0.42f)); sum += m_horiz[cls][p][k]; }
      for (k = 0; k < 4; k++) m_horiz[cls][p][k] /= sum;
    }
  }
  n = read_numbers(mcfg[cls].vert, v, 2 * 256 * 4, &ad, &tb);
  if (n == 2 * 256 * 4 || n == 256 * 4 || n == 64 * 4) {
    float div = tb ? 256.0f : 128.0f;
    int phases = n == 64 * 4 ? 64 : 256;
    for (i = 0; i < 2; i++)
      for (p = 0; p < 256; p++)
        for (k = 0; k < 4; k++) m_vert[cls][i][p][k] = v[(((n == 2 * 256 * 4 ? i : 0) * 256) + p * phases / 256) * 4 + k] / div;
  } else {                                     /* stand-ins: a beam over the two nearest lines, deeper gaps for dark pixels */
    for (i = 0; i < 2; i++)
      for (p = 0; p < 256; p++) {
        float f = p / 256.0f, s = i ? 0.457f : 0.337f, a = i ? 0.97f : 1.1f;
        m_vert[cls][i][p][0] = m_vert[cls][i][p][3] = 0;
        m_vert[cls][i][p][1] = a * expf(-powf(f / s, 1.5f));
        m_vert[cls][i][p][2] = a * expf(-powf((1 - f) / s, 1.5f));
      }
  }
  n = read_numbers(mcfg[cls].gamma, v, 256, &ad, &tb);
  if (n == 256) for (i = 0; i < 256; i++) m_gamma[cls][i] = v[i] / 255.0f;
  else for (i = 0; i < 256; i++) m_gamma[cls][i] = mcfg[cls].gamma[0] ? powf(i / 255.0f, 2.5f / 2.2f) : i / 255.0f;
  load_mask(mcfg[cls].mask, cls);
}

static void mister_mask_for(int height, int cls)
{
  int best = 0;
  if (height == m_mask_for && cls == m_class_up) return;
  m_mask_for = height;
  for (int i = 0; i < m_nmasks[cls]; i++) if (m_masks[cls][i].res <= height && m_masks[cls][i].res >= m_masks[cls][best].res) best = i;
  vgl_mister_mask(m_masks[cls][best].rgb, m_masks[cls][best].w, m_masks[cls][best].h);
}

static void mister_upload(int cls, int height)
{
  if (m_class_up != cls) {
    vgl_mister_tables((const float (*)[4])m_horiz[cls], (const float (*)[256][4])m_vert[cls], m_gamma[cls]);
    m_class_up = cls;
    m_mask_for = -1;
  }
  mister_mask_for(height, cls);
}

/* a preset of the MiSTer scaler (an .ini: hfilter, vfilter, sfilter, gamma, mask, maskmode), paths relative to its Filters, Gamma and Shadow_Masks folders */
static void apply_preset(int cls, const char *rel)
{
  char line[512], hf[260] = "", vf[260] = "same", gm[260] = "off", mk[260] = "", mm[32] = "off";
  FILE *f = open_rel(rel);
  if (!f) return;
  while (fgets(line, sizeof line, f)) {
    char *k = line, *v = strchr(line, '='), *e;
    if (!v || line[0] == '#') continue;
    *v++ = 0;
    for (e = v + strlen(v); e > v && (e[-1] == '\n' || e[-1] == '\r' || e[-1] == ' '); ) *--e = 0;
    if (!strcmp(k, "hfilter")) snprintf(hf, sizeof hf, "%s", v);
    else if (!strcmp(k, "vfilter")) snprintf(vf, sizeof vf, "%s", v);
    else if (!strcmp(k, "gamma")) snprintf(gm, sizeof gm, "%s", v);
    else if (!strcmp(k, "mask")) snprintf(mk, sizeof mk, "%s", v);
    else if (!strcmp(k, "maskmode")) snprintf(mm, sizeof mm, "%s", v);
  }
  fclose(f);
  snprintf(mcfg[cls].horiz, sizeof mcfg[cls].horiz, "mister/Filters/%.240s", hf);
  if (!strcmp(vf, "same")) memcpy(mcfg[cls].vert, mcfg[cls].horiz, sizeof mcfg[cls].vert);
  else snprintf(mcfg[cls].vert, sizeof mcfg[cls].vert, "mister/Filters/%.240s", vf);
  if (!strcmp(gm, "off") || !gm[0]) mcfg[cls].gamma[0] = 0; else snprintf(mcfg[cls].gamma, sizeof mcfg[cls].gamma, "mister/Gamma/%.240s", gm);
  if (!strcmp(mm, "off") || !mk[0]) mcfg[cls].mask[0] = 0; else snprintf(mcfg[cls].mask, sizeof mcfg[cls].mask, "mister/Shadow_Masks/%.240s", mk);
  mcfg[cls].mask_scale = mm[0] >= '1' && mm[0] <= '4' ? mm[0] - '0' : 1;
}

/* The integer scale taken before the window's bicubic scaling, the width of the scanlines (0: none), how many scanlines there are per source line,
 * and the style: 0 plain or scanlines, 1 a soft CRT (after Timothy Lottes' CRT shader), 2 the same with an aperture grille, 3 MiSTer, 4 custom. */
static void look(int w, int *pre, float *scan, int *period, int *style)
{
  static const int lo_pre[4] = { 3, 5, 7, 11 };
  *scan = 0; *period = 1; *style = 0;
  if (w <= 320) {
    int m = lores_mode;
    *pre = m < 4 ? lo_pre[m] : 3;
    if (m >= 4) *period = lores_khz31 ? 2 : 1;
    if (m >= 4 && m < 7) *scan = scan_strength[m - 4];
    if (m == 7 || m == 8) { *style = m - 6; *pre = 1; }
    if (m == 9) { *style = 3; *pre = 1; }
    if (m == 10) { *style = 4; *pre = 3; }
  } else {
    int m = hires_mode;
    *pre = m < 4 ? m + 1 : 1;
    if (m >= 4 && m < 7) *scan = scan_strength[m - 4];
    if (m >= 7 && m < 9) *style = 1 + (m - 7);
    if (m == 9) *style = 3;
    if (m == 10) *style = 4;
  }
}

const char *settings_path(void)
{
  static char path[1100];
  if (!path[0]) {
    const char *e = getenv("NHL94_INI");
    char *base = SDL_GetBasePath();
    if (e) snprintf(path, sizeof path, "%s", e);
    else snprintf(path, sizeof path, "%s%s", base ? base : "", "hockey94.ini");
    SDL_free(base);
  }
  return path;
}

static int name_index(const char *v, const char **names, int n, int def)
{
  for (int i = 0; i < n; i++) if (!strcmp(v, names[i])) return i;
  return def;
}

static void settings_load(void)
{
  char line[400];
  FILE *f;
  mister_defaults(0); mister_defaults(1);
  f = fopen(settings_path(), "r");
  if (!f) return;
  while (fgets(line, sizeof line, f)) {
    char *k = line, *v = strchr(line, '='), *e;
    if (!v || line[0] == ';' || line[0] == '[') continue;
    *v++ = 0;
    while (*k == ' ') k++;
    for (e = k + strlen(k); e > k && e[-1] == ' '; ) *--e = 0;
    while (*v == ' ') v++;
    for (e = v + strlen(v); e > v && (e[-1] == ' ' || e[-1] == '\n' || e[-1] == '\r'); ) *--e = 0;
    if (!strcmp(k, "refresh")) { if (!strcmp(v, "70")) present_hz = 70, vrr_on = 0; else if (!strcmp(v, "vrr")) vrr_on = 1; else present_hz = 60, vrr_on = 0; }
    else if (!strcmp(k, "vsync")) vsync_on = strcmp(v, "off") != 0;
    else if (!strcmp(k, "stats")) osd_on = !strcmp(v, "on");
    else if (!strcmp(k, "hires_scaling")) hires_mode = name_index(v, hires_names, NHIRES, 0);
    else if (!strcmp(k, "lores_scaling")) lores_mode = name_index(v, lores_names, NLORES, 0);
    else if (!strcmp(k, "lores_scan")) lores_khz31 = atoi(v) == 31;
    else if (!strncmp(k, "hires_mister_", 13) || !strncmp(k, "lores_mister_", 13)) {
      int c = k[0] == 'l';
      const char *key = k + 13;
      if (!strcmp(key, "horizontal_filter")) snprintf(mcfg[c].horiz, sizeof mcfg[c].horiz, "%s", v);
      else if (!strcmp(key, "vertical_filter")) snprintf(mcfg[c].vert, sizeof mcfg[c].vert, "%s", v);
      else if (!strcmp(key, "gamma")) snprintf(mcfg[c].gamma, sizeof mcfg[c].gamma, "%s", v);
      else if (!strcmp(key, "shadow_mask")) snprintf(mcfg[c].mask, sizeof mcfg[c].mask, "%s", v);
      else if (!strcmp(key, "mask_scale")) mcfg[c].mask_scale = atoi(v) < 1 ? 1 : atoi(v) > 4 ? 4 : atoi(v);
      else if (!strcmp(key, "brightness")) mcfg[c].bright = (float)atof(v);
    }
    else if (!strcmp(k, "custom_scanline_darkness")) c_dark = (float)atof(v);
    else if (!strcmp(k, "custom_gamma")) c_gamma = (float)atof(v);
    else if (!strcmp(k, "custom_mask_strength")) c_mask = (float)atof(v);
    else if (!strcmp(k, "custom_sharpness")) c_sharp = (float)atof(v);
    else if (!strcmp(k, "system_pointer")) ptr_mode = name_index(v, ptr_names, 3, 0);
    else if (!strcmp(k, "hires_picture_height")) vscale_hi = name_index(v, vscale_names, 4, 0);
    else if (!strcmp(k, "lores_picture_height")) vscale_lo = name_index(v, vscale_names, 4, 0);
  }
  fclose(f);
}

static void settings_save(void)
{
  FILE *f;
  if (getenv("NHL94_NOSAVE")) return;
  f = fopen(settings_path(), "w");
  if (!f) return;
  fprintf(f, "; NHL Hockey '94 (SDL2 port) settings. Changed from the window menu (Windows) or edited here.\n[video]\n");
  fprintf(f, "; refresh: 60, 70 or vrr (draw whenever the game's picture changes, for variable refresh rate monitors)\nrefresh=%s\n", vrr_on ? "vrr" : present_hz == 70 ? "70" : "60");
  fprintf(f, "; vsync: on or off\nvsync=%s\n", vsync_on ? "on" : "off");
  fprintf(f, "; stats: on or off (pictures per second, CPU and GPU use, in the top right corner; the ` key)\nstats=%s\n", osd_on ? "on" : "off");
  fprintf(f, "; lores_scaling (the 320x200 screens: all of the game's own): 3x, 5x, 7x, 11x, crt-light, crt-medium, crt-strong, crt-soft, crt-soft-grille, mister, custom\nlores_scaling=%s\n", lores_names[lores_mode]);
  fprintf(f, "; hires_scaling (640x480 screens, if any): 1x, 2x, 3x, 4x, crt-light, crt-medium, crt-strong, crt-soft, crt-soft-grille, mister, custom\nhires_scaling=%s\n", hires_names[hires_mode]);
  fprintf(f, "; lores_picture_height and hires_picture_height: fit (the window), integer (the biggest whole multiple of the source lines that fits: even scanlines),\n; overscan (the next multiple up, a little cut off) or auto-crop (the next multiple up when 6 (320x200) or 10 (640x480) window rows or fewer are cut off, else integer;\n; overscan and auto-crop never cut off columns: when the next multiple up is wider than the window they use integer)\nlores_picture_height=%s\nhires_picture_height=%s\n", vscale_names[vscale_lo], vscale_names[vscale_hi]);
  fprintf(f, "; the MiSTer look uses the MiSTer scaler's own files: paths relative to this folder, starting with the folder of the MiSTer SD card they come from\n");
  fprintf(f, "; (Filters, Gamma, Shadow_Masks; empty gamma or shadow mask: none), the mask scale (1-4) and the brightness (1.0 is the files' own)\n");
  for (int c = 1; c >= 0; c--) {
    const char *pre = c ? "lores" : "hires";
    fprintf(f, "%s_mister_horizontal_filter=%s\n%s_mister_vertical_filter=%s\n%s_mister_gamma=%s\n%s_mister_shadow_mask=%s\n%s_mister_mask_scale=%d\n%s_mister_brightness=%.2f\n",
            pre, mcfg[c].horiz, pre, mcfg[c].vert, pre, mcfg[c].gamma, pre, mcfg[c].mask, pre, mcfg[c].mask_scale, pre, mcfg[c].bright);
  }
  fprintf(f, "; lores_scan: 15 (single scan, a TV) or 31 (double scan, a VGA monitor: the 320x200 picture is doubled to 320x400) for the CRT looks\nlores_scan=%d\n", lores_khz31 ? 31 : 15);
  fprintf(f, "; the custom look: scanline gap darkness (0-1), gamma, RGB mask strength (0-0.3), horizontal sharpness (0 bilinear, 1 bicubic)\n");
  fprintf(f, "custom_scanline_darkness=%.2f\ncustom_gamma=%.2f\ncustom_mask_strength=%.2f\ncustom_sharpness=%.2f\n", c_dark, c_gamma, c_mask, c_sharp);
  fprintf(f, "; system_pointer: auto (hidden over the picture where the game draws its glove), show or hide\nsystem_pointer=%s\n", ptr_names[ptr_mode]);
  bindings_save(f);
  fclose(f);
}

void settings_save_all(void) { settings_save(); }

double video_present_interval(void) { return 1.0 / present_hz; }
int video_vrr(void) { return vrr_on; }
int video_pointer_mode(void) { return ptr_mode; }
void *video_window(void) { return win; }

int video_mister_preset_active(int cls, const char *rel)
{
  char save[sizeof mcfg[0]];
  int same;
  memcpy(save, &mcfg[cls], sizeof save);
  apply_preset(cls, rel);
  same = !strcmp(mcfg[cls].horiz, ((typeof(mcfg[0]) *)save)->horiz) && !strcmp(mcfg[cls].vert, ((typeof(mcfg[0]) *)save)->vert) &&
         !strcmp(mcfg[cls].gamma, ((typeof(mcfg[0]) *)save)->gamma) && !strcmp(mcfg[cls].mask, ((typeof(mcfg[0]) *)save)->mask) &&
         mcfg[cls].mask_scale == ((typeof(mcfg[0]) *)save)->mask_scale;
  memcpy(&mcfg[cls], save, sizeof save);
  return same;
}

/* any change to the MiSTer filters turns the MiSTer look on for that kind of screen (with auto crop, as for any look with scanlines) */
static void mister_on(int cls)
{
  if (cls == 0 && hires_mode != 9) { hires_mode = 9; vscale_hi = 3; }
  if (cls == 1 && lores_mode != 9) { lores_mode = 9; vscale_lo = 3; }
}

const char *video_mister_path(int cls, int kind) { return kind == 0 ? mcfg[cls].horiz : kind == 1 ? mcfg[cls].vert : kind == 2 ? mcfg[cls].gamma : mcfg[cls].mask; }

void video_mister_pick(int cls, int kind, const char *rel)
{
  if (kind == 4) apply_preset(cls, rel);
  else snprintf(kind == 0 ? mcfg[cls].horiz : kind == 1 ? mcfg[cls].vert : kind == 2 ? mcfg[cls].gamma : mcfg[cls].mask, 260, "%s", rel);
  m_dirty[cls] = 1;
  mister_on(cls);
  settings_save();
  menu_sync();
}

/* A scanline is drawn over `rows` window rows. Its brightest row is the middle one, and the gain keeps the average brightness. */
static void scan_rows(float sigma, int rows, float *center, float *gain)
{
  float sum = 0;
  if (rows < 1) rows = 1;
  *center = ((rows - 1) / 2 + 0.5f) / rows;
  *gain = 1;
  if (sigma <= 0) return;
  for (int r = 0; r < rows; r++) { float d = ((r + 0.5f) / rows - *center) / sigma; sum += expf(-d * d); }
  *gain = rows / sum;
}

void video_command(int id)
{
  if (id == CMD_REFRESH_60) { present_hz = 60; vrr_on = 0; }
  else if (id == CMD_REFRESH_70) { present_hz = 70; vrr_on = 0; }
  else if (id == CMD_REFRESH_VRR) { vrr_on = 1; vsync_on = 0; }
  else if (id == CMD_VSYNC) vsync_on = !vsync_on;
  else if (id == CMD_STATS) osd_on = !osd_on;
  else if (id >= CMD_HIRES && id < CMD_HIRES + NHIRES) { hires_mode = id - CMD_HIRES; vscale_hi = hires_mode >= 4 ? 3 : 0; }
  else if (id >= CMD_LORES && id < CMD_LORES + NLORES) { lores_mode = id - CMD_LORES; vscale_lo = lores_mode >= 4 ? 3 : 0; }
  else if (id >= CMD_POINTER && id < CMD_POINTER + 3) ptr_mode = id - CMD_POINTER;
  else if (id >= CMD_MBRIGHT_HI && id < CMD_MBRIGHT_HI + 9) { mcfg[0].bright = 0.7f + 0.1f * (id - CMD_MBRIGHT_HI); mister_on(0); }
  else if (id >= CMD_MBRIGHT_LO && id < CMD_MBRIGHT_LO + 9) { mcfg[1].bright = 0.7f + 0.1f * (id - CMD_MBRIGHT_LO); mister_on(1); }
  else if (id >= CMD_MSCALE_HI && id < CMD_MSCALE_HI + 4) { mcfg[0].mask_scale = id - CMD_MSCALE_HI + 1; mister_on(0); }
  else if (id >= CMD_MSCALE_LO && id < CMD_MSCALE_LO + 4) { mcfg[1].mask_scale = id - CMD_MSCALE_LO + 1; mister_on(1); }
  else if (id == CMD_MKHZ || id == CMD_MKHZ + 1) lores_khz31 = id - CMD_MKHZ;
  else if (id == CMD_MRESET_HI) { mister_defaults(0); mister_on(0); }
  else if (id == CMD_MRESET_LO) { mister_defaults(1); mister_on(1); }
  else if (id >= CMD_VSCALE_HI && id < CMD_VSCALE_HI + 4) vscale_hi = id - CMD_VSCALE_HI;
  else if (id >= CMD_VSCALE_LO && id < CMD_VSCALE_LO + 4) vscale_lo = id - CMD_VSCALE_LO;
  else return;
  if (use_gl) vgl_set_vsync(vsync_on);
  settings_save();
  menu_sync();
  title_refresh();
}

int video_command_checked(int id)
{
  if (id == CMD_REFRESH_60) return !vrr_on && present_hz == 60;
  if (id == CMD_REFRESH_70) return !vrr_on && present_hz == 70;
  if (id == CMD_REFRESH_VRR) return vrr_on;
  if (id == CMD_VSYNC) return vsync_on;
  if (id == CMD_STATS) return osd_on;
  if (id >= CMD_HIRES && id < CMD_HIRES + NHIRES) return id - CMD_HIRES == hires_mode;
  if (id >= CMD_LORES && id < CMD_LORES + NLORES) return id - CMD_LORES == lores_mode;
  if (id >= CMD_POINTER && id < CMD_POINTER + 3) return id - CMD_POINTER == ptr_mode;
  if (id == CMD_MKHZ || id == CMD_MKHZ + 1) return lores_khz31 == id - CMD_MKHZ;
  if (id >= CMD_MBRIGHT_HI && id < CMD_MBRIGHT_HI + 9) return fabsf(mcfg[0].bright - (0.7f + 0.1f * (id - CMD_MBRIGHT_HI))) < 0.01f;
  if (id >= CMD_MBRIGHT_LO && id < CMD_MBRIGHT_LO + 9) return fabsf(mcfg[1].bright - (0.7f + 0.1f * (id - CMD_MBRIGHT_LO))) < 0.01f;
  if (id >= CMD_MSCALE_HI && id < CMD_MSCALE_HI + 4) return id - CMD_MSCALE_HI + 1 == mcfg[0].mask_scale;
  if (id >= CMD_MSCALE_LO && id < CMD_MSCALE_LO + 4) return id - CMD_MSCALE_LO + 1 == mcfg[1].mask_scale;
  if (id >= CMD_VSCALE_HI && id < CMD_VSCALE_HI + 4) return id - CMD_VSCALE_HI == vscale_hi;
  if (id >= CMD_VSCALE_LO && id < CMD_VSCALE_LO + 4) return id - CMD_VSCALE_LO == vscale_lo;
  return 0;
}

static char base_title[96] = "NHL Hockey '94";
static int shown, changed, cpu_pct = -1, gpu_pct = -1;
static double title_at;

/* the game's picture into argb[] (and its size) */
static uint32_t render(void)
{
  uint32_t pal[256], hash = 0;
  vga_render(pix, &mode_w, &mode_h, pal);
  for (int i = 0; i < mode_w * mode_h; i++) argb[i] = pal[pix[i]];
  for (int i = 0; i < mode_w * mode_h; i += 5) hash = hash * 31 + argb[i];
  return hash;
}

/* VRR: the window is drawn when the game's picture has changed, not on a timer. Looked at when the VGA saw a write, at most every 2 ms. */
static uint32_t last_hash;
static int fresh;                              /* argb[] holds a new picture not yet drawn */
int video_changed(void)
{
  static double at;
  double now = host_time();
  uint32_t h;
  if (!vga_dirty || now - at < 0.002) return 0;
  at = now;
  vga_dirty = 0;
  h = render();
  if (h == last_hash) return 0;
  fresh = 1;
  return 1;
}

static void title_refresh(void)
{
  if (win) SDL_SetWindowTitle(win, base_title);
  if (use_gl) {
    char l1[32], l2[32], l3[32];
    snprintf(l1, sizeof l1, "FPS %d  NEW %d", shown, changed);
    if (vrr_on) snprintf(l2, sizeof l2, "VRR VSYNC %s", vsync_on ? "ON" : "OFF");
    else snprintf(l2, sizeof l2, "%dHZ VSYNC %s", present_hz, vsync_on ? "ON" : "OFF");
    if (cpu_pct < 0) snprintf(l3, sizeof l3, "CPU --"); else snprintf(l3, sizeof l3, "CPU %d%%", cpu_pct);
    if (gpu_pct >= 0) snprintf(l3 + strlen(l3), sizeof l3 - strlen(l3), " GPU %d%%", gpu_pct); else snprintf(l3 + strlen(l3), sizeof l3 - strlen(l3), " GPU --");
    vgl_osd_set(osd_on ? l1 : NULL, osd_on ? l2 : NULL, osd_on ? l3 : NULL);
  }
}

static void client_size(int *w, int *h)
{
  if (!menu_client_size(w, h) && win) SDL_GetWindowSize(win, w, h);
}

/* where the picture sits in the window: the largest 4:3 rectangle, centred, or a whole number of window rows per line (picture height) */
void video_view(int *vx, int *vy, int *vw, int *vh)
{
  int ww = 960, wh = 720, w, h, vs = mode_w <= 320 ? vscale_lo : vscale_hi;
  if (win) client_size(&ww, &wh);
  w = ww; h = ww * 3 / 4;
  if (h > wh) { h = wh; w = wh * 4 / 3; }
  if (vs) {
    int pre, period, style, unit, kf, kc, k;
    float scan;
    look(mode_w, &pre, &scan, &period, &style);
    unit = mode_h * (period == 2 ? 2 : 1);
    kf = wh / unit;
    if (kf < 1) kf = 1;
    while (kf > 1 && kf * unit * 4 / 3 > ww) kf--;
    kc = (wh + unit - 1) / unit;
    if (kc * unit * 4 / 3 > ww) kc = kf;          /* the rows may be cropped a little (overscan, auto crop), the columns never: too wide is one multiple down */
    if (kc < kf) kc = kf;
    if (vs == 1) k = kf;
    else if (vs == 2) k = kc;
    else k = (kc * unit - wh <= (mode_w <= 320 ? 6 : 10)) ? kc : kf;
    h = k * unit; w = h * 4 / 3;
  }
  *vw = w; *vh = h; *vx = (ww - w) / 2; *vy = (wh - h) / 2;
}

void video_mode_size(int *w, int *h) { *w = mode_w; *h = mode_h; }

void video_confine_mouse(int on)
{
  static int was, px, py, pw, ph;
  int vx, vy, vw, vh;
  if (!win) return;
  video_view(&vx, &vy, &vw, &vh);
  if (on == was && (!on || (vx == px && vy == py && vw == pw && vh == ph))) return;
  was = on; px = vx; py = vy; pw = vw; ph = vh;
  if (on) { SDL_Rect r = { vx, vy, vw, vh }; SDL_SetWindowMouseRect(win, &r); }
  else SDL_SetWindowMouseRect(win, NULL);
}

static int fullscreen;
void video_toggle_fullscreen(void)
{
  if (!win) return;
  fullscreen = !fullscreen;
  if (!fullscreen) menu_show(1);
  SDL_SetWindowFullscreen(win, fullscreen ? SDL_WINDOW_FULLSCREEN_DESKTOP : 0);
  if (fullscreen) menu_show(0);
}

int video_is_fullscreen(void) { return fullscreen; }

void video_init(int want_gl)
{
  int ww = getenv("NHL94_WINDOW_W") ? atoi(getenv("NHL94_WINDOW_W")) : 960, wh = getenv("NHL94_WINDOW_H") ? atoi(getenv("NHL94_WINDOW_H")) : 720;
  settings_load();
  bindings_load();
  if (getenv("NHL94_LOOK")) lores_mode = name_index(getenv("NHL94_LOOK"), lores_names, NLORES, lores_mode);   /* a test aid */
  if (getenv("NHL94_PRESET")) { const char *t = getenv("NHL94_PRESET"); apply_preset(t[0] == 'l', t + 2); mister_on(t[0] == 'l'); }
  vgl_filter = getenv("NHL94_FILTER");
  SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest");
  if (want_gl && !getenv("NHL94_NOGL") && SDL_strcmp(SDL_GetCurrentVideoDriver(), "dummy")) {
    win = SDL_CreateWindow(base_title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, ww, wh, SDL_WINDOW_RESIZABLE | SDL_WINDOW_OPENGL);
    if (win && vgl_init(win)) {
      use_gl = 1; vgl_set_vsync(vsync_on); menu_init(win); title_refresh();
      if (getenv("NHL94_MAXIMIZE")) SDL_MaximizeWindow(win);
      return;
    }
    fprintf(stderr, "OpenGL scaling is not available, using SDL's renderer\n");
    if (win) SDL_DestroyWindow(win);
    win = 0;
  }
  win = SDL_CreateWindow(base_title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, ww, wh, SDL_WINDOW_RESIZABLE);
  if (!win) { fprintf(stderr, "SDL window: %s\n", SDL_GetError()); exit(1); }
  ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | (vsync_on ? SDL_RENDERER_PRESENTVSYNC : 0));
  if (!ren) ren = SDL_CreateRenderer(win, -1, SDL_RENDERER_SOFTWARE);
  if (!ren) { fprintf(stderr, "SDL renderer: %s\n", SDL_GetError()); exit(1); }
  menu_init(win);
}

/* NHL94_DUMP=dir: a PPM of the picture (called twice a second) */
void video_dump(const char *dir)
{
  static int n;
  char path[1100];
  FILE *f;
  if (!fresh) render();
  snprintf(path, sizeof path, "%s/shot%04d.ppm", dir, n++);
  f = fopen(path, "wb");
  if (!f) return;
  fprintf(f, "P6\n%d %d\n255\n", mode_w, mode_h);
  for (int i = 0; i < mode_w * mode_h; i++) { uint8_t px[3] = { argb[i] >> 16, argb[i] >> 8, argb[i] }; fwrite(px, 1, 3, f); }
  fclose(f);
}

void video_present(void)
{
  int w, h;
  uint32_t hash;
  if (!ren && !use_gl) return;
  fresh = 0;
  hash = render();
  w = mode_w; h = mode_h;
  if (!use_gl && (w != tex_w || h != tex_h)) {
    if (tex) SDL_DestroyTexture(tex);
    tex = SDL_CreateTexture(ren, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, w, h);
    tex_w = w; tex_h = h;
  }
  {                                           /* pictures drawn and new pictures per second (the stats display) */
    static int n_shown, n_changed;
    double now = host_time();
    n_shown++; if (hash != last_hash) n_changed++;
    last_hash = hash;
    if (now - title_at >= 1.0) {
      shown = (int)(n_shown / (now - title_at) + 0.5); changed = (int)(n_changed / (now - title_at) + 0.5);
      n_shown = n_changed = 0; title_at = now;
      if (osd_on) { cpu_pct = plat_cpu_percent(); gpu_pct = plat_gpu_percent(); }
      title_refresh();
    }
  }
  {
    int vx, vy, vw, vh;
    video_view(&vx, &vy, &vw, &vh);
    if (use_gl) {                             /* the view in drawable pixels, origin at the bottom left */
      int ww, wh, dw, dh;
      client_size(&ww, &wh);
      SDL_GL_GetDrawableSize(win, &dw, &dh);
      if (ww <= 0 || wh <= 0) return;
      {
        int pre, period, style, unit, rows;
        float scan, center, gain;
        look(w, &pre, &scan, &period, &style);
        unit = h * (period == 2 ? 2 : 1);
        rows = (vh * dh / wh + unit / 2) / unit;
        scan_rows(scan, rows, &center, &gain);
        vgl_set_target(dw, dh);
        vgl_set_look(pre, scan, gain, center, period, style);
        if (style == 3) { int c = w <= 320; if (m_dirty[c]) mister_load(c); mister_upload(c, dh); }
        vgl_set_custom(c_dark, c_gamma, c_mask, c_sharp);
        vgl_set_bright(mcfg[w <= 320].bright, (float)mcfg[w <= 320].mask_scale);
      }
      vgl_draw(win, argb, w, h, vx * dw / ww, (wh - vy - vh) * dh / wh, vw * dw / ww, vh * dh / wh);
    } else {
      SDL_Rect dst = { vx, vy, vw, vh };
      int ow, oh, ww, wh;
      SDL_GetRendererOutputSize(ren, &ow, &oh); client_size(&ww, &wh);
      if (ww > 0 && wh > 0) { dst.x = vx * ow / ww; dst.y = vy * oh / wh; dst.w = vw * ow / ww; dst.h = vh * oh / wh; }
      SDL_UpdateTexture(tex, 0, argb, w * 4);
      SDL_SetRenderDrawColor(ren, 0, 0, 0, 255);
      SDL_RenderClear(ren);
      SDL_RenderCopy(ren, tex, 0, &dst);
      SDL_RenderPresent(ren);
    }
  }
}

void video_set_title(const char *title)
{
  snprintf(base_title, sizeof base_title, "%s", title);
  title_refresh();
}
