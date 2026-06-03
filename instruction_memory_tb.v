module instruction_memory_tb;

    reg  [31:0] addr;
    wire [31:0] instr;

    instruction_memory uut (
        .addr(addr),
        .instr(instr)
    );

    initial begin
        $display("=== Instruction Memory Testbench ===");

        addr = 32'h00; #10;
        $display("PC=0x00 : instr = %h (expected 00500113)", instr);

        addr = 32'h04; #10;
        $display("PC=0x04 : instr = %h (expected 00a00193)", instr);

        addr = 32'h08; #10;
        $display("PC=0x08 : instr = %h (expected 00310233)", instr);

        $display("=== Done ===");
        $finish;
    end

endmodule