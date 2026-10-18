#!/bin/bash
# Builds the presenter's NEON comparison and its test as ARM Linux code and
# runs it under QEMU (needs gcc-arm-linux-gnueabihf and qemu-user).
#   tests/present/run-neon.sh [JULIUS_TREE]   (default work/julius)
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
TREE=${1:-$HERE/../../work/julius}
OUT=${TMPDIR:-/tmp}/julius-neon-test
arm-linux-gnueabihf-gcc -O2 -static -march=armv7-a -mfpu=neon -mfloat-abi=hard -mno-unaligned-access \
  -DPLATFORM_RISCOS_PRESENT -I"$TREE/src" -I"$HERE/stub" \
  "$HERE/test_neon.c" "$TREE/src/platform/riscos/riscos_present_neon.c" -o "$OUT"
qemu-arm -cpu cortex-a8 "$OUT"
