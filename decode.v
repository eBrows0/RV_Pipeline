module decode (
    input wire clk,
    input wire reset,
    input wire [31:0] instr,
    input wire [31:0] pc_in,
    input wire [31:0] pc_plus_4_in,
    input wire        RegWriteW,
    input wire [4:0]  rdW,
    input wire [31:0] resultW,

    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    output wire [31:0] imm_ext,
    output wire [4:0]  rs1_addr,
    output wire [4:0]  rs2_addr,
    output wire [4:0]  rd_addr,
    output wire [6:0]  opcode,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,
    output wire        RegWrite,
    output wire        MemRead,
    output wire        MemWrite,
    output wire [2:0]  ALUOp,
    output wire        ALUSrc,
    output wire        Branch,
    output wire        Jump,
    output wire [1:0]  ResultSrc
);

    wire [4:0] instr_rs1_addr;
    wire [4:0] instr_rs2_addr;
    wire [4:0] instr_rd_addr;

    assign opcode         = instr[6:0];
    assign instr_rd_addr  = instr[11:7];
    assign funct3         = instr[14:12];
    assign instr_rs1_addr = instr[19:15];
    assign instr_rs2_addr = instr[24:20];
    assign funct7         = instr[31:25];

    assign rs1_addr = instr_rs1_addr;
    assign rs2_addr = instr_rs2_addr;
    assign rd_addr  = instr_rd_addr;

    wire [2:0] imm_sel;

    control_unit ctrl (
        .opcode    (opcode),
        .funct3    (funct3),
        .funct7    (funct7),
        .RegWrite  (RegWrite),
        .MemRead   (MemRead),
        .MemWrite  (MemWrite),
        .ALUOp     (ALUOp),
        .ALUSrc    (ALUSrc),
        .Branch    (Branch),
        .Jump      (Jump),
        .ResultSrc (ResultSrc),
        .ImmSel    (imm_sel)
    );

    imm_gen immgen (
        .instr     (instr),
        .imm_sel   (imm_sel),
        .imm_ext   (imm_ext)
    );

    wire [31:0] rf_rdata1_raw;
    wire [31:0] rf_rdata2_raw;

    register_file rf (
        .clk        (clk),
        .reset      (reset),
        .rs1        (instr_rs1_addr),
        .rs2        (instr_rs2_addr),
        .rd         (rdW),
        .wdata      (resultW),
        .RegWrite   (RegWriteW),
        .rdata1     (rf_rdata1_raw),
        .rdata2     (rf_rdata2_raw)
    );

    wire forward_A_from_WB;
    assign forward_A_from_WB = (RegWriteW && (rdW != 0) && (rdW == instr_rs1_addr));

    wire forward_B_from_WB;
    assign forward_B_from_WB = (RegWriteW && (rdW != 0) && (rdW == instr_rs2_addr));

    assign rdata1 = forward_A_from_WB ? resultW : rf_rdata1_raw;
    assign rdata2 = forward_B_from_WB ? resultW : rf_rdata2_raw;

endmodule
