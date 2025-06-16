module ex_mem_register (
    input wire clk,
    input wire reset,

    // Inputs from EX stage
    input wire [31:0] pc_plus_4_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] rdata2_in,      // Data to be written to memory (for SW)
    input wire [4:0]  rd_in,          // Destination register address
    input wire [1:0]  mem_write_in,   // Memory write control (2-bit)
    input wire        mem_read_in,    // Memory read control
    input wire        reg_write_in,   // Register write enable
    input wire [1:0]  result_src_in,  // Source for write-back data

    // Outputs to MEM stage
    output reg [31:0] pc_plus_4_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] rdata2_out,
    output reg [4:0]  rd_out,
    output reg [1:0]  mem_write_out,
    output reg        mem_read_out,
    output reg        reg_write_out,
    output reg [1:0]  result_src_out
);

   
    always @(posedge clk or posedge reset) begin 
        if (reset) begin
            pc_plus_4_out <= 32'b0;
            alu_result_out <= 32'b0;
            rdata2_out <= 32'b0;
            rd_out <= 5'b0;
            mem_write_out <= 2'b00;
            mem_read_out <= 1'b0;
            reg_write_out <= 1'b0;
            result_src_out <= 2'b00;
        end else begin
            pc_plus_4_out <= pc_plus_4_in;
            alu_result_out <= alu_result_in;
            rdata2_out <= rdata2_in;
            rd_out <= rd_in;
            mem_write_out <= mem_write_in;
            mem_read_out <= mem_read_in;
            reg_write_out <= reg_write_in;
            result_src_out <= result_src_in;
        end
    end

endmodule