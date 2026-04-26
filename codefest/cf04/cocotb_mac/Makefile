SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Point to your correct module from the CLLM section
VERILOG_SOURCES += $(PWD)/../hdl/mac_correct.v

TOPLEVEL = mac
MODULE = test_mac

# Force Icarus to generate a waveform dump file
WAVES = 1

include $(shell cocotb-config --makefiles)/Makefile.sim