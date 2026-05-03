/* -----------------------------------------------------------------------------
 * File:        tb_interface.sv
 * Description: Testbench for the AXI4-Lite Interface module.
 * Exercises one complete AXI Write and AXI Read transaction.
 * ----------------------------------------------------------------------------- */
`timescale 1ns / 1ps

module tb_interface;

    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 32;
    localparam CLK_PERIOD = 10;

    logic                    clk;
    logic                    axi_aresetn;

    logic [ADDR_WIDTH-1:0]   awaddr;
    logic                    awvalid;
    logic                    awready;
    logic [DATA_WIDTH-1:0]   wdata;
    logic                    wvalid;
    logic                    wready;
    logic [1:0]              bresp;
    logic                    bvalid;
    logic                    bready;

    logic [ADDR_WIDTH-1:0]   araddr;
    logic                    arvalid;
    logic                    arready;
    logic [DATA_WIDTH-1:0]   rdata;
    logic [1:0]              rresp;
    logic                    rvalid;
    logic                    rready;

    // Instantiate DUT
    axi_interface #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (.*);

    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test Sequence
    initial begin
        // Setup inputs
        axi_aresetn = 0;
        awvalid = 0; wvalid = 0; bready = 0;
        arvalid = 0; rready = 0;
        awaddr = '0; wdata = '0; araddr = '0;

        // Reset
        #(CLK_PERIOD * 5);
        axi_aresetn = 1;
        #(CLK_PERIOD * 2);

        $display("--- Starting AXI4-Lite Interface Test ---");

        // ---------------------------------------------------------------------
        // TRANSACTION 1: AXI Write (Write to Base Vector Register 0x04)
        // ---------------------------------------------------------------------
        @(posedge clk);
        awaddr  = 32'h0000_0004;
        awvalid = 1;
        wdata   = 32'hBEEF_CAFE;
        wvalid  = 1;
        bready  = 1;

        // Wait for handshake
        wait (awready && wready);
        @(posedge clk);
        awvalid = 0;
        wvalid  = 0;

        // Wait for response
        wait (bvalid);
        @(posedge clk);
        bready = 0;

        // ---------------------------------------------------------------------
        // TRANSACTION 2: AXI Read (Read back from Base Vector Register 0x04)
        // ---------------------------------------------------------------------
        @(posedge clk);
        araddr  = 32'h0000_0004;
        arvalid = 1;
        rready  = 1;

        // Wait for valid read data
        wait (rvalid);
        @(posedge clk);
        arvalid = 0;

        // ---------------------------------------------------------------------
        // VERIFICATION
        // ---------------------------------------------------------------------
        if (rdata === 32'hBEEF_CAFE) begin
            $display("DUT Read Data: %h | Expected: beefcafe", rdata);
            $display("RESULT: PASS");
        end else begin
            $display("DUT Read Data: %h | Expected: beefcafe", rdata);
            $display("RESULT: FAIL");
        end

        #(CLK_PERIOD * 5);
        $display("--- Simulation Complete ---");
        $finish;
    end

endmodule