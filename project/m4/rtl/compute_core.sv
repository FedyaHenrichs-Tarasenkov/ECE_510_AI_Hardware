// ==============================================================================
// Author:       Fedya Henrichs-Tarasenkov
// Course:       ECE 410/510 
// Project:      Milestone 4 - HDC Edge Accelerator
// Description:  5-stage Output-Stationary Finite State Machine for calculating
//               Hyperdimensional Computing (HDC) binding, bundling, and 
//               Majority Gate thresholding. Accumulates 1,024-dimension vectors.
// ==============================================================================

`timescale 1ns / 1ps

module compute_core #(
    parameter NUM_CHUNKS = 32,   // 1024 Dimensions
    parameter COUNTER_WIDTH = 10
)(
    input  logic clk,
    input  logic rst,
    
    // Inbound Stream
    input  logic        s_axis_tvalid,
    input  logic [95:0] s_axis_tdata,
    input  logic        s_axis_tlast,
    output logic        s_axis_tready,

    // Outbound Stream
    output logic        m_axis_tvalid,
    output logic [95:0] m_axis_tdata,
    output logic        m_axis_tlast,
    input  logic        m_axis_tready
);

    localparam OP_CLEAR   = 3'b000;
    localparam OP_ACCUM   = 3'b001;
    localparam OP_THRESH  = 3'b010;
    localparam OP_INFER   = 3'b011;
    localparam OP_READ_HD = 3'b100;

    logic [31:0] base_vec;
    logic [31:0] feat_vec;
    logic [15:0] threshold_val;
    logic [2:0]  opcode;
    logic [9:0] safe_thresh;
    assign safe_thresh = threshold_val[9:0];

    assign base_vec      = s_axis_tdata[95:64];
    assign feat_vec      = s_axis_tdata[63:32];
    assign threshold_val = s_axis_tdata[31:16];
    assign opcode        = s_axis_tdata[2:0];

    // Flat 1D arrays to completely bypass Icarus slicing bugs
    logic [319:0] accum_ram [0 : NUM_CHUNKS - 1];
    logic [31:0]  class_ram [0 : NUM_CHUNKS - 1];

    logic [8:0]  chunk_ptr;
    logic [15:0] hd_count;

    assign s_axis_tready = m_axis_tready;

    // Combinational flattening variables
    logic [319:0] current_accum;
    logic [319:0] next_accum;
    logic [31:0]  thresh_chunk;
    
    assign current_accum = accum_ram[chunk_ptr];
    
    logic [31:0] bound_chunk;
    assign bound_chunk = base_vec ^ feat_vec;

    always_comb begin
        next_accum = current_accum;
        thresh_chunk = 32'b0;
        for (int i=0; i<32; i++) begin
            // Explicit sizing prevents 'x' propagation
            next_accum[i*10 +: 10] = current_accum[i*10 +: 10] + {9'b0, bound_chunk[i]};
            
            if (current_accum[i*10 +: 10] >= safe_thresh) begin
                thresh_chunk[i] = 1'b1;
            end else begin
                thresh_chunk[i] = 1'b0;
            end
        end
    end

    logic [31:0] class_chunk;
    assign class_chunk = class_ram[chunk_ptr];

    logic [31:0] infer_xor;
    logic [5:0]  chunk_hd;
    assign infer_xor = bound_chunk ^ class_chunk;
    
    always_comb begin
        chunk_hd = 6'b0;
        for (int i=0; i<32; i++) begin
            chunk_hd = chunk_hd + {5'b0, infer_xor[i]};
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            chunk_ptr <= 0;
            hd_count <= 16'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tdata <= 96'b0;
            m_axis_tlast <= 1'b0;
            
            // Hard initialize memory to 0 to prevent Icarus 'x' states
            for (int i=0; i<NUM_CHUNKS; i++) begin
                accum_ram[i] <= 320'b0;
                class_ram[i] <= 32'b0;
            end
        end else begin
            m_axis_tvalid <= 1'b0; 
            m_axis_tlast  <= 1'b0;
            
            if (s_axis_tvalid && s_axis_tready) begin
                if (opcode == OP_CLEAR) begin
                    accum_ram[chunk_ptr] <= 320'b0;
                    class_ram[chunk_ptr] <= 32'b0;
                    hd_count <= 16'b0;
                end else if (opcode == OP_ACCUM) begin
                    accum_ram[chunk_ptr] <= next_accum;
                end else if (opcode == OP_THRESH) begin
                    class_ram[chunk_ptr] <= thresh_chunk;
                end else if (opcode == OP_INFER) begin
                    if (chunk_ptr == 0) begin
                        hd_count <= {10'b0, chunk_hd};
                    end else begin
                        hd_count <= hd_count + {10'b0, chunk_hd};
                    end
                end else if (opcode == OP_READ_HD) begin
                    m_axis_tvalid <= 1'b1;
                    m_axis_tdata  <= {64'b0, 16'b0, hd_count};
                    m_axis_tlast  <= 1'b1;
                end

                if (s_axis_tlast) begin
                    chunk_ptr <= 0;
                end else begin
                    chunk_ptr <= chunk_ptr + 1;
                end
            end
        end
    end
endmodule