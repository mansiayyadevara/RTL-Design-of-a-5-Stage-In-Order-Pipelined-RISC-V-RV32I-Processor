module alu_tb;

    reg  [31:0] a, b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    // Instantiate ALU
    alu uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );

    initial begin
        $display("=== ALU Testbench ===");

        // ADD
        a = 32'd10; b = 32'd5; alu_ctrl = 4'b0000;
        #10;
        $display("ADD: %0d + %0d = %0d (expected 15)", a, b, result);

        // SUB
        a = 32'd10; b = 32'd5; alu_ctrl = 4'b0001;
        #10;
        $display("SUB: %0d - %0d = %0d (expected 5)", a, b, result);

        // AND
        a = 32'hFF; b = 32'h0F; alu_ctrl = 4'b0010;
        #10;
        $display("AND: %h & %h = %h (expected 0f)", a, b, result);

        // OR
        a = 32'hF0; b = 32'h0F; alu_ctrl = 4'b0011;
        #10;
        $display("OR: %h | %h = %h (expected ff)", a, b, result);

        // XOR
        a = 32'hFF; b = 32'hFF; alu_ctrl = 4'b0100;
        #10;
        $display("XOR: %h ^ %h = %h (expected 0)", a, b, result);

        // SLL
        a = 32'd1; b = 32'd4; alu_ctrl = 4'b0101;
        #10;
        $display("SLL: %0d << %0d = %0d (expected 16)", a, b, result);

        // SRL
        a = 32'd16; b = 32'd2; alu_ctrl = 4'b0110;
        #10;
        $display("SRL: %0d >> %0d = %0d (expected 4)", a, b, result);

        // SRA (arithmetic - sign bit preserved)
        a = 32'hFFFFFFFF; b = 32'd1; alu_ctrl = 4'b0111;
        #10;
        $display("SRA: %h >>> 1 = %h (expected ffffffff)", a, result);

        // SLT
        a = 32'hFFFFFFFF; b = 32'd1; alu_ctrl = 4'b1000;
        #10;
        $display("SLT: -1 < 1 = %0d (expected 1)", result);

        // SLTU
        a = 32'hFFFFFFFF; b = 32'd1; alu_ctrl = 4'b1001;
        #10;
        $display("SLTU: 0xFFFFFFFF < 1 = %0d (expected 0)", result);

        // ZERO flag test
        a = 32'd5; b = 32'd5; alu_ctrl = 4'b0001;
        #10;
        $display("ZERO flag: 5-5=0, zero=%0d (expected 1)", zero);

        $display("=== Done ===");
        $finish;
    end

endmodule