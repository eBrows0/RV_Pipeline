module mem_wb_register (
    input wire clk,
    input wire reset,

    // Inputs from MEM stage
    input wire [31:0] pc_plus_4_in,
    input wire [31:0] alu_result_in,
    input wire [31:0] read_data_in,   // Data read from Data Memory
    input wire [4:0]  rd_in,          // Destination register address
    input wire        reg_write_in,   // Register write enable
    input wire [1:0]  result_src_in,  // Source for write-back data

    // Outputs to WB stage
    output reg [31:0] pc_plus_4_out,
    output reg [31:0] alu_result_out,
    output reg [31:0] read_data_out,
    output reg [4:0]  rd_out,
    output reg        reg_write_out,
    output reg [1:0]  result_src_out
);

    // Standard pipeline register logic
    always @(posedge clk or posedge reset) begin // Corrected 'always' keyword
        if (reset) begin
            pc_plus_4_out <= 32'b0;
            alu_result_out <= 32'b0;
            read_data_out <= 32'b0;
            rd_out <= 5'b0;
            reg_write_out <= 1'b0;
            result_src_out <= 2'b00;
        end else begin
            pc_plus_4_out <= pc_plus_4_in;
            alu_result_out <= alu_result_in;
            read_data_out <= read_data_in;
            rd_out <= rd_in;
            reg_write_out <= reg_write_in;
            result_src_out <= result_src_in;
        end
    end

endmodule