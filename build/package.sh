#!/bin/bash
# Makes dist/julius-$VERSION.zip (!Julius) from the build in work/.
# Test builds (*test) have the log turned on in !Run.
set -euo pipefail
. "$(dirname "$0")/env.sh"
: "${RISCOS_TOOLCHAIN:=$CROSSDEV/toolchain/env}"
export RISCOS_TOOLCHAIN
. "$CROSSDEV/env.sh"
T="$RISCOS_TOOLCHAIN"
APP="$DIST/!Julius"
rm -rf "$APP" && mkdir -p "$APP/docs" "$APP/C3data"
cp "$ROOT/app/!Julius/!Boot,feb" "$ROOT/app/!Julius/!Help,fff" "$APP/"
cp "$ROOT/app/!Julius/C3data/ReadMe,fff" "$APP/C3data/"
sed 's/^| Set Julius\$LogOn 1$/| Set Julius$LogOn 1/' "$ROOT/app/!Julius/!Run,feb" > "$APP/!Run,feb"
case "$VERSION" in *test) sed -i 's/^| Set Julius\$LogOn 1$/Set Julius$LogOn 1/' "$APP/!Run,feb" ;; esac

# Program: strip, then Absolute (AIF) so !SharedLibs isn't needed.
"$T/bin/arm-riscos-gnueabihf-strip" -o "$WORK/julius.stripped" "$WORK/build-julius/julius"
"$T/bin/elf2aif" -e "$WORK/julius.stripped" "$APP/julius,ff8" >/dev/null

# Icon (Julius's logo at 34x34 and 17x17; made once with ImageMagick and
# riscos-crossdev's package/png2sprite.py).
cp "$ROOT/app/!Julius/!Sprites,ff9" "$APP/"

cp "$T/riscos/PThrTicker,ffa" "$APP/"
cp "$T/riscos/PThreadTicker-Licence,fff" "$APP/docs/"
cp "$WORK/julius/LICENSE.txt" "$APP/docs/COPYING,fff"
cp "$ROOT/CHANGELOG.md" "$APP/docs/RISCOS-Changes,fff"
printf 'Julius %s for RISC OS (Julius %s + patches/julius of riscos-julius)\n' "$VERSION" "${JULIUS_REF#v}" > "$APP/docs/Version,fff"

if strings -a "$APP/julius,ff8" | grep -q "/home/claude\|$ROOT"; then echo "unwanted strings in the program" >&2; exit 1; fi
rm -f "$DIST/julius-$VERSION.zip"
python3 "$CROSSDEV/package/rozip.py" "$DIST/julius-$VERSION.zip" -C "$DIST" '!Julius'
ls -la "$DIST/julius-$VERSION.zip"; md5sum "$DIST/julius-$VERSION.zip" "$APP/julius,ff8"
