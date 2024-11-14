module accelerator #(
    parameter N = 16,
    parameter Q = 12,
    parameter n = 9'h004,
    parameter k = 9'h003,
    parameter p = 9'h002,
    parameter s = 1
)(
    input clk, global_rst, ce,
    input [N-1:0] activation,
    input [k*k*N-1:0] weight,
    output [N-1:0] data_out,
    output valid_op, 
    output end_op
);

    wire[N-1:0] conv_op;
    wire [N-1:0] relu_op;
    wire valid_conv, end_conv;
    wire valid_ip;
    wire [N-1:0] conv_op_tmp;
    

    assign valid_ip = valid_conv && (!end_conv);

    convolver #(N, Q, n, k, s) conv(
        .clk(clk),
        .ce(ce),
        .global_rst(global_rst),
        .activation(activation),
        .weight(weight),
        .conv_op(conv_op),
        .valid_conv(valid_conv),
        .end_conv(end_conv)
    );

    relu #(N,Q) act(
        .in_relu(conv_op),
        .out_relu(relu_op)
    );

    pooler #(n-k+1,p,N,Q,1, 16'b0000010000000000) max_pooling(
        .clk(clk),
        .ce(valid_ip),
        .master_rst(global_rst),
        .data_in(relu_op),
        .data_out(data_out),
        .valid_op(valid_op),
        .end_op(end_op)
    );
endmodule