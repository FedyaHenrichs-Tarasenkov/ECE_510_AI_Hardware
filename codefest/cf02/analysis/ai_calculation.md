**The dominant kernel is vector binding (np.bitwise_xor), accounting for >90% of the total runtime in the processing loop.**

### Arithmetic Intensity Calculation

**1. FLOPs (Operations)**
In Hyperdimensional Computing, the dominant kernel is vector binding (element-wise XOR). While HDC uses integer binary logic rather than floating-point math, we count these Operations (OPs) as FLOP-equivalents for the standard roofline model.
* Vector dimension: 10,000
* FLOPs per bind = **10,000 FLOPs** (XORs)

**2. Memory Traffic (Bytes)**
Assuming 32-bit integers (4 bytes per element) and no cache reuse (vectors loaded straight from DRAM):
* Load Vector A (Input): 10,000 × 4 = 40,000 Bytes
* Load Vector B (Base/Weight): 10,000 × 4 = 40,000 Bytes
* Store Output Vector C: 10,000 × 4 = 40,000 Bytes
* Total Bytes Transferred = **120,000 Bytes**

**3. Arithmetic Intensity (AI)**
* Formula: AI = FLOPs / Bytes
* Calculation: 10,000 / 120,000
* **AI = 0.0833 FLOP/Byte**