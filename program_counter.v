module program_counter (
    input wire clk,
    input wire reset,
    input wire stall_in, 

    input wire [31:0] pc_in,
    output reg [31:0] pc_out
);


always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 32'h00000000; 
    end else if (~stall_in) begin
        pc_out <= pc_in;
    end
end

endmodule