//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module serial_comparator_least_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  logic prev_a_eq_b, prev_a_less_b;

  assign a_eq_b      = prev_a_eq_b & (a == b);
  assign a_less_b    = (~ a & b) | (a == b & prev_a_less_b);
  assign a_greater_b = (~ a_eq_b) & (~ a_less_b);

  always_ff @ (posedge clk)
    if (rst)
    begin
      prev_a_eq_b   <= '1;
      prev_a_less_b <= '0;
    end
    else
    begin
      prev_a_eq_b   <= a_eq_b;
      prev_a_less_b <= a_less_b;
    end

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_comparator_most_significant_first
(
  input  clk,
  input  rst,
  input  a,
  input  b,
  output a_less_b,
  output a_eq_b,
  output a_greater_b
);

  // Task:
  // Implement a module that compares two numbers in a serial manner.
  // The module inputs a and b are 1-bit digits of the numbers
  // and most significant bits are first.
  // The module outputs a_less_b, a_eq_b, and a_greater_b
  // should indicate whether a is less than, equal to, or greater than b, respectively.
  // The module should also use the clk and rst inputs.
  //
  // See the testbench for the output format ($display task).
  logic decided;        
  logic prev_less;      
  logic prev_greater;   

  logic cur_a_eq_b;
  logic cur_a_less_b;
  logic cur_a_greater_b;

  assign cur_a_eq_b     = (a == b);
  assign cur_a_less_b   = ~a & b;
  assign cur_a_greater_b = a & ~b;

  assign a_eq_b      = ~decided & cur_a_eq_b & ~prev_less & ~prev_greater;
  assign a_less_b    = (decided & prev_less) | (~decided & cur_a_less_b);
  assign a_greater_b = (decided & prev_greater) | (~decided & cur_a_greater_b);

  always_ff @(posedge clk) begin
    if (rst) begin
      decided      <= 1'b0;
      prev_less    <= 1'b0;
      prev_greater <= 1'b0;
    end
    else begin
      if (decided) begin
      end
      else if (!cur_a_eq_b) begin
        decided      <= 1'b1;
        prev_less    <= cur_a_less_b;
        prev_greater <= cur_a_greater_b;
      end
      else begin
        decided      <= 1'b0;
        prev_less    <= 1'b0;
        prev_greater <= 1'b0;
      end
    end
  end
endmodule
