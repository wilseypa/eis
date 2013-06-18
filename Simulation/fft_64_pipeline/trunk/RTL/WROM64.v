/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Twiddle factor ROM for 64-point FFT                        ////
////                                                             ////
////  Authors: Anatoliy Sergienko, Volodya Lepeha                ////
////  Company: Unicore Systems http://unicore.co.ua              ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2006-2010 Unicore Systems LTD                 ////
//// www.unicore.co.ua                                           ////
//// o.uzenkov@unicore.co.ua                                     ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
//// THIS SOFTWARE IS PROVIDED "AS IS"                           ////
//// AND ANY EXPRESSED OR IMPLIED WARRANTIES,                    ////
//// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED                  ////
//// WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT              ////
//// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.        ////
//// IN NO EVENT SHALL THE UNICORE SYSTEMS OR ITS                ////
//// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,            ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL            ////
//// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT         ////
//// OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,               ////
//// DATA, OR PROFITS; OR BUSINESS INTERRUPTION)                 ////
//// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,              ////
//// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING                 ////
//// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,                 ////
//// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.          ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
// Design_Version       : 1.0
// File name            : WROM64.v
// File Revision        : 
// Last modification    : Sun Sep 30 20:11:56 2007
/////////////////////////////////////////////////////////////////////
// FUNCTION: 1-port synchronous RAM
// FILES:    RAM64.v -single ported synchronous RAM
// PROPERTIES:
//1) Has 64 complex coefficients which form a table 8x8,
//and stay in the needed order, as they are addressed
//by the simple counter 
//2) 16-bit values are stored. When shorter bit width is set
//then rounding	is not used
//3) for FFT and IFFT depending on paramifft	       
/////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps
`include "FFT64_CONFIG.inc"	 

module WROM64 ( WI ,WR ,ADDR );
	`USFFT64paramnw	
	
	input [5:0] ADDR ;
	wire [5:0] ADDR ;
	
	output [nw-1:0] WI ;
	wire [nw-1:0] WI ;
	output [nw-1:0] WR ;
	wire [nw-1:0] WR ;
	
	parameter signed  [15:0] pc0 = 16'h7fff;  
	parameter signed  [15:0] pc1 = 16'h7f62;   
	parameter signed  [15:0] pc2 = 16'h7d8a;   
	parameter signed  [15:0] pc3 = 16'h7a7d;   
	parameter signed  [15:0] pc4 = 16'h7642;   
	parameter signed  [15:0] pc5 = 16'h70e3;   
	parameter signed  [15:0] pc6 = 16'h6a6e;   
	parameter signed  [15:0] pc7 = 16'h62f2;   
	parameter signed  [15:0] pc8 = 16'h5a82;

	parameter signed [15:0] ps0 = 16'h0000;   
	parameter signed [15:0] ps1 = 16'h0c8c;
	parameter signed [15:0] ps2 = 16'h18f9;
 	parameter signed [15:0] ps3 = 16'h2528;
	parameter signed [15:0] ps4 = 16'h30fc;
	parameter signed [15:0] ps5 = 16'h3c57;
	parameter signed [15:0] ps6 = 16'h471d;
	parameter signed [15:0] ps7 = 16'h5134;
 
	parameter signed [15:0] ns0 = -16'h0000;   
	parameter signed [15:0] ns1 = -16'h0c8c;
	parameter signed [15:0] ns2 = -16'h18f9;
 	parameter signed [15:0] ns3 = -16'h2528;
	parameter signed [15:0] ns4 = -16'h30fc;
	parameter signed [15:0] ns5 = -16'h3c57;
	parameter signed [15:0] ns6 = -16'h471d;
	parameter signed [15:0] ns7 = -16'h5134;
 
	parameter signed  [15:0] nc0 = -16'h7fff;  
	parameter signed  [15:0] nc1 = -16'h7f62;   
	parameter signed  [15:0] nc2 = -16'h7d8a;   
	parameter signed  [15:0] nc3 = -16'h7a7d;   
	parameter signed  [15:0] nc4 = -16'h7642;   
	parameter signed  [15:0] nc5 = -16'h70e3;   
	parameter signed  [15:0] nc6 = -16'h6a6e;   
	parameter signed  [15:0] nc7 = -16'h62f2;   
	parameter signed  [15:0] nc8 = -16'h5a82;


	parameter[31:0] w0= {pc0,ns0};   
	parameter[31:0] w1= {pc1,ns1};
	parameter[31:0] w2= {pc2,ns2};
	parameter[31:0] w3= {pc3,ns3};
	parameter[31:0] w4= {pc4,ns4};
	parameter[31:0] w5= {pc5,ns5};
	parameter[31:0] w6= {pc6,ns6};
	parameter[31:0] w7= {pc7,ns7};
	parameter[31:0] w8= {pc8,nc8};
	parameter[31:0] w9= {ps7,nc7};
	parameter[31:0] w10= {ps6,nc6};
	parameter[31:0] w12= {ps4,nc4};
	parameter[31:0] w14= {ps2,nc2};
	parameter[31:0] w15= {ps1,nc1};
	parameter[31:0] w16= {ps0,nc0};
	parameter[31:0] w18= {ns2, nc2};
	parameter[31:0] w20= {ns4, nc4};
	parameter[31:0] w21= {ns5, nc5};
	parameter[31:0] w24= {nc8, nc8};
	parameter[31:0] w25= {nc7, ns7};
	parameter[31:0] w28= {nc4, ns4};
	parameter[31:0] w30= {nc2, ns2};
	parameter[31:0] w35= {nc3, ps3};
	parameter[31:0] w36= {nc4, ps4};
	parameter[31:0] w42= {ns6, pc6};
	parameter[31:0] w49= {ps1, pc1};
	
	reg [31:0] wf [0:63] ;	 
	integer	i;
	
	always@(ADDR) begin
			//(w0, w0, w0,  w0,  w0,  w0,  w0,  w0,	 	0..7 // twiddle factors for FFT
			//	w0, w1, w2,  w3,  w4,  w5,  w6,  w7,   	8..15
			//	w0, w2, w4,  w6,  w8,  w10,w12,w14,	16..23
			//	w0, w3, w6,  w9,  w12,w15,w18,w21,	24..31
			//	w0, w4, w8,  w12,w16,w20,w24,w28,	32..47
			//	w0, w5, w10,w15,w20,w25,w30,w35,
			//	w0, w6, w12,w18,w24,w30,w36,w42,
			//	w0, w7, w14,w21,w28,w35,w42,w49);																
			for( i =0; i<8; i=i+1) 	 wf[i] =w0;					
			for( i =8; i<63; i=i+8)  wf[i] =w0;					
			wf[9] =w1 ; wf[10] =w2 ;    wf[11] =w3 ;wf[12] =w4 ;
			wf[13] =w5 ;wf[14] =w6 ;   wf[15] =w7 ;
			wf[17] =w2 ;wf[18] =w4 ;   wf[19] =w6 ;wf[20] =w8 ;
			wf[21] =w10 ;wf[22] =w12 ;wf[23] =w14;
			wf[25] =w3 ;wf[26] =w6 ;   wf[27] =w9 ;wf[28] =w12 ;
			wf[29] =w15 ;wf[30] =w18 ;wf[31] =w21;
			wf[33] =w4 ;wf[34] =w8 ;	wf[35] =w12 ;wf[36] =w16 ;
			wf[37] =w20 ;wf[38] =w24 ;wf[39] =w28;
			wf[41] =w5 ;wf[42] =w10 ;	wf[43] =w15 ;wf[44] =w20 ;
			wf[45] =w25 ;wf[46] =w30 ;wf[47] =w35;
			wf[49] =w6 ;wf[50] =w12 ;	wf[51] =w18 ;wf[52] =w24 ;
			wf[53] =w30 ;wf[54] =w36 ;wf[55] =w42;
			wf[57] =w7 ;wf[58] =w14 ;	wf[59] =w21 ;wf[60] =w28 ;
			wf[61] =w35 ;wf[62] =w42 ;wf[63] =w49;
		end
	
	parameter[31:0] wi0= {pc0,ps0};   
	parameter[31:0] wi1= {pc1,ps1};
	parameter[31:0] wi2= {pc2,ps2};
	parameter[31:0] wi3= {pc3,ps3};
	parameter[31:0] wi4= {pc4,ps4};
	parameter[31:0] wi5= {pc5,ps5};
	parameter[31:0] wi6= {pc6,ps6};
	parameter[31:0] wi7= {pc7,ps7};
	parameter[31:0] wi8= {pc8,pc8};
	parameter[31:0] wi9= {ps7,pc7};
	parameter[31:0] wi10= {ps6,pc6};
	parameter[31:0] wi12= {ps4,pc4};
	parameter[31:0] wi14= {ps2,pc2};
	parameter[31:0] wi15= {ps1,pc1};
	parameter[31:0] wi16= {ps0,pc0};
	parameter[31:0] wi18= {ns2, pc2};
	parameter[31:0] wi20= {ns4, pc4};
	parameter[31:0] wi21= {ns5, pc5};
	parameter[31:0] wi24= {nc8, pc8};
	parameter[31:0] wi25= {nc7, ps7};
	parameter[31:0] wi28= {nc4, ps4};
	parameter[31:0] wi30= {nc2, ps2};
	parameter[31:0] wi35= {nc3, ns3};
	parameter[31:0] wi36= {nc4, ns4};
	parameter[31:0] wi42= {ns6, nc6};
	parameter[31:0] wi49= {ps1, nc1};		 
	
	reg [31:0] wb [0:63] ;	 
	always@(ADDR) begin
	//initial begin #10;	
			//(w0, w0, w0,  w0,  w0,  w0,  w0,  w0,	 	 // twiddle factors for IFFT
			for( i =0; i<8; i=i+1) 	 wb[i] =wi0;					
			for( i =8; i<63; i=i+8)  wb[i] =wi0;					
			wb[9] =wi1 ; wb[10] =wi2 ;    wb[11] =wi3 ;wb[12] =wi4 ;
			wb[13] =wi5 ;wb[14] =wi6 ;   wb[15] =wi7 ;
			wb[17] =wi2 ;wb[18] =wi4 ;   wb[19] =wi6 ;wb[20] =wi8 ;
			wb[21] =wi10 ;wb[22] =wi12 ;wb[23] =wi14;
			wb[25] =wi3 ;wb[26] =wi6 ;   wb[27] =wi9 ;wb[28] =wi12 ;
			wb[29] =wi15 ;wb[30] =wi18 ;wb[31] =wi21;
			wb[33] =wi4 ;wb[34] =wi8 ;	wb[35] =wi12 ;wb[36] =wi16 ;
			wb[37] =wi20 ;wb[38] =wi24 ;wb[39] =wi28;
			wb[41] =wi5 ;wb[42] =wi10 ;	wb[43] =wi15 ;wb[44] =wi20 ;
			wb[45] =wi25 ;wb[46] =wi30 ;wb[47] =wi35;
			wb[49] =wi6 ;wb[50] =wi12 ;	wb[51] =wi18 ;wb[52] =wi24 ;
			wb[53] =wi30 ;wb[54] =wi36 ;wb[55] =wi42;
			wb[57] =wi7 ;wb[58] =wi14 ;	wb[59] =wi21 ;wb[60] =wi28 ;
			wb[61] =wi35 ;wb[62] =wi42 ;wb[63] =wi49;
		end	  
	
	wire[31:0] reim;		
	
	`ifdef USFFT64paramifft
	assign reim = wb[ADDR];
	`else
	assign reim = wf[ADDR];
	`endif
	
	assign WR =reim[31:32-nw];
	assign WI=reim[15 :16-nw];
	
	
endmodule
