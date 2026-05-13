# Benchmarking Manual: Measuring Running Time of MKP Solvers on Ubuntu

This manual explains how to compile and benchmark both MKP solvers (Standard Assignment ILP vs. Rohwedder's Configuration ILP) on Ubuntu using GNU tools.

---

## 1. Prerequisites

### 1.1 Install required packages

```bash
sudo apt-get update
sudo apt-get install -y build-essential libglpk-dev time
```

- `build-essential` — GCC compiler, make, etc.
- `libglpk-dev` — GLPK (GNU Linear Programming Kit) for ILP solving
- `time` — GNU time (provides detailed resource measurements)

### 1.2 Verify GNU time is available

```bash
/usr/bin/time --version
```

> **Important:** The shell built-in `time` (what you get by typing just `time`) gives minimal output.
> Always use `/usr/bin/time` (or `\time`) for detailed measurements.

---

## 2. Building the Solver

```bash
cd masterprojekt_Culcu_mkp
make clean
make
```

This produces the `./mkp` executable.

---

## 3. Command-Line Options

The solver supports the following modes:

| Command | Description |
|---------|-------------|
| `./mkp` | Run built-in examples with both solvers |
| `./mkp <file>` | Solve from input file with both solvers |
| `./mkp --direct <file>` | Solve with **Standard (Direct) ILP** only |
| `./mkp --rohwedder <file>` | Solve with **Rohwedder (Pivot-based) ILP** only |
| `./mkp --benchmark <file>` | Run both solvers and print internal timing comparison |
| `./mkp --large` | Run larger built-in example |
| `./mkp --help` | Show usage help |

---

## 4. Benchmarking Methods

### Method 1: Built-in Timing (Recommended for Quick Comparison)

The program measures wall-clock time internally using `clock_gettime(CLOCK_MONOTONIC)`:

```bash
./mkp --benchmark example_input.txt
```

This runs both solvers on the same instance and prints a timing comparison:

```
========================================
  TIMING COMPARISON
========================================
  Direct (Standard) ILP:   0.001234 s
  Rohwedder (Pivot) ILP:   0.005678 s
  Speedup (Direct/Rohwedder): 0.22x
========================================
```

### Method 2: GNU time (Detailed Resource Usage)

Use `/usr/bin/time -v` for detailed statistics including CPU time, memory, and more:

**Benchmark the Direct (Standard) ILP:**
```bash
/usr/bin/time -v ./mkp --direct example_input.txt
```

**Benchmark the Rohwedder (Pivot-based) ILP:**
```bash
/usr/bin/time -v ./mkp --rohwedder example_input.txt
```

GNU time output includes:
- `Elapsed (wall clock) time` — total real time
- `User time` — CPU time in user mode
- `System time` — CPU time in kernel mode
- `Maximum resident set size` — peak memory usage (KB)
- `Voluntary context switches` — I/O waits
- etc.

### Method 3: Makefile Targets

```bash
# Full benchmark with GNU time for both solvers:
make benchmark

# Benchmark only the direct solver:
make benchmark-direct

# Benchmark only the Rohwedder solver:
make benchmark-rohwedder
```

### Method 4: Shell `time` (Simple)

For a quick wall-clock and CPU time measurement:

```bash
time ./mkp --direct example_input.txt
time ./mkp --rohwedder example_input.txt
```

This gives:
```
real    0m0.005s
user    0m0.003s
sys     0m0.001s
```

---

## 5. Comparing Both Solvers: Step-by-Step

### Step 1: Prepare your input file

Use the provided `example_input.txt` or create your own:

```
3 4
3 4 5
5 7 3
2 3 8
10 15 8 12
```

Format:
```
d m
w_1 p_1 n_1
w_2 p_2 n_2
...
w_d p_d n_d
C_1 C_2 ... C_m
```

### Step 2: Run the built-in benchmark

```bash
./mkp --benchmark example_input.txt
```

### Step 3: Run with GNU time for detailed statistics

```bash
echo "=== DIRECT (Standard) ILP ==="
/usr/bin/time -v ./mkp --direct example_input.txt 2> direct_time.txt
cat direct_time.txt

echo ""
echo "=== ROHWEDDER (Pivot-based) ILP ==="
/usr/bin/time -v ./mkp --rohwedder example_input.txt 2> rohwedder_time.txt
cat rohwedder_time.txt
```

### Step 4: Compare the results

```bash
echo "=== TIMING SUMMARY ==="
echo "Direct ILP:"
grep "wall clock" direct_time.txt
grep "Maximum resident" direct_time.txt

echo ""
echo "Rohwedder ILP:"
grep "wall clock" rohwedder_time.txt
grep "Maximum resident" rohwedder_time.txt
```

---

## 6. Running Multiple Trials

For reliable measurements, run each solver multiple times and average:

```bash
#!/bin/bash
# benchmark_trials.sh — Run N trials and compute average
INPUT=${1:-example_input.txt}
N=${2:-5}

echo "Benchmarking $INPUT with $N trials each..."
echo ""

# Direct ILP
echo "=== Direct (Standard) ILP ==="
TOTAL_DIRECT=0
for i in $(seq 1 $N); do
    T=$( { /usr/bin/time -f "%e" ./mkp --direct "$INPUT" > /dev/null; } 2>&1 )
    echo "  Trial $i: ${T}s"
    TOTAL_DIRECT=$(echo "$TOTAL_DIRECT + $T" | bc)
done
AVG_DIRECT=$(echo "scale=6; $TOTAL_DIRECT / $N" | bc)
echo "  Average: ${AVG_DIRECT}s"
echo ""

# Rohwedder ILP
echo "=== Rohwedder (Pivot-based) ILP ==="
TOTAL_ROHWEDDER=0
for i in $(seq 1 $N); do
    T=$( { /usr/bin/time -f "%e" ./mkp --rohwedder "$INPUT" > /dev/null; } 2>&1 )
    echo "  Trial $i: ${T}s"
    TOTAL_ROHWEDDER=$(echo "$TOTAL_ROHWEDDER + $T" | bc)
done
AVG_ROHWEDDER=$(echo "scale=6; $TOTAL_ROHWEDDER / $N" | bc)
echo "  Average: ${AVG_ROHWEDDER}s"
echo ""

echo "=== SUMMARY ==="
echo "Direct (Standard) ILP avg:   ${AVG_DIRECT}s"
echo "Rohwedder (Pivot) ILP avg:   ${AVG_ROHWEDDER}s"
```

Save this as `benchmark_trials.sh` and run:

```bash
chmod +x benchmark_trials.sh
./benchmark_trials.sh example_input.txt 10
```

---

## 7. Creating Larger Test Instances

To see meaningful timing differences, create larger instances. For example, create a file `large_test.txt`:

```
5 20
3 4 50
5 7 30
2 3 80
7 10 20
4 6 40
100 100 100 100 100
100 100 100 100 100
100 100 100 100 100
100 100 100 100 100
```

Then benchmark:

```bash
./mkp --benchmark large_test.txt
```

### Generating random instances

```bash
#!/bin/bash
# generate_instance.sh — Generate a random MKP instance
D=${1:-5}   # item types
M=${2:-10}  # knapsacks

echo "$D $M"
for i in $(seq 1 $D); do
    W=$((RANDOM % 10 + 1))        # weight 1-10
    P=$((RANDOM % 20 + 1))        # profit 1-20
    N=$((RANDOM % 50 + 1))        # multiplicity 1-50
    echo "$W $P $N"
done
for j in $(seq 1 $M); do
    printf "%d " $((RANDOM % 100 + 10))  # capacity 10-109
done
echo ""
```

Usage:

```bash
chmod +x generate_instance.sh
./generate_instance.sh 5 20 > random_test.txt
./mkp --benchmark random_test.txt
```

---

## 8. Suppressing GLPK Output

GLPK prints solver progress to stdout. To measure timing without noise, redirect stdout:

```bash
# Timing only (suppress solver output):
/usr/bin/time -v ./mkp --direct example_input.txt > /dev/null 2> direct_time.txt
/usr/bin/time -v ./mkp --rohwedder example_input.txt > /dev/null 2> rohwedder_time.txt
```

> **Note:** GNU time output goes to stderr (`2>`), while the solver output goes to stdout (`>`).
> When using `/usr/bin/time -v`, the timing statistics appear on stderr mixed with any error output.
> To separate them cleanly:

```bash
{ /usr/bin/time -v ./mkp --direct example_input.txt > /dev/null; } 2> direct_time.txt
```

---

## 9. Quick Reference

| What you want | Command |
|---------------|---------|
| Quick comparison | `./mkp --benchmark example_input.txt` |
| Direct ILP only | `./mkp --direct example_input.txt` |
| Rohwedder ILP only | `./mkp --rohwedder example_input.txt` |
| GNU time (detailed) — Direct | `/usr/bin/time -v ./mkp --direct example_input.txt` |
| GNU time (detailed) — Rohwedder | `/usr/bin/time -v ./mkp --rohwedder example_input.txt` |
| Wall-clock only | `time ./mkp --direct example_input.txt` |
| Makefile targets | `make benchmark` / `make benchmark-direct` / `make benchmark-rohwedder` |
| Multiple trials | `./benchmark_trials.sh example_input.txt 10` |

---

## 10. Interpreting Results

### What to compare

| Metric | Source | Meaning |
|--------|--------|---------|
| Internal wall-clock | `--benchmark` output | Time for solver phase only (no I/O overhead) |
| GNU time `Elapsed` | `/usr/bin/time -v` | Total program time including startup/I/O |
| GNU time `User time` | `/usr/bin/time -v` | CPU time (excludes I/O waits) |
| GNU time `Max RSS` | `/usr/bin/time -v` | Peak memory usage |
| Solution profit | Solver output | Both solvers should find the same optimal profit |

### Expected differences

- **Small instances:** Both solvers finish in milliseconds; differences are noise.
- **Many identical knapsacks:** Rohwedder's ILP benefits from knapsack type aggregation.
- **Many distinct capacities:** Standard ILP may be faster (no enumeration overhead).
- **Large $w_{\max}$ or $d$:** Configuration explosion may slow down Rohwedder's ILP.

### Verifying correctness

Both solvers should report the same optimal profit value. If they differ, the one with the higher feasible profit is correct (or there may be a solver timeout issue — check GLPK status messages).
