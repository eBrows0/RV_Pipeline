module hazard_unit (
    input   wire                EX_MEM_RegWrite,
    input   wire    [4:0]       EX_MEM_Rd,
    input   wire                MEM_WB_RegWrite,
    input   wire    [4:0]       MEM_WB_Rd,
    input   wire    [4:0]       ID_EX_Rs1,
    input   wire    [4:0]       ID_EX_Rs2,
    input   wire                ID_EX_MemRead, // Added for load-use hazard detection

    output  reg     [1:0]       ForwardA,
    output  reg     [1:0]       ForwardB,
    output  reg                 Stall_IF_ID   // Output to stall IF and ID stages
);

reg [1:0] ForwardA_temp;
reg [1:0] ForwardB_temp;

always @(*) begin
    // Initialize to no forwarding (read from register file)
    ForwardA_temp = 2'b00;
    ForwardB_temp = 2'b00;
    Stall_IF_ID = 1'b0;  // Default: no stall

   
    if (ID_EX_MemRead &&
        ((ID_EX_Rs1 != 5'b00000) && (ID_EX_Rs1 == EX_MEM_Rd) ||
         (ID_EX_Rs2 != 5'b00000) && (ID_EX_Rs2 == EX_MEM_Rd))) begin
        Stall_IF_ID = 1'b1;
    end else begin

     
      // EX/MEM to EX forwarding
      if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000) && (EX_MEM_Rd == ID_EX_Rs1)) begin
          ForwardA_temp = 2'b01;
      end
      // MEM/WB to EX forwarding
      else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000) && (MEM_WB_Rd == ID_EX_Rs1)) begin
          ForwardA_temp = 2'b10;
      end

      // Forwarding for ALU operand B (Rs2)
      // EX/MEM to EX forwarding
      if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'b00000) && (EX_MEM_Rd == ID_EX_Rs2)) begin
          ForwardB_temp = 2'b01;
      end
      // MEM/WB to EX forwarding
      else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'b00000) && (MEM_WB_Rd == ID_EX_Rs2)) begin
          ForwardB_temp = 2'b10;
      end
    end
    ForwardA = ForwardA_temp;
    ForwardB = ForwardB_temp;
end

endmodule