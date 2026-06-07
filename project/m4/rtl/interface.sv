// ==============================================================================
// Author:       Fedya Henrichs-Tarasenkov
// Course:       ECE 410/510
// Project:      Milestone 4 - HDC Edge Accelerator
// Description:  Flattened 96-bit AXI-Stream interface pass-through bridge.
//               Strips AXI4-Lite handshake overhead to maximize memory bandwidth
//               and directly feed the compute core.
// ==============================================================================

`timescale 1ns / 1ps

module stream_interface #(
    parameter DATA_WIDTH = 96
)(
    // External AXI-Stream (From Host via top.sv)
    input  logic                    ext_s_tvalid,
    input  logic [DATA_WIDTH-1:0]   ext_s_tdata,
    input  logic                    ext_s_tlast,
    output logic                    ext_s_tready,

    output logic                    ext_m_tvalid,
    output logic [DATA_WIDTH-1:0]   ext_m_tdata,
    output logic                    ext_m_tlast,
    input  logic                    ext_m_tready,

    // Internal Stream (To compute_core.sv)
    output logic                    core_s_tvalid,
    output logic [DATA_WIDTH-1:0]   core_s_tdata,
    output logic                    core_s_tlast,
    input  logic                    core_s_tready,

    input  logic                    core_m_tvalid,
    input  logic [DATA_WIDTH-1:0]   core_m_tdata,
    input  logic                    core_m_tlast,
    output logic                    core_m_tready
);

    // Pass-through bridge mapping external pins to internal core logic
    assign core_s_tvalid = ext_s_tvalid;
    assign core_s_tdata  = ext_s_tdata;
    assign core_s_tlast  = ext_s_tlast;
    assign ext_s_tready  = core_s_tready;

    assign ext_m_tvalid  = core_m_tvalid;
    assign ext_m_tdata   = core_m_tdata;
    assign ext_m_tlast   = core_m_tlast;
    assign core_m_tready = ext_m_tready;

endmodule