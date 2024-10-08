CFLAGS  += -Wall -Wextra -Wpedantic -fopenmp -O3
LDFLAGS += -fopenmp

GRAPH_REPETITIONS ?= 1
GRAPH_MAX_THREADS ?= 16
GRAPH_INPUT ?= "5000 21 289"
GRAPH_RELATIVE ?= false

.PHONY: all clean debug graph

all: ./build/main ./build/main_seq

clean:
	@rm -rf build/

debug: CFLAGS+=-g3 -O0
debug: clean
debug: ./build/main ./build/main_seq

graph: ./build/main ./build/main_seq
	@python ./scripts/make_run_graph.py ./build/main ./build/main_seq $(GRAPH_RELATIVE) $(GRAPH_REPETITIONS) $(GRAPH_MAX_THREADS) $(GRAPH_INPUT)

./build/main: ./build/obj/main.o
	@mkdir -p build
	$(CC) $(LDFLAGS) -o $@ $^

./build/main_seq: ./build/obj/main_seq.o
	@mkdir -p build
	$(CC) $(LDFLAGS) -o $@ $^

./build/obj/%.o: ./src/%.omp.c
	@mkdir -p build
	@mkdir -p build/obj
	$(CC) $(CFLAGS) -c -o $@ $<
