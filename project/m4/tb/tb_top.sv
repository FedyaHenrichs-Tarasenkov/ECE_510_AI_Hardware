`timescale 1ns/1ps

module tb_top();

    // =========================================================================
    // Signals
    // =========================================================================
    logic clk;
    logic axi_aresetn;

    // AXI Write Channel
    logic [31:0] awaddr;
    logic        awvalid;
    logic        awready;
    logic [31:0] wdata;
    logic        wvalid;
    logic        wready;
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;

    // AXI Read Channel
    logic [31:0] araddr;
    logic        arvalid;
    logic        arready;
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rvalid;
    logic        rready;

    // =========================================================================
    // Device Under Test (DUT)
    // =========================================================================
    top dut (
        .clk(clk),
        .axi_aresetn(axi_aresetn),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wvalid(wvalid), .wready(wready),
        .bresp(bresp), .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready)
    );

    // =========================================================================
    // Clock Generation (100 MHz)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // Bus Functional Models (BFMs)
    // =========================================================================
    task axi_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            awaddr  <= addr;
            awvalid <= 1'b1;
            wdata   <= data;
            wvalid  <= 1'b1;
            wait(awready && wready);
            @(posedge clk);
            awvalid <= 1'b0;
            wvalid  <= 1'b0;
            wait(bvalid);
            bready <= 1'b1;
            @(posedge clk);
            bready <= 1'b0;
        end
    endtask

    task axi_read(input [31:0] addr, output [31:0] data);
        begin
            @(posedge clk);
            araddr  <= addr;
            arvalid <= 1'b1;
            wait(arready);
            @(posedge clk);
            arvalid <= 1'b0;
            wait(rvalid);
            rready <= 1'b1;
            data = rdata;
            @(posedge clk);
            rready <= 1'b0;
        end
    endtask

    // -------------------------------------------------------------------------
    // NEW: 4-Phase Handshake Command Execution
    // -------------------------------------------------------------------------
    task execute_cmd(input [31:0] cmd_val);
        logic [31:0] status;
        begin
            // 1. Write command with START=1
            axi_write(32'h0000_0000, cmd_val);
            
            // Wait a couple cycles for the core to drop its ready flag
            @(posedge clk);
            @(posedge clk);
            
            // 2. Clear START bit (START=0) to allow FSM to complete handshake later
            axi_write(32'h0000_0000, cmd_val & 32'hFFFF_FFFE);
            
            // 3. Poll Status Register until Core Ready bit (bit 1) is 1
            status = 32'h0;
            while ((status & 32'h0000_0002) == 32'h0) begin
                axi_read(32'h0000_0000, status);
            end
        end
    endtask

    // =========================================================================
    // Main Test Sequence
    // =========================================================================
    logic [31:0] read_val;
    logic [31:0] expected_val;

    initial begin
        // Setup waveform dumping for M4 deliverable
        $dumpfile("project/m4/sim/final_waveform.vcd");
        $dumpvars(0, tb_top);

        clk = 0;
        axi_aresetn = 0;
        awaddr = 0; awvalid = 0;
        wdata = 0; wvalid = 0;
        bready = 0;
        araddr = 0; arvalid = 0;
        rready = 0;

        // Apply Reset
        #25 axi_aresetn = 1;
        #20;

        $display("\n=======================================================");
        $display("--- Starting M4 Integration Test (Full HDC Pipeline) ---");
        $display("=======================================================\n");

        // 1. OP_CLEAR (Opcode 000)
        $display("[TB] 1. Clearing Accumulator and Class RAMs...");
        execute_cmd(32'h0000_0001); // OP=000, Start=1

        // 2. Stream 1 full vector (313 chunks) for OP_ACCUM
        $display("[TB] 2. Streaming Vector 1 for Accumulation (313 chunks)...");
        for (int i = 0; i < 313; i++) begin
            axi_write(32'h0000_0004, 32'hFFFF_FFFF); // Base Vector
            axi_write(32'h0000_0008, 32'h0000_0000); // Feature Vector -> Bound output is all 1s
            execute_cmd(32'h0000_0005);              // OP_ACCUM (001), Start=1
        end

        // 3. OP_THRESH (Threshold = 1)
        $display("[TB] 3. Thresholding Accumulator to Class RAM (Majority Gate)...");
        execute_cmd(32'h0001_0009); // Thresh=1, OP_THRESH (010), Start=1

        // 4. Stream 1 full vector (313 chunks) for OP_INFER
        $display("[TB] 4. Streaming Vector 2 for Similarity Check...");
        for (int i = 0; i < 313; i++) begin
            axi_write(32'h0000_0004, 32'hFFFF_FFFF); // Base Vector
            axi_write(32'h0000_0008, 32'hFFFF_0000); // Feature Vector -> Top 16 bits differ
            execute_cmd(32'h0000_000D);              // OP_INFER (011), Start=1
        end

        // 5. OP_READ_HD
        $display("[TB] 5. Reading Final Hamming Distance...");
        execute_cmd(32'h0000_0011); // OP_READ_HD (100), Start=1
        axi_read(32'h0000_000C, read_val);

        // ---------------------------------------------------------------------
        // Independent Reference Comparison
        // Chunk 0..312: Bound vector is FFFF_0000. Class vector is FFFF_FFFF.
        // XOR = 0000_FFFF (Exactly 16 bits differ per chunk).
        // Total HD = 313 chunks * 16 bits = 5008.
        // ---------------------------------------------------------------------
        expected_val = 313 * 16;
        
        $display("\n=======================================================");
        if (read_val === expected_val) begin
            $display("PASS: M4 Pipeline HD Output %0d matches expected %0d", read_val, expected_val);
        end else begin
            $display("FAIL: M4 Pipeline HD Output %0d does not match expected %0d", read_val, expected_val);
        end
        $display("=======================================================\n");

        #50 $finish;
    end

endmodule