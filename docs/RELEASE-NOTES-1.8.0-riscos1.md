# Julius 1.8.0-riscos1 for RISC OS

The first release of Julius for RISC OS. Julius is an open-source version
of Caesar III, the Roman city-building game by Impressions Games (1998):
the same game and the same saved games, with some improvements such as any
window size and wider screens.

## What you need
- RISC OS 5 on an ARMv7 machine with VFP (Raspberry Pi 2 or later and
  similar). A Pi 4 is recommended.
- **The original Caesar III files**, version 1.0.1.0 (the GOG and Steam
  versions are; so is the later Sierra CD). They aren't included.
  `!Julius.C3data.ReadMe` says what to copy, including how to get the
  files off the CD.
- ARMEABISupport and SharedUnixLibrary 1.16 or later (from !PackMan).
- For sound: SharedSoundBuffer and StreamManager, in ssb.zip on the
  RDPClient page: https://orac.co.uk/software/rdpclient/rdpclient.html
  (John Duffell's own site, now on the Internet Archive, has more details:
  https://web.archive.org/web/20110920080106/http://www.duffell.riscos.me.uk/).
  SharedSound is part of RISC OS. Without them the game is silent.

## What the RISC OS port does
- Runs in the desktop: in a window or full screen (a window covering the
  screen, so other programs keep running). F6 or Alt-Enter switch.
- Draws only what changed on the screen each frame, converted and scaled
  by the port itself (with NEON where the processor has it). On a Pi 4 at
  1920 x 1200 it runs at 50-56 frames a second in a city; SDL's own
  renderer managed 13.
- Draws at most 50 frames a second (`Julius$FPS` in `!Run`) and gives the
  rest of the time to the desktop.
- Saved games and settings are kept with the game files (`C3data`, or
  wherever `Julius$Data` points).
- A log can be turned on in `!Run` for reporting problems.

## Known limits
- Display scales other than 100% and 200% double some rows and columns of
  pixels (no smoothing).
- Keep the game files on the SD card or hard disc: from a network share
  loading is slow.

## Files
- `julius-1.8.0-riscos1.zip`: the `!Julius` application.
- `julius-1.8.0-source.tar.gz`: Julius 1.8.0 (AGPL-3.0).
- `riscos-julius-1.8.0-riscos1-source.tar.gz`: the RISC OS patches, build
  scripts and application files (this repository at the tag).
- `SDL2_mixer-2.6.3.tar.gz`: SDL2_mixer as used (zlib licence).
- `SHA256SUMS.txt`.

Julius and the RISC OS changes are free software under the GNU Affero
General Public License version 3. Caesar III is (c) Activision; its files
are not part of this release.

Problems: https://github.com/adyoull/riscos-julius/issues
