module register_file (
    input         clk,
    input         we,
    input  [4:0]  rs1, rs2, rd,
    input  [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] registers [31:0];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (we && rd != 5'b0)
            registers[rd] <= wd;
    end

    // Read with internal forwarding - if reading same reg being written, return new value
    assign rd1 = (rs1 == 5'b0)            ? 32'b0 :
                 (we && rd == rs1) ? wd   : registers[rs1];

    assign rd2 = (rs2 == 5'b0)            ? 32'b0 :
                 (we && rd == rs2) ? wd   : registers[rs2];

endmodule