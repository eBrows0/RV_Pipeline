module pc_reg(
    input clk,
    input reset,
    input pc_write,
    input [31:0] pc_in,
    output reg [31:0] pc_out
);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc_out <= 0;
    else if (pc_write)
        pc_out <= pc_in;
end

endmodule
