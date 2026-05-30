# Remaining Tasks for M4

1. **Integrate the Bundling Unit:** Implement the bitwise accumulator and majority gate thresholding logic to keep intermediate bound vectors on-chip, mitigating the current AXI4-Lite memory bandwidth bottleneck.
2. **Implement Similarity Check:** Design the Hamming Distance calculation block so the accelerator can output final scalar class predictions instead of streaming dense 10,000-bit vectors back to the host CPU.
3. **Configure Power Signoff:** Define the OpenROAD `VSRC_LOC_FILES` voltage source configuration inside the OpenLane `config.json` to resolve the missing/skipped synthesis power report for final PPA benchmarking.