#!/bin/bash
# Builds Julius for RISC OS: riscos-crossdev toolchain + devkit, SDL2_mixer,
# then Julius with patches/julius applied. Re-runnable.
#   build/build.sh            everything
#   build/build.sh julius     only rebuild Julius (work/julius as it is)
set -euo pipefail
. "$(dirname "$0")/env.sh"
mkdir -p "$DL" "$WORK" "$STAGE"

if [ ! -d "$CROSSDEV" ]; then
  git -c advice.detachedHead=false clone -q --branch "$CROSSDEV_REF" --depth 1 "$CROSSDEV_GIT" "$CROSSDEV"
fi
export RISCOS_TOOLCHAIN="$CROSSDEV/toolchain/env" RISCOS_DEVKIT="$CROSSDEV/devkit/env" DL
[ -x "$RISCOS_TOOLCHAIN/bin/arm-riscos-gnueabihf-gcc" ] || "$CROSSDEV/toolchain/install-prebuilt.sh"
# The devkit named in env.sh (not necessarily crossdev's own).
if [ "$(cat "$RISCOS_DEVKIT/VERSION" 2>/dev/null)" != "$DEVKIT_VERSION" ]; then
  [ -s "$DL/$DEVKIT_TARBALL" ] || curl -fsSL -o "$DL/$DEVKIT_TARBALL" "$DEVKIT_URL"
  echo "$DEVKIT_SHA256  $DL/$DEVKIT_TARBALL" | sha256sum -c --quiet
  rm -rf "$RISCOS_DEVKIT" && mkdir -p "$RISCOS_DEVKIT"
  tar xzf "$DL/$DEVKIT_TARBALL" -C "$RISCOS_DEVKIT" --strip-components=1
  echo "installed $(cat "$RISCOS_DEVKIT/VERSION")"
  rm -rf "$WORK/build-julius" "$STAGE/lib/libSDL2_mixer.a"   # rebuild against it
fi
. "$CROSSDEV/env.sh"
CFLAGS_RO="$RISCOS_CFLAGS -mtune=cortex-a72"

if [ "${1:-}" != julius ]; then
  # --- SDL2_mixer -----------------------------------------------------
  if [ ! -f "$STAGE/lib/libSDL2_mixer.a" ]; then
    [ -s "$DL/$MIXER_TARBALL" ] || curl -fsSL -o "$DL/$MIXER_TARBALL" "$MIXER_URL"
    echo "$MIXER_SHA256  $DL/$MIXER_TARBALL" | sha256sum -c --quiet
    rm -rf "$WORK/SDL2_mixer-2.6.3"
    tar xzf "$DL/$MIXER_TARBALL" -C "$WORK"
    ( cd "$WORK/SDL2_mixer-2.6.3"
      ./configure --host=arm-riscos-gnueabihf --prefix="$STAGE" --disable-shared --enable-static \
        SDL2_CONFIG=/bin/false \
        SDL_CFLAGS="-I$RISCOS_DEVKIT/include/SDL2 -I$RISCOS_DEVKIT/include -D_REENTRANT" \
        SDL_LIBS="-L$RISCOS_DEVKIT/lib -lSDL2" CFLAGS="$CFLAGS_RO" \
        --disable-music-cmd --disable-music-mod --disable-music-midi --disable-music-ogg \
        --disable-music-flac --disable-music-opus --disable-music-mp3-mpg123 \
        --enable-music-wave --enable-music-mp3 --enable-music-mp3-drmp3 --disable-sdltest >/dev/null
      # Only the library: the playwave/playmus examples don't link statically.
      make -j"$JOBS" build/libSDL2_mixer.la >/dev/null )
    mkdir -p "$STAGE/lib" "$STAGE/include/SDL2"
    cp "$WORK/SDL2_mixer-2.6.3/build/.libs/libSDL2_mixer.a" "$STAGE/lib/"
    cp "$WORK/SDL2_mixer-2.6.3/include/SDL_mixer.h" "$STAGE/include/SDL2/"
  fi

  # --- Julius source + patches ----------------------------------------
  if [ ! -d "$WORK/julius" ]; then
    git -c advice.detachedHead=false clone -q --branch "$JULIUS_REF" "$JULIUS_GIT" "$WORK/julius"
    ( cd "$WORK/julius" && git checkout -q -b riscos \
      && git -c user.name="Andrew Youll" -c user.email=adyoull@users.noreply.github.com \
         am -q $(sed "s|^|$ROOT/patches/julius/|" "$ROOT/patches/julius/series") )
  fi
fi

# --- Julius ------------------------------------------------------------
L="$RISCOS_DEVKIT/lib"
cmake -S "$WORK/julius" -B "$WORK/build-julius" -Wno-dev \
  -DCMAKE_TOOLCHAIN_FILE="$CROSSDEV/cmake/riscos.cmake" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS_RELEASE="-O2 -mtune=cortex-a72 -DNDEBUG -ffile-prefix-map=$WORK/julius=julius-1.8.0" \
  -DSYSTEM_LIBS=OFF \
  -DSDL2_INCLUDE_DIR="$RISCOS_DEVKIT/include/SDL2" \
  -DSDL2_LIBRARY="$L/libSDL2.a;$L/libGLU.a;$L/libEGL.a;$L/libOSMesa.a;stdc++;$L/libz.a;m" \
  -DSDL2_MIXER_INCLUDE_DIR="$STAGE/include/SDL2" -DSDL2_MIXER_LIBRARY="$STAGE/lib/libSDL2_mixer.a" >/dev/null
make -C "$WORK/build-julius" -j"$JOBS" julius >"$WORK/julius-build.log" 2>&1 || {
  tail -30 "$WORK/julius-build.log"; exit 1; }
"$CROSSDEV/checks/check-all.sh" "$WORK/build-julius/julius"
if strings -a "$WORK/build-julius/julius" | grep -q "$ROOT"; then
  echo "build paths found in the program" >&2; exit 1
fi
echo "built $WORK/build-julius/julius"
