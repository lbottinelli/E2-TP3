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
    wire data_ready;
    input wire reset_in;
    wire [3:0] key_code;
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
    reg [14:0] lhs_;
    reg [14:0] rhs;
    reg [14:0] result;
    reg [2:0] op;

    // Inputs
    reg CE;
    reg EQUAL;
    reg IS_NUM;
    reg IS_OP;

    // always @(key_code) begin
        // CE = key_code == KEY_CE;
        // EQUAL = key_code == KEY_EQUAL;
        // IS_NUM = (( key_code[1:0] != 2'b11 ) && (key_code[3:2] != 2'b11)) || key_code == KEY_0;
        // // Chequea que no este en la columna 3, en la fila 3 o que sea 0
        // IS_OP = !CE && !EQUAL && !IS_NUM;

        // case (key_code)
        //     KEY_1:   digit <= 4'd1;
        //     KEY_2:   digit <= 4'd2;
        //     KEY_3:   digit <= 4'd3;
        //     KEY_4:   digit <= 4'd4;
        //     KEY_5:   digit <= 4'd5;
        //     KEY_6:   digit <= 4'd6;
        //     KEY_7:   digit <= 4'd7;
        //     KEY_8:   digit <= 4'd8;
        //     KEY_9:   digit <= 4'd9;
        //     KEY_0:   digit <= 4'd0;
        //     KEY_A:   op_code <= SUMA;
        //     KEY_B:   op_code <= RESTA;
        //     KEY_C:   op_code <= MULT;
        //     KEY_D:   op_code <= DIV;
        //     default: digit <= 4'd0;
        // endcase
    // end

    reg [2:0] state = NUM_INIT;

    teclado_matrix teclado_mod(clk, reset_in,
    {gpio_36,
    gpio_42,
    gpio_38,
    gpio_28},
    {gpio_31,
    gpio_37,
    gpio_34,
    gpio_43}, key_code, data_ready);

    // Display module
    display_module display_mod(.VALUE_BIN(16'd1234), .internal_clock(clk), .VALUE_SIGNAL(gpio_46), .ENABLE_SIGNAL(gpio_2), .BOARD_CLOCK_SIGNAL(gpio_4), .DATA_CLOCK_SIGNAL(gpio_47));

    // // Concat Module
    wire error;
    wire [13:0] concat_result;
    reg [3:0] digit;
    reg [1:0] op_code;
    reg [13:0] concat_input;
    concat_module #(.BIT_SIZE(14)) concat_mod (concat_input, digit, concat_result, error);
    reg concat = 0;
    
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
    sumador #(.BITS(15)) sumador_mod (lhs_, rhs, sum_result, sum_overflow);

    // restador
    wire signo_resta;
    wire [14:0] resta_result;
    restador #(.BITS(15)) restador_mod (lhs_, rhs, resta_result, signo_resta);

    // multiplicador
    wire mult_out_of_range;
    wire [14:0] mult_result;
    multiplicador #(.BITS(15)) multiplicador_mod (lhs_, rhs, resta_result, mult_out_of_range);

    // Synchronous logic
    reg [2:0] newState = LHS;
    always @(posedge clk) begin
        // State transitions
        if (reset_in)
            state <= NUM_INIT;
        else
            state <= newState;
    end

    // // Extract number value
    // always @(key_code) begin
    //     case (key_code)
    //         KEY_1:   digit <= 4'd1;
    //         KEY_2:   digit <= 4'd2;
    //         KEY_3:   digit <= 4'd3;
    //         KEY_4:   digit <= 4'd4;
    //         KEY_5:   digit <= 4'd5;
    //         KEY_6:   digit <= 4'd6;
    //         KEY_7:   digit <= 4'd7;
    //         KEY_8:   digit <= 4'd8;
    //         KEY_9:   digit <= 4'd9;
    //         KEY_0:   digit <= 4'd0;
    //         KEY_A:   op_code <= SUMA;
    //         KEY_B:   op_code <= RESTA;
    //         KEY_C:   op_code <= MULT;
    //         KEY_D:   op_code <= DIV;
    //         default: digit <= 4'd0;
    //     endcase
    // end


        // // Concatenations
        // if (concat) begin
        //     // if (state == LHS)
        //     //     lhs <= concat_result;
        //     // else
        //     //     rhs <= concat_result;
        //     concat <= 0;
        // end
        // if (suma) begin
        //     result <= sum_result;
        //     suma <= 0;
        // end
        // if (resta) begin
        //     result <= resta_result;
        //     resta <= 0;
        // end
        // if (mult) begin
        //     result <= mult_result;
        //     mult <= 0;
        // end
        // if (div) begin
        //     // TODO: division
        //     mult <= 0;
        // end


    // Combinational logic: determine next state
    always @(*) begin
        CE = key_code == KEY_CE;
        EQUAL = key_code == KEY_EQUAL;
        IS_NUM = (( key_code[1:0] != 2'b11 ) && (key_code[3:2] != 2'b11)) || key_code == KEY_0;
        // Chequea que no este en la columna 3, en la fila 3 o que sea 0
        IS_OP = !CE && !EQUAL && !IS_NUM;
        digit <= 0;
        op_code <= 0;
        case (key_code)
            KEY_1:   digit <= 4'd1;
            KEY_2:   digit <= 4'd2;
            KEY_3:   digit <= 4'd3;
            KEY_4:   digit <= 4'd4;
            KEY_5:   digit <= 4'd5;
            KEY_6:   digit <= 4'd6;
            KEY_7:   digit <= 4'd7;
            KEY_8:   digit <= 4'd8;
            KEY_9:   digit <= 4'd9;
            KEY_0:   digit <= 4'd0;
            KEY_A:   op_code <= SUMA;
            KEY_B:   op_code <= RESTA;
            KEY_C:   op_code <= MULT;
            KEY_D:   op_code <= DIV;
            default: digit <= 4'd0;
        endcase
    end
    always @(*) begin
    
        newState <= state;

        lhs_ <= 0;
        case (state)
            NUM_INIT: begin
                if (CE) begin
                    newState <= NUM_INIT;
                    lhs_ <= 0;
                    rhs <= 0;
                    result <= 0;
                end
                else if (EQUAL || IS_OP)
                    newState <= NUM_INIT;
                else if (IS_NUM) begin
                    newState <= LHS;
                    lhs_ <= digit;
                end
                display_out <= lhs_;
            end
            // LHS: begin
            //     if (CE) begin
            //         newState = NUM_INIT;
            //         lhs = 0;
            //         rhs = 0;
            //         result = 0;
            //     end
            //     if (IS_NUM) begin
            //         newState = LHS;
            //         lhs = (lhs) + digit;
            //     end
            //     else if (EQUAL) begin
            //         result = lhs;
            //         newState = RESULT;
            //     end
            //     else if (IS_OP) begin
            //         newState = NUM_RHS;
            //         op = op_code;
            //     end
            //     display_out = lhs;
            // end
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