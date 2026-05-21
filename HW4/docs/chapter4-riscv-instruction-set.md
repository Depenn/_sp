# Chapter 4: RISC-V Instruction Set Implementation

We've built an ALU. Now we'll wire it into a processor that can actually run programs. This chapter implements a subset of the RISC-V RV32I base integer instruction set.

## RISC-V Basics

RISC-V is an open-source instruction set architecture (ISA). We'll implement the RV32I variant:
- **32-bit** data path
- **I** = Integer base instruction set
- **32 registers** (x0-x31)
- **Load/Store** architecture (memory accessed only via load/store instructions)

### Register File

| Register | ABI Name | Purpose |
|----------|----------|---------|
| x0 | zero | Hardwired to 0 (always reads 0) |
| x1 | ra | Return address |
| x2 | sp | Stack pointer |
| x5-x7 | t0-t2 | Temporaries |
| x10-x11 | a0-a1 | Function arguments / return values |
| x12-x17 | a2-a7 | Function arguments |
| x18-x27 | s0-s11 | Saved registers |
| x28-x31 | t3-t6 | Temporaries |

---

## RISC-V Instruction Formats

All RISC-V instructions are 32 bits wide. Understanding the format is critical for implementation.

### R-Type (Register-Register Operations)

```
31        25 24     20 19     15 14  12 11      7 6            0
+-----------+---------+---------+------+---------+--------------+
| funct7    | rs2     | rs1     | funct3| rd      | opcode       |
+-----------+---------+---------+------+---------+--------------+
```

Example: `add x1, x2, x3` (x1 = x2 + x3)
- opcode = 0110011 (R-type)
- funct3 = 000 (add/sub)
- funct7 = 0000000 (add)
- rs1 = x2, rs2 = x3, rd = x1

### I-Type (Immediate Operations)

```
31                    20 19     15 14  12 11      7 6            0
+-----------------------+---------+------+---------+--------------+
| imm[11:0]             | rs1     | funct3| rd      | opcode       |
+-----------------------+---------+------+---------+--------------+
```

Example: `addi x1, x2, 100` (x1 = x2 + 100)
- opcode = 0010011 (I-type ALU)
- imm[11:0] = sign-extended immediate

### S-Type (Store Operations)

```
31        25 24     20 19     15 14  12 11      7 6            0
+-----------+---------+---------+------+---------+--------------+
| imm[11:5] | rs2     | rs1     | funct3| imm[4:0]| opcode       |
+-----------+---------+---------+------+---------+--------------+
```

### B-Type (Branch Operations)

```
31        25 24     20 19     15 14  12 11      7 6            0
+-----------+---------+---------+------+---------+--------------+
| imm[12|10:5]| rs2 | rs1     | funct3| imm[4:1|11]| opcode    |
+-----------+---------+---------+------+---------+--------------+
```

### U-Type (Upper Immediate)

```
31                                        11      7 6            0
+-----------------------------------------+---------+--------------+
| imm[31:12]                              | rd      | opcode       |
+-----------------------------------------+---------+--------------+
```

---

## Instructions We'll Implement

