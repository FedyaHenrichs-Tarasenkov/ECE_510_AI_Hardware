# ECE 510 Spring 2026 

**Name:** Fedya Henrichs-Tarasenkov

## Project Compute Core Architecture
**Module:** Hyperdimensional Computing (HDC) Binding Unit (`hdc_core.sv`)
**Precision:** Binary (1-bit precision per dimension, processed in 32-bit chunks)
**Interface:** AXI4-Lite

**Interface & Arithmetic Intensity Justification:**
Based on the Milestone 1 profiling, the HDC vector binding operation accounts for >90% of the runtime on a standard CPU due to the memory bottleneck of shuttling massive 10,000-element arrays. By moving the base vectors into on-chip memory and computing with simple binary logic (XOR gates), the data remains highly localized. 

A standard 32-bit AXI4-Lite interface running at 100 MHz provides a theoretical peak bandwidth of 400 MB/s. To achieve a real-time target throughput of 2,000 samples/sec (at 40,000 bytes per encoded feature vector), the hardware requires a bandwidth of 80 MB/s. Because the required bandwidth is well below the rated capacity of the interface, the AXI4-Lite protocol was chosen. It provides a simple, standard integration path for an FPGA SoC without starving the compute engine, ensuring the design is not interface-bound.