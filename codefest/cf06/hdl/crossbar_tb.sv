/* -----------------------------------------------------------------------------
 * File:        crossbar_tb.sv
 * Description: Testbench for the 4x4 binary-weight crossbar MAC unit.
 * ----------------------------------------------------------------------------- */
`timescale 1ns / 1ps

module crossbar_tb;

    logic               clk;
    logic               rst;
    logic signed [7:0]  in_vec [0:3];
    logic signed [1:0]  weight [0:3][0:3];
    logic signed [15:0] out_vec [0:3];

    // Instantiate DUT
    crossbar_mac dut (
        .clk(clk),
        .rst(rst),
        .in_vec(in_vec),
        .weight(weight),
        .out_vec(out_vec)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Initialize weights (Rows i, Columns j)
        // Row 0
        weight[0][0] =  1; weight[0][1] = -1; weight[0][2] =  1; weight[0][3] = -1;
        // Row 1
        weight[1][0] =  1; weight[1][1] =  1; weight[1][2] = -1; weight[1][3] = -1;
        // Row 2
        weight[2][0] = -1; weight[2][1] =  1; weight[2][2] =  1; weight[2][3] = -1;
        // Row 3
        weight[3][0] = -1; weight[3][1] = -1; weight[3][2] = -1; weight[3][3] =  1;

        // Initialize inputs
        in_vec[0] = 10;
        in_vec[1] = 20;
        in_vec[2] = 30;
        in_vec[3] = 40;

        rst = 1;
        #15;
        rst = 0;

        // Wait one clock cycle for the MAC to compute
        #10;

        $display("--- Crossbar MAC Simulation Results ---");
        $display("out[0]: %0d | Expected: -40", out_vec[0]);
        $display("out[1]: %0d | Expected: 0",   out_vec[1]);
        $display("out[2]: %0d | Expected: -20", out_vec[2]);
        $display("out[3]: %0d | Expected: -20", out_vec[3]);
        
        if (out_vec[0] == -40 && out_vec[1] == 0 && out_vec[2] == -20 && out_vec[3] == -20) begin
            $display("RESULT: PASS");
        end else begin
            $display("RESULT: FAIL");
        end

        $finish;
    end
endmodule