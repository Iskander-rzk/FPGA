module detect_6_bit_sequence_using_shift_reg (
  input  logic clk,
  input  logic rst,
  input  logic new_bit,
  output logic detected
);

logic [5:0] shift_reg;

always_ff @(posedge clk) begin
    if (rst) begin
        shift_reg <= 6'b000000;
    end
    else begin
      shift_reg <= {shift_reg[4:0], new_bit};   
    end
end

  assign detected = (shift_reg == 6'b110011);

endmodule