CFLAGS  += -Wall -Wextra -Wpedantic -fopenmp
LDFLAGS += -fopenmp

EXECUTABLE ?= build/main
ZIPFILE    ?= ../zipfile.zip

CFILES = $(shell find src/ -type f |grep '\.omp.c')
OFILES = $(patsubst src/%.omp.c,build/obj/%.o, $(CFILES))

GRAPH_REPETITIONS ?= 5
GRAPH_MAX_THREADS ?= 16
GRAPH_INPUT ?= 5000

.PHONY: all clean run debug graph

all: $(EXECUTABLE)

clean:
	@rm -rf build/

run: $(EXECUTABLE)
	@./$(EXECUTABLE) $(ARGS)

debug: CFLAGS+=-g3 -O0
debug: clean
debug: $(EXECUTABLE)

graph: $(EXECUTABLE)
	@python ./scripts/make_run_graph.py ./$(EXECUTABLE) $(GRAPH_REPETITIONS) $(GRAPH_MAX_THREADS) $(GRAPH_INPUT)

$(EXECUTABLE): $(OFILES)
	@mkdir -p build
	$(CC) $(LDFLAGS) -o $@ $^

build/obj/%.o: src/%.omp.c src/%.h
	@mkdir -p build
	@mkdir -p build/obj
	$(CC) $(CFLAGS) -c -o $@ $<

build/obj/%.o: src/%.omp.c
	@mkdir -p build
	@mkdir -p build/obj
	$(CC) $(CFLAGS) -c -o $@ $<


