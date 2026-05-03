# Milestone 2: RTL & Testbenches

## Build and Simulation Instructions
The hardware design and testbenches are written in standard SystemVerilog and can be simulated completely from a clean repository clone using Icarus Verilog (version 11.0 or newer) and GTKWave for waveform viewing. No extra Python pre-processing dependencies are required for this specific milestone run.

### 1. Simulating the Compute Core (Binding Unit)
Navigate to the project/m2/tb/ directory and execute the following commands to compile, run, and log the compute core testbench:

    cd project/m2/tb/
    iverilog -g2012 -o compute_core.vvp ../rtl/compute_core.sv tb_compute_core.sv
    vvp compute_core.vvp > ../sim/compute_core_run.log

*Note: A VCD file (compute_core.vcd) will be automatically generated in the directory for waveform inspection via GTKWave.*

### 2. Simulating the Interface (AXI4-Lite Slave)
From the same project/m2/tb/ directory, execute the following commands to verify the AXI4-Lite read/write handshake transactions:

    iverilog -g2012 -o interface.vvp ../rtl/interface.sv tb_interface.sv
    vvp interface.vvp > ../sim/interface_run.log

## Deviations from the M1 Plan
1. Filename Standardization: During early prototyping (Codefest 4), the compute core logic was developed under the file name hdc_core.sv. For Milestone 2, this module and its corresponding file have been officially renamed to compute_core.sv to ensure clean compatibility with automated grading scripts. 
2. Interface Implementation Name: The AXI4-Lite module is named axi_interface internally rather than interface to prevent syntax compiler crashes, as interface is a strictly reserved SystemVerilog keyword. The file name remains interface.sv.
3. Kernel Scope Focus: As defined in M1 profiling, the binding unit (parallel XOR) accounts for the vast majority of CPU execution time. M2 compute core RTL is scoped tightly to this XOR binding logic. The Bundling (Majority Vote) and Similarity (Hamming Distance) units will be integrated subsequently leading into M3.