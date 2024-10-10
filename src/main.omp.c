#include <omp.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
  bool should_print_time = false;
  if (argc > 1) {
    should_print_time = strcmp("true", argv[1]) == 0;
  }

  int p = 8;
  if (argc > 2) {
    p = atoi(argv[2]);
  }

  uint64_t n, m, s;
  if (scanf("%lu %lu %lu", &n, &m, &s) != 3) {
    fprintf(stderr, "invalid number of arguments\n");
    return -1;
  }

  if (m % 2 == 0) {
    fprintf(stderr, "invalid value for m\n");
    return -1;
  }

  srand(s);

  uint8_t *A = calloc((n + m - 1) * (n + m - 1), sizeof(uint8_t));
  uint8_t *B = malloc(m * m * sizeof(uint8_t));

  for (uint64_t i = m / 2; i < n + m / 2; i++) {
    for (uint64_t j = m / 2; j < n + m / 2; j++) {
      A[i * (n + m / 2) + j] = rand();
    }
  }

  for (uint64_t i = 0; i < m; i++) {
    for (uint64_t j = 0; j < m; j++) {
      B[i * m + j] = rand() % 10;
    }
  }

  double start = omp_get_wtime();

  uint16_t max_v = 0, min_v = 2550;

#pragma omp parallel for num_threads(p) reduction(max : max_v)                 \
    reduction(min : min_v)
  for (uint64_t i = m / 2; i < n + m / 2; i++) {
    for (uint64_t j = m / 2; j < n + m / 2; j++) {
      uint16_t sum = 0;
      bool overflowed = false;

      for (uint64_t k = 0; k < m; k++) {
        for (uint64_t l = 0; l < m; l++) {
          sum +=
              A[(i - m / 2 + k) * (n + m / 2) + (j - m / 2 + l)] * B[k * m + l];
          overflowed |= (sum > 2550);
        }
        if (overflowed) {
          break;
        }
      }

      if (overflowed) {
        sum = 2550;
      }

      if (sum > max_v) {
        max_v = sum;
      }
      if (sum < min_v) {
        min_v = sum;
      }
    }
  }

  if (should_print_time) {
    printf("%lf\n", omp_get_wtime() - start);
  }

  printf("%d %d\n", max_v / 10, min_v / 10);
}
