# Makefile for MKP Solver
# Requires GLPK (GNU Linear Programming Kit)
#
# Install GLPK:
#   Ubuntu/Debian: sudo apt-get install libglpk-dev
#   macOS:         brew install glpk
#   Fedora:        sudo dnf install glpk-devel

CC      = gcc
CFLAGS  = -Wall -Wextra -O2 -std=c11
LDFLAGS = -lglpk -lm

TARGET  = mkp
SOURCES = main.c mkp.c
HEADERS = mkp.h
OBJECTS = $(SOURCES:.c=.o)

.PHONY: all clean run test benchmark benchmark-direct benchmark-rohwedder help

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c -o $@ $<

# Run both solvers on built-in examples
run: $(TARGET)
	./$(TARGET)

# Run both solvers on example_input.txt
test: $(TARGET)
	./$(TARGET) example_input.txt

# Benchmark: run both solvers and show timing comparison
benchmark: $(TARGET)
	@echo "=== Internal timing (clock_gettime) ==="
	./$(TARGET) --benchmark example_input.txt
	@echo ""
	@echo "=== GNU time: Direct (Standard) ILP ==="
	/usr/bin/time -v ./$(TARGET) --direct example_input.txt 2>&1 | tail -20
	@echo ""
	@echo "=== GNU time: Rohwedder (Pivot) ILP ==="
	/usr/bin/time -v ./$(TARGET) --rohwedder example_input.txt 2>&1 | tail -20

# Benchmark only the direct solver
benchmark-direct: $(TARGET)
	/usr/bin/time -v ./$(TARGET) --direct example_input.txt

# Benchmark only the Rohwedder solver
benchmark-rohwedder: $(TARGET)
	/usr/bin/time -v ./$(TARGET) --rohwedder example_input.txt

# Show usage
help:
	@echo "Available targets:"
	@echo "  make              Build the mkp solver"
	@echo "  make run          Run built-in examples (both solvers)"
	@echo "  make test         Run on example_input.txt (both solvers)"
	@echo "  make benchmark    Full timing comparison on example_input.txt"
	@echo "  make benchmark-direct     Benchmark direct ILP with GNU time"
	@echo "  make benchmark-rohwedder  Benchmark Rohwedder ILP with GNU time"
	@echo "  make clean        Remove build artifacts"
	@echo ""
	@echo "Manual benchmarking:"
	@echo "  /usr/bin/time -v ./mkp --direct <input_file>"
	@echo "  /usr/bin/time -v ./mkp --rohwedder <input_file>"
	@echo "  ./mkp --benchmark <input_file>"

clean:
	rm -f $(OBJECTS) $(TARGET)
