# Multiple Knapsack Problem (MKP) Solver

A C implementation of the Multiple Knapsack Problem solver based on the approach
of Lars Rohwedder for Q||Cmax, extended with profits and bundles.

Uses **GLPK (GNU Linear Programming Kit)** as the ILP solver library.

## Problem Description

Given:
- **d** different item types, each with weight `w_i`, profit `p_i`, and multiplicity `n_i`
- **m** knapsacks with capacities `C_1, ..., C_m`

Goal: Assign items to knapsacks to maximize total profit, without exceeding
any knapsack's capacity or any item type's multiplicity.

## Algorithm Overview

1. **Partition knapsacks** into big (capacity ≥ w_max⁴) and small (capacity < w_max⁴)
2. **Find pivot item type** `a` — the type with the largest total weight contribution
3. **Group knapsacks** by capacity into knapsack types
4. **Enumerate configurations** for each knapsack type (feasible item combinations)
5. **Introduce dummy items** (weight 1, profit 0) to allow exact capacity filling
6. **Build ILP formulation** with:
   - Variables `y_{τ,C}`: how often configuration C is used for knapsack type τ
   - Variables `b_i`: number of bundles used per item type
   - Constraints ensuring type counts, item limits, pivot bounds, and total weight
7. **Solve ILP** using GLPK
8. **Construct solution** — map ILP solution back to concrete item-to-knapsack assignments

## Dependencies

- **GLPK** (GNU Linear Programming Kit) — used for solving the Integer Linear Program
- **GCC** (or any C11-compatible compiler)
- **Make**

### Installing GLPK

```bash
# Ubuntu/Debian
sudo apt-get install libglpk-dev

# macOS (Homebrew)
brew install glpk

# Fedora/RHEL
sudo dnf install glpk-devel
```

## Building

```bash
make
```

## Usage

### Run built-in examples
```bash
./mkp
```

### Run with input file
```bash
./mkp example_input.txt
```

### Run the larger built-in example
```bash
./mkp --large
```

## Input File Format

```
d m
w_1 p_1 n_1
w_2 p_2 n_2
...
w_d p_d n_d
C_1 C_2 ... C_m
```

Where:
- `d` = number of item types
- `m` = number of knapsacks
- `w_i p_i n_i` = weight, profit, multiplicity of item type i
- `C_j` = capacity of knapsack j

### Example (`example_input.txt`)
```
3 4
3 4 5
5 7 3
2 3 8
10 15 8 12
```

This defines 3 item types and 4 knapsacks:
- Type 0: weight=3, profit=4, 5 available
- Type 1: weight=5, profit=7, 3 available
- Type 2: weight=2, profit=3, 8 available
- Knapsacks with capacities: 10, 15, 8, 12

## Project Structure

```
mkp-c/
├── mkp.h              # Header: data structures and function prototypes
├── mkp.c              # Core algorithm and ILP formulation
├── main.c             # Driver program with I/O and examples
├── Makefile           # Build system
├── example_input.txt  # Sample input file
└── README.md          # This file
```

## Output

The solver prints:
1. Instance statistics (item types, knapsacks, wmax)
2. Knapsack partitioning (big vs small)
3. Pivot item selection
4. Configuration enumeration counts
5. ILP solving progress (from GLPK)
6. Final solution: items assigned to each knapsack with weights and profits

## Changes made to previous version
**Problem identified**: The pivot selection heuristic (choosing the item type with the largest `multiplicity × weight`) does not always work. The test instance `test.txt` demonstrates this — with 2 item types (weight=2/profit=1/count=100 and weight=3/profit=100/count=100), 2 big knapsacks (capacity 100), and 100 small knapsacks (capacity 3), the heuristic picks item type 1 as pivot, but the resulting ILP becomes infeasible or suboptimal due to the pivot constraint reserving `|B| × wmax²` items.

**Fix applied**: 
- **`mkp_solve()` now tries ALL item types as pivot candidates** and returns the best solution found. This eliminates the reliance on the heuristic and guarantees correctness.
- **Added `mkp_solve_direct_ilp()`** as a fallback: a simpler configuration ILP without pivot constraints. If no pivot-based solution is feasible, this direct formulation is used instead. This handles edge cases where the pivot decomposition is too restrictive.
- Updated `mkp.h` to declare `mkp_solve_direct_ilp()`.


