`timescale 1ns / 1ps

module compute_core #(
    parameter NUM_CHUNKS = 32,   // 1024 Dimensions for synthesis viability
    parameter COUNTER_WIDTH = 10
)(
    input  logic clk,
    input  logic rst,
    
    // 96-bit Stream: {Base_Vec[31:0], Feat_Vec[31:0], Threshold[15:0], reserved[12:0], Opcode[2:0]}
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    localparam OP_CLEAR   = 3'b000;
    localparam OP_ACCUM   = 3'b001;
    localparam OP_THRESH  = 3'b010;
    localparam OP_INFER   = 3'b011;
    localparam OP_READ_HD = 3'b100;

    logic [31:0] base_vec, feat_vec;
    logic [15:0] threshold_val;
    logic [2:0]  opcode;

    assign base_vec      = s_axis.tdata[95:64];
    assign feat_vec      = s_axis.tdata[63:32];
    assign threshold_val = s_axis.tdata[31:16];
    assign opcode        = s_axis.tdata[2:0];

    logic [(32 * COUNTER_WIDTH) - 1 : 0] accum_ram [0 : NUM_CHUNKS - 1];
    logic [31:0]                         class_ram [0 : NUM_CHUNKS - 1];

    logic [8:0]  chunk_ptr;
    logic [15:0] hd_count;

    // Core is ready when output is ready
    assign s_axis.tready = m_axis.tready;

    logic [31:0] bound_chunk;
    assign bound_chunk = base_vec ^ feat_vec;

    logic [31:0] infer_xor;
    logic [5:0]  chunk_hd;
    assign infer_xor = bound_chunk ^ class_ram[chunk_ptr];
    
    always_comb begin
        chunk_hd = 0;
        for (int i=0; i<32; i++) begin
            chunk_hd = chunk_hd + infer_xor[i];
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            chunk_ptr <= 0;
            hd_count <= 0;
            m_axis.tvalid <= 1'b0;
            m_axis.tdata <= '0;
            m_axis.tlast <= 1'b0;
        end else begin
            m_axis.tvalid <= 1'b0; 
            m_axis.tlast  <= 1'b0;
            
            if (s_axis.tvalid && s_axis.tready) begin
                if (opcode == OP_CLEAR) begin
                    accum_ram[chunk_ptr] <= '0;
                    class_ram[chunk_ptr] <= '0;
                    hd_count <= 0;
                end else if (opcode == OP_ACCUM) begin
                    for (int i=0; i<32; i++) begin
                        accum_ram[chunk_ptr][i*COUNTER_WIDTH +: COUNTER_WIDTH] <= 
                            accum_ram[chunk_ptr][i*COUNTER_WIDTH +: COUNTER_WIDTH] + bound_chunk[i];
                    end
                end else if (opcode == OP_THRESH) begin
                    for (int i=0; i<32; i++) begin
                        class_ram[chunk_ptr][i] <= 
                            (accum_ram[chunk_ptr][i*COUNTER_WIDTH +: COUNTER_WIDTH] >= threshold_val) ? 1'b1 : 1'b0;
                    end
                end else if (opcode == OP_INFER) begin
                    if (chunk_ptr == 0) hd_count <= chunk_hd; 
                    else hd_count <= hd_count + chunk_hd;
                end else if (opcode == OP_READ_HD) begin
                    m_axis.tvalid <= 1'b1;
                    m_axis.tdata  <= {64'b0, 16'b0, hd_count};
                    m_axis.tlast  <= 1'b1;
                end

                if (s_axis.tlast) begin
                    chunk_ptr <= 0;
                end else begin
                    chunk_ptr <= chunk_ptr + 1;
                end
            end
        end
    end
endmodule