# Changes in the RISC OS port

## 1.8.0-riscos1 (2026-10-18) — first release
The riscos4test program with the log turned off by default.

Julius 1.8.0 for RISC OS 5: Caesar III in the desktop, in a window or
full screen, with sound, music and the films. On a Pi 4 at 1920 x 1200 it
runs at 50-56 frames a second in a city. Built with riscos-crossdev 1.8.2
(UnixLib 5.0.3.3) and riscos-mesa devkit 20.3.5-16 (SDL 2.26); SDL2_mixer
2.6.3. Patches 0001-0005; the test builds below have the details.

## 1.8.0-riscos4test (2026-10-18)
- riscos3test on the Pi 4 (owner): presenting takes 6.6-7 ms a frame at
  1920 x 1200 (was 14) with NEON; in a city a steady 49 frames a second,
  which is the 50 limit. But at times 61-81: over the limit.
- `patches/julius/0005`: SDL_Delay on RISC OS waits until the next tick of
  the centisecond clock, so it can return up to 10 ms early. The frame
  limiter now waits again while 5 ms or more remain, still yielding to the
  desktop (never busy-waiting).

## 1.8.0-riscos3test (2026-10-18)
Faster comparison of each frame with the last one.

- riscos2test on the Pi 4 (owner): 38-46 frames a second at 1920 x 1200
  full screen in a city (was 13), about 50 in the menus. Presenting took
  about 14 ms a frame though only 1-4% of the picture changed: the time
  went in comparing the frame with the last one. UnixLib's memcmp
  compares one byte at a time.
- `patches/julius/0004`: the comparison goes row by row through memory in
  order, 8 pixels at a time, skipping cells already known to have
  changed. On processors with NEON it compares 16 pixels a step (chosen at
  start-up with SDL_HasNEON(); only that one file uses NEON, so machines
  without it still work).
- Tests in `tests/present`: `run.sh` drives the presenter with random
  changes over many frames at several sizes and both pixel orders and
  checks every pixel of the result against a plain scaler (AddressSanitizer
  and UBSan on); `run-neon.sh` checks the NEON comparison against every
  length and offset as ARM code under QEMU. Both were checked to catch
  deliberately broken versions.

## 1.8.0-riscos2test (2026-10-18)
Much faster drawing.

- First Pi 4 test of riscos1test (owner): everything works (menus, a
  career, saving and loading, full screen and window), but only 13 frames
  a second at 1920 x 1200 with the display scale at 150% (78 ms a frame),
  20 at 1200 x 900. Measured on Linux: drawing the city takes 0.7 ms, SDL
  presenting it 18 ms. SDL's software renderer converted and scaled the
  whole frame every frame, and a scale that isn't a whole number with the
  RISC OS screen's XBGR order takes SDL's slowest path.
- `patches/julius/0003`: on RISC OS Julius no longer uses an SDL
  renderer. `src/platform/riscos/riscos_present.c` keeps the last frame,
  finds the 64 x 16 pixel cells that changed and only scales, converts and
  plots those. A full 1920 x 1200 frame takes 1.2 ms on the Linux test
  machine (SDL: 18 ms); a still city under 1 ms. The game's pointer is
  blended in for presenting only. Mouse positions are mapped to the
  game's coordinates (SDL's renderer did that before).
- Scaling is now nearest neighbour: 100% and 200% look exactly like the
  original; at 150% some pixel rows and columns are doubled (before, SDL
  smoothed them).
- With the log on, a "Present:" line every 10 seconds (frames, full
  frames, cells changed, pixels drawn, ms a frame) next to "Frames:".
- Checked on Linux: at 100% the picture is identical to SDL's (0 pixels
  differ); the XBGR order gives exactly the reference with red and blue
  swapped; crossdev checks pass.

## 1.8.0-riscos1test (2026-10-18)
First test build: Julius 1.8.0 for RISC OS 5.

- Built with riscos-crossdev 1.8.2 (toolchain 1.4, UnixLib 5.0.3.3) and
  riscos-mesa devkit 20.3.5-16 (SDL 2.26 with the RISC OS desktop video
  and SharedSoundBuffer sound drivers); SDL2_mixer 2.6.3 with WAV and MP3
  only (Caesar III's music and sounds are WAV).
- `patches/julius/0001`: no execinfo.h backtrace (UnixLib has none).
- `patches/julius/0002`, RISC OS platform support (`src/platform/riscos`):
  - nothing is printed in the desktop: output goes to `Julius$Log`, or
    nowhere;
  - the data folder comes from `Julius$Data` (`!Run` sets it to
    `!Julius.C3data` unless it's already set);
  - a missing data folder is reported in a desktop error box;
  - "North African.sg2" is opened as "North African" with a hard space,
    which is how RISC OS stores a space copied from another system;
  - no file name case correction, as RISC OS ignores case;
  - the game draws its own mouse pointer (the SDL driver has no colour
    pointers);
  - the main loop draws at most `Julius$FPS` frames a second (default 50)
    and gives the rest back to the desktop; without vsync it otherwise
    uses all the processor time;
  - with the log on, a "Frames:" line every 10 seconds (frames a second,
    work per frame, slowest frame) for checking the speed;
  - the C heap goes in a "Julius Heap" dynamic area.
- Not yet run on RISC OS. Checked: crossdev checks (static, stack probes,
  VFPv3, UnixLib ticker), no build paths in the program; the Linux build
  of the same source reaches the first city with Caesar III 1.0.1.0 data.
