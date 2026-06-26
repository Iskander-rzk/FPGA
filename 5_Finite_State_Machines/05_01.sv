module detect_6_bit_sequence_using_fsm (
  input  logic clk,
  input  logic rst,
  input  logic a,
  output logic detected
);

  logic [5:0] shift_reg;
  
  always_ff @(posedge clk) begin
    if (rst) begin
      shift_reg <= 6'b0;
    end else begin
      shift_reg <= {shift_reg[4:0], a};
    end
  end
  
  always_comb begin
    detected = (shift_reg == 6'b110011);
  end

endmodule