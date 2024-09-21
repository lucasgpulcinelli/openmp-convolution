#include <omp.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool is_perfect_number(int i) {
  int sub_sum = 0;
  for (int j = 1; j < i; j++) {
    if (i % j == 0) {
      sub_sum += j;
    }
  }

  return sub_sum == i;
}

int main(int argc, char **argv) {
  bool should_print_time = false;
  if (argc > 1) {
    should_print_time = strcmp("true", argv[1]) == 0;
  }

  int p = omp_get_num_procs();
  if (argc > 2) {
    p = atoi(argv[2]);
  }

  int n;
  int read = scanf("%d", &n);
  if (read != 1) {
    return -1;
  }

  uint64_t sum = 0;

  double start = omp_get_wtime();

#pragma omp parallel for num_threads(p) schedule(dynamic) shared(n)            \
    reduction(+ : sum)
  for (int i = 1; i < n; i++) {
    if (is_perfect_number(i)) {
      sum += i;
    }
  }

  if (should_print_time) {
    printf("%lf\n", omp_get_wtime() - start);
  }

  printf("%ld\n", sum);
}
