`timescale 1ns/1ps

module fsm_module_tb;

reg clk, reset, enable; 

wire [3:0] out;

fsm_module fsm_dut(clk, enable, reset, out);

initial begin
    clk = 0;
    reset = 1;
    enable = 0;
end

always
    #5 clk = ~clk;

initial begin
    $dumpfile("waveform.vcd"); 
    $dumpvars(1);

    #17 reset = 0;
    #10 enable = 1;

    #200 $finish;
end
 


endmodule