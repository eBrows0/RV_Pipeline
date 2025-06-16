module data_memory (
    input wire        clk,
    input wire [31:0] addr,         
    input wire [31:0] write_data,   
    input wire [1:0]  mem_write,   
    input wire        mem_read,     // 1: Read enable, 0: No read
    output reg [31:0] read_data     // Data read from memory
);

   
    reg [31:0] data_mem [0:255]; // Data memory array

    integer i; 

    // Initialize memory to all zeros on start
    initial begin
        for (i = 0; i < 256; i = i + 1) begin 
            data_mem[i] = 32'b0;
        end
    end

    // Read logic
    always @(*) begin 
        if (mem_read) begin
           
            read_data = data_mem[addr[31:2]];
        end else begin
            read_data = 32'b0; // Default to zero if not reading
        end
    end

   
    always @(posedge clk) begin 
        if (mem_write != 2'b00) begin 
            
            case (mem_write)
                2'b01: // Byte write (SB)
                   
                    data_mem[addr[31:2]][(addr[1:0]*8) +: 8] <= write_data[7:0]; // Example for byte write
                2'b10: // Half-word write (SH)
                   
                    data_mem[addr[31:2]][(addr[1]*16) +: 16] <= write_data[15:0]; // Example for half-word write
                2'b11: // Word write (SW)
                    data_mem[addr[31:2]] <= write_data;
                default: ; // Do nothing for 2'b00
            endcase
        end
    end

endmodule