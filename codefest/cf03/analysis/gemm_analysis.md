### CUDA GEMM Analysis

**(a) Why the naive kernel is memory-bound (and the roofline anomaly):**
Theoretically, the naive algorithm is severely memory-bound. With an arithmetic intensity of just 0.25 FLOP/byte, the T4's global DRAM bandwidth (320 GB/s) should strictly cap its performance at 80 GFLOP/s. However, on our Roofline plot, the naive kernel achieves ~297 GFLOP/s, seemingly breaking the physical DRAM ceiling. 

This is not a graphing error, but a testament to the hardware. As proven by the Nsight Compute profile, the kernel only utilized 7.2% DRAM throughput but hit 93.7% L1 Cache throughput. The Tesla T4's massive hardware cache intercepted the redundant matrix accesses. Therefore, while the underlying algorithm is mathematically memory-bound, it is physically bound by the much higher L1 cache bandwidth ceiling (~4000 GB/s) rather than global DRAM.

**(b) How tiling reduces DRAM traffic:**
Tiling mitigates this by loading a $T \times T$ block of data from slow global DRAM into ultra-fast, on-chip shared memory. The threads in the block then compute all their partial dot-products using that shared memory. Because each loaded element is reused $T$ times before the next tile is needed, total DRAM traffic is mathematically reduced by a factor of $T$. 

**(c) Tiled improvement and remaining bottlenecks:**
Despite the mathematical reduction in DRAM traffic, the tiled kernel did *not* achieve the expected performance improvement (dropping from ~297 GFLOP/s naive to ~289 GFLOP/s tiled). The Nsight Compute profiler explicitly flagged the tiled kernel for latency issues, dropping SM active cycles to 55%. The remaining bottleneck is **occupancy and latency**. The required tile size of $T=8$ yields block dimensions of 8x8, meaning there are only 64 threads (2 warps) per block. This is far too few threads for the GPU scheduler to effectively hide instruction and memory latency. Furthermore, the explicit `__syncthreads()` barriers added overhead that negated the shared memory benefits, especially since the T4's hardware cache was already highly optimizing the naive accesses.