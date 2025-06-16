module id_ex_register (
    input wire clk,
    input wire reset,
    input wire flush_ex, 
    input wire stall_ex, 

    input wire [31:0] pc_in_id,
    input wire [31:0] pc_plus_4_in_id,
    input wire [31:0] rdata1_in_id,
    input wire [31:0] rdata2_in_id,
    input wire [31:0] imm_ext_in_id,
    input wire [4:0]  rs1_in_id,      
    input wire [4:0]  rs2_in_id,
    input wire [4:0]  rd_in_id,
    input wire        reg_write_in_id,
    input wire        mem_read_in_id,
    input wire [1:0]  mem_write_in_id,
    input wire [2:0]  alu_op_in_id,
    input wire        alu_src_in_id,
    input wire        branch_in_id,
    input wire        jump_in_id,
    input wire [1:0]  result_src_in_id,
    input wire [2:0]  funct3_in_id,
    input wire [6:0]  funct7_in_id,

   
    output reg [31:0] pc_out_ex,
    output reg [31:0] pc_plus_4_out_ex,
    output reg [31:0] rdata1_out_ex,
    output reg [31:0] rdata2_out_ex,
    output reg [31:0] imm_ext_out_ex,
    output reg [4:0]  rs1_out_ex,      
    output reg [4:0]  rs2_out_ex,
    output reg [4:0]  rd_out_ex,
    output reg        reg_write_out_ex,
    output reg        mem_read_out_ex,
    output reg [1:0]  mem_write_out_ex,
    output reg [2:0]  alu_op_out_ex,
    output reg        alu_src_out_ex,
    output reg        branch_out_ex,
    output reg        jump_out_ex,
    output reg [1:0]  result_src_out_ex,
    output reg [2:0]  funct3_out_ex,
    output reg [6:0]  funct7_out_ex
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
       
        pc_out_ex <= 32'b0;
        pc_plus_4_out_ex <= 32'b0;
        rdata1_out_ex <= 32'b0;
        rdata2_out_ex <= 32'b0;
        imm_ext_out_ex <= 32'b0;
        rs1_out_ex <= 5'b0;       
        rs2_out_ex <= 5'b0;
        rd_out_ex <= 5'b0;
        reg_write_out_ex <= 1'b0;
        mem_read_out_ex <= 1'b0;
        mem_write_out_ex <= 2'b00;
        alu_op_out_ex <= 3'b000;
        alu_src_out_ex <= 1'b0;
        branch_out_ex <= 1'b0;
        jump_out_ex <= 1'b0;
        result_src_out_ex <= 2'b00;
        funct3_out_ex <= 3'b000;
        funct7_out_ex <= 7'b0000000;
    end else if (flush_ex) begin 
        pc_out_ex <= 32'b0;
        pc_plus_4_out_ex <= 32'b0;
        rdata1_out_ex <= 32'b0;
        rdata2_out_ex <= 32'b0;
        imm_ext_out_ex <= 32'b0;
        rs1_out_ex <= 5'b0;
        rs2_out_ex <= 5'b0;
        rd_out_ex <= 5'b0;
        reg_write_out_ex <= 1'b0;   
        mem_read_out_ex <= 1'b0;
        mem_write_out_ex <= 2'b00;
        alu_op_out_ex <= 3'b000;
        alu_src_out_ex <= 1'b0;
        branch_out_ex <= 1'b0;
        jump_out_ex <= 1'b0;
        result_src_out_ex <= 2'b00;
        funct3_out_ex <= 3'b000;
        funct7_out_ex <= 7'b0000000;
    end else if (~stall_ex) begin 
        pc_out_ex <= pc_in_id;
        pc_plus_4_out_ex <= pc_plus_4_in_id;
        rdata1_out_ex <= rdata1_in_id;
        rdata2_out_ex <= rdata2_in_id;
        imm_ext_out_ex <= imm_ext_in_id;
        rs1_out_ex <= rs1_in_id; 
        rs2_out_ex <= rs2_in_id;
        rd_out_ex <= rd_in_id;
        reg_write_out_ex <= reg_write_in_id;
        mem_read_out_ex <= mem_read_in_id;
        mem_write_out_ex <= mem_write_in_id;
        alu_op_out_ex <= alu_op_in_id;
        alu_src_out_ex <= alu_src_in_id;
        branch_out_ex <= branch_in_id;
        jump_out_ex <= jump_in_id;
        result_src_out_ex <= result_src_in_id;
        funct3_out_ex <= funct3_in_id;
        funct7_out_ex <= funct7_in_id;
    end
end

endmodule