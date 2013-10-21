//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//   ROM with 64 samples of the sine waves at the frequencies = 1 and 3
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   `timescale 1 ns / 1 ps  
module Wave_ROM64 ( ADDR ,DATA_RE,DATA_IM,DATA_REF ); 
    	output [15:0] DATA_RE,DATA_IM,DATA_REF ;     
    	input [5:0]    ADDR ;     
    	reg [15:0] cosi[0:63];    
    	initial	  begin    
  cosi[0]=16'h7FFC;  cosi[1]=16'h7369;  cosi[2]=16'h5200;  cosi[3]=16'h26F8;
  cosi[4]=16'h0000;  cosi[5]=16'hE801;  cosi[6]=16'hE335;  cosi[7]=16'hEE2C;
  cosi[8]=16'h0000;  cosi[9]=16'h0EA2;  cosi[10]=16'h133D;  cosi[11]=16'h0CD3;
  cosi[12]=16'h0000;  cosi[13]=16'hF42E;  cosi[14]=16'hEFB1;  cosi[15]=16'hF4A3;
  cosi[16]=16'h0000;  cosi[17]=16'h0B5D;  cosi[18]=16'h104F;  cosi[19]=16'h0BD2;
  cosi[20]=16'h0000;  cosi[21]=16'hF32D;  cosi[22]=16'hECC3;  cosi[23]=16'hF15E;
  cosi[24]=16'h0000;  cosi[25]=16'h11D4;  cosi[26]=16'h1CCB;  cosi[27]=16'h17FF;
  cosi[28]=16'h0000;  cosi[29]=16'hD908;  cosi[30]=16'hAE00;  cosi[31]=16'h8C97;
  cosi[32]=16'h8004;  cosi[33]=16'h8C97;  cosi[34]=16'hAE00;  cosi[35]=16'hD908;
  cosi[36]=16'h0000;  cosi[37]=16'h17FF;  cosi[38]=16'h1CCB;  cosi[39]=16'h11D4;
  cosi[40]=16'h0000;  cosi[41]=16'hF15E;  cosi[42]=16'hECC3;  cosi[43]=16'hF32D;
  cosi[44]=16'h0000;  cosi[45]=16'h0BD2;  cosi[46]=16'h104F;  cosi[47]=16'h0B5D;
  cosi[48]=16'h0000;  cosi[49]=16'hF4A3;  cosi[50]=16'hEFB1;  cosi[51]=16'hF42E;
  cosi[52]=16'h0000;  cosi[53]=16'h0CD3;  cosi[54]=16'h133D;  cosi[55]=16'h0EA2;
  cosi[56]=16'h0000;  cosi[57]=16'hEE2C;  cosi[58]=16'hE335;  cosi[59]=16'hE801;
  cosi[60]=16'h0000;  cosi[61]=16'h26F8;  cosi[62]=16'h5200;  cosi[63]=16'h7369;
     end 

    	reg [15:0] sine[0:63];    
    	initial	  begin    
  sine[0]=16'h0000;  sine[1]=16'h2FCE;  sine[2]=16'h5200;  sine[3]=16'h5E14;
  sine[4]=16'h539C;  sine[5]=16'h39EF;  sine[6]=16'h1CCB;  sine[7]=16'h0762;
  sine[8]=16'h0000;  sine[9]=16'h060F;  sine[10]=16'h133D;  sine[11]=16'h1EF7;
  sine[12]=16'h22A1;  sine[13]=16'h1C8A;  sine[14]=16'h104F;  sine[15]=16'h04B5;
  sine[16]=16'h0000;  sine[17]=16'h04B5;  sine[18]=16'h104F;  sine[19]=16'h1C8A;
  sine[20]=16'h22A1;  sine[21]=16'h1EF7;  sine[22]=16'h133D;  sine[23]=16'h060F;
  sine[24]=16'h0000;  sine[25]=16'h0762;  sine[26]=16'h1CCB;  sine[27]=16'h39EF;
  sine[28]=16'h539C;  sine[29]=16'h5E14;  sine[30]=16'h5200;  sine[31]=16'h2FCE;
  sine[32]=16'h0000;  sine[33]=16'hD032;  sine[34]=16'hAE00;  sine[35]=16'hA1EC;
  sine[36]=16'hAC64;  sine[37]=16'hC611;  sine[38]=16'hE335;  sine[39]=16'hF89E;
  sine[40]=16'h0000;  sine[41]=16'hF9F1;  sine[42]=16'hECC3;  sine[43]=16'hE109;
  sine[44]=16'hDD5F;  sine[45]=16'hE376;  sine[46]=16'hEFB1;  sine[47]=16'hFB4B;
  sine[48]=16'h0000;  sine[49]=16'hFB4B;  sine[50]=16'hEFB1;  sine[51]=16'hE376;
  sine[52]=16'hDD5F;  sine[53]=16'hE109;  sine[54]=16'hECC3;  sine[55]=16'hF9F1;
  sine[56]=16'h0000;  sine[57]=16'hF89E;  sine[58]=16'hE335;  sine[59]=16'hC611;
  sine[60]=16'hAC64;  sine[61]=16'hA1EC;  sine[62]=16'hAE00;  sine[63]=16'hD032;
      end 

    	reg [15:0] deltas[0:63];    
    	initial	  begin    
 deltas[0]=16'h0000; deltas[1]=16'h0000; deltas[2]=16'h0000; deltas[3]=16'h0000;
 deltas[4]=16'h0000; deltas[5]=16'h0000; deltas[6]=16'h0000; deltas[7]=16'h0000;
 deltas[8]=16'h0000; deltas[9]=16'h0000; deltas[10]=16'h0000; deltas[11]=16'h0000;
 deltas[12]=16'h0000; deltas[13]=16'h0000; deltas[14]=16'h0000; deltas[15]=16'h0000;
 deltas[16]=16'h0000; deltas[17]=16'h0000; deltas[18]=16'h0000; deltas[19]=16'h0000;
 deltas[20]=16'h0000; deltas[21]=16'h0000; deltas[22]=16'h0000; deltas[23]=16'h0000;
 deltas[24]=16'h0000; deltas[25]=16'h0000; deltas[26]=16'h0000; deltas[27]=16'h0000;
 deltas[28]=16'h0000; deltas[29]=16'h0000; deltas[30]=16'h0000; deltas[31]=16'h0000;
 deltas[32]=16'h0000; deltas[33]=16'h0000; deltas[34]=16'h0000; deltas[35]=16'h0000;
 deltas[36]=16'h0000; deltas[37]=16'h0000; deltas[38]=16'h0000; deltas[39]=16'h0000;
 deltas[40]=16'h0000; deltas[41]=16'h0000; deltas[42]=16'h0000; deltas[43]=16'h0000;
 deltas[44]=16'h0000; deltas[45]=16'h0000; deltas[46]=16'h0000; deltas[47]=16'h0000;
 deltas[48]=16'h0000; deltas[49]=16'h0000; deltas[50]=16'h0000; deltas[51]=16'h0000;
 deltas[52]=16'h0000; deltas[53]=16'h0000; deltas[54]=16'h0000; deltas[55]=16'h0000;
 deltas[56]=16'h0000; deltas[57]=16'h0000; deltas[58]=16'h0000; deltas[59]=16'h0000;
 deltas[60]=16'h0000; deltas[61]=16'h0000; deltas[62]=16'h0000; deltas[63]=16'h0000;
 deltas[1]=16'h7ffc;  deltas[3]=16'h7ffc; deltas[5]=16'h7ffc; deltas[7]=16'h7ffc;
     end 

	assign DATA_RE=cosi[ADDR];	
	assign DATA_IM=sine[ADDR];	
	assign DATA_REF=deltas[ADDR];	
endmodule   
