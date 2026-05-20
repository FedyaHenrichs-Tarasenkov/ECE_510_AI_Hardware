# CF08 CMAN: AER Bandwidth Analysis

## 1. Mean Aggregate Spike Rate
Formula: R = N * f
Substituted values: R = 1024 * 50
R = 51200 spikes/second

## 2. Mean AER Bandwidth
Formula: B = R * 20 bits/packet
Substituted values: B = 51200 * 20 = 1024000 bits/second
B = 1.024 Mbit/s

## 3. Interface Comparison
| Interface | Max Bandwidth | Sustain Mean Rate? |
| :--- | :--- | :--- |
| I2C | 3.4 Mbit/s | Y |
| SPI | 50 Mbit/s | Y |
| AXI4-Lite | 100 Mbit/s | Y |

Lowest-complexity interface that suffices: I2C (it sustains the 1.024 Mbit/s mean rate while requiring only 2 pins, making it much lower complexity than SPI or AXI4-Lite).

## 4. Burst Analysis
* Burst spikes: 1024 * 0.25 = 256 spikes
* Burst bits: 256 spikes * 20 bits/packet = 5120 bits
* Burst-peak bandwidth: 5120 bits / 0.001 seconds = 5120000 bits/second = 5.12 Mbit/s
* Burst-to-mean ratio: 5.12 / 1.024 = 5.0

Buffering decision: The chosen I2C interface (3.4 Mbit/s) cannot absorb the 5.12 Mbit/s peak instantaneous burst. Buffering is required. In a 1 ms window, the burst generates 5120 bits, but I2C can only drain 3400 bits, meaning a buffer depth of at least 1720 bits (86 packets) is needed to prevent dropped spikes.

## 5. Frame-Based Comparison
* Frame-based bandwidth: 1024 neurons * 1 bit/neuron * 1000 samples/second = 1024000 bits/second = 1.024 Mbit/s
* AER/frame ratio at f=50 Hz: 1.024 / 1.024 = 1.0
* f_crossover calculation: f_crossover * 20 = 1000
* f_crossover = 50 Hz

Implication: AER is the right choice only when neural activity is highly sparse (average firing rate below the 50 Hz crossover threshold), because at higher firing rates, the continuous overhead of sending 20-bit addresses wastes more bandwidth than simply sending a dense 1024-bit frame.