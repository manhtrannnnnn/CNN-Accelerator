module convolver #(
    parameter N = 16, // size bit
    parameter Q = 12, // for fixed point
    parameter n = 9'h004, // size input
    parameter k = 9'h003, // size kernel
    parameter s = 1 // stride
)(
    input clk, ce, global_rst,
    input [N-1:0] activation,
    input [k*k*N-1:0] weight,
    output [N-1:0] conv_op,  
    output reg valid_conv,
    output reg end_conv
);

    wire [N-1:0] weight_tmp[k*k-1:0];
    wire [N-1:0] tmp[k*k+1:0];

    // Breaking our weight into separate variables
    generate 
        genvar j;
        for(j = 0; j < k*k; j = j + 1) begin
            assign weight_tmp[j][N-1:0] = weight[j*N +: N];
        end
    endgenerate

    // Implement MAC
    assign tmp[0] = {N{1'b0}};
    generate 
        genvar i;
        for(i = 0; i < k*k; i = i + 1) begin
            if((i+1) % k == 0) begin
                if(i == k*k-1) begin
                    mac_manual #(N, Q) mac(
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .a(activation),
                        .b(weight_tmp[i]),
                        .sum(tmp[i]),
                        .data_out(conv_op)
                    );
                end
                else begin
                    wire [N-1:0] tmp2;
                    mac_manual #(N, Q) mac(
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .a(activation),
                        .b(weight_tmp[i]),
                        .sum(tmp[i]),
                        .data_out(tmp2)
                    );

                    shift_register #(.N(N), .size(n-k)) SR(
                        .clk(clk),
                        .ce(ce),
                        .rst(global_rst),
                        .data_in(tmp2),
                        .data_out(tmp[i+1])
                    );
                end
            end
            else begin
                mac_manual #(N, Q) mac(
                    .clk(clk),
                    .ce(ce),
                    .rst(global_rst),
                    .a(activation),
                    .b(weight_tmp[i]),
                    .sum(tmp[i]),
                    .data_out(tmp[i+1])
                );
            end
        end
    endgenerate

    // Counters to track row and column positions
    reg [$clog2(n):0] row_counter = 0;
    reg [$clog2(n):0] col_counter = 0;
    reg [$clog2(n*n):0] cycle_counter = 0;

    // Logic to control row and column counters
    always @(posedge clk or posedge global_rst) begin
        if (global_rst) begin
            row_counter <= 0;
            col_counter <= 0;
            cycle_counter <= 0;
        end else if (ce) begin
            // Increment column counter by stride `s`
            if (col_counter + s >= n) begin
                col_counter <= 0;
                if (row_counter + s >= n) begin
                    row_counter <= 0;
                end else begin
                    row_counter <= row_counter + s;
                end
            end else begin
                col_counter <= col_counter + s;
            end

            // Increment cycle counter
            cycle_counter <= cycle_counter + 1;
        end
    end

    // Generate `valid_conv` when at the last position of each valid convolution window with stride support
    always @(posedge clk or posedge global_rst) begin
        if (global_rst) begin
            valid_conv <= 0;
        end else if (ce) begin
            // Set `valid_conv` only at the last position of each convolution window, adjusted for stride `s`
            if ((row_counter >= k-1 && row_counter < n && (row_counter - (k-1)) % s == 0) &&
                (col_counter >= k-1 && col_counter < n && (col_counter - (k-1)) % s == 0)) begin
                valid_conv <= 1;
            end else begin
                valid_conv <= 0;
            end
        end
    end

    // Generate `end_conv` when the entire convolution operation is complete
    always @(posedge clk or posedge global_rst) begin
        if (global_rst) begin
            end_conv <= 0;
        end else if (cycle_counter >= n*n) begin
            end_conv <= 1;
        end else begin
            end_conv <= 0;
        end
    end
endmodule
