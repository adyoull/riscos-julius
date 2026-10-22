# Building

On x86-64 Linux with git, curl, cmake, make, python3 and ImageMagick
(`convert`):

    build/build.sh
    build/package.sh

`build.sh`:
- takes riscos-crossdev from its container image when run there (`RCD_DIR`
  set), otherwise clones the release named in `.riscos-deps` into `work/`
  and installs its prebuilt toolchain;
- uses the riscos-mesa devkit named in `.riscos-deps`: `RISCOS_DEVKIT` if
  that is the same version, otherwise it fetches the release into `work/`
  and checks it against `build/SHA256SUMS`;
- builds SDL2_mixer 2.6.3 (WAV and MP3 only) into `work/stage`;
- clones Julius (`JULIUS_REF`, default v1.8.0, checked against
  `JULIUS_COMMIT`) into `work/julius` and applies `patches/julius/series`
  with `git am`;
- builds Julius and runs riscos-crossdev's checks.

Downloads go in `dl/` (put the tarballs there to build offline). The
pinned releases are in `.riscos-deps`, checksums in `build/SHA256SUMS`,
everything else in `build/env.sh`.

Tests (on Linux): `tests/present/run.sh` (needs libsdl2-dev) and
`tests/present/run-neon.sh` (needs gcc-arm-linux-gnueabihf; uses
riscos-crossdev's qemu-arm-aligntrap).

`package.sh` makes `dist/julius-$VERSION.zip`: the program stripped and
converted to an Absolute file (`elf2aif -e`), `!Sprites` (Julius's logo,
kept in `app/`), PThreadTicker from the toolchain, the licence and the
change log.

## Building on GitHub

`.github/workflows/` has riscos-crossdev's two workflows (its `docs/CI.md`):

- **RISC OS build** (`riscos-build.yml`): on every push and pull request,
  in the container image `ghcr.io/adyoull/riscos-crossdev:<version in
  .riscos-deps>`: `build/build.sh`, `build/package.sh` (as `julius-ci.zip`,
  kept as a download on the run's page) and both tests. `dl/` is cached.
- **Dependency updates** (`riscos-deps-update.yml`): every day, if
  riscos-crossdev or riscos-mesa has a newer release than `.riscos-deps`
  names, it moves the pin (`ci/riscos-deps-hook.sh` puts the new devkit's
  checksum in `build/SHA256SUMS`), builds and tests with it, and opens a
  pull request. Nothing is released: merge, test on a Pi, then release.

They need, in the repository's Settings > Actions > General: "Workflow
permissions: Read and write" and "Allow GitHub Actions to create and
approve pull requests".

## Changing Julius

Edit `work/julius` (branch `riscos`), commit, then `build/build.sh julius`.
Regenerate the patches with

    git -C work/julius format-patch -o ../../patches/julius v1.8.0..riscos

and update `patches/julius/series`.
