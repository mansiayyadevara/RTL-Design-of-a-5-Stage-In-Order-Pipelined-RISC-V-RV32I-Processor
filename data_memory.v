module data_memory (
    input         clk,
    input         we,           // write enable (1 for SW, 0 for LW)
    input  [31:0] addr,         // address from ALU result
    input  [31:0] wd,           // write data (from rs2)
    output [31:0] rd            // read data (to register file)
);

    reg [31:0] mem [0:255];     // 256 words = 1KB data memory

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;     // initialize all to 0
    end

    // Write - synchronous
    always @(posedge clk) begin
        if (we)
            mem[addr[9:2]] <= wd;
    end

    // Read - asynchronous
    assign rd = mem[addr[9:2]];

endmodule