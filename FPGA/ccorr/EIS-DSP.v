module EIS-DSP(clock,datain,dataout,ready);
input clock;
input [0:71] datain;
output [0:71] dataout;
output ready;

cf_fft_1024_18();

endmodule
