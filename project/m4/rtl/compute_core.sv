/* -----------------------------------------------------------------------------
 * File:        compute_core.sv
 * Description: HDC Edge AI Accelerator Core (M4 Integrated).
 * Includes Binding, Bundling (Accumulation + Majority Gate), 
 * and Similarity Check (Hamming Distance) blocks.
 * ----------------------------------------------------------------------------- */

module compute_core #(
    parameter DATA_WIDTH = 32,
    parameter NUM_CHUNKS = 313,   // 10000 dimensions / 32 bits
    parameter COUNTER_WIDTH = 10  // Supports bundling up to 1023 vectors
)(
    input  logic                    clk,
    input  logic                    rst,
    
    input  logic [DATA_WIDTH-1:0]   s_axi_ctrl,
    input  logic                    s_axi_valid,
    input  logic [DATA_WIDTH-1:0]   s_axi_data_a,
    input  logic [DATA_WIDTH-1:0]   s_axi_data_b,
    output logic                    s_axi_ready,
    
    output logic                    m_axi_valid,
    output logic [DATA_WIDTH-1:0]   m_axi_data,
    input  logic                    m_axi_ready
);

    // Host Opcodes (s_axi_ctrl[4:2])
    localparam OP_CLEAR   = 3'b000; // Reset RAMs
    localparam OP_ACCUM   = 3'b001; // Bind (XOR) and add to accumulator
    localparam OP_THRESH  = 3'b010; // Apply majority gate, store in class RAM
    localparam OP_INFER   = 3'b011; // Infer (XOR) and accumulate Hamming Dist
    localparam OP_READ_HD = 3'b100; // Output final Hamming Distance

    logic [2:0]  opcode;
    logic [15:0] threshold_val;
    assign opcode        = s_axi_ctrl[4:2];
    assign threshold_val = s_axi_ctrl[31:16];

    // On-Chip Memory
    logic [(32 * COUNTER_WIDTH) - 1 : 0] accum_ram [0 : NUM_CHUNKS - 1];
    logic [DATA_WIDTH-1:0]               class_ram [0 : NUM_CHUNKS - 1];

    // FSM States
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_READ,
        ST_COMPUTE,
        ST_WRITE,
        ST_DONE
    } state_t;
    state_t state;

    logic [8:0]  chunk_ptr;
    logic [15:0] hd_count;

    // Pipeline Registers
    logic [(32 * COUNTER_WIDTH) - 1 : 0] accum_rdata;
    logic [DATA_WIDTH-1:0]               class_rdata;

    // --- Combinational Math Blocks ---
    
    // 1. Binding Unit (XOR)
    logic [DATA_WIDTH-1:0] bound_chunk;
    assign bound_chunk = s_axi_data_a ^ s_axi_data_b;

    // 2. Bundling Unit & Thresholding
    logic [(32 * COUNTER_WIDTH) - 1 : 0] next_accum;
    logic [DATA_WIDTH-1:0]               thresh_chunk;
    always_comb begin
        for (int i=0; i<32; i++) begin
            next_accum[i*COUNTER_WIDTH +: COUNTER_WIDTH] = accum_rdata[i*COUNTER_WIDTH +: COUNTER_WIDTH] + bound_chunk[i];
            thresh_chunk[i] = (accum_rdata[i*COUNTER_WIDTH +: COUNTER_WIDTH] >= threshold_val) ? 1'b1 : 1'b0;
        end
    end

    // 3. Similarity Check (Hamming Distance Popcount)
    logic [DATA_WIDTH-1:0] infer_xor;
    logic [5:0]            chunk_hd;
    assign infer_xor = bound_chunk ^ class_rdata;
    
    // Synthesizes into an adder tree
    always_comb begin
        chunk_hd = 0;
        for (int i=0; i<32; i++) begin
            chunk_hd = chunk_hd + infer_xor[i];
        end
    end

    // --- Core State Machine ---
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= ST_IDLE;
            chunk_ptr <= 0;
            hd_count <= 0;
            s_axi_ready <= 1'b1;
            m_axi_valid <= 1'b0;
            m_axi_data <= 0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (s_axi_valid && s_axi_ready) begin
                        s_axi_ready <= 1'b0; // Flag busy to host
                        m_axi_valid <= 1'b0;
                        
                        if (opcode == OP_CLEAR || opcode == OP_THRESH) begin
                            chunk_ptr <= 0; // Auto-loop operations start at 0
                        end
                        
                        if (opcode == OP_READ_HD) begin
                            m_axi_data <= {16'b0, hd_count};
                            state <= ST_DONE;
                        end else begin
                            state <= ST_READ;
                        end
                    end
                end

                ST_READ: begin
                    accum_rdata <= accum_ram[chunk_ptr];
                    class_rdata <= class_ram[chunk_ptr];
                    state <= ST_COMPUTE;
                end

                ST_COMPUTE: begin
                    // One cycle delay for math combinational logic
                    state <= ST_WRITE;
                end

                ST_WRITE: begin
                    // Execute memory writes based on opcode
                    if (opcode == OP_CLEAR) begin
                        accum_ram[chunk_ptr] <= '0;
                        class_ram[chunk_ptr] <= '0;
                        hd_count <= 0;
                    end else if (opcode == OP_ACCUM) begin
                        accum_ram[chunk_ptr] <= next_accum;
                    end else if (opcode == OP_THRESH) begin
                        class_ram[chunk_ptr] <= thresh_chunk;
                    end else if (opcode == OP_INFER) begin
                        if (chunk_ptr == 0) hd_count <= chunk_hd; 
                        else hd_count <= hd_count + chunk_hd;
                    end

                    // Auto-looping for full-memory operations (CLEAR and THRESH)
                    if (opcode == OP_CLEAR || opcode == OP_THRESH) begin
                        if (chunk_ptr == NUM_CHUNKS - 1) begin
                            state <= ST_DONE;
                            chunk_ptr <= 0;
                        end else begin
                            chunk_ptr <= chunk_ptr + 1;
                            state <= ST_READ;
                        end
                    end else begin
                        // Single-chunk operations (ACCUM and INFER)
                        if (chunk_ptr == NUM_CHUNKS - 1) chunk_ptr <= 0;
                        else chunk_ptr <= chunk_ptr + 1;
                        state <= ST_DONE;
                    end
                end

                ST_DONE: begin
                    m_axi_valid <= 1'b1;
                    // Wait for host software to clear the start bit (handshake)
                    if (!s_axi_valid) begin
                        s_axi_ready <= 1'b1;
                        state <= ST_IDLE;
                    end
                end
            endcase
        end
    end

endmodule