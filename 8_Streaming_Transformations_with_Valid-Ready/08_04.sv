module convert_first_to_last_with_flow_control
#(
    parameter width = 8
)
(
    input                      clock,
    input                      reset,

    input                      up_valid,
    output logic               up_ready,
    input                      up_first,
    input        [width - 1:0] up_data,

    output logic               down_valid,
    input                      down_ready,
    output logic               down_last,
    output logic [width - 1:0] down_data
);

    logic [width - 1:0] saved_data;
    logic               have_saved;

    always_comb begin
        up_ready   = !have_saved || down_ready;

        down_valid = have_saved && up_valid;
        down_data  = down_valid ? saved_data : 'x;
        down_last  = down_valid ? up_first   : 1'bx;
    end

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            saved_data <= '0;
            have_saved <= 1'b0;
        end
        else begin
            if (up_valid && up_ready) begin
                saved_data <= up_data;
                have_saved <= 1'b1;
            end
        end
    end

endmodule
