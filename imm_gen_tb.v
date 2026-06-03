module imm_gen_tb;

    reg  [31:0] instr;
    reg  [2:0]  imm_sel;
    wire [31:0] imm_ext;

    imm_gen uut (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm_ext(imm_ext)
    );

    initial begin
        $display("=== Immediate Generator Testbench ===");

        // I-type: addi x2, x0, 5 → imm = 5
        instr = 32'h00500113; imm_sel = 3'b000; #10;
        $display("I-type: imm = %0d (expected 5)", $signed(imm_ext));

        // I-type negative: addi x2, x0, -1 → imm = -1
        instr = 32'hFFF00113; imm_sel = 3'b000; #10;
        $display("I-type negative: imm = %0d (expected -1)", $signed(imm_ext));

        // S-type: sw x2, 4(x0) → imm = 4
        instr = 32'h00202223; imm_sel = 3'b001; #10;
        $display("S-type: imm = %0d (expected 4)", $signed(imm_ext));

        // B-type: beq x0, x0, 8 → imm = 8
        instr = 32'h00000463; imm_sel = 3'b010; #10;
        $display("B-type: imm = %0d (expected 8)", $signed(imm_ext));

        // U-type: lui x1, 1 → imm = 0x00001000
        instr = 32'h000010B7; imm_sel = 3'b011; #10;
        $display("U-type: imm = %h (expected 00001000)", imm_ext);

        // J-type: jal x1, 8 → imm = 8
        instr = 32'h008000EF; imm_sel = 3'b100; #10;
        $display("J-type: imm = %0d (expected 8)", $signed(imm_ext));

        $display("=== Done ===");
        $finish;
    end

endmodule