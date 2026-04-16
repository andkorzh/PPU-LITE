/*
 ===============================================================================================
 *                             Copyright (C) 2026  andkorzh
 *
 *
 *                This program is free software; you can redistribute it and/or
 *                modify it under the terms of the GNU General Public License
 *                as published by the Free Software Foundation; either version 2
 *                of the License, or (at your option) any later version.
 *
 *                This program is distributed in the hope that it will be useful,
 *                but WITHOUT ANY WARRANTY; without even the implied warranty of
 *                MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *                GNU General Public License for more details.
 *
 *                              2C02(7) NES P P U LITE (Cyclone I)
 *
 *   This design is inspired by Wiki BREAKNES. I tried to replicate the design of the real
 *  NMOS processor Ricoh 2C02(7) as much as possible. The Logsim 2C02(7) model was taken as the
 *  basis for the design of the circuit diagram. Dedicated to the lost web portal BREAKNES.com
 *  Our Wiki  https://github.com/emu-russia/breaks/tree/master/BreakingNESWiki/PPU
 *
 *  author andkorzh
 *  Thanks:
 *      HardWareMan: author of the concept of synchronously core NES PPU, help & support.
 *
 *      Org (ogamespec): help & support, C++ Cycle accurate model NES, Author: Wiki BREAKNES
 *
 *      Nukeykt: help & support
 *
 ===============================================================================================
*/

// module RP2C02_LITE
module RP2C02_LITE(
input Clk,         // System clock
input Clk2,        // Clock 21.477/26.601 for divider
// Inputs
input MODE,        // PAL/NTSC mode
input DENDY,       // DENDY mode (for PAL)
input ODD_EN,      // Enable ODDEVEN
input nRES,        // Reset
input PALSEL0,     // Palette select
input PALSEL1,     // Palette select
input RnW,         // External Pin Read/Write
input nDBE,        // PPU access strobe
input [2:0]A,      // Register address
input [7:0]PD,     // PPU Graphics Data Bus Input
// Outputs
inout [7:0]DB,     // CPU External Data Bus
output [17:0]RGB,  // RGB output R6 + G6 + B6
output [2:0]EMPH,  // EMPHASIS R G B
output [13:0]PAD,  // PPU Bus Address Output
output INT,        // Interrupt Request Output
output ALE,        // ALE VRAM Address Low Byte Latch Strobe Output
output nWR,        // VRAM Write Strobe
output nRD,        // VRAM Read Strobe
output SYNC,       // Composite sync output
output HSYNC,      // horizontal synchronization
output VSYNC,      // vertical synchronization
output SUBCLK      // Subcarrier clock
);
// Module connections
wire PCLK;
wire nPCLK;
wire [5:0]Hn;
wire [5:0]Hnn;
wire [7:0]DBIN;
wire [7:0]OB;
wire [3:0]OV;
wire [7:0]Vo;
wire [5:0]PIX;
wire [2:0]R2DB;
wire [4:0]THO;
wire [3:0]BGC;
wire [4:0]ZCOL;
wire [4:0]CGA;
wire W0;
wire W1;
wire R2;
wire W3;
wire W4;
wire R4;
wire W5_1;
wire W5_2;
wire W6_1;
wire W6_2;
wire W7;
wire R7;
wire R_EN;
wire CLIP_O;
wire CLIP_B;
wire I1_32;
wire OBSEL;
wire BGSEL;
wire O8_16;
wire VBL_EN;
wire B_W;
wire BGCLIP;
wire OBCLIP;
wire BLACK;
wire nCLPB;
wire CLPO;
wire S_EV;
wire O_HPOS;
wire nEVAL;
wire E_EV;
wire I_OAM2;
wire PAR_O;
wire nVIS;
wire F_NT;
wire F_AT;
wire F_TA;
wire F_TB;
wire N_FO;
wire BURST;
wire SC_CNT;
wire nPICTURE;
wire RC;
wire RESCL;
wire BLNK;
wire TSTEP;
wire PD_RB;
wire XRB;
wire TH_MUX;
wire DB_PAR;
wire TVO1;
wire OMFG;
wire PD_FIFO;
wire SPR0_EV;
wire SPR_OV;
wire nSPR0HIT;
wire SH2;
wire RPIX;

// CLK DIVIDER
CLK_DIV MOD_CLK_DIV(
Clk2,
MODE,
nRES,
PCLK,
nPCLK,
SUBCLK
);

// Register Selection Signals
REGISTER_SELECT MOD_REGISTER_SELECT(
Clk,
DB[7:0],
nDBE,
RnW,
A[2:0],
DBIN[7:0],
R_EN,
W0,
W1,
R2,
W3,
W4,
R4,
W5_1,
W5_2,
W6_1,
W6_2,
W7,
R7
);

//System registers
REG2000_2001 MOD_REG2000_2001(
Clk,
nPCLK,
W0,
W1,
RC,
DBIN[7:0],
nVIS,
CLIP_O,
CLIP_B,
MODE,
I1_32,
OBSEL,
BGSEL,
O8_16,
VBL_EN,
B_W,
BGCLIP,
OBCLIP,
BLACK,
nCLPB,
CLPO,
EMPH[2:0]
);

//Bus multiplexer on read
READBUSMUX MOD_READBUSMUX(
Clk,
PCLK,
R_EN,
R4,
OB[7:0],
RPIX,
PIX[5:0],
R2,
R2DB[2:0],
XRB,
PD_RB,
RC,
DBIN[7:0],
PD[7:0],
DB[7:0]
);

//PPU Main Timing Generator
TIMING_GENERATOR MOD_TIMING_GENERATOR(
Clk,
PCLK,
nPCLK,
MODE,
DENDY,
ODD_EN,
OBCLIP,
BGCLIP,
BLACK,
VBL_EN,
R2,
nRES,
Hn[5:0],
Hnn[5:0],
S_EV,
CLIP_O,
CLIP_B,
O_HPOS,
nEVAL,
E_EV,
I_OAM2,
PAR_O,
nVIS,
F_NT,
F_AT,
F_TA,
F_TB,
N_FO,
BURST,
SC_CNT,
SYNC,
HSYNC,
VSYNC,
nPICTURE,
RC,
RESCL,
BLNK,
INT,
R2DB[2],
Vo[7:0]
);

// PPU Local Bus Management
LOCAL_BUS_CONTROL MOD_LOCAL_BUS_CONTROL(
Clk,
PCLK,
nPCLK,
Hnn[0],
Hn[0],
R7,
W7,
BLNK,
PAD[13:8],
TSTEP,
PD_RB,
DB_PAR,
ALE,
nWR,
nRD,
XRB,
TH_MUX
);

//Background Pixel Generator
BG_COLOR MOD_BG_COLOR(
Clk,
PCLK,
nPCLK,
Hnn[0],
nCLPB,
F_AT,
F_TA,
F_TB,
N_FO,
PD[7:0],
THO[1],
TVO1,
DBIN[2:0],
W5_1,
RC,
BGC[3:0]
);

//PPU address generator
PAR_GEN MOD_PAR_GEN(
Clk,
PCLK,
nPCLK,
Hnn[0],
Hn[1],
Hn[2],
F_NT,
F_AT,
F_TB,
RC,
PAR_O,
SH2,
OV[3:0],
OB[7:0],
PD[7:0],
DBIN[7:0],
O8_16,
OBSEL,
BGSEL,
RESCL,
SC_CNT,
W0,
W5_1,
W5_2,
W6_1,
W6_2,
DB_PAR,
E_EV,
TSTEP,
I1_32,
BLNK,
PAD[13:0],
THO[4:0],
TVO1
);

//Find sprites to be output on a next line
OBJ_EVAL MOD_OBJ_EVAL(
Clk,
PCLK,
nPCLK,
Hnn[0],
Vo[7:0],
OB[7:0],
O8_16,
I_OAM2,
nVIS,
SPR_OV,
F_NT,
S_EV,
PAR_O,
OV[3:0],
OMFG,
PD_FIFO,
SPR0_EV
);

//Sprite Memory Management
OAM MOD_OAM(
Clk,
PCLK,
nPCLK,
Hnn[0],
Hn[0],
Hn[2],
BLNK,
nVIS,
W3,
W4,
I_OAM2,
nEVAL,
PAR_O,
OMFG,
RESCL,
DBIN[7:0],
OB[7:0],
R2DB[0],
SPR_OV
);

//Sprite FIFO
OBJ_FIFO MOD_OBJ_FIFO(
Clk,
PCLK,
nPCLK,
Hnn[5:0],
O_HPOS,
PAR_O,
CLPO,
nVIS,
PD_FIFO,
PD[7:0],
OB[7:0],
nSPR0HIT,
SH2,
ZCOL[4:0]
);

//Pixel multiplexer
PIX_MUX MOD_PIX_MUX(
Clk,
PCLK,
nPCLK,
BGC[3:0],
ZCOL[4:0],
THO[4:0],
nVIS,
SPR0_EV,
nSPR0HIT,
RESCL,
TH_MUX,
CGA[4:0],
R2DB[1]
);

//Palette module
PALETTE MOD_PALETTE(
Clk,
PCLK,
nPCLK,
R7,
TH_MUX,
nPICTURE,
B_W,
DB_PAR,
CGA[4:0],
DBIN[5:0],
PALSEL0,
PALSEL1,
RPIX,
PIX[5:0],
RGB[17:0]
);
// End of module RP2C02_LITE
endmodule

//===============================================================================================
// CLK DIVIDER Module
//===============================================================================================
module CLK_DIV(
input Clk2,          // MASTER clock
// Inputs
input MODE,          // PAL/NTSC mode
input nRES,          // Reset
// Outputs
output  PCLK,        //  PIXEL CLOCK
output nPCLK,        // ~PIXEL CLOCK
output reg SUBCLK    // Subcarrier clock
);
// Variables
reg DIV2n;
reg [2:0]DIV;
reg [1:0]SUB;
// Combinatorics
assign PCLK  =   DIV[2] | DIV2n | (~MODE & DIV[1]);
assign nPCLK = ~(DIV[2] | DIV2n | (~MODE & DIV[1]));
// Logics
always @(posedge Clk2) begin
        // PCLK DIVIDER
        DIV[2:0] <= { DIV[1] & MODE, DIV[0], ~( ~nRES | DIV[2] | DIV[1] )};
        // SUBCARRIER DIVIDER
        {SUBCLK, SUB[1:0]} <= {SUB[1:0], ~( SUBCLK | ~nRES )};
                        end
