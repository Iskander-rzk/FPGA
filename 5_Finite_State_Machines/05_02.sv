module serial_comparator_most_significant_first_using_fsm (
    input  logic clk,
    input  logic rst,
    input  logic a,
    input  logic b,
    output logic a_less_b,
    output logic a_eq_b,
    output logic a_greater_b
);

    typedef enum logic [1:0] {
        EQ,
        LESS,
        GREATER
    } state_t;
    
    state_t state, next_state;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= EQ;
        end else begin
            state <= next_state;
        end
    end
    
    always_comb begin
        next_state = state;
        
        case (state)
            EQ: begin
                if (a < b) next_state = LESS;
                else if (a > b) next_state = GREATER;
                else next_state = EQ;
            end
            LESS: begin
                next_state = LESS;
            end
            GREATER: begin
                next_state = GREATER;
            end
        endcase
        
        case (state)
            EQ: begin
                if (a < b) begin
                    a_less_b = 1'b1;
                    a_eq_b = 1'b0;
                    a_greater_b = 1'b0;
                end else if (a > b) begin
                    a_less_b = 1'b0;
                    a_eq_b = 1'b0;
                    a_greater_b = 1'b1;
                end else begin
                    a_less_b = 1'b0;
                    a_eq_b = 1'b1;
                    a_greater_b = 1'b0;
                end
            end
            LESS: begin
                a_less_b = 1'b1;
                a_eq_b = 1'b0;
                a_greater_b = 1'b0;
            end
            GREATER: begin
                a_less_b = 1'b0;
                a_eq_b = 1'b0;
                a_greater_b = 1'b1;
            end
        endcase
    end

endmodule