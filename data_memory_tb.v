module data_memory_tb;

    reg         clk, we;
    reg  [31:0] addr, wd;
    wire [31:0] rd;

    data_memory uut (
        .clk(clk), .we(we),
        .addr(addr), .wd(wd),
        .rd(rd)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== Data Memory Testbench ===");

        // Write 0xDEADBEEF to address 0
        we = 1; addr = 32'h00; wd = 32'hDEADBEEF;
        @(posedge clk); #1;
        $display("Write addr=0x00 : data = %h", wd);

        // Write 0xCAFEBABE to address 4
        addr = 32'h04; wd = 32'hCAFEBABE;
        @(posedge clk); #1;
        $display("Write addr=0x04 : data = %h", wd);

        // Read back address 0
        we = 0; addr = 32'h00; #1;
        $display("Read  addr=0x00 : data = %h (expected deadbeef)", rd);

        // Read back address 4
        addr = 32'h04; #1;
        $display("Read  addr=0x04 : data = %h (expected cafebabe)", rd);

        // Read unwritten address - should be 0
        addr = 32'h08; #1;
        $display("Read  addr=0x08 : data = %h (expected 00000000)", rd);

        $display("=== Done ===");
        $finish;
    end

endmodule