always @(negedge Clk2) begin
         DIV2n <= DIV[1] & MODE;
                        end
endmodule

//===============================================================================================
// Register Selection Module
//===============================================================================================
module REGISTER_SELECT(
input Clk,             // System clock
// Inputs
input [7:0]DB,         // Input data from CPU
input nDBE,            // PPU access strobe
input RnW,             // R/W circulation direction
input [2:0]A,          // Register address
// Outputs
output reg [7:0]DBIN,  // PPU Register Open Bus
output R_EN,           // CPU Data Bus Tristate Management
output reg W0,         // Write to register     $2000
output reg W1,         // Write to register     $2001
output reg R2,         // Reading from register $2002
output reg W3,         // Write to register     $2003
output reg W4,         // Write to register     $2004
output reg R4,         // Reading from register $2004
output reg W5_1,       // Write to register     $2005/1
output reg W5_2,       // Write to register     $2005/2
output reg W6_1,       // Write to register     $2006/1
output reg W6_2,       // Write to register     $2006/2
output reg W7,         // Write to register     $2007
output reg R7          // Reading from register $2007
);
// Variables
reg [2:0]ADR;
reg RnWR;
reg nDBER;
reg DWR1, DWR2;
// Combinatorics
assign R_EN = RnWR & ~nDBER;
// Logics
always @(posedge Clk) begin
        ADR[2:0] <= A[2:0];
        RnWR <= RnW;
        nDBER <= nDBE;
        W0   <= ~ADR[2] & ~ADR[1] & ~ADR[0] & ~RnWR & ~nDBER;
        W1   <= ~ADR[2] & ~ADR[1] &  ADR[0] & ~RnWR & ~nDBER;
        R2   <= ~ADR[2] &  ADR[1] & ~ADR[0] &  RnWR & ~nDBER;
        W3   <= ~ADR[2] &  ADR[1] &  ADR[0] & ~RnWR & ~nDBER;
        R4   <=  ADR[2] & ~ADR[1] & ~ADR[0] &  RnWR & ~nDBER;
        W4   <=  ADR[2] & ~ADR[1] & ~ADR[0] & ~RnWR & ~nDBER;
        W5_1 <=  ADR[2] & ~ADR[1] &  ADR[0] & ~RnWR & ~nDBER &  DWR2;
        W5_2 <=  ADR[2] & ~ADR[1] &  ADR[0] & ~RnWR & ~nDBER & ~DWR2;
        W6_1 <=  ADR[2] &  ADR[1] & ~ADR[0] & ~RnWR & ~nDBER &  DWR2;
        W6_2 <=  ADR[2] &  ADR[1] & ~ADR[0] & ~RnWR & ~nDBER & ~DWR2;
        R7   <=  ADR[2] &  ADR[1] &  ADR[0] &  RnWR & ~nDBER;
        W7   <=  ADR[2] &  ADR[1] &  ADR[0] & ~RnWR & ~nDBER;

        if (R2) DWR1 <= 1'b1;
   else if (  W5_1 | W5_2 | W6_1 | W6_2)  DWR1 <= ~DWR2;
        if (R2) DWR2 <= 1'b1;
   else if (~(W5_1 | W5_2 | W6_1 | W6_2)) DWR2 <=  DWR1;
        if (~nDBE & ~RnW) DBIN[7:0] <= DB[7:0];
                      end
endmodule

//===============================================================================================
// System register module
//===============================================================================================
module REG2000_2001(
input Clk,           // System clock
input nPCLK,         // Pixel clock
// Inputs
input W0,            // Write to register $2000
input W1,            // Write to register $2001
input RC,            // Clearing registers
input [7:0]DBIN,     // PPU Register Open Bus
input nVIS,          // Visible part of the line
input CLIP_O,        // Blanking the left column of 8 screen pixels for sprites
input CLIP_B,        // Blanking the left column of 8 screen dots for the
input MODE,          // PAL/NTSC mode
// Outputs
output reg I1_32,    // PPU address increment +1/+32
output reg OBSEL,    // MSB addresses of the sprite character generator
output reg BGSEL,    // MSB addresses of the character generator background
output reg O8_16,    // Sprite height (0 - 8 points, 1 - 16 points)
output VBL_EN,       // Enable VBlank Interrupt
output B_W,          // B/W mode (zeroing the lower 4 bits of the color index)
output reg BGCLIP,   // Controls the blanking of the left 8 background dots
output reg OBCLIP,   // Controls the blanking of the left 8 sprite dots
output BLACK,        // Disabling rendering
output nCLPB,        // Disabling background
output CLPO,         // Disabling sprites
output [2:0]EMPH     // Emphasis B, G, R
);
// Variables
reg [4:0]W0R;
reg [7:0]W1R;
reg nVISR;
reg CLIPBR, CLIPOR;
reg BGE, OBE;
reg EMP_R, EMP_G;
// Combinatorics
assign BLACK = ~( BGE | OBE );
assign VBL_EN = W0R[4];
assign B_W    = W1R[0];
assign nCLPB = ~( ~BGE | nVISR | CLIPBR );
assign CLPO = ~CLIPOR;
wire EM_R, EM_G;
assign EM_R = (MODE) ? EMP_G : EMP_R; // For PAL Red/green color emphasis swapped.
assign EM_G = (MODE) ? EMP_R : EMP_G; // For PAL Red/green color emphasis swapped.
assign EMPH[0] = EM_R   ? 1'b0 : 1'hZ;
assign EMPH[1] = EM_G   ? 1'b0 : 1'hZ;
assign EMPH[2] = W1R[7] ? 1'b0 : 1'hZ;
// Logics
always @(posedge Clk) begin
         if (W0) W0R[4:0] <= RC ? 1'b0 : {DBIN[7],DBIN[5:2]};
         if (W1) W1R[7:0] <= RC ? 1'b0 : DBIN[7:0];
         if (~W0) {O8_16, BGSEL, OBSEL, I1_32} <= W0R[3:0];
         if (~W1) {EMP_G, EMP_R, OBE, BGE, OBCLIP, BGCLIP} <= W1R[6:1];
         if (nPCLK) begin
         nVISR  <= nVIS;
         CLIPBR <= CLIP_B;
         CLIPOR <= ~( CLIP_O | ~OBE | nVISR );
                    end
                      end
// End of system register module
endmodule

//===============================================================================================
// Bus multiplexer module when reading
//===============================================================================================
module READBUSMUX(
input Clk,        // System clock
input PCLK,       // Pixel clock
// Inputs
input R_EN,       // CPU Data Bus Tristate Management
input R4,         // $2004 Reading Selection
input [7:0]OB,    // Sprite data bus
input RPIX,       // Selecting RAM data palette
input [5:0]PIX,   // RAM data palette
input R2,         // $2002 Reading Selection
input [2:0]R2DB,  // $2002 data
input XRB,        // VRAM Read Selection
input PD_RB,      // VRAM Bus Bridge Strobe
input RC,         // Clearing registers
input [7:0]DBIN,  // PPU Register Open Bus
input [7:0]PD,    // PPU Graphics Data Bus
// Outputs
output [7:0]DB    // Output data for reading PPU from CPU side
);
// Variables
reg [7:0]PD_R;
reg [7:0]OB_R;
reg [7:0]Do;
// Combinatorics
wire [7:0]D;
assign D[7:0]  = ( R2 | R4 | RPIX | XRB ) ? Do[7:0] : DBIN[7:0];
assign DB[7:0] = R_EN ? D[7:0] : 8'hZZ; // tristate for reading mode
// Logics
always @(posedge Clk) begin
       if (PCLK)  OB_R[7:0] <= OB[7:0];
       if (RC)    PD_R[7:0] <= 8'h00;
  else if (PD_RB) PD_R[7:0] <= PD[7:0];
       Do[7:0] <= ({8{R4}} & OB_R[7:0]) | ({8{RPIX}} & {DBIN[7:6],PIX[5:0]}) | ({8{R2}} & {R2DB[2:0],DBIN[4:0]}) | ({8{XRB}} & PD_R[7:0]);
                       end
endmodule

