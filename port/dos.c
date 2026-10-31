/* dos.c: DOS for the game. int 21h (files, memory control blocks, vectors, find first/next, time), int 2Fh, and
 * loading HOCKEY.EXE (MZ image, relocations, PSP, environment). Drive C: is the game folder; a DOS name is matched
 * against the host's files ignoring case. */
#include "machine.h"
#include <ctype.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>
#ifdef _WIN32
#include <io.h>
#include <direct.h>
#define MKDIR(p) _mkdir(p)
#else
#define MKDIR(p) mkdir(p, 0777)
#endif
#ifndef O_BINARY
#define O_BINARY 0
#endif

char game_root[1024] = ".";
static char cwd[128] = "";             /* below C:\, no leading or trailing backslash */
static uint16_t cur_psp, dta_seg, dta_off;
static uint16_t last_error;
static int exit_code = -1;

#define FIRST_MCB 0x0700
#define MEM_TOP   0xA000

/* ---- paths ---- */
static void strip_pad(char *s)
{
  char *dot = strrchr(s, '.'), *e;
  if (dot) { for (e = dot; e > s && e[-1] == ' '; ) e--; memmove(e, dot, strlen(dot) + 1); }
  for (e = s + strlen(s); e > s && e[-1] == ' '; ) *--e = 0;
}

static void resolve_in(const char *base, const char *rel, char *out, size_t n)
{
  char tmp[512], cur[1024], *tok, *save;
  snprintf(tmp, sizeof tmp, "%s", rel);
  snprintf(cur, sizeof cur, "%s", base);
  for (tok = strtok_r(tmp, "/", &save); tok; tok = strtok_r(0, "/", &save)) {
    char next[1100]; int found = 0;
    strip_pad(tok);
    if (!*tok || !strcmp(tok, ".")) continue;
    DIR *d = opendir(cur);
    if (d) {
      struct dirent *e;
      while ((e = readdir(d))) if (!strcasecmp(e->d_name, tok)) { snprintf(next, sizeof next, "%s/%s", cur, e->d_name); found = 1; break; }
      closedir(d);
    }
    if (!found) snprintf(next, sizeof next, "%s/%s", cur, tok);
    snprintf(cur, sizeof cur, "%s", next);
  }
  snprintf(out, n, "%s", cur);
}

/* DOS path (any drive) -> path below C:\ with '/' separators, '..' folded */
static void dos_canon(const char *dos, char *out, size_t n)
{
  char tmp[512]; size_t i = 0;
  if (dos[0] && dos[1] == ':') dos += 2;
  if (*dos == '\\' || *dos == '/') tmp[0] = 0;
  else snprintf(tmp, sizeof tmp, "%s%s", cwd, *cwd ? "/" : "");
  i = strlen(tmp);
  for (; *dos && i < sizeof tmp - 1; dos++) tmp[i++] = (*dos == '\\') ? '/' : *dos;
  tmp[i] = 0;
  char *parts[64]; int np = 0; char *save, *tok;
  for (tok = strtok_r(tmp, "/", &save); tok && np < 64; tok = strtok_r(0, "/", &save)) {
    if (!strcmp(tok, ".")) continue;
    if (!strcmp(tok, "..")) { if (np) np--; continue; }
    parts[np++] = tok;
  }
  out[0] = 0;
  for (int k = 0; k < np; k++) { strncat(out, parts[k], n - strlen(out) - 1); if (k + 1 < np) strncat(out, "/", n - strlen(out) - 1); }
}

int host_path(const char *dos, char *out, size_t n, int must_exist)
{
  char rel[512]; struct stat st;
  dos_canon(dos, rel, sizeof rel);
  resolve_in(game_root, rel, out, n);
  if (!must_exist || !stat(out, &st)) return 0;
  /* not in the game folder: try the folder above it (files a DOS install kept next to the game) */
  char base[1100], alt[1100];
  snprintf(base, sizeof base, "%s/..", game_root);
  resolve_in(base, rel, alt, sizeof alt);
  if (!stat(alt, &st)) { snprintf(out, n, "%s", alt); return 0; }
  return -1;
}

static void read_str(uint16_t seg, uint16_t off, char *buf, size_t n)
{
  size_t i;
  for (i = 0; i + 1 < n; i++) { buf[i] = rd8(lin(seg, off + i)); if (!buf[i]) break; }
  buf[i] = 0;
}

