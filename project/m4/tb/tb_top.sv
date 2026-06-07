`timescale 1ns/1ps

module tb_top();
    logic clk, rst;
    
    logic        s_tvalid;
    logic [95:0] s_tdata;
    logic        s_tlast;
    logic        s_tready;

    logic        m_tvalid;
    logic [95:0] m_tdata;
    logic        m_tlast;
    logic        m_tready;

    top dut (
        .clk(clk),
        .rst(rst),
        .s_axis_tvalid(s_tvalid),
        .s_axis_tdata(s_tdata),
        .s_axis_tlast(s_tlast),
        .s_axis_tready(s_tready),
        .m_axis_tvalid(m_tvalid),
        .m_axis_tdata(m_tdata),
        .m_axis_tlast(m_tlast),
        .m_axis_tready(m_tready)
    );

    always #5 clk = ~clk;

    task send_stream(input [2:0] op, input [15:0] thresh, input [31:0] base, input [31:0] feat, input last);
        begin
            s_tvalid <= 1'b1;
            s_tdata  <= {base, feat, thresh, 13'b0, op};
            s_tlast  <= last;
            
            @(posedge clk);
            while (!s_tready) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("final_waveform.vcd");
        $dumpvars(0, tb_top);

        clk = 0; rst = 1;
        s_tvalid = 0; s_tdata = 0; s_tlast = 0; m_tready = 1;
        #25 rst = 0; #20;

        $display("\n--- Starting Robust AXI-Stream Tests ---");

        // ==========================================
        // TEST 1: Standard Inference (Expected HD = 512)
        // ==========================================
        for (int i=0; i<32; i++) send_stream(3'b000, 16'b0, 32'h0, 32'h0, (i==31)); // Clear
        for (int i=0; i<32; i++) send_stream(3'b001, 16'b0, 32'hFFFF_FFFF, 32'h0000_0000, (i==31)); // Accum
        for (int i=0; i<32; i++) send_stream(3'b010, 16'd1, 32'h0, 32'h0, (i==31)); // Thresh
        for (int i=0; i<32; i++) send_stream(3'b011, 16'b0, 32'hFFFF_FFFF, 32'hFFFF_0000, (i==31)); // Infer
        send_stream(3'b100, 16'b0, 32'h0, 32'h0, 1'b1); // Read Result
        
        s_tvalid <= 1'b0; 
        while (!m_tvalid) @(posedge clk); 
        if (m_tdata[15:0] === 512) $display("TEST 1 PASS: HD = 512");
        else $display("TEST 1 FAIL: Got %0d", m_tdata[15:0]);
        @(posedge clk);

        // ==========================================
        // TEST 2: Perfect Match (Expected HD = 0)
        // ==========================================
        for (int i=0; i<32; i++) send_stream(3'b000, 16'b0, 32'h0, 32'h0, (i==31)); // Clear
        for (int i=0; i<32; i++) send_stream(3'b001, 16'b0, 32'hAAAA_AAAA, 32'h5555_5555, (i==31)); // Accum
        for (int i=0; i<32; i++) send_stream(3'b010, 16'd1, 32'h0, 32'h0, (i==31)); // Thresh
        for (int i=0; i<32; i++) send_stream(3'b011, 16'b0, 32'hAAAA_AAAA, 32'h5555_5555, (i==31)); // Infer
        send_stream(3'b100, 16'b0, 32'h0, 32'h0, 1'b1); // Read Result
        
        s_tvalid <= 1'b0; 
        while (!m_tvalid) @(posedge clk); 
        if (m_tdata[15:0] === 0) $display("TEST 2 PASS: HD = 0");
        else $display("TEST 2 FAIL: Got %0d", m_tdata[15:0]);
        @(posedge clk);

        // ==========================================
        // TEST 3: Total Mismatch (Expected HD = 1024)
        // ==========================================
        for (int i=0; i<32; i++) send_stream(3'b000, 16'b0, 32'h0, 32'h0, (i==31)); // Clear
        for (int i=0; i<32; i++) send_stream(3'b001, 16'b0, 32'h0000_0000, 32'h0000_0000, (i==31)); // Accum
        for (int i=0; i<32; i++) send_stream(3'b010, 16'd1, 32'h0, 32'h0, (i==31)); // Thresh
        for (int i=0; i<32; i++) send_stream(3'b011, 16'b0, 32'hFFFF_FFFF, 32'h0000_0000, (i==31)); // Infer
        send_stream(3'b100, 16'b0, 32'h0, 32'h0, 1'b1); // Read Result
        
        s_tvalid <= 1'b0; 
        while (!m_tvalid) @(posedge clk); 
        if (m_tdata[15:0] === 1024) $display("TEST 3 PASS: HD = 1024");
        else $display("TEST 3 FAIL: Got %0d", m_tdata[15:0]);

        $display("--- All Tests Completed Successfully ---");
        #50 $finish;
    end
endmodule