//===============================================================================================
// PPU Main Timing Generator Module
//===============================================================================================
module TIMING_GENERATOR(
input Clk,           // System clock
input PCLK,          // Pixel clock
input nPCLK,         // Pixel clock
// Inputs
input MODE,          // PAL mode
input DENDY,         // DENDY mode
input ODD_EN,        // Enable ODDEVEN
input OBCLIP,        // Controls the blanking of the left 8 sprite dots
input BGCLIP,        // Controls the blanking of the left 8 background dots
input BLACK,         // Disabling rendering
input	VBL_EN,        // Enable VBlank Interrupt Request
input R2,            // Reading register $2002
input nRES,          // PPU Master Reset
// Outputs
output reg[5:0]Hn,   // Synchronized state of the PPU
output reg[5:0]Hnn,  // Synchronized state of the PPU
output reg S_EV,     // Starting the sprite list view process
output CLIP_O,       // Left column blanking 8 dots at sprite
output CLIP_B,       // Left column blanking 8 dots at background
output reg O_HPOS,   // Starting sprite X coordinate counters (0 sprite position)
output reg nEVAL,    // Reset OAM2 counter and start OAM2 processing
output reg E_EV,     // End of the process of viewing the list and comparing sprites
output reg I_OAM2,   // OAM2 Initialization (Clear) Signal
output reg PAR_O,    // Fetch sprite graphics
output reg nVIS,     // Visible part of the line sprites
output reg F_NT,     // Reading tile number from Name Table
output F_AT,         // Phase of fetching attributes from Name Table
output F_TA,         // First byte tile fetch phase
output F_TB,         // Second tile byte fetch phase
output N_FO,         // Activate graphics shift
output BURST,        // Color Subcarrier Sync Burst Output Mask
output SC_CNT,       // Starting the address counter when raster and/or background are
output SYNC,         // Composite sync output
output HSYNCo,       // horizontal synchronization
output VSYNCo,       // vertical synchronization
output nPICTURE,     // Blanking
output reg RC,       // Clearing registers
output reg RESCL,    // Prerender line (reset all fetch schemes)
output BLNK,         // Rendering is disabled
output INT,          // interrupt on VBLANK
output reg R2DB7,    // Reading INT flag
output [7:0]Vo       // Vertical counter output (for sprite machine)
);
// Variables
reg HC, VC_LATCH;
reg [1:0]ODDEVEN;
reg FPORCH_FF;
reg SEV_IN;
reg CLIP_OUT, CLIP1, CLIP2;
reg HPOS_IN;
reg EVAL_IN;
reg EEV_IN;
reg IOAM2_IN;
reg PARO_IN;
reg NVIS_IN;
reg FNT_IN;
reg FTB_IN, FTB_OUT;
reg FTA_IN, FTA_OUT;
reg NFO_OUT, NFO1, NFO2;
reg FAT_IN;
reg BURST_FF, BURST_OUT;
reg N_HB;
reg VSYNC_FF;
reg HSYNC;
reg VSYNC;
reg BPORCH_FF;
reg PEN_FF, PICT1, PICT2;
reg RESCL_IN;
reg BLNK_FF;
reg VB_FF;
reg [2:0]VSET;
reg INT_FF;
// Combinatorics
assign CLIP_O = ~( CLIP_OUT | OBCLIP );
assign CLIP_B = ~( CLIP_OUT | BGCLIP );
// HV COUNTERS CONTROL
wire [8:0]H, V, HCout, VCout;
wire VC, HIN5;
assign HIN5 = H[4] & H[3] & H[2] & H[1] & H[0];
assign VC = HC | ~VC_LATCH;
// HV COUNTERS
//                Clk   F2    DIR                   C_IN                  Reset     LOAD     STEP   DATA   CNT_OUT   C_OUT
COUNTER HCNT[8:0](Clk, nPCLK, 1'b1, {HCout[7:5], HIN5, HCout[3:0], 1'b1}, ~nRES, ~HC & PCLK, PCLK, 9'h000, H[8:0], HCout[8:0]);
COUNTER VCNT[8:0](Clk, nPCLK, 1'b1, {VCout[7:0], H_LINE23},               ~nRES, ~VC & PCLK, PCLK, 9'h000, V[8:0], VCout[8:0]);
//HV PLA (NTSC/PAL)
wire H_LINE0, H_LINE1, H_LINE2, H_LINE5, H_LINE6, H_LINE7, H_LINE17, H_LINE18;
wire H_LINE20, H_LINE21, H_LINE22, H_LINE23;
wire V_LINE0N, V_LINE0P, V_LINE1N, V_LINE1P, V_LINE2N, V_LINE2P;
wire V_LINE3N, V_LINE3P, V_LINE4, V_LINE5, VLINE241, VLINE291, VLINE311;
assign H_LINE0  = ~( ~H[8] |  H[7] |  H[6] |  H[5] | ~H[4] |  H[3] | ~H[2] | ~H[1] | ~H[0] );                  // H279
assign H_LINE1  = ~( ~H[8] |  H[7] |  H[6] |  H[5] |  H[4] |  H[3] |  H[2] |  H[1] |  H[0] );                  // H256
assign H_LINE2  = ~(  BLNK |  H[8] |  H[7] | ~H[6] |  H[5] |  H[4] |  H[3] |  H[2] |  H[1] | ~H[0] );          // H065
assign H_LINE5  = ~(  BLNK | ~H[8] |  H[7] | ~H[6] |  H[5] | ~H[4] |  H[3] |  H[2] | ~H[1] | ~H[0] );          // H339
assign H_LINE6  = ~(  BLNK |  H[8] |  H[7] |  H[6] | ~H[5] | ~H[4] | ~H[3] | ~H[2] | ~H[1] | ~H[0] );          // H063
assign H_LINE7  = ~(  BLNK | ~H[7] | ~H[6] | ~H[5] | ~H[4] | ~H[3] | ~H[2] | ~H[1] | ~H[0] );                  // H255
assign H_LINE17 = ~( ~H[8] |  H[7] |  H[6] |  H[5] |  H[4] |  H[3] |  H[2] | ~H[1] |  H[0] );                  // H258
assign H_LINE18 = ~(  H[8] |  H[7] |  H[6] |  H[5] |  H[4] |  H[3] |  H[2] | ~H[1] |  H[0] );                  // H002
assign H_LINE20 = ~( ~H[8] |  H[7] |  H[6] | ~H[5] | ~H[4] |  H[3] |  H[2] |  H[1] |  H[0] );                  // H304
assign H_LINE21 = ~( ~H[8] |  H[7] | ~H[6] |  H[5] |  H[4] |  H[3] |  H[2] | ~H[1] | ~H[0] );                  // H323
assign H_LINE22 = ~( ~H[8] |  H[7] |  H[6] | ~H[5] | ~H[4] |  H[3] | ~H[2] |  H[1] |  H[0] );                  // H308
assign H_LINE23 = ~( ~H[8] |  H[7] | ~H[6] |  H[5] | ~H[4] |  H[3] | ~H[2] |  H[1] |  H[0] );                  // H340
assign V_LINE0N = ~( ~V[7] | ~V[6] | ~V[5] | ~V[4] |  V[3] | ~V[2] | ~V[1] | ~V[0] |  MODE );                  // V247 NTSC
assign V_LINE0P = ~( ~V[8] |  V[7] |  V[6] |  V[5] | ~V[4] |  V[3] |  V[2] |  V[1] |  V[0] | ~MODE );          // V272 PAL
assign V_LINE1N = ~( ~V[7] | ~V[6] | ~V[5] | ~V[4] |  V[3] | ~V[2] |  V[1] |  V[0] |  MODE );                  // V244 NTSC
assign V_LINE1P = ~( ~V[8] |  V[7] |  V[6] |  V[5] |  V[4] | ~V[3] | ~V[2] |  V[1] | ~V[0] | ~MODE );          // V269 PAL
assign V_LINE2N = ~( ~V[8] |  V[7] |  V[6] |  V[5] |  V[4] |  V[3] | ~V[2] |  V[1] | ~V[0] |  MODE );          // V261 NTSC
assign V_LINE2P = ~(  V[8] |  V[7] |  V[6] |  V[5] |  V[4] |  V[3] |  V[2] |  V[1] |  V[0] | ~MODE );          // V000 PAL
assign V_LINE3N = ~( ~V[7] | ~V[6] | ~V[5] | ~V[4] |  V[3] |  V[2] |  V[1] | ~V[0] |  MODE );                  // V241 NTSC
assign V_LINE3P = ~( ~V[7] | ~V[6] | ~V[5] | ~V[4] |  V[3] |  V[2] |  V[1] |  V[0] | ~MODE );                  // V240 PAL
assign V_LINE4  = ~(  V[8] |  V[7] |  V[6] |  V[5] |  V[4] |  V[3] |  V[2] |  V[1] |  V[0] );                  // V000
assign V_LINE5  = ~( ~V[7] | ~V[6] | ~V[5] | ~V[4] |  V[3] |  V[2] |  V[1] |  V[0] );                          // V240
assign VLINE241 = ~( ~V[7] | ~V[6] | ~V[5] | ~V[4] |  V[3] |  V[2] |  V[1] | ~V[0] | ~MODE | DENDY );          // V241 PAL INT
assign VLINE291 = ~( ~V[8] |  V[7] |  V[6] | ~V[5] |  V[4] |  V[3] |  V[2] | ~V[1] | ~V[0] | ~MODE | ~DENDY ); // V291 DENDY INT
assign VLINE311 = ~( ~V[8] |  V[7] |  V[6] | ~V[5] | ~V[4] |  V[3] | ~V[2] | ~V[1] | ~V[0] | ~MODE );          // V311 PAL
//FETCH CONTROL
assign F_TB = ~( FTB_OUT | NFO_OUT );
assign F_TA = ~( FTA_OUT | NFO_OUT );
assign N_FO = ~NFO_OUT;
assign F_AT = ~( ~FAT_IN | ~( NFO1 | NFO2 ));
//Outputs
assign BURST = ~( BURST_OUT | ~SYNC );
assign SC_CNT = ~( ~N_HB | BLACK );
assign HSYNCo = HSYNC;
assign VSYNCo = VSYNC_FF;
assign SYNC = HSYNC | VSYNC;
assign nPICTURE = PICT1 | PICT2;
assign BLNK = BLACK | BLNK_FF;
assign Vo[7:0] = V[7:0];
assign INT = VBL_EN & INT_FF;
// Logics
always @(posedge Clk) begin
         if (~nRES) ODDEVEN[0] <= 1'b0;
    else if ( V[8]) ODDEVEN[0] <=  ODDEVEN[1];
         if (~V[8]) ODDEVEN[1] <= ~ODDEVEN[0];
         if (N_HB) begin
         if (V_LINE1N | V_LINE1P) VSYNC_FF <= 1'b1;
    else if (V_LINE0N | V_LINE0P) VSYNC_FF <= 1'b0;
                    end
         if (~nRES) RC <= 1'b1;
    else if (RESCL) RC <= 1'b0;
         if (RESCL | R2)                      INT_FF <= 1'b0;
    else if (~( nPCLK | ~VSET[0] | VSET[2] )) INT_FF <= 1'b1;
         if (~R2) R2DB7 <= INT_FF;
         if (PCLK) begin
         Hnn[5:0]  <=  Hn[5:0];
         S_EV      <=  SEV_IN;
         CLIP_OUT  <= ~( CLIP1 | ~CLIP2 );
         O_HPOS    <=  HPOS_IN;
         nEVAL     <= ~( HPOS_IN | EVAL_IN | EEV_IN );
         E_EV      <=  EEV_IN;
         I_OAM2    <=  IOAM2_IN;
         PAR_O     <=  PARO_IN;
         nVIS      <= ~NVIS_IN;
         F_NT      <=  FNT_IN;
         FTB_OUT   <= ~FTB_IN;
         FTA_OUT   <= ~FTA_IN;
         NFO_OUT   <= ~( NFO1 | NFO2 );
         BURST_OUT <=  BURST_FF;
         HSYNC     <= ~FPORCH_FF;
         VSYNC     <= ~( N_HB | VSYNC_FF );
         PICT1     <=  BPORCH_FF;
         PICT2     <=  PEN_FF;
         RESCL     <=  RESCL_IN;
         VSET[1]   <= ~VSET[0];
                    end
         if (nPCLK) begin
         HC        <= ~( H_LINE23 | ( H_LINE5 & ~ODDEVEN[0] & RESCL & ~MODE & ODDEVEN ));
         VC_LATCH  <= V_LINE2N | VLINE311;
         Hn[5:0]   <= H[5:0];
         SEV_IN    <= H_LINE2;
         CLIP1     <= ~( H[7] | H[6] | H[5] | H[4] | H[3] );
         CLIP2     <= ~( H[8] | ~VB_FF );
         HPOS_IN   <= H_LINE5;
         EVAL_IN   <= H_LINE6;
         EEV_IN    <= H_LINE7;
         IOAM2_IN  <= ~( BLNK |  H[8] |  H[7] |  H[6] );
         PARO_IN   <= ~( BLNK | ~H[8] |  H[7] |  H[6] );
         NVIS_IN   <= ~( BLNK |  H[8] | ~VB_FF );
         FNT_IN    <= ~( BLNK |  H[2] |  H[1] );
         FTB_IN    <= ~( ~H[2]| ~H[1] );
         FTA_IN    <= ~( ~H[2]|  H[1] );
         NFO1      <= ~( BLNK | ~H[8] | ~H[6] | H[5] | H[4]);
         NFO2      <= ~( BLNK |  H[8] );
         FAT_IN    <= ~(  H[2]| ~H[1] );
         if (H_LINE0)  FPORCH_FF <= 1'b1;
    else if (H_LINE1)  FPORCH_FF <= 1'b0;
         if (H_LINE21) BURST_FF  <= 1'b1;
    else if (H_LINE22) BURST_FF  <= 1'b0;
         if (H_LINE0 ) N_HB      <= 1'b1;
    else if (H_LINE20) N_HB      <= 1'b0;
         if (H_LINE17) BPORCH_FF <= 1'b1;
    else if (H_LINE18) BPORCH_FF <= 1'b0;
         if (V_LINE3N | V_LINE3P)  PEN_FF  <= 1'b1;
    else if (V_LINE2N | V_LINE2P)  PEN_FF  <= 1'b0;
         if (V_LINE5)              BLNK_FF <= 1'b1;
    else if (V_LINE2N | VLINE311)  BLNK_FF <= 1'b0;
         if (V_LINE4)  VB_FF   <= 1'b1;
    else if (V_LINE5)  VB_FF   <= 1'b0;
         RESCL_IN <= V_LINE2N | VLINE311;
         VSET[0]  <= V_LINE3N | VLINE291 | VLINE241; // activating the interrupt queue
         VSET[2]  <= ~VSET[1];
                end
                      end
