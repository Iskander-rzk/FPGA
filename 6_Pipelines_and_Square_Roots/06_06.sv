module float_discriminant_distributor #(
    parameter FLEN = 64,
    parameter NE   = 11
) (
    input  logic             clk,
    input  logic             rst,
    
    input  logic             arg_vld,
    input  logic [FLEN-1:0]  a,
    input  logic [FLEN-1:0]  b,
    input  logic [FLEN-1:0]  c,
    
    output logic             res_vld,
    output logic [FLEN-1:0]  res,
    output logic             res_negative,
    output logic             err,
    output logic             busy
);

    // Сигналы от всех модулей
    logic [NE-1:0] res_vld_t;
    logic [NE-1:0][FLEN-1:0] res_t;
    logic [NE-1:0] res_negative_t;
    logic [NE-1:0] err_t;
    logic [NE-1:0] busy_t;
    
    // Сигналы к модулям
    logic [NE-1:0] arg_vld_t;
    logic [NE-1:0][FLEN-1:0] a_t;
    logic [NE-1:0][FLEN-1:0] b_t;
    logic [NE-1:0][FLEN-1:0] c_t;
    
    // Счетчик для round-robin
    logic [$clog2(NE)-1:0] current_engine;
    integer i;
    
    // Подключаем NE модулей
    generate
        genvar j;
        for (j = 0; j < NE; j++) begin : engines
            float_discriminant #(
                .FLEN (FLEN)
            ) disc (
                .clk(clk),
                .rst(rst),
                .arg_vld(arg_vld_t[j]),
                .a(a_t[j]),
                .b(b_t[j]),
                .c(c_t[j]),
                .res_vld(res_vld_t[j]),
                .res(res_t[j]),
                .res_negative(res_negative_t[j]),
                .err(err_t[j]),
                .busy(busy_t[j])
            );
        end
    endgenerate
    
    // Логика распределения
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_engine <= 0;
            arg_vld_t <= '0;
            res_vld <= 1'b0;
            
            for (i = 0; i < NE; i++) begin
                a_t[i] <= '0;
                b_t[i] <= '0;
                c_t[i] <= '0;
            end
        end else begin
            // Сбрасываем сигналы
            arg_vld_t <= '0;
            res_vld <= 1'b0;
            
            // Если есть новый вход
            if (arg_vld) begin
                // Подаем на текущий модуль
                a_t[current_engine] <= a;
                b_t[current_engine] <= b;
                c_t[current_engine] <= c;
                arg_vld_t[current_engine] <= 1'b1;
                
                // Переходим к следующему
                if (current_engine == NE-1)
                    current_engine <= 0;
                else
                    current_engine <= current_engine + 1;
            end
            
            // Проверяем результаты
            for (i = 0; i < NE; i++) begin
                if (res_vld_t[i]) begin
                    res_vld <= 1'b1;
                    res <= res_t[i];
                    res_negative <= res_negative_t[i];
                    err <= err_t[i];
                end
            end
        end
    end
    
    // Сигнал busy - активен если любой модуль занят
    always_comb begin
        busy = 1'b0;
        for (i = 0; i < NE; i++) begin
            if (busy_t[i]) busy = 1'b1;
        end
    end

endmodule
