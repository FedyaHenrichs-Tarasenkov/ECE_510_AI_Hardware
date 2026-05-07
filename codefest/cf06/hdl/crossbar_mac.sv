/* -----------------------------------------------------------------------------
 * File:        crossbar_mac.sv
 * Description: 4x4 binary-weight crossbar MAC unit. 
 * Computes out[j] = sum_i(weight[i][j] * in[i]) every clock cycle.
 * ----------------------------------------------------------------------------- */
`timescale 1ns / 1ps

module crossbar_mac (
    input  logic               clk,
    input  logic               rst,
    input  logic signed [7:0]  in_vec [0:3],
    input  logic signed [1:0]  weight [0:3][0:3], // +1 or -1 weights
    output logic signed [15:0] out_vec [0:3]
);

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int j = 0; j < 4; j++) begin
                out_vec[j] <= '0;
            end
        end else begin
            // Compute MAC for each of the 4 output columns
            for (int j = 0; j < 4; j++) begin
                out_vec[j] <= (in_vec[0] * weight[0][j]) +
                              (in_vec[1] * weight[1][j]) +
                              (in_vec[2] * weight[2][j]) +
                              (in_vec[3] * weight[3][j]);
            end
        end
    end

endmodule