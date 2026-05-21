// simple_riscv.v
// Chapter 4: Minimal RISC-V-like processor for simulation
// Implements a tiny subset: ADD, ADDI, SUB, BEQ, LUI, JAL
// This is a simplified educational processor, not a full RV32I implementation.

`timescale 1ns / 1ns

module simple_riscv (
    input  wire        clk,
    input  wire        reset
);

    // Registers
    reg [31:0] regs [0:31];
    reg [31:0] pc;
    reg [31:0] instr;

    // Instruction memory (hardcoded for demo)
    reg [31:0] instr_mem [0:31];

    // Data memory
    reg [31:0] data_mem [0:255];

    wire [31:0] rd1, rd2;

    // x0 always returns 0
    assign rd1 = (instr[19:15] == 5'b0) ? 32'b0 : regs[instr[19:15]];
    assign rd2 = (instr[24:20] == 5'b0) ? 32'b0 : regs[instr[24:20]];

    // Initialize instruction memory with a simple program
    initial begin
        // Program: compute 5 + 3, store result in memory, then loop
        instr_mem[0] = 32'h00500293;  // addi x5, x0, 5    (x5 = 5)
        instr_mem[1] = 32'h00300313;  // addi x6, x0, 3    (x6 = 3)
        instr_mem[2] = 32'h006283B3;  // add  x7, x5, x6   (x7 = 8)
        instr_mem[3] = 32'h0463A223;  // sw   x6, 4(x7)    (mem[12] = 3)
        instr_mem[4] = 32'h00700093;  // addi x1, x0, 7    (x1 = 7)
        instr_mem[5] = 32'h00000563;  // beq  x0, x0, offset (jump to instr_mem[5] - infinite loop)
        instr_mem[6] = 32'h00000013;  // nop
        instr_mem[7] = 32'h00000013;  // nop
    end

    // Main execution
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h00000000;
            regs[0] <= 32'b0;
        end else begin
            // Fetch
            instr = instr_mem[pc[9:2]];

            // Decode and Execute
            case (instr[6:0])
                // I-type ALU (ADDI, etc.)
                7'b0010011: begin
                    regs[instr[11:7]] <= rd1 + {{20{instr[31]}}, instr[31:20]};
                    pc <= pc + 4;
                end

                // R-type (ADD, SUB)
                7'b0110011: begin
                    if (instr[30])
                        regs[instr[11:7]] <= rd1 - rd2;  // SUB
                    else
                        regs[instr[11:7]] <= rd1 + rd2;  // ADD
                    pc <= pc + 4;
                end

                // S-type (STORE)
                7'b0100011: begin
                    wire [31:0] addr;
                    wire [31:0] imm_s;
                    imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                    addr = rd1 + imm_s;
                    data_mem[addr[9:2]] <= rd2;
                    pc <= pc + 4;
                end

                // B-type (BEQ)
                7'b1100011: begin
                    wire [31:0] imm_b;
                    imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
                    if (rd1 == rd2)
                        pc <= pc + imm_b;
                    else
                        pc <= pc + 4;
                end

                // JAL
                7'b1101111: begin
                    wire [31:0] imm_j;
                    imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
                    regs[instr[11:7]] <= pc + 4;
                    pc <= pc + imm_j;
                end

                // Unknown instruction
                default: begin
                    $display("Unknown instruction: 0x%08h at PC=0x%08h", instr, pc);
                    pc <= pc + 4;
                end
            endcase
        end
    end

    // Debug: dump state after some cycles
    task dump_state;
        integer i;
        begin
            $display("\n=== Processor State ===");
            $display("PC = 0x%08h", pc);
            $display("\nRegisters:");
            for (i = 0; i < 8; i = i + 1) begin
                $display("  x%d = %08d (0x%08h)", i, regs[i], regs[i]);
            end
            $display("\nData Memory:");
            for (i = 0; i < 4; i = i + 1) begin
                if (data_mem[i] != 0)
                    $display("  mem[0x%08h] = 0x%08h", i*4, data_mem[i]);
            end
        end
    endtask

endmodule

// Testbench
module simple_riscv_tb;
    reg clk, reset;

    simple_riscv uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Simple RISC-V Processor Testbench");
        $display("=================================");

        // Reset
        reset = 1;
        #20;
        reset = 0;

        // Execute instructions
        #100;
        $display("\nAfter 5 cycles:");
        uut.dump_state();

        #100;
        $display("\nAfter 10 cycles:");
        uut.dump_state();

        #200;
        $display("\nFinal state:");
        uut.dump_state();

        $display("\nExpected: x5=5, x6=3, x7=8, x1=7, mem[0xC]=3");
        $display("\nTest complete!");
        $finish;
    end
endmodule
