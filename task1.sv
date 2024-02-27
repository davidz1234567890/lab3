module dFlipFlop(
output logic q,
input logic d, clock, reset);
  always_ff @(posedge clock)
    if (reset == 1'b1)
      q <= 0;
    else
      q <= d;
endmodule: dFlipFlop



module myExplicitFSM(
output logic [3:0] credit,
output logic drop,
output logic q0, q1, q2, // connect to FF outputs(add more if needed)
input logic [1:0] coin,
input logic clock, reset);
logic d0, d1, d2; // connect to FF inputs (add more if needed)
// Example instantiation of D-flip-flop.
// Add more as necessary.
dFlipFlop ff0(.d(d0), .q(q0), .*),
ff1(.d(d1), .q(q1), .*),
ff2(.d(d2), .q(q2), .*);
// Next state logic goes here: combinational logic that drives
// next state (d0, etc) based upon input coin and the
// current state (q0, q1, etc).
assign d0 = q0 & (~coin[1]) & (~coin[0]) |
                 (~q0) & coin[0] |
                 (~q0) & coin[1];
assign d1 = (~q1) & (~q0) & coin[1] & (~coin[0]) |
                 (~q1) & q0 & coin[0] |
                 q1 & q0 & (~coin[0]) |
                 q1 & (~q0) & (~coin[1]) |
                 q1 & (~q0) & coin[0];
assign d2 = q1 & q0 & coin[0] | 
                 q0 & coin[1] |
                 q1 & coin[1] |
                 coin[1] & coin[0];


assign drop = q2;
assign credit[3] = 0;
assign credit[2] = 0;
assign credit[1] = q1;
assign credit[0] = q0;

endmodule: myExplicitFSM






module myFSM_test(
input logic [3:0] credit,
input logic drop,
input logic q2, q1, q0,
output logic [1:0] coin,
output logic clock, reset);
  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

  initial begin
    $monitor($time,, "state=%b, credit=%d, coin=%b, drop=%b",
        {q2, q1, q0}, credit, coin, drop);

            coin <= 2'b00; reset <= 1'b1;
        @(posedge clock);
            reset <= 1'b0; // release the reset

            coin <= 2'b01;
        @(posedge clock); // coin: 1, credit: 1
            coin <= 2'b10;
        @(posedge clock); // coin: 3, credit: 0
            #1 if (~drop) $display("Oops, incorrect drop");
            coin <= 2'b10;
        @(posedge clock); // coin: 3, credit: 3
            coin <= 2'b11;
        @(posedge clock); // coin: 5, credit: 0
            #1 if (~drop) $display("Oops, incorrect drop");
            coin <= 2'b11;
        @(posedge clock); // coin: 5, credit: 1
            #1 if (~drop) $display("Oops, incorrect drop");
            #1 if (credit != 1) $display("Oops, incorrect credit");
            coin <= 2'b10;
        @(posedge clock);
            #1 if (~drop) $display("Oops, incorrect drop");
            #1 if (credit != 0) $display("Oops, incorrect credit");

        $display("testing pentagons");
        for (int i = 0; i < 8; i++) begin
            if (i > 3) begin
                coin <= 2'b00;
                @(posedge clock);
            end
            coin <= 2'b11;
            @(posedge clock);
        end

        reset <= 1;
        @(posedge clock);
        reset <= 0;

        $display("testing triangles");
        for (int i = 0; i < 8; i++) begin
            
            coin <= 2'b10;
            @(posedge clock);
        end
        
        #1 $finish;
  end
endmodule: myFSM_test
  

module top();
  logic [3:0] credit;
  logic drop;
  logic q2, q1, q0;
  logic [1:0] coin;
  logic clock, reset;
  myExplicitFSM dut(.*);
  myFSM_test dut1(.*);


endmodule: top




  
