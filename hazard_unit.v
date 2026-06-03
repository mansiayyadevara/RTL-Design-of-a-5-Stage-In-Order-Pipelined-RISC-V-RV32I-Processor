module hazard_unit (
    input      [4:0] id_ex_rs1, id_ex_rs2,
    input            id_ex_alu_src,        // NEW - 1 for I-type, rs2 not real
    input      [4:0] ex_mem_rd, mem_wb_rd,
    input            ex_mem_reg_write,
    input            mem_wb_reg_write,
    input      [4:0] if_id_rs1, if_id_rs2,
    input            id_ex_mem_read,
    input      [4:0] id_ex_rd,

    output reg [1:0] forward_a, forward_b,
    output reg       stall,
    output reg       flush
);
    always @(*) begin
        // Forward A - always valid
        if (ex_mem_reg_write && (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs1))
            forward_a = 2'b10;
        else if (mem_wb_reg_write && (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs1))
            forward_a = 2'b01;
        else
            forward_a = 2'b00;

        // Forward B - only valid for R-type (alu_src=0)
        if (!id_ex_alu_src && ex_mem_reg_write &&
            (ex_mem_rd != 5'b0) && (ex_mem_rd == id_ex_rs2))
            forward_b = 2'b10;
        else if (!id_ex_alu_src && mem_wb_reg_write &&
                 (mem_wb_rd != 5'b0) && (mem_wb_rd == id_ex_rs2))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;

        // Load-use stall
        if (id_ex_mem_read &&
           ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)))
            stall = 1;
        else
            stall = 0;

        flush = 0;
    end
endmodule