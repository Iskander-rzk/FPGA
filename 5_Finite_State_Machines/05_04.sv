module formula_1_impl_2_fsm
(
    input  logic        clk,
    input  logic        rst,
    
    input  logic        arg_vld,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    
    output logic        res_vld,
    output logic [31:0] res,
    
    // isqrt_1 interface
    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,
    input  logic        isqrt_1_y_vld,
    input  logic [15:0] isqrt_1_y,
    
    // isqrt_2 interface
    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,
    input  logic        isqrt_2_y_vld,
    input  logic [15:0] isqrt_2_y
);

    // ────────────────────────────────────────────────
    //   Состояния автомата
    // ────────────────────────────────────────────────
    typedef enum logic [2:0] {
        IDLE       = 3'd0,
        START_AB   = 3'd1,     // запускаем isqrt(a) и isqrt(b) параллельно
        WAIT_AB    = 3'd2,
        START_C    = 3'd3,     // запускаем isqrt(c)
        WAIT_C     = 3'd4,
        DONE       = 3'd5
    } state_t;

    state_t state, next_state;

    // Регистры для хранения промежуточных результатов
    logic [15:0] sqrt_a;
    logic [15:0] sqrt_b;
    logic [15:0] sqrt_c;

    // ────────────────────────────────────────────────
    //   FSM — последовательная часть
    // ────────────────────────────────────────────────
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // ────────────────────────────────────────────────
    //   Логика переходов и выходов
    // ────────────────────────────────────────────────
    always_comb begin
        // значения по умолчанию
        next_state          = state;
        isqrt_1_x_vld       = 1'b0;
        isqrt_1_x           = 32'b0;
        isqrt_2_x_vld       = 1'b0;
        isqrt_2_x           = 32'b0;
        res_vld             = 1'b0;
        res                 = 32'b0;

        case (state)
            IDLE: begin
                if (arg_vld) begin
                    next_state = START_AB;
                end
            end

            START_AB: begin
                isqrt_1_x_vld = 1'b1;
                isqrt_1_x     = a;
                isqrt_2_x_vld = 1'b1;
                isqrt_2_x     = b;
                next_state    = WAIT_AB;
            end

            WAIT_AB: begin
                if (isqrt_1_y_vld && isqrt_2_y_vld) begin
                    next_state = START_C;
                end
            end

            START_C: begin
                isqrt_1_x_vld = 1'b1;     // используем isqrt_1 повторно
                isqrt_1_x     = c;
                next_state    = WAIT_C;
            end

            WAIT_C: begin
                if (isqrt_1_y_vld) begin
                    next_state = DONE;
                end
            end

            DONE: begin
                res_vld = 1'b1;
                res     = {16'd0, sqrt_a} + {16'd0, sqrt_b} + {16'd0, sqrt_c};
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // ────────────────────────────────────────────────
    //   Сохранение результатов isqrt
    // ────────────────────────────────────────────────
    always_ff @(posedge clk) begin
        if (rst) begin
            sqrt_a <= 16'd0;
            sqrt_b <= 16'd0;
            sqrt_c <= 16'd0;
        end
        else begin
            if (isqrt_1_y_vld && state == WAIT_AB)
                sqrt_a <= isqrt_1_y;

            if (isqrt_2_y_vld && state == WAIT_AB)
                sqrt_b <= isqrt_2_y;

            if (isqrt_1_y_vld && state == WAIT_C)
                sqrt_c <= isqrt_1_y;
        end
    end

endmodule