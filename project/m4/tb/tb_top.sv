`timescale 1ns/1ps

module tb_top();
    logic clk, rst;
    
    axis_if #(.DATA_WIDTH(96)) s_intf();
    axis_if #(.DATA_WIDTH(96)) m_intf();

    compute_core dut (
        .clk(clk),
        .rst(rst),
        .s_axis(s_intf.slave),
        .m_axis(m_intf.master)
    );

    always #5 clk = ~clk;

    task send_stream(input [2:0] op, input [15:0] thresh, input [31:0] base, input [31:0] feat, input last);
        begin
            @(posedge clk);
            s_intf.tvalid <= 1'b1;
            s_intf.tdata  <= {base, feat, thresh, 13'b0, op};
            s_intf.tlast  <= last;
            wait(s_intf.tready);
        end
    endtask

    initial begin
        clk = 0; rst = 1;
        s_intf.tvalid = 0;
        s_intf.tdata = 0;
        s_intf.tlast = 0;
        m_intf.tready = 1;

        #25 rst = 0; #20;

        $display("\n--- Starting AXI-Stream Test (NUM_CHUNKS=32) ---");

        // 1. Clear RAMs
        for (int i=0; i<32; i++) send_stream(3'b000, 16'b0, 32'h0, 32'h0, (i==31));

        // 2. Accumulate
        for (int i=0; i<32; i++) send_stream(3'b001, 16'b0, 32'hFFFF_FFFF, 32'h0000_0000, (i==31));

        // 3. Threshold
        for (int i=0; i<32; i++) send_stream(3'b010, 16'd1, 32'h0, 32'h0, (i==31));

        // 4. Infer
        for (int i=0; i<32; i++) send_stream(3'b011, 16'b0, 32'hFFFF_FFFF, 32'hFFFF_0000, (i==31));

        // 5. Read Result
        s_intf.tvalid <= 1'b0;
        @(posedge clk);
        send_stream(3'b100, 16'b0, 32'h0, 32'h0, 1'b1);
        s_intf.tvalid <= 1'b0;

        wait(m_intf.tvalid);
        if (m_intf.tdata[15:0] === 32 * 16) $display("PASS: Output matches %0d", m_intf.tdata[15:0]);
        else $display("FAIL: Got %0d", m_intf.tdata[15:0]);

        #50 $finish;
    end
endmodule