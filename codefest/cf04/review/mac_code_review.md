# MAC Module Code Review

## 1. LLM Models Used
* **LLM A:** Gemini Pro (mac_llm_A.v)
* **LLM B:** DeepSeek-V3-0324 (mac_llm_B.v)

## 2. Compilation & Linting Logs
**LLM A Compilation (iverilog):**
Clean compilation with no syntax errors.

**LLM B Compilation (iverilog):**
Clean compilation with no syntax errors.

## 3. Simulation Results

**LLM A Simulation:**
    Time=0 | rst=1 a=   0 b=   0 | out=          x
    Time=5 | rst=1 a=   0 b=   0 | out=          0
    Time=6 | rst=0 a=   3 b=   4 | out=          0
    Time=15 | rst=0 a=   3 b=   4 | out=         12
    Time=25 | rst=0 a=   3 b=   4 | out=         24
    Time=35 | rst=0 a=   3 b=   4 | out=         36
    Time=36 | rst=1 a=   3 b=   4 | out=         36
    Time=45 | rst=1 a=   3 b=   4 | out=          0
    Time=46 | rst=0 a=  -5 b=   2 | out=          0
    Time=55 | rst=0 a=  -5 b=   2 | out=        -10
    Time=65 | rst=0 a=  -5 b=   2 | out=        -20
    Time=75 | rst=0 a=  -5 b=   2 | out=        -30

**LLM B Simulation:**
    Time=0 | rst=1 a=   0 b=   0 | out=          x
    Time=5 | rst=1 a=   0 b=   0 | out=          0
    Time=6 | rst=0 a=   3 b=   4 | out=          0
    Time=15 | rst=0 a=   3 b=   4 | out=         12
    Time=25 | rst=0 a=   3 b=   4 | out=         24
    Time=35 | rst=0 a=   3 b=   4 | out=         36
    Time=36 | rst=1 a=   3 b=   4 | out=         36
    Time=45 | rst=1 a=   3 b=   4 | out=          0
    Time=46 | rst=0 a=  -5 b=   2 | out=          0
    Time=55 | rst=0 a=  -5 b=   2 | out=      65526
    Time=65 | rst=0 a=  -5 b=   2 | out=     131052
    Time=75 | rst=0 a=  -5 b=   2 | out=     196578

## 4. Code Review & Corrections

**Issue 1: Sign Extension Error in LLM B (DeepSeek)**
* **(a) Offending Line:** `out <= out + {16'b0, product};`
* **(b) Explanation:** LLM B successfully created a signed 16-bit `product` wire. However, when accumulating into the 32-bit `out` register, it forced a zero-padding concatenation (`16'b0`). Because the top bits of a negative 2's complement number must be padded with `1`s to maintain the negative sign, explicitly padding with `0`s corrupts the sign and converts the negative product into a massive positive integer (as proven by the simulation output jumping from 0 to 65526 instead of -10).
* **(c) Correction:** Because both `out` and the operands are declared as `signed`, SystemVerilog will automatically handle sign extension if the math is done directly. The concatenation should be completely removed: `out <= out + product;` or `out <= out + (a * b);`.

## 5. Corrected Module Simulation (mac_correct.v)

**Simulation Output:**
    Time=0 | rst=1 a=   0 b=   0 | out=          x
    Time=5 | rst=1 a=   0 b=   0 | out=          0
    Time=6 | rst=0 a=   3 b=   4 | out=          0
    Time=15 | rst=0 a=   3 b=   4 | out=         12
    Time=25 | rst=0 a=   3 b=   4 | out=         24
    Time=35 | rst=0 a=   3 b=   4 | out=         36
    Time=36 | rst=1 a=   3 b=   4 | out=         36
    Time=45 | rst=1 a=   3 b=   4 | out=          0
    Time=46 | rst=0 a=  -5 b=   2 | out=          0
    Time=55 | rst=0 a=  -5 b=   2 | out=        -10
    Time=65 | rst=0 a=  -5 b=   2 | out=        -20
    Time=75 | rst=0 a=  -5 b=   2 | out=        -30

## 6. Yosys Synthesis (Optional)
**Command Run:** `yosys -p 'synth; stat' mac_correct.v`

**Synthesis Statistics Output:**
    === mac ===

       Number of wires:                 12
       Number of wire bits:            182
       Number of public wires:           5
       Number of public wire bits:      49
       Number of memories:               0
       Number of memory bits:            0
       Number of processes:              0
       Number of cells:                 34
         $add                            1
         $adff                          32
         $mul                            1