Run. Execute make SIM=icarus. Commit the simulation log and VCD waveform file.
2. Overflow test. Add a second test function test_mac_overflow that checks behavior when the
accumulator approaches 2³¹− 1. Does the design saturate or wrap? Document the behavior.
3. Waveform. Open the VCD in GTKWave (gtkwave dump.vcd). Add clk, rst, a, b, and out. Screenshot
to codefest/cf04/cocotb_mac/waveform.png.