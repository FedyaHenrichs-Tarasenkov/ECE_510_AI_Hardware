# CMAN: 2x2 Systolic Array Trace

## (a) Processing Elements (PE) Diagram
**Dataflow:** Weight-Stationary. Weights from Matrix B are pre-loaded. Inputs from Matrix A stream horizontally; partial sums (PS) accumulate vertically.

       Input Row 0 of Array (Col 0 of A: A_00, A_10) ──▶ [ PE 0,0 ] ──▶ [ PE 0,1 ]
                                                          (W=B_00=5)      (W=B_01=6)
                                                              │               │
                                                              ▼               ▼
       Input Row 1 of Array (Col 1 of A: A_01, A_11) ──▶ [ PE 1,0 ] ──▶ [ PE 1,1 ]
                                                          (W=B_10=7)      (W=B_11=8)
                                                              │               │
                                                              ▼               ▼
                                                           Output C        Output C

## (b) Cycle-by-Cycle Trace Table
*Note: Array Row 1 is skewed by 1 cycle to align the partial sum from Row 0 with the corresponding input in Row 1.*

| Cycle | Array Row 0 Input ($A_{i,0}$) | Array Row 1 Input ($A_{i,1}$) | PE[0,0] PS | PE[0,1] PS | PE[1,0] PS | PE[1,1] PS | Output (C values) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **1** | **1** ($A_{0,0}$) | - | $1 \cdot 5 = 5$ | - | - | - | - |
| **2** | **3** ($A_{1,0}$) | **2** ($A_{0,1}$) | $3 \cdot 5 = 15$ | $1 \cdot 6 = 6$ | $5 + (2 \cdot 7) = 19$ | - | **$C_{0,0} = 19$** |
| **3** | - | **4** ($A_{1,1}$) | - | $3 \cdot 6 = 18$ | $15 + (4 \cdot 7) = 43$ | $6 + (2 \cdot 8) = 22$ | **$C_{1,0} = 43, C_{0,1} = 22$** |
| **4** | - | - | - | - | - | $18 + (4 \cdot 8) = 50$ | **$C_{1,1} = 50$** |

## (c) Metrics & Counts
* **Total MAC Operations:** **8** (4 PEs, each performing 2 multiplication/accumulation steps).
* **Input Reuse:** **2 times per value.** Each element of matrix $A$ is read once from memory and reused twice because the value physically propagates horizontally across the array. An input enters the first PE, is used in a MAC operation, and is then forwarded via a register to the adjacent PE in the next clock cycle.
* **Off-Chip Memory Accesses:** **12 total accesses**
  * **Matrix A (Inputs):** 4 reads ($A_{0,0}, A_{0,1}, A_{1,0}, A_{1,1}$)
  * **Matrix B (Weights):** 4 reads (Pre-load of $B_{0,0}, B_{0,1}, B_{10}, B_{1,1}$)
  * **Matrix C (Outputs):** 4 writes ($C_{0,0}, C_{0,1}, C_{1,0}, C_{1,1}$)

## (d) Output-Stationary Dataflow
If this were an output-stationary design, the **partial sums (the resulting $C$ matrix values)** would remain fixed inside the PEs while both the inputs ($A$) and weights ($B$) would stream through the array.