// End of PPU Main Timing Generator Module
endmodule

//===============================================================================================
// Local Bus Control Module PPU
//===============================================================================================
module LOCAL_BUS_CONTROL(
input Clk,       // System clock
input PCLK,      // Pixel clock
input nPCLK,     // Pixel clock
// Inputs
input Hnn0,      // Synchronized state of the PPU
input Hn0,       // Synchronized state of the PPU
input R7,        // Reading from register $2007
input W7,        // Write to register $2007
input BLNK,      // Rendering is disabled
input [13:8]PAD, // PPU bus high addresses
// Outputs
output TSTEP,    // Increment PPU address counters
output PD_RB,    // Data to PD bus read latch
output DB_PAR,   // Forwarding CPU data to PPU bus
output ALE,      // ALE signal
output nWR,      // write activate
output nRD,      // read activate
output XRB,      // PD data on CPU bus
output TH_MUX    // Palette range
);
// Variables
reg W7_FF, R7_FF;
reg [4:0]R7Q;
reg [4:0]W7Q;
reg BLNK_LATCH;
reg TSTEP_LATCH;
// Combinatorics
assign TH_MUX = PAD[13] & PAD[12] & PAD[11] & PAD[10] & PAD[9] & PAD[8] & BLNK_LATCH;
assign TSTEP  = PD_RB | TSTEP_LATCH;
assign PD_RB  = ~( ~R7Q[4] | R7Q[2] );
assign DB_PAR = ~(  W7Q[3] | W7Q[1] );
assign nWR = ~DB_PAR | TH_MUX;
assign nRD = ~( PD_RB | ( Hnn0 & ~BLNK ));
assign XRB = ~( ~R7 | TH_MUX );
assign ALE = ~( R7Q[4] | ~R7Q[2] ) | ~( W7Q[4] | ~W7Q[2] ) | ~( nPCLK | Hn0 | BLNK );
// Logics
always @(posedge Clk) begin
         if (~R7Q[3]) R7_FF <= 1'b0;
    else if (R7)      R7_FF <= 1'b1;
         if (~W7Q[3]) W7_FF <= 1'b0;
    else if (W7)      W7_FF <= 1'b1;
         if (PCLK) begin
         BLNK_LATCH  <= BLNK;
         TSTEP_LATCH <= DB_PAR;
         {R7Q[4], R7Q[2], R7Q[0]} <= {~R7Q[3], R7Q[1], R7_FF & ~R7};
         {W7Q[4], W7Q[2], W7Q[0]} <= {~W7Q[3], W7Q[1], W7_FF & ~W7};
                    end
         if (nPCLK) begin
         {R7Q[3], R7Q[1]} <= {~R7Q[2], R7Q[0]};
         {W7Q[3], W7Q[1]} <= {~W7Q[2], W7Q[0]};
                    end
                       end
// End of Local Bus Control Module PPU
endmodule