static void fail(uint16_t code) { last_error = code; s_ax(code); set_cf(1); }
static void ok(void) { set_cf(0); }

static uint16_t err_of(int e)
{
  switch (e) {
  case ENOENT: return 2; case ENOTDIR: return 3; case EMFILE: return 4;
  case EACCES: case EPERM: case EROFS: return 5; case EBADF: return 6; case ENOMEM: return 8; case EEXIST: return 80;
  }
  return 1;
}

/* ---- handles ---- */
#define NHANDLES 64
static int hfd[NHANDLES];
static char hname[NHANDLES][64];

static int new_handle(int fd)
{
  for (int i = 5; i < NHANDLES; i++) if (hfd[i] < 0) { hfd[i] = fd; return i; }
  return -1;
}

/* ---- memory control blocks ---- */
static uint8_t mcb_type(uint16_t s) { return rd8(lin(s, 0)); }
static uint16_t mcb_owner(uint16_t s) { return rd16(lin(s, 1)); }
static uint16_t mcb_size(uint16_t s) { return rd16(lin(s, 3)); }
static void mcb_set(uint16_t s, uint8_t type, uint16_t owner, uint16_t size)
{
  wr8(lin(s, 0), type); wr16(lin(s, 1), owner); wr16(lin(s, 3), size);
  for (int i = 5; i < 16; i++) wr8(lin(s, i), 0);
}

static void mcb_merge(void)
{
  uint16_t s = FIRST_MCB;
  for (;;) {
    if (mcb_type(s) == 'Z') return;
    uint16_t n = s + 1 + mcb_size(s);
    if (mcb_owner(s) == 0 && mcb_owner(n) == 0) {
      mcb_set(s, mcb_type(n), 0, mcb_size(s) + 1 + mcb_size(n));
      continue;
    }
    s = n;
  }
}

static uint16_t largest_free(void)
{
  uint16_t best = 0, s = FIRST_MCB;
  mcb_merge();
  for (;;) {
    if (mcb_owner(s) == 0 && mcb_size(s) > best) best = mcb_size(s);
    if (mcb_type(s) == 'Z') return best;
    s += 1 + mcb_size(s);
  }
}

static int mem_alloc(uint16_t paras, uint16_t *seg)
{
  uint16_t s = FIRST_MCB;
  mcb_merge();
  for (;;) {
    if (mcb_owner(s) == 0 && mcb_size(s) >= paras) {
      uint16_t sz = mcb_size(s); uint8_t t = mcb_type(s);
      if (sz > paras) {
        mcb_set(s, 'M', cur_psp, paras);
        mcb_set(s + 1 + paras, t, 0, sz - paras - 1);
      } else mcb_set(s, t, cur_psp, sz);
      *seg = s + 1;
      return 0;
    }
    if (mcb_type(s) == 'Z') return -1;
    s += 1 + mcb_size(s);
  }
}

static int mem_resize(uint16_t seg, uint16_t paras, uint16_t *maxp)
{
  uint16_t s = seg - 1;
  mcb_merge();
  uint16_t sz = mcb_size(s);
  if (paras <= sz) {
    if (paras < sz) {
      uint8_t t = mcb_type(s);
      mcb_set(s, 'M', mcb_owner(s), paras);
      mcb_set(s + 1 + paras, t, 0, sz - paras - 1);
      mcb_merge();
    }
    return 0;
  }
  /* grow into a free block that follows */
  uint16_t avail = sz;
  if (mcb_type(s) != 'Z') {
    uint16_t n = s + 1 + sz;
    if (mcb_owner(n) == 0) avail = sz + 1 + mcb_size(n);
    if (paras <= avail) {
      uint8_t t = mcb_type(n); uint16_t total = avail;
      if (total - paras >= 1) {
        mcb_set(s, 'M', mcb_owner(s), paras);
        if (total > paras) mcb_set(s + 1 + paras, t, 0, total - paras - 1);
      } else mcb_set(s, t, mcb_owner(s), total);
      return 0;
    }
  }
  *maxp = avail;
  return -1;
}

/* ---- find first / next ---- */
struct find { int used; char dir[1024]; char pat[16]; long pos; uint8_t attr; };
static struct find finds[16];

