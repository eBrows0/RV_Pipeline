`timescale 1ns / 1ps

module ex_tb();

    // ALU Control inputs
    reg [2:0] alu_op;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire [3:0] alu_ctrl_out;

    // ALU inputs
    reg [31:0] operand_a, operand_b;
    wire [31:0] alu_result;
    wire zero_flag, less_than_flag, overflow_flag;

    // Instantiate ALU Control
    alu_control alu_ctrl_inst (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control_out(alu_ctrl_out)
    );

    // Instantiate ALU
    alu alu_inst (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control_code(alu_ctrl_out),
        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .less_than_flag(less_than_flag),
        .overflow_flag(overflow_flag)
    );

    // Simulated registers (for testing)
    reg [31:0] x11, x12;

    initial begin
        $display("---- Minimal EX Stage Testbench ----");

        // -------------------------
        // 01400613 → ADDI x12, x0, 20
        // -------------------------
        alu_op = 3'b001;           // I-type
        funct3 = 3'b000;           // ADDI
        funct7 = 7'b0000000;
        operand_a = 32'd0;         // x0
        operand_b = 32'd20;
        #10;
        x12 = alu_result;
        $display("ADDI x12 = %d", x12);

        // -------------------------
        // 00400593 → ADDI x11, x0, 4
        // -------------------------
        operand_a = 32'd0;
        operand_b = 32'd4;
        #10;
        x11 = alu_result;
        $display("ADDI x11 = %d", x11);

        // -------------------------
        // 00b585b3 → ADD x11, x11, x11
        // -------------------------
        alu_op = 3'b000;           // R-type
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        operand_a = x11;
        operand_b = x11;
        #10;
        x11 = alu_result;
        $display("ADD x11, x11, x11 = %d", x11);

        // -------------------------
        // 00c58633 → ADD x12, x11, x12
        // -------------------------
        operand_a = x11;
        operand_b = x12;
        #10;
        x12 = alu_result;
        $display("ADD x12, x11, x12 = %d", x12);

        // -------------------------
        // 0400006f → JAL x0, 64 (simulate PC + offset)
        // -------------------------
        alu_op = 3'b001;           // Use ADD
        operand_a = 32'd100;       // Simulated PC
        operand_b = 32'd64;        // Offset
        #10;
        $display("JAL x0, 64 → PC + offset = %d", alu_result);

        $finish;
    end

endmodule
