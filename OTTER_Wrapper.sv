`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: J. Calllenes
//           P. Hummel
// 
// Create Date: 01/20/2019 10:36:50 AM
// Description: OTTER Wrapper (with Debounce, Switches, LEDS, and SSEG
//////////////////////////////////////////////////////////////////////////////////

module OTTER_Wrapper(
   input    CLK_100MHz,
   input    BTNL,
   input    BTNC,
   input    [7:0] JB,
   input    [1:0] JC,
   input    [15:0] SWITCHES,
   output   logic [15:0] LEDS,
   output   logic [7:0] CATHODES,
   output   logic [3:0] ANODES
   );

/********** MMI (memory mapped input) addresses **********/

localparam SWITCHES_AD =    32'h11000000;

/********** MMO (memory mapped output) addresses **********/

localparam LEDS_AD =        32'h11080000;
localparam SSEG_AD =        32'h110C0000;

/********** Signals for connecting OTTERMCU to OTTER_wrapper **********/

logic   [31:0] IOBUS_out,IOBUS_in,IOBUS_addr;
logic   [15:0]  r_SSEG, r_LEDS;
logic   IOBUS_wr, btn_rst, btn_int;
logic   [9:0] progData;
assign progData = {JC,JB};

/********** Optional CLK Divider **********/

int COUNTER = 0;
logic SCLK = 0;
always_ff @ (posedge CLK_100MHz)
    begin
        if ((SWITCHES[15] == 1) && (COUNTER >= 100000)) // Set condition to 100,000 for test-all
            COUNTER = 0;
        else if ((SWITCHES[15] == 0) && (COUNTER >= 1))
            COUNTER = 0;
        else
            COUNTER += 1;
    end
always_ff @ (posedge CLK_100MHz)
    begin
        if (COUNTER == 0)
            SCLK = ~SCLK;
    end

/********** Module Instantiations **********/

// OTTER
OTTERMCU        MCU         (   .RST(btn_rst),
                                .INTR(btn_int),
                                .CLK(SCLK),
                                .IOBUS_OUT(IOBUS_out),
                                .IOBUS_IN(IOBUS_in),
                                .IOBUS_ADDR(IOBUS_addr),
                                .IOBUS_WR(IOBUS_wr),
                                .progData(progData) );

// Seven Segment Display
SevSegDisp      SSG_DISP    (   .DATA_IN(r_SSEG),
                                .CLK(CLK_100MHz),
                                .MODE(1'b0),
                                .CATHODES(CATHODES),
                                .ANODES(ANODES) );

// One Shot Debouncer for the interrupt button
debounce_one_shot   DBint   (   .CLK(SCLK),
                                .BTN(BTNL),
                                .DB_BTN(btn_int) );

// One Shot Debouncer for the reset button
debounce_one_shot   DBrst   (   .CLK(SCLK),
                                .BTN(BTNC),
                                .DB_BTN(btn_rst) );

/********** Connections between IOBUS and MMIO **********/

always_ff @ (posedge SCLK)      // MMO
begin
    if(IOBUS_wr == 1)
        begin
        case(IOBUS_addr)
        
            LEDS_AD:        r_LEDS      <= IOBUS_out[15:0];
            SSEG_AD:        r_SSEG      <= IOBUS_out[15:0];
            
        endcase
        end
end
assign LEDS = r_LEDS;

always_comb                     // MMI
begin
    IOBUS_in=32'b0;
    case(IOBUS_addr)
    
        SWITCHES_AD:    IOBUS_in[15:0]  = SWITCHES;
        default:        IOBUS_in        = 32'b0;
        
    endcase
end

endmodule