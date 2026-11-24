#!/bin/sh
# verify_all.sh: clean check. Deletes output/ and Extracted/, extracts fresh, builds the whole EXE and the overlays and compares
# them with the retail files, then checks the overlays' SPA labels against src/data/frames.asm (check_spa.py). The last line is
# MATCH or FAIL.
cd "$(dirname "$0")/.."
rm -rf output Extracted
fail=0; mkdir -p output; LOG=output/verify_all.log
./build.sh >$LOG 2>&1
grep -q 'MATCH output/HOCKEY.EXE' $LOG || { echo "TOP:"; tail -15 $LOG; fail=1; }
[ -s output/HOCKEY.EXE ] || { echo "TOP NO BIN"; fail=1; }
python3 tools/check_spa.py || fail=1
[ $fail = 0 ] && echo MATCH || { echo FAIL; exit 1; }
