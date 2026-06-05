`timescale 1ns / 1ps

module top (
    input  logic        clk,
    input  logic        rst,

    // AXI-Stream Slave (Inbound from Host)
    input  logic        s_axis_tvalid,
    input  logic [95:0] s_axis_tdata,
    input  logic        s_axis_tlast,
    output logic        s_axis_tready,

    // AXI-Stream Master (Outbound to Host)
    output logic        m_axis_tvalid,
    output logic [95:0] m_axis_tdata,
    output logic        m_axis_tlast,
    input  logic        m_axis_tready
);

    // Internal wires connecting the interface to the compute core
    logic        core_s_valid, core_s_last, core_s_ready;
    logic [95:0] core_s_data;
    
    logic        core_m_valid, core_m_last, core_m_ready;
    logic [95:0] core_m_data;

    stream_interface #(.DATA_WIDTH(96)) intf_inst (
        .ext_s_tvalid(s_axis_tvalid),
        .ext_s_tdata(s_axis_tdata),
        .ext_s_tlast(s_axis_tlast),
        .ext_s_tready(s_axis_tready),
        .ext_m_tvalid(m_axis_tvalid),
        .ext_m_tdata(m_axis_tdata),
        .ext_m_tlast(m_axis_tlast),
        .ext_m_tready(m_axis_tready),
        
        .core_s_tvalid(core_s_valid),
        .core_s_tdata(core_s_data),
        .core_s_tlast(core_s_last),
        .core_s_tready(core_s_ready),
        .core_m_tvalid(core_m_valid),
        .core_m_tdata(core_m_data),
        .core_m_tlast(core_m_last),
        .core_m_tready(core_m_ready)
    );

    compute_core #(
        .NUM_CHUNKS(32),       // 1024 dimensions
        .COUNTER_WIDTH(10)
    ) core_inst (
        .clk(clk),
        .rst(rst),
        .s_axis_tvalid(core_s_valid),
        .s_axis_tdata(core_s_data),
        .s_axis_tlast(core_s_last),
        .s_axis_tready(core_s_ready),
        
        .m_axis_tvalid(core_m_valid),
        .m_axis_tdata(core_m_data),
        .m_axis_tlast(core_m_last),
        .m_axis_tready(core_m_ready)
    );

endmodule