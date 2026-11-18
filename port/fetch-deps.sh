#!/bin/sh
# Download the third-party code the port builds with into port/third_party (not committed):
#   libx86emu (SciTech/SUSE licence, permissive): the x86 CPU core that runs the game's 16-bit code
#   Nuked-OPL3 (LGPL 2.1+): the Yamaha OPL2/OPL3 chip of the AdLib and Sound Blaster
#   Munt libmt32emu (LGPL 2.1+): the Roland MT-32 (needs your MT32_CONTROL.ROM and MT32_PCM.ROM at run time)
set -e
cd "$(dirname "$0")"
mkdir -p third_party
cd third_party
if [ ! -d libx86emu ]; then
  git clone -q https://github.com/wfeldt/libx86emu libx86emu
  git -C libx86emu checkout -q ce81129c57fdfbf690bebc210a8db97d926cc5e7
fi
[ -d nuked-opl3 ] || GIT_LFS_SKIP_SMUDGE=1 git clone -q --depth 1 https://github.com/nukeykt/Nuked-OPL3 nuked-opl3
[ -n "$NHL94_NO_MUNT" ] || [ -d munt ] || GIT_LFS_SKIP_SMUDGE=1 git clone -q --depth 1 https://github.com/munt/munt munt
echo "dependencies are in port/third_party"
