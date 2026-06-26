module float_discriminant #(
    parameter FLEN = 64
) (
    input clk,
    input rst,
    input arg_vld,
    input [FLEN - 1:0] a,
    input [FLEN - 1:0] b,
    input [FLEN - 1:0] c,
    output logic res_vld,
    output logic [FLEN - 1:0] res,
    output logic res_negative,
    output logic err,
    output logic busy
);

    typedef enum logic [1:0] {
        IDLE = 2'd0,
        WAIT_BB_AC = 2'd1,
        WAIT_4AC = 2'd2,
        WAIT_SUB = 2'd3
    } state_t;

    state_t state;

    logic [FLEN-1:0] reg_a, reg_b, reg_c;
    logic [FLEN-1:0] four = 64'h4010000000000000;

    logic start_mult_bb, start_mult_ac, start_mult_4, start_sub;
    logic bb_done, ac_done, four_done, sub_done;
    logic bb_busy, ac_busy, four_busy, sub_busy;
    logic bb_err, ac_err, four_err, sub_err;
    logic [FLEN-1:0] b2, ac, four_ac, sub_res;

    // Input checks for NaN/Inf
    wire [10:0] reg_a_exp = reg_a[62:52];
    wire [51:0] reg_a_mant = reg_a[51:0];
    wire reg_a_nan = (reg_a_exp == 11'h7ff) && (reg_a_mant != 52'd0);
    wire reg_a_inf = (reg_a_exp == 11'h7ff) && (reg_a_mant == 52'd0);

    wire [10:0] reg_b_exp = reg_b[62:52];
    wire [51:0] reg_b_mant = reg_b[51:0];
    wire reg_b_nan = (reg_b_exp == 11'h7ff) && (reg_b_mant != 52'd0);
    wire reg_b_inf = (reg_b_exp == 11'h7ff) && (reg_b_mant == 52'd0);

    wire [10:0] reg_c_exp = reg_c[62:52];
    wire [51:0] reg_c_mant = reg_c[51:0];
    wire reg_c_nan = (reg_c_exp == 11'h7ff) && (reg_c_mant != 52'd0);
    wire reg_c_inf = (reg_c_exp == 11'h7ff) && (reg_c_mant == 52'd0);

    wire err_input = reg_a_nan | reg_a_inf | reg_b_nan | reg_b_inf | reg_c_nan | reg_c_inf;

    f_mult mult_bb (
        .clk(clk),
        .rst(rst),
        .a(reg_b),
        .b(reg_b),
        .up_valid(start_mult_bb),
        .res(b2),
        .down_valid(bb_done),
        .busy(bb_busy),
        .error(bb_err)
    );

    f_mult mult_ac (
        .clk(clk),
        .rst(rst),
        .a(reg_a),
        .b(reg_c),
        .up_valid(start_mult_ac),
        .res(ac),
        .down_valid(ac_done),
        .busy(ac_busy),
        .error(ac_err)
    );

    f_mult mult_4ac (
        .clk(clk),
        .rst(rst),
        .a(ac),
        .b(four),
        .up_valid(start_mult_4),
        .res(four_ac),
        .down_valid(four_done),
        .busy(four_busy),
        .error(four_err)
    );

    f_sub subtract (
        .clk(clk),
        .rst(rst),
        .a(b2),
        .b(four_ac),
        .up_valid(start_sub),
        .res(sub_res),
        .down_valid(sub_done),
        .busy(sub_busy),
        .error(sub_err)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            res_vld <= 1'b0;
            busy <= 1'b0;
            err <= 1'b0;
            res_negative <= 1'b0;
            start_mult_bb <= 1'b0;
            start_mult_ac <= 1'b0;
            start_mult_4 <= 1'b0;
            start_sub <= 1'b0;
        end else begin
            res_vld <= 1'b0;
            start_mult_bb <= 1'b0;
            start_mult_ac <= 1'b0;
            start_mult_4 <= 1'b0;
            start_sub <= 1'b0;
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    if (arg_vld) begin
                        reg_a <= a;
                        reg_b <= b;
                        reg_c <= c;
                        start_mult_bb <= 1'b1;
                        start_mult_ac <= 1'b1;
                        state <= WAIT_BB_AC;
                        busy <= 1'b1;
                    end
                end
                WAIT_BB_AC: begin
                    if (bb_done && ac_done) begin
                        start_mult_4 <= 1'b1;
                        state <= WAIT_4AC;
                    end
                end
                WAIT_4AC: begin
                    if (four_done) begin
                        start_sub <= 1'b1;
                        state <= WAIT_SUB;
                    end
                end
                WAIT_SUB: begin
                    if (sub_done) begin
                        res <= sub_res;
                        res_vld <= 1'b1;
                        res_negative <= sub_res[63] && (sub_res[62:0] != 63'd0);
                        err <= err_input;
                        state <= IDLE;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule