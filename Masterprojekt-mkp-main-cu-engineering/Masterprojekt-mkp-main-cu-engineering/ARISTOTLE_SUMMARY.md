# Summary of changes for run d0dfd580-9a81-4960-93dc-95a9caca8a53
I have added three deliverables to the project in `Masterprojekt_mkp-main/masterprojekt_Culcu_mkp/`:

## 1. Proof Presentation (`proof_presentation.md`)

A comprehensive document comparing the **Standard Assignment ILP** with **Rohwedder's Configuration ILP** for the Multiple Knapsack Problem. It covers:

- **Full formulation of both ILPs** with variables, objectives, and constraints
- **Side-by-side comparison table** (variables, symmetry, LP relaxation, ideal use cases, etc.)
- **Correctness proof** of the Standard ILP (trivial bijection with MKP)
- **Correctness proof** of Rohwedder's Configuration ILP (soundness via 3-phase reconstruction, completeness via pigeonhole/pivot, optimality equivalence)
- **Lean 4 formalization** summary (referencing `MKPDefs.lean` and `MKPCorrectness.lean`)
- **Complexity and practical trade-offs** — when each formulation wins
- **Key structural insight:** the unit of decision shifts from per-knapsack assignments to per-type configuration patterns, breaking symmetry

## 2. Benchmarking Support (modified `main.c` and `Makefile`)

Modified `main.c` to support separate solver execution modes:
- `./mkp --direct <file>` — runs **only** the Standard (Direct) ILP
- `./mkp --rohwedder <file>` — runs **only** Rohwedder's Pivot-based ILP
- `./mkp --benchmark <file>` — runs **both** solvers and prints a timing comparison
- Internal timing uses `clock_gettime(CLOCK_MONOTONIC)` for precise wall-clock measurement

Updated `Makefile` with targets: `make benchmark`, `make benchmark-direct`, `make benchmark-rohwedder`.

Also added helper scripts:
- `benchmark_trials.sh` — runs N trials of each solver and computes averages
- `generate_instance.sh` — generates random MKP instances for testing

## 3. Benchmarking Manual (`BENCHMARKING_MANUAL.md`)

A detailed step-by-step guide for Ubuntu covering:
- **Prerequisites:** `sudo apt-get install build-essential libglpk-dev time`
- **4 benchmarking methods:** built-in timing, GNU `/usr/bin/time -v`, Makefile targets, and shell `time`
- **Step-by-step walkthrough** for comparing both solvers
- **Running multiple trials** with the provided `benchmark_trials.sh` script
- **Creating larger test instances** with `generate_instance.sh`
- **Suppressing GLPK output** for clean timing measurements
- **Quick reference table** of all benchmarking commands
- **Interpreting results:** which metrics to compare, expected differences, correctness verification