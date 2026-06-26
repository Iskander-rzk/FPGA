module gearbox_2_to_1_fc
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      up_valid,
    output logic               up_ready,
    input      [2*width - 1:0] up_data,

    output logic               down_valid,
    input                      down_ready,
    output logic [width - 1:0] down_data
);

    // Internal registers
    logic [2*width - 1:0] buffer_data;
    logic                 buffer_valid;
    logic                 output_high; // 0 = high part, 1 = low part

    // up_ready: can accept new wide word if buffer is empty OR
    // (buffer is valid and we are about to send the last part and down is ready)
    always_comb begin
        if (!buffer_valid)
            up_ready = 1'b1;
        else if (output_high && down_ready)
            up_ready = 1'b1;
        else
            up_ready = 1'b0;
    end

    // down_data and down_valid
    always_comb begin
        if (buffer_valid) begin
            if (!output_high)
                down_data = buffer_data[2*width - 1 : width];
            else
                down_data = buffer_data[width - 1 : 0];
            down_valid = 1'b1;
        end else begin
            down_data = {width{1'b0}};
            down_valid = 1'b0;
        end
    end

    // Main FSM / state update
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            buffer_valid <= 1'b0;
            output_high  <= 1'b0;
        end else begin
            // Default: clear down_valid if consumed
            if (down_valid && down_ready) begin
                if (output_high) begin
                    // Finished sending both parts
                    buffer_valid <= 1'b0;
                    output_high  <= 1'b0;
                end else begin
                    // Move to second part
                    output_high <= 1'b1;
                end
            end

            // Load new data when possible
            if (up_valid && up_ready) begin
                buffer_data <= up_data;
                if (!(down_valid && down_ready && !output_high)) begin
                    // Only set valid if we're not already in the middle
                    // of sending a word that just got consumed
                    if (!(buffer_valid && down_valid && down_ready && !output_high))
                        buffer_valid <= 1'b1;
                    output_high <= 1'b0;
                end
            end
        end
    end

endmodule