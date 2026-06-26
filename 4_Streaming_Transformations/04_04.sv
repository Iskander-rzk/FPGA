module gearbox_1_to_2 #(
  parameter int width = 8  
) (
  input  logic             clk,
  input  logic             rst,

  input  logic             up_vld,
  input  logic [width-1:0] up_data,

  output logic             down_vld,
  output logic [2*width-1:0] down_data
);

  logic [width-1:0]        buffer;
  logic                    have_first;


  always_ff @(posedge clk) begin
    if (rst) begin
      have_first  <= 1'b0;
      buffer      <= '0;
      down_vld    <= 1'b0;
    end

    else begin
      down_vld <= 1'b0;           

      if (up_vld) begin
        if (have_first) begin
          down_data <= {buffer, up_data};   
          down_vld  <= 1'b1;
          have_first <= 1'b0;               
        end
        else begin
          buffer     <= up_data;
          have_first <= 1'b1;
        end
      end
    end
  end

endmodule