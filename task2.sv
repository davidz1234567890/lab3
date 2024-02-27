module myAbstractFSM (
output logic [3:0] credit,
output logic drop,
input logic [1:0] coin,
input logic clock, reset);
  enum logic [2:0] {nothing = 3'b000, 
                  credit1_nosoda = 3'b001,
                  credit2_nosoda = 3'b010,
                  credit3_nosoda = 3'b011,
                  mult_of_4 = 3'b100,
                  credit1_soda = 3'b101,
                  credit2_soda = 3'b110,
                  credit3_soda = 3'b111} currState, nextState;

  always_comb begin
    case (currState)
      nothing: begin
        if (coin == 2'b00) begin
          nextState = nothing;
        end
        if (coin == 2'b01) begin
          nextState = credit1_nosoda;
        end
        if (coin == 2'b10) begin
          nextState = credit3_nosoda;
        end
        if (coin == 2'b11) begin
          nextState = credit1_soda;
        end

      
      end

      credit1_nosoda: begin
        if (coin == 2'b00) begin
          nextState = credit1_nosoda;
        end
        if (coin == 2'b01) begin
          nextState = credit2_nosoda;
        end
        if (coin == 2'b10) begin
          nextState = mult_of_4;
        end
        if (coin == 2'b11) begin
          nextState = credit2_soda;
        end

      
      end

      credit2_nosoda: begin
        if (coin == 2'b00) begin
          nextState = credit2_nosoda;
        end
        if (coin == 2'b01) begin
          nextState = credit3_nosoda;
        end
        if (coin == 2'b10) begin
          nextState = credit1_soda;
        end
        if (coin == 2'b11) begin
          nextState = credit3_soda;
        end

      
      end

      credit3_nosoda: begin
        if (coin == 2'b00) begin
          nextState = credit3_nosoda;
        end
        if (coin == 2'b01) begin
          nextState = mult_of_4;
        end
        if (coin == 2'b10) begin
          nextState = credit2_soda;
        end
        if (coin == 2'b11) begin
          nextState = mult_of_4;
        end

      
      end

      mult_of_4: begin
        if (coin == 2'b00) begin
          nextState = nothing;
        end
        if (coin == 2'b01) begin
          nextState = credit1_nosoda;
        end
        if (coin == 2'b10) begin
          nextState = credit3_nosoda;
        end
        if (coin == 2'b11) begin
          nextState = credit1_soda;
        end

      
      end

      credit1_soda: begin
        if (coin == 2'b00) begin
          nextState = credit1_nosoda;
        end
        if (coin == 2'b01) begin
          nextState = credit2_nosoda;
        end
        if (coin == 2'b10) begin
          nextState = mult_of_4;
        end
        if (coin == 2'b11) begin
          nextState = credit2_soda;
        end

      
      end

      credit2_soda: begin
        if (coin == 2'b00) begin
          nextState = credit2_nosoda;
        end
        if (coin == 2'b01) begin
          nextState = credit3_nosoda;
        end
        if (coin == 2'b10) begin
          nextState = credit1_soda;
        end
        if (coin == 2'b11) begin
          nextState = credit3_soda;
        end

      
      end

      default: begin
        if (coin == 2'b00) begin
          nextState = credit3_nosoda;
        end
        if (coin == 2'b01) begin
          nextState = mult_of_4;
        end
        if (coin == 2'b10) begin
          nextState = credit2_soda;
        end
        if (coin == 2'b11) begin
          nextState = mult_of_4;
        end

      end
    endcase
  end


  always_comb begin
    credit = 4'b0000; drop = 1'b0;
    case (currState)
      nothing: credit = 4'b0000;
      credit1_nosoda: begin
        
        credit = 4'b0001;
      end
      credit2_nosoda: begin
        
        credit = 4'b0010;
      end
      credit3_nosoda: begin
        
        credit = 4'b0011;
      end
      mult_of_4: begin
        drop = 1'b1;
        credit = 4'b0000;
      end
      credit1_soda: begin
        drop = 1'b1;
        credit = 4'b0001;
      end
      credit2_soda: begin
        drop = 1'b1;
        credit = 4'b0010;
      end
      credit3_soda: begin
        drop = 1'b1;
        credit = 4'b0011;
      end
      default: begin
        credit=4'b0000; 
        drop = 1'b0;
      end

    endcase
  end

  always_ff @(posedge clock)
    if (reset)
      currState <= nothing; // or whatever the reset state is
    else
      currState <= nextState;
endmodule: myAbstractFSM







module myFSM_test;
  logic [3:0] credit;
  logic drop;
  logic [1:0] coin;
  logic clock, reset;
  myAbstractFSM dut(.*);
  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

   initial begin
        $monitor($time,, "state=%s, credit=%d, coin=%b, drop=%b",
        dut.currState.name, credit, coin, drop);

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
            if (i == 0) begin
              $display("only printing the change in coin between these 2 lines");
            end
            @(posedge clock);
            if (i == 0) begin
              $display("only printing the change in coin between these 2 lines");
            end
        end

        reset <= 1;
        @(posedge clock);
        reset <= 0;

        $display("testing triangles");
        $display("resetting here, then setting coin to triangle");
        for (int i = 0; i < 5; i++) begin
            coin <= 2'b10;
            @(posedge clock);
        end
        coin <= 2'b10;
        @(posedge clock);
        coin <= 2'b11;
        @(posedge clock);
        coin <= 2'b10;
        @(posedge clock);
        reset <= 1;
        @(posedge clock); $display("reset here");
        reset <= 0;
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b10;
        @(posedge clock);
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b10;
        @(posedge clock);
        reset <= 1;
        @(posedge clock);$display("reset here");
        reset <= 0;
        coin <= 2'b01;
        @(posedge clock);
        reset <= 1;
        @(posedge clock);$display("reset here");
        reset <= 0;
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b01;
        @(posedge clock);
        reset <= 1;
        @(posedge clock);$display("reset here");
        reset <= 0;
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b11;
        @(posedge clock);
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b10;
        @(posedge clock);
        coin <= 2'b00;
        @(posedge clock);
        reset <= 1;
        @(posedge clock);$display("reset here");
        reset <= 0;
        coin <= 2'b10;
        @(posedge clock);
        coin <= 2'b01;
        
        @(posedge clock);
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b01;
        @(posedge clock);
        coin <= 2'b11;
        @(posedge clock);
        reset <= 1;
        @(posedge clock);$display("reset here");

          










        #5 $finish;
    end
endmodule: myFSM_test
  

/*module top();
  logic [3:0] credit;
  logic drop;
  //logic q2, q1, q0;
  logic [1:0] coin;
  logic clock, reset;
  myAbstractFSM dut(.*);
  myFSM_test dut1(.*);
  initial begin
  $monitor($time,, "state=%b, credit=%d, coin=%b, drop=%b",
        dut.state.name, credit, coin, drop);
  end


endmodule: top*/

