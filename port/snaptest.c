/* snaptest.c: NHL94_SNAPTEST=1. At chunk A a state of the machine is taken, at chunk A+N its hash; then the state is put back and
 * the same N chunks run again: the hash must be the same. NHL94_SNAPTEST_AT (default 3000 chunks) and _N (default 500) change A and
 * N. The log lines start with "snaptest". Run with NHL94_SOUND=none (the sound cards are not part of the state). */
#include "machine.h"
#include "overbar/snap.h"
#include <stdio.h>
#include <stdlib.h>

extern int vtime_free;
static ob_snap_store *store;
static ob_snap snap;
static int on = -1, phase, a = 3000, n = 500;
static long chunk, goal;
static uint64_t h1;

static void say(const char *m, uint64_t x) { printf("snaptest %s %016llx (chunk %ld)\n", m, (unsigned long long)x, chunk); fflush(stdout); }

void snaptest_chunk(void)
{
  if (on < 0) {
    on = getenv("NHL94_SNAPTEST") != NULL;
    if (getenv("NHL94_SNAPTEST_AT")) a = atoi(getenv("NHL94_SNAPTEST_AT"));
    if (getenv("NHL94_SNAPTEST_N")) n = atoi(getenv("NHL94_SNAPTEST_N"));
  }
  if (!on) return;
  chunk++;
  if (phase == 0 && chunk >= a) {
    const ob_snap_region *r;
    char blob[1024];
    int nr = machine_regions(&r);
    size_t bn = machine_blob(blob, sizeof blob);
    if (!store) store = ob_snap_store_new(NULL);
    if (ob_snap_take(store, &snap, r, nr, blob, bn)) { puts("snaptest FAIL take"); on = 0; return; }
    printf("snaptest taken at chunk %ld: %zu bytes, %zu pages (%s)\n", chunk, snap.size, snap.ndiff, ob_snap_stats(store));
    goal = chunk + n; phase = 1;
  } else if (phase == 1 && chunk >= goal) {
    size_t bn;
    const void *b = ob_snap_blob(&snap, &bn);
    h1 = machine_hash(); say("first run", h1);
    if (ob_snap_put(store, &snap)) { puts("snaptest FAIL put"); on = 0; return; }
    machine_unblob(b, bn);
    say("restored", machine_hash());
    chunk = a; goal = a + n; phase = 2; vtime_free = 1;
  } else if (phase == 2 && chunk >= goal) {
    uint64_t h2 = machine_hash();
    say("second run", h2);
    printf("snaptest %s\n", h1 == h2 ? "PASS" : "FAIL (different)");
    fflush(stdout);
    vtime_free = 0; phase = 3; on = 0;
  }
}
