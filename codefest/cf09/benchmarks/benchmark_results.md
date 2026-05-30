# CLLM: Accelerator Benchmarking Results

*Note: M3 hardware metrics are projected based on the fallback path using the OpenLane 2 synthesis target of 100 MHz and a 32-bit AXI4-Lite memory bandwidth limit (0.4 GB/s). The upper-bound AI of 4.0 BOPs/Byte yields a memory-bound attainable throughput of 1.6 GOPS.*

| Platform | Execution Scenario | Execution Time (ms) | Throughput (GOPS) | Memory Usage | Energy Efficiency |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **M1 SW Baseline** | Apple Mac (Dual-Core) | 188.3 ms | 2.65 | 22.47 MB | N/A |
| **M3 HW Accelerator** | Sky130 ASIC (Projected) | N/A (Projected) | 1.60 | N/A (Projected) | 0.7 mW (Power) |

**Speedup Ratio (HW/SW):** 0.60x 
*(Note: Current implementation is an I/O bottlenecked intermediate stage; speedup is expected to exceed 1.0x upon integration of M4 on-chip accumulation).*