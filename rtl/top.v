module top(
    input            clk, reset, start,
    input      [2:0] A, B, N,
    output reg       ready,
    output reg [5:0] result
    );
    reg [2:0] cstate = 3'b000, fstate, temp_A, temp_B;
    reg [5:0] lalb_rslt, galb_rslt;
    
    localparam START   = 3'b000;
    localparam LA_EB   = 3'b001;
    localparam EA_LB   = 3'b010;
    localparam LA_LB   = 3'b011;
    localparam GA_LB   = 3'b100;
    localparam LA_GB   = 3'b101;
    localparam GA_GB   = 3'b110;
    localparam DONE    = 3'b111;

/*
    reg [1:0] mode = 2'b00;

    localparam READY   = 2'b00;
    localparam LOAD    = 2'b01;
    localparam WAIT    = 2'b10;
    localparam DONE    = 2'b11;
*/

    always@(posedge clk) begin
        temp_A <= A;
        temp_B <= B;
        if ((A==N) && (B==N)) begin
            temp_A <= ~A + 1;
            temp_B <= ~B + 1;
            fstate <= LA_EB; end
        else if ((A<N) && (B==N)) begin
            temp_B <= ~B + 1;
            fstate <= LA_EB; end
        else if ((A==N) && (B<N)) begin
            temp_A <= ~A + 1;
            fstate <= EA_LB; end
        else if ((A<N) && (B<N)) begin
            fstate <= LA_LB; end
        else if ((A>N) && (B<N)) begin
            temp_A <= ~A + 1;
            fstate <= GA_LB; end
        else if ((A<N) && (B>N)) begin
            temp_B <= ~B + 1;
            fstate <= LA_GB; end
        else if ((A>N) && (B>N)) begin
            temp_A <= ~A + 1;
            temp_B <= ~B + 1;
            fstate <= GA_GB; end
    end
/*
    always@(posedge clk) begin
        case (mode)
            READY : begin if (start) begin
                cstate <= 3'b000;
                ready <= 1'b0;
                mode <= LOAD; end end
            LOAD  : begin mode <= WAIT; end
            WAIT  : begin if(done) mode <= DONE; else mode <= LOAD; end
            DONE  : begin if(cstate <= fstate) begin
                prev_result <= curr_result;
                cstate = cstate + 3'b001;
                done = 1'b0;
                mode = LOAD; end
                else begin result = curr_result; ready = 1'b1; end end
        endcase
    end
*/
    always@(posedge clk) begin 
        case (cstate)
            START   : begin if(start) begin 
                cstate <= LA_EB; ready <= 1'b0; end end
            LA_EB   : begin 
                result = temp_A << (N-1);
                if (cstate != fstate) cstate <= EA_LB; else cstate <= DONE; end
            EA_LB   : begin
                result = temp_B << (N-1);
                if (cstate != fstate) cstate <= LA_LB; else cstate <= DONE; end
            LA_LB   : begin
                lalb_rslt = (temp_A[1:0]) * (temp_B[1:0]);
                result = lalb_rslt;
                if (cstate != fstate) cstate <= GA_LB; else cstate <= DONE; end
            GA_LB   : begin
                if (fstate == LA_GB) cstate = LA_GB;
                else begin
                    result = (temp_B << (N-1)) - lalb_rslt;
                if (cstate != fstate) cstate <= LA_GB; else cstate <= DONE; end end
            LA_GB   : begin
                result = (temp_A << (N-1)) - lalb_rslt;
                if (cstate != fstate) cstate <= GA_GB; else cstate <= DONE; end
            GA_GB   : begin
                result = (~(temp_A << (N-1) + temp_B << (N-1)) + 1) + lalb_rslt;
                cstate = DONE; end
            DONE    : begin ready <= 1'b1; end
        endcase
    end
endmodule
