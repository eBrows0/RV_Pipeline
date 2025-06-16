module if_id_register (
    input wire clk,
    input wire reset,
    input wire stall_id, 

    input wire [31:0] if_instr_in,
    input wire [31:0] if_pc_plus_4_in,
    input wire [31:0] if_current_pc_in,

    output reg [31:0] id_instr_out,
    output reg [31:0] id_pc_plus_4_out,
    output reg [31:0] id_pc_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        id_instr_out <= 32'b0;
        id_pc_plus_4_out <= 32'b0;
        id_pc_out <= 32'b0;
    end else if (~stall_id) begin // <--- ADDED: Only update if not stalled
        id_instr_out <= if_instr_in;
        id_pc_plus_4_out <= if_pc_plus_4_in;
        id_pc_out <= if_current_pc_in;
    end
end

endmodule