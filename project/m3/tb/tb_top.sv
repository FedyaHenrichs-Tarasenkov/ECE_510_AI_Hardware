`timescale 1ns/1ps

module tb_top();

    // =========================================================================
    // Signals
    // =========================================================================
    logic clk;
    logic axi_aresetn;

    // AXI Write Address
    logic [31:0] awaddr;
    logic [2:0]  awprot;
    logic        awvalid;
    logic        awready;

    // AXI Write Data
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;

    // AXI Write Response
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;

    // AXI Read Address
    logic [31:0] araddr;
    logic [2:0]  arprot;
    logic        arvalid;
    logic        arready;

    // AXI Read Data
    logic [31:0] rdata;
    logic [2:0]  rresp;
    logic        rvalid;
    logic        rready;

    // =========================================================================
    // Device Under Test (DUT) - Integrated Top Module
    // =========================================================================
    top dut (
        .clk(clk),
        .axi_aresetn(axi_aresetn),
        .awaddr(awaddr), .awprot(awprot), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready),
        .bresp(bresp), .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arprot(arprot), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready)
    );

    // =========================================================================
    // Clock Generation (100 MHz -> 10ns Period)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // Bus Functional Models (BFMs) for AXI Host Transactions
    // =========================================================================
    
    // Task to simulate a host CPU writing to a memory-mapped register
    task axi_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            awaddr  <= addr;
            awvalid <= 1'b1;
            wdata   <= data;
            wvalid  <= 1'b1;
            wstrb   <= 4'hF; // Write all 4 bytes
            
            // Wait for slave to accept address and data
            wait(awready && wready);
            @(posedge clk);
            awvalid <= 1'b0;
            wvalid  <= 1'b0;
            
            // Wait for write response
            wait(bvalid);
            bready <= 1'b1;
            @(posedge clk);
            bready <= 1'b0;
        end
    endtask

    // Task to simulate a host CPU reading from a memory-mapped register
    task axi_read(input [31:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            araddr  <= addr;
            arvalid <= 1'b1;
            
            // Wait for slave to accept address
            wait(arready);
            @(posedge clk);
            arvalid <= 1'b0;
            
            // Wait for read data
            wait(rvalid);
            rready <= 1'b1;
            data = rdata;
            @(posedge clk);
            rready <= 1'b0;
        end
    endtask

    // =========================================================================
    // Main Test Sequence
    // =========================================================================
    logic [31:0] read_val;
    logic [31:0] expected_val;

    initial begin
        // Setup waveform dumping for M3 deliverable
        $dumpfile("project/m3/sim/cosim_waveform.vcd"); 
        $dumpvars(0, tb_top);

        // Initialize signals
        clk = 0;
        axi_aresetn = 0;
        awaddr = 0; awprot = 0; awvalid = 0;
        wdata = 0; wstrb = 0; wvalid = 0;
        bready = 0;
        araddr = 0; arprot = 0; arvalid = 0;
        rready = 0;

        // Apply Reset (Active Low)
        #25 axi_aresetn = 1;
        #20;

        // ---------------------------------------------------------------------
        // 1. Host loads a 32-bit chunk of the Base Vector into Address 0x04
        // ---------------------------------------------------------------------
        axi_write(32'h0000_0004, 32'hAAAA_5555);

        // ---------------------------------------------------------------------
        // 2. Host loads a 32-bit chunk of the Feature Vector into Address 0x08
        // ---------------------------------------------------------------------
        axi_write(32'h0000_0008, 32'h0F0F_F0F0);

        // ---------------------------------------------------------------------
        // 3. Host triggers Compute Core (Write 1 to bit[0] of Control Reg 0x00)
        // ---------------------------------------------------------------------
        axi_write(32'h0000_0000, 32'h0000_0001);

        // Wait a few cycles to represent processing time
        #40;

        // ---------------------------------------------------------------------
        // 4. Host reads the Bound Vector from Address 0x0C
        // ---------------------------------------------------------------------
        axi_read(32'h0000_000C, read_val);

        // ---------------------------------------------------------------------
        // 5. Independent Reference Comparison
        // ---------------------------------------------------------------------
        // Hand-calculated expected XOR of the 32-bit chunks:
        expected_val = 32'hAAAA_5555 ^ 32'h0F0F_F0F0; // Evaluates to 32'hA5A5_A5A5

        if (read_val === expected_val) begin
            $display("PASS: Co-simulation output %h matches expected %h", read_val, expected_val);
        end else begin
            $display("FAIL: Co-simulation output %h does not match expected %h", read_val, expected_val);
        end

        #20 $finish;
    end

endmodule