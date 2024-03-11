
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

module chipInterface
(output logic [6:0] HEX0, 
input logic [17:0] SW,
output logic [7:0] LEDG,
input logic [3:0] KEY);
//assign LEDG[1] = 1;
logic [1:0] intermediate_credit;
logic drop_intermediate;
logic q0, q1, q2;
/*myExplicitFSM DUT(
    .credit(intermediate_credit),
    .drop(drop_intermediate), //not sure about this
    .q0(q0), .q1(q1), .q2(q2),  //not sure about this
    .coin(SW[1:0]),
    .clock(KEY[0]), .reset(SW[5]));*/
myAbstractFSM DUT(
    .credit(intermediate_credit),
    .drop(drop_intermediate), //not sure about this
     //not sure about this
    .coin(SW[1:0]),
    .clock(KEY[0]), .reset(SW[5]));

BCDtoSevenSegment_2bitinput DUT2(.bcd(intermediate_credit), .segment(HEX0));
//drop_to_LEDG DUT3(.drop(drop_intermediate), .LEDG(LEDG[7:0]));
assign LEDG = drop_intermediate ? 8'b1111_1111 : 8'b0000_0000;
endmodule: chipInterface
