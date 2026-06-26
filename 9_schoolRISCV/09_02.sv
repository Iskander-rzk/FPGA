//
//  schoolRISCV - small RISC-V CPU
//

`include "sr_cpu.svh"

module sr_mdu
# (
    parameter n_delay = 2
)
(
    input               clk,
    input               rst,

    input               i_vld,
    input        [31:0] srcA,
    input        [31:0] srcB,
    output              o_vld,
    output logic [31:0] result,
    output              busy
);

    logic [31:0] result_pipe [0:n_delay - 1];
    logic [n_delay - 1:0] vld_pipe;

    integer i;

    always_ff @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for (i = 0; i < n_delay; i = i + 1)
            begin
                result_pipe[i] <= 32'b0;
                vld_pipe[i]    <= 1'b0;
            end
        end
        else
        begin
            result_pipe[0] <= srcA * srcB;
            vld_pipe[0]    <= i_vld;

            for (i = 1; i < n_delay; i = i + 1)
            begin
                result_pipe[i] <= result_pipe[i - 1];
                vld_pipe[i]    <= vld_pipe[i - 1];
            end
        end
    end

    assign result = result_pipe[n_delay - 1];
    assign o_vld  = vld_pipe[n_delay - 1];
    assign busy   = |vld_pipe;

endmodule

//----------------------------------------------------------------------------

module shift_register
# (
    parameter width = 8, depth = 8
)
(
    input                clk,
    input  [width - 1:0] in_data,
    output [width - 1:0] out_data
);
    logic [width - 1:0] data [0:depth - 1];

    always_ff @ (posedge clk)
    begin
        data [0] <= in_data;

        for (int i = 1; i < depth; i ++)
            data [i] <= data [i - 1];
    end

    assign out_data = data [depth - 1];

endmodule