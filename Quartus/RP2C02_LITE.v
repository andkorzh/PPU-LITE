/*
 ===============================================================================================
 *                             Copyright (C) 2023  EMU-RUSSIA.COM
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
 *	 NMOS processor Ricoh 2C02(7) as much as possible. The Logsim 2C02(7) model was taken as the
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
    input Clk,               // System clock
    input Clk2,	             // Clock 21.477/26.601 for divider
    // Inputs
    input MODE,              // PAL/NTSC mode
	input DENDY,             // DENDY mode	(for PAL)
	input nRES,              // Reset 
	input PALSEL0,           // Palette select
	input PALSEL1,           // Palette select
    input RnW,               // External Pin Read/Write	
    input nDBE,              // PPU access strobe
	input [2:0]A,            // Register address
	input [7:0]PD,           // PPU Graphics Data Bus Input
	// Outputs
	inout [7:0]DB,           // CPU External Data Bus
	output [17:0]RGB,        // RGB output 6 + 6 + 6
	output [2:0]EMPH,        // EMPHASIS R G B
	output [13:0]PAD,        // PPU Bus Address Output
	output INT,              // Interrupt Request Output
	output ALE,              // ALE VRAM Address Low Byte Latch Strobe Output
	output nWR,              // VRAM Write Strobe	
	output nRD,              // VRAM Read Strobe
	output SYNC,             // Composite sync output
	output HSYNC,            // horizontal synchronization
    output VSYNC,            // vertical synchronization
	output [7:0]DBIN,        // CPU Internal Data Bus
	output DB_PAR            // Forwarding CPU data to PPU bus
);
// Module connections
wire PCLK;
wire nPCLK;
wire [7:0]OB;
wire [3:0]OV;
wire [7:0]Vo;
wire [5:0]PIX;
wire [2:0]R2DB;
wire [4:0]THO;	
wire [3:0]BGC;
wire [4:0]ZCOL;
wire [4:0]CGA;
wire Hn0;          
wire nHn2;         
wire nHn1;         
wire [5:0]Hnn;
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
wire N_TR;		
wire N_TG;		    
wire N_TB;
wire S_EV;            
wire O_HPOS;   
wire nEVAL;    
wire E_EV;     
wire I_OAM2;   
wire PAR_O;    
wire nVIS;     
wire nF_NT;    
wire F_TB;         
wire F_TA;         
wire N_FO;         
wire F_AT;         
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
wire TVO1;         
wire OMFG;		  
wire PD_FIFO; 
wire SPR0_EV;
wire SPR_OV;
wire nSPR0HIT;    
wire SH2;
wire RPIX;
// Variables
reg PCLK_N1, PCLK_N2;
reg PCLK_P1, PCLK_P2, PCLK_P3, PCLK_P4;
// Combinatorics
assign PCLK  =  PCLK_N2 | PCLK_P3 | PCLK_P4;
assign nPCLK = ~PCLK;
// Logics (Pixel clock divider)
always @(posedge Clk2) begin
		  PCLK_N1 <= ~( ~nRES |  MODE | PCLK_N2 );
          PCLK_N2 <= PCLK_N1;
          PCLK_P1 <= ~( ~nRES | ~MODE | ( PCLK_P2 | PCLK_P3 ));
		  PCLK_P2 <= PCLK_P1;
		  PCLK_P3 <= PCLK_P2;	  
                       end
always @(negedge Clk2) begin
		  PCLK_P4 <= PCLK_P2;
                       end							 
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
OBCLIP,        
BGCLIP,        
BLACK,         
VBL_EN,			
R2,            
nRES,          
Hn0,          
nHn2,         
nHn1,         
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
nF_NT,    
F_TB,         
F_TA,         
N_FO,         
F_AT,         
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
ADDRESS_BUS_CONTROL MOD_ADDRESS_BUS_CONTROL(
Clk,			
PCLK,	
nPCLK,
Hnn[0],
Hn0,
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
F_TA,			  
F_AT,		    
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
nHn1,
nHn2,		       
nF_NT,		  
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
F_AT,			    
DB_PAR,		
E_EV,			    		       
TSTEP,		    
F_TB,			    
I1_32,		   
BLNK,			    
PAD[13:0], 
THO[4:0],	 
TVO1	
);

//Find sprites to be output on a given line
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
nF_NT,	     
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
Hn0,
nHn2,
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
VID_MUX MOD_VID_MUX(
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
// Register Selection Module
//===============================================================================================
module REGISTER_SELECT(
input Clk,				       // System clock
// Inputs
input [7:0]DB,			       // Input data from CPU
input nDBE,				       // PPU access strobe
input RnW,				       // R/W circulation direction
input [2:0]A,		           // Register address
// Outputs
output reg [7:0]DBIN,		   // CPU External Data Bus Data
output R_EN,                   // CPU Data Bus Tristate Management
output reg W0,				   // Write to register #2000
output reg W1,				   // Write to register #2001
output reg R2,				   // Reading from register #2002
output reg W3,				   // Write to register #2003
output reg W4,				   // Write to register #2004
output reg R4,				   // Reading from register #2004
output reg W5_1,			   // Write to register  #2005/1
output reg W5_2,			   // Write to register  #2005/2
output reg W6_1,			   // Write to register  #2006/1
output reg W6_2,			   // Write to register  #2006/2
output reg W7,				   // Write to register  #2007
output reg R7				   // Reading from register #2007
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
	else if (W5_1 | W5_2 | W6_1 | W6_2) DWR1 <= ~DWR2;
	     if (R2) DWR2 <= 1'b1;
	else if (~(W5_1 | W5_2 | W6_1 | W6_2)) DWR2 <=  DWR1;	  
	     if (~nDBE & ~RnW) DBIN[7:0] <= DB[7:0];
                      end
endmodule

//===============================================================================================
// System register module
//===============================================================================================
module REG2000_2001(
input Clk,				    // System clock
input nPCLK,				// Pixel clock 
// Inputs
input W0,					// Write to register 2000
input W1,					// Write to register 2001
input RC,                   // Clearing registers
input [7:0]DBIN,			// CPU data bus
input nVIS,			        // Visible part of the line
input CLIP_O,               // Blanking the left column of 8 screen pixels for sprites
input CLIP_B,               // Blanking the left column of 8 screen dots for the
// Outputs
output reg I1_32,			// PPU address increment +1/+32
output reg OBSEL,			// MSB addresses of the sprite character generator
output reg BGSEL,			// MSB addresses of the character generator background
output reg O8_16,			// Sprite height (0 - 8 points, 1 - 16 points)
output VBL_EN,		        // Enable VBlank Interrupt
output B_W,			        // B/W mode (zeroing the lower 4 bits of the color index)
output reg BGCLIP,	        // Controls the blanking of the left 8 background dots
output reg OBCLIP,	        // Controls the blanking of the left 8 sprite dots
output BLACK,               // Disabling rendering
output nCLPB,			    // Disabling background
output CLPO,			    // Disabling sprites 
output [2:0]EMPH		    // Emphasis B, G, R
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
assign EMPH[0] = EMP_R  ? 1'b0 : 1'hZ;
assign EMPH[1] = EMP_G  ? 1'b0 : 1'hZ;
assign EMPH[2] = W1R[7] ? 1'b0 : 1'hZ;
// Logics
always @(posedge Clk) begin
			if (W0) W0R[4:0] <= RC ? 1'b0 : {DBIN[7],DBIN[5:2]};
			if (W1) W1R[7:0] <= RC ? 1'b0 : DBIN[7:0];
			if (~W0) I1_32   <= W0R[0];
            if (~W0) OBSEL   <= W0R[1];
			if (~W0) BGSEL   <= W0R[2];
            if (~W0) O8_16   <= W0R[3];
			if (~W1) BGCLIP  <= W1R[1];
			if (~W1) OBCLIP  <= W1R[2];
			if (~W1) BGE     <= W1R[3];
			if (~W1) OBE     <= W1R[4];
			if (~W1) EMP_R   <= W1R[5];
			if (~W1) EMP_G   <= W1R[6];
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
input Clk,				    // System clock
input PCLK,				    // Pixel clock
// Inputs
input R_EN,                 // CPU Data Bus Tristate Management
input R4,					// R2004 Reading Selection
input [7:0]OB,			    // Sprite data bus
input RPIX,				    // Selecting RAM data palette
input [5:0]PIX,			    // RAM data palette
input R2,					// R2002 Reading Selection
input [2:0]R2DB,			// R2002 data
input XRB,				    // VRAM Read Selection
input PD_RB,				// VRAM Bus Bridge Strobe
input RC,                   // Clearing registers
input [7:0]DBIN,			// CPU data bus
input [7:0]PD,			    // PPU Graphics Data Bus
// Outputs
output [7:0]DB	            // Output data for reading PPU from CPU side 
);
// Variables
reg [7:0]PD_R;
reg [7:0]OB_R;
reg [7:0]Do;
// Combinatorics
wire [7:0]D;
assign D[7:0] = ( R2 | R4 | RPIX | XRB ) ? Do[7:0] : DBIN[7:0];
assign DB[7:0] = R_EN ? D[7:0] : 8'hZZ; // tristate for reading mode
// Logics
always @(posedge Clk) begin
	   if (PCLK)  OB_R[7:0] <= OB[7:0];
	   if (RC)    PD_R[7:0] <= 8'h00;
  else if (PD_RB) PD_R[7:0] <= PD[7:0];
      Do[7:0] <= ({8{R4}} & OB_R[7:0]) | ({8{RPIX}} & {2'h0,PIX[5:0]}) | ({8{R2}} & {R2DB[2:0],5'h00}) | ({8{XRB}} & PD_R[7:0]);
                      end
endmodule

//===============================================================================================
// PPU Main Timing Generator Module
//===============================================================================================
module TIMING_GENERATOR(
input Clk,	         // System clock 
input PCLK,	         // Pixel clock
input nPCLK,         // Pixel clock
// Inputs
input MODE,          // PAL mode
input DENDY,         // DENDY mode	
input OBCLIP,        // Controls the blanking of the left 8 sprite dots
input BGCLIP,        // Controls the blanking of the left 8 background dots
input BLACK,         // Disabling rendering
input	VBL_EN,	     // Enable VBlank Interrupt Request
input R2,            // Reading register #2002
input nRES,          // PPU Master Reset
// Outputs
output Hn0,          // Synchronized state of the PPU
output nHn2,         // Synchronized state of the PPU
output nHn1,         // Synchronized state of the PPU
output reg[5:0]Hnn,  // Synchronized state of the PPU
output reg S_EV,     // Starting the sprite list view process
output CLIP_O,       // Left column blanking 8 dots at sprite
output CLIP_B,       // Left column blanking 8 dots at background
output reg O_HPOS,   // Starting sprite X coordinate counters (0 sprite position)
output reg nEVAL,    // Reset OAM2 counter and start OAM2 processing
output reg E_EV,     // End of the process of viewing the list and comparing sprites
output reg I_OAM2,   // OAM2 Initialization (Clear) Signal
output reg PAR_O,    // Fetch sprite graphics
output reg nVIS,     // Visible part of the line
output reg nF_NT,    // Reading tile number from Name Table
output F_TB,         // Second tile byte fetch phase
output F_TA,         // First byte tile fetch phase
output N_FO,         // Activate graphics shift
output F_AT,         // Phase of fetching attributes from Name Table
output BURST,        // Color Subcarrier Sync Burst Output Mask
output SC_CNT,       // Starting the address counter when raster and/or background are
output SYNC,         // Composite sync output
output reg HSYNC,    // horizontal synchronization
output reg VSYNC,    // vertical synchronization
output nPICTURE,     // Blanking
output reg RC,       // Clearing registers
output reg RESCL,    // Prerender line (reset all fetch schemes)
output BLNK,         // Rendering is disabled
output INT,          // interrupt on VBLANK
output reg R2DB7,    // Reading INT flag
output [7:0]Vo       // Vertical counter output (for sprite machine)
);
// Variables
reg [8:0]H;
reg [8:0]V;
reg [8:0]H_IN;
reg [8:0]V_IN;
reg HC, VC_LATCH;
reg ODDEVEN1, ODDEVEN2;
reg FPORCH_FF;
reg [5:0]Hn;
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
reg BPORCH_FF;
reg PEN_FF, PICT1, PICT2;
reg RESCL_IN;
reg BLNK_FF;
reg VB_FF;
reg VSET1,VSET2,VSET3;
reg INT_FF; 
// Combinatorics
// HV COUNTERS CONTROL
wire [8:0]HCarry;
assign HCarry[8:0] = H[8:0] & {HCarry[7:5], HIN5, HCarry[3:0], 1'b1};
wire [8:0]VCarry;
assign VCarry[8:0] = V[8:0] & {VCarry[7:0], H_LINE23};
wire HIN5;
assign HIN5 = H[4] & H[3] & H[2] & H[1] & H[0];
wire VC;
assign VC = HC | ~VC_LATCH; 
assign Hn0  =  Hn[0];
assign nHn1 = ~Hn[1];
assign nHn2 = ~Hn[2];
assign CLIP_O = ~( CLIP_OUT | OBCLIP );
assign CLIP_B = ~( CLIP_OUT | BGCLIP );
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
assign VLINE241 = ~( ~V[8] | ~V[7] | ~V[6] | ~V[5] | ~V[4] |  V[3] |  V[2] |  V[1] | ~V[0] | ~MODE |  DENDY ); // V241 PAL INT	
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
assign SYNC = HSYNC | VSYNC;
assign nPICTURE = PICT1 | PICT2;
assign BLNK = BLACK | BLNK_FF;
assign Vo[7:0] = V[7:0];
assign INT = VBL_EN & INT_FF;
// Logics
always @(posedge Clk) begin
         if (~nRES) ODDEVEN1 <= 1'b0;
    else if ( V[8]) ODDEVEN1 <=  ODDEVEN2;
	     if (~V[8]) ODDEVEN2 <= ~ODDEVEN1;
	     if (N_HB) begin
	     if (V_LINE1N | V_LINE1P) VSYNC_FF <= 1'b1;
    else if (V_LINE0N | V_LINE0P) VSYNC_FF <= 1'b0;
		           end
         if (~nRES) RC <= 1'b1;
    else if (RESCL) RC <= 1'b0;
         if (RESCL | R2)                  INT_FF <= 1'b0;
    else if (~( nPCLK | ~VSET1 | VSET3 )) INT_FF <= 1'b1; 
	     if (~R2) R2DB7 <= INT_FF;			 
         if (PCLK) begin
	     H[8:0]    <= ~nRES ? 9'h000 : { 9 { HC }} & H_IN[8:0];
	     V[8:0]    <= ~nRES ? 9'h000 : { 9 { VC }} & V_IN[8:0];
	     Hnn[5:0]  <= Hn[5:0];
	     S_EV      <= SEV_IN;
	     CLIP_OUT  <= ~( CLIP1 | ~CLIP2 );
	     O_HPOS    <= HPOS_IN;
	     nEVAL     <= ~( HPOS_IN | EVAL_IN | EEV_IN );
	     E_EV      <= EEV_IN;
	     I_OAM2    <= IOAM2_IN;
	     PAR_O     <= PARO_IN;
	     nVIS      <= ~NVIS_IN;
	     nF_NT     <= ~FNT_IN;
	     FTB_OUT   <= ~FTB_IN;
	     FTA_OUT   <= ~FTA_IN;
	     NFO_OUT   <= ~( NFO1 | NFO2 );
	     BURST_OUT <= BURST_FF;
	     HSYNC     <= ~FPORCH_FF;
	     VSYNC     <= ~( N_HB | VSYNC_FF );
	     PICT1     <= BPORCH_FF;
	     PICT2     <= PEN_FF;
	     RESCL     <= RESCL_IN;
	     VSET2     <= ~VSET1;
		           end
         if (nPCLK) begin
         H_IN[8:0] <= H[8:0] ^ {HCarry[7:5],HIN5,HCarry[3:0], 1'b1};
	     V_IN[8:0] <= V[8:0] ^ {VCarry[7:0], H_LINE23};
	     HC        <= ~( H_LINE23 | ( H_LINE5 & ~ODDEVEN1 & RESCL & ~MODE ));
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
         VSET1    <= V_LINE3N | VLINE291 | VLINE241; // activating the interrupt queue
	     VSET3    <= ~VSET2;
		          end          
                      end							
// End of PPU Main Timing Generator Module
endmodule

//===============================================================================================
// Local Bus Control Module PPU
//===============================================================================================
module ADDRESS_BUS_CONTROL(
input  Clk,		    // System clock 
input  PCLK,	    // Pixel clock
input nPCLK,        // Pixel clock
// Inputs
input Hnn0,		    // Synchronized state of the PPU
input Hn0,		    // Synchronized state of the PPU
input R7,			// Reading from register 2007
input W7,			// Write to register 2007
input BLNK,		    // Rendering is disabled
input [13:8]PAD,	// PPU bus high addresses
// Outputs
output TSTEP,		// Increment PPU address counters
output PD_RB,		// Data to PD bus read latch
output DB_PAR,		// Forwarding CPU data to PPU bus
output ALE,			// ALE signal
output nWR,			// write activate
output nRD,			// read activate
output XRB,			// PD data on CPU bus
output TH_MUX		// Appeal to the palette
);
// Variables
reg W7_FF, R7_FF;
reg R7_Q1, R7_Q2, R7_Q3, R7_Q4, R7_Q5;
reg W7_Q1, W7_Q2, W7_Q3, W7_Q4, W7_Q5;
reg BLNK_LATCH;
reg TSTEP_LATCH;
// Combinatorics
assign TH_MUX = PAD[13] & PAD[12] & PAD[11] & PAD[10] & PAD[9] & PAD[8] & BLNK_LATCH;
assign TSTEP  = PD_RB | TSTEP_LATCH;
assign PD_RB  = ~( ~R7_Q5 | R7_Q3 ); 
assign DB_PAR = ~( W7_Q2 | W7_Q4 );
assign nWR = ~DB_PAR | TH_MUX;
assign nRD = ~( PD_RB | ( Hnn0 & ~BLNK ));
assign XRB = ~( ~R7 | TH_MUX );
assign ALE = ~( ~R7_Q3 | R7_Q5 ) | ~( ~W7_Q3 | W7_Q5 ) | ~( nPCLK | Hn0 | BLNK );
// Logics
always @(posedge Clk) begin
          if (~R7_Q4) R7_FF <= 1'b0;
	 else if (R7)     R7_FF <= 1'b1;
          if (~W7_Q4) W7_FF <= 1'b0;
	 else if (W7)     W7_FF <= 1'b1;	 
          if (PCLK) begin
			BLNK_LATCH  <= BLNK;
			TSTEP_LATCH <= DB_PAR;
			R7_Q1 <=  R7_FF & ~R7;
			W7_Q1 <=  W7_FF & ~W7;
			R7_Q3 <=  R7_Q2;
			W7_Q3 <=  W7_Q2;
			R7_Q5 <= ~R7_Q4;
			W7_Q5 <= ~W7_Q4;
			         end
          if (nPCLK) begin
            R7_Q2 <=  R7_Q1;
			W7_Q2 <=  W7_Q1;
			R7_Q4 <= ~R7_Q3;
			W7_Q4 <= ~W7_Q3;
			          end          
                       end							
// End of Local Bus Control Module PPU
endmodule

//===============================================================================================
// Background Pixel Generator Module
//===============================================================================================
module BG_COLOR(
input   Clk,		// System clock 
input  PCLK,	    // Pixel clock
input nPCLK,        // Pixel clock
// Inputs
input Hnn0,		    // Synchronized state of the PPU
input nCLPB,		// Background is off
input F_TA,			// First byte tile fetch phase
input F_AT,		    // Attribute Fetching Phase
input F_TB,			// Second tile byte fetch phase
input N_FO,			// Activate graphics shift
input [7:0]PD,		// PPU Graphics Data Bus
input THO1,			// Horizontal coordinate in attribute
input TVO1,			// Vertical coordinate in attribute
input [2:0]DBIN,	// CPU data bus
input W5_1,			// Write to the fine horizontal scroll register
input RC,			// Clearing registers
// Outputs
output [3:0]BGC     // Background pixel output
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
reg [7:0]SR0;
reg [7:0]SR1;
reg [7:0]SR2;
reg [7:0]SR3;
reg [7:0]FSR0;
reg [7:0]FSR1;
reg [7:0]FSR2;
reg [7:0]FSR3;
reg [1:0]ATR;
reg [1:0]ATRO;
// Combinatorics
wire PD_SR;
assign PD_SR  = nPCLK & Hnn0 & F_TA;
wire PD_SEL;
assign PD_SEL = nPCLK & Hnn0 & F_AT_LATCH;
wire SRLOAD;
assign SRLOAD = nPCLK & Hnn0 & F_TB;
wire STEP;
assign STEP   = nPCLK & N_FO & ~( Hnn0 & F_TB );
wire STEP2;
assign STEP2  = nPCLK & N_FO;
wire NEXT;
assign NEXT   = ~( nPCLK | STEP | STEP2 );
wire [1:0]ATSEL;
assign ATSEL[0] = ( PDAT[0] & ~THO1R & ~TVO1 )|( PDAT[2] & THO1R & ~TVO1 )|( PDAT[4] & ~THO1R & TVO1 )|( PDAT[6] & THO1R & TVO1 );
assign ATSEL[1] = ( PDAT[1] & ~THO1R & ~TVO1 )|( PDAT[3] & THO1R & ~TVO1 )|( PDAT[5] & ~THO1R & TVO1 )|( PDAT[7] & THO1R & TVO1 );
wire [3:0]BGC_POS;
assign BGC_POS[3:0] = (~FH[0] & ~FH[1] & ~FH[2]) ? {SR3[7], SR2[7], SR1[7], SR0[7]} :
                      ( FH[0] & ~FH[1] & ~FH[2]) ? {SR3[6], SR2[6], SR1[6], SR0[6]} :
                      (~FH[0] &  FH[1] & ~FH[2]) ? {SR3[5], SR2[5], SR1[5], SR0[5]} :
					  ( FH[0] &  FH[1] & ~FH[2]) ? {SR3[4], SR2[4], SR1[4], SR0[4]} :
					  (~FH[0] & ~FH[1] &  FH[2]) ? {SR3[3], SR2[3], SR1[3], SR0[3]} :
					  ( FH[0] & ~FH[1] &  FH[2]) ? {SR3[2], SR2[2], SR1[2], SR0[2]} :
					  (~FH[0] &  FH[1] &  FH[2]) ? {SR3[1], SR2[1], SR1[1], SR0[1]} :
					  ( FH[0] &  FH[1] &  FH[2]) ? {SR3[0], SR2[0], SR1[0], SR0[0]} :
							                                                4'b0000 ;
// Background Pixel Shift Registers
wire QTA, QTB;
SHIFTREG SREG_TA( Clk, NEXT, STEP, SRLOAD ,PDTA[7:0], QTA );
SHIFTREG SREG_TB( Clk, NEXT, STEP, SRLOAD ,PD[7:0],   QTB );
assign BGC[3:0] = BGC2[3:0] & { 4 { CLPB_LATCH }};
// Logics
always @(posedge Clk) begin
	    if (PD_SR)  PDTA[7:0] <= PD[7:0];
	    if (PD_SEL) PDAT[7:0] <= PD[7:0];	
   	    if (RC)     FH[2:0]   <= 3'b000;
   else if (W5_1)   FH[2:0]   <= DBIN[2:0];	
        if (SRLOAD) begin
		ATRO[1:0] <= ATSEL[1:0];
		           end
		if (NEXT) begin
        ATR[1:0] <= ATRO[1:0];
		SR0[7:0] <= FSR0[7:0];
		SR1[7:0] <= FSR1[7:0];
		SR2[7:0] <= FSR2[7:0];
		SR3[7:0] <= FSR3[7:0];
               end
		if (STEP2) begin
        FSR0[7:0] <= {SR0[6:0],QTA};
	    FSR1[7:0] <= {SR1[6:0],QTB};
        FSR2[7:0] <= {SR2[6:0],ATR[0]};
	    FSR3[7:0] <= {SR3[6:0],ATR[1]};
                  end		
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
input	Clk,			// System clock 
input	PCLK,	        // Pixel clock
input	nPCLK,          // Pixel clock
// Inputs
input	Hnn0,		    // Synchronized state of the PPU
input	NHn1,		    // Synchronized state of the PPU
input	NHn2,		    // Synchronized state of the PPU
input	nF_NT,		    // Reading tile number from Name Table
input	RC,			    // Clearing registers
input	PAR_O,		    // Fetch sprite graphics
input	SH2,			// Sprite attribute reading phase
input	[3:0]OV,		// Sprite graphic line number
input	[7:0]OB,		// Sprite data bus
input	[7:0]PD,		// PPU Graphics Data Bus
input	[7:0]DBIN,	    // CPU data bus
input	O8_16,		    // Sprite height (0 - 8 points, 1 - 16 points)
input	OBSEL,		    // MSB addresses of objects
input	BGSEL,		    // MSB background addresses
input	RESCL,		    // Prerender line (reset all fetch schemes)
input	SC_CNT,		    // Starting the address counter when raster and/or background
input	W0,			    // Write to register #2000
input	W5_1,			// Write to register #2005.1
input	W5_2,			// Write to register #2005.2
input	W6_1,			// Write to register #2006.1
input	W6_2,			// Write to register #2006.2
input	F_AT,			// Attribute Fetching Phase
input	DB_PAR,		    // Forwarding CPU data to PPU bus
input	E_EV,			// End of the process of viewing the list and comparing sprites
input	TSTEP,		    // Increment PPU address counters
input	F_TB,			// Second tile byte fetch phase
input	I1_32,		    // PPU address increment +1/+32
input	BLNK,			// Rendering is disabled
// Outputs
output reg [13:0]PAD,   // VRAM Address/Data Output
output [4:0]THO,	    // Tile counter output
output TVO1				// Vertical coordinate in attribute 
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
reg EEVR1, EEVR2;
reg SCCNTR;
reg Z_TV1, Z_TV2, TVZR;
reg W62_FF;
reg W62_1, W62_2;
reg TV_IN;
// Combinatorics
wire TAL;
assign TAL = ~( nPCLK | TAL_LATCH );
wire [3:0]OBJ_INV;
assign OBJ_INV[3:0] = {4{ VINV_LATCH }} ^ OVOUT[3:0];
// Address counters control
wire THLOAD, TVLOAD;
assign THLOAD = ~( ~( EEVR2 | W62_2 )  | PCLK );
assign TVLOAD = ~( ~(( SCCNTR & RESCL )| W62_2 ) | PCLK );
wire THSTEP, TVSTEP;
assign THSTEP = ~( ~(( F_TB & Hnn0 )  | TSTEP )| PCLK );
assign TVSTEP = ~( ~( E_EV   | TSTEP )| PCLK  );
wire Z_TV;
assign Z_TV = ~( Z_TV1 | Z_TV2 );
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
//                  Clk   F2              C_IN        Reset   LOAD    STEP   DATA    CNT_OUT     C_OUT
COUNTER THCNT[4:0] (Clk, PCLK, {THOCout[3:0], TH_IN}, 1'b0, THLOAD, THSTEP, TH[4:0], THO[4:0], THOCout[4:0]);
// TV COUNTER
COUNTER TVCNT[4:0] (Clk, PCLK, {TVOCout[3:0], TV_IN}, Z_TV, TVLOAD, TVSTEP, TV[4:0], TVO[4:0], TVOCout[4:0]);
// NTH COUNTER
COUNTER NTHCNT     (Clk, PCLK,                NTH_IN, 1'b0, THLOAD, THSTEP, NTH,     NTHDO,    NTHC);
// NTV COUNTER
COUNTER NTVCNT     (Clk, PCLK,                NTV_IN, 1'b0, TVLOAD, TVSTEP, NTV,     NTVDO,    NTVC);
// FV COUNTER
COUNTER FVCNT[2:0] (Clk, PCLK, {FVOCout[1:0], FV_IN}, 1'b0, TVLOAD, TVSTEP, FV[2:0], FVO[2:0], FVOCout[2:0]);
// VRAM address multiplexer
wire BFVO0, NBFVO1;
assign BFVO0  =  BLNK & FVO[0];
assign NBFVO1 = ~BLNK | FVO[1];
wire PARR;
assign PARR = ~( NHn2 | BLNK );
wire [13:0]PAQ;
assign PAQ[7:0]  = DB_PAR ? DBIN[7:0] : PARR ? {TP[6:3],~NHn1,TP[2:0]} : F_AT ? {2'b11,TVO[4:2],THO[4:2]} : {TVO[2:0],THO[4:0]};
assign PAQ[13:8] = PARR ? {1'b0,TP[11:7]} : F_AT ? {NBFVO1,BFVO0,NTVDO,NTHDO,2'b11} : {NBFVO1,BFVO0,NTVDO,NTHDO,TVO[4:3]};
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
	   if (TAL) begin
	   OVOUT[3:0] <= OVR[3:0];
	   OBOUT[7:0] <= OB[7:0];
	   PDOUT[7:0] <= PDIN[7:0];
	            end
       if (nPCLK & W62_2) W62_FF <= 1'b0;
  else if	(W6_2)        W62_FF <= 1'b1;
	   if (PCLK) begin
		TVZR   <= TVZ;
		EEVR2  <= EEVR1;
		SCCNTR <= SC_CNT;
		W62_2  <= W62_1;
		PAD[13:0]  <= PAQ[13:0];
                end
      if (nPCLK) begin
        TAL_LATCH <= nF_NT | ~Hnn0;
		OVR[3:0]  <= OV[3:0];
		PDIN[7:0] <= PD[7:0];
		TP[2:0]   <= (PAR_O) ? OBJ_INV[2:0] : FVO[2:0] ; 
		TP[3]     <= (PAR_O) ? ((O8_16)   ? OBJ_INV[3] :  OBOUT[0] ) : PDOUT[0];
		TP[10:4]  <= (PAR_O) ? OBOUT[7:1] : PDOUT[7:1] ;
		TP[11]    <= (PAR_O) ? ((O8_16)   ? OBOUT[0] : OBSEL ) : BGSEL;
		Z_TV1     <= ~TVSTEP; 
		Z_TV2     <= ~TVZR;
		EEVR1     <= E_EV;
        W62_1     <= ~( ~W62_FF | W6_2 ); 		
                 end
			             end

// End of PPU Address Generator Module
endmodule

//===============================================================================================
// Module for searching sprites to be output on a given line
//===============================================================================================
module OBJ_EVAL(
input	Clk,		  // System clock 
input	PCLK,	      // Pixel clock
input	nPCLK,        // Pixel clock
// Inputs
input Hnn0,		      // Synchronized state of the PPU		
input [7:0]V,         // Vertical counter output (for sprite machine)
input [7:0]OB,		  // Sprite data bus
input O8_16,		  // Sprite height (0 - 8 points, 1 - 16 points)
input I_OAM2,		  // OAM2 Initialization (Clear) Signal
input nVIS,		      // Visible part of the line
input SPR_OV,		  // OAM counter is full or more than 8 sprites found
input nF_NT,		  // Reading tile number from Name Table
input S_EV,		      // Starting the sprite list view process
input PAR_O,		  // Fetch sprite graphics
// Outputs
output [3:0]OV,	      // Sprite graphic line number 
output OMFG,		  // Signal to copy the current comparison sprite in OAM2
output reg PD_FIFO,   // Resetting sprite graphics
output reg SPR0_EV    // Sprite #0 is on the current line
);
// Variables
reg LATCH1, LATCH2, LATCH3, LATCH4, LATCH5, LATCH6;
reg SPR0_EV1, PD_FIFO1, PD_FIFO2;
reg [7:0]OBLATCH;
// Combinatorics
wire [7:0]OVS;
assign OVS[7:0] = V[7:0] - OBLATCH[7:0];
wire OVZ;
assign OVZ = ( LATCH2 | LATCH4 | LATCH6 ) | ( ~O8_16 & OVS[3] ) | OVS[4] | OVS[5] | OVS[6] | OVS[7] | ~( ~OBLATCH[7] | V[7] );
wire DO_COPY;
assign DO_COPY = ~( nVIS | I_OAM2 | SPR_OV | OVZ );
assign OMFG = ~(( LATCH2 | LATCH4 | LATCH6 ) | DO_COPY );
assign OV[3:0] = OVS[3:0];
// Logics
always @(posedge Clk) begin
         if (PCLK) begin
			OBLATCH[7:0] <= OB[7:0];
			LATCH2 <= LATCH1;
			LATCH4 <= LATCH3;
			LATCH6 <= LATCH5;
			end
         if (nPCLK) begin
			PD_FIFO1 <= OVZ;
			PD_FIFO2 <= nF_NT | ~Hnn0;
			end
         if (~( nPCLK | PD_FIFO2 )) PD_FIFO <= ~PD_FIFO1;
         if (S_EV  & nPCLK) SPR0_EV1 <=  DO_COPY;
		 if (PAR_O & nPCLK) SPR0_EV  <= ~SPR0_EV1;
		 if ( nPCLK & Hnn0 ) begin
			LATCH1 <= DO_COPY;
			LATCH3 <= LATCH2;
			LATCH5 <= LATCH4;
			                  end
                     end							
// End of module for searching sprites to be output on this line
endmodule

//===============================================================================================
// Sprite Memory Management Module
//===============================================================================================
module OAM(
input	Clk,		  // System clock 
input  PCLK,	      // Pixel clock
input nPCLK,          // Pixel clock
// Inputs
input Hnn0,		      // Synchronized state of the PPU
input Hn0,		      // Synchronized state of the PPU
input NHn2,		      // Synchronized state of the PPU	
input BLNK,		      // Rendering is disabled
input nVIS,		      // Visible part of the line
input W3,			  // Write to OAM address register
input W4,			  // Write to OAM data register
input I_OAM2,		  // OAM2 Initialization (Clear) Signal
input nEVAL,		  // Reset OAM2 counter and start OAM2 processing
input PAR_O,		  // Fetch sprite graphics
input OMFG,		      // Signal to copy the current comparison sprite in OAM2
input RESCL,		  // Prerender line (reset all fetch schemes)
input [7:0]DBIN,      // CPU data bus
// Outputs
output reg [7:0]OB,   // Sprite data bus
output reg R2DB5,     // Sprite Overflow Flag
output reg SPR_OV     // OAM counter is full or more than 8 sprites found
);
// Variables
reg W4FF;
reg W4Q1, W4Q2, W4Q3, W4Q4, W4Q5;
reg OMSTEP1, OMSTEP2;
reg ORES_LATCH;
reg OSTEP1, OSTEP2, OSTEP3;
reg OVF_LATCH, OMFG_LATCH;
reg OMV_LATCH, TMV_LATCH;
reg OAMCTR2;
reg [7:0]OB2;
// Combinatorics
wire WE_EN;
assign WE_EN = ~( PCLK | BLNK | nVIS | OAMCTR2 | SPR_OV | ~Hnn0 );
wire WE;
assign WE = WE_EN | OFETCH;
wire OFETCH;
assign OFETCH = ~( ~W4Q3 | W4Q5 );
wire OAP;
assign OAP = ~(( Hnn0 | nVIS ) & ~BLNK );
wire SPR_OVERFLOW;
assign SPR_OVERFLOW = ~( nPCLK | Hn0 | OVF_LATCH | OMFG_LATCH );
// ÎÀÌ counter control
wire OMSTEP;
assign OMSTEP = ~(( nPCLK | ~OMSTEP1 ) & ( nPCLK | OMSTEP2 ));
wire MODE4;
assign MODE4 = ~( ~OMFG | BLNK );
wire ORES;
assign ORES = ~( nPCLK | ORES_LATCH );
wire OSTEP;
assign OSTEP = ~( nPCLK | OSTEP1 | ~(( PAR_O & NHn2 ) | ~( Hn0 | ~( OSTEP2 | OSTEP3 ))));
wire OMV;
wire [4:0]OAM2ADR, OAM2Cout;
wire [7:0]OAM1ADR;
// OAM COUNTER
//                  Clk  MODE   Reset LOAD   STEP    DATA     CNT_OUT      C_OUT
OAM_COUNTER OAMCNT (Clk, MODE4, PAR_O, W3, OMSTEP, DBIN[7:0], OAM1ADR[7:0], OMV);
// OAM2 COUNTER
//                    Clk   F2              C_IN        Reset  LOAD   STEP   DATA    CNT_OUT        C_OUT
COUNTER OAM2CNT[4:0] (Clk, nPCLK, {OAM2Cout[3:0], 1'b1}, ORES, 1'b0, OSTEP, 5'h00, OAM2ADR[4:0], OAM2Cout[4:0]);
// Internal memory modules
wire [7:0]OAMQ, OAM2Q; 
OAM_RAM  MOD_OAM_RAM  (OAM1ADR[7:0], Clk, DBIN[7:0], (WE & BLNK), OAMQ[7:0]);             // OAM
OAM2_RAM MOD_OAM2_RAM (OAM2ADR[4:0], Clk, ( {8{ I_OAM2 }} | OB2[7:0] ), WE, OAM2Q[7:0]);  // OAM2
// Logics
always @(posedge Clk) begin
          if (~W4Q4) W4FF <= 1'b0;
	 else if (W4)    W4FF <= 1'b1;
	      if (RESCL)        R2DB5  <= 1'b0;
	 else if (SPR_OVERFLOW) R2DB5  <= 1'b1;
	      if (I_OAM2)       SPR_OV <= 1'b0;
	 else if ( SPR_OVERFLOW |( OMSTEP & OMV_LATCH )) SPR_OV <= 1'b1;
	      if (ORES)               OAMCTR2 <= 1'b0;
	 else if (OSTEP & TMV_LATCH ) OAMCTR2 <= 1'b1;
		  if (~( BLNK | nPCLK )) OB2[7:0] <= OB[7:0]; 
          if (PCLK) begin
			W4Q1 <= ~( W4 | ~W4FF );
			W4Q3 <=  W4Q2;
			W4Q5 <= ~W4Q4;
			           end
          if (nPCLK) begin
			W4Q2 <=  W4Q1;
			W4Q4 <= ~W4Q3;
            OB[7:0] <= OAP ? OAMQ[7:0] : OAM2Q[7:0];
		    OMSTEP1 <= OFETCH;
			OMSTEP2 <= ~( Hnn0 & ~( I_OAM2 | nVIS ));
			ORES_LATCH <= nEVAL;
			OSTEP1 <= ~( nEVAL & ~OAMCTR2 );
			OSTEP2 <= I_OAM2;
			OSTEP3 <= ~OMFG;
			OVF_LATCH  <= ~OAMCTR2;
			OMFG_LATCH <= OMFG;
		    OMV_LATCH  <= OMV;
	        TMV_LATCH  <= OAM2Cout[4];
			            end          
                      end							
// End of Sprite Memory Management Module
endmodule			

//===============================================================================================
// Sprite FIFO Module
//===============================================================================================
module OBJ_FIFO(
input	Clk,		// System clock
input	PCLK,	    // Pixel clock
input	nPCLK,      // Pixel clock
// Inputs 		
input [5:0]Hnn,	    // Synchronized state of the PPU
input HPOS_0,       // Starting sprite X coordinate counters (0 sprite position)
input PAR_O,        // Fetch sprite graphics
input CLPO,         // Sprites are disabled
input nVIS,         // Visible part of the line
input PD_FIFO,      // Resetting sprite graphics
input [7:0]PD,      // PPU Graphics Data Bus
input [7:0]OB,      // Sprite data bus		     
// Outputs 
output nSPR0HIT,    // Sprite Detector #0
output reg SH2,     // Reading sprite attributes (for vertical mirroring)
output [4:0]ZCOL    // Sprite FIFO output 
);
// Variables
reg [7:0]SEL_LATCH;
reg MIRR_LATCH;
reg [2:0]ZPOS;
reg [7:0]PD_LATCH;
reg SH3, SH5, SH7;
reg [2:0] ATR_IN0, ATR_IN1, ATR_IN2, ATR_IN3, ATR_IN4, ATR_IN5, ATR_IN6, ATR_IN7;
reg [2:0] ATR0, ATR1, ATR2, ATR3, ATR4, ATR5, ATR6, ATR7;
reg SPR0HIT_LATCH;
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
SHIFTREG SREG_0A( Clk, nPCLK, (PCLK & EN[0]), (PCLK & SH5 & SEL_LATCH[0]), SDATA[7:0], COL0[0] );
SHIFTREG SREG_0B( Clk, nPCLK, (PCLK & EN[0]), (PCLK & SH7 & SEL_LATCH[0]), SDATA[7:0], COL1[0] );
SHIFTREG SREG_1A( Clk, nPCLK, (PCLK & EN[1]), (PCLK & SH5 & SEL_LATCH[1]), SDATA[7:0], COL0[1] );
SHIFTREG SREG_1B( Clk, nPCLK, (PCLK & EN[1]), (PCLK & SH7 & SEL_LATCH[1]), SDATA[7:0], COL1[1] );
SHIFTREG SREG_2A( Clk, nPCLK, (PCLK & EN[2]), (PCLK & SH5 & SEL_LATCH[2]), SDATA[7:0], COL0[2] );
SHIFTREG SREG_2B( Clk, nPCLK, (PCLK & EN[2]), (PCLK & SH7 & SEL_LATCH[2]), SDATA[7:0], COL1[2] );
SHIFTREG SREG_3A( Clk, nPCLK, (PCLK & EN[3]), (PCLK & SH5 & SEL_LATCH[3]), SDATA[7:0], COL0[3] );
SHIFTREG SREG_3B( Clk, nPCLK, (PCLK & EN[3]), (PCLK & SH7 & SEL_LATCH[3]), SDATA[7:0], COL1[3] );
SHIFTREG SREG_4A( Clk, nPCLK, (PCLK & EN[4]), (PCLK & SH5 & SEL_LATCH[4]), SDATA[7:0], COL0[4] );
SHIFTREG SREG_4B( Clk, nPCLK, (PCLK & EN[4]), (PCLK & SH7 & SEL_LATCH[4]), SDATA[7:0], COL1[4] );
SHIFTREG SREG_5A( Clk, nPCLK, (PCLK & EN[5]), (PCLK & SH5 & SEL_LATCH[5]), SDATA[7:0], COL0[5] );
SHIFTREG SREG_5B( Clk, nPCLK, (PCLK & EN[5]), (PCLK & SH7 & SEL_LATCH[5]), SDATA[7:0], COL1[5] );
SHIFTREG SREG_6A( Clk, nPCLK, (PCLK & EN[6]), (PCLK & SH5 & SEL_LATCH[6]), SDATA[7:0], COL0[6] );
SHIFTREG SREG_6B( Clk, nPCLK, (PCLK & EN[6]), (PCLK & SH7 & SEL_LATCH[6]), SDATA[7:0], COL1[6] );
SHIFTREG SREG_7A( Clk, nPCLK, (PCLK & EN[7]), (PCLK & SH5 & SEL_LATCH[7]), SDATA[7:0], COL0[7] );
SHIFTREG SREG_7B( Clk, nPCLK, (PCLK & EN[7]), (PCLK & SH7 & SEL_LATCH[7]), SDATA[7:0], COL1[7] ); 
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
			ZPOS[0] <= HPOS_0;
			ZPOS[2] <= ZPOS[1];
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
input	Clk,		// System clock
input	PCLK,	    // Pixel clock
input	nPCLK,      // Pixel clock
// Inputs 
input [7:0]OB,      // Sprite data bus
input LOAD,         // Loading data for recalculation
input nVIS,         // Visible part of the line
input n0_H,         // Starting sprite X coordinate counters (0 sprite position)
// Outputs 
output reg EN       // Enable output for sprite shift register
);
// Variables
reg ZH_FF;          // Downward Counter Control Trigger
reg [7:0]CNT;       // Downward counter latches
reg [7:0]CNT1;      // Downward counter latches
// Combinatorics
wire STEP;
assign STEP = ~( PCLK | ~ZH_FF );  
wire [7:0]Cout;
assign Cout[7:0] = ~CNT[7:0] & {Cout[6:0], 1'b1};
// Logics
always @(posedge Clk) begin
	      if ( PCLK & ( ~|CNT[7:0] ))            ZH_FF <= 1'b0;
	 else if (~( nPCLK | n0_H | ( ~|CNT[7:0] ))) ZH_FF <= 1'b1;
          if (LOAD | STEP) CNT[7:0] <= LOAD ? OB[7:0] : CNT1[7:0];
		  if ( ~(LOAD | STEP)) CNT1[7:0] <= CNT[7:0] ^ {Cout[6:0], 1'b1};
          if (nPCLK) begin
		  EN <= ~( nVIS | ZH_FF );
		              end
                       end						 
// End of Sprite FIFO Horizontal Position Counter Module
endmodule

//===============================================================================================
// Sprite FIFO and BG_COLOR shift register module
//===============================================================================================
module SHIFTREG(
input	Clk,		// System clock
// Inputs 
input	NEXT,	    // Shift Resolution, Phase 2
input	STEP,       // Shift Resolution, Phase 1
input LOAD,         // Permission to load data for shift
input [7:0]D,       // Data to shift
// Outputs 
output Q            // Shift register output
);
// Variables
reg [7:0]QS;        // The second phase of the shift
reg [7:0]QS_IN;     // First phase of the shift
// Combinatorics
assign Q = QS[7];   // Shift register output
// Logics
always @(posedge Clk) begin
  if (LOAD | STEP) QS_IN[7:0] <= LOAD ? D[7:0] : {QS[6:0], 1'b0};
  if (NEXT) QS[7:0] <= QS_IN[7:0];
                      end
// End of module shift register Sprite FIFO and BG_COLOR
endmodule
							 
//===============================================================================================
// Pixel multiplexer module
//===============================================================================================
module VID_MUX(
input	Clk,		 // System clock
input	PCLK,	     // Pixel clock
input	nPCLK,       // Pixel clock
// Inputs
input [3:0]BGC,      // Background data
input [4:0]ZCOL,     // Object data
input [4:0]THO,      // Tile counter low bits
input nVIS,			 // Visible part of the line
input SPR0_EV,       // Sprite #0 is on the current line
input nSPR0HIT,	     // Sprite Detector #0
input RESCL,		 // Prerender line (reset all fetch schemes)
input TH_MUX,		 // Appeal to the palette
// Outputs
output [4:0]CGA,     // Graphics data bus
output reg R2DB6     // Spritehit flag
);
// Variables
reg [4:0]ZCOLN;
reg [4:0]THO_LATCH;
reg [3:0]STEP2;
reg [4:0]STEP3;
reg BGC_LATCH, ZCOL_LATCH, OCOLN;
// Combinatorics
wire OCOL;
assign OCOL = ~( ~( ZCOLN[1] | ZCOLN[0] ) | ( ZCOLN[4] & ( BGC[1] | BGC[0] )));
wire [3:0]BGCF;
assign BGCF[3:0] = ( ~( BGC_LATCH | ZCOL_LATCH )) ? 4'b0000 : STEP2[3:0];
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
input	Clk,		   // System clock 
input	PCLK,	       // Pixel clock
input	nPCLK,         // Pixel clock
// Inputs
input R7,              // Reading from register 2007
input TH_MUX,		   // Appeal to the palette
input nPICTURE,        // Blanking
input B_W,             // B/W mode (zeroing the lower 4 bits of the color index)
input DB_PAR,		   // Forwarding CPU data to PPU bus
input [4:0]CGA,        // Graphics data bus 
input [5:0]DBIN,	   // CPU data bus
input PALSEL0,         // Palette select
input PALSEL1,         // Palette select

// Outputs
output RPIX,           // Selecting pixel output
output reg [5:0]PIX,   // Pixel output data
output [17:0]RGB       // RGB output 6 + 6 + 6
);
// Variables
reg DB_PARR;
reg PICTURER;
// Combinatorics
wire CGAH;
assign CGAH = ( CGA[0] | CGA[1] ) & CGA[4];
wire [3:0]CN;
assign CN[3:0] = C[3:0] & { 4 { nB_W }};
wire nB_W;
assign nB_W = ~( B_W | ( nPICTURE & ~RPIX ));
assign RPIX = R7 & TH_MUX;
// Internal Palette RAM/ROM Modules
wire [17:0]RGB_IN;
wire [5:0]C;
PALETTE_RAM MOD_PALETTE_RAM ( {CGAH,CGA[3:0]}, Clk, DBIN[5:0],( TH_MUX & DB_PARR ), C[5:0] );
PALETTE_RGB_TABLE MOD_RGB_TABLE ( {PALSEL1,PALSEL0,PIX[5:0]}, Clk, RGB_IN[17:0] );
// Output
assign RGB[17:0] = RGB_IN[17:0] & { 18 { ~PICTURER }};
// Logics
always @(posedge Clk) begin
         if (PCLK) begin
			DB_PARR <= DB_PAR;
			PIX[5:0] <= {C[5],C[4],CN[3:0]};
			        end
         if (nPCLK) begin
			PICTURER <= nPICTURE;
			        end          
                      end							
// End of palette module
endmodule

//===============================================================================================
// counter module
//===============================================================================================
module COUNTER(
  // Clocks
  input	Clk,	       // Clock
  input	F2,            // Phase 2 (PCLK, nPCLK, etc)
  //Inputs  
  input	C_IN,          // Carry input
  input	Reset,		   // Reset counter
  input	LOAD,		   // Load DATA
  input	STEP,		   // Step Count
  input  DATA,         // DATA INPUT
  // Outputs 
  output reg CNT,      // Counter output
  output C_OUT         // Carry out
);
reg CNT1;
assign C_OUT = CNT & C_IN;  

always @(posedge Clk) begin
      if ( Reset | LOAD | STEP ) CNT <= ( Reset ? 1'b0 : LOAD ? DATA : CNT1 );
	  if ( F2 ) CNT1  <= CNT ^ C_IN;
                      end
endmodule

//===============================================================================================
// counter module OAM1
//===============================================================================================
module OAM_COUNTER(
  // Clocks
  input	Clk,	       // Clock
  //Inputs  
  input	MODE4,         // Counting mode 1 or 4 step
  input	Reset,		   // Reset counter
  input	LOAD,		   // Load DATA
  input	STEP,		   // Step Count
  input  [7:0]DATA,    // DATA INPUT
  // Outputs 
  output reg [7:0]CNT, // Counter output
  output C_OUT         // Carry out
);
reg [7:0]CNT1; 
wire [7:0]OAM1Cout;
assign OAM1Cout[7:0] = CNT[7:0] & {OAM1Cout[6:0],1'b1};
wire [5:0]OAM4Cout; 
assign OAM4Cout[5:0] = CNT[7:2] & {OAM4Cout[4:0],1'b1};
wire [5:0]CNT4;
assign CNT4[5:0]  = CNT[7:2] ^ {OAM4Cout[4:0],1'b1};
assign C_OUT = (MODE4) ? CNT[7] & CNT[6] & CNT[5] & CNT[4] & CNT[3] & CNT[2] & ~CNT[1] & ~CNT[0] 
                       : CNT[7] & CNT[6] & CNT[5] & CNT[4] & CNT[3] & CNT[2] &  CNT[1] &  CNT[0];
always @(posedge Clk) begin
     if (   LOAD | STEP | Reset ) CNT[7:0]  <= Reset ? 8'h00 : LOAD ? DATA[7:0] : CNT1[7:0];                     
     if (~( LOAD | STEP ))        CNT1[7:0] <= MODE4 ? {CNT4[5:0], 2'b00 } : ( CNT[7:0] ^ {OAM1Cout[6:0],1'b1});
                      end
endmodule
