module riscv_tb;

    reg clk, reset;

    riscv_single_cycle uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Access register file for checking
    // (direct hierarchical reference)
    wire [31:0] x1  = uut.rf.registers[1];
    wire [31:0] x2  = uut.rf.registers[2];
    wire [31:0] x3  = uut.rf.registers[3];
    wire [31:0] x4  = uut.rf.registers[4];
    wire [31:0] x5  = uut.rf.registers[5];

    initial begin
        $display("=== RISC-V Single Cycle Testbench ===");
        reset = 1; #10;
        reset = 0;

        // Run for 20 cycles
        repeat(20) @(posedge clk);
        #1;

        $display("x1  = %0d", x1);
        $display("x2  = %0d", x2);
        $display("x3  = %0d", x3);
        $display("x4  = %0d", x4);
        $display("x5  = %0d", x5);

        $display("=== Done ===");
        $finish;
    end

endmodule