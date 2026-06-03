module register_file_tb;

    reg        clk, we;
    reg  [4:0] rs1, rs2, rd;
    reg  [31:0] wd;
    wire [31:0] rd1, rd2;

    register_file uut (
        .clk(clk), .we(we),
        .rs1(rs1), .rs2(rs2),
        .rd(rd),   .wd(wd),
        .rd1(rd1), .rd2(rd2)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns period

    initial begin
        $display("=== Register File Testbench ===");

        // Write 42 to x1
        we = 1; rd = 5'd1; wd = 32'd42;
        @(posedge clk); #1;
        $display("Write x1 = 42");

        // Write 100 to x2
        rd = 5'd2; wd = 32'd100;
        @(posedge clk); #1;
        $display("Write x2 = 100");

        // Read x1 and x2
        we = 0; rs1 = 5'd1; rs2 = 5'd2;
        #1;
        $display("Read x1 = %0d (expected 42)", rd1);
        $display("Read x2 = %0d (expected 100)", rd2);

        // Test x0 hardwired to 0
        we = 1; rd = 5'd0; wd = 32'hDEADBEEF;
        @(posedge clk); #1;
        rs1 = 5'd0;
        #1;
        $display("Read x0 = %0d (expected 0)", rd1);

        // Write to x15, read back
        rd = 5'd15; wd = 32'hCAFEBABE;
        @(posedge clk); #1;
        we = 0; rs1 = 5'd15;
        #1;
        $display("Read x15 = %h (expected cafebabe)", rd1);

        $display("=== Done ===");
        $finish;
    end

endmodule