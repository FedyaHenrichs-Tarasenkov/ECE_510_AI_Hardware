# CMAN: Arithmetic Intensity Analysis

**1. Kernel Identification & Dimensions**
* Dominant Kernel: 32-bit element-wise bitwise XOR (HDC Binding Operation).
* Dimensions: 10,000 dimensions per vector, processed in 32-bit (4-byte) parallel chunks per clock cycle.
* Data Type: Binary (1-bit precision per dimension, packed into 32-bit integers).
* Reuse Pattern: Streaming Vector-Vector Weight Reuse (Base vectors are cached on-chip; feature vectors stream in, are XOR'd, and the result streams out).

**2. FLOPs (BOPs) Count**
* Formula: 1 chunk = 32 parallel bitwise operations.
* Total: 32 BOPs per 32-bit chunk invocation.

**3. Arithmetic Intensity (AI) Bounds**
* Lower Bound (No Data Reuse):
  * Bytes Transferred: 4 Bytes (Read Vector A) + 4 Bytes (Read Vector B) + 4 Bytes (Write Output C) = 12 Bytes.
  * Formula: AI_lower = 32 BOPs / 12 Bytes
  * AI_lower = 2.66 BOPs/Byte

* Upper Bound (Streaming Weight Reuse):
  * Bytes Transferred: 4 Bytes (Read Vector A) + 0 Bytes (Vector B reused from on-chip register) + 4 Bytes (Write Output C) = 8 Bytes.
  * Formula: AI_upper = 32 BOPs / 8 Bytes
  * AI_upper = 4.00 BOPs/Byte

**4. Bottleneck Identification & Improvement**
* Current Bottleneck: The design is strictly memory-bound. The upper bound AI (4.0 BOPs/Byte) is lower than the hardware ridge point (8.0 BOPs/Byte). The 32-bit AXI4-Lite interface limits throughput to 0.4 GB/s, capping the attainable compute at 1.6 GOPS (well below the 3.2 GOPS compute ceiling).
* Highest-Leverage Improvement: Implement the HDC Bundling Unit to accumulate the bound vectors on-chip. By not writing the intermediate bound vectors back across the AXI bus, we drastically reduce outgoing memory traffic, increasing the AI and shifting the kernel toward the compute-bound region.