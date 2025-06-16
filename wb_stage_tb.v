`timescale 1ns/1ps

module wb_stage_tb;

    // Clock and reset
    reg clk;
    reg reset;

    // Inputs to MEM/WB latch
    reg [31:0] pc_plus_4_in;
    reg [31:0] alu_result_in;
    reg [31:0] read_data_in;
    reg [4:0]  rd_in;
    reg        reg_write_in;
    reg [1:0]  result_src_in;

    // Outputs from MEM/WB latch
    wire [31:0] pc_plus_4_out;
    wire [31:0] alu_result_out;
    wire [31:0] read_data_out;
    wire [4:0]  rd_out;
    wire        reg_write_out;
    wire [1:0]  result_src_out;

    // Output from MUX (final write-back data)
    wire [31:0] write_back_data;

    // Instantiate the MEM/WB register
    mem_wb_register mem_wb_inst (
        .clk(clk),
        .reset(reset),
        .pc_plus_4_in(pc_plus_4_in),
        .alu_result_in(alu_result_in),
        .read_data_in(read_data_in),
        .rd_in(rd_in),
        .reg_write_in(reg_write_in),
        .result_src_in(result_src_in),

        .pc_plus_4_out(pc_plus_4_out),
        .alu_result_out(alu_result_out),
        .read_data_out(read_data_out),
        .rd_out(rd_out),
        .reg_write_out(reg_write_out),
        .result_src_out(result_src_out)
    );

    // Instantiate the mux to select ALU vs MEM
    // Let's assume: result_src[0] = sel for simplicity
    mux2 #(32) wb_mux (
        .in0(alu_result_out),
        .in1(read_data_out),
        .sel(result_src_out[0]), // only LSB decides between ALU(0) and MEM(1)
        .out(write_back_data)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $dumpfile("wb_stage_tb.vcd");
        $dumpvars(0, wb_stage_tb);
        $display("=== WB Stage Testbench ===");

        // Reset
        reset = 1;
        pc_plus_4_in = 0;
        alu_result_in = 0;
        read_data_in = 0;
        rd_in = 0;
        reg_write_in = 0;
        result_src_in = 2'b00;
        #10;

        reset = 0;

        // 1. Simulate ALU result write-back
        pc_plus_4_in = 32'h00000004;
        alu_result_in = 32'hA5A5A5A5;
        read_data_in = 32'h12345678;
        rd_in = 5'd10;
        reg_write_in = 1;
        result_src_in = 2'b00; // ALU selected
        #10;

        $display("Cycle 1 - ALU result: 0x%h", write_back_data); // Expected A5A5A5A5

        // 2. Simulate MEM result write-back
        alu_result_in = 32'hCAFEBABE;
        read_data_in = 32'h87654321;
        rd_in = 5'd11;
        reg_write_in = 1;
        result_src_in = 2'b01; // MEM selected
        #10;

        $display("Cycle 2 - MEM result: 0x%h", write_back_data); // Expected 87654321

        // 3. Reset again
        reset = 1;
        #10;

        $display("After reset - Output: 0x%h", write_back_data); // Should be 0

        $finish;
    end

endmodule
