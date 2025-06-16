`timescale 1ns / 1ps

module decode_tb;

  reg clk;
  reg reset;
  reg [31:0] instr;
  reg RegWriteW;
  reg [4:0] rdW;
  reg [31:0] resultW;

  reg [31:0] pc_in;
  reg [31:0] pc_plus_4_in;

  wire [31:0] rdata1, rdata2, imm_ext;
  wire [4:0] rs1_addr_out, rs2_addr_out, rd_addr_out;
  wire [6:0] opcode, funct7;
  wire [2:0] funct3;
  wire RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump;
  wire [1:0] ALUOp, ResultSrc;

  // Instantiate the Unit Under Test (UUT)
  decode uut (
    .clk(clk),
    .reset(reset),
    .instr(instr),
    .pc_in(pc_in),
    .pc_plus_4_in(pc_plus_4_in),
    .RegWriteW(RegWriteW),
    .rdW(rdW),
    .resultW(resultW),
    .rdata1(rdata1),
    .rdata2(rdata2),
    .imm_ext(imm_ext),
    .rs1_addr(rs1_addr_out),
    .rs2_addr(rs2_addr_out),
    .rd_addr(rd_addr_out),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .Branch(Branch),
    .Jump(Jump),
    .ResultSrc(ResultSrc)
  );

  // Clock generation
  always #5 clk = ~clk; // Clock with 10ns period

  initial begin
    // Initial conditions
    clk = 0;
    reset = 1;
    RegWriteW = 0;
    rdW = 0;
    resultW = 0;
    pc_in = 0;
    pc_plus_4_in = 4; // Arbitrary for now, not directly used by decode module without full pipeline

    #10; // Hold reset for 10ns
    reset = 0;
    #10; // Wait for initial state to settle after reset goes low

   
    instr = 32'h01400613; // ADD x12, x8, x1
    RegWriteW = 0; // No forwarding from previous instruction for this test
    rdW = 0;
    resultW = 0;
    #10;
    $display("\n--- Instr 1: ADD x12, x8, x1 (0x01400613) ---");
    $display("opcode=%b rd=%d rs1=%d rs2=%d funct3=%b funct7=%b", opcode, rd_addr_out, rs1_addr_out, rs2_addr_out, funct3, funct7);
    $display("imm_ext=%d RegWrite=%b MemRead=%b MemWrite=%b ALUSrc=%b Branch=%b Jump=%b ALUOp=%b ResultSrc=%b",
              imm_ext, RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, ALUOp, ResultSrc);
    $display("rdata1=%d rdata2=%d (Expected: 0s if RF uninitialized, no forwarding)", rdata1, rdata2);
  
    instr = 32'h00400593; // ADDI x11, x8, 4
   
    RegWriteW = 1;      // WB stage *is* writing
    rdW = 5'd12;        // To x12
    resultW = 32'd50;   // Arbitrary result for x12
    #10;
    $display("\n--- Instr 2: ADDI x11, x8, 4 (0x00400593) ---");
    $display("opcode=%b rd=%d rs1=%d rs2=%d funct3=%b funct7=%b", opcode, rd_addr_out, rs1_addr_out, rs2_addr_out, funct3, funct7);
    $display("imm_ext=%d RegWrite=%b MemRead=%b MemWrite=%b ALUSrc=%b Branch=%b Jump=%b ALUOp=%b ResultSrc=%b",
              imm_ext, RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, ALUOp, ResultSrc);
    $display("rdata1=%d rdata2=%d (Expected: rdata1=0 for x8, rdata2=0 for x0)", rdata1, rdata2); // No forwarding for x8 in this cycle

    instr = 32'h00b585b3; // ADD x11, x11, x11
    RegWriteW = 1;        // Simulate previous ADDI to x11
    rdW = 5'd11;          // Previous instruction wrote to x11
    resultW = 32'd10;     // Value the ADDI would have produced for x11
    #10;
    $display("\n--- Instr 3: ADD x11, x11, x11 (0x00b585b3) ---");
    $display("opcode=%b rd=%d rs1=%d rs2=%d funct3=%b funct7=%b", opcode, rd_addr_out, rs1_addr_out, rs2_addr_out, funct3, funct7);
    $display("imm_ext=%d RegWrite=%b MemRead=%b MemWrite=%b ALUSrc=%b Branch=%b Jump=%b ALUOp=%b ResultSrc=%b",
              imm_ext, RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, ALUOp, ResultSrc);
    $display("rdata1=%d (Expected: 10 - Forwarded from resultW for x11)", rdata1);
    $display("rdata2=%d (Expected: 10 - Forwarded from resultW for x11)", rdata2);
 


  
    instr = 32'h00c58633; // ADD x12, x11, x12
    RegWriteW = 1;        // Simulate previous ADD to x11
    rdW = 5'd11;          // Previous instruction wrote to x11
    resultW = 32'd20;     // Value the ADD would have produced for x11 (10 + 10 = 20)
    #10;
    $display("\n--- Instr 4: ADD x12, x11, x12 (0x00c58633) ---");
    $display("opcode=%b rd=%d rs1=%d rs2=%d funct3=%b funct7=%b", opcode, rd_addr_out, rs1_addr_out, rs2_addr_out, funct3, funct7);
    $display("imm_ext=%d RegWrite=%b MemRead=%b MemWrite=%b ALUSrc=%b Branch=%b Jump=%b ALUOp=%b ResultSrc=%b",
              imm_ext, RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, ALUOp, ResultSrc);
    $display("rdata1=%d (Expected: 20 - Forwarded from resultW for x11)", rdata1);
    $display("rdata2=%d (Expected: 50 - If x12 had 50 from Instr 2, else 0 if RF uninitialized, no forwarding for x12 in this setup)", rdata2);
    
    // This instruction does *not* write to a register. So RegWriteW, rdW, resultW should be cleared.
    instr = 32'h0400006f; // JAL x0, 0x40
    RegWriteW = 0; // This JAL does not write to a register
    rdW = 0;
    resultW = 0;
    #10;
    $display("\n--- Instr 5: JAL x0, 0x40 (0x0400006f) ---");
    $display("opcode=%b rd=%d rs1=%d rs2=%d funct3=%b funct7=%b", opcode, rd_addr_out, rs1_addr_out, rs2_addr_out, funct3, funct7);
    $display("imm_ext=%d RegWrite=%b MemRead=%b MemWrite=%b ALUSrc=%b Branch=%b Jump=%b ALUOp=%b ResultSrc=%b",
              imm_ext, RegWrite, MemRead, MemWrite, ALUSrc, Branch, Jump, ALUOp, ResultSrc);
    $display("rdata1=%d rdata2=%d (Expected: 0s as rs1/rs2 are 0 for JAL, no forwarding)", rdata1, rdata2);
  

    #20 $finish; // End simulation after some time
  end

endmodule