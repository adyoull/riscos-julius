# Source this: . build/env.sh
# Versions and checksums of everything the RISC OS build of Julius uses.
# Each can be overridden from the environment.
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

: "${VERSION:=1.8.0-riscos5test}"
: "${JULIUS_REF:=v1.8.0}"
: "${JULIUS_GIT:=https://github.com/bvschaik/julius.git}"

# riscos-crossdev (kit + prebuilt toolchain) and the riscos-mesa devkit (SDL2).
: "${CROSSDEV_REF:=v1.8.2}"
: "${CROSSDEV_GIT:=https://github.com/adyoull/riscos-crossdev.git}"
: "${TOOLCHAIN_TARBALL:=riscos-crossdev-toolchain-1.4-x86_64-linux.tar.xz}"
: "${DEVKIT_TARBALL:=riscos-mesa-devkit-20.3.5-17.tgz}"
# riscos-crossdev 1.8.2 names devkit 20.3.5-16; this port uses 20.3.5-17
# (icon bar fix for full screen, SDL framebuffer overlay), installed by
# build.sh from dl/ or its release on GitHub.
: "${DEVKIT_URL:=https://github.com/adyoull/riscos-mesa/releases/download/v20.3.5-17/riscos-mesa-devkit-20.3.5-17.tgz}"
: "${DEVKIT_SHA256:=e0bea16a604265cde8d360055d2cb57dc38f4c7442954e599c393acd4c1395b8}"
: "${DEVKIT_VERSION:=riscos-mesa devkit 20.3.5-17}"

# SDL2_mixer: WAV and MP3 (dr_mp3) only. Caesar III's music is WAV.
: "${MIXER_TARBALL:=SDL2_mixer-2.6.3.tar.gz}"
: "${MIXER_URL:=https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.6.3/SDL2_mixer-2.6.3.tar.gz}"
: "${MIXER_SHA256:=7a6ba86a478648ce617e3a5e9277181bc67f7ce9876605eea6affd4a0d6eea8f}"

: "${DL:=$ROOT/dl}"
: "${WORK:=$ROOT/work}"
: "${DIST:=$ROOT/dist}"
: "${CROSSDEV:=$WORK/riscos-crossdev}"
: "${STAGE:=$WORK/stage}"
export ROOT VERSION DL WORK DIST CROSSDEV STAGE
