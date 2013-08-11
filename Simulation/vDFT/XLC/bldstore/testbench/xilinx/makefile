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
# Makefile fragment for building RTL testbenches using Xilinx ISim.
#
# Original Author(s):
#   Niroshan Mahasinghe, nmahasinghe@xionlogic.com
###############################################################################
COMPILER_OPTS      = --prj $(WORK_DIR)/$(TARGET_NAME).prj
COMPILER_OPTS     += --lib work=$(WORK_DIR)/$(TARGET_NAME)
COMPILER_OPTS     += --lib xilinxcorelib_ver
COMPILER_OPTS     += $(foreach top, $(TOP_LEVEL_MODULE), --top $(top))
COMPILER_OPTS     += $(foreach dir, $(INC_DIRS), -i $(dir))
COMPILER_OPTS     += $(foreach def, $(DEFINES), -d $(def))
COMPILER_OPTS     += -intstyle xflow
COMPILER_OPTS     += -mt on

TARGET_EXE_OPTS    = -intstyle xflow
TARGET_EXE_OPTS   += -log $(WORK_DIR)/$(TARGET_NAME).log
TARGET_EXE_OPTS   += -wdb $(TVOUT_DIR)/$(TARGET_NAME).wdb
TARGET_EXE_OPTS   += $(foreach arg, $(PLUS_ARGS), -testplusarg $(arg))

TARGET_EXE_CMDLINE = -tclbatch $(BLD_STORE)/testbench/xilinx/isim-cmdline.tcl

PRJ_FILE          := $(WORK_DIR)/$(TARGET_NAME).prj

# Make rules
$(PRJ_FILE): $(VERILOG_SOURCES) $(MAKEFILE_LIST)
	@echo " PRJ  $@"
	@mkdir -p $(WORK_DIR)
	@echo -n "verilog work " > $@
	@echo "$(abspath $(filter %.v,$^))" >> $@


$(TBCNFG_DIR)/$(TARGET_NAME).wcfg:
	@mkdir -p $(TBCNFG_DIR)
	@touch $@

$(TARGET_EXE_NAME): $(PRJ_FILE)
	@echo " FUSE $@"
	@fuse $(COMPILER_OPTS) -o $@ && mv -f fuse.log $(WORK_DIR) && touch $(TARGET_EXE_NAME)

clean:
	@rm -rf $(WORK_DIR) \
	         ./isim/$(TARGET_NAME).exe.sim \
	         $(TVOUT_DIR)/$(TARGET_NAME).txt \
	         $(TVOUT_DIR)/$(TARGET_NAME).xwv \
	         $(TVOUT_DIR)/$(TARGET_NAME).wdb > /dev/null

gui: $(TARGET_EXE_NAME) $(TBCNFG_DIR)/$(TARGET_NAME).wcfg
	@echo " GUI $(TARGET_EXE_NAME) $(TARGET_EXE_OPTS)"
	@mkdir -p $(TVOUT_DIR)
	@$(TARGET_EXE_NAME) $(TARGET_EXE_OPTS) -gui -view $(TBCNFG_DIR)/$(TARGET_NAME).wcfg -tclbatch $(BLD_STORE)/testbench/xilinx/isim-gui.tcl

# END OF FILE
