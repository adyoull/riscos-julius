# Building

On x86-64 Linux with git, curl, cmake, make, python3 and ImageMagick
(`convert`):

    build/build.sh
    build/package.sh

`build.sh` fetches riscos-crossdev (`CROSSDEV_REF`, default v1.8.2) and
installs its prebuilt toolchain and the riscos-mesa devkit it names,
builds SDL2_mixer 2.6.3 (WAV and MP3 only) into `work/stage`, clones
Julius (`JULIUS_REF`, default v1.8.0) into `work/julius` and applies
`patches/julius/series` with `git am`, then builds and runs riscos-crossdev's
checks. Downloads go in `dl/` (put the tarballs there to build offline).
Versions and checksums are in `build/env.sh`.

`package.sh` makes `dist/julius-$VERSION.zip`: the program stripped and
converted to an Absolute file (`elf2aif -e`), the icon from Julius's logo,
PThreadTicker from the toolchain, the licence and the change log.

## Changing Julius

Edit `work/julius` (branch `riscos`), commit, then `build/build.sh julius`.
Regenerate the patches with

    git -C work/julius format-patch -o ../../patches/julius v1.8.0..riscos

and update `patches/julius/series`.
