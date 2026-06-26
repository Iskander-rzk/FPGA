//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_overflow
(
  input  [3:0] a, b,
  output [3:0] sum,
  output       overflow
);
  wire signed [3:0] a_signed = a;
  wire signed [3:0] b_signed = b;
  wire signed [4:0] extended_sum; 
  
  assign extended_sum = {a_signed[3], a_signed} + {b_signed[3], b_signed};
  assign sum = extended_sum[3:0];
  assign overflow = (extended_sum[4] ^ extended_sum[3]) & 
                    ~(a_signed[3] ^ b_signed[3]);



endmodule
