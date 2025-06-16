module mux4 #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire [WIDTH-1:0] in3,
    input wire [1:0]       sel, // 2-bit select for 4 inputs
    output wire [WIDTH-1:0] out
);

    // Using a case statement for clarity and better synthesis
    assign out = ({sel == 2'b00}) ? in0 :
                 ({sel == 2'b01}) ? in1 :
                 ({sel == 2'b10}) ? in2 :
                 in3; // Default to in3 if sel is 2'b11 or unknown

    

endmodule