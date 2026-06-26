module halve_tokens_with_flow_control
(
    input              clk,
    input              rst,

    input              up_valid,
    output logic       up_ready,
    input              up_token,

    output logic       down_valid,
    input              down_ready,
    output logic       down_data
);

    // 0 -> очередную '1' гасим
    // 1 -> очередную '1' пропускаем
    logic pass_flag;

    // буфер одного токена
    logic buf_valid;
    logic buf_data;

    // уже показывали ли этот буферный токен на выходе
    logic buf_shown;

    logic cur_data;

    assign cur_data = up_token ? pass_flag : 1'b0;

    always_comb begin
        if (buf_valid) begin
            down_valid = 1'b1;

            // единицу из буфера показываем только один раз
            if (!buf_shown)
                down_data = buf_data;
            else
                down_data = 1'b0;

            // новый вход можно принять только если буфер уйдет
            up_ready = down_ready;
        end
        else begin
            // буфер пуст -> текущий вход сразу виден на выходе
            down_valid = up_valid;
            down_data  = up_valid ? cur_data : 1'b0;

            // можно принять вход
            up_ready = 1'b1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pass_flag <= 1'b0;
            buf_valid <= 1'b0;
            buf_data  <= 1'b0;
            buf_shown <= 1'b0;
        end
        else begin
            // меняем фазу только при принятии входной единицы
            if (up_valid && up_ready && up_token)
                pass_flag <= ~pass_flag;

            if (buf_valid) begin
                // если токен в буфере еще не показывали — отмечаем, что показали
                if (!buf_shown)
                    buf_shown <= 1'b1;

                if (down_ready) begin
                    // буферный токен считается ушедшим
                    if (up_valid) begin
                        // одновременно принимаем новый токен в буфер
                        buf_valid <= 1'b1;
                        buf_data  <= cur_data;
                        buf_shown <= 1'b0;
                    end
                    else begin
                        buf_valid <= 1'b0;
                        buf_data  <= 1'b0;
                        buf_shown <= 1'b0;
                    end
                end
            end
            else begin
                // буфер пуст
                if (up_valid && !down_ready) begin
                    // приняли токен, но вниз сейчас не готово
                    buf_valid <= 1'b1;
                    buf_data  <= cur_data;

                    // этот токен уже был показан на выходе в текущем такте
                    buf_shown <= 1'b1;
                end
                else begin
                    buf_valid <= 1'b0;
                    buf_data  <= 1'b0;
                    buf_shown <= 1'b0;
                end
            end
        end
    end

endmodule
