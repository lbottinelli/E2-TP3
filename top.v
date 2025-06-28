module top (
    // Pines de display
    output wire gpio_2,
    output wire gpio_4,
    output wire gpio_45,
    output wire gpio_46,
    output wire gpio_47,

    // Pines de teclado
    output wire gpio_28,
    output wire gpio_38,
    output wire gpio_42,
    output wire gpio_36,
    input wire gpio_43,
    input wire gpio_34,
    input wire gpio_37,
    input wire gpio_31
);
    reg rstn;
    wire clk;

    // Internal oscilator
    SB_HFOSC HFOSC_mod(.CLKHFPU(1), .CLKHFEN(1), .CLKHF(clk)); defparam HFOSC_mod.CLKHF_DIV = "0b10";

    
    wire [15:0] data;
    assign gpio_45 = 1'b0;
    fsm_module fsm(.clk(clk), .reset_in(0), .data_out(data),
    .gpio_2(gpio_2),
    .gpio_4(gpio_4), 
    .gpio_46(gpio_46), 
    .gpio_47(gpio_47), 
    .gpio_28(gpio_28),
    .gpio_38(gpio_38),
    .gpio_42(gpio_42),
    .gpio_36(gpio_36),
    .gpio_43(gpio_43),
    .gpio_34(gpio_34),
    .gpio_37(gpio_37),
    .gpio_31(gpio_31)
    );

endmodule