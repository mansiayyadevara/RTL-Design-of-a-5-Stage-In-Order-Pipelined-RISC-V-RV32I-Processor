module riscv_pipeline (
    input clk,
    input reset
);

    // ─── IF Stage Wires ──────────────────────────────────────────
    wire [31:0] pc_out, pc_next, pc_plus4;
    wire [31:0] if_instr;

    // ─── IF/ID Register Outputs ──────────────────────────────────
    wire [31:0] id_pc, id_instr;

    // ─── ID Stage Wires ──────────────────────────────────────────
    wire [31:0] id_rd1, id_rd2, id_imm;
    wire        id_reg_write, id_mem_write, id_mem_read;
    wire        id_mem_to_reg, id_alu_src, id_branch, id_jump;
    wire [2:0]  id_imm_sel;
    wire [3:0]  id_alu_ctrl;

    // ─── ID/EX Register Outputs ──────────────────────────────────
    wire [31:0] ex_pc, ex_rd1, ex_rd2, ex_imm;
    wire [4:0]  ex_rs1, ex_rs2, ex_rd;
    wire        ex_reg_write, ex_mem_write, ex_mem_read;
    wire        ex_mem_to_reg, ex_alu_src, ex_branch, ex_jump;
    wire [3:0]  ex_alu_ctrl;

    // ─── EX Stage Wires ──────────────────────────────────────────
    wire [31:0] ex_alu_a, ex_alu_b_pre, ex_alu_b;
    wire [31:0] ex_alu_result, ex_pc_branch;
    wire        ex_zero;
    wire [1:0]  forward_a, forward_b;

    // ─── EX/MEM Register Outputs ─────────────────────────────────
    wire [31:0] mem_alu_result, mem_rd2, mem_pc_branch;
    wire [4:0]  mem_rd;
    wire        mem_zero;
    wire        mem_reg_write, mem_mem_write, mem_mem_read;
    wire        mem_mem_to_reg, mem_branch, mem_jump;

    // ─── MEM Stage Wires ─────────────────────────────────────────
    wire [31:0] mem_data_rd;
    wire        pc_src;

    // ─── MEM/WB Register Outputs ─────────────────────────────────
    wire [31:0] wb_alu_result, wb_mem_rd;
    wire [4:0]  wb_rd;
    wire        wb_reg_write, wb_mem_to_reg;

    // ─── WB Stage Wires ──────────────────────────────────────────
    wire [31:0] wb_result;

    // ─── Hazard Wires ────────────────────────────────────────────
    wire        stall, flush;

    // ════════════════════════════════════════════════════════════
    // IF STAGE
    // ════════════════════════════════════════════════════════════
    assign pc_plus4  = pc_out + 32'd4;
    assign pc_src    = (mem_branch & mem_zero) | mem_jump;
    assign pc_next   = stall ? pc_out :
                       pc_src ? mem_pc_branch : pc_plus4;

    pc pc_reg (
        .clk(clk), .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    instruction_memory imem (
        .addr(pc_out),
        .instr(if_instr)
    );

    if_id_reg if_id (
        .clk(clk), .reset(reset), .stall(stall),
        .pc_in(pc_out),       .instr_in(if_instr),
        .pc_out(id_pc),       .instr_out(id_instr)
    );

    // ════════════════════════════════════════════════════════════
    // ID STAGE
    // ════════════════════════════════════════════════════════════
    control_unit cu (
        .opcode(id_instr[6:0]),
        .funct3(id_instr[14:12]),
        .funct7(id_instr[31:25]),
        .reg_write(id_reg_write), .mem_write(id_mem_write),
        .mem_read(id_mem_read),   .mem_to_reg(id_mem_to_reg),
        .alu_src(id_alu_src),     .branch(id_branch),
        .jump(id_jump),           .imm_sel(id_imm_sel),
        .alu_ctrl(id_alu_ctrl)
    );

    register_file rf (
        .clk(clk),
        .we(wb_reg_write),
        .rs1(id_instr[19:15]), .rs2(id_instr[24:20]),
        .rd(wb_rd),            .wd(wb_result),
        .rd1(id_rd1),          .rd2(id_rd2)
    );

    imm_gen ig (
        .instr(id_instr),
        .imm_sel(id_imm_sel),
        .imm_ext(id_imm)
    );

    id_ex_reg id_ex (
        .clk(clk), .reset(reset), .flush(flush),
        .pc_in(id_pc),
        .rd1_in(id_rd1),          .rd2_in(id_rd2),
        .imm_in(id_imm),
        .rs1_in(id_instr[19:15]), .rs2_in(id_instr[24:20]),
        .rd_in(id_instr[11:7]),
        .reg_write_in(id_reg_write), .mem_write_in(id_mem_write),
        .mem_read_in(id_mem_read),   .mem_to_reg_in(id_mem_to_reg),
        .alu_src_in(id_alu_src),     .branch_in(id_branch),
        .jump_in(id_jump),           .alu_ctrl_in(id_alu_ctrl),
        .pc_out(ex_pc),
        .rd1_out(ex_rd1),         .rd2_out(ex_rd2),
        .imm_out(ex_imm),
        .rs1_out(ex_rs1),         .rs2_out(ex_rs2),
        .rd_out(ex_rd),
        .reg_write_out(ex_reg_write), .mem_write_out(ex_mem_write),
        .mem_read_out(ex_mem_read),   .mem_to_reg_out(ex_mem_to_reg),
        .alu_src_out(ex_alu_src),     .branch_out(ex_branch),
        .jump_out(ex_jump),           .alu_ctrl_out(ex_alu_ctrl)
    );

    // ════════════════════════════════════════════════════════════
    // EX STAGE
    // ════════════════════════════════════════════════════════════
    hazard_unit hu (
    .id_ex_rs1          (ex_rs1),
    .id_ex_rs2          (ex_rs2),
    .id_ex_alu_src      (ex_alu_src),      // NEW
    .ex_mem_rd          (mem_rd),
    .mem_wb_rd          (wb_rd),
    .ex_mem_reg_write   (mem_reg_write),
    .mem_wb_reg_write   (wb_reg_write),
    .if_id_rs1          (id_instr[19:15]),
    .if_id_rs2          (id_instr[24:20]),
    .id_ex_mem_read     (ex_mem_read),
    .id_ex_rd           (ex_rd),
    .forward_a          (forward_a),
    .forward_b          (forward_b),
    .stall              (stall),
    .flush              (flush)
);

    assign ex_alu_a     = (forward_a == 2'b10) ? mem_alu_result :
                      (forward_a == 2'b01) ? wb_result      : ex_rd1;

assign ex_alu_b_pre = (forward_b == 2'b10) ? mem_alu_result :
                      (forward_b == 2'b01) ? wb_result      : ex_rd2;

assign ex_alu_b     = ex_alu_src ? ex_imm : ex_alu_b_pre;
    alu alu_inst (
        .a(ex_alu_a), .b(ex_alu_b),
        .alu_ctrl(ex_alu_ctrl),
        .result(ex_alu_result),
        .zero(ex_zero)
    );

    ex_mem_reg ex_mem (
        .clk(clk), .reset(reset),
        .alu_result_in(ex_alu_result), .rd2_in(ex_alu_b_pre),
        .pc_branch_in(ex_pc_branch),   .rd_in(ex_rd),
        .zero_in(ex_zero),
        .reg_write_in(ex_reg_write),   .mem_write_in(ex_mem_write),
        .mem_read_in(ex_mem_read),     .mem_to_reg_in(ex_mem_to_reg),
        .branch_in(ex_branch),         .jump_in(ex_jump),
        .alu_result_out(mem_alu_result), .rd2_out(mem_rd2),
        .pc_branch_out(mem_pc_branch),   .rd_out(mem_rd),
        .zero_out(mem_zero),
        .reg_write_out(mem_reg_write),   .mem_write_out(mem_mem_write),
        .mem_read_out(mem_mem_read),     .mem_to_reg_out(mem_mem_to_reg),
        .branch_out(mem_branch),         .jump_out(mem_jump)
    );

    // ════════════════════════════════════════════════════════════
    // MEM STAGE
    // ════════════════════════════════════════════════════════════
    data_memory dmem (
        .clk(clk),
        .we(mem_mem_write),
        .addr(mem_alu_result),
        .wd(mem_rd2),
        .rd(mem_data_rd)
    );

    mem_wb_reg mem_wb (
        .clk(clk), .reset(reset),
        .alu_result_in(mem_alu_result), .mem_rd_in(mem_data_rd),
        .rd_in(mem_rd),
        .reg_write_in(mem_reg_write),   .mem_to_reg_in(mem_mem_to_reg),
        .alu_result_out(wb_alu_result), .mem_rd_out(wb_mem_rd),
        .rd_out(wb_rd),
        .reg_write_out(wb_reg_write),   .mem_to_reg_out(wb_mem_to_reg)
    );

    // ════════════════════════════════════════════════════════════
    // WB STAGE
    // ════════════════════════════════════════════════════════════
    assign wb_result = wb_mem_to_reg ? wb_mem_rd : wb_alu_result;

endmodule