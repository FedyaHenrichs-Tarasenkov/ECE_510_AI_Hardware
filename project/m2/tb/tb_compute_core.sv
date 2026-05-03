/* -----------------------------------------------------------------------------
 * File:        tb_compute_core.sv
 * Description: Testbench for the HDC Compute Core (Binding Unit).
 * Exercises a representative 32-bit chunk of a 10,000-bit HDC vector.
 * Includes VCD dumping for waveform generation.
 * ----------------------------------------------------------------------------- */
`timescale 1ns / 1ps

module tb_compute_core;

    // Parameters
    localparam DATA_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    // Signals
    logic                    clk;
    logic                    rst;
    logic                    s_axi_valid;
    logic [DATA_WIDTH-1:0]   s_axi_data_a;
    logic [DATA_WIDTH-1:0]   s_axi_data_b;
    logic                    s_axi_ready;
    logic                    m_axi_valid;
    logic [DATA_WIDTH-1:0]   m_axi_data;
    logic                    m_axi_ready;

    // Instantiate the Device Under Test (DUT)
    compute_core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .s_axi_valid(s_axi_valid),
        .s_axi_data_a(s_axi_data_a),
        .s_axi_data_b(s_axi_data_b),
        .s_axi_ready(s_axi_ready),
        .m_axi_valid(m_axi_valid),
        .m_axi_data(m_axi_data),
        .m_axi_ready(m_axi_ready)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Setup VCD dumping for waveform.png deliverable
        $dumpfile("compute_core.vcd");
        $dumpvars(0, tb_compute_core);

        // Initialize Inputs
        rst = 1;
        s_axi_valid = 0;
        s_axi_data_a = '0;
        s_axi_data_b = '0;
        m_axi_ready = 1; // Downstream is always ready for this test

        // Wait 100 ns for global reset to finish
        #(CLK_PERIOD * 10);
        rst = 0;
        #(CLK_PERIOD * 2);

        // ---------------------------------------------------------------------
        // TEST CASE 1: Representative Input Vector (HDC Binding)
        // ---------------------------------------------------------------------
        $display("--- Starting HDC Binding Test ---");
        
        // Representative HDC vector chunks (Alternating patterns)
        s_axi_data_a = 32'hA5A5_5A5A; // 10100101...
        s_axi_data_b = 32'h0F0F_F0F0; // 00001111...
        s_axi_valid  = 1;

        // Wait for valid handshake completion
        wait(m_axi_valid == 1'b1);
        #(CLK_PERIOD); 
        
        s_axi_valid = 0; // De-assert valid after capture

        // ---------------------------------------------------------------------
        // VERIFICATION
        // Expected output calculated independently: 32'hA5A5_5A5A ^ 32'h0F0F_F0F0 = 32'hAAAA_AAAA
        // ---------------------------------------------------------------------
        if (m_axi_data === 32'hAAAA_AAAA) begin
            $display("DUT Output: %h | Expected: aaaaaaaa", m_axi_data);
            $display("RESULT: PASS");
        end else begin
            $display("DUT Output: %h | Expected: aaaaaaaa", m_axi_data);
            $display("RESULT: FAIL");
        end

        // End simulation
        #(CLK_PERIOD * 5);
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule