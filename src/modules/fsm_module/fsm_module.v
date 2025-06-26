module fsm_module (clk, key_code, data_ready, reset_in, data_out);
    input wire clk, data_ready, reset_in;
    input wire [3:0] key_code;
    output reg [15:0] data_out;

    // Import constants
    `include "../../constants.vh"

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
    reg [14:0] lhs;
    reg [14:0] rhs;
    reg [14:0] result;
    reg [2:0] op;

    // Inputs
    reg CE;
    reg EQUAL;
    reg IS_NUM;
    reg IS_OP;

    always @(*) begin
        CE = key_code == KEY_CE;
        EQUAL = key_code == KEY_EQUAL;
        IS_NUM = (( key_code[1:0] != 2'b11 ) && (key_code[3:2] != 2'b11)) || key_code == KEY_0;
        // Chequea que no este en la columna 3, en la fila 3 o que sea 0
        IS_OP = !CE && !EQUAL && !IS_NUM;
    end

    reg [2:0] state = NUM_INIT;

    // Concat Module
    wire error;
    wire [13:0] concat_result;
    reg [3:0] digit;
    reg [1:0] op_code;
    reg [13:0] concat_input;
    concat_module #(.BIT_SIZE(14)) concat_mod (concat_input, digit, concat_result, error);
    reg concat;
    
    // ALU registers
    reg suma;
    reg resta;
    reg mult;
    reg div;
    wire alu_error;

    // ALU Modules
    // sumador
    wire sum_overflow;
    wire [13:0] sum_result;
    sumador #(.BITS(14)) sumador_mod (lhs, rhs, sum_result, sum_overflow);

    // restador
    wire signo_resta;
    wire [13:0] resta_result;
    restador #(.BITS(14)) restador_mod (lhs, rhs, resta_result, signo_resta);

    // multiplicador
    wire mult_out_of_range;
    wire [13:0] mult_result;
    multiplicador #(.BITS(14)) multiplicador_mod (lhs, rhs, resta_result, mult_out_of_range);

    // Synchronous logic
    reg [2:0] newState = NUM_INIT;
    always @(posedge clk) begin
        // State transitions
        if (reset_in)
            state <= NUM_INIT;
        else
            state <= newState;
        // Concatenations
        if (concat) begin
            result <= concat_result;
            concat <= 0;
        end
        if (suma) begin
            result <= sum_result;
            suma <= 0;
        end
        if (resta) begin
            result <= resta_result;
            resta <= 0;
        end
        if (mult) begin
            result <= mult_result;
            mult <= 0;
        end
        if (div) begin
            // TODO: division
            mult <= 0;
        end
    end

    // Extract number value
    always @(*) begin
        case (key_code)
            KEY_1:   digit = 4'd1;
            KEY_2:   digit = 4'd2;
            KEY_3:   digit = 4'd3;
            KEY_4:   digit = 4'd4;
            KEY_5:   digit = 4'd5;
            KEY_6:   digit = 4'd6;
            KEY_7:   digit = 4'd7;
            KEY_8:   digit = 4'd8;
            KEY_9:   digit = 4'd9;
            KEY_0:   digit = 4'd0;
            KEY_A:   op_code = SUMA;
            KEY_B:   op_code = RESTA;
            KEY_C:   op_code = MULT;
            KEY_D:   op_code = DIV;
            default: digit = 4'd0;
        endcase
    end

    // Combinational logic: determine next state
    always @(*) begin
        newState = state;

        case (state)
            NUM_INIT: begin
                if (CE || EQUAL || IS_OP)
                    newState = NUM_INIT;
                else if (IS_NUM) begin
                    newState = LHS;
                    lhs = digit;
                end
            end
            LHS: begin
                if (IS_NUM) begin
                    newState = LHS;
                    concat_input = lhs;
                    concat = 1;
                end
                else if (EQUAL) begin
                    result = lhs;
                    newState = RESULT;
                end
                else if (IS_OP) begin
                    newState = NUM_RHS;
                    op = op_code;
                end
            end
            NUM_RHS: begin
                if (IS_OP) begin
                    newState = NUM_RHS;
                    op = op_code;
                end
                else if (IS_NUM) begin
                    newState = RHS;
                    rhs = digit;
                end
                else if (EQUAL) begin
                    newState = RESULT;
                    result = lhs;
                end
            end

            RHS: begin
                if (IS_OP)
                    // TODO: Ver este caso
                    newState = NUM_RHS;
                else if (IS_NUM) begin
                    newState = RHS;
                    concat = 1;
                    concat_input = rhs;
                end
                else if (EQUAL) begin
                    case (op)
                        SUMA: suma = 1;
                        RESTA: resta = 1;
                        MULT: mult = 1;
                        DIV: default:
                    endcase
                    newState = RESULT;
                end
            end
            RESULT: begin
                if (IS_OP) begin
                    newState = NUM_RHS;
                    lhs = result;
                    op = op_code;
                end
                else if (IS_NUM) begin
                    newState = LHS;
                    lhs = digit;
                end
                else if (EQUAL) begin
                    newState = RESULT;
                    lhs = result;
                    // TODO: Hacer que cuando pongo igual repita la operacion anterior. Ej 1+1= -> Ans + 1 = Result;
                end
            end
            default: newState = NUM_INIT;
        endcase
    end
endmodule