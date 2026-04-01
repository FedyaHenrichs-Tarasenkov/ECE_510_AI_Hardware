module adder (
    input  [3:0] a, b,
    output [3:0] sum,
    output       co
);
    assign {co, sum} = a + b;
endmodule