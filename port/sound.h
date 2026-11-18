/* sound.h: the sound hardware the game's drivers (*.BGP) program through I/O ports. */
#ifndef SOUND_H
#define SOUND_H
#include <stdint.h>

int  sound_in(uint16_t port, int *val);   /* 1 when the port belongs to a sound device */
int  sound_out(uint16_t port, uint8_t val);
void sound_init(void);
void sound_pump(double now);              /* run the devices' clocks up to now (DMA, timers, interrupts) */

#endif