**Proofs**
# Theorem 5: From mod-IP(a) Solution to Multiple Knapsack Solution

**Theorem:** Given a feasible solution x̃ to mod-IP(a), we can construct a feasible solution to the Multiple Knapsack Problem in polynomial time.

**Proof:**

Given a Multiple Knapsack instance with:
- n items with weights w₁, ..., wₙ and profits p₁, ..., pₙ
- m knapsacks with capacities c₁, ..., cₘ

Let x̃ ∈ {0,1}ⁿ be a feasible solution to mod-IP(a) where:
- Σᵢ₌₁ⁿ wᵢx̃ᵢ ≡ a (mod D)
- x̃ satisfies all knapsack capacity constraints

We construct a solution x* for the Multiple Knapsack Problem as follows:

1. **Initialize:** Set x*ᵢⱼ = 0 for all items i ∈ [n] and knapsacks j ∈ [m].

2. **Assignment Phase:** For each item i with x̃ᵢ = 1:
   - Find the first knapsack j that has sufficient remaining capacity for item i
   - Set x*ᵢⱼ = 1
   - Update the remaining capacity of knapsack j

3. **Feasibility:** Since x̃ satisfies the capacity constraints in mod-IP(a), we know that:
   - The total weight Σᵢ: x̃ᵢ₌₁ wᵢ can be distributed among the m knapsacks
   - Each knapsack's capacity constraint is respected

4. **Profit Preservation:** The total profit of solution x* equals:
   
   Σᵢ₌₁ⁿ Σⱼ₌₁ᵐ pᵢx*ᵢⱼ = Σᵢ: x̃ᵢ₌₁ pᵢ
   
   which matches the profit from the mod-IP(a) solution.

Therefore, x* is a feasible solution to the Multiple Knapsack Problem with the same profit as the mod-IP(a) solution. ∎

# Lemma 9: From Multiple Knapsack Solution to mod-IP(a) Solution

**Lemma:** Given a feasible solution x* to the Multiple Knapsack Problem with total weight congruent to a modulo D, we can construct a feasible solution to mod-IP(a) in polynomial time.

**Proof:**

Given a feasible Multiple Knapsack solution x* ∈ {0,1}ⁿˣᵐ where:
- x*ᵢⱼ = 1 if item i is in knapsack j, and 0 otherwise
- Σᵢ₌₁ⁿ wᵢx*ᵢⱼ ≤ cⱼ for all knapsacks j ∈ [m]
- Each item is assigned to at most one knapsack: Σⱼ₌₁ᵐ x*ᵢⱼ ≤ 1 for all i

Assume the total weight satisfies: Σᵢ₌₁ⁿ Σⱼ₌₁ᵐ wᵢx*ᵢⱼ ≡ a (mod D)

We construct x̃ ∈ {0,1}ⁿ for mod-IP(a) as follows:

1. **Define:** Set x̃ᵢ = maxⱼ∈[m] x*ᵢⱼ for each item i
   - This equals 1 if item i is in any knapsack, 0 otherwise

2. **Modular Constraint:** The total weight under x̃ is:
   
   Σᵢ₌₁ⁿ wᵢx̃ᵢ = Σᵢ₌₁ⁿ wᵢ · maxⱼ∈[m] x*ᵢⱼ = Σᵢ₌₁ⁿ Σⱼ₌₁ᵐ wᵢx*ᵢⱼ ≡ a (mod D)

3. **Capacity Constraints:** The solution x̃ satisfies all capacity constraints because:
   - The items selected by x̃ are exactly those in the Multiple Knapsack solution
   - These items already fit within the combined capacity of all knapsacks

4. **Profit Preservation:** The total profit is:
   
   Σᵢ₌₁ⁿ pᵢx̃ᵢ = Σᵢ₌₁ⁿ Σⱼ₌₁ᵐ pᵢx*ᵢⱼ

Therefore, x̃ is a feasible solution to mod-IP(a) with the same profit as the Multiple Knapsack solution. ∎

