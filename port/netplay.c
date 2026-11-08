/* netplay.c: online play for NHL 94 PC, rollback through Overbar's ob_net (overbar/net.h).
 *
 * The whole emulated PC is the game's state (machine_state.c). A session starts when both players have a game on (a team on each of two
 * devices the host can feed: keyboard, joystick A or B): the host's machine, as it is then, goes to the guest in the settings, so both
 * start from the same bytes; the CPU then runs in steps of 1/20 s of the PC's virtual time (vtime), and between steps the pad words
 * of ob_net (input.c: input_net_apply) are the only input. A state is a difference to a base copy (overbar/snap.h), taken before each
 * step; a wrong guess loads the state and the steps run again, as fast as the CPU goes. Not yet in it: the sound cards (run with
 * NHL94_SOUND=none), the mouse. */
#include "machine.h"
#include "include/x86emu_int.h"
#include "host.h"
#include "overbar_client.h"
#include "overbar/net.h"
#include "overbar/snap.h"
#include <SDL.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

uint16_t input_net_local(void);
void input_net_apply(uint16_t w0, uint16_t w1);
void input_net(int on);
int input_net_in_game(void);
int input_net_device(int team);
void input_net_set_device(int team, int dev);

#define STEP_S 0.05
#define RB_SLOTS 32
#define MAGIC 0x394E4850u
enum { IDLE, ARMED, CONNECT, PLAY };

static int mode;
static ob_online cfg;
static ob_net *net;
static char why[200];
static double base, t_go;
static uint32_t hi;                                 /* the most steps made: below it a step is a replay */
static ob_snap_store *store;
static ob_snap slot[RB_SLOTS];
static uint32_t slot_gen[RB_SLOTS], gen_c, slot_next;
static uint8_t *settings;
static size_t settings_n;
static int me;                                      /* the pad this machine plays */
static int verbose;
static uint32_t n_rollbacks, n_replayed, n_steps;

typedef struct { uint32_t slot, gen; } blob_t;

/* ---- the machine as bytes (zero runs squeezed): the host's goes to the guest ---- */
static size_t raw_size(void)
{
  const ob_snap_region *r;
  int n = machine_regions(&r), i;
  size_t t = 512;
  for (i = 0; i < n; i++) t += r[i].n;
  return t;
}

static uint8_t *pack(size_t *out_n)
{
  const ob_snap_region *r;
  int n = machine_regions(&r), i;
  size_t raw = raw_size(), at = 0, o = 16, k;
  uint8_t *flat = malloc(raw), *p;
  uint32_t h[4];
  if (!flat) return NULL;
  for (i = 0; i < n; i++) { memcpy(flat + at, r[i].p, r[i].n); at += r[i].n; }
  memset(flat + at, 0, 512);
  machine_blob(flat + at, 512);
  p = malloc(raw + raw / 100 + 64);
  if (!p) { free(flat); return NULL; }
  for (k = 0; k < raw;) {                           /* 0: zero run (u32), 1: literal (u32, bytes) */
    size_t e = k;
    if (flat[k] == 0) { while (e < raw && flat[e] == 0 && e - k < 0x7FFFFFFF) e++; p[o++] = 0; memcpy(p + o, &(uint32_t){(uint32_t)(e - k)}, 4); o += 4; }
    else {
      while (e < raw && (flat[e] != 0 || (e + 8 < raw && (flat[e + 1] != 0 || flat[e + 2] != 0 || flat[e + 3] != 0)))) e++;
      p[o++] = 1; memcpy(p + o, &(uint32_t){(uint32_t)(e - k)}, 4); o += 4; memcpy(p + o, flat + k, e - k); o += e - k;
    }
    k = e;
  }
  h[0] = MAGIC; h[1] = 1; h[2] = (uint32_t)raw; h[3] = (uint32_t)(o - 16);
  memcpy(p, h, 16);
  free(flat);
  *out_n = o;
  return p;
}

