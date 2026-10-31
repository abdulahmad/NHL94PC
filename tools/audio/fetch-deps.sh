#!/bin/sh
# Download the OPL emulator kms.py renders with into tools/audio/third_party/ (not committed):
#   Nuked-OPL3 (LGPL 2.1+), the same emulator the NHL95PC SDL port uses.
# kms.py also needs the unicorn CPU emulator for Python: pip install unicorn
set -e
cd "$(dirname "$0")"
mkdir -p third_party
cd third_party
[ -d nuked-opl3 ] || git clone -q --depth 1 https://github.com/nukeykt/Nuked-OPL3 nuked-opl3
echo "Nuked-OPL3 is in tools/audio/third_party/nuked-opl3"
