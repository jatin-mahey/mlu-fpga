`timescale 1ns / 1ps

module tb_top();
    reg        clk, reset, start;
    reg  [2:0] A, B, N;
    wire       ready;
    wire [5:0] result;

    top nm (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A(A),
        .B(B),
        .N(N),
        .result(result),
        .ready(ready)
    );
    
    initial begin
        clk = 1'b0;
        forever #1 clk = ~clk;
    end

    initial begin
        reset = 1'b1;
        start = 1'b0;
        A = 3'b101;
        B = 3'b101;
        N = 3'b100;
        #10
        reset = 1'b0;
        start = 1'b1;
    end

endmodule
