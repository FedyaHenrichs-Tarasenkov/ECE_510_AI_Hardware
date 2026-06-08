# ECE 510 Spring 2026: Custom Hardware for AI & ML

**Name:** Fedya Henrichs-Tarasenkov

---

## Final Project Submission: Milestone 4

This repository houses the design, verification, and physical synthesis files for a custom, ultra-low-power **Hyperdimensional Computing (HDC) Edge Accelerator** designed for real-time electromyography (EMG) gesture recognition. Moving from a software baseline to a highly parallel spatial hardware architecture, the accelerator accelerates the binding, bundling, and distance calculation operations core to the HDC pipeline. 

### 🚀 Direct Links to Grading Deliverables
* **Final Sub-Project Directory:** [Milestone 4 (m4/) Folder](./project/m4/)
* **M4 Deliverables & File Catalog:** [Milestone 4 README](./project/m4/README.md)
* **Comprehensive Documentation:** [Design Justification Report (PDF)](./project/m4/report/design_justification.pdf)

---

## Core Architectural Progression

### Milestone 1 & 2: Mathematical Foundation
* **Module:** `compute_core.sv`
* **Precision:** Custom 1-bit Binary representation per dimension (XOR binding logic).
* **Dimensionality:** Originally targeted 10,000 dimensions; scaled to 1,024 dimensions in the physical layout to safely prevent out-of-memory compiler crashes during synthesis.

### Milestone 3: Register-Mapped Baseline
* **Interface:** 32-bit register-mapped AXI4-Lite bus.
* **Bottleneck:** While functional, multi-cycle handshakes and explicit address decoding created a severe memory-bound constraint, resulting in an active throughput speed-down (1.60 GOPS) relative to the software baseline.

### Milestone 4: Streaming & High-Throughput ASIC (Final Version)
* **Interface:** Custom 96-bit wide concatenated **AXI-Stream** interface.
* **Dataflow:** Strictly **Output-Stationary**. 10-bit intermediate accumulators are kept locally on-chip (`accum_ram`) during the bundling loop, ensuring heavy data paths never toggle external bus interconnect wires.
* **Interface Correction:** SystemVerilog interface dot-notation was flattened into a standard Verilog port list to prevent open-source synthesis tools (Yosys) from crashing during the OpenLane layout flow.

---

## Performance & Silicon Summary

The architecture was successfully hardcoded, routed, and timing-closed using the **OpenLane 2** compiler toolchain and the open-source **SkyWater 130nm PDK** targeted at a 100 MHz clock period constraint:

| Metric | M1 Software Baseline | M4 Hardware Accelerator | ASIC Benefit |
| :--- | :---: | :---: | :---: |
| **Max Frequency** | 3.2 GHz | **141.2 MHz** *(Post-PnR Static Timing)* | Native Hardware Limit |
| **Silicon Area** | N/A | **480,849.9 $\mu m^2$** | 50.03% Dedicated to Memory |
| **Power Draw** | 15.0 W | **87.8 mW** *(Post-Routing PSM)* | Ultra-Low-Power Edge Profile |
| **Measured Throughput** | 2.65 GOPS | **4.51 GOPS** | **1.70x Faster Processing** |
| **Energy Efficiency** | 0.17 GOPS/W | **51.36 GOPS/W** | **~300x Energy Reduction** |

### Verification Assertions
The design's FSM logic was co-simulated against three continuous streaming edge cases (Standard Inference, Perfect Match, and Total Mismatch), producing an annotated verification waveform trace that mathematically matches theoretical models. 

*To replicate simulation logs or examine physical area, timing, and power text reports, navigate directly into the **[project/m4/](./project/m4/)** subdirectory.*