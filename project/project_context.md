HDC Accelerator Project Context
User: Fyodor Henrichs-Tarasenkov
Course: ECE 410/510 Hardware for AI and ML
Current Phase: Milestone 3 (M3) Completed / Entering Milestone 4 (M4)

Architecture Overview
Target Algorithm: Hyperdimensional Computing (HDC) Classifier.

Application: Ultra-low-power edge classification (real-time EMG gesture recognition).

Hardware Paradigm: Custom co-processor chiplet bypassing standard CPU memory bottlenecks via data localization.

Vector Dimensions: 10,000 dimensions per vector.

Technical Specifications
Precision: Custom Binary (1-bit precision per dimension).

Data Path: Vectors are processed in 32-bit chunks (DATA_WIDTH = 32).

Hardware Interface: Integrated AXI4-Lite slave interface running at 100 MHz.

Physical Constraints: Absolute die sizing (250x250 µm) to mitigate pin-bound limitations.

Core Hardware Units
On-Chip Memory: Item Memory (IMEM) for Base Vectors and Associative Memory (AMEM) for Class Vectors (DRAM Bypass).

Binding Unit: 32-bit parallel bitwise XOR array (Synthesized, M2).

Bundling Unit: Bitwise Accumulator / Majority Gate thresholding (Pending M4).

Similarity Check: Hamming Distance calculation (Pending M4).

Project Status
M1: Software Baseline & Roofline analysis completed.

M2: RTL for Binding Unit and AXI4-Lite Interface fully implemented in synthesizable SystemVerilog.

M3: * Successful full-chip integration (top.sv).

Full end-to-end co-simulation passed (PASS in cosim_run.log).

Synthesis flow completed via OpenLane 2 (absolute die size: 250x250 µm, clock: 100 MHz).

Antenna violations documented in synthesis_notes.md.

Critical path analysis identified reset fanout as the primary bottleneck.

Next Steps for Milestone 4
Implement and integrate the Bundling Unit (Bitwise Accumulator / Majority Gate).

Implement the final Similarity Check (Hamming Distance) stage.

Perform full power/area/performance (PPA) benchmarking using the M1 software baseline as the point of comparison.

Resolve any outstanding LVS/DRC or antenna issues through iterative floorplan adjustment.