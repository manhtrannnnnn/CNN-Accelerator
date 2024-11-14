`timescale 1ns / 1ps

module pooler_tb();

    reg clk,ce;
    reg [31:0] data_in;
    reg master_rst;
    wire [31:0] data_out;
    wire valid_op;
    wire end_op;
    parameter clkp = 40;
    integer i;
    
    pooler #(9'h4,9'h2) dut(
        .clk(clk),
        .ce(ce),
        .master_rst(master_rst),
        .data_in(data_in),
        .data_out(data_out),
        .valid_op(valid_op),
        .end_op(end_op)
        );
    
    initial 
    begin
        clk = 0;
        ce = 0;
        data_in = 0;
        master_rst = 0;
        #100;
        master_rst = 1;
        #clkp;
        master_rst  = 0;
        #10;
        ce = 1;
        for(i = 0; i<25;i = i+1) 
        begin
            data_in = i;
            #clkp;
        end
    end
    always #(clkp/2) clk = ~clk;
        initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pooler_tb);
        #1200;
        $finish;
    end
endmodule