static int unpack(const uint8_t *p, size_t n)
{
  const ob_snap_region *r;
  int rn = machine_regions(&r), i;
  uint32_t h[4];
  size_t raw = raw_size(), o = 16, k = 0, at = 0;
  uint8_t *flat;
  if (n < 16) return -1;
  memcpy(h, p, 16);
  if (h[0] != MAGIC || h[1] != 1 || h[2] != raw || h[3] != n - 16) return -1;
  flat = malloc(raw);
  if (!flat) return -1;
  while (o < n && k < raw) {
    uint32_t len;
    if (o + 5 > n) break;
    memcpy(&len, p + o + 1, 4);
    if (k + len > raw) break;
    if (p[o] == 0) { memset(flat + k, 0, len); o += 5; }
    else { if (o + 5 + len > n) break; memcpy(flat + k, p + o + 5, len); o += 5 + len; }
    k += len;
  }
  if (k != raw) { free(flat); return -1; }
  { u64 *msr = cpu->x86.msr; unsigned char *perm = cpu->x86.msr_perm; sel_t *dseg = cpu->x86.default_seg; char *dis = cpu->x86.disasm_ptr;
    for (i = 0; i < rn; i++) { memcpy(r[i].p, flat + at, r[i].n); at += r[i].n; }
    cpu->x86.msr = msr; cpu->x86.msr_perm = perm; cpu->x86.default_seg = dseg; cpu->x86.disasm_ptr = dis;   /* (the host's pointers mean nothing here) */
  }
  machine_unblob(flat + at, 512);
  free(flat);
  return 0;
}

/* ---- ob_net's states ---- */
static size_t st_save(void *user, void *out, size_t cap)
{
  const ob_snap_region *r;
  char b[1024];
  blob_t bl;
  uint32_t s = slot_next % RB_SLOTS;
  int n;
  size_t bn;
  (void)user;
  if (cap < sizeof bl) return sizeof bl;
  n = machine_regions(&r);
  bn = machine_blob(b, sizeof b);
  if (ob_snap_take(store, &slot[s], r, n, b, bn)) return 0;
  slot_next++;
  slot_gen[s] = ++gen_c;
  bl.slot = s; bl.gen = slot_gen[s];
  memcpy(out, &bl, sizeof bl);
  return sizeof bl;
}

static int st_load(void *user, const void *in, size_t size)
{
  blob_t bl;
  const void *b;
  size_t bn;
  (void)user;
  if (size != sizeof bl) return -1;
  memcpy(&bl, in, sizeof bl);
  if (bl.slot >= RB_SLOTS || slot_gen[bl.slot] != bl.gen || !slot[bl.slot].valid) return -1;
  if (ob_snap_put(store, &slot[bl.slot])) return -1;
  b = ob_snap_blob(&slot[bl.slot], &bn);
  machine_unblob(b, bn);
  n_rollbacks++;
  return 0;
}
static const ob_net_states states = { NULL, st_save, st_load };

/* tests: a short hash of each region of the machine, to find which one differs between two machines */
static void region_line(const char *tag, uint32_t step)
{
  const ob_snap_region *r;
  int n = machine_regions(&r), i;
  fprintf(stderr, "rh %s %u:", tag, (unsigned)step);
  for (i = 0; i < n; i++) {
    const uint8_t *q = r[i].p;
    uint32_t h = 2166136261u;
    size_t k;
    for (k = 0; k < r[i].n; k++) { h ^= q[k]; h *= 16777619u; }
    fprintf(stderr, " %u:%04x", i, (unsigned)(h & 0xFFFF));
  }
  fputc('\n', stderr);
}

static void end_net(const char *m)
{
  if (net) {
    if (ob_net_state(net) == OB_NET_ENDED && ob_net_why(net)[0]) snprintf(why, sizeof why, "%s", ob_net_why(net));
    else if (m) snprintf(why, sizeof why, "%s", m);
    if (verbose) fprintf(stderr, "online: session ends: %s\n", why);
    ob_net_free(net);
    net = NULL;
  } else if (m) snprintf(why, sizeof why, "%s", m);
  free(settings); settings = NULL;
  input_net(0);
  vtime_wall_fixed = 0;
  mode = IDLE;
}

/* one step of the PC: the same loop as main.c's, until the step's end in virtual time */
static void run_to(double end)
{
  while (vtime() < end) {
    double wait = 0;
    uint64_t tsc0 = cpu_instr_count();
    int halted;
    vtime_begin_chunk();
    halted = cpu_run(20000);
    if (halted) wait = pit_to_next_tick() + 1e-9;
    pit_advance((double)(cpu_instr_count() - tsc0) / vtime_ips() + wait);
    vtime_end_chunk(wait);
    kbd_pump();
  }
}

