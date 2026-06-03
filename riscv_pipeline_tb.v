module riscv_pipeline_tb;

    reg clk, reset;

    riscv_pipeline uut (
        .clk(clk), .reset(reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer i;
    initial begin
        reset = 1; #10; reset = 0;

        for (i = 0; i < 8; i = i + 1) begin
    @(posedge clk); #1;
    $display("cycle=%0d | ex_rd=%0d mem_rd=%0d wb_rd=%0d | ex_rs1=%0d ex_rs2=%0d | fwd_a=%b fwd_b=%b | alu_a=%0d alu_b=%0d alu_res=%0d",
        i,
        uut.ex_rd, uut.mem_rd, uut.wb_rd,
        uut.ex_rs1, uut.ex_rs2,
        uut.forward_a, uut.forward_b,
        $signed(uut.ex_alu_a),
        $signed(uut.ex_alu_b),
        $signed(uut.ex_alu_result));
end

        $display("x1=%0d x2=%0d x3=%0d x4=%0d",
            $signed(uut.rf.registers[1]),
            $signed(uut.rf.registers[2]),
            $signed(uut.rf.registers[3]),
            $signed(uut.rf.registers[4]));
        $finish;
    end

endmodule