`timescale 1ns/1ps

module concat_module_tb;

reg [14:0] left;
reg [3:0] digit;
wire [14:0] result;
wire error;

concat_module #(.BIT_SIZE(15)) concat_dut (left, digit, result, error);

initial begin
    left = 4'd1;
    digit = 1'd1;
end

always
    #20 left = result;

initial begin
    $dumpfile("waveform.vcd"); 
    $dumpvars(1);

    #200 $finish;
end
 


endmodule