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
#   Top-level makefile for the 35x18 bit pipelined signed multiplier trialsynth.
#
# Original Author(s):
#   Niroshan Mahasinghe, nmahasinghe@xionlogic.com
###############################################################################
FPGA_PART_NAME    = xc6slx16csg324-2

TARGET_NAME       = mult_35x18s
TOP_LEVEL_MODULE  = mult_35x18s_ts

VERILOG_SOURCES   = mult_35x18s_ts.v
VERILOG_SOURCES  += mult_35x18s.v

USER_CONST_FILE   = $(BLD_ROOT)/trialsynth.ucf
XST_CONST_FILE    = $(BLD_ROOT)/trialsynth.xcf

DEFINES           =

VPATH             = ..
INC_DIRS          = ..

TOP_LEVEL_SRC_DIR = ../../..
include $(TOP_LEVEL_SRC_DIR)/../bldstore/synthesis/makefile
