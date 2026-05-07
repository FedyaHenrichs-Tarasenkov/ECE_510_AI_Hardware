# CMAN: Sneak Paths in a Resistive Crossbar

**Given Crossbar Parameters:**
* $V_{row0} = 1\text{V}$ (Driven node)
* $V_{col0} = 0\text{V}$ (Virtual ground)
* $R_{00} = 1\text{k}\Omega$, $R_{01} = 2\text{k}\Omega$, $R_{10} = 2\text{k}\Omega$, $R_{11} = 1\text{k}\Omega$

## (a) Ideal Read Calculation
For an ideal read of $R_{00}$, we assume $Row_1$ and $Col_1$ are actively grounded ($0\text{V}$) to isolate the target cell. 
Because $Row_1$ is at $0\text{V}$ and $Col_0$ is at $0\text{V}$, there is no voltage drop across $R_{10}$, meaning zero current flows through it. The only current entering $Col_0$ comes directly from $Row_0$ through $R_{00}$.

* $I_{ideal\_path} = (V_{row0} - V_{col0}) / R_{00}$
* $I_{ideal\_path} = (1\text{V} - 0\text{V}) / 1\text{k}\Omega = 1\text{ mA}$

**Ideal $I_{col0} = 1.0\text{ mA}$**

## (b) KCL Solution for Floating Node Voltages
When $Row_1$ and $Col_1$ are left floating (undriven), they form a sneak path. We apply Kirchhoff's Current Law (sum of currents leaving a node = 0) to find the floating node voltages $V_{row1}$ and $V_{col1}$.

**Node 1 ($V_{col1}$):**
Current arrives from $Row_0$ and leaves toward $Row_1$.
* $(V_{col1} - V_{row0}) / R_{01} + (V_{col1} - V_{row1}) / R_{11} = 0$
* $(V_{col1} - 1) / 2\text{k}\Omega + (V_{col1} - V_{row1}) / 1\text{k}\Omega = 0$
* Multiply by 2k: $(V_{col1} - 1) + 2(V_{col1} - V_{row1}) = 0$
* $3V_{col1} - 2V_{row1} = 1$  **(Equation 1)**

**Node 2 ($V_{row1}$):**
Current arrives from $Col_1$ and leaves toward $Col_0$.
* $(V_{row1} - V_{col1}) / R_{11} + (V_{row1} - V_{col0}) / R_{10} = 0$
* $(V_{row1} - V_{col1}) / 1\text{k}\Omega + (V_{row1} - 0) / 2\text{k}\Omega = 0$
* Multiply by 2k: $2(V_{row1} - V_{col1}) + V_{row1} = 0$
* $3V_{row1} - 2V_{col1} = 0 \implies V_{col1} = 1.5 V_{row1}$ **(Equation 2)**

**Solving the System:**
Substitute Equation 2 into Equation 1:
* $3(1.5 V_{row1}) - 2 V_{row1} = 1$
* $4.5 V_{row1} - 2 V_{row1} = 1$
* $2.5 V_{row1} = 1$

**Results:**
* **$V_{row1} = 0.4\text{ V}$**
* **$V_{col1} = 1.5(0.4) = 0.6\text{ V}$**

## (c) Actual Current with Sneak Path
The actual current entering $Col_0$ is the sum of the intended path from $Row_0$ and the unintended sneak path leaking from the floating $Row_1$ node.

* $I_{intended} = (V_{row0} - V_{col0}) / R_{00} = (1\text{V} - 0\text{V}) / 1\text{k}\Omega = 1.0\text{ mA}$
* $I_{sneak} = (V_{row1} - V_{col0}) / R_{10} = (0.4\text{V} - 0\text{V}) / 2\text{k}\Omega = 0.2\text{ mA}$

**Actual $I_{col0} = 1.0\text{ mA} + 0.2\text{ mA} = 1.2\text{ mA}$**

## (d) Explanation of MVM Corruption
Sneak paths occur when unintended parallel routes allow current to flow backward through unselected or floating cells and into the measurement column. This corrupts the intended Matrix-Vector Multiplication (MVM) by summing extra "ghost" currents into the output, making it impossible to distinguish the true mathematical product from electrical noise. In large crossbar arrays, this severely degrades the read margin and limits scalability unless selector devices (like 1T1R architectures) are used to physically block reverse currents.