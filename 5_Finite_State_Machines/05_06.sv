module sort_floats_using_fsm #(
    parameter FLEN = 64
) (
    input clk,
    input rst,
    input valid_in,
    input [0:2][FLEN - 1:0] unsorted,
    output logic valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic err,
    output logic busy,
    // f_less_or_equal interface
    output logic [FLEN - 1:0] f_le_a,
    output logic [FLEN - 1:0] f_le_b,
    input f_le_res,
    input f_le_err
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        CMP1 = 2'b01,
        CMP2 = 2'b10,
        CMP3 = 2'b11
    } state_t;

    state_t state;

    logic [FLEN-1:0] x [0:2];
    logic err_reg;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            valid_out <= 0;
            err_reg <= 0;
            x[0] <= 0;
            x[1] <= 0;
            x[2] <= 0;
        end else begin
            case (state)
                IDLE: begin
                    valid_out <= 0;
                    if (valid_in) begin
                        x[0] <= unsorted[0];
                        x[1] <= unsorted[1];
                        x[2] <= unsorted[2];
                        err_reg <= 0;
                        state <= CMP1;
                    end
                end
                CMP1: begin
                    valid_out <= 0;
                    err_reg <= err_reg | f_le_err;
                    if (!f_le_res) begin
                        x[0] <= x[1];
                        x[1] <= x[0];
                    end else begin
                        x[0] <= x[0];
                        x[1] <= x[1];
                    end
                    x[2] <= x[2];
                    state <= CMP2;
                end
                CMP2: begin
                    valid_out <= 0;
                    err_reg <= err_reg | f_le_err;
                    if (!f_le_res) begin
                        x[0] <= x[2];
                        x[2] <= x[0];
                    end else begin
                        x[0] <= x[0];
                        x[2] <= x[2];
                    end
                    x[1] <= x[1];
                    state <= CMP3;
                end
                CMP3: begin
                    err_reg <= err_reg | f_le_err;
                    if (!f_le_res) begin
                        x[1] <= x[2];
                        x[2] <= x[1];
                    end else begin
                        x[1] <= x[1];
                        x[2] <= x[2];
                    end
                    x[0] <= x[0];
                    state <= IDLE;
                    valid_out <= 1;
                end
            endcase
        end
    end

    always @(*) begin
        case (state)
            CMP1: begin
                f_le_a = x[0];
                f_le_b = x[1];
            end
            CMP2: begin
                f_le_a = x[0];
                f_le_b = x[2];
            end
            CMP3: begin
                f_le_a = x[1];
                f_le_b = x[2];
            end
            default: begin
                f_le_a = 0;
                f_le_b = 0;
            end
        endcase
    end

    assign sorted[0] = x[0];
    assign sorted[1] = x[1];
    assign sorted[2] = x[2];
    assign err = err_reg;
    assign busy = (state != IDLE);

endmodule