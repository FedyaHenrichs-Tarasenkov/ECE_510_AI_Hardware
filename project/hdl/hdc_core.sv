module hdc_core #(
    parameter DATA_WIDTH = 32 // Processing 32 dimensions of the 10,000-bit vector per cycle
)(
    input  logic                    clk,
    input  logic                    rst,
    
    // AXI4-Lite Style Valid/Ready Interface
    input  logic                    s_axi_valid,
    input  logic [DATA_WIDTH-1:0]   s_axi_data_a, // Base vector chunk
    input  logic [DATA_WIDTH-1:0]   s_axi_data_b, // Feature vector chunk
    output logic                    s_axi_ready,
    
    // Output Interface
    output logic                    m_axi_valid,
    output logic [DATA_WIDTH-1:0]   m_axi_data,
    input  logic                    m_axi_ready
);

    // Reset-able register for the bound vector
    logic [DATA_WIDTH-1:0] bound_vector;
    logic valid_q;

    assign s_axi_ready = m_axi_ready; 
    assign m_axi_valid = valid_q;
    assign m_axi_data  = bound_vector;

    always_ff @(posedge clk) begin
        if (rst) begin
            bound_vector <= '0;
            valid_q      <= 1'b0;
        end else if (s_axi_valid && s_axi_ready) begin
            // HDC Binding Operation is a bitwise XOR
            bound_vector <= s_axi_data_a ^ s_axi_data_b;
            valid_q      <= 1'b1;
        end else begin
            valid_q      <= 1'b0;
        end
    end

endmodule