//===============================================================================================
// Background Pixel Generator Module
//===============================================================================================
module BG_COLOR(
input Clk,        // System clock
input PCLK,       // Pixel clock
input nPCLK,      // Pixel clock
// Inputs
input Hnn0,       // Synchronized state of the PPU
input nCLPB,      // Background is off
input F_AT,       // Attribute Fetching Phase
input F_TA,       // First byte tile fetch phase
input F_TB,       // Second tile byte fetch phase
input N_FO,       // Activate graphics shift
input [7:0]PD,    // PPU Graphics Data Bus
input THO1,       // Horizontal coordinate in attribute
input TVO1,       // Vertical coordinate in attribute
input [2:0]DBIN,  // PPU Register Open Bus
input W5_1,       // Write to the fine horizontal scroll register $2005.1
input RC,         // Clearing registers
// Outputs
output [3:0]BGC   // Background pixel output
);
// Variables
reg [3:0]BGC1;
reg [3:0]BGC2;
reg [2:0]FH;
reg CLPB_LATCH;
reg F_AT_LATCH;
reg THO1R;
reg [7:0]PDAT;
reg [7:0]PDTA;
reg [1:0]ATR;
reg [1:0]ATRO;
// Combinatorics
wire PD_SR, PD_SEL, SRLOAD, STEP, STEP2, NEXT;
assign PD_SR  = nPCLK & Hnn0 & F_TA;
assign PD_SEL = nPCLK & Hnn0 & F_AT_LATCH;
assign SRLOAD = nPCLK & Hnn0 & F_TB;
assign STEP   = nPCLK & N_FO & ~( Hnn0 & F_TB );
assign STEP2  = nPCLK & N_FO;
assign NEXT   = ~( nPCLK | STEP | STEP2 );
wire [1:0]ATSEL;
assign ATSEL[0] = ( PDAT[0] & ~THO1R & ~TVO1 )|( PDAT[2] & THO1R & ~TVO1 )|( PDAT[4] & ~THO1R & TVO1 )|( PDAT[6] & THO1R & TVO1 );
assign ATSEL[1] = ( PDAT[1] & ~THO1R & ~TVO1 )|( PDAT[3] & THO1R & ~TVO1 )|( PDAT[5] & ~THO1R & TVO1 )|( PDAT[7] & THO1R & TVO1 );
// Background Pixel Shift Registers
wire QTA, QTB, QT0, QT1, QT2, QT3; // QT0 - QT3 - not used
wire[7:0]SR0, SR1, SR2, SR3;
//                  Clk  SIn     STEP   NEXT  LOAD    P DATA In  PAROut    SEROut
SHIFTREG SREG_TA  ( Clk, 1'b1,   STEP,  NEXT, SRLOAD, PDTA[7:0],         , QTA );
SHIFTREG SREG_TB  ( Clk, 1'b1,   STEP,  NEXT, SRLOAD, PD[7:0]  ,         , QTB );
SHIFTREG SREG_FS0 ( Clk, QTA,    STEP2, NEXT, 1'h0,   8'h00    , SR0[7:0], QT0 );
SHIFTREG SREG_FS1 ( Clk, QTB,    STEP2, NEXT, 1'h0,   8'h00    , SR1[7:0], QT1 );
SHIFTREG SREG_FS2 ( Clk, ATR[0], STEP2, NEXT, 1'h0,   8'h00    , SR2[7:0], QT2 );
SHIFTREG SREG_FS3 ( Clk, ATR[1], STEP2, NEXT, 1'h0,   8'h00    , SR3[7:0], QT3 );
wire [3:0]BGC_POS;
assign BGC_POS[3:0] = (~FH[0] & ~FH[1] & ~FH[2]) ? {SR3[7], SR2[7], SR1[7], SR0[7]} :
                      ( FH[0] & ~FH[1] & ~FH[2]) ? {SR3[6], SR2[6], SR1[6], SR0[6]} :
                      (~FH[0] &  FH[1] & ~FH[2]) ? {SR3[5], SR2[5], SR1[5], SR0[5]} :
                      ( FH[0] &  FH[1] & ~FH[2]) ? {SR3[4], SR2[4], SR1[4], SR0[4]} :
                      (~FH[0] & ~FH[1] &  FH[2]) ? {SR3[3], SR2[3], SR1[3], SR0[3]} :
                      ( FH[0] & ~FH[1] &  FH[2]) ? {SR3[2], SR2[2], SR1[2], SR0[2]} :
                      (~FH[0] &  FH[1] &  FH[2]) ? {SR3[1], SR2[1], SR1[1], SR0[1]} :
                      ( FH[0] &  FH[1] &  FH[2]) ? {SR3[0], SR2[0], SR1[0], SR0[0]} :
                                                                               4'h0 ;
assign BGC[3:0] = BGC2[3:0] & { 4 { CLPB_LATCH }};
// Logics
always @(posedge Clk) begin
      if (PD_SR)  PDTA[7:0] <= PD[7:0];
      if (PD_SEL) PDAT[7:0] <= PD[7:0];
      if (RC)       FH[2:0] <= 3'h0;
 else if (W5_1)     FH[2:0] <= DBIN[2:0];
      if (SRLOAD) ATRO[1:0] <= ATSEL[1:0];
      if (NEXT)    ATR[1:0] <= ATRO[1:0];
      if (PCLK) begin
      CLPB_LATCH <= nCLPB;
      F_AT_LATCH <= F_AT;
      THO1R <= THO1;
      BGC2[3:0] <= BGC1[3:0];
                 end
      if (nPCLK) BGC1[3:0] <= BGC_POS[3:0];
                       end
// End of background pixel generator module
endmodule

//===============================================================================================
// PPU Address Generator Module
//===============================================================================================
module PAR_GEN(
input Clk,            // System clock
input PCLK,           // Pixel clock
input nPCLK,          // Pixel clock
// Inputs
input Hnn0,           // Synchronized state of the PPU
input Hn1,            // Synchronized state of the PPU
input Hn2,            // Synchronized state of the PPU
input F_NT,           // Reading tile number from Name Table
input F_AT,           // Attribute Fetching Phase
input F_TB,           // Second tile byte fetch phase
input RC,             // Clearing registers
input PAR_O,          // Fetch sprite graphics
input SH2,            // Sprite attribute reading phase
input [3:0]OV,        // Sprite graphic line number
input [7:0]OB,        // Sprite data bus
input [7:0]PD,        // PPU Graphics Data Bus
input [7:0]DBIN,      // PPU Register Open Bus
input O8_16,          // Sprite height (0 - 8 points, 1 - 16 points)
input OBSEL,          // MSB addresses of objects
input BGSEL,          // MSB background addresses
input RESCL,          // Prerender line (reset all fetch schemes)
input SC_CNT,         // Starting the address counter when raster and/or background
input W0,             // Write to register $2000
input W5_1,           // Write to register $2005.1
input W5_2,           // Write to register $2005.2
input W6_1,           // Write to register $2006.1
input W6_2,           // Write to register $2006.2
input DB_PAR,         // Forwarding CPU data to PPU bus
input E_EV,           // End of the process of viewing the list and comparing sprites
input TSTEP,          // Increment PPU address counters
input I1_32,          // PPU address increment +1/+32
input BLNK,           // Rendering is disabled
// Outputs
output reg [13:0]PAD, // VRAM Address/Data Output
output [4:0]THO,      // Tile counter output
output TVO1           // Vertical coordinate in attribute
);
// Variables
reg TAL_LATCH;
reg VINV_LATCH;
reg [3:0]OVR;
reg [3:0]OVOUT;
reg [7:0]PDIN;
reg [7:0]PDOUT;
reg [7:0]OBOUT;
reg [11:0]TP;
reg [4:0]TH;
reg [4:0]TV;
reg NTH, NTV;
reg [2:0]FV;
reg [1:0]EEVR;
reg SCCNTR;
reg [1:0]Z_TV;
reg TVZR;
reg W62_FF;
reg [1:0]W62;
reg TV_IN;
// Combinatorics
wire [3:0]OBJ_INV;
assign OBJ_INV[3:0] = {4{ VINV_LATCH }} ^ OVOUT[3:0];
// Address counters control
wire THLOAD, TVLOAD, THSTEP, TVSTEP, ZTV;
assign THLOAD = ~( ~( EEVR[1] | W62[1] )  | PCLK );
assign TVLOAD = ~( ~(( SCCNTR & RESCL )| W62[1] ) | PCLK );
assign THSTEP = ~( ~(( F_TB & Hnn0 )  | TSTEP )| PCLK );
assign TVSTEP = ~( ~( E_EV   | TSTEP )| PCLK  );
assign ZTV = ~( Z_TV[0] | Z_TV[1] );
wire TH_IN, NTH_IN, NTV_IN, FV_IN;
assign TH_IN = ~( I1_32 & BLNK );
assign NTH_IN =   THZ | TVZB;
assign NTV_IN =   TVZ | ( BLNK & NTHC );
assign FV_IN  = ~BLNK | ( BLNK & NTVC );
wire THZ, THZB, TVZ, TVZB, FVZ;
assign THZ  = THO[4] & THO[3] & THO[2] &  THO[1] & THO[0] & ~BLNK;
assign THZB = THO[4] & THO[3] & THO[2] &  THO[1] & THO[0] &  BLNK;
assign TVZ  = TVO[4] & TVO[3] & TVO[2] & ~TVO[1] & TVO[0] & ~BLNK & TV_IN;
assign TVZB = TVO[4] & TVO[3] & TVO[2] &  TVO[1] & TVO[0] &  BLNK & TV_IN;
assign FVZ  = FVO[2] & FVO[1] & FVO[0] & ~BLNK   & FV_IN ;
wire [4:0]TVO, THOCout, TVOCout;
wire NTHDO, NTVDO, NTHC, NTVC;
wire [2:0]FVO, FVOCout;
//PAR COUNTERS
// TH COUNTER
//                  Clk   F2   DIR              C_IN        Reset   LOAD    STEP   DATA    CNT_OUT     C_OUT
COUNTER THCNT[4:0] (Clk, PCLK, 1'b1, {THOCout[3:0], TH_IN}, 1'b0, THLOAD, THSTEP, TH[4:0], THO[4:0], THOCout[4:0]);
// TV COUNTER
COUNTER TVCNT[4:0] (Clk, PCLK, 1'b1, {TVOCout[3:0], TV_IN}, ZTV,  TVLOAD, TVSTEP, TV[4:0], TVO[4:0], TVOCout[4:0]);
// NTH COUNTER
COUNTER NTHCNT     (Clk, PCLK, 1'b1,                NTH_IN, 1'b0, THLOAD, THSTEP, NTH,     NTHDO,    NTHC);
// NTV COUNTER
COUNTER NTVCNT     (Clk, PCLK, 1'b1,                NTV_IN, 1'b0, TVLOAD, TVSTEP, NTV,     NTVDO,    NTVC);
// FV COUNTER
COUNTER FVCNT[2:0] (Clk, PCLK, 1'b1, {FVOCout[1:0], FV_IN}, 1'b0, TVLOAD, TVSTEP, FV[2:0], FVO[2:0], FVOCout[2:0]);
// VRAM address multiplexer
wire BFVO0, NBFVO1;
assign BFVO0  =  BLNK & FVO[0];
assign NBFVO1 = ~BLNK | FVO[1];
wire PARR;
assign PARR =  Hn2 & ~BLNK;
wire [13:0]PAMUX;  // Picture address multiplexer
assign PAMUX[7:0]  = DB_PAR ? DBIN[7:0] : PARR ? {TP[6:3],Hn1,TP[2:0]} : F_AT ? {2'b11,TVO[4:2],THO[4:2]} : {TVO[2:0],THO[4:0]};
assign PAMUX[13:8] = PARR ? {1'b0,TP[11:7]} : {NBFVO1,BFVO0,NTVDO,NTHDO, F_AT ? 2'b11 : TVO[4:3]};
assign TVO1 = TVO[1];
// Logics
always @(posedge Clk) begin
      if (W6_2 | W5_1 | RC) TH[0] <= RC ? 1'b0 : (W6_2 & DBIN[0]) | (W5_1 & DBIN[3]);
      if (W6_2 | W5_1 | RC) TH[1] <= RC ? 1'b0 : (W6_2 & DBIN[1]) | (W5_1 & DBIN[4]);
      if (W6_2 | W5_1 | RC) TH[2] <= RC ? 1'b0 : (W6_2 & DBIN[2]) | (W5_1 & DBIN[5]);
      if (W6_2 | W5_1 | RC) TH[3] <= RC ? 1'b0 : (W6_2 & DBIN[3]) | (W5_1 & DBIN[6]);
      if (W6_2 | W5_1 | RC) TH[4] <= RC ? 1'b0 : (W6_2 & DBIN[4]) | (W5_1 & DBIN[7]);
      if (W6_2 | W5_2 | RC) TV[0] <= RC ? 1'b0 : (W6_2 & DBIN[5]) | (W5_2 & DBIN[3]);
      if (W6_2 | W5_2 | RC) TV[1] <= RC ? 1'b0 : (W6_2 & DBIN[6]) | (W5_2 & DBIN[4]);
      if (W6_2 | W5_2 | RC) TV[2] <= RC ? 1'b0 : (W6_2 & DBIN[7]) | (W5_2 & DBIN[5]);
      if (W6_1 | W5_2 | RC) TV[3] <= RC ? 1'b0 : (W6_1 & DBIN[0]) | (W5_2 & DBIN[6]);
      if (W6_1 | W5_2 | RC) TV[4] <= RC ? 1'b0 : (W6_1 & DBIN[1]) | (W5_2 & DBIN[7]);
      if (W6_1 | W0   | RC) NTH   <= RC ? 1'b0 : (W6_1 & DBIN[2]) | (W0   & DBIN[0]);
      if (W6_1 | W0   | RC) NTV   <= RC ? 1'b0 : (W6_1 & DBIN[3]) | (W0   & DBIN[1]);
      if (W6_1 | W5_2 | RC) FV[0] <= RC ? 1'b0 : (W6_1 & DBIN[4]) | (W5_2 & DBIN[0]);
      if (W6_1 | W5_2 | RC) FV[1] <= RC ? 1'b0 : (W6_1 & DBIN[5]) | (W5_2 & DBIN[1]);
      if (W6_1 | W5_2 | RC) FV[2] <= RC ? 1'b0 : (W6_1 & 1'b0   ) | (W5_2 & DBIN[2]);
      if ( PCLK & SH2 ) VINV_LATCH <= OB[7];
      TV_IN <= THZB | FVZ | ( I1_32 & BLNK );
      if (~( nPCLK | TAL_LATCH )) begin
      OVOUT[3:0] <= OVR[3:0];
      OBOUT[7:0] <= OB[7:0];
      PDOUT[7:0] <= PDIN[7:0];
                                   end
      if (nPCLK & W62[1]) W62_FF <= 1'b0;
 else if (W6_2)           W62_FF <= 1'b1;
      if (PCLK) begin
      TVZR   <= TVZ;
      EEVR[1]  <= EEVR[0];
      SCCNTR <= SC_CNT;
      W62[1]  <= W62[0];
      PAD[13:0]  <= PAMUX[13:0];
                 end
      if (nPCLK) begin
      TAL_LATCH <= ~F_NT | ~Hnn0;
      OVR[3:0]  <= OV[3:0];
      PDIN[7:0] <= PD[7:0];
      TP[2:0]   <= (PAR_O) ? OBJ_INV[2:0] : FVO[2:0] ;
      TP[3]     <= (PAR_O) ? ((O8_16)   ? OBJ_INV[3] : OBOUT[0] ) : PDOUT[0];
      TP[10:4]  <= (PAR_O) ? OBOUT[7:1] : PDOUT[7:1] ;
      TP[11]    <= (PAR_O) ? ((O8_16)   ? OBOUT[0]   : OBSEL )    : BGSEL;
      Z_TV[1:0] <= {~TVZR, ~TVSTEP};
      EEVR[0]   <= E_EV;
      W62[0]    <= W62_FF & ~W6_2;  // W$2006.2 EDGE DET
                  end
                      end
// End of PPU Address Generator Module
endmodule

//===============================================================================================
// Module for searching sprites to be output on a next line
//===============================================================================================
module OBJ_EVAL(
input Clk,           // System clock
input PCLK,          // Pixel clock
input nPCLK,         // Pixel clock
// Inputs
input Hnn0,          // Synchronized state of the PPU
input [7:0]V,        // Vertical counter output (for sprite machine)
input [7:0]OB,       // Sprite data bus
input O8_16,         // Sprite height (0 - 8 points, 1 - 16 points)
input I_OAM2,        // OAM2 Initialization (Clear) Signal
input nVIS,          // Visible part of the line
input SPR_OV,        // OAM counter is full or more than 8 sprites found
input F_NT,          // Reading tile number from Name Table
input S_EV,          // Starting the sprite list view process
input PAR_O,         // Fetch sprite graphics
// Outputs
output [3:0]OV,      // Sprite graphic line number
output OMFG,         // Signal to copy the current comparison sprite in OAM2
output reg PD_FIFO,  // OBJ FIFO Input Blocking
output reg SPR0_EV   // Sprite #0 is on the current line
);
// Variables
reg [5:0]CLATCH;
reg SPR0_EV1;
reg [1:0]PDFIFO;
reg [7:0]OBLATCH;
// Combinatorics
wire [7:0]OVS;
assign OVS[7:0] = V[7:0] - OBLATCH[7:0];
wire OVZ;
assign OVZ = ( CLATCH[5] | CLATCH[3] | CLATCH[1] ) | ( OVS[7] | OVS[6] ) | OVS[5] | OVS[4] | ( ~O8_16 & OVS[3] ) | ~( ~OBLATCH[7] | V[7] );
wire DO_COPY;
assign DO_COPY = ~( nVIS | I_OAM2 | SPR_OV | OVZ );
assign OMFG = ~( CLATCH[5] | CLATCH[3] | CLATCH[1] | DO_COPY );
assign OV[3:0] = OVS[3:0];
// Logics
always @(posedge Clk) begin
         if (PCLK) begin
         OBLATCH[7:0] <= OB[7:0];
         {CLATCH[5], CLATCH[3], CLATCH[1]} <= {CLATCH[4], CLATCH[2], CLATCH[0]};
                   end
         if (nPCLK) PDFIFO[1:0] <= { ~F_NT | ~Hnn0, OVZ };
         if (~( nPCLK | PDFIFO[1] )) PD_FIFO <= ~PDFIFO[0];
         if (S_EV  & nPCLK) SPR0_EV1 <=  DO_COPY;
         if (PAR_O & nPCLK) SPR0_EV  <= ~SPR0_EV1;
         if (nPCLK & Hnn0)  {CLATCH[4], CLATCH[2], CLATCH[0]} <= {CLATCH[3], CLATCH[1], DO_COPY};
                       end
// End of module for searching sprites to be output on next line
endmodule

//===============================================================================================
// Sprite Memory Management Module
//===============================================================================================
module OAM(
input Clk,          // System clock
input PCLK,         // Pixel clock
input nPCLK,        // Pixel clock
// Inputs
input Hnn0,         // Synchronized state of the PPU
input Hn0,          // Synchronized state of the PPU
input Hn2,          // Synchronized state of the PPU
input BLNK,         // Rendering is disabled
input nVIS,         // Visible part of the line
input W3,           // Write to OAM address register $2003
input W4,           // Write to OAM data register    $2004
input I_OAM2,       // OAM2 Initialization (Clear) Signal
input nEVAL,        // Reset OAM2 counter and start OAM2 processing
input PAR_O,        // Fetch sprite graphics
input OMFG,         // Signal to copy the current comparison sprite in OAM2
input RESCL,        // Prerender line (reset all fetch schemes)
input [7:0]DBIN,    // PPU Register Open Bus
// Outputs
output reg [7:0]OB, // Sprite data bus
output reg R2DB5,   // Sprite Overflow Flag
output reg SPR_OV   // OAM counter is full or more than 8 sprites found
);
// Variables
reg W4FF;
reg [4:0]W4Q;
reg [1:0]OMSTEP;
reg ORES_LATCH;
reg [2:0]OSTEP;
reg OVF_LATCH, OMFG_LATCH;
reg OMV_LATCH, TMV_LATCH;
reg OAMCTR2;
reg [7:0]OB2;
// Combinatorics
wire WE_EN, WE, OFETCH, OAP, SPR_OVERFLOW, OAMSTEP, M4, OAM2STEP, ORES;
assign WE_EN = ~( PCLK | BLNK | nVIS | OAMCTR2 | SPR_OV | ~Hnn0 );
assign WE = WE_EN | OFETCH;
assign OFETCH = ~( ~W4Q[2] | W4Q[4] );
assign OAP = ~(( Hnn0 | nVIS ) & ~BLNK );
assign SPR_OVERFLOW = ~( nPCLK | Hn0 | OVF_LATCH | OMFG_LATCH );
// OAM counter control
assign OAMSTEP = ~(( nPCLK | OMSTEP[1] ) & ( nPCLK | ~OMSTEP[0] ));
assign M4 = ~( ~OMFG | BLNK );
assign ORES  = ~( nPCLK | ORES_LATCH );
assign OAM2STEP = ~( nPCLK | OSTEP[0] | ~(( PAR_O & ~Hn2 ) | ~( Hn0 | ~( OSTEP[1] | OSTEP[2] ))));
wire [2:0]OBDZ;
assign OBDZ[2:0] = OAMQ[4:2] & {3{ ~( OAM1ADR[1] & ~OAM1ADR[0] )}};
wire [4:0]OAM2ADR, OAM2Cout;
wire [7:0]OAM1ADR, OAMCout;
// OAM COUNTER
//                    Clk          F2         DIR              C_IN                         Reset         LOAD            STEP        DATA               CNT_OUT         C_OUT
COUNTER OAMCNT1[1:0] (Clk, ~( OAMSTEP | W3 ), 1'b1, {OAMCout[0], 1'b1},                     PAR_O, W3 | M4,             OAMSTEP, M4 ? 2'h0 : DBIN[1:0], OAM1ADR[1:0], OAMCout[1:0]);
COUNTER OAMCNT2[7:2] (Clk, ~( OAMSTEP | W3 ), 1'b1, {OAMCout[6:2], M4 ? 1'b1 : OAMCout[1]}, PAR_O, W3,                  OAMSTEP,             DBIN[7:2], OAM1ADR[7:2], OAMCout[7:2]);
// OAM2 COUNTER
//                    Clk   F2    DIR              C_IN       Reset  LOAD   STEP     DATA    CNT_OUT        C_OUT
COUNTER OAM2CNT[4:0] (Clk, nPCLK, 1'b1, {OAM2Cout[3:0], 1'b1}, ORES, 1'b0, OAM2STEP, 5'h00, OAM2ADR[4:0], OAM2Cout[4:0]);
// Internal memory modules
wire [7:0]OAMQ, OAM2Q; 
OAM_RAM  MOD_OAM_RAM  (OAM1ADR[7:0], Clk, DBIN[7:0], (WE & BLNK), OAMQ[7:0]);  // OAM
OAM2_RAM MOD_OAM2_RAM (OAM2ADR[4:0], Clk,  OB2[7:0],  WE,         OAM2Q[7:0]); // OAM2
// Logics
always @(posedge Clk) begin
         if (~W4Q[3]) W4FF <= 1'b0;
    else if (W4)      W4FF <= 1'b1;
         if (RESCL)        R2DB5  <= 1'b0;
    else if (SPR_OVERFLOW) R2DB5  <= 1'b1;
         if (I_OAM2)       SPR_OV <= 1'b0;
    else if (SPR_OVERFLOW |( OAMSTEP & OMV_LATCH )) SPR_OV <= 1'b1;
         if (ORES)                  OAMCTR2 <= 1'b0;
    else if (OAM2STEP & TMV_LATCH ) OAMCTR2 <= 1'b1;
         if (~( BLNK | nPCLK )) OB2[7:0] <= OB[7:0];
         if (PCLK) {W4Q[4], W4Q[2], W4Q[0]} <= {~W4Q[3], W4Q[1], ~(W4 | ~W4FF)};
         if (nPCLK) begin
         {W4Q[3], W4Q[1]} <= { ~W4Q[2], W4Q[0]};
         OB[7:0] <= I_OAM2 ? 8'hFF : OAP ? {OAMQ[7:5], OBDZ[2:0], OAMQ[1:0]} : OAM2Q[7:0];
         OMSTEP[1:0] <= {~( Hnn0 & ~( I_OAM2 | nVIS )), OFETCH};
         OSTEP[2:0]  <= {~OMFG, I_OAM2, ~(nEVAL & ~OAMCTR2)};
         ORES_LATCH  <= nEVAL;
         OVF_LATCH   <= ~OAMCTR2;
         OMFG_LATCH  <= OMFG;
         OMV_LATCH   <= M4 ? &OAM1ADR[7:2] & ~OAM1ADR[1] & ~OAM1ADR[0] : &OAM1ADR[7:0];
         TMV_LATCH   <= OAM2Cout[4];
                     end
                       end
// End of Sprite Memory Management Module
endmodule

//===============================================================================================
// Sprite FIFO Module
//===============================================================================================
module OBJ_FIFO(
input Clk,        // System clock
input PCLK,       // Pixel clock
input nPCLK,      // Pixel clock
// Inputs
input [5:0]Hnn,   // Synchronized state of the PPU
input HPOS_0,     // Starting sprite X coordinate counters (0 sprite position)
input PAR_O,      // Fetch sprite graphics
input CLPO,       // Sprites are disabled
input nVIS,       // Visible part of the line
input PD_FIFO,    // OBJ FIFO Input Blocking
input [7:0]PD,    // PPU Graphics Data Bus
input [7:0]OB,    // Sprite data bus
// Outputs 
output nSPR0HIT,  // Sprite Detector #0
output reg SH2,   // Reading sprite attributes (for vertical mirroring)
output [4:0]ZCOL  // Sprite FIFO output
);
// Variables
reg SPR0HIT_LATCH, MIRR_LATCH, SH3, SH5, SH7;
reg [7:0]SEL_LATCH, PD_LATCH;
reg [2:0]ZPOS;
reg [2:0]ATR_IN0, ATR_IN1, ATR_IN2, ATR_IN3, ATR_IN4, ATR_IN5, ATR_IN6, ATR_IN7;
reg [2:0]ATR0, ATR1, ATR2, ATR3, ATR4, ATR5, ATR6, ATR7;
// Combinatorics
wire [7:0]MIRR_MUX;
assign MIRR_MUX[7:0] = MIRR_LATCH ? {PD[0],PD[1],PD[2],PD[3],PD[4],PD[5],PD[6],PD[7]} : PD[7:0];
// Sprite FIFO horizontal position counters
wire [7:0]EN;   // Sprite horizontal position counter outputs
FIFO_HPOSCNT HPOSCNT0( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[0]), nVIS, ~ZPOS[2], EN[0] );
FIFO_HPOSCNT HPOSCNT1( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[1]), nVIS, ~ZPOS[2], EN[1] );
FIFO_HPOSCNT HPOSCNT2( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[2]), nVIS, ~ZPOS[2], EN[2] );
FIFO_HPOSCNT HPOSCNT3( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[3]), nVIS, ~ZPOS[2], EN[3] );
FIFO_HPOSCNT HPOSCNT4( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[4]), nVIS, ~ZPOS[2], EN[4] );
FIFO_HPOSCNT HPOSCNT5( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[5]), nVIS, ~ZPOS[2], EN[5] );
FIFO_HPOSCNT HPOSCNT6( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[6]), nVIS, ~ZPOS[2], EN[6] );
FIFO_HPOSCNT HPOSCNT7( Clk, PCLK, nPCLK, OB[7:0], (PCLK & SH3 & SEL_LATCH[7]), nVIS, ~ZPOS[2], EN[7] );
// Sprite FIFO Shift Registers
wire [7:0]SDATA;
assign SDATA[7:0] = {8{ PD_FIFO }} & PD_LATCH[7:0];
wire[7:0]COL0, COL1;
//                Clk   SIn       STEP        NEXT              LOAD             P DATA In  NC  SEROut
SHIFTREG SREG_0A( Clk, 1'b0, (PCLK & EN[0]), nPCLK, (PCLK & SH5 & SEL_LATCH[0]), SDATA[7:0],  ,COL0[0] );
SHIFTREG SREG_0B( Clk, 1'b0, (PCLK & EN[0]), nPCLK, (PCLK & SH7 & SEL_LATCH[0]), SDATA[7:0],  ,COL1[0] );
SHIFTREG SREG_1A( Clk, 1'b0, (PCLK & EN[1]), nPCLK, (PCLK & SH5 & SEL_LATCH[1]), SDATA[7:0],  ,COL0[1] );
SHIFTREG SREG_1B( Clk, 1'b0, (PCLK & EN[1]), nPCLK, (PCLK & SH7 & SEL_LATCH[1]), SDATA[7:0],  ,COL1[1] );
SHIFTREG SREG_2A( Clk, 1'b0, (PCLK & EN[2]), nPCLK, (PCLK & SH5 & SEL_LATCH[2]), SDATA[7:0],  ,COL0[2] );
SHIFTREG SREG_2B( Clk, 1'b0, (PCLK & EN[2]), nPCLK, (PCLK & SH7 & SEL_LATCH[2]), SDATA[7:0],  ,COL1[2] );
SHIFTREG SREG_3A( Clk, 1'b0, (PCLK & EN[3]), nPCLK, (PCLK & SH5 & SEL_LATCH[3]), SDATA[7:0],  ,COL0[3] );
SHIFTREG SREG_3B( Clk, 1'b0, (PCLK & EN[3]), nPCLK, (PCLK & SH7 & SEL_LATCH[3]), SDATA[7:0],  ,COL1[3] );
SHIFTREG SREG_4A( Clk, 1'b0, (PCLK & EN[4]), nPCLK, (PCLK & SH5 & SEL_LATCH[4]), SDATA[7:0],  ,COL0[4] );
SHIFTREG SREG_4B( Clk, 1'b0, (PCLK & EN[4]), nPCLK, (PCLK & SH7 & SEL_LATCH[4]), SDATA[7:0],  ,COL1[4] );
SHIFTREG SREG_5A( Clk, 1'b0, (PCLK & EN[5]), nPCLK, (PCLK & SH5 & SEL_LATCH[5]), SDATA[7:0],  ,COL0[5] );
SHIFTREG SREG_5B( Clk, 1'b0, (PCLK & EN[5]), nPCLK, (PCLK & SH7 & SEL_LATCH[5]), SDATA[7:0],  ,COL1[5] );
SHIFTREG SREG_6A( Clk, 1'b0, (PCLK & EN[6]), nPCLK, (PCLK & SH5 & SEL_LATCH[6]), SDATA[7:0],  ,COL0[6] );
SHIFTREG SREG_6B( Clk, 1'b0, (PCLK & EN[6]), nPCLK, (PCLK & SH7 & SEL_LATCH[6]), SDATA[7:0],  ,COL1[6] );
SHIFTREG SREG_7A( Clk, 1'b0, (PCLK & EN[7]), nPCLK, (PCLK & SH5 & SEL_LATCH[7]), SDATA[7:0],  ,COL0[7] );
SHIFTREG SREG_7B( Clk, 1'b0, (PCLK & EN[7]), nPCLK, (PCLK & SH7 & SEL_LATCH[7]), SDATA[7:0],  ,COL1[7] );
// Sprite Output Priority
wire [7:0]SPR;
assign SPR[0] = ~( CLPO | ~EN[0] | ~( COL0[0] | COL1[0] ) );
assign SPR[1] = ~( CLPO | ~EN[1] | ~( COL0[1] | COL1[1] ) | SPR[0] );
assign SPR[2] = ~( CLPO | ~EN[2] | ~( COL0[2] | COL1[2] ) | SPR[0] | SPR[1] );
assign SPR[3] = ~( CLPO | ~EN[3] | ~( COL0[3] | COL1[3] ) | SPR[0] | SPR[1] | SPR[2] );
assign SPR[4] = ~( CLPO | ~EN[4] | ~( COL0[4] | COL1[4] ) | SPR[0] | SPR[1] | SPR[2] | SPR[3] );
assign SPR[5] = ~( CLPO | ~EN[5] | ~( COL0[5] | COL1[5] ) | SPR[0] | SPR[1] | SPR[2] | SPR[3] | SPR[4] );
assign SPR[6] = ~( CLPO | ~EN[6] | ~( COL0[6] | COL1[6] ) | SPR[0] | SPR[1] | SPR[2] | SPR[3] | SPR[4] | SPR[5] );
assign SPR[7] = ~( CLPO | ~EN[7] | ~( COL0[7] | COL1[7] ) | SPR[0] | SPR[1] | SPR[2] | SPR[3] | SPR[4] | SPR[5] | SPR[6] );
// Sprite pixel output
assign ZCOL[4:0] = SPR[0] ? { ATR0[2:0],COL1[0],COL0[0] } :
                   SPR[1] ? { ATR1[2:0],COL1[1],COL0[1] } :
                   SPR[2] ? { ATR2[2:0],COL1[2],COL0[2] } :
                   SPR[3] ? { ATR3[2:0],COL1[3],COL0[3] } :
                   SPR[4] ? { ATR4[2:0],COL1[4],COL0[4] } :
                   SPR[5] ? { ATR5[2:0],COL1[5],COL0[5] } :
                   SPR[6] ? { ATR6[2:0],COL1[6],COL0[6] } :
                   SPR[7] ? { ATR7[2:0],COL1[7],COL0[7] } :
                   5'b00000;
assign nSPR0HIT = ~SPR0HIT_LATCH;
// Logics
always @(posedge Clk) begin
         if (PCLK) begin
         ZPOS[1] <= ZPOS[0];
         SPR0HIT_LATCH <= SPR[0];
                   end
         if (nPCLK) begin
         SH2  <= PAR_O & ~Hnn[0] &  Hnn[1] & ~Hnn[2];
         SH3  <= PAR_O &  Hnn[0] &  Hnn[1] & ~Hnn[2];
         SH5  <= PAR_O &  Hnn[0] & ~Hnn[1] &  Hnn[2];
         SH7  <= PAR_O &  Hnn[0] &  Hnn[1] &  Hnn[2];
         SEL_LATCH[0] <= ~Hnn[3] & ~Hnn[4] & ~Hnn[5];
         SEL_LATCH[1] <=  Hnn[3] & ~Hnn[4] & ~Hnn[5];
         SEL_LATCH[2] <= ~Hnn[3] &  Hnn[4] & ~Hnn[5];
         SEL_LATCH[3] <=  Hnn[3] &  Hnn[4] & ~Hnn[5];
         SEL_LATCH[4] <= ~Hnn[3] & ~Hnn[4] &  Hnn[5];
         SEL_LATCH[5] <=  Hnn[3] & ~Hnn[4] &  Hnn[5];
         SEL_LATCH[6] <= ~Hnn[3] &  Hnn[4] &  Hnn[5];
         SEL_LATCH[7] <=  Hnn[3] &  Hnn[4] &  Hnn[5];
         {ZPOS[0], ZPOS[2]} <= {HPOS_0, ZPOS[1]};
         PD_LATCH[7:0] <= MIRR_MUX[7:0];
         ATR0[2:0] <= ATR_IN0[2:0];
         ATR1[2:0] <= ATR_IN1[2:0];
         ATR2[2:0] <= ATR_IN2[2:0];
         ATR3[2:0] <= ATR_IN3[2:0];
         ATR4[2:0] <= ATR_IN4[2:0];
         ATR5[2:0] <= ATR_IN5[2:0];
         ATR6[2:0] <= ATR_IN6[2:0];
         ATR7[2:0] <= ATR_IN7[2:0];
                    end
         if (PCLK & SH2) MIRR_LATCH <= OB[6];
         if (PCLK & SH2 & SEL_LATCH[0]) ATR_IN0[2:0] <= {OB[5], OB[1:0]};
         if (PCLK & SH2 & SEL_LATCH[1]) ATR_IN1[2:0] <= {OB[5], OB[1:0]};
         if (PCLK & SH2 & SEL_LATCH[2]) ATR_IN2[2:0] <= {OB[5], OB[1:0]};
         if (PCLK & SH2 & SEL_LATCH[3]) ATR_IN3[2:0] <= {OB[5], OB[1:0]};
         if (PCLK & SH2 & SEL_LATCH[4]) ATR_IN4[2:0] <= {OB[5], OB[1:0]};
         if (PCLK & SH2 & SEL_LATCH[5]) ATR_IN5[2:0] <= {OB[5], OB[1:0]};
         if (PCLK & SH2 & SEL_LATCH[6]) ATR_IN6[2:0] <= {OB[5], OB[1:0]};
         if (PCLK & SH2 & SEL_LATCH[7]) ATR_IN7[2:0] <= {OB[5], OB[1:0]};
                      end
// End of sprite FIFO module
endmodule

//===============================================================================================
// Sprite FIFO Horizontal Position Counter Module
//===============================================================================================
module FIFO_HPOSCNT(
input Clk,      // System clock
input PCLK,     // Pixel clock
input nPCLK,    // Pixel clock
// Inputs
input [7:0]OB,  // Sprite data bus
input LOAD,     // Loading data for recalculation
input nVIS,     // Visible part of the line
input n0_H,     // Starting sprite X coordinate counters (0 sprite position)
// Outputs
output reg EN   // Enable output for sprite shift register
);
// Variables
reg ZH_FF;      // Downward Counter Control Trigger
// Combinatorics
wire STEP;
assign STEP = ~( PCLK | ~ZH_FF );
wire [7:0]CNT, Cout;
// FIFO COUNTER
//                    Clk         F2        DIR       C_IN          Reset LOAD  STEP   DATA    CNT_OUT     C_OUT
COUNTER FIFOCNT[7:0] (Clk, ~(LOAD | STEP), 1'b0, {Cout[6:0], 1'b1}, 1'b0, LOAD, STEP, OB[7:0], CNT[7:0], Cout[7:0]);
// Logics
always @(posedge Clk) begin
         if ( PCLK & ( ~|CNT[7:0] ))            ZH_FF <= 1'b0;
    else if (~( nPCLK | n0_H | ( ~|CNT[7:0] ))) ZH_FF <= 1'b1;
         if (nPCLK) EN <= ~( nVIS | ZH_FF );
                       end
// End of Sprite FIFO Horizontal Position Counter Module
endmodule

//===============================================================================================
// Sprite FIFO and BG_COLOR shift register module
//===============================================================================================
module SHIFTREG(
input Clk,           // System clock
// Inputs
input SIN,           // Shift register serial input
input STEP,          // Shift Resolution, Phase 1
input NEXT,          // Shift Resolution, Phase 2
input LOAD,          // Permission to load data for shift
input [7:0]D,        // Data to shift
// Outputs
output reg [7:0]QP,  // Shift register parallel output
output QS            // Shift register serial   output
);
// Variables
reg [7:0]QS_IN;      // First phase of the shift
// Combinatorics
assign QS = QP[7];   // Shift register serial output
// Logics
always @(posedge Clk) begin
  if (LOAD | STEP) QS_IN[7:0] <= LOAD ? D[7:0] : {QP[6:0], SIN};
  if (NEXT) QP[7:0] <= QS_IN[7:0];
                      end
// End of module shift register Sprite FIFO and BG_COLOR
endmodule

//===============================================================================================
// Pixel multiplexer module
//===============================================================================================
module PIX_MUX(
input Clk,        // System clock
input PCLK,       // Pixel clock
input nPCLK,      // Pixel clock
// Inputs
input [3:0]BGC,   // Background data
input [4:0]ZCOL,  // Object data
input [4:0]THO,   // Tile counter low bits
input nVIS,       // Visible part of the line
input SPR0_EV,    // Sprite #0 is on the current line
input nSPR0HIT,   // Sprite Detector #0
input RESCL,      // Prerender line (reset all fetch schemes)
input TH_MUX,     // Palette range
// Outputs
output [4:0]CGA,  // Graphics data bus
output reg R2DB6  // Spritehit flag
);
// Variables
reg BGC_LATCH, ZCOL_LATCH, OCOLN;
reg [4:0]ZCOLN, THO_LATCH, STEP3;
reg [3:0]STEP2;
// Combinatorics
wire OCOL;
assign OCOL = ~( ~( ZCOLN[1] | ZCOLN[0] ) | ( ZCOLN[4] & ( BGC[1] | BGC[0] )));
wire [3:0]BGCF;
assign BGCF[3:0] = ( ~( BGC_LATCH | ZCOL_LATCH )) ? 4'h0 : STEP2[3:0];
assign CGA[4:0] = TH_MUX ? THO_LATCH[4:0] : STEP3[4:0];
// Logics
always @(posedge Clk) begin
          if (RESCL) R2DB6 <= 1'b0;
     else if (~( PCLK | nVIS | SPR0_EV | nSPR0HIT | ~( BGC[0] | BGC[1] ))) R2DB6 <= 1'b1;
          if (PCLK) begin
          ZCOLN[4:0] <= ZCOL[4:0];
          THO_LATCH[4:0] <= THO[4:0];
          STEP3[4:0] <= {OCOLN,BGCF[3:0]};
                     end
          if (nPCLK) begin
          STEP2[3:0] <= OCOL ? ZCOLN[3:0] : BGC[3:0];
          BGC_LATCH  <= BGC[1]   | BGC[0];
          ZCOL_LATCH <= ZCOLN[1] | ZCOLN[0];
          OCOLN      <= OCOL;
                     end
                       end
// End of pixel multiplexer module
endmodule

//===============================================================================================
// Palette module
//=============================================================================================== 
module PALETTE(
input Clk,            // System clock
input PCLK,           // Pixel clock
input nPCLK,          // Pixel clock
// Inputs
input R7,             // Reading from register 2007
input TH_MUX,         // Palette range
input nPICTURE,       // Blanking
input B_W,            // B/W mode (zeroing the lower 4 bits of the color index)
input DB_PAR,         // Forwarding CPU data to PPU bus
input [4:0]CGA,       // Graphics data bus
input [5:0]DBIN,      // PPU Register Open Bus
input PALSEL0,        // Palette select
input PALSEL1,        // Palette select
// Outputs
output RPIX,          // Selecting pixel output
output reg [5:0]PIX,  // Pixel output data
output [17:0]RGB      // RGB output R6 + G6 + B6
);
// Variables
reg DB_PARR;
reg [1:0]PICTR;
// Combinatorics
wire CGAH, nB_W;
wire [3:0]CN;
assign CGAH = CGA[4] & ( CGA[1] | CGA[0] );
assign CN[3:0] = C[3:0] & {4{ nB_W }};
assign nB_W = ~( B_W | ( nPICTURE & ~RPIX ));
assign RPIX = R7 & TH_MUX;
// Internal Palette RAM/ROM Modules
wire [17:0]RGB_TABLE;
wire [5:0]C;
PALETTE_RAM MOD_PALETTE_RAM ( {CGAH,CGA[3:0]}, Clk, DBIN[5:0],( TH_MUX & DB_PARR ), C[5:0] );  // Adr, Clk, DIn, WE, Q
PALETTE_RGB_TABLE MOD_RGB_TABLE ( {PALSEL1,PALSEL0,PIX[5:0]}, Clk, RGB_TABLE[17:0] );          // Adr, Clk, Q
// Output
assign RGB[17:0] = RGB_TABLE[17:0] & { 18 { ~PICTR[1] }};
// Logics
always @(posedge Clk) begin
         if (PCLK) begin
         DB_PARR  <= DB_PAR;
         PIX[5:0] <= {C[5:4], CN[3:0]};
         PICTR[0] <= nPICTURE;
                   end
         PICTR[1] <= PICTR[0];
                      end
// End of palette module
endmodule

//===============================================================================================
// counter module
//===============================================================================================
module COUNTER(
input Clk,       // Clock
input F2,        // Phase 2 (PCLK, nPCLK, etc)
// Inputs
input DIR,       // Direction of counting
input C_IN,      // Carry input
input Reset,     // Reset counter
input LOAD,      // Load DATA
input STEP,      // Step Count
input DATA,      // DATA INPUT
// Outputs
output reg CNT,  // Counter output
output C_OUT     // Carry out
);
reg CNT1;
assign C_OUT = DIR ? CNT & C_IN : ~CNT & C_IN;
// Logics
always @(posedge Clk or posedge Reset) begin
       if (Reset) CNT <= 1'b0;
  else if (LOAD)  CNT <= DATA;
  else if (STEP)  CNT <= CNT1;
                      end
always @(posedge Clk) begin
       if ( F2 ) CNT1 <= CNT ^ C_IN;
                      end
endmodule
