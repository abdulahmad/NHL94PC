#!/bin/sh
# Build the 64-bit Windows program (build/win/hockey94.exe + SDL2.dll) with mingw-w64 from Linux or WSL:
#   sudo apt install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 git
# and SDL2 for MinGW: unpack SDL2-devel-2.x-mingw.tar.gz (github.com/libsdl-org/SDL/releases) next to the repository, or point
# SDL2_MINGW at its x86_64-w64-mingw32 directory. Copy hockey94.exe and SDL2.dll into the game folder (beside HOCKEY.EXE).
set -e
cd "$(dirname "$0")/.."
SDL2_MINGW=${SDL2_MINGW:-$(ls -d SDL2-*/x86_64-w64-mingw32 ../SDL2-*/x86_64-w64-mingw32 2>/dev/null | head -1)}
if [ -z "$SDL2_MINGW" ] || [ ! -d "$SDL2_MINGW/include/SDL2" ]; then
  echo "SDL2 for 64-bit Windows not found: set SDL2_MINGW to the x86_64-w64-mingw32 directory of SDL2-devel-*-mingw" >&2
  exit 1
fi
sh port/fetch-deps.sh
CC=${CC:-x86_64-w64-mingw32-gcc}
CXX=${CXX:-x86_64-w64-mingw32-g++}
AR=${AR:-x86_64-w64-mingw32-ar}
OUT=build/win
mkdir -p $OUT
X=port/third_party/libx86emu
CFLAGS="${CFLAGS:--O2}"
for f in api decode mem ops ops2 prim_ops; do
  $CC $CFLAGS -w -Iport/winshim -I$X/include -c $X/$f.c -o $OUT/x86emu_$f.o
done
MUNT=""
if [ -d port/third_party/munt/mt32emu/src ]; then
  CXX=$CXX AR=$AR sh port/munt-build.sh $OUT/munt "-static"
  MUNT="-DHAVE_MUNT -I$OUT/munt/inc -Iport/third_party/munt/mt32emu/src $OUT/munt/libmt32emu.a"
fi
$CC $CFLAGS -Wall -Wno-misleading-indentation -Wno-format-truncation -I$X -Iport -I"$SDL2_MINGW/include/SDL2" -o $OUT/hockey94.exe \
  port/main.c port/cpu.c port/pc.c port/vga.c port/dos.c port/bios.c port/sound.c port/audio.c port/opl.c port/sb.c port/dma.c \
  port/mpu.c port/speaker.c port/video_gl.c port/third_party/nuked-opl3/opl3.c $OUT/x86emu_*.o $MUNT \
  -L"$SDL2_MINGW/lib" -lmingw32 -lSDL2main -lSDL2 -lopengl32 -static-libgcc -static-libstdc++ \
  -Wl,-Bstatic -lstdc++ -lpthread -Wl,-Bdynamic -lm -mwindows
cp "$SDL2_MINGW/bin/SDL2.dll" $OUT/
echo "built $OUT/hockey94.exe (with SDL2.dll)"
