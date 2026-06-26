//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  // Task:
  // Create an one cycle pulse (010) detector.
  //
  // Note:
  // See the testbench for the output format ($display task).
  logic a_d1, a_d2;

  always_ff @(posedge clk) begin
    if (rst) begin
      a_d1 <= 0;
      a_d2 <= 0;
    end 
    else begin
      a_d2 <= a_d1;
      a_d1 <= a;
    end
  end

  assign detected = ~a_d2 & a_d1 & ~a;

endmodule
