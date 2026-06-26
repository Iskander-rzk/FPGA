module formula_1_pipe
(
    input logic clk,
    input logic rst,
    input logic arg_vld,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c,
    output logic res_vld,
    output logic [31:0] res
);
    logic [31:0] sqrt_a, sqrt_b, sqrt_c;
    logic vld_a, vld_b, vld_c;

    isqrt u_isqrt_a (
        .clk    (clk),
        .rst    (rst),
        .x_vld  (arg_vld),
        .x      (a),
        .y_vld  (vld_a),
        .y      (sqrt_a)
    );

    isqrt u_isqrt_b (
        .clk    (clk),
        .rst    (rst),
        .x_vld  (arg_vld),
        .x      (b),
        .y_vld  (vld_b),
        .y      (sqrt_b)
    );

    isqrt u_isqrt_c (
        .clk    (clk),
        .rst    (rst),
        .x_vld  (arg_vld),
        .x      (c),
        .y_vld  (vld_c),
        .y      (sqrt_c)
    );

    assign res = sqrt_a + sqrt_b + sqrt_c;
    assign res_vld = vld_a & vld_b & vld_c;

endmodule