// riscv_pipeline_tb.v
// Testbench for the RISC-V Pipeline

`timescale 1ns/1ps // Define timescale for simulation

module riscv_pipeline_tb;

    // ----------------------------------------------------
    // Testbench Signals (Inputs to DUT are regs, Outputs from DUT are wires)
    // ----------------------------------------------------
    reg  clk;
    reg  reset;

    // Outputs from the DUT (your riscv_pipeline) - declared as wires
    // Renamed from debug_ to functional names (matching riscv_pipeline.v's new ports)
    wire [31:0] current_pc_if_stage;
    wire [31:0] instr_id_stage;
    wire [31:0] alu_result_ex_stage;
    wire        zero_flag_ex_stage;
    wire [31:0] branch_target_ex_stage;
    wire [31:0] jump_target_ex_stage;
    wire        branch_taken_ex_stage;
    wire [3:0]  alu_control_code_ex_stage;
    wire        alu_src_out_ex_stage;
    wire [31:0] rdata1_out_ex_stage;
    wire [31:0] rdata2_out_ex_stage;
    wire [31:0] imm_ext_out_ex_stage;
    wire [4:0]  rd_out_ex_stage;
    wire        reg_write_out_ex_stage;
    wire        mem_read_out_ex_stage;
    wire [1:0]  mem_write_out_ex_stage; // <<-- Updated to 2-bit

    // MEM Stage Debug Signals (NEW)
    wire [31:0] read_data_mem_stage;
    wire [31:0] mem_addr_mem_stage;
    wire [31:0] mem_write_data_mem_stage;

    // WB Stage Debug Signals (NEW)
    wire [31:0] wb_result_wb_stage; // Renamed from debug_wb_resultW
    wire [4:0]  wb_rd_wb_stage;     // Renamed from debug_wb_rdW
    wire        wb_reg_write_wb_stage; // Renamed from debug_wb_RegWriteW


    // Clock period definition
    parameter CLK_PERIOD = 10; // 10ns period = 100MHz clock

    // ----------------------------------------------------
    // DUT Instantiation
    // ----------------------------------------------------
    riscv_pipeline DUT (
        .clk(clk),
        .reset(reset),

        // Connections for EX Stage Debug Signals
        .current_pc_if_stage(current_pc_if_stage),
        .instr_id_stage(instr_id_stage),
        .alu_result_ex_stage(alu_result_ex_stage),
        .zero_flag_ex_stage(zero_flag_ex_stage),
        .branch_target_ex_stage(branch_target_ex_stage),
        .jump_target_ex_stage(jump_target_ex_stage),
        .branch_taken_ex_stage(branch_taken_ex_stage),
        .alu_control_code_ex_stage(alu_control_code_ex_stage),
        .alu_src_out_ex_stage(alu_src_out_ex_stage),
        .rdata1_out_ex_stage(rdata1_out_ex_stage),
        .rdata2_out_ex_stage(rdata2_out_ex_stage),
        .imm_ext_out_ex_stage(imm_ext_out_ex_stage), // Corrected port name
        .rd_out_ex_stage(rd_out_ex_stage),
        .reg_write_out_ex_stage(reg_write_out_ex_stage),
        .mem_read_out_ex_stage(mem_read_out_ex_stage),
        .mem_write_out_ex_stage(mem_write_out_ex_stage),

        // Connections for MEM Stage Debug Signals (NEW)
        .read_data_mem_stage(read_data_mem_stage),
        .mem_addr_mem_stage(mem_addr_mem_stage),
        .mem_write_data_mem_stage(mem_write_data_mem_stage),

        // Connections for WB Stage Debug Signals (NEW)
        .wb_result_wb_stage(wb_result_wb_stage),
        .wb_rd_wb_stage(wb_rd_wb_stage),
        .wb_reg_write_wb_stage(wb_reg_write_wb_stage)
    );

    // ----------------------------------------------------
    // Clock Generation
    // ----------------------------------------------------
    always begin
        #(CLK_PERIOD/2) clk = ~clk; // Toggle clock every half period
    end

    // ----------------------------------------------------
    // Initial Block (Reset and Stimulus)
    // ----------------------------------------------------
    initial begin
        // Initialize signals
        clk = 1'b0;
        reset = 1'b1; // Assert reset

        // Dump waveforms (for simulators like QuestaSim/ModelSim)
        $dumpfile("riscv_pipeline.vcd"); // Creates Value Change Dump file

        // Dump ALL signals under DUT for comprehensive debugging
        // This is the most robust way to ensure all internal signals are captured.
        $dumpvars(0, DUT); 

        // Apply reset for a few clock cycles
        #(CLK_PERIOD * 2) reset = 1'b0; // Deassert reset

        // Allow pipeline to run for a number of cycles
        // Adjust this duration based on the program loaded in instruction_memory
        #(CLK_PERIOD * 100); // Increased to 100 cycles to allow complex code to complete

        // End simulation
        $finish;
    end

    // ----------------------------------------------------
    // Monitoring (Optional: for console output during simulation)
    // ----------------------------------------------------
    // This will print values at every positive clock edge after reset
    always @(posedge clk) begin
        if (!reset) begin
            $display("Time: %0t | PC_IF: %h | Instr_ID: %h | ALU_Res_EX: %h | Zero_EX: %b | Br_Taken_EX: %b | Rdata1_EX: %h | Rdata2_EX: %h | WB_Result: %h",
                     $time,
                     current_pc_if_stage,
                     instr_id_stage,
                     alu_result_ex_stage,
                     zero_flag_ex_stage,
                     branch_taken_ex_stage,
                     rdata1_out_ex_stage,
                     rdata2_out_ex_stage,
                     wb_result_wb_stage // Added WB Result for final verification in console
            );
        end
    end

endmodule