| Instruction | Format | Operation | funct3 | funct7 |
|-------------|--------|-----------|--------|--------|
| ADD | R | rd = rs1 + rs2 | 000 | 0000000 |
| SUB | R | rd = rs1 - rs2 | 000 | 0100000 |
| AND | R | rd = rs1 & rs2 | 111 | 0000000 |
| OR | R | rd = rs1 \| rs2 | 110 | 0000000 |
| XOR | R | rd = rs1 ^ rs2 | 100 | 0000000 |
| SLT | R | rd = (rs1 < rs2) signed | 010 | 0000000 |
| SLTU | R | rd = (rs1 < rs2) unsigned | 011 | 0000000 |
| SLL | R | rd = rs1 << rs2[4:0] | 001 | 0000000 |
| SRL | R | rd = rs1 >> rs2[4:0] | 101 | 0000000 |
| SRA | R | rd = rs1 >>> rs2[4:0] | 101 | 0100000 |
| ADDI | I | rd = rs1 + imm | 000 | - |
| ANDI | I | rd = rs1 & imm | 111 | - |
| ORI | I | rd = rs1 \| imm | 110 | - |
| XORI | I | rd = rs1 ^ imm | 100 | - |
| SLTI | I | rd = (rs1 < imm) signed | 010 | - |
| SLTIU | I | rd = (rs1 < imm) unsigned | 011 | - |
| SLLI | I | rd = rs1 << imm[4:0] | 001 | - |
| SRLI | I | rd = rs1 >> imm[4:0] | 101 | 0000000 |
| SRAI | I | rd = rs1 >>> imm[4:0] | 101 | 0100000 |
| LUI | U | rd = imm[31:12] << 12 | - | - |
| AUIPC | U | rd = PC + (imm << 12) | - | - |
| LB | I | rd = M[rs1+imm][7:0] | 000 | - |
| LH | I | rd = M[rs1+imm][15:0] | 001 | - |
| LW | I | rd = M[rs1+imm][31:0] | 010 | - |
| LBU | I | rd = M[rs1+imm][7:0] zero-ext | 100 | - |
| LHU | I | rd = M[rs1+imm][15:0] zero-ext | 101 | - |
| SB | S | M[rs1+imm] = rs2[7:0] | 000 | - |
| SH | S | M[rs1+imm] = rs2[15:0] | 001 | - |
| SW | S | M[rs1+imm] = rs2[31:0] | 010 | - |
| BEQ | B | if (rs1 == rs2) PC += imm | 000 | - |
| BNE | B | if (rs1 != rs2) PC += imm | 001 | - |
| BLT | B | if (rs1 < rs2) signed, PC += imm | 100 | - |
| BGE | B | if (rs1 >= rs2) signed, PC += imm | 101 | - |
| BLTU | B | if (rs1 < rs2) unsigned, PC += imm | 110 | - |
| BGEU | B | if (rs1 >= rs2) unsigned, PC += imm | 111 | - |
| JAL | J | rd = PC + 4; PC += imm | - | - |
| JALR | I | rd = PC + 4; PC = rs1 + imm | 000 | - |

---

## Building Block: Register File

```verilog
module regfile (
    input  wire        clk,
    input  wire        we3,          // Write enable
    input  wire [4:0]  ra1,          // Read address 1
    input  wire [4:0]  ra2,          // Read address 2
    input  wire [4:0]  wa3,          // Write address
    input  wire [31:0] wd3,          // Write data
    output wire [31:0] rd1,          // Read data 1
    output wire [31:0] rd2           // Read data 2
);

    reg [31:0] registers [0:31];

    // Read port 1: x0 always returns 0
    assign rd1 = (ra1 == 5'b0) ? 32'b0 : registers[ra1];

    // Read port 2: x0 always returns 0
    assign rd2 = (ra2 == 5'b0) ? 32'b0 : registers[ra2];

    // Write port: x0 is never written (hardwired to 0)
    always @(posedge clk) begin
        if (we3 && wa3 != 5'b0) begin
            registers[wa3] <= wd3;
        end
    end

    // Debug: dump register contents
    task dump_regs;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1) begin
                $display("x%02d = %08d (0x%08h)", i, registers[i], registers[i]);
            end
        end
    endtask

endmodule
```

---

## Building Block: Instruction Memory

For simulation purposes, we'll use a simple instruction memory initialized from a file.

```verilog
module instr_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] memory [0:255];  // 256 words = 1KB instruction memory

    initial begin
        $readmemh("program.hex", memory);  // Load from hex file
    end

    assign instr = memory[addr[9:2]];  // Word-aligned addressing

endmodule
```

---

## Building Block: Data Memory

```verilog
module data_mem (
    input  wire         clk,
    input  wire         we,            // Write enable
    input  wire [31:0]  addr,
    input  wire [31:0]  write_data,
    input  wire [3:0]   byte_en,       // Byte enables
    output wire [31:0]  read_data
);

    reg [31:0] memory [0:255];

    // Read (combinational)
    assign read_data = memory[addr[9:2]];

    // Write (sequential)
    always @(posedge clk) begin
        if (we) begin
            if (byte_en[0]) memory[addr[9:2]][7:0]   <= write_data[7:0];
            if (byte_en[1]) memory[addr[9:2]][15:8]  <= write_data[15:8];
            if (byte_en[2]) memory[addr[9:2]][23:16] <= write_data[23:16];
            if (byte_en[3]) memory[addr[9:2]][31:24] <= write_data[31:24];
        end
    end

    // Debug
    task dump_mem;
        input [31:0] start_addr;
        input [31:0] num_words;
        integer i;
        begin
            for (i = 0; i < num_words; i = i + 1) begin
                $display("mem[0x%08h] = 0x%08h", start_addr + i*4, memory[start_addr[9:2] + i]);
            end
        end
    endtask

endmodule
```

