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

    // Inputs

    wire CE = key_code == KEY_CE;
    wire EQUAL = key_code == KEY_EQUAL;
    wire IS_NUM = (( key_code[1:0] != 2'b11 ) && (key_code[3:2] != 2'b11)) || key_code == KEY_0;
    wire IS_OP = !CE && !EQUAL && !IS_NUM;
    // Chequea que no este en la columna 3, en la fila 3 o que sea 0

    reg [2:0] state = NUM_INIT;

    // Data Storage
    reg [13:0] lhs;
    reg [13:0] rhs;
    reg [2:0] op;

    // Handle state transitions
    reg [2:0] newState = NUM_INIT;
    // Sequential logic: update state on clock edge
    always @(posedge clk) begin
        if (reset_in)
            state <= NUM_INIT;
        else
            state <= newState;
    end

    // Combinational logic: determine next state
    always @(*) begin
        newState = state; // default: remain in current state

        case (state)
            NUM_INIT: begin
                if (CE || EQUAL)
                    newState = NUM_INIT;
                else if (IS_NUM)
                    newState = LHS;
            end
            LHS: begin
                if (IS_NUM)
                    newState = LHS;
                else if (EQUAL)
                    newState = RESULT;
                else if (IS_OP)
                    newState = NUM_RHS;
            end
            NUM_RHS: begin
                if (IS_OP)
                    newState = NUM_RHS;
                else if (IS_NUM)
                    newState = RHS;
                else if (EQUAL)
                    newState = RESULT;
            end
            RHS: begin
                if (IS_OP)
                    newState = NUM_RHS;
                else if (IS_NUM)
                    newState = RHS;
                else if (EQUAL)
                    newState = RESULT;
            end
            RESULT: begin
                if (IS_OP)
                    newState = NUM_RHS;
                else if (IS_NUM)
                    newState = LHS;
                else if (EQUAL)
                    newState = RESULT;
            end
            default: newState = NUM_INIT;
        endcase
    end
endmodule