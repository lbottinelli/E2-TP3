module teclado_matrix (
    input clock,
    input reset,
    output reg [3:0] row, // salida hacia filas
    input [3:0] col,     // entrada de columns
    output reg [3:0] key_code, // salida: código de la tecla presionada
    output reg data_ready
);

    reg [1:0] state = 0; // 2-bit state (0-3)
    reg polling_rate;

    // Antirebote
    reg [14:0] anti_rebote_counter = 0;

     // Display Clock
    reg [14:0] freq_counter_i;
    parameter CLK_RST = 10000;

    always @(posedge clock) begin
        freq_counter_i <= freq_counter_i + 1'b1;
        if (freq_counter_i == CLK_RST) begin
            polling_rate <= 1;
        end
        if (freq_counter_i > CLK_RST) begin
            freq_counter_i <= 0;
            polling_rate <= 0;
        end

        data_ready <= 0;
        if (state > 3)
                state <= 0;

        if (polling_rate) begin
            if (anti_rebote_counter > 0)
                anti_rebote_counter <= anti_rebote_counter - 1;
            else begin
                // Primero ponemos el row según el estado
                case (state)
                    3: row <= 4'b0001;
                    0: row <= 4'b0010;
                    1: row <= 4'b0100;
                    2: row <= 4'b1000;
                endcase

                // luego chequeamos columns
                if (col[0] == 1) begin 
                    key_code <= state * 4 + 0; 
                    data_ready <= 1;
                    anti_rebote_counter <= 15'd1000;
                end
                else if (col[1] == 1) begin
                    key_code <= state * 4 + 1;
                    data_ready <= 1;
                    anti_rebote_counter <= 15'd1000;
                end
                else if (col[2] == 1) begin 
                    key_code <= state * 4 + 2;
                    data_ready <= 1;
                    anti_rebote_counter <= 15'd1000;
                end
                else if (col[3] == 1) begin 
                    key_code <= state * 4 + 3;
                    data_ready <= 1;
                    anti_rebote_counter <= 15'd1000;
                end
                //else begin key_code <= key_code; end
                state <= state + 1; 
            end
        end
    end
    
endmodule