#!/bin/bash
# benchmark_trials.sh — Run N trials of each solver and compute average
#
# Usage:
#   ./benchmark_trials.sh [input_file] [num_trials]
#
# Examples:
#   ./benchmark_trials.sh example_input.txt 5
#   ./benchmark_trials.sh large_test.txt 10

INPUT=${1:-example_input.txt}
N=${2:-5}

if [ ! -f "$INPUT" ]; then
    echo "Error: Input file '$INPUT' not found."
    exit 1
fi

if [ ! -f "./mkp" ]; then
    echo "Error: ./mkp not found. Run 'make' first."
    exit 1
fi

echo "============================================="
echo "  MKP Solver Benchmark"
echo "  Input: $INPUT"
echo "  Trials per solver: $N"
echo "============================================="
echo ""

# ---- Direct (Standard) ILP ----
echo "=== Direct (Standard) ILP ==="
TOTAL_DIRECT=0
for i in $(seq 1 $N); do
    T=$( { /usr/bin/time -f "%e" ./mkp --direct "$INPUT" > /dev/null; } 2>&1 )
    echo "  Trial $i: ${T}s"
    TOTAL_DIRECT=$(echo "$TOTAL_DIRECT + $T" | bc)
done
AVG_DIRECT=$(echo "scale=6; $TOTAL_DIRECT / $N" | bc)
echo "  ----"
echo "  Average: ${AVG_DIRECT}s"
echo ""

# ---- Rohwedder (Pivot-based) ILP ----
echo "=== Rohwedder (Pivot-based) ILP ==="
TOTAL_ROHWEDDER=0
for i in $(seq 1 $N); do
    T=$( { /usr/bin/time -f "%e" ./mkp --rohwedder "$INPUT" > /dev/null; } 2>&1 )
    echo "  Trial $i: ${T}s"
    TOTAL_ROHWEDDER=$(echo "$TOTAL_ROHWEDDER + $T" | bc)
done
AVG_ROHWEDDER=$(echo "scale=6; $TOTAL_ROHWEDDER / $N" | bc)
echo "  ----"
echo "  Average: ${AVG_ROHWEDDER}s"
echo ""

# ---- Summary ----
echo "============================================="
echo "  SUMMARY"
echo "============================================="
echo "  Direct (Standard) ILP avg:   ${AVG_DIRECT}s"
echo "  Rohwedder (Pivot) ILP avg:   ${AVG_ROHWEDDER}s"

if [ "$(echo "$AVG_ROHWEDDER > 0" | bc)" -eq 1 ] && [ "$(echo "$AVG_DIRECT > 0" | bc)" -eq 1 ]; then
    SPEEDUP=$(echo "scale=2; $AVG_DIRECT / $AVG_ROHWEDDER" | bc)
    echo "  Ratio (Direct / Rohwedder):  ${SPEEDUP}x"
fi
echo "============================================="
