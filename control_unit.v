module control_unit (
    input wire [6:0] opcode,     
    input wire [2:0] funct3,    
    input wire [6:0] funct7,     
    output reg RegWrite,        
    output reg MemRead,          
    output reg [1:0] MemWrite,   
    output reg [2:0] ALUOp,      
    output reg ALUSrc,           
    output reg Branch,         
    output reg Jump,             
    output reg [1:0] ResultSrc,  
    output reg [2:0] ImmSel    
);
always @(*) begin
   
    RegWrite = 1'b0;
    MemRead = 1'b0;
    MemWrite = 2'b00;
    ALUOp = 3'b000; 
    ALUSrc = 1'b0;
    Branch = 1'b0;
    Jump = 1'b0;
    ResultSrc = 2'b00;
    ImmSel = 3'b000;

    case (opcode)
        7'b0110011: begin 
            RegWrite = 1'b1;
            ALUOp = 3'b000; 
        end

        7'b0010011: begin 
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ALUOp = 3'b001; // I-type ALUOp for alu_control
            ImmSel = 3'b000; // I-type immediate
        end

        7'b0000011: begin // Load instructions (LW, etc.)
            RegWrite = 1'b1;
            MemRead = 1'b1;
            ALUSrc = 1'b1;
            ALUOp = 3'b001; // I-type ALUOp for Load address calculation (ADD)
            ResultSrc = 2'b01;
            ImmSel = 3'b000;
        end

        7'b0100011: begin // S-type instructions (SW, etc.)
            MemWrite = 2'b11;
            ALUSrc = 1'b1;
            ALUOp = 3'b010; // S-type ALUOp for alu_control
            ImmSel = 3'b001;
        end

        7'b1100011: begin // B-type instructions (BEQ, etc.)
            Branch = 1'b1;
            ALUOp = 3'b011; // B-type ALUOp for alu_control
            ImmSel = 3'b010;
        end

        7'b1101111: begin // JAL
            RegWrite = 1'b1;
            Jump = 1'b1;
            ResultSrc = 2'b10; // Result is PC + immediate (branch target)
            ImmSel = 3'b011;
            ALUOp = 3'b100; // J-type ALUOp for alu_control (PC + Imm)
        end

        7'b1100111: begin // JALR
            RegWrite = 1'b1;
            Jump = 1'b1;
            ALUSrc = 1'b1;
            ALUOp = 3'b001; // I-type ALUOp for JALR (Base Reg + Imm)
            ResultSrc = 2'b10;
            ImmSel = 3'b000;
        end

        7'b0110111: begin // LUI
            RegWrite = 1'b1;
            ResultSrc = 2'b00; 
            ALUOp = 3'b101; // U-type ALUOp for alu_control
            ALUSrc = 1'b1;
        end

        7'b0010111: begin // AUIPC
            RegWrite = 1'b1;
            ALUSrc = 1'b1;
            ALUOp = 3'b101; // U-type ALUOp for alu_control (PC + Imm)
            ResultSrc = 2'b00;
            ImmSel = 3'b100; // U-type immediate (This was already correct in your code)
        end

        default: begin 
            RegWrite = 1'b0;
            MemRead = 1'b0;
            MemWrite = 2'b00;
            ALUOp = 3'b000; 
            ALUSrc = 1'b0;
            Branch = 1'b0;
            Jump = 1'b0;
            ResultSrc = 2'b00;
            ImmSel = 3'b000;
        end
    endcase
end
endmodule