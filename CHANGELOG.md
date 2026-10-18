# Changes in the RISC OS port

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
