`timescale 1ns / 1ps

module accelerator_tb;

    // Parameters
    parameter N = 16;
    parameter Q = 12;
    parameter n = 9'h004;
    parameter k = 9'h003;
    parameter p = 9'h002;
    parameter s = 1;

    // Inputs
    reg clk;
    reg global_rst;
    reg ce;
    reg [N-1:0] activation;
    reg [k*k*N-1:0] weight;

    // Outputs
    wire [N-1:0] data_out;
    wire valid_op;
    wire end_op;

    // Instantiate the Unit Under Test (UUT)
    accelerator #(
        .N(N),
        .Q(Q),
        .n(n),
        .k(k),
        .p(p),
        .s(s)
    ) uut (
        .clk(clk),
        .global_rst(global_rst),
        .ce(ce),
        .activation(activation),
        .weight(weight),
        .data_out(data_out),
        .valid_op(valid_op),
        .end_op(end_op)
    );

    // Clock period
    parameter clkp = 20;

    // Clock generation
    initial begin
        clk = 0;
        forever #(clkp/2) clk = ~clk;
    end

    integer i;

    // Test sequence
    initial begin
        // Initialize inputs
        ce = 0;
        weight = 0;
        global_rst = 0;
        activation = 0;
        
        // Wait 100 ns for global reset to finish
        #100;
        global_rst = 1;    // Activate reset
        #50;
        global_rst = 0;    // Deactivate reset
        #10;
        ce = 1;

        // Set weights (matching the golden model from Python code)
        weight = 144'h0008_0007_0006_0005_0004_0003_0002_0001_0000; 

        // Provide a range of activation values
        for (i = 0; i < 255; i = i + 1) begin
            activation = i;
            #(clkp); 
        end
        $finish;
    end 

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, accelerator_tb);
        #1200;
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time = %0t | activation = %0d | weight = %0h | data_out = %0d | valid_op = %0b | end_op = %0b", 
                 $time, activation, weight, data_out, valid_op, end_op);
    end

endmodule
