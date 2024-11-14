`timescale 1ns / 1ps
module convolver_tb;

    // Inputs
    reg clk;
    reg ce;
    reg [143:0] weight;
    reg global_rst;
    reg [15:0] activation;

    // Outputs
    wire [15:0] conv_op;
    wire valid_conv;
    wire end_conv;
    integer i;
    parameter clkp = 40; // Move parameter to the top level

    // Instantiate the Unit Under Test (UUT)
    convolver #(.N(16), .Q(12), .n(9'h004), .k(9'h003), .s(1)) uut (
        .clk(clk), 
        .ce(ce), 
        .global_rst(global_rst), 
        .activation(activation), 
        .weight(weight), 
        .conv_op(conv_op),
        .valid_conv(valid_conv),
        .end_conv(end_conv)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
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
            #clkp; 
        end
        $finish;
    end 

    // Clock generation
    always #(clkp/2) clk = ~clk;

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, convolver_tb);
        #1200;
        $finish;
    end
endmodule
