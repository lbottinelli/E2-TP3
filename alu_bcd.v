// -------------------------
// SUMADOR BCD DE 4 DIGITOS
// -------------------------

module sumador_bcd_4_digitos (
    input  [15:0] A,            // 4 dígitos BCD (A3 A2 A1 A0)
    input  [15:0] B,            // 4 dígitos BCD (B3 B2 B1 B0)
    output [15:0] result,       // Resultado BCD (4 dígitos)
    output        Cout          // Acarreo final (si el resultado es > 9999)
);

    wire c1, c2, c3;
    wire [15:0] S;

    // Suma dígito 0 (unidades)
    sumador_bcd u0 (
        .A   (A[3:0]),
        .B   (B[3:0]),
        .Cin (1'b0),
        .S   (S[3:0]),
        .Cout(c1)
    );

    // Suma dígito 1 (decenas)
    sumador_bcd u1 (
        .A   (A[7:4]),
        .B   (B[7:4]),
        .Cin (c1),
        .S   (S[7:4]),
        .Cout(c2)
    );

    // Suma dígito 2 (centenas)
    sumador_bcd u2 (
        .A   (A[11:8]),
        .B   (B[11:8]),
        .Cin (c2),
        .S   (S[11:8]),
        .Cout(c3)
    );

    // Suma dígito 3 (milésimas)
    sumador_bcd u3 (
        .A   (A[15:12]),
        .B   (B[15:12]),
        .Cin (c3),
        .S   (S[15:12]),
        .Cout(Cout)
    );

    assign result = Cout? 16'b1111_1111_1111_1111 : S; // Si hay acarreo, mostramos 9999 (error de suma)
    
endmodule

module sumador_bcd (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] S,
    output       Cout
);

    wire [4:0] suma_binaria;
    wire       correccion;
    wire [4:0] suma_corregida;

    assign suma_binaria = A + B + Cin;
    assign correccion   = (suma_binaria > 9);
    assign suma_corregida = correccion ? (suma_binaria + 5'd6) : suma_binaria;

    assign S    = suma_corregida[3:0];
    assign Cout = suma_corregida[4];

endmodule

// -------------------------
// RESTADOR BCD DE 4 DIGITOS
// -------------------------

module restador_bcd_4_digitos (
    input  [15:0] A,        // BCD input A (4 digitos)
    input  [15:0] B,        // BCD input B (4 digitos)
    output reg [15:0] R,    // Resultado en BCD (4 digitos)
    output reg neg          // Indica si el resultado es negativo (A < B)
);

    
    reg [3:0] A0, A1, A2, A3;
    reg [3:0] B0, B1, B2, B3;
    reg [3:0] R0, R1, R2, R3;
    

    integer d0, d1, d2, d3;
    integer borrow0, borrow1, borrow2;

    always @(*) begin
        // Separo cada digito en BCD
        A0 = A[3:0];
        A1 = A[7:4];
        A2 = A[11:8];
        A3 = A[15:12];

        B0 = B[3:0];
        B1 = B[7:4];
        B2 = B[11:8];
        B3 = B[15:12];

        // Inicializar borrow
        borrow0 = 0;
        borrow1 = 0;
        borrow2 = 0;
        neg = 0;

        // Comparar si A < B para saber si el resultado será negativo
        if (A < B) begin
            neg = 1;
            // Intercambiamos A y B para hacer B - A y luego marcarlo como negativo
            A0 = B[3:0];   B0 = A[3:0];
            A1 = B[7:4];   B1 = A[7:4];
            A2 = B[11:8];  B2 = A[11:8];
            A3 = B[15:12]; B3 = A[15:12];
        end

        // Restar dígito por dígito con borrow (BCD decimal math)
        // Unidades
        d0 = A0 - B0;
        if (d0 < 0) begin
            d0 = d0 + 10;
            borrow0 = 1;
        end else borrow0 = 0;

        // Decenas
        d1 = A1 - B1 - borrow0;
        if (d1 < 0) begin
            d1 = d1 + 10;
            borrow1 = 1;
        end else borrow1 = 0;

        // Centenas
        d2 = A2 - B2 - borrow1;
        if (d2 < 0) begin
            d2 = d2 + 10;
            borrow2 = 1;
        end else borrow2 = 0;

        // Millar
        d3 = A3 - B3 - borrow2;
        if (d3 < 0) begin
            d3 = d3 + 10;
            // No se propaga más
        end

        // Empaquetar resultado en BCD
        R = {d3[3:0], d2[3:0], d1[3:0], d0[3:0]};
    end

endmodule

// ------------------------------
// MULTIPLICADOR BCD DE 4 DIGITOS
// ------------------------------

module multiplicador_bcd_4_digitos (
    input  [15:0] A,        // BCD input A (4 dígitos: A3 A2 A1 A0)
    input  [15:0] B,        // BCD input B (4 dígitos: B3 B2 B1 B0)
    output reg [15:0] R,    // Resultado en BCD o 16'hFFFF si overflow
    output reg overflow    
);

    integer dec_A, dec_B;
    integer product;
    reg [3:0] d0, d1, d2, d3;

    always @(*) begin
        // Convertir A de BCD a decimal
        dec_A = (A[15:12] * 1000) + (A[11:8] * 100) + (A[7:4] * 10) + A[3:0];

        // Convertir B de BCD a decimal
        dec_B = (B[15:12] * 1000) + (B[11:8] * 100) + (B[7:4] * 10) + B[3:0];

        // Multiplicación decimal
        product = dec_A * dec_B;

        // Si el producto > 9999, saturamos a FFFF
        if (product > 9999) begin
            overflow = 1; // Indicamos que hubo overflow
            R = 16'hFFFF;
        end else begin
            // Convertir resultado decimal a BCD (máximo 4 dígitos)
            d3 = (product / 1000) % 10;
            d2 = (product / 100)  % 10;
            d1 = (product / 10)   % 10;
            d0 = product % 10;
            overflow = 0; // No hubo overflow

            R = {d3, d2, d1, d0};
        end
    end

endmodule

module bcd_modulo_4digit (
    input  [15:0] A,           // 4-digit BCD
    input  [15:0] B,           // 4-digit BCD
    output [15:0] Remainder,   // 4-digit BCD remainder
    output        DivideByZero
);
    wire [13:0] A_bin, B_bin;
    wire [13:0] rem_bin;

    // Convert BCD to binary
    assign A_bin = (A[15:12]*1000) + (A[11:8]*100) + (A[7:4]*10) + A[3:0];
    assign B_bin = (B[15:12]*1000) + (B[11:8]*100) + (B[7:4]*10) + B[3:0];

    assign DivideByZero = (B_bin == 0);

    assign rem_bin = DivideByZero ? 14'd0 : (A_bin % B_bin);

    // Convert binary remainder back to BCD
    wire [3:0] bcd0, bcd1, bcd2, bcd3, bcd4_unused;

    binary_to_bcd_20bit b2b (
        .binary_in({6'd0, rem_bin}), // pad to 20 bits
        .bcd0(bcd0),
        .bcd1(bcd1),
        .bcd2(bcd2),
        .bcd3(bcd3),
        .bcd4(bcd4_unused)  // ignored, result always < B
    );

    assign Remainder = {bcd3, bcd2, bcd1, bcd0};
endmodule

module binary_to_bcd_20bit (
    input  [19:0] binary_in,
    output [3:0]  bcd0, // LSD
    output [3:0]  bcd1,
    output [3:0]  bcd2,
    output [3:0]  bcd3,
    output [3:0]  bcd4  // MSD
);
    integer i;
    reg [39:0] shift_reg;

    always @(*) begin
        shift_reg = 40'd0;
        shift_reg[19:0] = binary_in;

        for (i = 0; i < 20; i = i + 1) begin
            if (shift_reg[23:20] >= 5) shift_reg[23:20] = shift_reg[23:20] + 3;
            if (shift_reg[27:24] >= 5) shift_reg[27:24] = shift_reg[27:24] + 3;
            if (shift_reg[31:28] >= 5) shift_reg[31:28] = shift_reg[31:28] + 3;
            if (shift_reg[35:32] >= 5) shift_reg[35:32] = shift_reg[35:32] + 3;
            if (shift_reg[39:36] >= 5) shift_reg[39:36] = shift_reg[39:36] + 3;
            shift_reg = shift_reg << 1;
        end
    end

    assign bcd0 = shift_reg[23:20];
    assign bcd1 = shift_reg[27:24];
    assign bcd2 = shift_reg[31:28];
    assign bcd3 = shift_reg[35:32];
    assign bcd4 = shift_reg[39:36];
endmodule