module sumador
#(parameter BITS = 14)
(
    input [BITS-1:0] A,
    input [BITS-1:0] B,

    output wire [BITS-1:0] O,
    output wire OVERFLOW
);

    localparam [BITS:0] MAX_DECIMAL = 15'd9999;     // Maximo valor que podemos representar en display
    localparam [BITS-1:0] ERROR_SUM = 14'd9999;     // Flag: ERROR DE SUMA -> Valor en 
                                                    // display que mostremos en caso de overflow

    wire [BITS:0] O_EXTENDED = A + B;

    wire IN_RANGE;

    assign IN_RANGE = O_EXTENDED < MAX_DECIMAL;

    wire [BITS-1:0] OUT;

    assign OUT = IN_RANGE? O_EXTENDED[BITS-1:0]: ERROR_SUM;

    assign O = OUT;
    assign OVERFLOW = !IN_RANGE;    

endmodule

module restador
#(parameter BITS = 14)
(
    input [BITS-1:0] A,
    input [BITS-1:0] B,

    output wire [BITS-1:0] O,
    output wire SIGNO
);

    wire NEGATIVE;

    assign NEGATIVE = A < B;

    wire [BITS-1:0] OUT;

    assign OUT = NEGATIVE? B-A: A-B;

    assign O = OUT;
    assign SIGNO = NEGATIVE;    

endmodule


module multiplicador
#(parameter BITS = 14, parameter BITS_EXT = 27)
(
    input [BITS-1:0] A,
    input [BITS-1:0] B,

    output wire [BITS-1:0] O,
    output wire OUT_OF_RANGE
);
    localparam [BITS:0] MAX_DECIMAL = 15'd9999;     // Maximo valor que podemos representar en display
    localparam [BITS-1:0] ERROR_PRODUCT = 14'd9999;     // Flag: ERROR DE MULTIPLICACION -> Valor en 
                                                    // display que mostremos en caso de superar 9999


    wire [BITS_EXT:0] O_EXTENDED = A*B; // BITS_EXT = 27 -> Max multip: 9999*9999=99980001 -> n=26.57 ~= 27 bits

    wire IN_RANGE;

    assign IN_RANGE = O_EXTENDED < MAX_DECIMAL;

    wire [BITS-1:0] OUT;

    assign OUT = IN_RANGE? O_EXTENDED[BITS-1:0]: ERROR_PRODUCT;

    assign O = OUT;
    assign OUT_OF_RANGE = !IN_RANGE;    

endmodule

// --------------------------
// Función: Binario a BCD (4 dígitos)
// --------------------------
// function [15:0] bin_a_bcd_4dig;
// input [13:0] bin;
// integer i;
// reg [29:0] shift_reg;  // 14 bits binario + 16 bits BCD

// begin
//     shift_reg = 30'd0;
//     shift_reg[13:0] = bin;  // Binario en los bits menos significativos

//     for (i = 0; i < 14; i = i + 1) begin
//     // Suma 3 si el grupo BCD ≥ 5
//     if (shift_reg[29:26] >= 5)
//         shift_reg[29:26] = shift_reg[29:26] + 3; // Miles
//     if (shift_reg[25:22] >= 5)
//         shift_reg[25:22] = shift_reg[25:22] + 3; // Centenas
//     if (shift_reg[21:18] >= 5)
//         shift_reg[21:18] = shift_reg[21:18] + 3; // Decenas
//     if (shift_reg[17:14] >= 5)
//         shift_reg[17:14] = shift_reg[17:14] + 3; // Unidades

//     shift_reg = shift_reg << 1; // Desplazamiento
//     end

//     bin_a_bcd_4dig = shift_reg[29:14]; // BCD final
// end
// endfunction
