#!/bin/sh
# Build the SDL2 port for this machine (Linux; macOS should work the same way): build/hockey94.
# Needs a C compiler, git and the SDL2 development files (apt install gcc libsdl2-dev). src/ is not used: the game's
# own HOCKEY.EXE, overlays and data run on the built-in CPU, so the byte-exact build stays as it is.
cd "$(dirname "$0")/.." || exit 1
sh port/fetch-deps.sh || exit 1
mkdir -p build
X=port/third_party/libx86emu
CFLAGS="${CFLAGS:--O2 -g}"
# Munt (the MT-32 emulator, LGPL) as a static library when it was fetched; its ROMs are not included
MUNT=""
if [ -d port/third_party/munt/mt32emu/src ]; then
  sh port/munt-build.sh build/munt "" || exit 1
  MUNT="-DHAVE_MUNT -Ibuild/munt/inc -Iport/third_party/munt/mt32emu/src build/munt/libmt32emu.a -lstdc++ -lpthread"
fi
gcc $CFLAGS -w -I$X/include -c $X/api.c -o build/x86emu_api.o &&
gcc $CFLAGS -w -I$X/include -c $X/decode.c -o build/x86emu_decode.o &&
gcc $CFLAGS -w -I$X/include -c $X/mem.c -o build/x86emu_mem.o &&
gcc $CFLAGS -w -I$X/include -c $X/ops.c -o build/x86emu_ops.o &&
gcc $CFLAGS -w -I$X/include -c $X/ops2.c -o build/x86emu_ops2.o &&
gcc $CFLAGS -w -I$X/include -c $X/prim_ops.c -o build/x86emu_prim_ops.o || exit 1
gcc $CFLAGS -Wall -Wno-misleading-indentation -Wno-format-truncation -I$X -Iport -o build/hockey94 port/main.c port/cpu.c port/pc.c port/vga.c \
  port/dos.c port/bios.c port/sound.c port/audio.c port/opl.c port/sb.c port/dma.c port/mpu.c port/speaker.c \
  port/video_gl.c port/third_party/nuked-opl3/opl3.c build/x86emu_*.o $MUNT $(pkg-config --cflags --libs sdl2) -lGL -lm || exit 1
echo "built build/hockey94"
