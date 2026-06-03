module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    output reg       reg_write,
    output reg       mem_write,
    output reg       mem_read,
    output reg       mem_to_reg,
    output reg       alu_src,
    output reg       branch,
    output reg       jump,
    output reg [2:0] imm_sel,
    output reg [3:0] alu_ctrl
);

    always @(*) begin
        // Default all signals to 0
        reg_write  = 0;
        mem_write  = 0;
        mem_read   = 0;
        mem_to_reg = 0;
        alu_src    = 0;
        branch     = 0;
        jump       = 0;
        imm_sel    = 3'b000;
        alu_ctrl   = 4'b0000;

        case (opcode)

            // R-type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
            7'b0110011: begin
                reg_write = 1;
                case ({funct7, funct3})
                    10'b0000000_000: alu_ctrl = 4'b0000; // ADD
                    10'b0100000_000: alu_ctrl = 4'b0001; // SUB
                    10'b0000000_111: alu_ctrl = 4'b0010; // AND
                    10'b0000000_110: alu_ctrl = 4'b0011; // OR
                    10'b0000000_100: alu_ctrl = 4'b0100; // XOR
                    10'b0000000_001: alu_ctrl = 4'b0101; // SLL
                    10'b0000000_101: alu_ctrl = 4'b0110; // SRL
                    10'b0100000_101: alu_ctrl = 4'b0111; // SRA
                    10'b0000000_010: alu_ctrl = 4'b1000; // SLT
                    10'b0000000_011: alu_ctrl = 4'b1001; // SLTU
                    default:         alu_ctrl = 4'b0000;
                endcase
            end

            // I-type ALU: ADDI, ANDI, ORI, XORI, SLTI, SLTIU
            7'b0010011: begin
                reg_write = 1;
                alu_src   = 1;
                imm_sel   = 3'b000;
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                    3'b110: alu_ctrl = 4'b0011; // ORI
                    3'b100: alu_ctrl = 4'b0100; // XORI
                    3'b010: alu_ctrl = 4'b1000; // SLTI
                    3'b011: alu_ctrl = 4'b1001; // SLTIU
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b101: alu_ctrl = (funct7[5]) ? 4'b0111 : 4'b0110; // SRAI/SRLI
                    default: alu_ctrl = 4'b0000;
                endcase
            end

            // Load: LW
            7'b0000011: begin
                reg_write  = 1;
                mem_read   = 1;
                mem_to_reg = 1;
                alu_src    = 1;
                imm_sel    = 3'b000;
                alu_ctrl   = 4'b0000; // ADD (base + offset)
            end

            // Store: SW
            7'b0100011: begin
                mem_write = 1;
                alu_src   = 1;
                imm_sel   = 3'b001;
                alu_ctrl  = 4'b0000; // ADD (base + offset)
            end

            // Branch: BEQ, BNE, BLT, BGE
            7'b1100011: begin
                branch  = 1;
                imm_sel = 3'b010;
                case (funct3)
                    3'b000: alu_ctrl = 4'b0001; // BEQ  → SUB, check zero
                    3'b001: alu_ctrl = 4'b0001; // BNE  → SUB, check not zero
                    3'b100: alu_ctrl = 4'b1000; // BLT  → SLT
                    3'b101: alu_ctrl = 4'b1000; // BGE  → SLT, check zero
                    default: alu_ctrl = 4'b0001;
                endcase
            end

            // JAL
            7'b1101111: begin
                reg_write = 1;
                jump      = 1;
                imm_sel   = 3'b100;
            end

            // LUI
            7'b0110111: begin
                reg_write  = 1;
                alu_src    = 1;
                mem_to_reg = 0;
                imm_sel    = 3'b011;
                alu_ctrl   = 4'b0000;
            end

            // AUIPC
            7'b0010111: begin
                reg_write = 1;
                alu_src   = 1;
                imm_sel   = 3'b011;
                alu_ctrl  = 4'b0000;
            end

        endcase
    end

endmodule