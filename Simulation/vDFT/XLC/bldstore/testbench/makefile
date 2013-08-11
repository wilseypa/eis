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
# Makefile fragment for building RTL test-benches.
# Before including this file, make sure you have set
#   TARGET_NAME, TOP_LEVEL_MODULE, VERILOG_SOURCES,
#   TOP_LEVEL_SRC_DIR & INC_DIRS
#
# E.g.
#
# TARGET_NAME       = my_module
# TOP_LEVEL_MODULE  = my_module_tb
# VERILOG_SOURCES   = my_module.v \
#                     another_module.v
#
# TOP_LEVEL_SRC_DIR = ../..
# INC_DIRS          = .
#
# TOP_LEVEL_MODULE specifies the top level module to elaborate. It is valid
# specify more than one top level modules if necessary.
#
# Original Author(s):
#   Niroshan Mahasinghe, nmahasinghe@xionlogic.com
###############################################################################

# Common parameters.
RTLSIM_TOOLCHAIN ?= xilinx
VERILOG_SOURCES  += unittest.v ut_math.v
TOP_LEVEL_MODULE += ut math

DEFINES          += UNITTEST

VPATH            += $(TOP_LEVEL_SRC_DIR)/system
INC_DIRS         += $(TOP_LEVEL_SRC_DIR)/system

DIFF_OPTS        := --ignore-all-space --ignore-blank-lines --text

WORK_DIR         := work/$(RTLSIM_TOOLCHAIN)/$(TARGET_NAME)
BLD_STORE        := $(TOP_LEVEL_SRC_DIR)/../bldstore

TVREF_DIR        := tvref
TVGEN_DIR        := tvgen
TVANA_DIR        := tvana
TVOUT_DIR        := tvout/$(RTLSIM_TOOLCHAIN)
TBCNFG_DIR       := tcnfg/$(RTLSIM_TOOLCHAIN)
TARGET_EXE_NAME  := $(WORK_DIR)/$(TARGET_NAME).exe

# Common rules.
all: $(TARGET_EXE_NAME)

$(TVREF_DIR):
	@mkdir -p $@

$(TVGEN_DIR):
	@mkdir -p $@

$(TVOUT_DIR)/$(TARGET_NAME).txt: PLUS_ARGS += TVOUT_FILE=$(TVOUT_DIR)/$(TARGET_NAME).txt
$(TVOUT_DIR)/$(TARGET_NAME).txt: $(TARGET_EXE_NAME)
	@echo "Running simulation: $(TARGET_EXE_NAME) $(TARGET_EXE_OPTS)"
	@mkdir -p $(TVOUT_DIR)
	@$(TARGET_EXE_NAME) $(TARGET_EXE_OPTS) $(TARGET_EXE_CMDLINE)

test: $(TVOUT_DIR)/$(TARGET_NAME).txt $(TVREF_DIR)/$(TARGET_NAME).txt
	@echo "Comparing $(TVREF_DIR)/$(TARGET_NAME).txt $(TVOUT_DIR)/$(TARGET_NAME).txt"
	@diff $(DIFF_OPTS) --brief $(TVREF_DIR)/$(TARGET_NAME).txt $(TVOUT_DIR)/$(TARGET_NAME).txt && \
		printf "\033[1;32mPASSED:\033[0m $(TARGET_NAME)\n" || \
		printf "\033[1;31mFAILED:\033[0m $(TARGET_NAME)\n"

analyse: $(TVOUT_DIR)/$(TARGET_NAME).txt
	@if [ -x "./tvana/$(TARGET_NAME)/$(TARGET_NAME)" ] ; then \
    ./tvana/$(TARGET_NAME)/$(TARGET_NAME) '$(TVOUT_DIR)/$(TARGET_NAME).txt' $(ANA_PARAMS); \
  else \
    echo "No executable analysis script"; \
	fi

generate: $(TVGEN_DIR)/$(TARGET_NAME)/$(TARGET_NAME)
	@$(TVGEN_DIR)/$(TARGET_NAME)/$(TARGET_NAME) $(TVGEN_ARGS)
	@rm -f $(TVOUT_DIR)/$(TARGET_NAME).txt

.PHONY: all clean test analyse generate gui

# Toolchain specific commands.
include $(BLD_STORE)/testbench/$(RTLSIM_TOOLCHAIN)/makefile

# END OF FILE
