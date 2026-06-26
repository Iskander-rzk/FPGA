module halve_tokens (
  input  logic clk,
  input  logic rst,
  input  logic a,
  output logic b
);

  logic count;

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= 1'b0;
      b <= 1'b0;
    end
    else begin
      b <= 1'b0;

      if (a) begin
        count <= ~count;
        
        if (count == 1'b1) begin
          b <= 1'b1;
        end
      end
    end
  end

endmodule