# HDC Accelerator Project Context

**User:** Fedya Henrichs-Tarasenkov
**Course:** ECE 410/510 Hardware for AI and ML
**Current Phase:** Entering Milestone 2 / 3

## Architecture Overview
* **Target Algorithm:** Hyperdimensional Computing (HDC) Classifier.
* **Application:** Ultra-low-power edge classification (e.g., real-time EMG gesture recognition).
* **Hardware Paradigm:** Custom co-processor chiplet overcoming standard CPU memory bandwidth bottlenecks.
* **Vector Dimensions:** $10,000$ dimensions per vector.

## Technical Specifications
* **Precision:** Binary (1-bit precision per dimension).
* **Data Path:** Vectors are processed in 32-bit chunks per clock cycle (`DATA_WIDTH = 32`).
* **Hardware Interface:** 32-bit AXI4-Lite bus running at 100 MHz (Peak capacity: 400 MB/s).
* **Bandwidth Requirement:** 80 MB/s (to achieve 2,000 samples/sec real-time throughput). Design is compute-bound, NOT interface-bound.

## Core Hardware Units
1. **On-Chip Memory:** * Item Memory (IMEM) for Base Vectors.
   * Associative Memory (AMEM) for Class Vectors.
2. **Compute Engine:**
   * **Binding Unit:** Bitwise XOR gates (`hdc_core.sv`).
   * **Bundling Unit:** Bitwise Accumulator / Majority Gate thresholding.
   * **Similarity Check:** Hamming Distance calculation.

## Current Project Status
* M1 (Software Baseline & Roofline) completed. 
* Codefest 4 (cocotb transition) completed.
* AXI4-Lite interface and Binding Unit (`hdc_core.sv`) stub verified in `cocotb`.