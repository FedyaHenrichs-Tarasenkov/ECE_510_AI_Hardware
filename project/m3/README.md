# Milestone 3 Deliverables

This directory contains the integrated RTL, testbenches, simulation logs, and OpenLane 2 synthesis reports for the M3 deliverable.

### Co-Simulation Reproduction
* **Simulator:** Icarus Verilog (iverilog version 12.0)
* **Reproduction Command:**
    iverilog -g2012 -o project/m3/sim/cosim.vvp project/m2/rtl/interface.sv project/m2/rtl/compute_core.sv project/m3/rtl/top.sv project/m3/tb/tb_top.sv
    vvp project/m3/sim/cosim.vvp

### Synthesis Reproduction
* **Tool:** OpenLane 2 (Dockerized via Python orchestrator)
* **Reproduction Command:**
    openlane --dockerized project/m3/synth/config.json

### File Catalog
* project/m3/README.md : This index file cataloging M3 deliverables.
* project/m3/rtl/top.sv : Integrated top module instantiating the AXI interface and compute core.
* project/m3/tb/tb_top.sv : End-to-end co-simulation testbench using AXI BFMs.
* project/m3/sim/cosim_run.log : Simulation transcript showing the PASS result.
* project/m3/sim/cosim_waveform.png : Annotated waveform showing host writes, compute, and host reads.
* project/m3/synth/config.json : OpenLane 2 configuration specifying absolute die sizing.
* project/m3/synth/openlane_run.log : Full captured stdout/stderr from the OpenLane run.
* project/m3/synth/timing_report.txt : The STA report indicating path delays.
* project/m3/synth/area_report.txt : The metrics summary containing cell area and counts.
* project/m3/synth/power_report.txt : OpenROAD power estimation report (documented failure/skip).
* project/m3/synth/critical_path.md : Identification and explanation of the reset-bound critical path.
* project/m3/synthesis_notes.md : Detailed narrative of the integration, synthesis flow, and scope confirmation.