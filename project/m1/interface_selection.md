# Interface Selection: AXI4-Lite

**1. Chosen Interface:** AXI4-Lite
**2. Assumed Host Platform:** FPGA SoC (e.g., Xilinx Zynq where an ARM CPU acts as the host and the accelerator is in programmable logic).

**3. Target Bandwidth Calculation:**
To classify a real-time signal at a high sampling rate, let's assume a target throughput of 2,000 samples/sec. 
* Data Width: 10,000 dimensions × 4 bytes (int32) = 40,000 bytes per encoded feature vector.
* Required Bandwidth = 2,000 samples/sec × 40,000 bytes/sample = 80,000,000 bytes/sec (**80 MB/s**).

**4. Bottleneck Status:**
A standard 32-bit AXI4-Lite bus running at a modest 100 MHz provides a theoretical peak bandwidth of 400 MB/s. 
Because the required bandwidth (80 MB/s) is well below the rated bandwidth (400 MB/s), the design is **not interface-bound**. The data can comfortably stream into the chiplet without starving the compute engine.