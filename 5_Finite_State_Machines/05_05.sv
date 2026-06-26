module formula_2_fsm
(
    input  logic       clk,
    input  logic       rst,
    input  logic       arg_vld,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    output logic       res_vld,
    output logic [31:0] res,

    output logic       isqrt_x_vld,
    output logic [31:0] isqrt_x,
    input  logic       isqrt_y_vld,
    input  logic [15:0] isqrt_y
);

    typedef enum logic [2:0] {
        IDLE,
        START_INNermost,     // подаём c
        WAIT_INNermost,
        START_MIDDLE,        // подаём b + sqrt(c)
        WAIT_MIDDLE,
        START_OUTER,         // подаём a + sqrt(b + sqrt(c))
        WAIT_OUTER,
        DONE
    } state_t;

    state_t state, next;

    logic [31:0] tmp1, tmp2;
    logic [15:0] sqrt_c, sqrt_bc;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            res_vld    <= 0;
            isqrt_x_vld<= 0;
            tmp1       <= 0;
            tmp2       <= 0;
            sqrt_c     <= 0;
            sqrt_bc    <= 0;
            res        <= 0;
        end
        else begin
            state <= next;

            case (state)
                IDLE: begin
                    res_vld     <= 0;
                    isqrt_x_vld <= 0;
                    if (arg_vld) begin
                        tmp1 <= c;
                    end
                end

                START_INNermost: begin
                    isqrt_x_vld <= 1;
                    isqrt_x     <= tmp1;           // c
                end

                WAIT_INNermost: begin
                    isqrt_x_vld <= 0;
                    if (isqrt_y_vld) begin
                        sqrt_c <= isqrt_y;
                        tmp1   <= b + isqrt_y;     // b + √c   (расширение до 32 бит)
                    end
                end

                START_MIDDLE: begin
                    isqrt_x_vld <= 1;
                    isqrt_x     <= tmp1;           // b + √c
                end

                WAIT_MIDDLE: begin
                    isqrt_x_vld <= 0;
                    if (isqrt_y_vld) begin
                        sqrt_bc <= isqrt_y;
                        tmp2    <= a + isqrt_y;    // a + √(b+√c)
                    end
                end

                START_OUTER: begin
                    isqrt_x_vld <= 1;
                    isqrt_x     <= tmp2;
                end

                WAIT_OUTER: begin
                    isqrt_x_vld <= 0;
                    if (isqrt_y_vld) begin
                        res     <= {16'd0, isqrt_y};   // расширение до 32 бит
                        res_vld <= 1;
                    end
                end

                DONE: begin
                    res_vld <= 0;
                end
            endcase
        end
    end

    always_comb begin
        next = state;

        case (state)
            IDLE: begin
                if (arg_vld)
                    next = START_INNermost;
            end

            START_INNermost: begin
                next = WAIT_INNermost;
            end

            WAIT_INNermost: begin
                if (isqrt_y_vld)
                    next = START_MIDDLE;
            end

            START_MIDDLE: begin
                next = WAIT_MIDDLE;
            end

            WAIT_MIDDLE: begin
                if (isqrt_y_vld)
                    next = START_OUTER;
            end

            START_OUTER: begin
                next = WAIT_OUTER;
            end

            WAIT_OUTER: begin
                if (isqrt_y_vld)
                    next = DONE;
            end

            DONE: begin
                next = IDLE;
            end
        endcase
    end

endmodule