module serial_divisibility_by_5_using_fsm (
    input  logic  clk,
    input  logic  rst,
    input  logic  new_bit,
    output logic  div_by_5
);

    localparam logic [2:0] REM_0 = 3'd0;
    localparam logic [2:0] REM_1 = 3'd1;
    localparam logic [2:0] REM_2 = 3'd2;
    localparam logic [2:0] REM_3 = 3'd3;
    localparam logic [2:0] REM_4 = 3'd4;

    logic [2:0] current_state;
    logic [2:0] next_state;

    always_ff @(posedge clk) begin
        if (rst)
            current_state <= REM_0;
        else
            current_state <= next_state;
    end

    always_comb begin
        case (current_state)
            REM_0: next_state = new_bit ? REM_1 : REM_0;
            REM_1: next_state = new_bit ? REM_3 : REM_2;
            REM_2: next_state = new_bit ? REM_0 : REM_4;
            REM_3: next_state = new_bit ? REM_2 : REM_1;
            REM_4: next_state = new_bit ? REM_4 : REM_3;
            default: next_state = REM_0;
        endcase
    end

    assign div_by_5 = (current_state == REM_0);

endmodule