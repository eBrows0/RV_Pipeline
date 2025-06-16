`timescale 1ns / 1ps

module hazard_unit_tb;

  // Inputs
  reg EX_MEM_RegWrite;
  reg [4:0] EX_MEM_Rd;
  reg MEM_WB_RegWrite;
  reg [4:0] MEM_WB_Rd;
  reg [4:0] ID_EX_Rs1;
  reg [4:0] ID_EX_Rs2;
  reg ID_EX_MemRead;

  // Outputs
  wire [1:0] ForwardA;
  wire [1:0] ForwardB;
  wire Stall_IF_ID;

  // Instantiate the Unit Under Test (UUT)
  hazard_unit dut (
    .EX_MEM_RegWrite (EX_MEM_RegWrite),
    .EX_MEM_Rd       (EX_MEM_Rd),
    .MEM_WB_RegWrite (MEM_WB_RegWrite),
    .MEM_WB_Rd       (MEM_WB_Rd),
    .ID_EX_Rs1       (ID_EX_Rs1),
    .ID_EX_Rs2       (ID_EX_Rs2),
    .ID_EX_MemRead   (ID_EX_MemRead),
    .ForwardA        (ForwardA),
    .ForwardB        (ForwardB),
    .Stall_IF_ID     (Stall_IF_ID)
  );

  // Clock generation (optional, as hazard_unit is combinational, but good practice)
  reg clk;
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period, 100MHz clock
  end

  // Test sequence
  initial begin
    // Initialize all inputs to default (no hazard, no write)
    EX_MEM_RegWrite = 0;
    EX_MEM_Rd       = 5'b00000;
    MEM_WB_RegWrite = 0;
    MEM_WB_Rd       = 5'b00000;
    ID_EX_Rs1       = 5'b00000;
    ID_EX_Rs2       = 5'b00000;
    ID_EX_MemRead   = 0;

    $display("--------------------------------------------------------------------------------------------------");
    $display("Time | EX_MEM_RW | EX_MEM_Rd | MEM_WB_RW | MEM_WB_Rd | ID_EX_Rs1 | ID_EX_Rs2 | ID_EX_MemRead | ForwardA | ForwardB | Stall_IF_ID | Description");
    $display("--------------------------------------------------------------------------------------------------");

    #10; // Wait for initial stable state
    $monitor("%4tns | %9b | %9b | %9b | %9b | %9b | %9b | %13b | %8b | %8b | %13b | %s",
             $time, EX_MEM_RegWrite, EX_MEM_Rd, MEM_WB_RegWrite, MEM_WB_Rd,
             ID_EX_Rs1, ID_EX_Rs2, ID_EX_MemRead, ForwardA, ForwardB, Stall_IF_ID, "Initial state");

    // Test Case 1: No Hazard
    // Rs1=x1, Rs2=x2, but no results available from EX/MEM or MEM/WB
    ID_EX_Rs1 = 5'd1;
    ID_EX_Rs2 = 5'd2;
    #10;
    $display("No hazard. Rs1 and Rs2 should read from RF (ForwardA=00, ForwardB=00).");

    
    EX_MEM_RegWrite = 1;
    EX_MEM_Rd       = 5'd3;
    ID_EX_Rs1       = 5'd3;
    ID_EX_Rs2       = 5'd4; // Rs2 doesn't match
    #10;
    $display("EX/MEM to EX Forwarding (Rs1). Expect ForwardA=01.");

    
    EX_MEM_Rd       = 5'd5;
    ID_EX_Rs1       = 5'd1; // Rs1 doesn't match
    ID_EX_Rs2       = 5'd5;
    #10;
    $display("EX/MEM to EX Forwarding (Rs2). Expect ForwardB=01.");

    EX_MEM_RegWrite = 0; // Clear EX/MEM forwarding
    EX_MEM_Rd       = 5'b00000;
    MEM_WB_RegWrite = 1;
    MEM_WB_Rd       = 5'd6;
    ID_EX_Rs1       = 5'd6;
    ID_EX_Rs2       = 5'd7;
    #10;
    $display("MEM/WB to EX Forwarding (Rs1). Expect ForwardA=10.");

    
    MEM_WB_Rd       = 5'd8;
    ID_EX_Rs1       = 5'd1;
    ID_EX_Rs2       = 5'd8;
    #10;
    $display("MEM/WB to EX Forwarding (Rs2). Expect ForwardB=10.");

    
    EX_MEM_RegWrite = 1;
    EX_MEM_Rd       = 5'd9;
    MEM_WB_RegWrite = 1; // This should be overridden by EX/MEM if same Rd, or different Rd
    MEM_WB_Rd       = 5'd9;
    ID_EX_Rs1       = 5'd9;
    ID_EX_Rs2       = 5'd10;
    #10;
    $display("Priority: EX/MEM over MEM/WB (Rs1). Expect ForwardA=01.");

    // Test Case 7: Load-Use Hazard (Stall_IF_ID = 1'b1)
    // Assume LW in EX/MEM stage, and current ID/EX needs its result
    EX_MEM_RegWrite = 1;
    EX_MEM_Rd       = 5'd11;
    ID_EX_Rs1       = 5'd11; // ID/EX needs x11
    ID_EX_Rs2       = 5'd12;
    ID_EX_MemRead   = 1; // LW instruction in EX/MEM stage
    #10;
    $display("Load-Use Hazard. Expect Stall_IF_ID=1, ForwardA=00, ForwardB=00 (stall overrides forwarding).");

    // Test Case 8: Load-Use Hazard (Rs2 match)
    ID_EX_Rs1       = 5'd1;
    ID_EX_Rs2       = 5'd11; // ID/EX needs x11 for Rs2
    ID_EX_MemRead   = 1;
    #10;
    $display("Load-Use Hazard (Rs2 match). Expect Stall_IF_ID=1, ForwardA=00, ForwardB=00.");

    // Test Case 9: No Load-Use Hazard (MemRead is 0)
    // Even if Rd matches, not a load-use hazard if MemRead is 0
    ID_EX_MemRead   = 0;
    ID_EX_Rs1       = 5'd11;
    ID_EX_Rs2       = 5'd1;
    #10;
    $display("No Load-Use Hazard (MemRead=0). Expect ForwardA=01, Stall_IF_ID=0.");


    // Test Case 10: Register x0 (Zero Register)
    // Should never forward to or from x0
    EX_MEM_RegWrite = 1;
    EX_MEM_Rd       = 5'd0; // x0 written in EX/MEM
    ID_EX_Rs1       = 5'd0; // ID/EX reads x0
    ID_EX_Rs2       = 5'd0;
    ID_EX_MemRead   = 0;
    #10;
    $display("x0 check. Expect ForwardA=00, ForwardB=00, Stall_IF_ID=0.");

    EX_MEM_RegWrite = 1;
    EX_MEM_Rd       = 5'd1;
    ID_EX_Rs1       = 5'd0; // ID/EX reads x0
    ID_EX_Rs2       = 5'd1; // ID/EX reads x1
    #10;
    $display("x0 as Rs1, x1 as Rs2. Expect ForwardA=00, ForwardB=01, Stall_IF_ID=0.");


    // End simulation
    $finish;
  end

endmodule