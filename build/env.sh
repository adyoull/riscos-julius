# Source this: . build/env.sh
# What the RISC OS build of Julius uses. The riscos-crossdev and riscos-mesa
# releases come from .riscos-deps; checksums of downloads from
# build/SHA256SUMS. Each setting can be overridden from the environment.
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

: "${VERSION:=1.8.0-riscos5test}"
: "${JULIUS_REF:=v1.8.0}"
: "${JULIUS_COMMIT:=127b5ddb4a80d6fc6b11b19fe8d8c22db2459c78}"
: "${JULIUS_GIT:=https://github.com/bvschaik/julius.git}"

_dep() { awk -v n="$1" '$1 == n || $1 == "adyoull/" n {print $2}' "$ROOT/.riscos-deps"; }
_sum() { awk -v f="$1" '$2 == f {print $1}' "$ROOT/build/SHA256SUMS"; }

# riscos-crossdev: the kit (checks, cmake, packaging tools) and its prebuilt
# toolchain. In its container image (RCD_DIR set) the image's own is used.
: "${CROSSDEV_REF:=$(_dep riscos-crossdev)}"
: "${CROSSDEV_GIT:=https://github.com/adyoull/riscos-crossdev.git}"

# riscos-mesa's devkit (SDL2, EGL): the release in .riscos-deps, used from
# RISCOS_DEVKIT if that is the same version, else fetched into work/.
: "${MESA_TAG:=$(_dep riscos-mesa)}"
MESA_VERSION=${MESA_TAG#v}
: "${DEVKIT_TARBALL:=riscos-mesa-devkit-$MESA_VERSION.tgz}"
: "${DEVKIT_URL:=https://github.com/adyoull/riscos-mesa/releases/download/$MESA_TAG/$DEVKIT_TARBALL}"
: "${DEVKIT_SHA256:=$(_sum "$DEVKIT_TARBALL")}"
: "${DEVKIT_VERSION:=riscos-mesa devkit $MESA_VERSION}"

# SDL2_mixer: WAV and MP3 (dr_mp3) only. Caesar III's music is WAV.
: "${MIXER_TARBALL:=SDL2_mixer-2.6.3.tar.gz}"
: "${MIXER_URL:=https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.6.3/SDL2_mixer-2.6.3.tar.gz}"
: "${MIXER_SHA256:=$(_sum "$MIXER_TARBALL")}"

: "${DL:=$ROOT/dl}"
: "${WORK:=$ROOT/work}"
: "${DIST:=$ROOT/dist}"
: "${STAGE:=$WORK/stage}"
if [ -z "${CROSSDEV:-}" ]; then
  if [ -n "${RCD_DIR:-}" ] && [ -f "$RCD_DIR/env.sh" ]; then
    CROSSDEV=$RCD_DIR
  else
    CROSSDEV=$WORK/riscos-crossdev
  fi
fi
export ROOT VERSION DL WORK DIST CROSSDEV STAGE MESA_VERSION
