`default_nettype none

// Implements a Counter module, which can be loaded with a value, can count
// up or down, and can be cleared. Input/output is WIDTH bits wide
module Counter
    #(parameter WIDTH = 8)
    (input logic clock, clear, en, load, up,
     input logic [(WIDTH - 1):0] D,
     output logic [(WIDTH - 1):0] Q);

    // Describes what the counter does at each clock edge
    always_ff @(posedge clock) begin
        // If clear is asserted, set all bits to 0
        if (clear)
            Q <= '0;
        // If load is asserted, set Q to input D
        else if (load)
            Q <= D;
        // Else if en & up, count up
        else if (en & up)
            Q <= Q + 1;
        // Else if en & ~up, count down
        else if (en & ~up)
            Q <= Q - 1;
    end

endmodule: Counter

// Implements a Mag Comparator with two WIDTH-bit inputs, outputs equal, gt, lt
module MagComp
    #(parameter WIDTH = 8)
    (input logic [(WIDTH - 1):0] A, B,
     output logic AltB, AeqB, AgtB);

    assign AeqB = (A == B);
    assign AltB = (A < B);
    assign AgtB = (A > B);

endmodule: MagComp

// Synchronizes an asynchronous input signal by double-buffering it
// i.e. running it through two flip-flops
module Synchronizer
    (input logic async, clock,
     output logic sync);

    logic ff_buf;
    // Synchronize the signal by running it through two flip-flops (buffering)
    always_ff @(posedge clock) begin
        ff_buf <= async;
        sync <= ff_buf;
    end

endmodule: Synchronizer

// Sets up the FSM thats used for the manual mode output. This one
// outputs the inputted coin on the next clock cycle, for one clock cycle
module manualFSM (
    input logic reset, CLOCK_50,
    output logic circleM, triangleM, pentagonM,
    input logic manualMode, syncClock,
    input logic manualCircleL, manualTriangleL, manualPentagonL);

    logic man_en, man_clr;
    logic count7, count6, count4;
    logic [3:0] count_out;

// Datapath. Consists of one counter and 4 MagComps, that are used to track
// the number of manual clock cycles that have elapsed. The MagComps signal when
// 4 cycles, 6 cycles, and 7 cycles have elapsed.
    Counter #(4) c1 (.D(), .clock(syncClock), .en(man_en), .clear(man_clr),
                      .load(1'b0), .up(1'b1), .Q(count_out));

    MagComp #(4) m1 (.A(count_out), .B(4'd7), .AltB(), .AgtB(), .AeqB(count7));
    MagComp #(4) m2 (.A(count_out), .B(4'd6), .AltB(), .AgtB(), .AeqB(count6));
    MagComp #(4) m3 (.A(count_out), .B(4'd4), .AltB(), .AgtB(), .AeqB(count4));

    // State assignment - 10 states
    enum logic [3:0] {start = 4'b0000, out4 = 4'b0001, wait2 = 4'b0010,
                      wait3 = 4'b0011, out1 = 4'b0100, out2 = 4'b0101,
                      out3 = 4'b0110, wait1 = 4'b0111, out5 = 4'b1000,
                      out6 = 4'b1001} currState, nextState;

    // Flip-flops
    always_ff @(posedge CLOCK_50) begin
        if (reset) currState <= start;
        else currState <= nextState;
    end
   
    // Next-state logic
    always_comb begin
        case (currState)
            start: begin
                if (~manualCircleL) nextState = wait1;
                else if (~manualTriangleL) nextState = wait2;
                else if (~manualPentagonL) nextState = wait3;
else nextState = start;
            end
            wait2: nextState = (count6) ? out2 : wait2;
            wait3: nextState = (count7) ? out3 : wait3;
            wait1: nextState = (count4) ? out1 : wait1;
            out2: nextState = (syncClock) ? out2 : out5;
            out3: nextState = (syncClock) ? out3 : out6;
            out1: nextState = (syncClock) ? out1 : out4;
out4: nextState = (syncClock) ? start : out4;
            out5: nextState = (syncClock) ? start : out5;
            out6: nextState = (syncClock) ? start : out6;
            default: nextState = currState;
        endcase
    end

    // Output logic
    always_comb begin
        circleM = 1'b0;
        triangleM = 1'b0;
        pentagonM = 1'b0;
        man_en = 1'b0;
        man_clr = 1'b0;
        case (currState)
            start: begin
                man_clr = 1'b1;
                man_en = 1'b0;
            end
            wait1: begin
                man_en = 1'b1;
                man_clr = 1'b0;
            end
wait2: begin
   man_en = 1'b1;
man_clr = 1'b0;
end
wait3: begin
   man_en = 1'b1;
man_clr = 1'b0;
end
            out2: begin
   triangleM = 1'b1;
man_en = 1'b0;
man_clr = 1'b1;
end
            out3: begin
   pentagonM = 1'b1;
man_en = 1'b0;
man_clr = 1'b1;
end
            out1: begin
                circleM = 1'b1;
                man_en = 1'b0;
                man_clr = 1'b1;
            end
out4: begin
   circleM = 1'b1;
man_en = 1'b0;
man_clr = 1'b1;
end
            out5: begin
   triangleM = 1'b1;
man_en = 1'b0;
man_clr = 1'b1;
end
            out6: begin
   pentagonM = 1'b1;
man_en = 1'b0;
man_clr = 1'b1;
end
            default: begin
                circleM = 1'b0;
                triangleM = 1'b0;
                pentagonM = 1'b0;
            end
        endcase
    end

endmodule: manualFSM

// This module sets up the interface FSM, that reads data from the
// physical coin acceptor. It detects the 25ms pulses from the coin
// acceptor, and decodes them to determine the coin it accepted.
module coinAccepterFSM (
    input logic CLOCK_50, // pin Y2
    input logic reset,
    input logic UART_RXD,
    output logic circleCA, triangleCA, pentagonCA);

    logic count_clr, count_en, pulse;
    logic [23:0] count_out;

    // Datapath. Consists of a Counter and a MagComp, that count the number
// of clock cycles that have elapsed. The MagComp signals when 6,300,000
// clock cycles have elapsed, that is 126ms for a 50MHz clock.
    Counter #(24) c0 (.clock(CLOCK_50), .en(count_en), .clear(count_clr),
                    .load(1'b0), .up(1'b1), .D(), .Q(count_out));
   
    MagComp #(24) m0 (.A(count_out), .B(24'd6_300_000), .AltB(), .AgtB(),
                        .AeqB(pulse));

    // State assignment - 10 states
    enum logic [3:0] {start = 4'b0000, count1 = 4'b0001, reset1 = 4'b0010,
        count2 = 4'b0011, reset3 = 4'b0100, nickel = 4'b0101, reset2 = 4'b0110,
        reset4 = 4'b0111, dime = 4'b1000, quarter = 4'b1001} currState, nextState;
   
    always_ff @(posedge CLOCK_50) begin
        if (reset) currState <= start;
        else currState <= nextState;
    end

    // Next-state logic
    always_comb begin
        unique case (currState)
            start: nextState = (UART_RXD) ? count1 : start;
            count1: begin
                if (pulse & UART_RXD) nextState = reset1;
                else if (pulse & ~UART_RXD) nextState = reset3;
                // else if (~pulse)
                else nextState = count1;
            end
            reset3: nextState = nickel;
            reset1: nextState = count2;
            reset4: nextState = dime;
            reset2: nextState = quarter;
            count2: begin
                if (pulse & UART_RXD) nextState = reset2;
                else if (pulse & ~UART_RXD) nextState = reset4;
                // else if ~pulse
                else nextState = count2;
            end
            nickel: nextState = (pulse) ? start : nickel;
            dime: nextState = (pulse) ? start: dime;
            quarter: nextState = (pulse) ? start: quarter;
        endcase
    end

    // Output logic
    always_comb begin
        circleCA = 1'b0;
        triangleCA = 1'b0;
        pentagonCA = 1'b0;
        count_clr = 1'b0;
        count_en = 1'b0;
        unique case (currState)
            start: count_clr = 1'b1;
            count1: count_en = 1'b1;
            count2: count_en = 1'b1;
            reset1: count_clr = 1'b1;
            reset2: count_clr = 1'b1;
            reset3: count_clr = 1'b1;
            reset4: count_clr = 1'b1;
            nickel: begin
                circleCA = 1'b1;
                count_en = 1'b1;
                count_clr = 1'b0;
            end
            dime: begin
                triangleCA = 1'b1;
                count_en = 1'b1;
                count_clr = 1'b0;
            end
            quarter: begin
                pentagonCA = 1'b1;
                count_en = 1'b1;
                count_clr = 1'b0;
            end
        endcase
    end

endmodule: coinAccepterFSM

// Top module that connects the two FSMs together and selects between each one,
// depending on whether manualMode is asserted.
module coinAccepter (
    input logic CLOCK_50, // pin Y2
    input logic reset,
    input logic UART_RXD,
    output logic circle, triangle, pentagon,
    input logic manualMode, manualClockL,
    input logic manualCircleL, manualTriangleL, manualPentagonL,
    output logic clock);

    logic circleCA, triangleCA, pentagonCA;
    logic circleM, triangleM, pentagonM;
    logic syncClock;

    Synchronizer syn0 (.async(~manualClockL), .clock(CLOCK_50), .sync(syncClock));

    coinAccepterFSM ca (.*);
    manualFSM m0 (.*);

    // Changing the outputs in manual mode vs. regular mode
    always_comb begin
        if (~manualMode) begin
            circle = circleCA;
            triangle = triangleCA;
            pentagon = pentagonCA;
            clock = CLOCK_50;
        end
        else begin
            circle = circleM;
            triangle = triangleM;
            pentagon = pentagonM;
            clock = syncClock;
        end
    end

endmodule: coinAccepter

//2 new modules for bcd and for drop to ledg
module BCDtoSevenSegment_2bitinput
(input logic [1:0] bcd,
output logic [6:0] segment);
  always_comb
    unique case (bcd)
      2'b00: segment = ~(7'b011_1111);
      2'b01: segment = ~(7'b000_0110);
      2'b10: segment = ~(7'b101_1011);
      2'd3: segment = ~(7'b100_1111);
      

    endcase
endmodule: BCDtoSevenSegment_2bitinput


module drop_to_LEDG(input logic drop, output logic [7:0] LEDG);
always_comb
    unique case (drop)
      0: LEDG = 8'b0000_0000;
      1: LEDG = 8'b1111_1111;
      

    endcase

endmodule: drop_to_LEDG











// Example Chip Interface module for the coin acceptor
module chipInterface
  (output logic [7:0] LEDG,
   input logic CLOCK_50,
   input  logic [17:0] SW,
output logic [17:0] LEDR,
   input  logic [3:0] KEY,
   input logic UART_RXD,
	output logic [6:0] HEX0); //added hex0 here on this line

   logic reset, circle, triangle, pentagon;
   logic manualMode, manualClockL;
   logic manualCircleL, manualTriangleL, manualPentagonL;
   logic clock;
	
	
	
	//new stuff here
	logic [1:0] credit;
	logic drop;
	task5 dut(.*);
	BCDtoSevenSegment_2bitinput DUT2(.bcd(credit), .segment(HEX0));
   //drop_to_LEDG DUT3(.drop(drop_intermediate), .LEDG(LEDG[7:0]));
   assign LEDG = drop ? 8'b1111_1111 : 8'b0000_0000;


   assign reset = SW[0];
   assign manualMode = SW[17];
   assign manualClockL = KEY[0];
   assign manualCircleL = KEY[1];
   assign manualTriangleL = KEY[2];
   assign manualPentagonL = KEY[3];

   coinAccepter ca (.*); // instantiate the FSM
   assign LEDG[0] = circle;
   assign LEDG[1] = triangle;
   assign LEDG[2] = pentagon;

endmodule: chipInterface

