`default_nettype none
module myFSM1
(input logic clock, reset_L, 
input logic [1:0] coin, 
 output logic [4:0] result_vector);
logic [2:0] state, nextState;
always_comb begin
  nextState[2] = state[1] & state[0] & coin[0] | 
                 state[0] & coin[1] |
                 state[1] & coin[1] |
                 coin[1] & coin[0];
  nextState[1] = (~state[1]) & (~state[0]) & coin[1] & (~coin[0]) |
                 (~state[1]) & state[0] & coin[0] |
                 state[1] & state[0] & (~coin[0]) |
                 state[1] & (~state[0]) & (~coin[1]) |
                 state[1] & (~state[0]) & coin[0];
  nextState[0] = state[0] & (~coin[1]) & (~coin[0]) |
                 (~state[0]) & coin[0] |
                 (~state[0]) & coin[1];
                 
end
//assign f = state[1] & state[0];
assign result_vector[4] = state[2];
assign result_vector[3] = 0;
assign result_vector[2] = 0;
assign result_vector[1] = state[1];
assign result_vector[0] = state[0];
always_ff @(posedge clock, negedge reset_L)
  if (~reset_L)
    state <= 3'b0;
  else
    state <= nextState;
endmodule: myFSM1




module tb1;
  logic clock, reset_L;
  logic [1:0] coin;
  logic [4:0] result_vector;
  myFSM1 dut(.*);
  initial begin
    clock = 0;
    reset_L = 0;
    reset_L <= 1;
    forever #5 clock = ~clock;
  end

  //monitor
  initial
    $monitor("State = %b, in(%b), out(%b)",
                 dut.state, coin, result_vector);
  initial begin
    coin = 2'b00;
    @(posedge clock);
    coin = 2'b10;
    @(posedge clock);
    @(posedge clock);
    coin = 2'b11;
    @(posedge clock);
    coin = 2'b01;
    @(posedge clock);
    coin = 2'b11;
    @(posedge clock);
    //a <= 1;
    @(posedge clock);
    coin = 2'b00;
    @(posedge clock);
    coin = 2'b10;
    @(posedge clock);
    coin = 2'b11;
    @(posedge clock);
    coin = 2'b11;
    @(posedge clock);
    coin = 2'b01;
    @(posedge clock);
    coin = 2'b01;
    $finish;



  end
endmodule: tb1
