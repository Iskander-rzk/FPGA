module shift_register_with_valid
# (
    parameter width = 8, depth = 8
)
(
    input logic clk,
    input logic rst,
    input logic in_vld,
    input logic [width - 1:0] in_data,
    output logic out_vld,
    output logic [width - 1:0] out_data
);
    logic [width-1:0] regs [0:depth-1];
    logic [depth-1:0] valids;

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < depth; i++) begin
                regs[i] <= '0;
                valids[i] <= 1'b0;
            end
        end else begin
            for (int i = depth-1; i >= 1; i--) begin
                regs[i] <= regs[i-1];
                valids[i] <= valids[i-1];
            end
            regs[0] <= in_vld ? in_data : '0;
            valids[0] <= in_vld ? 1'b1 : 1'b0;
        end
    end

    assign out_data = regs[depth-1];
    assign out_vld = valids[depth-1];
endmodule