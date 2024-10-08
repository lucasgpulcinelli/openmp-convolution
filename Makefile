CFLAGS  += -Wall -Wextra -Wpedantic -fopenmp
LDFLAGS += -fopenmp

ZIPFILE    ?= ../zipfile.zip

GRAPH_REPETITIONS ?= 5
GRAPH_MAX_THREADS ?= 16
GRAPH_INPUT ?= 5000
GRAPH_RELATIVE ?= false

.PHONY: all clean run debug graph

all: ./build/main

clean:
	@rm -rf build/

run: ./build/main
	@./build/main $(ARGS)

debug: CFLAGS+=-g3 -O0
debug: clean
debug: ./build/main

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
