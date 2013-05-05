module EISDSP(clock,datain,dataout,ready,geti,geto);
input clock;
input [0:71] datain;
input geti;
output geto;
output [0:71] dataout;
output ready;

cf_fft_1024_18 fft1(clock, ready, 0, geti, datain[0:35], datain[36:71],
							geto, dataout[0:35], dataout[36:71]);

endmodule