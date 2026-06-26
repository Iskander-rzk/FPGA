module generate_tokens_by_number_with_flow_control
#(
    parameter WIDTH = 4
)
(
    input                clk,
    input                rst,

    input                up_valid,
    output logic         up_ready,
    input  [WIDTH-1 : 0] n_tokens,

    output logic         down_valid,
    input                down_ready,
    output logic         down_token
);

    // FSM states
    typedef enum logic [1:0] {
        IDLE,
        GENERATE
    } state_t;
    
    state_t state, next_state;
    
    // Counter for remaining tokens to generate
    logic [WIDTH-1 : 0] counter;
    logic [WIDTH-1 : 0] counter_next;
    logic                counter_load;
    logic                counter_decr;
    
    // Registers for handshake
    logic                n_tokens_reg_valid;
    logic [WIDTH-1 : 0]  n_tokens_reg;
    
    // FSM transition
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // FSM next state logic
    always_comb begin
        next_state = state;
        
        case (state)
            IDLE: begin
                // Accept new number when up_valid is asserted and we're ready
                if (up_valid && up_ready && (n_tokens_reg_valid || n_tokens != 0)) begin
                    next_state = GENERATE;
                end
            end
            
            GENERATE: begin
                // Stay in GENERATE until all tokens are sent
                // Counter reaches 0 after decrement when token is sent
                if (counter == 0) begin
                    next_state = IDLE;
                end else begin
                    next_state = GENERATE;
                end
            end
        endcase
    end
    
    // up_ready logic
    always_comb begin
        up_ready = (state == IDLE);
    end
    
    // Capture n_tokens when handshake happens
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            n_tokens_reg_valid <= 1'b0;
            n_tokens_reg <= 0;
        end else begin
            if (state == IDLE && up_valid && up_ready) begin
                if (n_tokens == 0) begin
                    n_tokens_reg_valid <= 1'b0;
                end else begin
                    n_tokens_reg_valid <= 1'b1;
                    n_tokens_reg <= n_tokens;
                end
            end else if (state == GENERATE && counter == 0) begin
                n_tokens_reg_valid <= 1'b0;
            end
        end
    end
    
    // Counter logic
    always_comb begin
        counter_load = 1'b0;
        counter_decr = 1'b0;
        
        if (state == IDLE && up_valid && up_ready && n_tokens != 0) begin
            counter_load = 1'b1;
        end else if (state == GENERATE && down_valid && down_ready && counter != 0) begin
            counter_decr = 1'b1;
        end
    end
    
    always_comb begin
        if (counter_load) begin
            counter_next = n_tokens;
        end else if (counter_decr) begin
            counter_next = counter - 1;
        end else begin
            counter_next = counter;
        end
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            counter <= counter_next;
        end
    end
    
    // down_valid and down_token logic
    always_comb begin
        down_valid = (state == GENERATE) && (counter != 0);
        down_token = down_valid;
    end

endmodule