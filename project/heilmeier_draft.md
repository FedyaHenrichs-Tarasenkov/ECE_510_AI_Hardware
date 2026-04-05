# Project Heilmeier Questions Draft

**Target Algorithm:** Hyperdimensional Computing (HDC) Classifier
**Target Application:** Real-time edge classification (e.g., EMG gesture recognition or language detection)
**Reference Codebase:** https://github.com/cumbof/hdlib (Pure Python HDC implementation)

**1. What are you trying to do? Articulate your objectives using absolutely no jargon.**
I am building a specialized hardware chiplet that classifies streaming sensor data using a brain-inspired AI approach. Instead of calculating complex math equations, this algorithm translates sensor data into massive, 10,000-bit "barcodes." The hardware will compare and combine these barcodes to recognize patterns, such as identifying a specific hand gesture from muscle sensors.

**2. How is it done today, and what are the limits of current practice?**
Currently, edge AI tasks are typically done using standard Neural Networks running on microcontrollers. The limit of current practice is that these networks rely on thousands of 32-bit floating-point multiplications. This math is computationally expensive, consumes significant battery power, and takes up a large physical footprint when translated to silicon, making it hard to deploy on tiny wearable devices.

**3. What is new in your approach and why do you think it will be successful?**
My approach abandons floating-point multiplications entirely. By accelerating a Hyperdimensional Computing (HDC) algorithm in custom hardware, the complex math is replaced by massive arrays of simple binary logic gates (like XOR and bit-counting). I think this will be successful because binary logic is incredibly cheap and fast in silicon, allowing the chiplet to achieve high classification accuracy while using a fraction of the power and area of a traditional AI accelerator.