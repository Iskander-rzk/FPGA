module double_tokens (
  input  logic  clk,
  input  logic  rst,
  input  logic  a,
  output logic  b,
  output logic  overflow
);

  logic [8:0] debt;
  logic [7:0] consec_ones;

  always_ff @(posedge clk) begin
    if (rst) begin
      debt         <= 9'd0;
      consec_ones  <= 8'd0;
      overflow     <= 1'b0;
    end

    else begin
      if (overflow) begin
        overflow <= 1'b1;
      end
      if (a) begin
        debt <= debt + 1;
        if (consec_ones == 8'd200) begin
          overflow <= 1'b1;
        end
        else if (consec_ones < 8'd200) begin
          consec_ones <= consec_ones + 1;
        end
        b <= 1'b1;
      end

      else begin
        consec_ones <= 8'd0;
        if (debt > 0) begin
          debt <= debt - 1;
          b    <= 1'b1;
        end
        else begin
          b <= 1'b0;
        end
      end
    end
  end
endmodule