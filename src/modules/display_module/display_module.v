module display_module
#(parameter BITS = 16)
(
    input [BITS-1:0] VALUE_BIN,
    input internal_clock,

    output VALUE_SIGNAL = 1'b0,
    output ENABLE_SIGNAL = 1'b1,
    output reg BOARD_CLOCK_SIGNAL,
    output reg DATA_CLOCK_SIGNAL
);

    // --------------------------
    // Función: Binario a BCD (4 dígitos)
    // --------------------------
    function [15:0] bin_a_bcd_4dig;
    input [13:0] bin;
    integer i;
    reg [29:0] shift_reg;  // 14 bits binario + 16 bits BCD
    if(bin > 14'd9999) begin        // Su se pasa de lo que podemos representar -> Devuelve un codigo de error: OVERFLOW
        shift_reg[29:26] = 4'd15;
        shift_reg[25:22] = 4'd15;
        shift_reg[21:18] = 4'd15;
        shift_reg[17:14] = 4'd15;
        bin_a_bcd_4dig = shift_reg[29:14];  
    end
    else begin
        shift_reg = 30'd0;
        shift_reg[13:0] = bin;  // Binario en los bits menos significativos

        for (i = 0; i < 14; i = i + 1) begin
        // Suma 3 si el grupo BCD ≥ 5
        if (shift_reg[29:26] >= 5)
            shift_reg[29:26] = shift_reg[29:26] + 3; // Miles
        if (shift_reg[25:22] >= 5)
            shift_reg[25:22] = shift_reg[25:22] + 3; // Centenas
        if (shift_reg[21:18] >= 5)
            shift_reg[21:18] = shift_reg[21:18] + 3; // Decenas
        if (shift_reg[17:14] >= 5)
            shift_reg[17:14] = shift_reg[17:14] + 3; // Unidades

        shift_reg = shift_reg << 1; // Desplazamiento
        end

        bin_a_bcd_4dig = shift_reg[29:14]; // BCD final
    end
    endfunction

    // Define clocks
    // Display Clock
    reg [7:0] freq_counter_i;
    parameter CLK_RST = 240;
     always @(posedge internal_clock) begin
	    freq_counter_i <= freq_counter_i + 1'b1;
        if (freq_counter_i > CLK_RST) begin
            freq_counter_i <= 0;
            BOARD_CLOCK_SIGNAL <= !BOARD_CLOCK_SIGNAL;
        end
    end

    // Serial Clock
    // Display Clock
    reg [12:0] freq_counter_2;
    parameter DATA_CLK_RST = 4600;
     always @(posedge internal_clock) begin
	    freq_counter_2 <= freq_counter_2 + 1'b1;
        if (freq_counter_2 > DATA_CLK_RST) begin
            freq_counter_2 <= 0;
            DATA_CLOCK_SIGNAL <= !DATA_CLOCK_SIGNAL;
        end
    end

    wire [BITS-1:0] VALUE_BCD;

    assign VALUE_BCD = bin_a_bcd_4dig(VALUE_BIN);

    integer k = 0;

    always @(*) begin
        if(k<16) begin
            VALUE_SIGNAL = VALUE_BCD[k];
            k = k+1;
        end
        else begin
            VALUE_SIGNAL = 1'b0;
            ENABLE_SIGNAL = 1'b0;
        end
    end    

endmodule



