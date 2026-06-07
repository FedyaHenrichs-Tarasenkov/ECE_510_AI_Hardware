# HDC Edge Accelerator (Milestone 4)

**Fedya Henrichs-Tarasenkov | ECE 410/510 Spring 2026**

## Project Overview
This repository contains the Milestone 4 (M4) final RTL, testbenches, and physical design reports for a custom Hyperdimensional Computing (HDC) Edge Accelerator. The ASIC is designed to accelerate the binding, bundling, and thresholding phases of HDC inference for real-time physiological signal processing (e.g., EMG gesture recognition).

### Key Architectural Features
* **Interface:** Custom 96-bit concatenated AXI-Stream interface to maximize memory bandwidth and eliminate AXI4-Lite handshake overhead.
* **Dataflow:** Output-Stationary processing via a 5-stage Finite State Machine (FSM). 10-bit intermediate accumulators remain on-chip to prevent system bus bottlenecks.
* **Precision:** 1-bit feature/base vectors, dynamically expanded to 10-bit during accumulation, and quantized back to 1-bit via parallel majority gates.
* **Scale:** Optimized for 1,024-dimension hypervectors (processed in 32-chunk sequential blocks).

## Performance vs. Baseline
Synthesized using the OpenLane 2 toolchain and the Sky130 PDK (100 MHz target):
* **Throughput:** 4.51 GOPS (1.70x speedup over the M1 CPU baseline).
* **Energy Efficiency:** 51.36 GOPS/W (~300x improvement over the 15W edge processor baseline).

## Directory Structure
* `rtl/` - SystemVerilog source code (`compute_core.sv`, `interface.sv`, `top.sv`).
* `tb/` - End-to-end transaction testbench (`tb_top.sv`).
* `sim/` - Simulation scripts, waveform generator, and `.vcd` outputs.
* `report/` - Contains the comprehensive `design_justification.pdf` and architectural diagrams.

## How to Run the Simulation
The testbench validates the 5-stage FSM against three continuous AXI-Stream corner cases: Standard Inference, Perfect Match, and Total Mismatch.

1. Navigate to the project root directory.
2. Execute the run script:
    `./run_m4.sh`
3. Check the terminal for PASS assertions. The resulting waveform trace will be saved as `final_waveform.vcd` and can be viewed using GTKWave.

## Detailed Documentation
For a complete roofline analysis, precision justifications, and OpenLane physical implementation details, please see the [Design Justification Report](report/design_justification.pdf).