---

## Single-Cycle RISC-V Processor

This is where everything comes together. The single-cycle design is simplest to understand (though not the most efficient in practice).

```verilog
module riscv_core (
    input  wire        clk,
    input  wire        reset
);

    // Internal wires
    wire [31:0] pc, next_pc, instr;
    wire [31:0] rd1, rd2, alu_result, write_data;
    wire [31:0] sign_ext_imm, branch_target;
    wire        mem_read, mem_write, reg_write;
    wire [2:0]  alu_op;
    wire [1:0]  alu_src_sel, pc_sel;
    wire        branch_taken;
    wire [4:0]  write_reg;
    wire        zero_flag;

    // Program Counter
    pc_reg pc_reg_inst (
        .clk(clk), .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Instruction Memory
    instr_mem instr_mem_inst (
        .addr(pc),
        .instr(instr)
    );

    // Register File
    regfile regfile_inst (
        .clk(clk),
        .we3(reg_write),
        .ra1(instr[19:15]),   // rs1
        .ra2(instr[24:20]),   // rs2
        .wa3(write_reg),
        .wd3(write_data),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Immediate Generation
    wire [31:0] imm;

    always @(*) begin
        case (instr[6:0])
            7'b0110011: imm = 32'b0;                    // R-type: no immediate
            7'b0010011: imm = {{20{instr[31]}}, instr[31:20]};  // I-type ALU
            7'b0000011: imm = {{20{instr[31]}}, instr[31:20]};  // I-type load
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
            7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
            7'b0110111,
            7'b0010111: imm = {instr[31:12], 12'b0};    // U-type
            7'b1101111: imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
            7'b1100111: imm = {{20{instr[31]}}, instr[31:20]};  // I-type JALR
            default:     imm = 32'b0;
        endcase
    end

    assign sign_ext_imm = imm;

    // ALU (reuse our Chapter 3 ALU)
    alu alu_inst (
        .a(rd1),
        .b(alu_src_sel == 2'b01 ? rd2 :
           alu_src_sel == 2'b10 ? sign_ext_imm :
           32'b0),
        .op(alu_op),
        .result(alu_result),
        .zero(zero_flag),
        .overflow(),
        .carry_out()
    );

    // ALU Control
    always @(*) begin
        case (instr[6:0])
            7'b0110011: alu_op = 3'b010;  // R-type: use ALU from funct7
            7'b0010011: alu_op = 3'b010;  // I-type ALU: use ALU from funct3
            7'b0000011: alu_op = 3'b010;  // Load: add
            7'b0100011: alu_op = 3'b010;  // Store: add
            7'b1100011: alu_op = 3'b011;  // Branch: subtract
            7'b0110111: alu_op = 3'b000;  // LUI: not used
            7'b0010111: alu_op = 3'b010;  // AUIPC: add
            7'b1101111: alu_op = 3'b000;  // JAL: not used
            7'b1100111: alu_op = 3'b010;  // JALR: add
            default:     alu_op = 3'b000;
        endcase
    end

    // Branch Logic
    wire branch;
    wire [2:0] branch_funct;

    always @(*) begin
        if (instr[6:0] == 7'b1100011) begin
            branch = 1'b1;
            branch_funct = instr[14:12];
        end else begin
            branch = 1'b0;
            branch_funct = 3'b000;
        end
    end

    always @(*) begin
        case (branch_funct)
            3'b000: branch_taken = (rd1 == rd2);           // BEQ
            3'b001: branch_taken = (rd1 != rd2);           // BNE
            3'b100: branch_taken = ($signed(rd1) < $signed(rd2));  // BLT
            3'b101: branch_taken = ($signed(rd1) >= $signed(rd2)); // BGE
            3'b110: branch_taken = (rd1 < rd2);            // BLTU
            3'b111: branch_taken = (rd1 >= rd2);           // BGEU
            default: branch_taken = 1'b0;
        endcase
    end

    assign branch_target = pc + sign_ext_imm;

    // PC Update Logic
    wire jal, jalr;
    assign jal  = (instr[6:0] == 7'b1101111);
    assign jalr = (instr[6:0] == 7'b1100111);

    assign next_pc = jal ? (pc + sign_ext_imm) :
                     jalr ? (rd1 + sign_ext_imm) :
                     (branch && branch_taken) ? branch_target :
                     pc + 4;

    // Writeback Multiplexer
    assign write_data = mem_read ? write_data :
                        jal | jalr ? pc + 4 :
                        alu_result;

    // Write Register Selection
    assign write_reg = jal ? instr[11:7] :
                       instr[11:7];  // rd field

    // Control Signals
    wire [3:0] mem_ctrl;
    wire reg_write_sel;

    always @(*) begin
        case (instr[6:0])
            7'b0000011: begin mem_ctrl = 4'b1000; mem_read = 1'b1; mem_write = 1'b0; reg_write = 1'b1; end
            7'b0100011: begin mem_ctrl = 4'b0011; mem_read = 1'b0; mem_write = 1'b1; reg_write = 1'b0; end
            default:    begin mem_ctrl = 4'b0000; mem_read = 1'b0; mem_write = 1'b0; reg_write = (instr[6:0] != 7'b0100011); end
        endcase
    end

    // Data Memory
    data_mem data_mem_inst (
        .clk(clk),
        .we(mem_write),
        .addr(alu_result),
        .write_data(rd2),
        .byte_en(mem_ctrl),
        .read_data(write_data)
    );

endmodule
```

