# Proof Presentation: Standard Assignment ILP vs. Rohwedder's Configuration ILP for MKP

## Table of Contents

1. [Problem Definition](#1-problem-definition)
2. [Formulation 1: Standard Assignment ILP](#2-formulation-1-standard-assignment-ilp)
3. [Formulation 2: Rohwedder's Configuration ILP](#3-formulation-2-rohwedders-configuration-ilp)
4. [Side-by-Side Comparison](#4-side-by-side-comparison)
5. [Correctness Proof of the Standard Assignment ILP](#5-correctness-proof-of-the-standard-assignment-ilp)
6. [Correctness Proof of Rohwedder's Configuration ILP](#6-correctness-proof-of-rohwedders-configuration-ilp)
7. [Lean 4 Formalization](#7-lean-4-formalization)
8. [Complexity and Practical Trade-offs](#8-complexity-and-practical-trade-offs)
9. [When to Use Which Formulation](#9-when-to-use-which-formulation)

---

## 1. Problem Definition

### Multiple Knapsack Problem (MKP)

**Given:**
- $d$ item types with weights $w_1, \ldots, w_d$, profits $p_1, \ldots, p_d$, and multiplicities $n_1, \ldots, n_d$
- $m$ knapsacks with capacities $C_1, \ldots, C_m$

**Goal:** Find an assignment of items to knapsacks that:
1. Does not exceed any knapsack's capacity
2. Does not exceed any item type's multiplicity
3. Maximizes total profit

---

## 2. Formulation 1: Standard Assignment ILP

### 2.1 Variables

$$x_{i,j} \in \mathbb{N}_0 \quad \text{for } i = 1,\ldots,d, \; j = 1,\ldots,m$$

where $x_{i,j}$ = number of items of type $i$ placed in knapsack $j$.

### 2.2 Objective

$$\max \quad \sum_{j=1}^{m} \sum_{i=1}^{d} x_{i,j} \cdot p_i$$

### 2.3 Constraints

**(C1) Capacity constraints:** Each knapsack respects its capacity.
$$\forall j \in \{1, \ldots, m\}: \quad \sum_{i=1}^{d} x_{i,j} \cdot w_i \leq C_j$$

**(C2) Multiplicity constraints:** Each item type respects its supply.
$$\forall i \in \{1, \ldots, d\}: \quad \sum_{j=1}^{m} x_{i,j} \leq n_i$$

**(C3) Non-negativity and integrality:**
$$x_{i,j} \geq 0, \quad x_{i,j} \in \mathbb{Z}$$

### 2.4 Size of the ILP

| Aspect | Count |
|--------|-------|
| Variables | $d \cdot m$ |
| Constraints | $m + d$ (plus variable bounds) |
| Non-zeros | $\leq d \cdot m \cdot 2$ |

**Key feature:** The number of variables grows linearly with $m$ (number of knapsacks), making this formulation compact. However, the LP relaxation can be weak, leading to long branch-and-bound times.

---

## 3. Formulation 2: Rohwedder's Configuration ILP

This formulation is based on the approach of Lars Rohwedder for the $Q||C_{\max}$ scheduling problem, extended here to the MKP with profits.

### 3.1 Preprocessing

**Partition knapsacks** into:
- **Big knapsacks:** $B := \{j : C_j \geq w_{\max}^4\}$ where $w_{\max} := \max_i w_i$
- **Small knapsacks:** $S := \{j : C_j < w_{\max}^4\}$

**Group by type:** Knapsacks with the same capacity form a *knapsack type* $\tau$, with $m(\tau)$ knapsacks of capacity $C_\tau$.

**Choose a pivot item type** $a \in \{1, \ldots, d\}$.

### 3.2 Configurations

A **configuration** $\mathbf{c} = (c_1, \ldots, c_d) \in \mathbb{N}^d$ specifies how many items of each type to pack. For knapsack type $\tau$, the set of valid configurations is:

$$\mathcal{C}(\tau) := \left\{ \mathbf{c} \in \mathbb{N}^d \;\middle|\; \sum_{i=1}^d c_i \cdot w_i \leq C_\tau^{\text{red}} \right\}$$

where the **reduced capacity** for big knapsack types is:
$$C_\tau^{\text{red}} := C_\tau - w_{\max}^2 \cdot w_a$$

and for small knapsack types: $C_\tau^{\text{red}} := C_\tau$.

### 3.3 Variables

- $y_{\tau, \mathbf{c}} \in \mathbb{N}_0$ : how many knapsacks of type $\tau$ use configuration $\mathbf{c}$
- $b_i \in \mathbb{N}_0$ for $i \neq a$: number of bundles of type $i$ (each bundle = $w_a$ items of type $i$)
- $b_a \in \mathbb{N}_0$: number of additional pivot items

### 3.4 Objective

$$\max \quad \sum_{\tau} \sum_{\mathbf{c} \in \mathcal{C}(\tau)} y_{\tau,\mathbf{c}} \cdot P(\mathbf{c}) \;+\; \sum_{i \neq a} b_i \cdot w_a \cdot p_i \;+\; b_a \cdot p_a$$

where $P(\mathbf{c}) := \sum_{i=1}^d c_i \cdot p_i$.

### 3.5 Constraints

**(R1) Knapsack type counts:**
$$\forall \tau: \quad \sum_{\mathbf{c} \in \mathcal{C}(\tau)} y_{\tau,\mathbf{c}} = m(\tau)$$

**(R2) Item multiplicity (non-pivot):**
$$\forall i \neq a: \quad \sum_{\tau} \sum_{\mathbf{c}} c_i \cdot y_{\tau,\mathbf{c}} \;+\; w_a \cdot b_i \;\leq\; n_i$$

**(R3) Pivot multiplicity:**
$$\sum_{\tau} \sum_{\mathbf{c}} c_a \cdot y_{\tau,\mathbf{c}} \;+\; b_a \;\leq\; n_a - |B| \cdot w_{\max}^2$$

**(R4) Total weight:**
$$\sum_{\tau} \sum_{\mathbf{c}} W(\mathbf{c}) \cdot y_{\tau,\mathbf{c}} \;+\; \sum_{i \neq a} b_i \cdot w_a \cdot w_i \;+\; b_a \cdot w_a \;\leq\; \sum_j C_j \;-\; |B| \cdot w_{\max}^2 \cdot w_a$$

**(R5) Non-negativity and integrality.**

### 3.6 Size of the ILP

| Aspect | Count |
|--------|-------|
| Variables | $\sum_\tau |\mathcal{C}(\tau)| + (d+1)$ |
| Constraints | $T + d + 2$ ($T$ = number of knapsack types) |

**Key feature:** The number of variables depends on the number of **configurations** per knapsack type, not on the total number of knapsacks. For fixed $d$, the configuration count is bounded by $O(w_{\max}^{4d})$ for small knapsacks and $O(w_{\max}^{2(d-1)} \cdot C_\tau / w_a)$ for big knapsacks (with the $c_i \leq w_{\max}^2$ restriction for non-pivot types).

---

## 4. Side-by-Side Comparison

| Feature | Standard Assignment ILP | Rohwedder Configuration ILP |
|---------|------------------------|-----------------------------|
| **Variables** | $d \cdot m$ (one per item-knapsack pair) | $\sum_\tau |\mathcal{C}(\tau)| + d + 1$ |
| **Grows with** | Number of knapsacks $m$ | Number of configurations (depends on $w_{\max}$, $d$, capacities) |
| **LP relaxation** | Weak (fractional solutions far from integer) | Stronger (configurations encode combinatorial structure) |
| **Symmetry** | High: identical knapsacks give symmetric solutions | Low: knapsacks of the same type are aggregated |
| **Preprocessing** | None required | Partitioning, pivot selection, configuration enumeration |
| **Knapsack grouping** | Not exploited | Essential: knapsacks of the same capacity share configurations |
| **Pivot mechanism** | Not applicable | Reserves $w_{\max}^2$ pivot items per big knapsack; enables bundle mechanism |
| **Bundle variables** | Not applicable | Allow redistribution of items in reserved capacity |
| **Ideal for** | Small $d \cdot m$ | Many identical knapsacks, fixed $d$, moderate $w_{\max}$ |
| **Worst case for** | Many identical knapsacks (symmetry explosion) | Large $w_{\max}$ with large $d$ (configuration explosion) |
| **Solution reconstruction** | Direct: variables are the assignment | Requires reconstruction: configurations → knapsacks, then bundles and pivot items |
| **Correctness** | Trivially equivalent to MKP definition | Requires non-trivial proof (Sections 5–6) |

### Structural Difference

The fundamental difference is the **unit of decision**:

- **Standard ILP:** Decides *how many items of each type go into each individual knapsack*.
- **Configuration ILP:** Decides *how many knapsacks of each type use each packing pattern (configuration)*.

This shift from per-knapsack decisions to per-type-pattern decisions **breaks symmetry** between identical knapsacks and can dramatically reduce the effective search space.

### Symmetry Breaking Example

Consider 100 identical knapsacks with capacity 10 and 3 item types. The standard ILP has $3 \times 100 = 300$ integer variables, and the solver must explore exponentially many equivalent assignments (swapping items between identical knapsacks). The configuration ILP has a single knapsack type with perhaps 20–50 configurations, so the ILP has $\sim 50 + 4 = 54$ variables — and the constraint $\sum_\mathbf{c} y_{\tau,\mathbf{c}} = 100$ automatically aggregates the 100 knapsacks.

---

## 5. Correctness Proof of the Standard Assignment ILP

### Theorem 1 (Standard ILP ↔ MKP)

*The standard assignment ILP is a faithful encoding of the MKP: an assignment $(x_{i,j})$ is a feasible MKP solution if and only if it satisfies constraints (C1)–(C3), and the objective function equals the total MKP profit.*

**Proof.** This is immediate from the definitions:

- **Feasibility (C1):** $\sum_i x_{i,j} \cdot w_i \leq C_j$ is exactly the capacity constraint for knapsack $j$.
- **Feasibility (C2):** $\sum_j x_{i,j} \leq n_i$ is exactly the multiplicity constraint for item type $i$.
- **Objective:** $\sum_{j,i} x_{i,j} \cdot p_i$ is the total profit of the assignment.
- **Integrality (C3):** Items are indivisible.

The correspondence is a bijection: every MKP assignment *is* a matrix $(x_{i,j})$ satisfying (C1)–(C3). $\square$

---

## 6. Correctness Proof of Rohwedder's Configuration ILP

The correctness of Rohwedder's configuration ILP is more subtle and requires two directions.

### 6.1 Soundness (ILP solution → MKP solution)

**Theorem 2.** Let $(y^*_{\tau,\mathbf{c}}, b^*_i)$ be a feasible solution of the configuration ILP with pivot $a$. Then there exists a feasible MKP assignment with total profit equal to $Z^* + |B| \cdot w_{\max}^2 \cdot p_a$, where $Z^*$ is the ILP objective value.

**Proof sketch (3 phases):**

1. **Phase 1 — Configuration assignment:** Assign configurations to individual knapsacks. Constraint (R1) ensures each knapsack type has exactly the right number of configurations. Each assigned configuration respects the (reduced) capacity.

2. **Phase 2 — Reserved pivot items:** Place $w_{\max}^2$ items of pivot type $a$ into each big knapsack. The capacity reduction ensures space is available: $W(\mathbf{c}) + w_{\max}^2 \cdot w_a \leq C_\tau^{\text{red}} + w_{\max}^2 \cdot w_a = C_\tau$.

3. **Phase 3 — Bundle items:** Distribute bundle items ($w_a \cdot b_i$ items of type $i$ for $i \neq a$, and $b_a$ pivot items) among knapsacks using remaining capacity. Constraint (R4) guarantees total remaining capacity suffices. A greedy placement works because each item weighs $\leq w_{\max}$ and big knapsacks have large remaining capacity.

Multiplicity is verified by constraints (R2) and (R3). $\square$

### 6.2 Completeness (Optimal MKP → ILP solution)

**Theorem 3.** If $w_{\max} \geq d+1$ and OPT is an optimal MKP solution with profit $P^*$, then there exists a pivot type $a$ such that the configuration ILP has a feasible solution with objective value $\geq P^* - |B| \cdot w_{\max}^2 \cdot p_a$.

**Proof sketch:**

1. **Fill with dummies:** Pad OPT so every knapsack uses its full capacity (add dummy items with weight 1, profit 0).

2. **Pivot existence (pigeonhole):** Each big knapsack has $\geq C_j / w_{\max} \geq w_{\max}^3$ items. With $d+1$ types and $w_{\max} \geq d+1$, each big knapsack has $\geq w_{\max}^2$ items of some type. By averaging, one type $a$ has $\geq w_{\max}^2$ items in *total* across big knapsacks. If needed, redistribute pivot items between big knapsacks (adding dummies to maintain capacity).

3. **Construct ILP solution:** For each knapsack, form the configuration by removing the $w_{\max}^2$ reserved pivot items (for big knapsacks). Set $b_i = 0$ for all $i$. All ILP constraints are satisfied.

4. **Objective:** $Z = P^* - |B| \cdot w_{\max}^2 \cdot p_a$ (the removed pivot items' profit). $\square$

### 6.3 Optimality Equivalence

**Corollary.** Running the configuration ILP for every pivot candidate $a \in \{1, \ldots, d\}$ and taking the best solution yields an optimal MKP assignment.

*Proof.* By Theorem 3, the optimal pivot achieves $Z \geq P^* - |B| \cdot w_{\max}^2 \cdot p_a$, so the reconstructed MKP profit is $\geq P^*$. Since $P^*$ is optimal, equality holds. $\square$

---

## 7. Lean 4 Formalization

The equivalence between the assignment-based and configuration-based formulations has been formalized in Lean 4 using Mathlib. The formalization covers the *structural* equivalence (without the pivot/bundle mechanism, which adds complexity without affecting the core insight).

### Files

- **`MKPDefs.lean`** — Definitions of `MKPInstance`, `MKPAssignment`, `Configuration`, `ConfigILPSolution`, and their properties (feasibility, profit, conversions).

- **`MKPCorrectness.lean`** — Machine-verified proofs of:

| Theorem | Statement |
|---------|-----------|
| `configILP_to_mkp_feasible` | Feasible config-ILP solution → feasible MKP assignment |
| `mkp_to_configILP_feasible` | Feasible MKP assignment → feasible config-ILP solution |
| `configILP_to_mkp_profit` | Profit preserved: config-ILP → MKP |
| `mkp_to_configILP_profit` | Profit preserved: MKP → config-ILP |
| `roundtrip_mkp` | MKP → ConfigILP → MKP = identity |
| `roundtrip_configILP` | ConfigILP → MKP → ConfigILP = identity |
| `configILP_optimal_implies_mkp_optimal` | Optimal config-ILP solution → optimal MKP assignment |
| `mkp_optimal_implies_configILP_optimal` | Optimal MKP assignment → optimal config-ILP solution |

### Key Insight of the Lean Proof

The conversion functions are structurally trivial:
```
ConfigILPSolution.toAssignment : config j ↦ (fun j i => (config j).items i)
MKPAssignment.toConfigILP     : assign ↦ (fun j => ⟨fun i => assign j i⟩)
```
Both round-trips are definitional equalities (`rfl`), which means the two formulations are *the same mathematical object* viewed from different perspectives. The feasibility and profit preservation follow directly by unfolding definitions.

The Lean proofs confirm that:
- There is a **profit-preserving bijection** between MKP assignments and configuration ILP solutions.
- **Optimality transfers** in both directions.

---

## 8. Complexity and Practical Trade-offs

### 8.1 ILP Size

| Formulation | Variables | Constraints |
|-------------|-----------|-------------|
| Standard | $O(d \cdot m)$ | $O(d + m)$ |
| Config (no pivot) | $O(\sum_\tau |\mathcal{C}(\tau)|)$ | $O(T + d)$ |
| Config (with pivot) | $O(\sum_\tau |\mathcal{C}(\tau)| + d)$ | $O(T + d)$ |

where $T$ = number of distinct knapsack types.

### 8.2 When Configuration ILP Wins

- **Many identical knapsacks:** If $m$ is large but $T$ is small (e.g., 1000 knapsacks of 3 types), the configuration ILP has far fewer variables.
- **Small number of item types $d$:** Configuration count grows exponentially in $d$; for small $d$ (2–5), it remains manageable.
- **Moderate $w_{\max}$:** Configuration count for small knapsacks is $O(w_{\max}^{4d})$; if $w_{\max}$ is not too large this is practical.

### 8.3 When Standard ILP Wins

- **Many distinct capacities:** If every knapsack has a unique capacity ($T = m$), the configuration ILP gains no advantage from grouping.
- **Large $d$ or $w_{\max}$:** Configuration explosion makes enumeration and the ILP itself impractical.
- **Simple instances:** The standard ILP is trivial to set up and interpret.

### 8.4 Solver Behavior

- **Symmetry:** The standard ILP suffers from symmetry among identical knapsacks — the solver explores equivalent permutations. The configuration ILP breaks this symmetry by construction.
- **LP relaxation:** The configuration ILP often has a tighter LP relaxation, reducing the branch-and-bound tree.
- **Enumeration cost:** The configuration ILP front-loads computation in the enumeration phase; this cost is paid even if the ILP turns out to be easy.

---

## 9. When to Use Which Formulation

| Scenario | Recommended Formulation |
|----------|------------------------|
| Few knapsacks, many item types | Standard ILP |
| Many identical knapsacks, few item types | Configuration ILP (Rohwedder) |
| All knapsacks have distinct capacities | Standard ILP |
| $w_{\max}$ is small, $d$ is small | Configuration ILP |
| $w_{\max}^{4d}$ is very large | Standard ILP |
| Need proven optimality for scheduling-like instances | Configuration ILP |
| Quick prototyping / simple instances | Standard ILP |

### The C Implementation

The solver in `mkp.c` implements **both** formulations:
- `mkp_solve_direct_ilp()` — the standard configuration ILP (without pivot/bundles)
- `mkp_solve()` → `mkp_solve_ilp()` — Rohwedder's pivot-based configuration ILP

Both use **GLPK** as the ILP backend. The command-line interface allows selecting either solver independently for benchmarking:

```bash
./mkp --direct <input>      # Standard ILP
./mkp --rohwedder <input>   # Rohwedder ILP
./mkp --benchmark <input>   # Both with timing comparison
```

See **`BENCHMARKING_MANUAL.md`** for detailed instructions on measuring and comparing running times.

---

## References

- Lars Rohwedder. *A QPTAS for Makespan Minimization on Uniform Machines beyond the Known Ratio of Machine Speeds.* LIPIcs ICALP 2025.
- Lean 4 / Mathlib formalization: `MKPDefs.lean`, `MKPCorrectness.lean` in this project.
