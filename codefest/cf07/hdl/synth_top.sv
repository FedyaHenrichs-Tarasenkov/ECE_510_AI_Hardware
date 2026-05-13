/* -----------------------------------------------------------------------------
 * File:        compute_core.sv
 * Description: Top-level compute core for the HDC Edge AI Accelerator.
 * Currently implements the Binding Unit (32-bit parallel XOR array)
 * for 1-bit quantized Hyperdimensional Computing vectors.
 *
 * Clocking:    Single clock domain (clk).
 * Reset:       Synchronous, active-high reset (rst).
 *
 * Ports:
 * - clk          : input  : 1-bit  : System clock.
 * - rst          : input  : 1-bit  : Synchronous active-high reset.
 * - s_axi_valid  : input  : 1-bit  : AXI4-Lite style valid signal from host.
 * - s_axi_data_a : input  : 32-bit : 32-bit chunk of the Base Vector.
 * - s_axi_data_b : input  : 32-bit : 32-bit chunk of the Feature Vector.
 * - s_axi_ready  : output : 1-bit  : Ready signal to host.
 * - m_axi_valid  : output : 1-bit  : Valid signal indicating bound data is ready.
 * - m_axi_data   : output : 32-bit : 32-bit chunk of the bound HDC vector.
 * - m_axi_ready  : input  : 1-bit  : Ready signal from downstream logic.
 * ----------------------------------------------------------------------------- */

module compute_core #(
    parameter DATA_WIDTH = 32
)(
    input  logic                    clk,
    input  logic                    rst,
    
    // AXI4-Lite Style Input Interface
    input  logic                    s_axi_valid,
    input  logic [DATA_WIDTH-1:0]   s_axi_data_a,
    input  logic [DATA_WIDTH-1:0]   s_axi_data_b,
    output logic                    s_axi_ready,
    
    // Output Interface
    output logic                    m_axi_valid,
    output logic [DATA_WIDTH-1:0]   m_axi_data,
    input  logic                    m_axi_ready
);

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
            bound_vector <= s_axi_data_a ^ s_axi_data_b;
            valid_q      <= 1'b1;
        end else begin
            valid_q      <= 1'b0;
        end
    end

endmodule