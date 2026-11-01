/* sound.c: where the sound hardware sits on the ISA bus, and the PC speaker and DMA ports. The cards the game supports
 * (its *.BGP drivers: PC speaker, AdLib, Sound Blaster, Roland MT-32) are emulated at port level, so the game's own drivers
 * run unchanged and the card chosen in the game's sound setup (SND.CFG) is the one that plays. The Sound Blaster's address
 * comes from the BLASTER variable (default A220 I7 D1 T3), the MPU-401 at 330h; NHL94_SOUND=none disables all of them. */
#include "sndhost.h"
#include "audio.h"
#include "sound.h"
#include <ctype.h>

static int sb_b = 0x220, mpu_b = 0x330, have_cards;

static int hexopt(const char *env, char key, int def, int base)
{
  const char *p = env;
  while (p && *p) {
    if (toupper((unsigned char)*p) == key && (p == env || p[-1] == ' ')) return (int)strtol(p + 1, 0, base);
    while (*p && *p != ' ') p++;
    while (*p == ' ') p++;
  }
  return def;
}

void sound_init(void)
{
  const char *blaster = getenv("BLASTER"), *none = getenv("NHL94_SOUND");
  audio_init();
  if (none && !strcmp(none, "none")) return;
  if (!blaster) blaster = DEFAULT_BLASTER;
  sb_b = hexopt(blaster, 'A', 0x220, 16);
  int irq = hexopt(blaster, 'I', 7, 10), dma = hexopt(blaster, 'D', 1, 10), type = hexopt(blaster, 'T', 3, 10);
  mpu_b = hexopt(blaster, 'P', 0x330, 16);
  int version = type == 1 ? 0x0105 : type == 2 ? 0x0201 : type >= 6 ? 0x0405 : 0x0302;
  sb_init(sb_b, irq, dma, version);
  mpu_init(mpu_b);
  have_cards = 1;
}

void sound_pump(double now) { (void)now; sb_pump(); audio_pump(); }

int sound_in(uint16_t port, int *v)
{
  if (port < 0x10 || (port >= 0x80 && port <= 0x8F) || (port >= 0xC0 && port <= 0xDF)) { *v = dma_in(port); return 1; }
  if (!have_cards) return 0;
  if (port >= 0x388 && port <= 0x38B) { *v = opl_in(port & 3); return 1; }
  if (port >= sb_b && port < sb_b + 16) {
    unsigned o = port - sb_b;
    *v = (o < 4 || o == 8 || o == 9) ? opl_in(o & 3) : sb_in(port);
    return 1;
  }
  if (port == mpu_b || port == mpu_b + 1) { *v = mpu_in(port); return 1; }
  return 0;
}

int sound_out(uint16_t port, uint8_t v)
{
  if (port < 0x10 || (port >= 0x80 && port <= 0x8F) || (port >= 0xC0 && port <= 0xDF)) { dma_out(port, v); return 1; }
  if (!have_cards) return 0;
  if (port >= 0x388 && port <= 0x38B) { opl_out(port & 3, v); return 1; }
  if (port >= sb_b && port < sb_b + 16) {
    unsigned o = port - sb_b;
    if (o < 4 || o == 8 || o == 9) opl_out(o & 3, v); else sb_out(port, v);
    return 1;
  }
  if (port == mpu_b || port == mpu_b + 1) { mpu_out(port, v); return 1; }
  return 0;
}
