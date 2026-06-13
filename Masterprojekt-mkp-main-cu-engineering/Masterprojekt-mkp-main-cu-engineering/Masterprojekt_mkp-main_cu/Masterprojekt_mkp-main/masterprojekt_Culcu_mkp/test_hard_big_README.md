# `test_hard_big.txt` — a large, hard, big-knapsack instance

Run it with:

```bash
./mkp test_hard_big.txt
```

On a typical machine the solver needs **~7–8 seconds** of real branch-and-bound
work (GLPK) before it reports the optimal solution
(`Status: OPTIMAL, Objective: 64575999`). This is in sharp contrast to the
earlier example files, which finish in well under 0.1 s.

## Instance contents

```
2 256
2 2017 12195
3 3028 13203
250 250 ... 250          (256 capacities, all = 250)
```

* **2 item types**, **256 knapsacks**
  * Type 0: weight 2, profit 2017, 12195 copies available
  * Type 1: weight 3, profit 3028, 13203 copies available
* **256 knapsacks, every one of capacity 250.**

## Why every knapsack is "big"

A knapsack is classified as *big* when its capacity is at least `wmax⁴`,
where `wmax` is the largest item weight. Here `wmax = 3`, so the threshold is
`3⁴ = 81`. Every capacity is `250 ≥ 81`, so **all 256 knapsacks are big** —
exactly the regime the project's pivot/big-knapsack machinery targets.

## Why it actually takes time to solve

The solver must exactly fill every knapsack (using the two item types plus a
limited number of weight‑1 dummy items) while respecting the item
multiplicities, and maximise total profit. This instance was tuned to be hard
on purpose:

1. **Tight supply.** The total available item weight is essentially equal to
   the total knapsack capacity (`Σ wᵢ·nᵢ ≈ Σ Cⱼ`). There is almost no slack,
   so the packing is a tight subset‑sum‑style feasibility problem rather than a
   loose one that the LP relaxation solves at the root.
2. **Near‑proportional, almost‑tied profits.** The profits (2017 for weight 2,
   3028 for weight 3) are both very close to `≈ 1009 × weight`. Because the two
   item types have almost the same profit‑per‑weight ratio, the LP relaxation is
   highly fractional and the integer optimum is not obvious, forcing GLPK to
   explore many branch‑and‑bound nodes.
3. **Maximum size.** With 256 knapsacks (the solver's `MAX_KNAPSACKS` limit)
   and a capacity of 250, the configuration enumerator produces the maximum
   number of packing configurations (the global `MAX_CONFIGS = 4096` budget is
   essentially saturated), giving the largest integer program the solver can
   build.

Together these make the resulting ILP genuinely non‑trivial, so GLPK spends
several seconds in branch‑and‑bound — "the algorithms generally need some time
to solve it" — while the instance still has a real optimal solution.

## A note on the design space

The solver caps the number of enumerated packing configurations at
`MAX_CONFIGS = 4096` (see `mkp.c`). If one uses many item types together with
large capacities, this budget is exhausted by the first knapsack capacity group,
leaving later groups with no configurations, which makes the instance
*infeasible* (this is why some earlier "big" test files report
"No feasible solution found"). Keeping the number of distinct item types small
(here 2) while making the capacities big and the supply tight is what yields an
instance that is simultaneously **big**, **feasible**, and **hard**.
