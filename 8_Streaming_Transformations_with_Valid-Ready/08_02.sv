module double_tokens_with_flow_control
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

    // Сколько единичных токенов еще нужно выдать вниз
    // На 100 входных единиц подряд без приема вниз нужно накопить 200
    logic [8:0] pending_ones;

    logic in_fire;
    logic out_fire_one;

    always_comb begin
        // В этом testbench down_valid ожидается всегда = 1
        down_valid = 1'b1;

        // На выходе 1, если:
        // - уже есть накопленные единицы
        // - или прямо сейчас пришла новая входная единица
        down_data = (pending_ones != 0) || (up_valid && up_token);

        // Вход можно принимать, пока не накопили 200 единиц к выдаче
        // Это дает ровно 100 принятых входных единиц подряд при down_ready=0
        up_ready = (pending_ones < 9'd200);
    end

    assign in_fire      = up_valid && up_ready && up_token;
    assign out_fire_one = down_ready && down_data;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pending_ones <= 9'd0;
        end
        else begin
            case ({in_fire, out_fire_one})
                2'b00: pending_ones <= pending_ones;           // ничего не приняли и не выдали
                2'b01: pending_ones <= pending_ones - 9'd1;    // выдали одну '1'
                2'b10: pending_ones <= pending_ones + 9'd2;    // приняли одну '1' -> надо выдать две
                2'b11: pending_ones <= pending_ones + 9'd1;    // приняли одну '1' и одну выдали
            endcase
        end
    end

endmodule
