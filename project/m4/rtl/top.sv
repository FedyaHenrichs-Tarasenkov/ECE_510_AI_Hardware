`timescale 1ns / 1ps

/* -----------------------------------------------------------------------------
 * File:        top.sv
 * Description: Integrated Top-Level Module for the AXI-Stream HDC Accelerator.
 * ----------------------------------------------------------------------------- */

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

    // Instantiate the interfaces defined in interface.sv
    axis_if #(.DATA_WIDTH(96)) s_intf();
    axis_if #(.DATA_WIDTH(96)) m_intf();

    // Bind inbound top-level ports to the slave interface
    assign s_intf.tvalid = s_axis_tvalid;
    assign s_intf.tdata  = s_axis_tdata;
    assign s_intf.tlast  = s_axis_tlast;
    assign s_axis_tready = s_intf.tready;

    // Bind outbound top-level ports to the master interface
    assign m_axis_tvalid = m_intf.tvalid;
    assign m_axis_tdata  = m_intf.tdata;
    assign m_axis_tlast  = m_intf.tlast;
    assign m_intf.tready = m_axis_tready;

    // Instantiate the compute core
    compute_core #(
        .NUM_CHUNKS(32),       // 1024 dimensions
        .COUNTER_WIDTH(10)     // Max bundle count of 1023
    ) core_inst (
        .clk(clk),
        .rst(rst),
        .s_axis(s_intf.slave),
        .m_axis(m_intf.master)
    );

endmodule