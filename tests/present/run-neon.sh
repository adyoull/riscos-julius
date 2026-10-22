#!/bin/bash
# Builds the presenter's NEON comparison and its test as ARM Linux code and
# runs it on an emulated Cortex-A8. With riscos-crossdev's
# qemu-arm-aligntrap (in its toolchain and container image) unaligned
# accesses in the test's own code stop it, as they would on RISC OS;
# otherwise plain qemu-arm (qemu-user) is used.
# Needs gcc-arm-linux-gnueabihf (and qemu-user without the toolchain's QEMU).
#   tests/present/run-neon.sh [JULIUS_TREE]   (default work/julius)
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../build/env.sh"
TREE=${1:-$WORK/julius}
OUT=${TMPDIR:-/tmp}/julius-neon-test
CFLAGS="-O2 -march=armv7-a -mfpu=neon -mfloat-abi=hard -mno-unaligned-access -DPLATFORM_RISCOS_PRESENT -I$TREE/src -I$HERE/stub"
SRC="$HERE/test_neon.c $TREE/src/platform/riscos/riscos_present_neon.c"
QEMU_AT=${RISCOS_TOOLCHAIN:-$CROSSDEV/toolchain/env}/bin/qemu-arm-aligntrap
if [ -x "$QEMU_AT" ] && [ -f "$CROSSDEV/qemu/aligntrap.sh" ]; then
  arm-linux-gnueabihf-gcc $CFLAGS -no-pie $SRC -o "$OUT"
  echo "(qemu-arm-aligntrap: RISC OS alignment rules)"
  QEMU="$QEMU_AT" "$CROSSDEV/qemu/aligntrap.sh" "$OUT"
else
  arm-linux-gnueabihf-gcc $CFLAGS -static $SRC -o "$OUT"
  echo "(plain qemu-arm: alignment not checked)"
  qemu-arm -cpu cortex-a8 "$OUT"
fi
