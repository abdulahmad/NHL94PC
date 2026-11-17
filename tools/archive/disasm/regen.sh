#!/bin/sh
# regen.sh: regenerate the generated code segments and DGROUP, then re-apply every name list in docs/cleanup/names94_*.txt.
# Only for use before those files are edited by hand.
cd "$(dirname "$0")/../.."
python3 tools/disasm/gen_root.py $(seq -f "seg%03g" 6 55) seg058 >/dev/null || exit 1
python3 tools/disasm/gen_data.py || exit 1
for f in docs/cleanup/names94_*.txt; do python3 tools/rename.py --generated "$f" || exit 1; done
python3 tools/make_stubs.py
