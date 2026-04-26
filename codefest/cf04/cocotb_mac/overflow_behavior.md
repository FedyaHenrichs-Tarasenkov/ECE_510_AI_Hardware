# MAC Overflow Behavior Analysis

**Test Executed:** `test_mac_overflow`
**Inputs Applied:** `a = 127`, `b = 127` (Product = 16,129 per cycle)
**Cycles Run:** 133,150

**Observed Behavior: Wrapping**
When the 32-bit signed accumulator exceeds its maximum positive value of $2^{31}-1$ (2,147,483,647), the design **wraps** rather than saturating. 

Because the `mac_correct.v` module uses standard SystemVerilog addition (`out <= out + (a * b)`) without any explicit overflow-catching or clamping logic, it exhibits standard 2's complement rollover. The moment the value pushes past the 32-bit integer limit, the MSB (sign bit) flips to `1`, causing the value to violently wrap around to a massive negative number. In the simulation, the value immediately following the threshold breach was read as `-2,147,390,946`.