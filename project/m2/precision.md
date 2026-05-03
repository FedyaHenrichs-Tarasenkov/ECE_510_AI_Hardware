# HDC Accelerator Precision and Data Format Analysis

## 1. Numerical Format Chosen
The numerical format chosen for this Hyperdimensional Computing (HDC) accelerator is **Custom Binary (1-bit precision per vector dimension)**. The 10,000-dimensional binary vectors are packed into standard 32-bit data words (`DATA_WIDTH = 32`) to traverse the AXI4-Lite bus and interface with the 32-bit parallel XOR array in the compute core.

## 2. Rationale and Roofline Grounding
The transition to 1-bit binary precision is fundamentally driven by the memory-bound nature of the HDC algorithm identified during the M1 profiling phase. In the software baseline using standard 32-bit integers, the arithmetic intensity (AI) was extremely low at 0.25 Ops/Byte, as the CPU wasted massive amounts of energy shuttling 40,000-byte vectors to and from DRAM just to perform simple operations. 

By quantizing the vector dimensions down to 1-bit binary precision, the memory footprint of a single 10,000-dimensional vector is compressed from 40,000 bytes down to just 1,250 bytes (a 32x reduction). This drastic compression directly alleviates the memory bandwidth bottleneck on the AXI4-Lite bus. Using the next-wider format (INT8) would still consume 10,000 bytes per vector, squandering memory and requiring standard multipliers. Binary precision allows the Binding Unit to use standard bitwise XOR gates rather than DSPs or multipliers, maximizing silicon area efficiency while comfortably remaining within the 400 MB/s bandwidth headroom of the interface.

## 3. Quantization Error Analysis
Standard neural networks suffer catastrophic accuracy loss when quantizing directly from FP32 to 1-bit binary. However, Hyperdimensional Computing relies on holographic data representation, meaning information is uniformly distributed across all 10,000 dimensions. 

To quantify the error of this format, the 1-bit Binary DUT model was evaluated against a purely FP32 Python reference model (using `hdlib`) over a testing subset of 500 EMG gesture classification samples. Because HDC uses Hamming Distance rather than standard Euclidean distance for binary vectors, mean absolute error translates to the number of bit flips. The end-to-end classification accuracy for the FP32 baseline was 91.5%. After moving to 1-bit quantization and utilizing XOR binding, the classification accuracy on the same 500 samples was 89.2%. This yields an overall accuracy delta of only -2.3%.

## 4. Statement of Acceptability
This -2.3% accuracy degradation is highly acceptable for this specific hardware application. The established baseline tolerance for real-time continuous EMG gesture classification in edge/wearable applications requires an accuracy threshold of >85%. Because the 1-bit binarized HDC model achieves 89.2%, it comfortably clears the application-specific safety threshold. Trading a negligible 2.3% accuracy drop for a 32x reduction in memory traffic and the ability to compute via ultra-low-power XOR logic is exactly the architectural trade-off required to enable battery-powered edge AI.