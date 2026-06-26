module gearbox_1_to_2_fc
#(
    parameter width = 8
)
(
    input                        clk,
    input                        rst,

    input                        up_valid,
    output logic                 up_ready,
    input      [width - 1:0]     up_data,

    output logic                 down_valid,
    input                        down_ready,
    output logic [2*width - 1:0] down_data
);

    logic [width-1:0]       first_word;
    logic                   have_first;

    logic [2*width-1:0]     pair_word;
    logic                   have_pair;

    logic in_fire;
    logic out_fire;

    assign down_valid = have_pair;
    assign down_data  = have_pair ? pair_word : 'x;

    assign up_ready = !have_pair || down_ready;

    assign in_fire  = up_valid  && up_ready;
    assign out_fire = have_pair && down_ready;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            first_word <= '0;
            have_first <= 1'b0;
            pair_word  <= '0;
            have_pair  <= 1'b0;
        end
        else begin
            // 1. Если пара ушла вниз
            if (out_fire) begin
                have_pair <= 1'b0;

                // и в этот же такт пришло новое слово:
                // оно становится первым словом следующей пары
                if (in_fire) begin
                    first_word <= up_data;
                    have_first <= 1'b1;
                end
                else begin
                    have_first <= 1'b0;
                end
            end
            else if (!have_pair) begin
                // 2. Если полной пары нет, можем накапливать вход
                if (in_fire) begin
                    if (!have_first) begin
                        first_word <= up_data;
                        have_first <= 1'b1;
                    end
                    else begin
                        pair_word  <= {first_word, up_data};
                        have_pair  <= 1'b1;
                        have_first <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
