`timescale 1ns/1ps

module data_memory_tb;

    // Inputs
    reg clk;
    reg [31:0] addr;
    reg [31:0] write_data;
    reg [1:0] mem_write;
    reg mem_read;

    // Output
    wire [31:0] read_data;

    // Instantiate the module
    data_memory uut (
        .clk(clk),
        .addr(addr),
        .write_data(write_data),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(read_data)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        $display("=== DATA MEMORY TEST ===");
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);

        // Initial values
        addr = 0;
        write_data = 0;
        mem_write = 2'b00;
        mem_read = 0;

        // 1. Write full word at address 0x00
        #10;
        addr = 32'h00000000;
        write_data = 32'hDEADBEEF;
        mem_write = 2'b11;
        mem_read = 0;
        #10;

        // 2. Read word at address 0x00
        mem_write = 2'b00;
        mem_read = 1;
        #10;
        $display("Read from 0x00: 0x%h (Expected: 0xDEADBEEF)", read_data);

        // 3. Write byte at address 0x04
        addr = 32'h00000004;
        write_data = 32'h000000AA;
        mem_write = 2'b01;
        mem_read = 0;
        #10;

        // 4. Read word at address 0x04
        mem_write = 2'b00;
        mem_read = 1;
        #10;
        $display("Read from 0x04: 0x%h (Expected: 0x000000AA)", read_data);

        // 5. Write half-word at address 0x08
        addr = 32'h00000008;
        write_data = 32'h0000BEEF;
        mem_write = 2'b10;
        mem_read = 0;
        #10;

        // 6. Read word at address 0x08
        mem_write = 2'b00;
        mem_read = 1;
        #10;
        $display("Read from 0x08: 0x%h (Expected: 0x0000BEEF)", read_data);

        // 7. Write word at address 0x0C, then read back
        addr = 32'h0000000C;
        write_data = 32'hCAFEBABE;
        mem_write = 2'b11;
        mem_read = 0;
        #10;

        mem_write = 2'b00;
        mem_read = 1;
        #10;
        $display("Read from 0x0C: 0x%h (Expected: 0xCAFEBABE)", read_data);

        // 8. Read from address never written (0x10)
        addr = 32'h00000010;
        mem_read = 1;
        #10;
        $display("Read from 0x10: 0x%h (Expected: 0x00000000)", read_data);

        $finish;
    end

endmodule
