`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
//
// This is the top level module for the OTTER MCU.
//
//
//////////////////////////////////////////////////////////////////////////////////


module OTTERMCU(
    input RST,
    input INTR,
    input CLK,
    input [9:0] progData,
    input [31:0] IOBUS_IN,
    output logic [31:0] IOBUS_OUT,
    output logic IOBUS_WR,
    output logic [31:0] IOBUS_ADDR
    );

logic [31:0] pc_4, jalr, branch, jal;
logic [31:0] CIS, NIS;
logic [31:0] rs1, rs2;
logic [31:0] ir;
logic [31:0] srcA, srcB, ALU_out;
logic [31:0] wd;
logic [31:0] dout2;
logic [31:0] mtvec, mepc, csr_wd;
logic [3:0] alu_fun;
logic [1:0] alu_srcB, rf_wr_sel;
logic [2:0] pcSource;
logic alu_srcA;
logic intTaken, csrWrite, mie, interrupt;
logic pcWrite, regWrite, memWrite, memRead1, memRead2;
logic br_eq, br_lt, br_ltu;
logic [31:0] UType, IType, SType, BType, JType;

/********** STM32 Programmer Signals **********/
logic prog_RST, prog_memWrite, prog_memRead1, prog_memRead2;
logic [31:0] prog_addr2, prog_din2;
logic [1:0] prog_size;
logic prog_sign;

assign interrupt = ( mie & INTR );
assign IOBUS_OUT = rs2;
assign IOBUS_ADDR = ALU_out;

STM32_programmer  STM32prog (   .CLK(CLK),
                                .progData(progData),
                                .RST(RST),
                                .memWrite(memWrite),
                                .memRead1(memRead1),
                                .memRead2(memRead2),
                                .addr2(ALU_out),
                                .din2(rs2),
                                .size(ir[13:12]),
                                .sign(ir[14]),
                                .prog_RST(prog_RST),
                                .prog_memWrite(prog_memWrite),
                                .prog_memRead1(prog_memRead1),
                                .prog_memRead2(prog_memRead2),
                                .prog_addr2(prog_addr2),
                                .prog_din2(prog_din2),
                                .prog_size(prog_size),
                                .prog_sign(prog_sign) );

OTTER_mem_byte  memory      (   .MEM_ADDR1(CIS),
                                .MEM_ADDR2(prog_addr2),
                                .MEM_CLK(CLK),
                                .MEM_DIN2(prog_din2),
                                .MEM_WRITE2(prog_memWrite),
                                .MEM_READ1(prog_memRead1),
                                .MEM_READ2(prog_memRead2),
                                .IO_IN(IOBUS_IN),
                                .ERR(),
                                .MEM_SIZE(prog_size),
                                .MEM_SIGN(prog_sign),
                                .MEM_DOUT1(ir),
                                .MEM_DOUT2(dout2),
                                .IO_WR(IOBUS_WR) );

CSR             CSR         (   .CLK(CLK),
                                .RST(prog_RST),
                                .INT_TAKEN(intTaken),
                                .ADDR(ir[31:20]),
                                .PC(CIS),
                                .WD(ALU_out),
                                .WR_EN(csrWrite),
                                .RD(csr_wd),
                                .CSR_MEPC(mepc),
                                .CSR_MTVEC(mtvec),
                                .CSR_MIE(mie) );

PC_MUX          pc_mux      (   .pc_plus_4(pc_4),
                                .jalr(jalr),
                                .branch(branch),
                                .jal(jal),
                                .mtvec(mtvec),
                                .mepc(mepc),
                                .pcSource(pcSource),
                                .NIS(NIS) );
                                
PC              pc          (   .clk(CLK),
                                .NIS(NIS),
                                .reset(prog_RST),
                                .pcWrite(pcWrite),
                                .CIS(CIS) );

PLUS_4          plus_4      (   .CIS(CIS),
                                .NIS(pc_4) );
                                
Reg_File        register    (   .adr1(ir[19:15]),
                                .adr2(ir[24:20]),
                                .wd(wd),
                                .wa(ir[11:7]),
                                .en(regWrite),
                                .clk(CLK),
                                .rs1(rs1),
                                .rs2(rs2) );
                                
MUX_4           wd_sel      (   .A(pc_4),
                                .B(csr_wd),
                                .C(dout2),
                                .D(ALU_out),
                                .SEL(rf_wr_sel),
                                .Q(wd) );

MUX_4           alu_A_in    (   .A(rs1),
                                .B(UType),
                                .C(),
                                .D(),
                                .SEL({1'b0, alu_srcA}),
                                .Q(srcA) );
                                
MUX_4           alu_B_in    (   .A(rs2),
                                .B(IType),
                                .C(SType),
                                .D(CIS),
                                .SEL(alu_srcB),
                                .Q(srcB) );
                                
ALU             alu         (   .A(srcA),
                                .B(srcB),
                                .alu_fun(alu_fun),
                                .Q(ALU_out) );

CU_FSM          cu_fsm      (   .clk(CLK),
                                .RST(prog_RST),
                                .INTR(interrupt),
                                .ir(ir),
                                .pcWrite(pcWrite),
                                .regWrite(regWrite),
                                .memWrite(memWrite),
                                .memRead1(memRead1),
                                .memRead2(memRead2),
                                .csrWrite(csrWrite),
                                .intTaken(intTaken) );
                              
CU_Decoder      cu_decoder  (   .br_eq(br_eq),
                                .br_lt(br_lt),
                                .br_ltu(br_ltu),
                                .ir(ir),
                                .intTaken(intTaken),
                                .alu_fun(alu_fun),
                                .alu_srcA(alu_srcA),
                                .alu_srcB(alu_srcB),
                                .pcSource(pcSource),
                                .rf_wr_sel(rf_wr_sel) );

Branch_CondGen  branch_gen  (   .rs1(rs1),
                                .rs2(rs2),
                                .br_eq(br_eq),
                                .br_lt(br_lt),
                                .br_ltu(br_ltu) );

Immed_Gen       immed_gen   (   .ir(ir),
                                .UType(UType),
                                .IType(IType),
                                .SType(SType),
                                .BType(BType),
                                .JType(JType) );

Target_Gen      target_gen  (   .CIS(CIS),
                                .IType(IType),
                                .BType(BType),
                                .JType(JType),
                                .rs1(rs1),
                                .jalr(jalr),
                                .branch(branch),
                                .jal(jal) );

endmodule
