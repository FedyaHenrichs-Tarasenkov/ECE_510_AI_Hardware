# CF07 Synthesis Interpretation: HDC Compute Core

**(a) Clock Period and Slack:**
The synthesis was targeted at a 10.0 ns clock period (100 MHz) to match the AXI4-Lite bus specification. The design easily met timing, yielding a massive positive slack. The worst-case delay from the Yosys synthesis mapping was only ~1.03 ns, leaving roughly +8.97 ns of setup slack, meaning the highly parallel combinational logic is extremely fast.

**(b) Critical Path:**
Because the HDC Binding Unit relies on a parallel 32-bit XOR array, the logic depth is incredibly shallow (only 2 logic levels). The critical path begins at the input control registers (e.g., `s_axi_valid`) and terminates at the output multiplexers/registers. The path is dominated by `sky130_fd_sc_hd__a211oi_2` (AND-OR-INV) and `sky130_fd_sc_hd__xnor2_2` cells.

**(c) Area and Top Contributors:**
The core logic is highly efficient, utilizing only 132 total cells with a combined chip area of 1,924.35 µm². The top three contributors by instance count are:
1. `sky130_fd_sc_hd__dfxtp_2` (D-Flip-Flops): 33 instances (36.5% of sequential area)
2. `sky130_fd_sc_hd__a211oi_2` (AND-OR-Invert): 32 instances
3. `sky130_fd_sc_hd__xnor2_2` (XNOR/XOR Logic): 32 instances

**(d) Violations and Warnings:**
There were zero setup, hold, max slew, or max capacitance violations (all Passed). However, during floorplanning, the design triggered a `[PPL-0024]` error because it was "pin-bound." The 132 logic cells required so little physical silicon that OpenLane initially shrunk the die to 73x83µm, which physically lacked the perimeter to place the 102 AXI4 I/O pins. This was resolved by forcing an absolute die size of 150x150µm.