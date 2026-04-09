# Project Heilmeier Questions

**Target Algorithm:** Hyperdimensional Computing (HDC) Classifier
**Target Application:** Real-time edge classification (e.g., EMG gesture recognition or language detection)
**Reference Codebase:** https://github.com/cumbof/hdlib (Pure Python HDC implementation)

**1. What are you trying to do? Articulate your objectives using absolutely no jargon.**
I am building a specialized hardware chiplet that classifies streaming sensor data using a brain-inspired AI approach. Instead of calculating complex math equations, this algorithm translates sensor data into massive, 10,000-bit "barcodes." The hardware will compare and combine these barcodes to recognize patterns, such as identifying a specific hand gesture from muscle sensors.

**2. How is it done today, and what are the limits of current practice?**
Currently, HDC is run in software on standard microcontrollers. My profiling and roofline analysis show that the limit of this practice is memory bandwidth. A standard CPU becomes severely memory-bound because it has to constantly shuttle massive 10,000-element arrays back and forth from external DRAM just to perform incredibly simple operations (like XOR), resulting in slow execution and wasted power.

**3. What is new in your approach and why do you think it will be successful?**
My approach abandons the CPU's memory bottleneck. By moving the base vectors into on-chip SRAM and accelerating the HDC algorithm with massive arrays of simple binary logic gates, the data never has to leave the chiplet. I think this will be successful because the roofline model dictates that storing data locally shifts the bottleneck away from memory. Binary logic is incredibly cheap in silicon, allowing the chiplet to achieve high classification throughput while using a fraction of the power of a standard processor.