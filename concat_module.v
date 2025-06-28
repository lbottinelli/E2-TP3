module concat_module
    #(parameter BIT_SIZE=16)
(
    input wire[BIT_SIZE-1:0] left,
    input wire[3:0] digit,
    output reg[BIT_SIZE-1:0] out,
    output reg error
);

reg [BIT_SIZE-1:0] result;
always @(*) begin
    result <= (left * 4'd10) + digit;
    error <= (result < left) ? 1'b1 : 1'b0;
    out <= result;
end

endmodule