static void start_session(void)
{
  char err[160], ident[120];
  ob_net_game g;
  size_t n = 0;
  uint8_t *p = NULL;
  int d0 = input_net_device(0), d1 = input_net_device(1);
  if (getenv("NHL94_NETTEST") && d1 == 0 && d0 == 8) { input_net_set_device(1, 8); d1 = 8; }   /* (tests: the computer team plays too) */
  if (verbose) fprintf(stderr, "online: a game is on, devices %d and %d\n", d0, d1);
  if (!((d0 == 8 || d0 == 2 || d0 == 4) && (d1 == 8 || d1 == 2 || d1 == 4) && (d0 != d1 || getenv("NHL94_NETTEST")))) {
    snprintf(why, sizeof why, "online play needs a person on each team, each on a different device (keyboard, joystick A, joystick B)");
    mode = IDLE;
    return;
  }
  if (cfg.role != 1) { p = pack(&n); if (!p) { snprintf(why, sizeof why, "out of memory"); mode = IDLE; return; } }
  snprintf(ident, sizeof ident, "nhl94pc rollback1 sound none ips %.0f", vtime_ips());
  memset(&g, 0, sizeof g);
  g.identity = ident;
  g.pads = 2;
  g.settings = p;
  g.settings_size = n;
  g.states = &states;
  net = ob_net_new(&cfg, &g, err, sizeof err);
  free(p);
  if (!net) { snprintf(why, sizeof why, "%s", err); mode = IDLE; return; }
  if (getenv("NHL94_NETSIM")) {
    int d = 0, j = 0, l = 0;
    sscanf(getenv("NHL94_NETSIM"), "%d,%d,%d", &d, &j, &l);
    ob_net_simulate(net, d, j, l, 0);
    fprintf(stderr, "online: simulating %d ms delay, %d ms jitter, %d%% loss\n", d, j, l);
  }
  why[0] = 0;
  mode = CONNECT;
}

static void go(void)
{
  size_t n = 0;
  const void *s = ob_net_settings(net, &n);
  if (!s || unpack(s, n)) { ob_net_quit(net); end_net("the host's machine is not this build's"); return; }
  me = (ob_net_my_pads(net) & 1) ? 0 : 1;
  vtime_wall_fixed = 1;
  input_net(1);
  base = vtime();
  t_go = host_time();
  hi = 0; slot_next = 0; n_rollbacks = n_replayed = n_steps = 0;
  memset(slot_gen, 0, sizeof slot_gen);
  if (store) ob_snap_store_free(store);
  store = ob_snap_store_new(NULL);
  mode = PLAY;
  if (getenv("NHL94_REGIONS")) region_line("go", 0);
  if (verbose) fprintf(stderr, "online: go, I play pad %d\n", me);
}

/* returns 1 when the session has the CPU; *idle: nothing ran (sleep a little) */
int netplay_frame(double now, int *idle)
{
  uint16_t local, all[OB_NET_MAX_PADS];
  uint32_t cnt;
  int r;
  *idle = 0;
  if (mode == IDLE) return 0;
  if (mode == ARMED) {
    if (!input_net_in_game()) return 0;
    start_session();
    if (mode != CONNECT) return 0;
  }
  if (mode == CONNECT) {
    int st = ob_net_poll(net);
    *idle = 1;
    if (st == OB_NET_ENDED) { end_net("the session did not start"); return 0; }
    if (st == OB_NET_GO) go();
    return 1;
  }
  if (ob_net_poll(net) == OB_NET_ENDED) { end_net(NULL); return 0; }
  cnt = ob_net_step_count(net);
  if (cnt >= hi && (now - t_go) < (double)hi * STEP_S) { *idle = 1; return 1; }   /* (a new step waits for its time) */
  local = input_net_local();
  if (getenv("NHL94_AUTOPAD")) {                    /* tests: a pattern of moves and buttons, different on each machine */
    unsigned t = (unsigned)((now - t_go) * 4) + (unsigned)me * 5;
    local = (uint16_t)(1u << (t % 4)) | ((t % 7) == 0 ? 16 : 0) | ((t % 11) == 0 ? 32 : 0);
  }
  r = ob_net_frame(net, 1, &local, all);
  if (r < 0) { end_net(NULL); return 0; }
  if (r == OB_NET_WAIT) { *idle = 1; return 1; }
  if (r == OB_NET_RESTART) return 1;
  cnt = ob_net_step_count(net);                     /* the step to run is cnt - 1 */
  input_net_apply(all[0], all[1]);
  run_to(base + cnt * STEP_S);
  if (cnt > hi) hi = cnt; else n_replayed++;
  n_steps++;
  if (getenv("NHL94_REGIONS") && (cnt <= 42 || cnt % 40 == 0)) region_line("step", cnt);
  if (cnt % 40 == 0) ob_net_check(net, cnt - 1, machine_hash());
  if (verbose && cnt % 200 == 0 && cnt >= hi) {
    char line[200];
    ob_net_status(net, line, sizeof line);
    fprintf(stderr, "rollback: step %u, %u rollbacks, %u steps replayed; %s; %s\n", (unsigned)cnt, n_rollbacks, n_replayed, line, ob_snap_stats(store));
  }
  return 1;
}

