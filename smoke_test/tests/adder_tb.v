module tb;
    reg [3:0] a, b; wire [3:0] s; wire c;
    adder uut (a, b, s, c);
    initial begin
        $dumpfile("waveform.vcd"); // This allows you to use GTKWave later
        $dumpvars(0, tb);
        $monitor("A:%d B:%d | Sum:%d Carry:%b", a, b, s, c);
        a = 4; b = 5; #10;
        a = 12; b = 7; #10;
        $finish;
    end
endmodule