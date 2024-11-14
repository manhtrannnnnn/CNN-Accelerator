module relu #(
    parameter N = 16, // Bit width of input and output data
    parameter Q = 12  // for fixed point
)(
    input [N-1:0] in_relu,       // Input data for the ReLU function, represented as a signed integer
    output [N-1:0] out_relu      // Output data after applying the ReLU function
);

    // Check the sign bit of the input (MSB). If it is 1 (indicating a negative value), set out_value to 0.
    // Otherwise, pass the input value through as the output.
    assign out_relu = (in_relu[N-1]) ? 0 : in_relu;

endmodule