---

## PC Register

```verilog
module pc_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h00000000;
        else
            pc <= next_pc;
    end

endmodule
```

---

## Testbench: Running a Simple Program

```verilog
module riscv_core_tb;
    reg clk, reset;

    riscv_core uut (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period = 100 MHz
    end

    initial begin
        // Initialize
        reset = 1;
        #20;
        reset = 0;

        // Run for some cycles
        #1000;

        // Dump final state
        $display("Program finished");
        uut.regfile_inst.dump_regs();
        uut.data_mem_inst.dump_mem(32'h00000000, 16);

        $finish;
    end

    initial begin
        $dumpfile("riscv_core.vcd");
        $dumpvars(0, riscv_core_tb);
    end
endmodule
```

### Sample Program (program.hex)

This is a hex file that the processor executes:

```
00500093  // addi x1, x0, 5      ; x1 = 5
00300113  // addi x2, x0, 3      ; x2 = 3
00208133  // add  x3, x1, x2     ; x3 = 8
402101B3  // sub  x4, x2, x1     ; x4 = -2
00311163  // bne  x2, x3, offset ; branch if x2 != x3
0000006f  // jal  x0, PC         ; infinite loop
```

To generate `program.hex`, you can use the RISC-V assembler or write machine code manually.

---

## Control Unit (Decoupled Design)

For a cleaner architecture, separate the control logic into its own module:

