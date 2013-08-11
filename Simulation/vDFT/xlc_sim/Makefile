VERILOG_SOURCES   = fft_r22sdf_tb.v
VERILOG_SOURCES  += $(wildcard ./fft*r22sdf*.v)
VERILOG_SOURCES  += $(wildcard ./ROMs/fft*r22sdf*.v)

DEFINES           = DUT_CNFG_FFT_LEN=256      ## FFT length (number of bins).
DEFINES          += DUT_CNFG_TF_WDTH=10       ## Twidle-factor bit-width.
DEFINES          += DUT_CNFG_DIN_WDTH=8       ## Input data bit-width.
DEFINES          += DUT_CNFG_DOUT_WDTH=16     ## Output data bit-width [DOUT_WDTH = max(TF_WDTH, DIN_WDTH) + 2*(log2(FFT_LEN)/2 - 1)].
DEFINES          += DUT_CNFG_DOUT_SCALE=1

default:
    
