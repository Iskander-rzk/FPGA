module formula_1_pipe_aware_fsm
(
    input logic clk,
    input logic rst,
    input logic arg_vld,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] c,
    output logic res_vld,
    output logic [31:0] res,
    output logic isqrt_x_vld,
    output logic [31:0] isqrt_x,
    input logic isqrt_y_vld,
    input logic [15:0] isqrt_y
);

    localparam IDLE = 0;
    localparam COMPUTE = 1;

    logic [1:0] state;
    logic [31:0] a_reg;
    logic [31:0] b_reg;
    logic [31:0] c_reg;
    logic [31:0] sum_reg;
    logic [1:0] sent_count;
    logic [1:0] recv_count;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            res_vld <= 0;
            isqrt_x_vld <= 0;
            sum_reg <= 0;
            sent_count <= 0;
            recv_count <= 0;
            a_reg <= 0;
            b_reg <= 0;
            c_reg <= 0;
            res <= 0;
            isqrt_x <= 0;
        end else begin
            isqrt_x_vld <= 0;
            res_vld <= 0;
            case (state)
                IDLE: begin
                    if (arg_vld) begin
                        a_reg <= a;
                        b_reg <= b;
                        c_reg <= c;
                        sum_reg <= 0;
                        sent_count <= 0;
                        recv_count <= 0;
                        state <= COMPUTE;
                    end
                end
                COMPUTE: begin
                    if (sent_count < 3) begin
                        case (sent_count)
                            0: isqrt_x <= a_reg;
                            1: isqrt_x <= b_reg;
                            2: isqrt_x <= c_reg;
                        endcase
                        isqrt_x_vld <= 1;
                        sent_count <= sent_count + 1;
                    end
                    if (isqrt_y_vld) begin
                        sum_reg <= sum_reg + {16'b0, isqrt_y};
                        recv_count <= recv_count + 1;
                        if (recv_count + 1 == 3) begin
                            res <= sum_reg + {16'b0, isqrt_y};
                            res_vld <= 1;
                            state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule