module riscv_single_cycle (
    input clk,
    input reset
);

    // ─── Wire Declarations ───────────────────────────────────────
    wire [31:0] pc_out, pc_plus4, pc_next, pc_branch;
    wire [31:0] instr;
    wire [31:0] rd1, rd2;
    wire [31:0] imm_ext;
    wire [31:0] alu_a, alu_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [31:0] mem_rd;
    wire [31:0] result;

    // ─── Control Signals ─────────────────────────────────────────
    wire        reg_write, mem_write, mem_read;
    wire        mem_to_reg, alu_src;
    wire        branch, jump;
    wire [2:0]  imm_sel;
    wire [3:0]  alu_ctrl;
    wire        pc_src;

    // ─── PC Logic ────────────────────────────────────────────────
    assign pc_plus4  = pc_out + 32'd4;
    assign pc_branch = pc_out + imm_ext;
    assign pc_src    = (branch & alu_zero) | jump;
    assign pc_next   = pc_src ? pc_branch : pc_plus4;

    pc pc_reg (
        .clk(clk), .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    // ─── Instruction Memory ──────────────────────────────────────
    instruction_memory imem (
        .addr(pc_out),
        .instr(instr)
    );

    // ─── Control Unit ────────────────────────────────────────────
    control_unit cu (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7(instr[31:25]),
        .reg_write(reg_write), .mem_write(mem_write),
        .mem_read(mem_read),   .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),     .branch(branch),
        .jump(jump),           .imm_sel(imm_sel),
        .alu_ctrl(alu_ctrl)
    );

    // ─── Register File ───────────────────────────────────────────
    register_file rf (
        .clk(clk),
        .we(reg_write),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .wd(result),
        .rd1(rd1), .rd2(rd2)
    );

    // ─── Immediate Generator ─────────────────────────────────────
    imm_gen ig (
        .instr(instr),
        .imm_sel(imm_sel),
        .imm_ext(imm_ext)
    );

    // ─── ALU ─────────────────────────────────────────────────────
    assign alu_a = rd1;
    assign alu_b = alu_src ? imm_ext : rd2;

    alu alu_inst (
        .a(alu_a), .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    // ─── Data Memory ─────────────────────────────────────────────
    data_memory dmem (
        .clk(clk),
        .we(mem_write),
        .addr(alu_result),
        .wd(rd2),
        .rd(mem_rd)
    );

    // ─── Writeback Mux ───────────────────────────────────────────
    assign result = mem_to_reg ? mem_rd : alu_result;

endmodule