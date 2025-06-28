module display_module
#(parameter WORDS = 4)
(
    VALUE_BCD,
    internal_clock,

    VALUE_SIGNAL,
    ENABLE_SIGNAL,
    BOARD_CLOCK_SIGNAL,
    DATA_CLOCK_SIGNAL
);
    input wire [4*WORDS-1:0] VALUE_BCD;
    input wire internal_clock;
    output reg VALUE_SIGNAL,ENABLE_SIGNAL, BOARD_CLOCK_SIGNAL, DATA_CLOCK_SIGNAL;

    // Define clocks
    // Display Clock
    reg [10:0] freq_counter_i;
    parameter CLK_RST = 400;
     always @(posedge internal_clock) begin
	    freq_counter_i <= freq_counter_i + 1'b1;
        if (freq_counter_i > CLK_RST) begin
            freq_counter_i <= 0;
            BOARD_CLOCK_SIGNAL <= !BOARD_CLOCK_SIGNAL;
        end
    end

    // Serial Clock
    reg [20:0] freq_counter_2;
    parameter DATA_CLK_RST = 2000;
     always @(posedge internal_clock) begin
	    freq_counter_2 <= freq_counter_2 + 1'b1;
        if (freq_counter_2 > DATA_CLK_RST) begin
            freq_counter_2 <= 0;
            DATA_CLOCK_SIGNAL <= !DATA_CLOCK_SIGNAL;
        end
    end

    wire [3:0] algo;
    wire busy,fin, RST;
    reg en = 1'b1;
    
    reg [7:0] counter = 1'b0;
    wire cnt_enable;
    reg clk_prev;
    always @(posedge internal_clock) begin 
        clk_prev <= DATA_CLOCK_SIGNAL;
    end
    assign cnt_enable = DATA_CLOCK_SIGNAL & (~clk_prev);

    always @(posedge internal_clock) begin
        if (cnt_enable == 1'd1) begin
            if(counter < 5'd16) begin
                ENABLE_SIGNAL <= 1'b1;
                VALUE_SIGNAL <= VALUE_BCD[(3 - counter%4) + (counter/4)*4];
                counter <= counter + 1;
            end
            else if (counter < 6'd32) begin
                VALUE_SIGNAL <= 1'b0;
                ENABLE_SIGNAL <= 1'b0;
                counter <= counter + 1;
            end
            else 
                counter <= 0;
        end
    end
endmodule



// module bin_a_bcd_4dig (
//     input wire clk,
//     input wire [13:0] bin,
//     output wire [15:0] salida  // 14 bits binario + 16 bits BCD
// );
//     //reg [29:0] shift_reg;
//     reg [29:0] shift_reg_pipeline [13:0];
//     reg [29:0] shift_reg_pipeline_shift [13:0];
    
//     integer i;
//     always @(posedge clk) begin
 
//         shift_reg_pipeline[0] <= {16'd0, bin};
//         shift_reg_pipeline_shift[0] <= {16'd0, bin};
//         for (i = 0; i < 14; i = i + 1) begin
//         // Suma 3 si el grupo BCD ≥ 5
//             shift_reg_pipeline[i] = shift_reg_pipeline_shift[i];
//             if (shift_reg_pipeline[i][29:26] >= 5)
//                 shift_reg_pipeline[i+1][29:26] = shift_reg_pipeline[i][29:26] + 3; // Miles
//             if (shift_reg_pipeline[i][25:22] >= 5)
//                 shift_reg_pipeline[i+1][25:22] = shift_reg_pipeline[i][25:22] + 3; // Centenas
//             if (shift_reg_pipeline[i][21:18] >= 5)
//                 shift_reg_pipeline[i+1][21:18] = shift_reg_pipeline[i][21:18] + 3; // Decenas
//             if (shift_reg_pipeline[i][17:14] >= 5)
//                 shift_reg_pipeline[i+1][17:14] = shift_reg_pipeline[i][17:14] + 3; // Unidades

//             shift_reg_pipeline_shift[i+1] = shift_reg_pipeline[i+1] << 1; // Desplazamiento
//         end

//         salida = shift_reg_pipeline_shift[14][29:14]; // BCD final
        
//     end
// endmodule

// module bin2bcd(
//    input [13:0] bin,
//    output reg [15:0] bcd
//    );
   
// integer i;
	
// always @(*) begin
//     bcd=0;		 	
//     for (i=0;i<14;i=i+1) begin					//Iterate once for each bit in input number
//         if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;		//If any BCD digit is >= 5, add three
// 	if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
// 	if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
// 	if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
// 	bcd = {bcd[14:0],bin[13-i]};				//Shift one bit, and shift in proper bit from input 
//     end
// end
// endmodule


// module bin2bcd16
//   (
//    input        CLK,
//    input        RST,

//    input        en,
//    input [15:0] bin,

//    output [3:0] bcd0,
//    output [3:0] bcd1,
//    output [3:0] bcd2,
//    output [3:0] bcd3,
//    output [3:0] bcd4,

//    output       busy,
//    output       fin
//    );

//    reg [15:0]   bin_r;
//    reg [3:0]    bitcount;
//    reg [3:0]    bcd[0:4];
//    wire [3:0]   bcdp[0:4];

//    assign bcd0 = bcd[0];
//    assign bcd1 = bcd[1];
//    assign bcd2 = bcd[2];
//    assign bcd3 = bcd[3];
//    assign bcd4 = bcd[4];

//    localparam s_idle = 2'b00;
//    localparam s_busy = 2'b01;
//    localparam s_fin  = 2'b10;
//    reg [1:0]    state;
   
//    assign busy = state != s_idle;
//    assign fin  = state == s_fin;

//    always @(posedge CLK or negedge RST)
//      if (!RST) begin
//         state <= s_idle;
//      end else begin
//         case (state)
//           s_idle: 
//             if (en)
//               state <= s_busy;

//           s_busy:
//             if (bitcount == 4'd15)
//               state <= s_fin;

//           s_fin:
//             state <= s_idle;

//           default: ;
//         endcase
//      end

//    always @(posedge CLK) begin
//       case (state)
//         s_idle: 
//           if (en)
//             bin_r <= bin;
//         s_busy:
//           bin_r <= {bin_r[14:0], 1'b0};
//         default: ;
//       endcase
//    end

//    always @(posedge CLK or negedge RST)
//      if (!RST) begin
//         bitcount <= 4'd0;
//      end else begin
//         case (state)
//           s_busy: 
//             bitcount <= bitcount + 4'd1;

//           default: 
//             bitcount <= 4'd0;
//         endcase
//      end

//    generate
//       genvar g;

//       for (g=0; g<=4; g=g+1) begin : GEN_BCD

//          wire [3:0] s;
//          wire [3:0] prev;

//          assign bcdp[g] = (bcd[g] >= 4'd5) ? bcd[g] + 4'd3 : bcd[g];

//          if (g != 0) begin
//             assign prev = bcdp[g-1];
//          end else begin // if (g != 0)
//             assign prev = {bin_r[15], 3'b0};
//          end
//          assign s 
//            = ((bcdp[g] << 1) | (prev >> 3));

//          always @(posedge CLK or negedge RST)
//            if (!RST) begin
//               bcd[g] <= 4'd0;
//            end else begin
//               case (state)
//                 s_idle: 
//                   bcd[g] <= 4'd0;

//                 s_busy:
//                   bcd[g] <= s;

//                 default: ;
//               endcase
//            end

//       end
//    endgenerate

// endmodule