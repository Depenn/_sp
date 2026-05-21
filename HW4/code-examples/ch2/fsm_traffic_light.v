// fsm_traffic_light.v
// Chapter 2: Traffic Light FSM - demonstrates Moore state machine design

module traffic_light (
    input  wire       clk,
    input  wire       reset,
    input  wire       car_sensor,  // 1 = car waiting at red light
    output reg  [1:0] light        // 00=RED, 01=YELLOW, 10=GREEN
);

    // State encoding
    localparam RED    = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN  = 2'b10;

    reg [1:0] state_reg, state_next;

    // Sequential block: state register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state_reg <= RED;
        else
            state_reg <= state_next;
    end

    // Combinational block: next state logic
    always @(*) begin
        case (state_reg)
            RED: begin
                // RED -> GREEN (always)
                state_next = GREEN;
            end
            GREEN: begin
                // GREEN -> YELLOW (if car waiting or timer expired)
                if (car_sensor)
                    state_next = YELLOW;
                else
                    state_next = GREEN;
            end
            YELLOW: begin
                // YELLOW -> RED (always)
                state_next = RED;
            end
            default: state_next = RED;
        endcase
    end

    // Combinational block: output logic (Moore - depends only on state)
    always @(*) begin
        light = state_reg;
    end

endmodule

// Testbench
module traffic_light_tb;
    reg clk, reset, car_sensor;
    wire [1:0] light;

    traffic_light uut (
        .clk(clk),
        .reset(reset),
        .car_sensor(car_sensor),
        .light(light)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task print_light;
        begin
            case (light)
                2'b00: $display("  %0d  |    RED    | car=%b", $time, car_sensor);
                2'b01: $display("  %0d  |  YELLOW   | car=%b", $time, car_sensor);
                2'b10: $display("  %0d  |   GREEN   | car=%b", $time, car_sensor);
                default: $display("  %0d  |  UNKNOWN  | car=%b", $time, car_sensor);
            endcase
        end
    endtask

    initial begin
        $display("Traffic Light FSM Testbench");
        $display("===========================");
        $display(" Time  |   Light   | sensor");
        $display("-------+-----------+-------");

        // Reset
        reset = 1; car_sensor = 0;
        #10;
        reset = 0;
        print_light();

        // Stay in GREEN for a few cycles (no car)
        car_sensor = 0;
        repeat (3) begin
            #10;
            print_light();
        end

        // Car arrives
        car_sensor = 1;
        #10;
        print_light();

        // Wait for GREEN -> YELLOW -> RED -> GREEN
        car_sensor = 0;
        repeat (4) begin
            #10;
            print_light();
        end

        $display("\nTest complete!");
        $finish;
    end
endmodule
