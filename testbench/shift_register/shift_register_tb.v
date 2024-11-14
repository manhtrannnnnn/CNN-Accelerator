`timescale 1ns/1ps

module shift_register_tb();
    parameter WIDTH = 16;
    parameter size = 3;
    reg clk, ce, rst;
    reg [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;
    parameter clkp = 40;
    integer i;

    shift_register #(WIDTH, size) dut (
        .clk(clk),
        .ce(ce),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        // Initial Input
        clk = 0;
        ce = 0;
        rst = 1;
        data_in = 0;

        #clkp rst = 0; ce = 1;
        
        for (i = 0; i < 15; i = i + 1) begin
            data_in = i;
            #clkp;
        end
        #clkp;
        $finish;
    end

    always #(clkp/2) clk = ~clk;
    
    initial begin
        // Dump waveform for GTKWave
        $dumpfile("wave.vcd");
        $dumpvars(0, shift_register_tb);
    end
endmodule
