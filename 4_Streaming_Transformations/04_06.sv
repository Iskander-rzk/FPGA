module conv_first_to_last_no_ready #(
  parameter int width = 8
)(
  input  logic             clock,
  input  logic             reset,

  input  logic             up_valid,
  input  logic             up_first,
  input  logic [width-1:0] up_data,

  output logic             down_valid,
  output logic             down_last,
  output logic [width-1:0] down_data
);

  // 1-элементный буфер: держим предыдущий принятый элемент,
  // чтобы поставить ему down_last = up_first текущего элемента.
  logic             buf_v;
  logic [width-1:0] buf_data;

  always_ff @(posedge clock) begin
    if (reset) begin
      buf_v      <= 1'b0;
      buf_data   <= '0;
      down_valid <= 1'b0;
      down_last  <= 1'b0;
      down_data  <= '0;
    end else begin
      // по умолчанию на каждом такте ничего не выдаём
      down_valid <= 1'b0;
      down_last  <= 1'b0;

      if (up_valid) begin
        // если в буфере уже есть прошлый элемент — выдаём его
        if (buf_v) begin
          down_valid <= 1'b1;
          down_data  <= buf_data;
          down_last  <= up_first;   // "конец кадра" для прошлого = "first" текущего
        end

        // текущий элемент запоминаем как "прошлый" для следующего раза
        buf_v    <= 1'b1;
        buf_data <= up_data;
      end
    end
  end

endmodule