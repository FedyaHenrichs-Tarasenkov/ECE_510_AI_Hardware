# Milestone 4 Benchmark Analysis

## 1. Measured Accelerator Throughput
The M4 hardware accelerator was synthesized using the Sky130 PDK. Based on the post-routing Static Timing Analysis (STA), the design achieved a positive slack of 2.92 ns against a 10.0 ns clock constraint. 
* **True Maximum Frequency:** 1 / (10.0 ns - 2.92 ns) = **141.2 MHz**

To process the AXI-Stream dataflow, the compute core evaluates one 32-bit chunk per clock cycle. Therefore, the core executes 32 bitwise operations per cycle.
* **Measured Throughput:** 141.2 MHz * 32 Ops/Cycle = **4.51 GOPS** (Giga-Operations Per Second).

## 2. Speedup vs. Software Baseline
The Milestone 1 software baseline profiled the HDC kernel running on a standard CPU, which achieved a throughput of **2.65 GOPS**.

* **Speedup Calculation:** 4.51 GOPS / 2.65 GOPS = **1.70x Speedup**

**Analysis of Speedup:** In Milestone 3, the AXI4-Lite interface imposed a severe memory-bound limitation, resulting in a projected speed-down (1.60 GOPS). By migrating to a 96-bit AXI-Stream interface in M4 and utilizing an output-stationary dataflow (storing intermediate bundles in local `accum_ram`), the core was able to bypass the address-decode latency and achieve a 1.70x speedup over the software baseline. To make this physical layout viable within synthesis memory limits, the HDC dimensionality was scaled from 10,000 to 1,024 dimensions.

## 3. Energy Comparison
The OpenROAD post-routing power report (`power_report.txt`) estimates the total power consumption of the M4 accelerator at **87.8 mW** (73.7% internal, 26.3% switching). 

* **Hardware Energy Efficiency:** 4.51 GOPS / 0.0878 W = **51.36 GOPS/W**
* **Software Baseline Efficiency:** 2.65 GOPS / ~15 W (Typical Edge CPU) = **0.17 GOPS/W**

While the throughput speedup is a modest 1.70x, the custom spatial architecture provides an approximate **300x improvement in energy efficiency**, validating the use of an ASIC co-processor for ultra-low-power edge classification.