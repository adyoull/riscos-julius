#!/bin/bash
# Builds and runs the presenter test on the host (needs libsdl2-dev), with
# AddressSanitizer and UndefinedBehaviorSanitizer.
#   tests/present/run.sh [JULIUS_TREE]   (default work/julius)
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
TREE=${1:-$HERE/../../work/julius}
OUT=${TMPDIR:-/tmp}/julius-present-test
cc -O1 -g -fsanitize=address,undefined -fno-sanitize-recover=all -std=gnu99 \
  -I"$TREE/src" $(sdl2-config --cflags) "$HERE/test_present.c" -o "$OUT" $(sdl2-config --libs)
ASAN_OPTIONS=detect_leaks=0 "$OUT"
