module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input  logic                       clk,
    input  logic                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output logic                down_vld,
    output logic [ width - 1:0] down_data
);

    // Буферы для хранения данных каждого входа
    logic [n_inputs-1:0][width-1:0] data_buffer;
    logic [n_inputs-1:0] valid_buffer;
    
    // Счетчик текущего ожидаемого индекса
    logic [$clog2(n_inputs)-1:0] current_idx, next_idx;
    
    // Комбинационная логика для определения, готов ли текущий индекс
    logic current_ready;
    logic [width-1:0] current_data;
    
    always_comb begin
        // По умолчанию используем данные из буфера
        current_ready = valid_buffer[current_idx];
        current_data = data_buffer[current_idx];
        
        // Если данные приходят в этом такте для текущего индекса,
        // используем их (они имеют приоритет)
        if (up_vlds[current_idx]) begin
            current_ready = 1'b1;
            current_data = up_data[current_idx];
        end
    end
    
    assign next_idx = (current_idx == n_inputs-1) ? 0 : current_idx + 1;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_idx <= 0;
            down_vld <= 0;
            down_data <= 0;
            
            for (int i = 0; i < n_inputs; i++) begin
                valid_buffer[i] <= 0;
                data_buffer[i] <= 0;
            end
        end else begin
            // Сохраняем входные данные в буфер
            for (int i = 0; i < n_inputs; i++) begin
                if (up_vlds[i]) begin
                    data_buffer[i] <= up_data[i];
                    valid_buffer[i] <= 1'b1;
                end
            end
            
            // Выдаем данные, если текущий индекс готов
            if (current_ready) begin
                down_vld <= 1'b1;
                down_data <= current_data;
                
                // Сбрасываем валидность для этого индекса
                valid_buffer[current_idx] <= 1'b0;
                
                // Переходим к следующему индексу
                current_idx <= next_idx;
            end else begin
                down_vld <= 1'b0;
            end
        end
    end

endmodule