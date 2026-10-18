/*
 * Host test of src/platform/riscos/riscos_present.c (the RISC OS presenter).
 * Includes the presenter's source and drives its internals: random changes
 * to a canvas over many frames; after each frame the shadow must equal the
 * canvas and the surface must equal a straightforward nearest-neighbour
 * scale of the canvas (with red and blue swapped for XBGR surfaces).
 *   tests/present/run.sh
 */
#define PLATFORM_RISCOS_PRESENT
#include "platform/riscos/riscos_present.c"

#include <stdio.h>

static uint32_t rng = 12345;
static uint32_t rnd(void)
{
    rng ^= rng << 13;
    rng ^= rng >> 17;
    rng ^= rng << 5;
    return rng;
}

static int check(SDL_Surface *s, const color_t *canvas, int sw, int sh, int swap)
{
    for (int dy = 0; dy < s->h; dy++) {
        const uint32_t *row = (const uint32_t *) ((const uint8_t *) s->pixels + dy * s->pitch);
        int sy = (int) ((int64_t) dy * sh / s->h);
        for (int dx = 0; dx < s->w; dx++) {
            int sx = (int) ((int64_t) dx * sw / s->w);
            color_t c = canvas[sy * sw + sx];
            uint32_t want = swap ? (((c >> 16) & 0xff) | (c & 0xff00) | ((c & 0xff) << 16)) : c;
            if ((row[dx] & 0xffffff) != (want & 0xffffff)) {
                printf("  surface differs at %d,%d: %08x, want %08x\n", dx, dy, row[dx], want);
                return 0;
            }
        }
    }
    if (memcmp(p.shadow, canvas, (size_t) sw * sh * 4) != 0) {
        printf("  shadow differs from the canvas\n");
        return 0;
    }
    return 1;
}

static void mutate(color_t *canvas, int sw, int sh)
{
    switch (rnd() % 6) {
        case 0: /* nothing */
            break;
        case 1: { /* a few pixels */
            int n = 1 + rnd() % 20;
            while (n--) {
                canvas[(rnd() % sh) * sw + rnd() % sw] = rnd();
            }
            break;
        }
        case 2: case 3: { /* a rectangle */
            int w = 1 + rnd() % (sw / 2), h = 1 + rnd() % (sh / 2);
            int x = rnd() % (sw - w + 1), y = rnd() % (sh - h + 1);
            color_t c = rnd();
            for (int j = y; j < y + h; j++) for (int i = x; i < x + w; i++) canvas[j * sw + i] = c;
            break;
        }
        case 4: /* the last pixel of each row / the last row */
            for (int j = 0; j < sh; j += 1 + rnd() % 37) canvas[j * sw + sw - 1] = rnd();
            for (int i = 0; i < sw; i += 1 + rnd() % 41) canvas[(sh - 1) * sw + i] = rnd();
            break;
        case 5: /* everything (scrolling) */
            if (rnd() % 4 == 0) for (int k = 0; k < sw * sh; k++) canvas[k] = rnd();
            break;
    }
}

static int run(int sw, int sh, int dw, int dh, Uint32 format, int frames)
{
    SDL_Surface *s = SDL_CreateRGBSurfaceWithFormat(0, dw, dh, 32, format);
    color_t *canvas = malloc(sizeof(color_t) * sw * sh);
    for (int k = 0; k < sw * sh; k++) canvas[k] = rnd();
    p.full = 1;
    if (!setup(s, sw, sh)) {
        printf("setup failed\n");
        return 0;
    }
    int swap = p.swap;
    unsigned cells = 0;
    for (int f = 0; f < frames; f++) {
        if (f) mutate(canvas, sw, sh);
        int changed = find_changes(canvas);
        p.full = 0;
        cells += (unsigned) changed;
        if (changed) {
            int n = collect_rects();
            for (int i = 0; i < n; i++) draw_rect(&p.rects[i]);
        }
        if (!check(s, canvas, sw, sh, swap)) {
            printf("FAIL %dx%d -> %dx%d %s frame %d\n", sw, sh, dw, dh, SDL_GetPixelFormatName(format), f);
            return 0;
        }
    }
    /* window -> canvas mapping matches the picture */
    for (int k = 0; k < 1000; k++) {
        int x = rnd() % dw, y = rnd() % dh, cx = x, cy = y;
        riscos_present_window_to_canvas(&cx, &cy);
        if (cx != (int) ((int64_t) x * sw / dw) || cy != (int) ((int64_t) y * sh / dh)) {
            printf("FAIL mapping %d,%d -> %d,%d\n", x, y, cx, cy);
            return 0;
        }
    }
    printf("ok %4dx%-4d -> %4dx%-4d %-22s %d frames, %u cells changed\n", sw, sh, dw, dh,
        SDL_GetPixelFormatName(format), frames, cells);
    free(canvas);
    SDL_FreeSurface(s);
    return 1;
}

int main(void)
{
    setvbuf(stdout, NULL, _IONBF, 0);
    static const struct { int sw, sh, dw, dh; } sizes[] = {
        {1280, 800, 1920, 1200}, {800, 600, 1200, 900}, {640, 480, 800, 600},
        {1920, 1200, 1920, 1200}, {1163, 727, 1920, 1200}, {641, 481, 1001, 777}, {960, 600, 1920, 1200},
    };
    static const Uint32 formats[] = { SDL_PIXELFORMAT_XBGR8888, SDL_PIXELFORMAT_XRGB8888 };
    int ok = 1;
    for (unsigned i = 0; i < sizeof(sizes) / sizeof(sizes[0]); i++) {
        for (unsigned f = 0; f < 2; f++) {
            ok &= run(sizes[i].sw, sizes[i].sh, sizes[i].dw, sizes[i].dh, formats[f], 120);
        }
    }
    printf(ok ? "all passed\n" : "FAILED\n");
    return ok ? 0 : 1;
}
