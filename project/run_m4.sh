#!/bin/bash

# Compile using paths relative to the current script location
iverilog -g2012 -o m4/sim/m4_sim \
    m4/rtl/top.sv \
    m4/rtl/compute_core.sv \
    m4/rtl/interface.sv \
    m4/tb/tb_top.sv

# Run the simulation
./m4/sim/m4_sim > m4/sim/final_run.log

# Check status
if grep -q "PASS" m4/sim/final_run.log; then
    echo "Simulation passed! Log saved to m4/sim/final_run.log"
else
    echo "Simulation failed! Check m4/sim/final_run.log"
fi