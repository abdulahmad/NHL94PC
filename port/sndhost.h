/* sndhost.h: what the sound devices taken from the NHL 95 PC port (audio.c, opl.c, sb.c, dma.c, mpu.c, speaker.c) need from
 * the host. They run on the main thread (port reads and writes) and on SDL's audio thread (rendering). */
#ifndef SNDHOST_H
#define SNDHOST_H
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "machine.h"

extern int trace;
#define trace_on trace
#define TRACE(...) do { if (trace) fprintf(stderr, __VA_ARGS__); } while (0)
static inline int64_t plat_now_ns(void) { return (int64_t)(host_time() * 1e9); }
void irq_raise(int irq);                  /* any thread */
void video_set_title(const char *title);
extern volatile int intro_skip;
#endif
