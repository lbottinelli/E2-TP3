`timescale 1ns/1ps

module fsm_module_tb;

reg clk, reset, data_ready; 
reg [3:0] key_code;
wire [15:0] data_out;

fsm_module fsm_dut(clk, key_code, data_ready, reset, data_out);

initial begin
    clk = 0;
    reset = 1;
end

always
    #5 clk = ~clk;

initial begin
    $dumpfile("waveform.vcd"); 
    $dumpvars(1);

    #17 reset = 0;

    #200 $finish;
end
 


endmodule