/* ---- the Online page ---- */
static void ini_path(char *out, size_t n)
{
  char *b = SDL_GetBasePath();
  snprintf(out, n, "%shockey-online.ini", b ? b : "");
  SDL_free(b);
}

static void ini_save(const ob_online *o)
{
  char path[1024];
  FILE *f;
  ini_path(path, sizeof path);
  f = fopen(path, "w");
  if (!f) return;
  fprintf(f, "; NHL Hockey 94 (SDL2 port): the Online page's last settings. role: 0 host, 1 join, 2 both connect\n");
  fprintf(f, "name=%s\nrole=%d\naddress=%s\nport=%d\ndelay=%d\n", o->name, o->role, o->addr, o->port, o->delay);
  fclose(f);
}

static void ini_load(ob_online *o)
{
  char path[1024], line[256];
  FILE *f;
  ini_path(path, sizeof path);
  f = fopen(path, "r");
  if (!f) return;
  while (fgets(line, sizeof line, f)) {
    char *v = strchr(line, '='), *e;
    if (!v || line[0] == ';') continue;
    *v++ = 0;
    for (e = v + strlen(v); e > v && (e[-1] == '\n' || e[-1] == '\r' || e[-1] == ' '); ) *--e = 0;
    if (!strcmp(line, "name")) snprintf(o->name, sizeof o->name, "%s", v);
    else if (!strcmp(line, "role")) o->role = atoi(v) >= 0 && atoi(v) <= 2 ? atoi(v) : 0;
    else if (!strcmp(line, "address")) snprintf(o->addr, sizeof o->addr, "%s", v);
    else if (!strcmp(line, "port")) o->port = atoi(v) > 0 && atoi(v) < 65536 ? atoi(v) : OB_NET_PORT_DEFAULT;
    else if (!strcmp(line, "delay")) o->delay = atoi(v) < 0 ? 0 : atoi(v) > 10 ? 10 : atoi(v);
  }
  fclose(f);
}

static int online_start(const ob_online *o, char *msg, int msg_size)
{
  if (mode != IDLE) { snprintf(msg, (size_t)msg_size, "a session is on: Leave it first"); return -1; }
  cfg = *o;
  cfg.here = 1;
  cfg.all = 2;
  ini_save(o);
  why[0] = 0;
  mode = ARMED;
  return 0;
}

static void online_leave(void)
{
  if (net) { ob_net_quit(net); end_net("you left"); }
  else { mode = IDLE; snprintf(why, sizeof why, "you left"); }
}

static int online_status(char *line, int size)
{
  line[0] = 0;
  if (net) {
    ob_net_status(net, line, size);
    return ob_net_state(net) != OB_NET_ENDED;
  }
  if (mode == ARMED) {
    snprintf(line, (size_t)size, "%s%sboth players: start a game, a person on each team, on different devices", why[0] ? why : "", why[0] ? "; " : "");
    return 1;
  }
  snprintf(line, (size_t)size, "%s", why);
  return 0;
}

static const char *online_lan(char *buf, int size)
{
  const char *a = ob_net_lan_address(buf, size);
  return a && a[0] ? a : NULL;
}

void netplay_online_setup(ob_host *h)
{
  ob_online_ops ops;
  verbose = getenv("NHL94_ONLINE") != NULL;
  memset(&ops, 0, sizeof ops);
  ops.max_pads = 2;
  ops.max_delay = 10;
  ops.roles = 3;
  ops.start = online_start;
  ops.leave = online_leave;
  ops.status = online_status;
  ops.lan_address = online_lan;
  ini_load(&h->online);
  h->online.here = 1;
  h->online.all = 2;
  ob_online_set_ops(h, &ops);
  if (getenv("NHL94_ONLINE")) {                     /* tests: NHL94_ONLINE=host|join[:addr], NHL94_PORT, NHL94_DELAY */
    const char *e = getenv("NHL94_ONLINE");
    ob_online o = h->online;
    snprintf(o.name, sizeof o.name, "%s", strncmp(e, "host", 4) ? "joiner" : "host");
    o.role = strncmp(e, "host", 4) ? 1 : 0;
    snprintf(o.addr, sizeof o.addr, "%s", strchr(e, ':') ? strchr(e, ':') + 1 : "127.0.0.1");
    o.port = getenv("NHL94_PORT") ? atoi(getenv("NHL94_PORT")) : OB_NET_PORT_DEFAULT;
    o.delay = getenv("NHL94_DELAY") ? atoi(getenv("NHL94_DELAY")) : 2;
    { char msg[100]; online_start(&o, msg, sizeof msg); }
  }
}
