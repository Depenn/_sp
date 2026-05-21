// decoder.v
// Chapter 4: Instruction Decoder - extracts fields from RISC-V instructions

module decoder (
    input  wire [31:0] instr,
    output wire [6:0]  opcode,
    output wire [4:0]  rd,
    output wire [2:0]  funct3,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [6:0]  funct7,
    output wire [31:0] imm_i,    // I-type immediate
    output wire [31:0] imm_s,    // S-type immediate
    output wire [31:0] imm_b,    // B-type immediate
    output wire [31:0] imm_u,    // U-type immediate
    output wire [31:0] imm_j     // J-type immediate
);

    // Field extraction
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // I-type: imm[11:0] from instr[31:20]
    assign imm_i = {{20{instr[31]}}, instr[31:20]};

    // S-type: imm[11:5] from instr[31:25], imm[4:0] from instr[11:7]
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};

    // B-type: imm[12|10:5] from instr[31:25], imm[4:1|11] from instr[11:8|7]
    assign imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

    // U-type: imm[31:12] from instr[31:12]
    assign imm_u = {instr[31:12], 12'b0};

    // J-type: imm[20|10:1|11|19:12] from instr[31|30:21|20|19:12]
    assign imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

endmodule

// Testbench
module decoder_tb;
    reg [31:0] instr;
    wire [6:0] opcode, funct7;
    wire [4:0] rd, rs1, rs2;
    wire [2:0] funct3;
    wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

    decoder uut (
        .instr(instr),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j)
    );

    task print_decode(input string name);
        begin
            $display("\n=== %s ===", name);
            $display("  instr    = 0x%08h (%b)", instr, instr);
            $display("  opcode   = 0x%02h (%b)", opcode, opcode);
            $display("  rd       = x%0d", rd);
            $display("  rs1      = x%0d", rs1);
            $display("  rs2      = x%0d", rs2);
            $display("  funct3   = %b", funct3);
            $display("  funct7   = %b", funct7);
        end
    endtask

    initial begin
        $display("Decoder Testbench");
        $display("=================");

        // ADDI x1, x0, 5
        instr = 32'h00500093;
        #5;
        print_decode("ADDI x1, x0, 5");
        $display("  imm_i    = %d (expected: 5)", imm_i);

        // ADD x3, x1, x2
        instr = 32'h002081B3;
        #5;
        print_decode("ADD x3, x1, x2");

        // SUB x4, x2, x1
        instr = 32'h40110233;
        #5;
        print_decode("SUB x4, x2, x1");

        // BEQ x0, x0, 8
        instr = 32'h00000063;
        #5;
        print_decode("BEQ x0, x0, PC+8");
        $display("  imm_b    = %d (expected: 8)", imm_b);

        // LUI x5, 0x12345
        instr = 32'h123452B7;
        #5;
        print_decode("LUI x5, 0x12345");
        $display("  imm_u    = 0x%08h (expected: 0x12345000)", imm_u);

        // JAL x1, 100
        instr = 32'h064000EF;
        #5;
        print_decode("JAL x1, PC+100");
        $display("  imm_j    = %d (expected: 100)", imm_j);

        $display("\nTest complete!");
        $finish;
    end
endmodule
