module conv_last_to_first #(
  parameter int width = 8
) (
  input  logic               clock,
  input  logic               reset,

  input  logic               up_valid,
  input  logic               up_last,
  input  logic [width-1:0]   up_data,

  output logic               down_valid,
  output logic               down_first,
  output logic [width-1:0]   down_data
);

  logic first_pending; // выдать down_first на следующем valid

  always_ff @(posedge clock) begin
    if (reset) begin
      down_valid    <= 1'b0;
      down_first    <= 1'b0;
      down_data     <= '0;
      first_pending <= 1'b1;  // первый валидный элемент после reset = начало кадра
    end else begin
      down_valid <= up_valid;

      if (up_valid) begin
        down_data  <= up_data;
        down_first <= first_pending; // first появляется на первом слове кадра
        first_pending <= up_last;    // last текущего кадра -> first следующего
      end else begin
        down_first <= 1'b0; // first имеет смысл только вместе с valid
      end
    end
  end

endmodule