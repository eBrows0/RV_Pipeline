module fetch (
    input wire clk,
    input wire reset,
    input wire stall_in,

    input wire [3:0] pc_src_sel_in,   
    input wire [31:0] branch_target_in, 
    input wire [31:0] jump_target_in,  
    output wire [31:0] instruction,
    output wire [31:0] pc_plus_4,
    output wire [31:0] current_pc
);

    wire [31:0] pc_next_val;
    wire [31:0] pc_plus_4_val;
    wire [31:0] pc_reg_out; 
   
    program_counter pc_reg (
        .clk(clk),
        .reset(reset),
        .stall_in(stall_in), 
        .pc_in(pc_next_val), 
        .pc_out(pc_reg_out)
    );

    // PC + 4 adder
    adder pc_adder_plus_4 (
        .a(pc_reg_out),
        .b(32'd4),
        .y(pc_plus_4_val)
    );

   
    mux4 #(32) pc_src_mux (
        .in0(pc_plus_4_val),
        .in1(branch_target_in),
        .in2(jump_target_in),
        .in3(32'b0),
        .sel(pc_src_sel_in),
        .out(pc_next_val)
    );

    
    instruction_memory imem (
        .addr(pc_reg_out),      
        .instruction(instruction) 
    );

    assign pc_plus_4 = pc_plus_4_val;
    assign current_pc = pc_reg_out;

endmodule