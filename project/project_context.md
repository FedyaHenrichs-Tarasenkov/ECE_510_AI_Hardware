# HDC Accelerator Project Context

**User:** Fedya Henrichs-Tarasenkov
**Course:** ECE 410/510 Hardware for AI and ML
**Current Phase:** Milestone 2 (M2) Completed / Entering Milestone 3 (M3)

## Architecture Overview
* **Target Algorithm:** Hyperdimensional Computing (HDC) Classifier.
* **Application:** Ultra-low-power edge classification (real-time EMG gesture recognition).
* **Hardware Paradigm:** Custom co-processor chiplet bypassing standard CPU memory bottlenecks via data localization.
* **Vector Dimensions:** 10,000 dimensions per vector.

## Technical Specifications
* **Precision:** Custom Binary (1-bit precision per dimension).
* **Data Path:** Vectors are processed in 32-bit chunks per clock cycle (DATA_WIDTH = 32).
* **Hardware Interface:** 32-bit AXI4-Lite bus running at 100 MHz.
* **Bandwidth Capacity vs. Requirement:** 400 MB/s peak capacity versus 80 MB/s requirement for 2,000 samples/sec real-time throughput. 

## Core Hardware Units
* **On-Chip Memory:** Item Memory (IMEM) for Base Vectors and Associative Memory (AMEM) for Class Vectors (DRAM Bypass).
* **Binding Unit:** 32-bit parallel bitwise XOR array (Synthesized in M2).
* **Bundling Unit:** Bitwise Accumulator / Majority Gate thresholding (Pending M3).
* **Similarity Check:** Hamming Distance calculation (Pending M3).

## Current Project Status
* **M1:** Software Baseline (309k samples/sec) & Roofline analysis completed. 
* **Codefest 4:** Initial `cocotb` transition completed.
* **M2:** RTL for Compute Core (Binding Unit) and AXI4-Lite Interface fully implemented in synthesizable SystemVerilog.
* **M2 Verification:** Both modules verified using Icarus Verilog testbenches. Handshakes and data integrity confirmed with generated logs and GTKWave waveforms.
* **Precision Justification:** 1-bit binary precision formally analyzed, yielding a 32x memory compression factor with an acceptable -2.3% accuracy delta.