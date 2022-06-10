`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//
// STM32 programmer for CPE333 final project.
//
// 
//////////////////////////////////////////////////////////////////////////////////


module STM32_programmer(
    input CLK,
    input [9:0] progData,
    input RST,
    input memWrite,
    input memRead1,
    input memRead2,
    input [31:0] addr2,
    input [31:0] din2,
    input [1:0] size,
    input sign,
    output logic prog_RST,
    output logic prog_memWrite,
    output logic prog_memRead1,
    output logic prog_memRead2,
    output logic [31:0] prog_addr2,
    output logic [31:0] prog_din2,
    output logic [1:0] prog_size,
    output logic prog_sign
    );

/********** Programmer Signals **********/
logic [7:0] data_in;
logic CS, ENA;
assign data_in = progData[7:0];
assign CS = progData[8];
assign ENA = progData[9];

/********** Programmer Register Signals **********/
logic INTERN_ADDR2_INC = 0;
logic INTERN_ADDR2_RST = 0;
logic [31:0] INTERN_ADDR2 = 0;

/********** FSM Signals **********/
logic [3:0] S0, S1, S2, S3, S4, S5, S6, S7, NS;
logic [3:0] PS = 0;
assign S0 = 4'b0000;
assign S1 = 4'b0001;
assign S2 = 4'b0010;
assign S3 = 4'b0011;
assign S4 = 4'b0100;
assign S5 = 4'b0101;
assign S6 = 4'b0110;
assign S7 = 4'b0111;

always_ff @ (posedge CLK)
    begin
        PS = NS;
        if (INTERN_ADDR2_INC == 1)
            INTERN_ADDR2 += 1;
        else if (INTERN_ADDR2_RST == 1)
            INTERN_ADDR2 = 0;
    end

always_comb
    begin
        INTERN_ADDR2_INC = 0;
        INTERN_ADDR2_RST = 0;
        case(PS)
        
                S0:
                    begin
                            prog_RST        = RST;
                            prog_memWrite   = memWrite;
                            prog_memRead1   = memRead1;
                            prog_memRead2   = memRead2;
                            prog_addr2      = addr2;
                            prog_din2       = din2;
                            prog_size       = size;
                            prog_sign       = sign;
                            if (CS == 1)
                                NS = S1;
                            else
                                NS = S0;
                    end
                
                S1:
                    begin
                            prog_RST        = 0;
                            prog_memWrite   = 0;
                            prog_memRead1   = 0;
                            prog_memRead2   = 0;
                            prog_addr2      = INTERN_ADDR2;
                            prog_din2       = {24'h000000,data_in};
                            prog_size       = 0;
                            prog_sign       = 0;
                            if (ENA == 1)
                                NS = S2;
                            else
                                NS = S1;
                    end
                
                S2:
                    begin
                            prog_RST        = 0;
                            prog_memWrite   = 1;
                            prog_memRead1   = 0;
                            prog_memRead2   = 0;
                            prog_addr2      = INTERN_ADDR2;
                            prog_din2       = {24'h000000,data_in};
                            prog_size       = 0;
                            prog_sign       = 0;
                            if (ENA == 1)
                                NS = S2;
                            else
                                NS = S3;
                    end
                
                S3:
                    begin
                            prog_RST        = 0;
                            prog_memWrite   = 0;
                            prog_memRead1   = 0;
                            prog_memRead2   = 0;
                            prog_addr2      = INTERN_ADDR2;
                            prog_din2       = {24'h000000,data_in};
                            prog_size       = 0;
                            prog_sign       = 0;
                            INTERN_ADDR2_INC = 1;
                            NS = S4;
                    end
                
                S4:
                    begin
                            prog_RST        = 0;
                            prog_memWrite   = 0;
                            prog_memRead1   = 0;
                            prog_memRead2   = 0;
                            prog_addr2      = INTERN_ADDR2;
                            prog_din2       = {24'h000000,data_in};
                            prog_size       = 0;
                            prog_sign       = 0;
                            if ((CS == 1) && (ENA == 0))
                                NS = S4;
                            else if ((CS == 1) && (ENA == 1))
                                NS = S2;
                            else
                                NS = S5;
                    end
                
                S5:
                    begin
                            prog_RST        = 1;
                            prog_memWrite   = 0;
                            prog_memRead1   = 0;
                            prog_memRead2   = 0;
                            prog_addr2      = INTERN_ADDR2;
                            prog_din2       = {24'h000000,data_in};
                            prog_size       = 0;
                            prog_sign       = 0;
                            INTERN_ADDR2_RST = 1;
                            NS = S0;
                    end
                
                default:
                    begin
                            prog_RST        = RST;
                            prog_memWrite   = memWrite;
                            prog_memRead1   = memRead1;
                            prog_memRead2   = memRead2;
                            prog_addr2      = addr2;
                            prog_din2       = din2;
                            prog_size       = size;
                            prog_sign       = sign;
                            if (ENA == 1)
                                NS = S1;
                            else
                                NS = S0;
                    end
        
        endcase
    end

endmodule
