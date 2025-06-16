module alu (
    input wire [31:0] operand_a,
    input wire [31:0] operand_b,
    input wire [3:0]  alu_control_code, 

    output wire [31:0] alu_result,
    output wire        zero_flag,      
    output wire        less_than_flag, 
    output wire        overflow_flag   
);

    reg [31:0] result;
    reg        zero;
    reg        less_than;
    reg        overflow;

   
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SLL  = 4'b0001;
    localparam ALU_SLT  = 4'b0010;
    localparam ALU_SLTU = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SRL  = 4'b0101;
    localparam ALU_OR   = 4'b0110;
    localparam ALU_AND  = 4'b0111;
    localparam ALU_SUB  = 4'b1000;
    localparam ALU_SRA  = 4'b1101;


    always @(*) begin
        result = 32'b0;
        zero = 1'b0;
        less_than = 1'b0;
        overflow = 1'b0; 
        case (alu_control_code)
            ALU_ADD: begin
                result = operand_a + operand_b;
               
            end
            ALU_SUB: begin
                result = operand_a - operand_b;
               
            end
            ALU_SLL: result = operand_a << operand_b[4:0]; // Shift amount is 5 bits
            ALU_SLT: begin // Signed less than
                if ($signed(operand_a) < $signed(operand_b)) begin
                    result = 32'd1;
                    less_than = 1'b1;
                end else begin
                    result = 32'd0;
                end
            end
            ALU_SLTU: begin // Unsigned less than
                if (operand_a < operand_b) begin
                    result = 32'd1;
                    less_than = 1'b1;
                end else begin
                    result = 32'd0;
                end
            end
            ALU_XOR: result = operand_a ^ operand_b;
            ALU_SRL: result = operand_a >> operand_b[4:0]; // Logical Right Shift
            ALU_OR:  result = operand_a | operand_b;
            ALU_AND: result = operand_a & operand_b;
            ALU_SRA: result = $signed(operand_a) >>> operand_b[4:0]; 
            default: result = 32'b0; 
        endcase

        if (result == 32'b0) zero = 1'b1;
    end

    assign alu_result = result;
    assign zero_flag = zero;
    assign less_than_flag = less_than; 
    assign overflow_flag = overflow;

endmodule