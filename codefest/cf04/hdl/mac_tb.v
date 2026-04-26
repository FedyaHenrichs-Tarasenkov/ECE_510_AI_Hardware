module mac_tb;
    logic clk = 0;
    logic rst;
    logic signed [7:0] a, b;
    logic signed [31:0] out;

    // Instantiate the module under test
    mac uut (.clk(clk), .rst(rst), .a(a), .b(b), .out(out));

    // Generate Clock
    always #5 clk = ~clk;

    initial begin
        // 1. Initialize
        rst = 1; a = 0; b = 0;
        @(posedge clk);
        #1 rst = 0;

        // 2. Apply [a=3, b=4] for 3 cycles
        a = 3; b = 4;
        repeat(3) @(posedge clk);

        // 3. Assert reset
        #1 rst = 1;
        @(posedge clk);
        #1 rst = 0;

        // 4. Apply [a=-5, b=2] for 2 cycles
        a = -5; b = 2;
        repeat(2) @(posedge clk);

        // Finish simulation
        @(posedge clk);
        $finish;
    end

    // Print to terminal
    initial begin
        $monitor("Time=%0t | rst=%b a=%4d b=%4d | out=%d", $time, rst, a, b, out);
    end
endmodule