static int wild(const char *pat, const char *name)
{
  for (; *pat; pat++, name++) {
    if (*pat == '*') { while (*pat == '*') pat++; if (!*pat) return 1; if (*pat == '.' && !strchr(name, '.') && !strcmp(pat, ".*")) return 1;
      while (*name) if (wild(pat, name++)) return 1; return wild(pat, name); }
    if (*pat == '?') { if (!*name || *name == '.') { name--; continue; } continue; }
    if (toupper((unsigned char)*pat) != toupper((unsigned char)*name)) {
      if (*pat == '.' && !*name && !strcmp(pat, ".*")) return 1;
      return 0;
    }
  }
  return !*name;
}

static int find_next(struct find *f)
{
  DIR *d = opendir(f->dir);
  if (!d) return 0;
  struct dirent *e; long k = 0;
  uint32_t dta = lin(dta_seg, dta_off);
  while ((e = readdir(d))) {
    if (k++ < f->pos) continue;
    f->pos = k;
    if (e->d_name[0] == '.' || strlen(e->d_name) > 12) continue;
    if (!wild(f->pat, e->d_name)) continue;
    char full[1200]; struct stat st;
    snprintf(full, sizeof full, "%s/%s", f->dir, e->d_name);
    if (stat(full, &st)) continue;
    if (S_ISDIR(st.st_mode) && !(f->attr & 0x10)) continue;
    struct tm *t = localtime(&st.st_mtime);
    wr8(dta + 0x15, S_ISDIR(st.st_mode) ? 0x10 : 0x20);
    wr16(dta + 0x16, (t->tm_hour << 11) | (t->tm_min << 5) | (t->tm_sec / 2));
    wr16(dta + 0x18, ((t->tm_year - 80) << 9) | ((t->tm_mon + 1) << 5) | t->tm_mday);
    wr32(dta + 0x1A, (uint32_t)st.st_size);
    for (int i = 0; i < 13; i++) wr8(dta + 0x1E + i, 0);
    for (int i = 0; i < 12 && e->d_name[i]; i++) wr8(dta + 0x1E + i, toupper((unsigned char)e->d_name[i]));
    closedir(d);
    return 1;
  }
  closedir(d);
  return 0;
}

