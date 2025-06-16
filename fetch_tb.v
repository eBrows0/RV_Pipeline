`timescale 1ns / 1ps
module fetch_tb;

    reg clk;
    reg reset;
    reg stall_in; // Added: Control signal for stalling the PC
    
    reg [3:0] pc_src_sel_in;
    reg [31:0] branch_target_in;
    reg [31:0] jump_target_in;

    wire [31:0] current_pc;
    wire [31:0] pc_plus_4;
    wire [31:0] instruction;

    fetch uut (
        .clk(clk),
        .reset(reset),
        .stall_in(stall_in), // Connected: Ensure fetch module receives this
        .pc_src_sel_in(pc_src_sel_in),
        .branch_target_in(branch_target_in),
        .jump_target_in(jump_target_in),
        .current_pc(current_pc),
        .pc_plus_4(pc_plus_4),
        .instruction(instruction)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    initial begin
        $dumpfile("fetch_tb.vcd");    
        $dumpvars(0, fetch_tb);    

        // Inicialización
        reset = 1;
        stall_in = 0; // Initialize stall_in to 0 (no stall)
        pc_src_sel_in = 4'b0000; // PC+4 mode
        branch_target_in = 32'b0;
        jump_target_in = 32'b0;
        #10; // Hold reset for one clock cycle

        // Quitar reset
        reset = 0;
        #10; // Wait for the first PC update to 0x0 and instruction fetch

        // INSTRUCCIÓN 1: ADDI x12, x0, 20 (PC=0)
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        #10;

        // INSTRUCCIÓN 2: ADDI x11, x0, 4 (PC=4)
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        #10;

        // INSTRUCCIÓN 3: ADD x11, x11, x11 (PC=8)
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        #10;

        // INSTRUCCIÓN 4: ADD x12, x11, x12 (PC=C)
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        #10;

        // INSTRUCCIÓN 5: JAL x0, 0x40 (PC=10h)
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        #10;

        
        $display("\n--- Testing JUMP to 0x50 ---");
        jump_target_in = 32'h50; // New target
        pc_src_sel_in = 4'b0010; // Select jump_target_in
      
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        #10; // PC should now be 0x50
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b (After JUMP)", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        
        // Reset control signals for sequential execution
        pc_src_sel_in = 4'b0000; 
        jump_target_in = 32'b0;
        #10;
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b, PC_Sel: %b (Sequential from 0x50)", $time, current_pc, instruction, pc_plus_4, stall_in, pc_src_sel_in);
        
        // Test a stall
        $display("\n--- Testing STALL ---");
        stall_in = 1; // Activate stall
        #10; // PC should NOT increment here
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b (STALLED - PC should be unchanged)", $time, current_pc, instruction, pc_plus_4, stall_in);
        #10; // PC should still be unchanged
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b (STALLED - PC still unchanged)", $time, current_pc, instruction, pc_plus_4, stall_in);
        
        stall_in = 0; // Release stall
        #10; // PC should now advance
        $display("Time: %0t, PC: 0x%08h, Instr: 0x%08h, PC+4: 0x%08h, Stall: %b (STALL RELEASED - PC advanced)", $time, current_pc, instruction, pc_plus_4, stall_in);

        #20; // Esperar un par de ciclos extra para observar más
        $display("Simulation finished. Check fetch_tb.vcd for waveforms.");
        $stop;
    end

endmodule