### Arithmetic Intensity of HDC Binding Kernel

**1. Operations (OPs)**
In Hyperdimensional Computing, the dominant kernel is vector binding (element-wise XOR). We use Operations (OPs) rather than FLOPs because HDC relies on integer/binary logic, not floating-point math.
* Vector dimension: 10,000
* Operations per bind = **10,000 OPs** (XORs)

**2. Memory Traffic (Bytes)**
Assuming 32-bit integers (4 bytes per element) and no cache reuse (vectors loaded straight from DRAM):
* Load Vector A: 10,000 × 4 = 40,000 Bytes
* Load Vector B: 10,000 × 4 = 40,000 Bytes
* Store Output Vector C: 10,000 × 4 = 40,000 Bytes
* Total Bytes Transferred = **120,000 Bytes**

**3. Arithmetic Intensity (AI)**
* Formula: AI = OPs / Bytes
* Calculation: 10,000 / 120,000
* **AI = 0.0833 OPs/Byte**