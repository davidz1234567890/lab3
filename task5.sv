`default_nettype none

module task5 (
output logic [1:0] credit,
output logic drop,
input logic circle, triangle, pentagon,
input logic clock, reset);
enum logic [3:0] {nothing = 4'b0000,
                  credit1_nosoda = 4'b0001,
                  credit2_nosoda = 4'b0010,
                  credit3_nosoda = 4'b0011,
                  mult_of_4 = 4'b0100,
                  credit1_soda = 4'b0101,
                  credit2_soda = 4'b0110,
                  credit3_soda = 4'b0111,
                  nothing_wait = 4'b1000,
                  credit1_nosoda_wait = 4'b1001,
                  credit2_nosoda_wait = 4'b1010,
                  credit3_nosoda_wait = 4'b1011,
                  mult_of_4_wait = 4'b1100,
                  credit1_soda_wait = 4'b1101,
                  credit2_soda_wait = 4'b1110,
                  credit3_soda_wait = 4'b1111} currState, nextState;


//next state logic here
always_comb begin
  case(currState)
    nothing: begin
      if(circle) begin
        nextState = credit1_nosoda_wait;
      end
      else if(triangle) begin
        nextState = credit3_nosoda_wait;
      end
      else if(pentagon) begin
        nextState = credit1_soda_wait;
      end
      else begin
        nextState = nothing;
      end
    end

    credit1_nosoda: begin
      if(circle) begin
        nextState = credit2_nosoda_wait;
      end
      else if(triangle) begin
        nextState = mult_of_4_wait;
      end
      else if(pentagon) begin
        nextState = credit2_soda_wait;
      end
      else begin
        nextState = credit1_nosoda;
      end
    end

    credit2_nosoda: begin
      if(circle) begin
        nextState = credit3_nosoda_wait;
      end
      else if(triangle) begin
        nextState = credit1_soda_wait;
      end
      else if(pentagon) begin
        nextState = credit3_soda_wait;
      end
      else begin
        nextState = credit2_nosoda;
      end
    end

    credit3_nosoda: begin
      if(circle) begin
        nextState = mult_of_4_wait;
      end
      else if(triangle) begin
        nextState = credit2_soda_wait;
      end
      else if(pentagon) begin
        nextState = mult_of_4_wait;
      end
      else begin
        nextState = credit3_nosoda;
      end
    end

    mult_of_4: begin
      if(circle) begin
        nextState = credit1_nosoda_wait;
      end
      else if(triangle) begin
        nextState = credit3_nosoda_wait;
      end
      else if(pentagon) begin
        nextState = credit1_soda_wait;
      end
      else begin
        nextState = nothing;
      end
    end

    credit1_soda: begin
      if(circle) begin
        nextState = credit2_nosoda_wait;
      end
      else if(triangle) begin
        nextState = mult_of_4_wait;
      end
      else if(pentagon) begin
        nextState = credit2_soda_wait;
      end
      else begin
        nextState = credit1_nosoda;
      end
    end

    credit2_soda: begin
      if(circle) begin
        nextState = credit3_nosoda_wait;
      end
      else if(triangle) begin
        nextState = credit1_soda_wait;
      end
      else if(pentagon) begin
        nextState = credit3_soda_wait;
      end
      else begin
        nextState = credit2_nosoda;
      end
    end

    credit3_soda: begin
      if(circle) begin
        nextState = mult_of_4_wait;
      end
      else if(triangle) begin
        nextState = credit2_soda_wait;
      end
      else if(pentagon) begin
        nextState = mult_of_4_wait;
      end
      else begin
        nextState = credit3_nosoda;
      end
    end

    nothing_wait: begin
      if(circle | triangle | pentagon) begin
        nextState = nothing_wait;
      end
      else begin
        nextState = nothing;
      end
    end

    credit1_nosoda_wait: begin
      if(circle | triangle | pentagon) begin
        nextState = credit1_nosoda_wait;
      end
      else begin
        nextState = credit1_nosoda;
      end
    end

    credit2_nosoda_wait: begin
      if(circle | triangle | pentagon) begin
        nextState = credit2_nosoda_wait;
      end
      else begin
        nextState = credit2_nosoda;
      end
    end

    credit3_nosoda_wait: begin
      if(circle | triangle | pentagon) begin
        nextState = credit3_nosoda_wait;
      end
      else begin
        nextState = credit3_nosoda;
      end
    end

    mult_of_4_wait: begin
      if(circle | triangle | pentagon) begin
        nextState = mult_of_4_wait;
      end
      else begin
        nextState = mult_of_4;
      end
    end

    credit1_soda_wait: begin
      if(circle | triangle | pentagon) begin
        nextState = credit1_soda_wait;
      end
      else begin
        nextState = credit1_soda;
      end
    end

    credit2_soda_wait: begin
      if(circle | triangle | pentagon) begin
        nextState = credit2_soda_wait;
      end
      else begin
        nextState = credit2_soda;
      end
    end

    credit3_soda_wait: begin 
      if(circle | triangle | pentagon) begin
        nextState = credit3_soda_wait;
      end
      else begin
        nextState = credit3_soda;
      end
    end

    //just because we need a default
    default: begin 
      if(circle | triangle | pentagon) begin
        nextState = credit3_soda_wait;
      end
      else begin
        nextState = credit3_soda;
      end
    end
  endcase
end



//output logic here
always_comb begin
    credit = 2'b00; drop = 1'b0;
    case (currState)
      nothing: credit = 2'b00;
      credit1_nosoda: begin

        credit = 2'b01;
      end
      credit2_nosoda: begin

        credit = 2'b10;
      end
      credit3_nosoda: begin

        credit = 2'b11;
      end
      mult_of_4: begin
        drop = 1'b1;
        credit = 2'b00;
      end
      credit1_soda: begin
        drop = 1'b1;
        credit = 2'b01;
      end
      credit2_soda: begin
        drop = 1'b1;
        credit = 2'b10;
      end
      credit3_soda: begin
        drop = 1'b1;
        credit = 2'b11;
      end
      nothing_wait: begin
        credit = 2'b00;
        drop = 1'b0;
      end
      credit1_nosoda_wait: begin
        drop = 1'b0;
        credit = 2'b01;
      end
      credit2_nosoda_wait: begin
        drop = 1'b0;
        credit = 2'b10;
      end
      credit3_nosoda_wait: begin
        drop = 1'b0;
        credit = 2'b11;
      end
      mult_of_4_wait: begin
        drop = 1'b1;
        credit = 2'b00;
      end
      credit1_soda_wait: begin
        drop = 1'b1;
        credit = 2'b01;
      end
      credit2_soda_wait: begin
        drop = 1'b1;
        credit = 2'b10;
      end
      credit3_soda_wait: begin
        drop = 1'b1;
        credit = 2'b11;
      end
      
      //just because we need a default
      default: begin
        credit=2'b00;
        drop = 1'b0;
      end

    endcase
end

always_ff @(posedge clock)
  if (reset)
    currState <= nothing; // or whatever the reset state is
  else
    currState <= nextState;
endmodule: task5



module myFSM_test5;
  logic [1:0] credit;
  logic drop;
  logic circle, pentagon, triangle;
  logic clock, reset;
  task5 dut(.*);
  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

   initial begin
        $monitor($time,,
        {"state=%s, credit=%d, circle=%b, triangle = %b,",
        "pentagon = %b, drop=%b"},
        dut.currState.name, credit, circle, triangle, pentagon, drop); 
        //going to change this up a bit
        
        circle = 1'b0;
        triangle = 1'b0;
        pentagon = 1'b0;
        reset <= 1'b1;

        @(posedge clock);

        reset <= 1'b0; //release the reset
        circle <= 1'b1;
        #1 assert(dut.currState == dut.nothing);

        @(posedge clock);
        
        circle <= 1'b1;
        #1 assert(dut.currState == dut.credit1_nosoda_wait);

        @(posedge clock);

        circle <= 1'b1;
        #1 assert(dut.currState == dut.credit1_nosoda_wait);

        @(posedge clock);

        circle <= 1'b0;
        #1 assert(dut.currState == dut.credit1_nosoda_wait);

        @(posedge clock);

        pentagon <= 1'b1;
        #1 assert(dut.currState == dut.credit1_nosoda);

        @(posedge clock);

        #1 assert(dut.currState == dut.credit2_soda_wait);


        @(posedge clock);

        #1 assert(dut.currState == dut.credit2_soda_wait);

        @(posedge clock);

        pentagon <= 1'b0;
        #1 assert(dut.currState == dut.credit2_soda_wait);

        @(posedge clock);

        #1 assert(dut.currState == dut.credit2_soda);

        @(posedge clock);

        #1 assert(dut.currState == dut.credit2_nosoda);

        @(posedge clock);

        triangle <= 1'b1;
        #1 assert(dut.currState == dut.credit2_nosoda);

        @(posedge clock);

        triangle <= 1'b1;
        #1 assert(dut.currState == dut.credit1_soda_wait);

        @(posedge clock);

        triangle <= 1'b1;
        #1 assert(dut.currState == dut.credit1_soda_wait);

        @(posedge clock);

        triangle <= 1'b0;
        #1 assert(dut.currState == dut.credit1_soda_wait);

        @(posedge clock);

        #1 assert(dut.currState == dut.credit1_soda);

        @(posedge clock);

        #1 assert(dut.currState == dut.credit1_nosoda);

        @(posedge clock);

        $finish;


   end
endmodule: myFSM_test5
