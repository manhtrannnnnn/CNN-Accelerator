module mac_manual #(
    parameter N = 16,
    parameter Q = 12 // number of fractional bits for fixed-point
)(
    input clk, ce, rst,
    input [N-1:0] a,
    input [N-1:0] b,
    input [N-1:0] sum,
    output reg [N-1:0] data_out
);
    `ifdef FIXED_POINT
        reg [2*N-1:0] mult_result; // To hold full multiplication result
    `else
        // Integer mode implementation
        always @(posedge clk) begin
            if (rst) begin
                data_out <= 0;
            end else if (ce) begin
                data_out <= (a * b) + sum; // accumulate
            end
        end
    `endif
endmodule
