###############################################################################
# Copyright (c) 2010-2012, XIONLOGIC LIMITED                                  #
# Copyright (c) 2008-2012, Niroshan Mahasinghe                                #
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
# Makefile fragment for RTL synthesis.
# Before including this file, make sure you have set
#   TARGET_NAME, TOP_LEVEL_MODULE, FPGA_PART_NAME, USER_CONST_FILE,
#   VERILOG_SOURCES, TOP_LEVEL_SRC_DIR & INC_DIRS
#
# E.g.
#
# TARGET_NAME       = my_design
#
# TOP_LEVEL_MODULE  = my_design_top
# USER_CONST_FILE   = my_design.ucf
#
# FPGA_PART_NAME    = xc3s500efg320-4
# VERILOG_SOURCES   = my_module_1.v \
#                     my_module_2.v
#
# TOP_LEVEL_SRC_DIR = ../../source
# INC_DIRS          = .
#
# Original Author(s):
#   Niroshan Mahasinghe, nmahasinghe@xionlogic.com
##############################################################################

# Common parameters.
RTLSYNTH_TOOLCHAIN ?= xilinx
VPATH              += $(TOP_LEVEL_SRC_DIR)/system
INC_DIRS           += $(TOP_LEVEL_SRC_DIR)/system

WORK_DIR           := work/$(RTLSYNTH_TOOLCHAIN)/$(TARGET_NAME)
TARGET_DIR         := $(WORK_DIR)/out
REPORT_DIR         := $(WORK_DIR)/reports
BLD_STORE          := $(TOP_LEVEL_SRC_DIR)/../bldstore
BLD_ROOT           := $(BLD_STORE)/synthesis/$(RTLSYNTH_TOOLCHAIN)

.PHONY: all clean download

# Toolchain specific commands.
include $(BLD_STORE)/synthesis/$(RTLSYNTH_TOOLCHAIN)/makefile

# END OF FILE