/* ---- the program ---- */
int dos_load_exe(const char *hpath, const char *dpath, const char *args, uint16_t *cs, uint16_t *ip, uint16_t *ss,
                 uint16_t *sp, uint16_t *psp)
{
  FILE *f = fopen(hpath, "rb");
  if (!f) { fprintf(stderr, "cannot open %s\n", hpath); return -1; }
  uint8_t h[28];
  if (fread(h, 1, 28, f) != 28 || h[0] != 'M' || h[1] != 'Z') { fclose(f); return -1; }
#define H(i) (h[(i) * 2] | h[(i) * 2 + 1] << 8)
  uint32_t size = (H(2) - 1) * 512u + (H(1) ? H(1) : 512) - H(4) * 16u;
  uint16_t minalloc = H(5);
  /* environment */
  uint16_t env, pspseg;
  cur_psp = 0x0008; /* "DOS" owns the environment */
  mcb_set(FIRST_MCB, 'Z', 0, MEM_TOP - FIRST_MCB - 1);
  mem_alloc(0x20, &env);
  {
    uint32_t a = lin(env, 0);
    const char *vars[] = { "COMSPEC=C:\\COMMAND.COM", "PATH=C:\\", NULL, NULL };
    char blaster[64];
    const char *b = getenv("BLASTER"); snprintf(blaster, sizeof blaster, "BLASTER=%s", b ? b : "A220 I7 D1 T3");
    vars[2] = blaster;
    for (int i = 0; vars[i]; i++) { for (const char *p = vars[i]; *p; p++) wr8(a++, *p); wr8(a++, 0); }
    wr8(a++, 0); wr16(a, 1); a += 2;
    for (const char *p = dpath; *p; p++) wr8(a++, *p);
    wr8(a, 0);
  }
  uint16_t avail = largest_free();
  if (avail < size / 16 + 0x10 + minalloc) { fclose(f); fprintf(stderr, "not enough memory\n"); return -1; }
  cur_psp = 0xFFFF;
  mem_alloc(avail, &pspseg);
  mcb_set(pspseg - 1, mcb_type(pspseg - 1), pspseg, mcb_size(pspseg - 1));
  cur_psp = pspseg;
  /* PSP */
  uint32_t p = lin(pspseg, 0);
  for (int i = 0; i < 256; i++) wr8(p + i, 0);
  wr16(p, 0x20CD);
  wr16(p + 2, pspseg + mcb_size(pspseg - 1));
  wr8(p + 5, 0x9A);
  uint16_t vs, vo;
  cpu_get_vector(0x22, &vs, &vo); wr16(p + 0x0A, vo); wr16(p + 0x0C, vs);
  cpu_get_vector(0x23, &vs, &vo); wr16(p + 0x0E, vo); wr16(p + 0x10, vs);
  cpu_get_vector(0x24, &vs, &vo); wr16(p + 0x12, vo); wr16(p + 0x14, vs);
  wr16(p + 0x16, pspseg);
  for (int i = 0; i < 20; i++) wr8(p + 0x18 + i, i < 5 ? i : 0xFF);
  wr16(p + 0x2C, env);
  wr16(p + 0x32, 20); wr16(p + 0x34, 0x18); wr16(p + 0x36, pspseg);
  wr8(p + 0x50, 0xCD); wr8(p + 0x51, 0x21); wr8(p + 0x52, 0xCB);
  {
    size_t n = strlen(args); if (n > 126) n = 126;
    wr8(p + 0x80, n);
    for (size_t i = 0; i < n; i++) wr8(p + 0x81 + i, args[i]);
    wr8(p + 0x81 + n, 0x0D);
  }
  dta_seg = pspseg; dta_off = 0x80;
  /* load module */
  uint16_t load = pspseg + 0x10;
  uint8_t *img = malloc(size);
  fseek(f, H(4) * 16L, SEEK_SET);
  if (fread(img, 1, size, f) != size) { fclose(f); free(img); return -1; }
  memcpy(mem + lin(load, 0), img, size);
  free(img);
  fseek(f, H(12), SEEK_SET);
  for (int i = 0; i < H(3); i++) {
    uint8_t r[4];
    if (fread(r, 1, 4, f) != 4) break;
    uint16_t off = r[0] | r[1] << 8, seg = r[2] | r[3] << 8;
    uint32_t a = lin(load + seg, off);
    wr16(a, rd16(a) + load);
  }
  fclose(f);
  *cs = load + H(11); *ip = H(10); *ss = load + H(7); *sp = H(8); *psp = pspseg;
  LOG("loaded %s at %04X, entry %04X:%04X, %u bytes\n", hpath, load, *cs, *ip, size);
  return 0;
#undef H
}

void dos_init(const char *root, const char *exe, const char *args)
{
  (void)exe; (void)args;
  snprintf(game_root, sizeof game_root, "%s", root);
  for (int i = 0; i < NHANDLES; i++) hfd[i] = -1;
  hfd[0] = 0; hfd[1] = 1; hfd[2] = 2; hfd[3] = -2; hfd[4] = -2;
}

int dos_exit_code(void) { return exit_code; }

static uint16_t file_time(int fd, uint16_t *date)
{
  struct stat st; fstat(fd, &st);
  struct tm *t = localtime(&st.st_mtime);
  *date = ((t->tm_year - 80) << 9) | ((t->tm_mon + 1) << 5) | t->tm_mday;
  return (t->tm_hour << 11) | (t->tm_min << 5) | (t->tm_sec / 2);
}

