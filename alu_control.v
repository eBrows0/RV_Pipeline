module alu_control (
    input wire [2:0]  alu_op,    
    input wire [2:0]  funct3,   
    input wire [6:0]  funct7, 

    output wire [3:0] alu_control_out // 4-bit ALU operation code
);

   

    reg [3:0] alu_op_code;

    always @(*) begin
        case (alu_op)
            3'b000: begin 
                case (funct3)
                    3'b000: alu_op_code = (funct7[5]) ? 4'b1000 : 4'b0000; 
                    3'b001: alu_op_code = 4'b0001; // SLL
                    3'b010: alu_op_code = 4'b0010; // SLT
                    3'b011: alu_op_code = 4'b0011; // SLTU
                    3'b100: alu_op_code = 4'b0100; // XOR
                    3'b101: alu_op_code = (funct7[5]) ? 4'b1101 : 4'b0101; 
                    3'b110: alu_op_code = 4'b0110; // OR
                    3'b111: alu_op_code = 4'b0111; // AND
                    default: alu_op_code = 4'bxxxx; // Should not happen
                endcase
            end
            3'b001: begin 
                case (funct3)
                    3'b000: alu_op_code = 4'b0000; // ADDI
                    3'b001: alu_op_code = 4'b0001; // SLLI
                    3'b010: alu_op_code = 4'b0010; // SLTI
                    3'b011: alu_op_code = 4'b0011; // SLTIU
                    3'b100: alu_op_code = 4'b0100; // XORI
                    3'b101: alu_op_code = (funct7[5]) ? 4'b1101 : 4'b0101; // SRLI / SRAI
                    3'b110: alu_op_code = 4'b0110; // ORI
                    3'b111: alu_op_code = 4'b0111; // ANDI
                    default: alu_op_code = 4'bxxxx; // Should not happen
                endcase
            end
            3'b010: begin 
                alu_op_code = 4'b0000; 
            end
            3'b011: begin 
                alu_op_code = 4'b1000; 
            end
            3'b100: begin 
                alu_op_code = 4'b0000; // ADD for address calculation
            end
            3'b101: begin
                alu_op_code = 4'b0000; // ADD (for AUIPC)
            end
            default: alu_op_code = 4'bxxxx; // Dont care
        endcase
    end

    assign alu_control_out = alu_op_code;

endmodule