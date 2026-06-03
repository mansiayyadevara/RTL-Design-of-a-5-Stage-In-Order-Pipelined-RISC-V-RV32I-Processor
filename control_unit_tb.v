module control_unit_tb;

    reg  [6:0] opcode;
    reg  [2:0] funct3;
    reg  [6:0] funct7;
    wire       reg_write, mem_write, mem_read;
    wire       mem_to_reg, alu_src, branch, jump;
    wire [2:0] imm_sel;
    wire [3:0] alu_ctrl;

    control_unit uut (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .reg_write(reg_write), .mem_write(mem_write),
        .mem_read(mem_read),   .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),     .branch(branch),
        .jump(jump),           .imm_sel(imm_sel),
        .alu_ctrl(alu_ctrl)
    );

    initial begin
        $display("=== Control Unit Testbench ===");

        // R-type ADD
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("R-ADD : reg_write=%b alu_src=%b alu_ctrl=%b (expected 1,0,0000)",
                  reg_write, alu_src, alu_ctrl);

        // R-type SUB
        funct7 = 7'b0100000; #10;
        $display("R-SUB : reg_write=%b alu_src=%b alu_ctrl=%b (expected 1,0,0001)",
                  reg_write, alu_src, alu_ctrl);

        // I-type ADDI
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10;
        $display("ADDI  : reg_write=%b alu_src=%b alu_ctrl=%b (expected 1,1,0000)",
                  reg_write, alu_src, alu_ctrl);

        // Load LW
        opcode = 7'b0000011; funct3 = 3'b010; #10;
        $display("LW    : reg_write=%b mem_read=%b mem_to_reg=%b (expected 1,1,1)",
                  reg_write, mem_read, mem_to_reg);

        // Store SW
        opcode = 7'b0100011; funct3 = 3'b010; #10;
        $display("SW    : mem_write=%b alu_src=%b (expected 1,1)",
                  mem_write, alu_src);

        // Branch BEQ
        opcode = 7'b1100011; funct3 = 3'b000; #10;
        $display("BEQ   : branch=%b alu_ctrl=%b (expected 1,0001)",
                  branch, alu_ctrl);

        // JAL
        opcode = 7'b1101111; funct3 = 3'b000; #10;
        $display("JAL   : reg_write=%b jump=%b (expected 1,1)",
                  reg_write, jump);

        $display("=== Done ===");
        $finish;
    end

endmodule