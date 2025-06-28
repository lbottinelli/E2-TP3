module fsm_module (clk, reset_in, data_out,

    // Display
    gpio_2,
    gpio_4,
    gpio_46,
    gpio_47,

    // Teclado
    gpio_28,
    gpio_38,
    gpio_42,
    gpio_36,
    gpio_43,
    gpio_34,
    gpio_37,
    gpio_31
);
    input wire clk;
    input wire reset_in;
    reg key_pressed;
    reg [3:0] key_code;
    output reg [15:0] data_out;
    output wire gpio_2, gpio_4, gpio_46, gpio_47;
    reg [15:0] display_out;

    // Teclado
    output wire gpio_28, gpio_38, gpio_42, gpio_36;
    input wire gpio_43, gpio_34, gpio_37, gpio_31;

    // Import constants
    `include "constants.vh"

    // Define Functions
    parameter KEY_CE = KEY_ASS;
    parameter KEY_EQUAL = KEY_HASH;

    // States
    parameter NUM_INIT = 3'b000;
    parameter LHS = 3'b001;
    parameter NUM_RHS = 3'b010;
    parameter RHS = 3'b011;
    parameter RESULT = 3'b100;
    
    // Data Storage
    reg [15:0] lhs;
    reg [15:0] rhs;
    reg [15:0] result;
    reg [2:0] op_code;

    // Inputs
    reg CE;
    reg EQUAL;
    reg IS_NUM;
    reg IS_OP;
    wire [3:0] new_key_code;
    wire first_key_pressed;
    reg second_key_pressed;

    reg [2:0] state = NUM_INIT;
    teclado_matrix teclado_mod(clk, reset_in,
    {gpio_36,
    gpio_42,
    gpio_38,
    gpio_28},
    {gpio_31,
    gpio_37,
    gpio_34,
    gpio_43}, new_key_code, first_key_pressed);

    // Display module
    display_module display_mod(.VALUE_BCD(display_out), .internal_clock(clk), .VALUE_SIGNAL(gpio_46), .ENABLE_SIGNAL(gpio_2), .BOARD_CLOCK_SIGNAL(gpio_4), .DATA_CLOCK_SIGNAL(gpio_47));

    reg [3:0] digit;

    // ALU registers
    reg suma;
    reg resta;
    reg mult;
    reg div;
    wire alu_error;

    // ALU Modules
    // sumador
    wire sum_overflow;
    wire [14:0] sum_result;
    sumador #(.BITS(15)) sumador_mod (lhs, rhs, sum_result, sum_overflow);

    // restador
    wire signo_resta;
    wire [14:0] resta_result;
    restador #(.BITS(15)) restador_mod (lhs, rhs, resta_result, signo_resta);

    // multiplicador
    wire mult_out_of_range;
    wire [14:0] mult_result;
    multiplicador #(.BITS(15)) multiplicador_mod (lhs, rhs, resta_result, mult_out_of_range);

    // Synchronous logic
    reg [2:0] newState = LHS;
    always @(posedge clk) begin
        // State transitions
        if (reset_in)
            state <= NUM_INIT;
        else
            state <= newState;
        display_out <= new_display_out;
        lhs <= new_lhs;
        rhs <= new_rhs;
        result <= new_result;
        digit <= new_digit;
        op_code <= new_op_code;
        key_code <= new_key_code;
        second_key_pressed <= first_key_pressed;
        key_pressed <= second_key_pressed;
    end

    reg [15:0] new_lhs;
    reg [15:0] new_rhs;
    reg [15:0] new_result;
    reg [15:0] new_display_out;
    reg [3:0] new_digit;
    reg [2:0] new_op_code;

    // Combinational logic
    always @(*) begin
        CE <= key_pressed && (key_code == KEY_CE);
        EQUAL <= key_pressed && (key_code == KEY_EQUAL);
        IS_NUM <= key_pressed && ((( key_code[1:0] != 2'b11 ) && (key_code[3:2] != 2'b11)) || key_code == KEY_0);
        // Chequea que no este en la columna 3, en la fila 3 o que sea 0
        IS_OP <= key_pressed && (!CE && !EQUAL && !IS_NUM);

        new_digit <= digit;
        new_op_code <= op_code;
        new_lhs <= lhs;
        new_rhs <= rhs;
        new_display_out <= display_out;

        case (key_code)
            KEY_1:   new_digit <= 4'd1;
            KEY_2:   new_digit <= 4'd2;
            KEY_3:   new_digit <= 4'd3;
            KEY_4:   new_digit <= 4'd4;
            KEY_5:   new_digit <= 4'd5;
            KEY_6:   new_digit <= 4'd6;
            KEY_7:   new_digit <= 4'd7;
            KEY_8:   new_digit <= 4'd8;
            KEY_9:   new_digit <= 4'd9;
            KEY_0:   new_digit <= 4'd0;
            KEY_A:   new_op_code <= SUMA;
            KEY_B:   new_op_code <= RESTA;
            KEY_C:   new_op_code <= MULT;
            KEY_D:   new_op_code <= DIV;
            default: new_digit <= 4'd0;
        endcase
    
        newState <= state;

        case (state)
            NUM_INIT: begin
                if (CE) begin
                    newState <= NUM_INIT;
                    new_lhs <= 0;
                    new_rhs <= 0;
                    new_result <= 0;
                end
                else if (EQUAL || IS_OP)
                    newState <= NUM_INIT;
                else if (IS_NUM) begin
                    newState <= LHS;
                    new_lhs <= digit;
                end
                new_display_out <= lhs;
            end
            LHS: begin
                if (CE) begin
                    newState <= NUM_INIT;
                    new_lhs <= 0;
                    new_rhs <= 0;
                    new_result <= 0;
                end
                else if (IS_NUM) begin
                    newState <= LHS;
                    new_lhs <= lhs << 4;
                    new_lhs[3:0] <= digit;
                end
                else if (EQUAL) begin
                    new_result <= lhs;
                    newState <= RESULT;
                end
                else if (IS_OP) begin
                    newState <= NUM_RHS;
                    new_op_code <= op_code;
                end
                new_display_out <= lhs;
            end
            // NUM_RHS: begin
            //     if (CE) begin
            //         newState = NUM_INIT;
            //         lhs = 0;
            //         rhs = 0;
            //         result = 0;
            //     end
            //     if (IS_OP) begin
            //         newState = NUM_RHS;
            //         op = op_code;
            //     end
            //     else if (IS_NUM) begin
            //         newState = RHS;
            //         rhs = digit;
            //     end
            //     else if (EQUAL) begin
            //         newState = RESULT;
            //         result = lhs;
            //     end
            //     display_out = rhs;
            // end

            // RHS: begin
            //     if (CE) begin
            //         newState = NUM_INIT;
            //         lhs = 0;
            //         rhs = 0;
            //         result = 0;
            //     end
            //     if (IS_OP)
            //         // TODO: Ver este caso
            //         newState = NUM_RHS;
            //     else if (IS_NUM) begin
            //         newState = RHS;
            //         concat = 1;
            //         concat_input = rhs;
            //     end
            //     else if (EQUAL) begin
            //         case (op)
            //             SUMA: suma = 1;
            //             RESTA: resta = 1;
            //             MULT: mult = 1;
            //         endcase
            //         newState = RESULT;
            //     end
            //     display_out = rhs;
            // end
            // RESULT: begin
            //     if (CE) begin
            //         newState = NUM_INIT;
            //         lhs = 0;
            //         rhs = 0;
            //         result = 0;
            //     end
            //     if (IS_OP) begin
            //         newState = NUM_RHS;
            //         lhs = result;
            //         op = op_code;
            //     end
            //     else if (IS_NUM) begin
            //         newState = LHS;
            //         lhs = digit;
            //     end
            //     else if (EQUAL) begin
            //         newState = RESULT;
            //         lhs = result;
            //         // TODO: Hacer que cuando pongo igual repita la operacion anterior. Ej 1+1= -> Ans + 1 = Result;
            //     end
            //     display_out = result;
            // end
            default: newState <= NUM_INIT;
        endcase
    end
endmodule