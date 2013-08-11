###############################################################################
# Copyright (c) 2010-2012, XIONLOGIC LIMITED                                  #
# Copyright (c) 2010-2012, Niroshan Mahasinghe                                #
# All rights reserved.                                                        #
#                                                                             #
# Redistribution and use in source and binary forms, with or without          #
# modification, are permitted provided that the following conditions          #
# are met:                                                                    #
#                                                                             #
#  o  Redistributions of source code must retain the above copyright          #
#     notice, this list of conditions and the following disclaimer.           #
#                                                                             #
#  o  Redistributions in binary form must reproduce the above copyright       #
#     notice, this list of conditions and the following disclaimer in         #
#     the documentation and/or other materials provided with the              #
#     distribution.                                                           #
#                                                                             #
#  o  Neither the name of XIONLOGIC LIMITED nor the names of its              #
#     contributors may be used to endorse or promote products                 #
#     derived from this software without specific prior                       #
#     written permission.                                                     #
#                                                                             #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE   #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  #
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE   #
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR         #
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF        #
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS    #
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     #
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)     #
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF      #
# THE POSSIBILITY OF SUCH DAMAGE.                                             #
###############################################################################

###############################################################################
# Description:
#   Top-level makefile the radix-2^2 single-path delay feedback FFT processor
#   testbench.
#
# Original Author(s):
#   Niroshan Mahasinghe, nmahasinghe@xionlogic.com
###############################################################################
TARGET_NAME		    = fft1024_r22sdf
TOP_LEVEL_MODULE  = fft_r22sdf_tb

VERILOG_SOURCES   = fft_r22sdf_tb.v
VERILOG_SOURCES  += $(wildcard ../fft*r22sdf*.v)
VERILOG_SOURCES  += $(wildcard ../roms/fft*r22sdf*.v)

DEFINES           = DUT_CNFG_FFT_LEN=1024     ## FFT length (number of bins).
DEFINES          += DUT_CNFG_TF_WDTH=10       ## Twidle-factor bit-width.
DEFINES          += DUT_CNFG_DIN_WDTH=8       ## Input data bit-width.
DEFINES          += DUT_CNFG_DOUT_WDTH=18     ## Output data bit-width [DOUT_WDTH = max(TF_WDTH, DIN_WDTH) + 2*(log2(FFT_LEN)/2 - 1)].
DEFINES          += DUT_CNFG_DOUT_SCALE=1

VPATH             = ..
VPATH            += $(TOP_LEVEL_SRC_DIR)/dsp/misc
VPATH            += $(TOP_LEVEL_SRC_DIR)/dsp/fft/common
INC_DIRS          = ..

TOP_LEVEL_SRC_DIR = ../../../..
include $(TOP_LEVEL_SRC_DIR)/../bldstore/testbench/makefile
