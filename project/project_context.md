HDC Accelerator Project Context (Final M4 State)
User: Fedya Henrichs-Tarasenkov

Course: ECE 410/510 Hardware for AI and ML

Current Phase: Milestone 4 (M4) Implementation Complete / Entering Reporting & Documentation Phase

1. Architecture Overview
Target Algorithm: Hyperdimensional Computing (HDC) Classifier.

Application: Ultra-low-power edge classification (real-time EMG gesture recognition).

Dimensionality Scaling: Vectors are scaled to 1,024 dimensions (NUM_CHUNKS = 32). This reduction from the standard 10,000D was a deliberate engineering tradeoff to reduce sequential flip-flop count from ~100,000 down to ~10,240, ensuring ASIC synthesis viability within 16GB cloud memory constraints.

Dataflow Paradigm: Output-Stationary. Intermediate bundling totals are kept inside local accum_ram, bypassing external memory traffic bottlenecks.

2. Technical Specifications
Hardware Interface: 96-bit AXI-Stream protocol (migrated from AXI4-Lite). The host streams the Base Vector, Feature Vector, Threshold, and Opcode simultaneously on the same clock cycle, completely saturating the compute core and eliminating address-decode latency.

Precision: Custom Binary (1-bit precision per dimension for class/feature vectors, 10-bit precision for accumulator bundles).

Physical Constraints: 1000×1000μm absolute die size. Target placement density: 55%.

Operating Frequency Target: 100MHz (10.0ns clock period).

3. Core Hardware Units & RTL Fixes
Stream Interface (interface.sv): Implemented as a flattened standard Verilog module rather than a SystemVerilog interface construct to bypass known Yosys AST generation bugs during synthesis.

Compute Core (compute_core.sv): * Executes 5 opcodes: OP_CLEAR, OP_ACCUM, OP_THRESH, OP_INFER, OP_READ_HD.

Memory Flattening: Local SRAM (accum_ram) was flattened into a 1D [319:0] array. This successfully bypassed a severe bug in the Icarus Verilog simulator where dynamic bit-slicing within 2D arrays injected 'x (unknown) states into the thresholding logic.

4. M4 Project Status: SUCCESS
RTL Simulation: PASSED. The full testbench correctly output a Hamming Distance of 512 for the 1024-dimension test vectors. Log saved to final_run.log.

ASIC Synthesis & Routing: PASSED. The design successfully routed 100% of standard cells with zero DRC violations.

Timing: CLOSED (MET). The design achieved a positive slack of +2.92ns.

Calculated True Maximum Frequency: 1/(10.0−2.92ns)=141.2 MHz.

Area: 480,849.9μm 
2
 , with sequential flip-flops accounting for 50.03% of the total chip area.

Power: 87.8mW total power (73.7% Internal, 26.3% Switching).

Sign-off Quirk: The OpenROAD PSM (PowerGrid Simulation) tool threw a [PSM-0028] error at the very end. This only affected the generation of an optional visual voltage-drop PDF and did not impact the physical routing or standard power report.

5. Outstanding Work for Sunday Deadline (The Final Checklist)
Code & Repo Administration
[ ] Generate Waveform: Open project/m4/sim/final_waveform.vcd in GTKWave, zoom in on the AXI-Stream transaction, take a screenshot, and save it as project/m4/sim/final_waveform.png.

[ ] M4 README: Create project/m4/README.md cataloging every file in the M4 folder with a 1-line description mapping it to the rubric.

[ ] Top-Level README: Update the root README.md to point directly to the M4 folder and the final design justification PDF.

Benchmarking (project/m4/bench/)
[ ] Benchmark CSV: Fill out benchmark_data.csv with the measured hardware metrics (141.2 MHz, 87.8 mW, 1024 dimensions) vs. the M1 software baseline.

[ ] Calculate Speedup: Determine the speedup ratio in benchmark.md and explain how AXI-Stream alleviated the memory-bound constraints observed in M3.

[ ] Final Roofline Plot: Generate roofline_final.png showing the actual measured M4 accelerator point (not the hypothetical M1 point).

Design Justification Report (project/m4/report/design_justification.pdf)
[ ] Write the 9 Sections: (Problem/Motivation, Roofline Analysis, Precision, Dataflow, Hardware Interface, Verification, Synthesis Results, Benchmark Results, What Did Not Work).

[ ] Key "What Did Not Work" Talking Points to Include:

Simulation: The Icarus Verilog 'x state bug required flattening the 2D memory arrays into 1D vectors.

Synthesis Tooling: The Yosys AST bug required downgrading the SystemVerilog interface into a standard module.

Physical Layout RAM Limits: 10,000 dimensions required ~100k flip-flops, causing OpenROAD to exhaust cloud memory during detailed routing. Scaling to 1,024 dimensions and migrating from AXI4-Lite to AXI-Stream saved the physical layout while maintaining HDC algorithmic integrity.

IR Drop Report: Document the [PSM-0028] power grid naming error during sign-off.

[ ] Word Count Check: Ensure the final PDF is strictly between 2,000 and 5,000 words.

Final Submission
[ ] Commit all newly generated files and the PDF report.

[ ] Push to GitHub: git push origin main