module teclado_matrix (
    input clock,
    input reset,
    output reg [3:0] row, // salida hacia filas
    input [3:0] col,     // entrada de columns
    output reg [3:0] key_code, // salida: código de la tecla presionada
    output reg data_ready
);

    reg [1:0] state; // 2-bit state (0-3)

    always @(posedge clock or posedge reset) begin
        
        data_ready <= 1;

        if (reset) begin
            state <= 0;
            row <= 4'b1110;
            data_ready <= 0;
            key_code <= 4'b0000;
        end else begin
            // primero ponemos el row según el estado
            case (state)
                0: row <= 4'b1110;
                1: row <= 4'b1101;
                2: row <= 4'b1011;
                3: row <= 4'b0111;
            endcase
            
            // luego chequeamos columns
            if (col[0] == 0) key_code <= state * 4 + 0;
            else if (col[1] == 0) key_code <= state * 4 + 1;
            else if (col[2] == 0) key_code <= state * 4 + 2;
            else if (col[3] == 0) key_code <= state * 4 + 3;
            else data_ready <= 0;

            


            // avanzar de estado
            state <= state + 1;
            if (state == 3) state <= 0;
        end
    end
    
endmodule