// regfile.v
// Chapter 4: 32-register file with 2 read ports, 1 write port

module regfile (
    input  wire        clk,
    input  wire        we3,           // Write enable
    input  wire [4:0]  ra1,           // Read address 1
    input  wire [4:0]  ra2,           // Read address 2
    input  wire [4:0]  wa3,           // Write address
    input  wire [31:0] wd3,           // Write data
    output wire [31:0] rd1,           // Read data 1
    output wire [31:0] rd2            // Read data 2
);

    reg [31:0] registers [0:31];

    // x0 is hardwired to 0
    assign rd1 = (ra1 == 5'b0) ? 32'b0 : registers[ra1];
    assign rd2 = (ra2 == 5'b0) ? 32'b0 : registers[ra2];

    // Forwarding: if reading same register being written, return new value
    assign rd1_f = (ra1 == wa3 && we3 && ra1 != 5'b0) ? wd3 : rd1;
    assign rd2_f = (ra2 == wa3 && we3 && ra2 != 5'b0) ? wd3 : rd2;

    // Write: x0 is never written
    always @(posedge clk) begin
        if (we3 && wa3 != 5'b0) begin
            registers[wa3] <= wd3;
        end
    end

    // Debug task
    task dump_regs;
        integer i;
        begin
            $display("Register File Contents:");
            $display(" reg  |   decimal    |     hex");
            $display("------+--------------+-------------");
            for (i = 0; i < 32; i = i + 1) begin
                $display(" x%02d  | %12d | 0x%08h", i, registers[i], registers[i]);
            end
        end
    endtask

endmodule

// Testbench
module regfile_tb;
    reg        clk, we3;
    reg  [4:0] ra1, ra2, wa3;
    reg  [31:0] wd3;
    wire [31:0] rd1, rd2;

    regfile uut (
        .clk(clk), .we3(we3),
        .ra1(ra1), .ra2(ra2), .wa3(wa3),
        .wd3(wd3), .rd1(rd1), .rd2(rd2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Register File Testbench");
        $display("=======================");

        // Write to x1
        we3 = 1; wa3 = 5'd1; wd3 = 32'h00000005; ra1 = 5'd0; ra2 = 5'd0;
        #10;
        $display("Wrote 5 to x1. Read x0=%0d, x0=%0d", rd1, rd2);

        // Write to x2
        wa3 = 5'd2; wd3 = 32'h0000000A;
        #10;
        $display("Wrote 10 to x2. Read x1=%0d, x2=%0d", rd1, rd2);

        // Try to write to x0 (should fail)
        wa3 = 5'd0; wd3 = 32'hFFFFFFFF;
        #10;
        $display("Attempted write to x0. Read x0=%0d (should be 0)", rd1);

        // Read x0 directly
        ra1 = 5'd0; ra2 = 5'd1;
        #10;
        $display("Read x0=%0d, x1=%0d", rd1, rd2);

        // Dump all registers
        uut.dump_regs();

        $display("\nTest complete!");
        $finish;
    end
endmodule