```verilog
module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        alu_src,       // 0 = reg2, 1 = immediate
    output reg        mem_to_reg,    // 0 = alu_result, 1 = memory data
    output reg        reg_write,     // Enable register write
    output reg        mem_read,      // Enable memory read
    output reg        mem_write,     // Enable memory write
    output reg        branch,        // Is this a branch?
    output reg        jump,          // Is this a jump?
    output reg [2:0]  alu_op         // ALU operation select
);

    always @(*) begin
        alu_src     = 1'b0;
        mem_to_reg  = 1'b0;
        reg_write   = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        alu_op      = 3'b000;

        case (opcode)
            7'b0110011: begin  // R-type
                reg_write = 1'b1;
                alu_op = funct3;  // Pass funct3 to ALU
            end

            7'b0010011: begin  // I-type ALU
                reg_write = 1'b1;
                alu_src = 1'b1;
                alu_op = funct3;
            end

            7'b0000011: begin  // Load
                reg_write = 1'b1;
                mem_to_reg = 1'b1;
                mem_read = 1'b1;
                alu_src = 1'b1;
                alu_op = 3'b010;  // Add for address calculation
            end

            7'b0100011: begin  // Store
                mem_write = 1'b1;
                alu_src = 1'b1;
                alu_op = 3'b010;  // Add for address calculation
            end

            7'b1100011: begin  // Branch
                branch = 1'b1;
                alu_op = 3'b011;  // Subtract for comparison
            end

            7'b1101111: begin  // JAL
                reg_write = 1'b1;
                jump = 1'b1;
            end

            7'b1100111: begin  // JALR
                reg_write = 1'b1;
                jump = 1'b1;
                alu_src = 1'b1;
                alu_op = 3'b010;  // Add for target calculation
            end

            7'b0110111: begin  // LUI
                reg_write = 1'b1;
                // LUI: write immediate directly to register (no ALU needed)
            end

            7'b0010111: begin  // AUIPC
                reg_write = 1'b1;
                alu_op = 3'b010;  // Add PC + immediate
            end

            default: begin
                // NOP or unknown instruction
            end
        endcase
    end

endmodule
```

---

## Where Bugs Hide

### Bug #1: Incorrect Sign Extension

```verilog
// WRONG: zero-extension for I-type immediate
imm = {20'b0, instr[31:20]};  // Treats 0xFFF as 4095, not -1

// CORRECT: sign-extension
imm = {{20{instr[31]}}, instr[31:20]};  // Treats 0xFFF as -1
```

### Bug #2: Branch Target Calculation

```verilog
// WRONG: immediate already has PC included
pc_next = branch_target;  // branch_target = PC + imm

// CORRECT: branch_target is already PC-relative
pc_next = branch_target;  // This IS correct if imm includes PC offset
```

### Bug #3: Register File Read-After-Write Hazard

```verilog
// In a single-cycle design, the register file write happens at posedge clk,
// but the read is combinational. If we write and read the same register
// in the same cycle, we get the OLD value.
// Solution: forward the write data to the read port
assign rd1 = (ra1 == wa3 && we3 && ra1 != 5'b0) ? wd3 : registers[ra1];
assign rd2 = (ra2 == wa3 && we3 && ra2 != 5'b0) ? wd3 : registers[ra2];
```

### Bug #4: x0 Register Not Hardwired

```verilog
// WRONG: x0 can be written to
always @(posedge clk) begin
    if (we3) begin
        registers[wa3] <= wd3;  // x0 is not protected!
    end
end

// CORRECT: x0 is always 0
always @(posedge clk) begin
    if (we3 && wa3 != 5'b0) begin
        registers[wa3] <= wd3;
    end
end
```

### Bug #5: JALR Target Misalignment

```verilog
// JALR target must have LSB set to 0 (word-aligned)
wire [31:0] jalr_target = (rd1 + sign_ext_imm) & ~32'h1;
```

### Bug #6: LUI vs ADDI Confusion

```verilog
// LUI writes imm[31:12] << 12 to rd
// ADDI writes rs1 + sign_ext(imm[11:0]) to rd
// Both use different immediate formats but same opcode field in instruction[6:0]
// They differ in opcode: LUI=0110111, ADDI=0010011
```

---

## Chapter 4 Summary

- RISC-V instructions are 32 bits with structured field layouts
- The register file has 32 registers, with x0 hardwired to 0
- Immediate values must be sign-extended correctly
- A single-cycle processor executes one instruction per clock
- The control unit decodes the opcode and sets control signals
- The datapath wires together the PC, register file, ALU, and memories
- Forwarding solves read-after-write hazards in the register file

### Next Steps

This book covers the foundations. To go further:
- **Pipelining:** Split the single cycle into IF/ID/EX/MEM/WB stages
- **Hazard Detection:** Forwarding units, stall logic, branch prediction
- **Cache Memory:** Direct-mapped, set-associative, write policies
- **Interrupts/Exceptions:** M-mode, trap handling, CSRs

---

> *"A bug in software is a wrong answer. A bug in hardware is a short circuit."*
