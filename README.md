# Julius for RISC OS

A RISC OS 5 port of [Julius](https://github.com/bvschaik/julius), the
open-source version of Caesar III. It runs in the desktop (in a window or
full screen) using riscos-mesa's SDL2.

You need the original Caesar III files (version 1.0.1.0): see
`!Julius.C3data.ReadMe` in the release zip.

- `patches/julius/`: the changes to Julius 1.8.0, one per patch (`series`).
- `app/!Julius/`: `!Run`, `!Boot`, `!Help` and the data folder's ReadMe.
- `build/`: `build.sh` (toolchain, devkit, SDL2_mixer, Julius) and
  `package.sh` (the zip). See [BUILDING.md](BUILDING.md).

Requirements, sound modules and playing: see `app/!Julius/!Help,fff`.

Julius and these patches are under the GNU Affero General Public License
version 3 ([COPYING](COPYING)). Each release carries the exact source.

This port was made with the help of an AI assistant.
