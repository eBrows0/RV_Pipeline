module riscv_pipeline (
    input wire clk,
    input wire reset,

   
    output wire [31:0] current_pc_if_stage,     
    output wire [31:0] instr_id_stage,           

   
    output wire [31:0] alu_result_ex_stage,
    output wire        zero_flag_ex_stage,
    output wire [31:0] branch_target_ex_stage,
    output wire [31:0] jump_target_ex_stage,
    output wire        branch_taken_ex_stage,
    output wire [3:0]  alu_control_code_ex_stage,
    output wire        alu_src_out_ex_stage,
    output wire [31:0] rdata1_out_ex_stage,       
    output wire [31:0] rdata2_out_ex_stage,       
    output wire [31:0] imm_ext_out_ex_stage,
    output wire [4:0]  rd_out_ex_stage,
    output wire        reg_write_out_ex_stage,
    output wire        mem_read_out_ex_stage,
    output wire [1:0]  mem_write_out_ex_stage,

  
    output wire [31:0] read_data_mem_stage,
    output wire [31:0] mem_addr_mem_stage,
    output wire [31:0] mem_write_data_mem_stage,

    // Outputs for WB Stage
    output wire [31:0] wb_result_wb_stage,        
    output wire [4:0]  wb_rd_wb_stage,            
    output wire        wb_reg_write_wb_stage      
);


    wire [31:0] if_instr_to_reg;        
    wire [31:0] if_pc_plus_4_to_reg;    
    wire [31:0] if_current_pc_to_reg;   

    // Wires for ID/EX register
    wire [31:0] id_instr_from_reg;          
    wire [31:0] id_pc_plus_4_from_reg;      
    wire [31:0] id_pc_from_reg;             

    // Wires for Decode stage outputs
    wire [31:0] id_rdata1;
    wire [31:0] id_rdata2;
    wire [31:0] id_imm_ext;
    wire [4:0]  id_rs1_addr;
    wire [4:0]  id_rs2_addr;
    wire [4:0]  id_rd_addr;
    wire        id_reg_write;
    wire        id_mem_read;
    wire [1:0]  id_mem_write;
    wire [2:0]  id_alu_op;
    wire        id_alu_src;
    wire        id_branch;
    wire        id_jump;
    wire [1:0]  id_result_src;
    wire [2:0]  id_funct3;
    wire [6:0]  id_funct7;
    wire [6:0]  id_opcode;

    // Wires for ID/EX register outputs to EX stage inputs
    wire [31:0] id_ex_pc_out;
    wire [31:0] id_ex_pc_plus_4_out;
    wire [31:0] id_ex_rdata1_out;
    wire [31:0] id_ex_rdata2_out;
    wire [31:0] id_ex_imm_ext_out;
    wire [4:0]  id_ex_rs1_addr_out;
    wire [4:0]  id_ex_rs2_out;
    wire [4:0]  id_ex_rd_out;
    wire        id_ex_reg_write_out;
    wire        id_ex_mem_read_out;
    wire [1:0]  id_ex_mem_write_out;
    wire [2:0]  id_ex_alu_op_out;
    wire        id_ex_alu_src_out;
    wire        id_ex_branch_out;
    wire        id_ex_jump_out;
    wire [1:0]  id_ex_result_src_out;
    wire [2:0]  id_ex_funct3_out;
    wire [6:0]  id_ex_funct7_out;

    
    wire [31:0] alu_operand_a;          
    wire [31:0] alu_operand_b;         
    wire [3:0]  alu_control_code;      
    wire [31:0] alu_result;             
    wire        zero_flag;              
    wire        less_than_flag;         
    wire        overflow_flag;         
    wire [31:0] branch_target_ex;       
    wire [31:0] jump_target_ex;         
    wire        branch_taken_ex;       
    wire [3:0] pc_src_sel_ex;          

   
    wire [31:0] ex_mem_pc_plus_4_out;
    wire [31:0] ex_mem_alu_result_out;
    wire [31:0] ex_mem_rdata2_out; // For SW instruction
    wire [4:0]  ex_mem_rd_out;
    wire [1:0]  ex_mem_mem_write_out;
    wire        ex_mem_mem_read_out;
    wire        ex_mem_reg_write_out;
    wire [1:0]  ex_mem_result_src_out;

   
    wire [31:0] mem_read_data; 
   
    wire [31:0] mem_wb_pc_plus_4_out;
    wire [31:0] mem_wb_alu_result_out;
    wire [31:0] mem_wb_read_data_out;
    wire [4:0]  mem_wb_rd_out;
    wire        mem_wb_reg_write_out;
    wire [1:0]  mem_wb_result_src_out;

    
    wire        wb_RegWriteW_internal;  
    wire [4:0]  wb_rdW_internal;        
    wire [31:0] wb_resultW_internal;   
	 wire [31:0] wb_mux_result;

    // Wires for Hazard Unit outputs
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;
    wire        stall_if_id; 

    // Wires for the inputs of the forwarding muxes
    wire [31:0] forwarded_rdata1;
    wire [31:0] forwarded_rdata2_from_rf; 
   

    // 1. FETCH Stage
    fetch IF_stage_inst (
        .clk(clk),
        .reset(reset),
        .stall_in(stall_if_id), 
        .pc_src_sel_in(pc_src_sel_ex),
        .branch_target_in(branch_target_ex),
        .jump_target_in(jump_target_ex),

        .instruction(if_instr_to_reg),
        .pc_plus_4(if_pc_plus_4_to_reg),
        .current_pc(if_current_pc_to_reg)
    );

    // IF/ID Pipeline Register
    if_id_register IF_ID_reg_inst (
        .clk(clk),
        .reset(reset),
        .stall_id(stall_if_id), 
        .if_instr_in(if_instr_to_reg),
        .if_pc_plus_4_in(if_pc_plus_4_to_reg),
        .if_current_pc_in(if_current_pc_to_reg),

        .id_instr_out(id_instr_from_reg),
        .id_pc_plus_4_out(id_pc_plus_4_from_reg),
        .id_pc_out(id_pc_from_reg)
    );

    // 2. DECODE Stage
    decode ID_stage_inst (
        .clk(clk),
        .reset(reset),
        .instr(id_instr_from_reg),
        .pc_in(id_pc_from_reg),
        .pc_plus_4_in(id_pc_plus_4_from_reg),

        .RegWriteW(wb_RegWriteW_internal), 
        .rdW(wb_rdW_internal),          
        .resultW(wb_resultW_internal),    

        .rdata1(id_rdata1),
        .rdata2(id_rdata2),
        .imm_ext(id_imm_ext),
        .rs1_addr(id_rs1_addr),
        .rs2_addr(id_rs2_addr),
        .rd_addr(id_rd_addr),
        .opcode(id_opcode),
        .funct3(id_funct3),
        .funct7(id_funct7),
        .RegWrite(id_reg_write),
        .MemRead(id_mem_read),
        .MemWrite(id_mem_write),
        .ALUOp(id_alu_op),
        .ALUSrc(id_alu_src),
        .Branch(id_branch),
        .Jump(id_jump),
        .ResultSrc(id_result_src)
    );

    // ID/EX Pipeline Register
    id_ex_register ID_EX_reg_inst (
        .clk(clk),
        .reset(reset),
        .flush_ex(1'b0), 
        .stall_ex(stall_if_id), 

       
        .pc_in_id(id_pc_from_reg),
        .pc_plus_4_in_id(id_pc_plus_4_from_reg),
        .rdata1_in_id(id_rdata1),
        .rdata2_in_id(id_rdata2),
        .imm_ext_in_id(id_imm_ext),
        .rs1_in_id(id_rs1_addr),
        .rs2_in_id(id_rs2_addr),
        .rd_in_id(id_rd_addr),
        .reg_write_in_id(id_reg_write),
        .mem_read_in_id(id_mem_read),
        .mem_write_in_id(id_mem_write),
        .alu_op_in_id(id_alu_op),
        .alu_src_in_id(id_alu_src),
        .branch_in_id(id_branch),
        .jump_in_id(id_jump),
        .result_src_in_id(id_result_src),
        .funct3_in_id(id_funct3),
        .funct7_in_id(id_funct7),

        // Outputs to EX stage inputs
        .pc_out_ex(id_ex_pc_out),
        .pc_plus_4_out_ex(id_ex_pc_plus_4_out),
        .rdata1_out_ex(id_ex_rdata1_out),
        .rdata2_out_ex(id_ex_rdata2_out),
        .imm_ext_out_ex(id_ex_imm_ext_out),
        .rs1_out_ex(id_ex_rs1_addr_out),
        .rs2_out_ex(id_ex_rs2_out),
        .rd_out_ex(id_ex_rd_out),
        .reg_write_out_ex(id_ex_reg_write_out),
        .mem_read_out_ex(id_ex_mem_read_out),
        .mem_write_out_ex(id_ex_mem_write_out),
        .alu_op_out_ex(id_ex_alu_op_out),
        .alu_src_out_ex(id_ex_alu_src_out),
        .branch_out_ex(id_ex_branch_out),
        .jump_out_ex(id_ex_jump_out),
        .result_src_out_ex(id_ex_result_src_out),
        .funct3_out_ex(id_ex_funct3_out),
        .funct7_out_ex(id_ex_funct7_out)
    );

    // --- HAZARD UNIT INSTANTIATION ---
    hazard_unit Hazard_Unit_inst (
        .EX_MEM_RegWrite (ex_mem_reg_write_out),
        .EX_MEM_Rd       (ex_mem_rd_out),
        .MEM_WB_RegWrite (mem_wb_reg_write_out),
        .MEM_WB_Rd       (mem_wb_rd_out),
        .ID_EX_Rs1       (id_ex_rs1_addr_out), // Needs to be passed through ID/EX register
        .ID_EX_Rs2       (id_ex_rs2_out),
        .ID_EX_MemRead   (id_ex_mem_read_out), // For load-use hazard
        .ForwardA        (forward_a),
        .ForwardB        (forward_b),
        .Stall_IF_ID     (stall_if_id)
    );

    // 3. EXECUTE Stage
    alu_control ALU_Control_inst (
        .alu_op(id_ex_alu_op_out),
        .funct3(id_ex_funct3_out),
        .funct7(id_ex_funct7_out),
        .alu_control_out(alu_control_code)
    );

   

    // Forwarding Mux for ALU Operand A (Rs1)
    mux4 #(32) ALU_Operand_A_Forward_Mux (
        .in0(id_ex_rdata1_out),     
        .in1(ex_mem_alu_result_out), 
        .in2(wb_resultW_internal),   
        .in3(32'b0),                
        .sel(forward_a),
        .out(alu_operand_a)         
    );

    
    mux4 #(32) ALU_Operand_B_Rdata2_Forward_Mux (
        .in0(id_ex_rdata2_out),      
        .in1(ex_mem_alu_result_out), 
        .in2(wb_resultW_internal),  
        .in3(32'b0),               
        .sel(forward_b),
        .out(forwarded_rdata2_from_rf)
    );

   
    mux2 #(32) ALU_Src_Mux_inst (
        .in0(forwarded_rdata2_from_rf), 
        .in1(id_ex_imm_ext_out),
        .sel(id_ex_alu_src_out),
        .out(alu_operand_b)            
    );

    alu ALU_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control_code(alu_control_code),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .less_than_flag(less_than_flag),
        .overflow_flag(overflow_flag)
    );

    adder Branch_Target_Adder_inst (
        .a(id_ex_pc_out),
        .b(id_ex_imm_ext_out),
        .y(branch_target_ex)
    );

    adder JALR_Target_Adder_inst (
        .a(alu_operand_a),
        .b(id_ex_imm_ext_out),
        .y(jump_target_ex)
    );

    
    assign branch_taken_ex = id_ex_branch_out &&
                             ((id_ex_funct3_out == 3'b000 && zero_flag) || 
                              (id_ex_funct3_out == 3'b001 && !zero_flag) ||
                              (id_ex_funct3_out == 3'b100 && less_than_flag) || 
                              (id_ex_funct3_out == 3'b101 && !less_than_flag)); 
                            

  
    assign pc_src_sel_ex = (id_ex_jump_out) ? 4'b0010 :
                           (branch_taken_ex) ? 4'b0001 :
                           4'b0000; 

    // EX/MEM Pipeline Register
    ex_mem_register EX_MEM_reg_inst (
        .clk(clk),
        .reset(reset),
        .pc_plus_4_in(id_ex_pc_plus_4_out),
        .alu_result_in(alu_result),
        .rdata2_in(id_ex_rdata2_out),
        .rd_in(id_ex_rd_out),
        .mem_write_in(id_ex_mem_write_out),
        .mem_read_in(id_ex_mem_read_out),
        .reg_write_in(id_ex_reg_write_out),
        .result_src_in(id_ex_result_src_out),

        .pc_plus_4_out(ex_mem_pc_plus_4_out),
        .alu_result_out(ex_mem_alu_result_out),
        .rdata2_out(ex_mem_rdata2_out),
        .rd_out(ex_mem_rd_out),
        .mem_write_out(ex_mem_mem_write_out),
        .mem_read_out(ex_mem_mem_read_out),
        .reg_write_out(ex_mem_reg_write_out),
        .result_src_out(ex_mem_result_src_out)
    );

    // 4. MEMORY Stage
    data_memory Data_Memory_inst (
        .clk(clk),
        .addr(ex_mem_alu_result_out),      // ALU result is memory address
        .write_data(ex_mem_rdata2_out),    // rdata2 for SW
        .mem_write(ex_mem_mem_write_out),  // 2-bit control
        .mem_read(ex_mem_mem_read_out),
        .read_data(mem_read_data)          // Data read from memory
    );

    // MEM/WB Pipeline Register
    mem_wb_register MEM_WB_reg_inst (
        .clk(clk),
        .reset(reset),
        .pc_plus_4_in(ex_mem_pc_plus_4_out),
        .alu_result_in(ex_mem_alu_result_out),
        .read_data_in(mem_read_data),
        .rd_in(ex_mem_rd_out),
        .reg_write_in(ex_mem_reg_write_out),
        .result_src_in(ex_mem_result_src_out),

        .pc_plus_4_out(mem_wb_pc_plus_4_out),
        .alu_result_out(mem_wb_alu_result_out),
        .read_data_out(mem_wb_read_data_out),
        .rd_out(mem_wb_rd_out),
        .reg_write_out(mem_wb_reg_write_out),
        .result_src_out(mem_wb_result_src_out)
    );

    
    mux4 #(32) Result_Src_Mux_inst (
        .in0(mem_wb_alu_result_out),
        .in1(mem_wb_read_data_out),
        .in2(mem_wb_pc_plus_4_out),
        .in3(32'b0), 
        .sel(mem_wb_result_src_out),
        .out(wb_mux_result)
    );

   
    assign wb_RegWriteW_internal = mem_wb_reg_write_out;
    assign wb_rdW_internal       = mem_wb_rd_out;
    assign wb_resultW_internal   = wb_mux_result;


    
    assign current_pc_if_stage = if_current_pc_to_reg;
    assign instr_id_stage = id_instr_from_reg;

    assign alu_result_ex_stage = alu_result;
    assign zero_flag_ex_stage = zero_flag;
    assign branch_target_ex_stage = branch_target_ex;
    assign jump_target_ex_stage = jump_target_ex;
    assign branch_taken_ex_stage = branch_taken_ex;
    assign alu_control_code_ex_stage = alu_control_code;
    assign alu_src_out_ex_stage = id_ex_alu_src_out;
    assign rdata1_out_ex_stage = alu_operand_a; 
    assign rdata2_out_ex_stage = forwarded_rdata2_from_rf; 
    assign imm_ext_out_ex_stage = id_ex_imm_ext_out;
    assign rd_out_ex_stage = id_ex_rd_out;
    assign reg_write_out_ex_stage = id_ex_reg_write_out;
    assign mem_read_out_ex_stage = id_ex_mem_read_out;
    assign mem_write_out_ex_stage = id_ex_mem_write_out;

    // Outputs for MEM stage
    assign read_data_mem_stage = mem_read_data;
    assign mem_addr_mem_stage = ex_mem_alu_result_out;
    assign mem_write_data_mem_stage = ex_mem_rdata2_out;

    // Outputs for WB stage
    assign wb_result_wb_stage = wb_resultW_internal;
    assign wb_rd_wb_stage = wb_rdW_internal;
    assign wb_reg_write_wb_stage = wb_RegWriteW_internal;
	 

endmodule