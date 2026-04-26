import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge

@cocotb.test()
async def test_mac_basic(dut):
    """Basic functional test based on the professor's minimal code."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    dut.rst.value = 1
    dut.a.value = 0
    dut.b.value = 0
    await RisingEdge(dut.clk)
    
    dut.rst.value = 0
    dut.a.value = 3
    dut.b.value = 4
    
    for expected in [12, 24, 36]:
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)  # Wait half a cycle for the value to settle safely
        assert dut.out.value.signed_integer == expected
        
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await FallingEdge(dut.clk)
    assert dut.out.value.signed_integer == 0

@cocotb.test()
async def test_mac_overflow(dut):
    """Task 2: Overflow test to check if it wraps."""
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    
    dut.rst.value = 1
    dut.a.value = 0
    dut.b.value = 0
    await RisingEdge(dut.clk)
    
    dut.rst.value = 0
    dut.a.value = 127
    dut.b.value = 127
    
    for _ in range(133150):
        await RisingEdge(dut.clk)
        
    await FallingEdge(dut.clk)
    final_val = dut.out.value.signed_integer
    assert final_val < 0, "Error: MAC should wrap to a negative number."