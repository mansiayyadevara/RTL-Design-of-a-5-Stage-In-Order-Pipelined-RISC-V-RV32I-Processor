module instruction_memory (
    input  [31:0] addr,
    output [31:0] instr
);

    reg [31:0] mem [0:255];  // 256 words = 1KB of instruction memory

 initial begin
    mem[0] = 32'h00500093;  // addi x1, x0, 5
    mem[1] = 32'h00A00113;  // addi x2, x0, 10
    mem[2] = 32'h002081B3;  // add  x3, x1, x2  → x3 = 15
    mem[3] = 32'h40208233;  // sub  x4, x1, x2  → x4 = -5
    mem[4] = 32'h00000013;  // nop
    mem[5] = 32'h00000013;  // nop
    mem[6] = 32'h00000013;  // nop
    mem[7] = 32'h00000013;  // nop
end
    // Word-aligned read - use addr[9:2] to index
    assign instr = mem[addr[9:2]];

endmodule