int dos_int21(void)
{
  uint8_t ah = r_ah();
  char name[256], hp[1200];
  switch (ah) {
  case 0x02: putchar(r_dl()); fflush(stdout); return 1;
  case 0x06: if (r_dl() != 0xFF) { putchar(r_dl()); return 1; } s_al(0); set_zf(1); return 1;
  case 0x07: case 0x08: s_al(0x0D); return 1;
  case 0x09: { uint32_t a = lin(r_ds(), r_dx()); for (int i = 0; i < 4096; i++) { char c = rd8(a + i); if (c == '$') break; putchar(c); } fflush(stdout); return 1; }
  case 0x0B: s_al(0); return 1;
  case 0x0C: s_al(0); return 1;
  case 0x0D: return 1;
  case 0x0E: s_al(26); return 1;
  case 0x19: s_al(2); return 1;
  case 0x1A: dta_seg = r_ds(); dta_off = r_dx(); return 1;
  case 0x25: cpu_set_vector(r_al(), r_ds(), r_dx()); LOG("set vector %02X = %04X:%04X\n", r_al(), r_ds(), r_dx()); return 1;
  case 0x2A: { time_t t = time(0); struct tm *m = localtime(&t); s_cx(m->tm_year + 1900); s_dh(m->tm_mon + 1); s_dl(m->tm_mday); s_al(m->tm_wday); return 1; }
  case 0x2C: { struct timespec ts; clock_gettime(CLOCK_REALTIME, &ts); struct tm *m = localtime(&ts.tv_sec);
    s_ch(m->tm_hour); s_cl(m->tm_min); s_dh(m->tm_sec); s_dl(ts.tv_nsec / 10000000); return 1; }
  case 0x2B: case 0x2D: s_al(0); return 1;
  case 0x2F: s_es(dta_seg); s_bx(dta_off); return 1;
  case 0x30: s_ax(0x0005); s_bx(0xFF00); s_cx(0); return 1;
  case 0x33: if (r_al() == 0 || r_al() == 2) s_dl(0); else if (r_al() == 5) s_dl(3); return 1;
  case 0x35: { uint16_t s, o; cpu_get_vector(r_al(), &s, &o); s_es(s); s_bx(o); return 1; }
  case 0x36: s_ax(64); s_bx(0x8000); s_cx(512); s_dx(0xFFFF); return 1;
  case 0x37: s_dl('/'); s_al(0); return 1;
  case 0x38: s_bx(1); ok(); return 1;
  case 0x39: read_str(r_ds(), r_dx(), name, sizeof name); host_path(name, hp, sizeof hp, 0); MKDIR(hp); ok(); return 1;
  case 0x3A: read_str(r_ds(), r_dx(), name, sizeof name); host_path(name, hp, sizeof hp, 0); rmdir(hp); ok(); return 1;
  case 0x3B: {
    read_str(r_ds(), r_dx(), name, sizeof name);
    char rel[512]; dos_canon(name, rel, sizeof rel);
    host_path(name, hp, sizeof hp, 1);
    struct stat st;
    if (stat(hp, &st) || !S_ISDIR(st.st_mode)) { fail(3); return 1; }
    snprintf(cwd, sizeof cwd, "%s", rel); ok(); return 1;
  }
  case 0x3C: case 0x5B: {
    read_str(r_ds(), r_dx(), name, sizeof name);
    host_path(name, hp, sizeof hp, 0);
    int fd = open(hp, O_RDWR | O_CREAT | O_TRUNC | O_BINARY | (ah == 0x5B ? O_EXCL : 0), 0666);
    LOG("create %s -> %d\n", name, fd);
    if (fd < 0) { fail(err_of(errno)); return 1; }
    int h = new_handle(fd); if (h < 0) { close(fd); fail(4); return 1; }
    snprintf(hname[h], sizeof hname[h], "%s", name);
    s_ax(h); ok(); return 1;
  }
  case 0x3D: {
    read_str(r_ds(), r_dx(), name, sizeof name);
    int m = r_al() & 3, fl = m == 0 ? O_RDONLY : m == 1 ? O_WRONLY : O_RDWR;
    if (host_path(name, hp, sizeof hp, 1)) { LOG("open %s: not found\n", name); fail(2); return 1; }
    int fd = open(hp, fl | O_BINARY);
    if (fd < 0 && fl != O_RDONLY) fd = open(hp, O_RDONLY | O_BINARY);  /* read-only data files */
    LOG("open %s (%d) -> %d\n", name, m, fd);
    if (fd < 0) { fail(err_of(errno)); return 1; }
    int h = new_handle(fd); if (h < 0) { close(fd); fail(4); return 1; }
    snprintf(hname[h], sizeof hname[h], "%s", name);
    s_ax(h); ok(); return 1;
  }
  case 0x3E: {
    int h = r_bx();
    if (h >= NHANDLES || hfd[h] == -1) { fail(6); return 1; }
    if (h >= 5) { close(hfd[h]); hfd[h] = -1; }
    ok(); return 1;
  }
  case 0x3F: {
    int h = r_bx(); uint16_t n = r_cx(); uint32_t a = lin(r_ds(), r_dx());
    if (h >= NHANDLES || hfd[h] == -1) { fail(6); return 1; }
    if (h < 5) { s_ax(0); ok(); return 1; }
    uint8_t buf[65536];
    ssize_t got = read(hfd[h], buf, n);
    if (got < 0) { fail(err_of(errno)); return 1; }
    if (a + got <= 0xA0000) memcpy(mem + a, buf, got);
    else for (ssize_t i = 0; i < got; i++) wr8(a + i, buf[i]);
    s_ax(got); ok(); return 1;
  }
  case 0x40: {
    int h = r_bx(); uint16_t n = r_cx(); uint32_t a = lin(r_ds(), r_dx());
    if (h >= NHANDLES || hfd[h] == -1) { fail(6); return 1; }
    uint8_t buf[65536];
    for (int i = 0; i < n; i++) buf[i] = rd8(a + i);
    if (h < 5) { if (h == 1 || h == 2) { fwrite(buf, 1, n, stderr); } s_ax(n); ok(); return 1; }
    if (n == 0) { off_t pos = lseek(hfd[h], 0, SEEK_CUR); if (ftruncate(hfd[h], pos)) {} s_ax(0); ok(); return 1; }
    ssize_t w = write(hfd[h], buf, n);
    if (w < 0) { fail(err_of(errno)); return 1; }
    s_ax(w); ok(); return 1;
  }
  case 0x41: read_str(r_ds(), r_dx(), name, sizeof name); host_path(name, hp, sizeof hp, 0);
    if (unlink(hp)) fail(err_of(errno)); else ok(); return 1;
  case 0x42: {
    int h = r_bx();
    if (h >= NHANDLES || hfd[h] == -1) { fail(6); return 1; }
    if (h < 5) { s_ax(0); s_dx(0); ok(); return 1; }
    int32_t off = (int32_t)((uint32_t)r_cx() << 16 | r_dx());
    off_t r = lseek(hfd[h], off, r_al() == 0 ? SEEK_SET : r_al() == 1 ? SEEK_CUR : SEEK_END);
    if (r < 0) { fail(err_of(errno)); return 1; }
    s_ax(r & 0xFFFF); s_dx(r >> 16); ok(); return 1;
  }
  case 0x43: {
    read_str(r_ds(), r_dx(), name, sizeof name);
    struct stat st;
    if (host_path(name, hp, sizeof hp, 1) || stat(hp, &st)) { fail(2); return 1; }
    if (r_al() == 0) s_cx(S_ISDIR(st.st_mode) ? 0x10 : 0x20);
    ok(); return 1;
  }
  case 0x44: {
    int h = r_bx();
    switch (r_al()) {
    case 0x00:
      if (h >= NHANDLES || hfd[h] == -1) { fail(6); return 1; }
      s_dx(h < 5 ? (h == 0 || h == 1 ? 0x80D3 : 0x80C0) : 0x0002); ok(); return 1;
    case 0x01: ok(); return 1;
    case 0x07: case 0x06: s_al(0xFF); ok(); return 1;
    case 0x08: s_ax(1); ok(); return 1;
    case 0x09: s_dx(0); ok(); return 1;
    }
    fail(1); return 1;
  }
  case 0x45: case 0x46: {
    int h = r_bx();
    if (h >= NHANDLES || hfd[h] == -1) { fail(6); return 1; }
    if (ah == 0x45) {
      int fd = h < 5 ? hfd[h] : dup(hfd[h]);
      int n = new_handle(fd); if (n < 0) { fail(4); return 1; }
      s_ax(n); ok(); return 1;
    }
    int n = r_cx();
    if (n < NHANDLES) { if (n >= 5 && hfd[n] >= 0) close(hfd[n]); hfd[n] = h < 5 ? hfd[h] : dup(hfd[h]); }
    ok(); return 1;
  }
  case 0x47: {
    uint32_t a = lin(r_ds(), r_si()); size_t i;
    for (i = 0; cwd[i]; i++) wr8(a + i, cwd[i] == '/' ? '\\' : toupper((unsigned char)cwd[i]));
    wr8(a + i, 0); ok(); return 1;
  }
  case 0x48: {
    uint16_t seg;
    if (mem_alloc(r_bx(), &seg)) { uint16_t lf = largest_free(); LOG("alloc %04X failed, largest %04X\n", r_bx(), lf); s_bx(lf); fail(8); return 1; }
    LOG("alloc %04X paragraphs -> %04X\n", r_bx(), seg);
    s_ax(seg); ok(); return 1;
  }
  case 0x49: {
    uint16_t s = r_es() - 1;
    if (mcb_type(s) != 'M' && mcb_type(s) != 'Z') { fail(9); return 1; }
    mcb_set(s, mcb_type(s), 0, mcb_size(s)); LOG("free %04X\n", r_es()); ok(); return 1;
  }
  case 0x4A: {
    uint16_t maxp;
    if (mem_resize(r_es(), r_bx(), &maxp)) { LOG("resize %04X to %04X failed (max %04X)\n", r_es(), r_bx(), maxp); s_bx(maxp); fail(8); return 1; }
    LOG("resize %04X to %04X\n", r_es(), r_bx());
    if (r_es() == cur_psp) wr16(lin(cur_psp, 2), cur_psp + r_bx());
    ok(); return 1;
  }
  case 0x4C: case 0x00:
    exit_code = ah == 0 ? 0 : r_al();
    fprintf(stderr, "game exited (%d)\n", exit_code);
    cpu_quit = 1;
    return 1;
  case 0x4D: s_ax(0); ok(); return 1;
  case 0x4E: {
    read_str(r_ds(), r_dx(), name, sizeof name);
    char rel[512], *slash; dos_canon(name, rel, sizeof rel);
    struct find *f = &finds[0];
    for (int i = 0; i < 16; i++) if (!finds[i].used) { f = &finds[i]; break; }
    slash = strrchr(rel, '/');
    if (slash) { *slash = 0; resolve_in(game_root, rel, f->dir, sizeof f->dir); snprintf(f->pat, sizeof f->pat, "%s", slash + 1); }
    else { snprintf(f->dir, sizeof f->dir, "%s", game_root); snprintf(f->pat, sizeof f->pat, "%s", rel); }
    f->pos = 0; f->attr = r_cl(); f->used = 1;
    uint32_t dta = lin(dta_seg, dta_off);
    wr8(dta, (uint8_t)(f - finds));
    if (!find_next(f)) { f->used = 0; LOG("find %s: none\n", name); fail(18); return 1; }
    LOG("find %s\n", name);
    ok(); return 1;
  }
  case 0x4F: {
    uint32_t dta = lin(dta_seg, dta_off);
    struct find *f = &finds[rd8(dta) & 15];
    if (!f->used || !find_next(f)) { f->used = 0; fail(18); return 1; }
    ok(); return 1;
  }
  case 0x50: cur_psp = r_bx(); return 1;
  case 0x51: case 0x62: s_bx(cur_psp); return 1;
  case 0x54: s_al(0); return 1;
  case 0x56: {
    char to[256], hp2[1200];
    read_str(r_ds(), r_dx(), name, sizeof name); read_str(r_es(), r_di(), to, sizeof to);
    host_path(name, hp, sizeof hp, 1); host_path(to, hp2, sizeof hp2, 0);
    if (rename(hp, hp2)) fail(err_of(errno)); else ok(); return 1;
  }
  case 0x57: {
    int h = r_bx();
    if (h < 5 || h >= NHANDLES || hfd[h] < 0) { fail(6); return 1; }
    if (r_al() == 0) { uint16_t d, t = file_time(hfd[h], &d); s_cx(t); s_dx(d); }
    ok(); return 1;
  }
  case 0x58: s_ax(0); ok(); return 1;
  case 0x59: s_ax(last_error); s_bh(1); s_bl(1); s_ch(1); return 1;
  case 0x68: ok(); return 1;
  }
  LOG("int 21h AH=%02X not handled\n", ah);
  fprintf(stderr, "int 21h AX=%04X not handled at %04X:%04X\n", r_ax(), r_cs(), r_ip());
  fail(1);
  return 1;
}

int dos_int2f(void)
{
  /* no XMS, no Windows, no MSCDEX */
  if (r_ax() == 0x1687) return 1;
  if (r_ah() == 0x16 || r_ah() == 0x43 || r_ah() == 0x15) { if (r_ah() != 0x15) s_al(0); return 1; }
  return 1;
}
