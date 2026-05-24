# M3 Critical Path Analysis

**Startpoint:** `axi_aresetn` (input port clocked by `clk`)
**Endpoint:** `_1031_` (rising edge-triggered flip-flop `sky130_fd_sc_hd__dfxtp_2` clocked by `clk`)
**Path Type:** max (Setup time check)

**Path Explanation:**
The critical path in the integrated design does not actually lie within the HDC compute core's XOR datapath. Instead, the critical path is the global reset distribution network. The path begins at the AXI4-Lite active-low reset pin (`axi_aresetn`). This signal must fan out to reset every register within the interface and the compute core simultaneously. The logic stages on this path consist of the input delay, standard wire routing, and an AND-OR-Invert gate (`sky130_fd_sc_hd__o211a_2`) which acts as the glue logic/inverter to flip the active-low AXI reset to the active-high reset expected by the core. It terminates at the `D` pin of the destination flip-flop (`_1031_`).

**How to shorten it:**
Because this path is dominated by massive fanout (driving 161 destination gates), the primary way to shorten it is to insert a dedicated Reset Synchronization and Distribution Tree (reset pipelining/buffering). Breaking the massive single net into a buffered tree would reduce the fanout load on the initial pin and significantly reduce the RC delay, allowing the tool to meet timing much more comfortably at higher frequencies.