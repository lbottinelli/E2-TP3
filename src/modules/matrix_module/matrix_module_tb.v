`timescale 1ns/10ps

module testbench;

reg clock, reset;
reg [3:0] col;
wire [3:0] key_code, row;
wire data_ready;

teclado_matrix fsm(clock, reset, row, col, key_code, data_ready);

initial begin
    clock = 1;
    reset = 1;
    col = 4'b1111;
end

always
    #5 clock = ~clock;


initial begin
    $dumpfile("waveform.vcd"); 
    $dumpvars(1);

    #10 reset = 0;

    #30 col = 4'b1110;
    #10 col = 4'b1111;


    #200 $finish;
end

endmodule