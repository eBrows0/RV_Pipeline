module register_file (
    input wire clk,
    input wire reset,          // <-- Reset signal
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,
    input wire [31:0] wdata,
    input wire RegWrite,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2
);

reg [31:0] registers [0:31];
integer i; 

always @(posedge clk) begin
    if (reset) begin 
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] <= 32'b0; 
        end
    end else if (RegWrite && rd != 0) begin 
        registers[rd] <= wdata; // Write data to the destination register (x0 is hardwired to 0 by not writing to it)
    end
end

assign rdata1 = (rs1 == 0) ? 32'b0 : registers[rs1];
assign rdata2 = (rs2 == 0) ? 32'b0 : registers[rs2];

endmodule