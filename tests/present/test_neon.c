/*
 * The NEON pixel comparison against a plain loop, as ARM code (QEMU):
 * every length 0..200 at every 4-byte offset, with one differing pixel at
 * every position, and equal buffers.
 *   tests/present/run-neon.sh
 */
#include <stdio.h>
#include <stdint.h>
#include <string.h>

typedef uint32_t color_t;
int riscos_present_pixels_differ_neon(const color_t *a, const color_t *b, int n);

int main(void)
{
    static color_t a[256], b[256];
    for (int i = 0; i < 256; i++) a[i] = b[i] = 0x9e3779b9u * (unsigned) i;
    long checks = 0;
    for (int off = 0; off < 4; off++) {
        for (int n = 0; n <= 200; n++) {
            if (riscos_present_pixels_differ_neon(a + off, b + off, n)) {
                printf("FAIL equal: off %d n %d\n", off, n);
                return 1;
            }
            for (int k = 0; k < n; k++) {
                color_t keep = b[off + k];
                b[off + k] ^= 1u << (k % 32);
                if (!riscos_present_pixels_differ_neon(a + off, b + off, n)) {
                    printf("FAIL missed: off %d n %d pixel %d\n", off, n, k);
                    return 1;
                }
                b[off + k] = keep;
                checks++;
            }
            /* a difference just past the end must not count */
            b[off + n] ^= 1;
            if (riscos_present_pixels_differ_neon(a + off, b + off, n)) {
                printf("FAIL past end: off %d n %d\n", off, n);
                return 1;
            }
            b[off + n] ^= 1;
        }
    }
    printf("NEON compare: %ld checks passed\n", checks);
    return 0;
}
