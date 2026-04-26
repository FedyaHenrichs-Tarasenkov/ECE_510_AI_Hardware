import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge

@cocotb.test()
async def test_hdc_binding(dut):
    """Basic testbench stub for the HDC Binding Unit."""
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    # 1. Initialize and drive reset
    dut.rst.value = 1
    dut.s_axi_valid.value = 0
    dut.s_axi_data_a.value = 0
    dut.s_axi_data_b.value = 0
    dut.m_axi_ready.value = 1  
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

    # 2. Apply one representative input (Binding two binary chunks)
    await RisingEdge(dut.clk)
    dut.s_axi_valid.value = 1
    # Example: a = 1010 (Decimal 10), b = 1100 (Decimal 12)
    # Expected XOR out: 0110 (Decimal 6)
    dut.s_axi_data_a.value = 10
    dut.s_axi_data_b.value = 12
    
    await RisingEdge(dut.clk)
    dut.s_axi_valid.value = 0 
    
    await FallingEdge(dut.clk)
    
    output_val = dut.m_axi_data.value.integer
    dut._log.info(f"Valid: {dut.m_axi_valid.value}")
    dut._log.info(f"Bound Vector Output: {output_val}")
    
    assert output_val == 6, f"Expected XOR result 6, got {output_val}"