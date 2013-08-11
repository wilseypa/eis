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
# Makefile fragment for RTL synthesis using Xilinx XST.
#
# Original Author(s):
#   Niroshan Mahasinghe, nmahasinghe@xionlogic.com
##############################################################################

# Select the FPGA part name and set architecture specific defines.
FPGA_PART_NAME ?= xc3s500efg320-4

ifneq ($(findstring xc6slx, $(FPGA_PART_NAME)),)
FPGA_ARCH      := SPARTAN-6
DEFINES        += USE_DSP48A1_TILES
else
FPGA_ARCH      := SPARTAN-3E
endif

##############################################################################
#
#  FPGA Make Process Flow for Xilinx FPGAs using XST
#
#       (*.v)
#         |
#       [XST]    <-- (.xcf)
#         |
#       (.ngc)
#         |
#     [NGDBUILD] <-- (.ucf)
#         |
#     (.ngd,.pcf)
#         |
#       [MAP]
#         |
#     (.ncd,.pcf)
#         |
#       [PAR]
#         |
#       (.ncd)
#         |
#      [BITGEN]
#         |
#      (.bit)
#
##############################################################################

##############################################################################
# Synthesis Tool Configuration Options - STT
##############################################################################

# Options for XST.
XST_OPTS          += -ifn $(PRJ_FILE)
XST_OPTS          += -ofn $(NGC_FILE)
XST_OPTS          += -uc  $(XST_CONST_FILE)
XST_OPTS          += -p   $(FPGA_PART_NAME)
XST_OPTS          += -ifmt mixed                       # Input project format [vhdl|verilog|mixed] (default=mixed)
XST_OPTS          += -ofmt ngc                         # Output file format [ngc]
XST_OPTS          += -opt_mode speed                   # Optimisation goal [speed|area]
XST_OPTS          += -opt_level 2                      # Optimisation effort [1..2]
XST_OPTS          += -rtlview yes                      # Generate RTL schematic (.ngr) [yes|no|only]
XST_OPTS          += -keep_hierarchy no                # Keep hierarchy [yes|no|soft]
XST_OPTS          += -vlgincdir {$(foreach dir, $(INC_DIRS),"$(abspath $(dir))")}
XST_OPTS          += -define {$(DEFINES)}
XST_OPTS          += $(foreach top, $(TOP_LEVEL_MODULE), -top $(top))

# Options for NGDBuild.
NGDBUILD_OPTS     += -p  $(FPGA_PART_NAME)
NGDBUILD_OPTS     += -dd $(WORK_DIR)
NGDBUILD_OPTS     += -intstyle xflow

# Options for MAP.
MAP_OPTS          += -p  $(FPGA_PART_NAME)
MAP_OPTS          += -intstyle xflow
MAP_OPTS          += -ol std                           # Effort level [std|med|high].
MAP_OPTS          += -logic_opt on                     # Post-placement logic restructuring [on|off].
MAP_OPTS          += -power off                        # Power optimizations [on|off].
MAP_OPTS          += -timing                           # Perform a timing-driven packing.
MAP_OPTS          += -t 1                              # Timing-driven cost table entry [1..100].
MAP_OPTS          += -w                                # Overwrite. Allows overwrite of an existing file.
MAP_OPTS          += -detail                           # Print a more verbose map report.
ifneq ($(FPGA_ARCH), SPARTAN-6)
MAP_OPTS          += -cm area                          # Cover mode [area|speed|balanced].
endif

# Options for PAR.
PAR_OPTS          += -intstyle xflow
PAR_OPTS          += -ol std                           # Placer effort level [std|med|high]
PAR_OPTS          += -w                                # Overwrite. Allows overwrite of an existing file.
PAR_OPTS          += -nopad                            # Turns off generation of the pad report.
ifneq ($(FPGA_ARCH), SPARTAN-6)
PAR_OPTS          += -t 1                              # Placer cost table entry [1..100].
endif

# Options for BITGEN.
BITGEN_OPTS       += -w                                # Overwrite existing output file.
BITGEN_OPTS       += -g UnusedPin:Pullnone             # Leave unused pins floating.

# Options for TRCE.
TRCE_OPTS         += -intstyle xflow
TRCE_OPTS         += -timegroups
TRCE_OPTS         += -fastpaths
TRCE_OPTS         += -e 25
TRCE_OPTS         += -l 25
TRCE_OPTS         += -n 25
TRCE_OPTS         += -u 25

##############################################################################
# Synthesis Tool Configuration Options - END
##############################################################################

PRJ_FILE          :=   $(WORK_DIR)/$(TARGET_NAME).prj
NGC_FILE          :=   $(WORK_DIR)/$(TARGET_NAME).ngc
NGD_FILE          :=   $(WORK_DIR)/$(TARGET_NAME).ngd
PCF_FILE          :=   $(WORK_DIR)/$(TARGET_NAME).pcf
NCD_MAP_FILE      :=   $(WORK_DIR)/$(TARGET_NAME)_map.ncd
NCD_FILE          :=   $(WORK_DIR)/$(TARGET_NAME).ncd
STA_FILE          :=   $(WORK_DIR)/$(TARGET_NAME)_sta.ncd
BIT_FILE          := $(TARGET_DIR)/$(TARGET_NAME).bit
BGZ_FILE          := $(TARGET_DIR)/$(TARGET_NAME).bgz
TWX_FILE          := $(REPORT_DIR)/$(TARGET_NAME).twx
TWR_FILE          := $(REPORT_DIR)/$(TARGET_NAME).twr
TSI_FILE          := $(REPORT_DIR)/$(TARGET_NAME).tsi

XST_LOG           := $(REPORT_DIR)/$(TARGET_NAME)_xst.log

# 3rd party cores:
#  CORES should list the path and name of each core to be added,
#  but without any file extension. This allows the name of the
#  .v wrapper and .ngc implementation to be derrived.
VERILOG_SOURCES   += $(foreach core, $(CORES), $(addsuffix .v, $(notdir $(core))))
NGDBUILD_OPTS     += $(foreach core, $(sort $(dir $(CORES))), $(addprefix -sd , $(core)))
vpath %v $(dir $(CORES))

all: $(BIT_FILE)

$(PRJ_FILE): $(VERILOG_SOURCES) $(MAKEFILE_LIST)
	@mkdir -p $(WORK_DIR)
	@mkdir -p $(TARGET_DIR)
	@echo "Making PRJ"
	@printf "$(foreach file,$(filter %v,$^),verilog work $(file)\n)" | sed "s/^[ ]*//g" > $@;

$(NGC_FILE) $(XST_LOG): $(PRJ_FILE) $(XST_CONST_FILE)
	@echo "Running XST"
	@mkdir -p $(REPORT_DIR)
	@mkdir -p $(WORK_DIR)/xst/temp
	@echo 'set -tmpdir $(WORK_DIR)/xst/temp'   > $(WORK_DIR)/$(TARGET_NAME)_xst.scr
	@echo 'set -xsthdpdir $(WORK_DIR)/xst'    >> $(WORK_DIR)/$(TARGET_NAME)_xst.scr
	@echo 'run $(XST_OPTS)' | sed "s/ \+/ /g" >> $(WORK_DIR)/$(TARGET_NAME)_xst.scr
	@xst -ifn $(WORK_DIR)/$(TARGET_NAME)_xst.scr -ofn $(XST_LOG) -intstyle xflow
	@rm -f $(foreach top, $(TOP_LEVEL_MODULE), $(top).lso) > /dev/null
	@$(BLD_ROOT)/disp-warns $(XST_LOG)

$(NGD_FILE): $(NGC_FILE) $(USER_CONST_FILE)
	@echo "Running NGDBuild"
	@ngdbuild $(NGDBUILD_OPTS) -uc $(USER_CONST_FILE) $(NGC_FILE) $@
	@cp $(WORK_DIR)/$(TARGET_NAME).bld $(REPORT_DIR)
	@rm -rf xlnx_auto_0_xdb

$(NCD_MAP_FILE) $(PCF_FILE) $(REPORT_DIR)/$(TARGET_NAME)_map.mrp: $(NGD_FILE)
	@echo "Running MAP"
	@map $(MAP_OPTS) $(NGD_FILE) -o $(NCD_MAP_FILE) $(PCF_FILE);
	@cp $(WORK_DIR)/$(TARGET_NAME)_map.map $(REPORT_DIR)
	@cp $(WORK_DIR)/$(TARGET_NAME)_map.mrp $(REPORT_DIR)
	@mv $(foreach top, $(TOP_LEVEL_MODULE), $(top)_map.xrpt) $(WORK_DIR)

$(NCD_FILE) $(STA_FILE) $(REPORT_DIR)/$(TARGET_NAME).par: $(NCD_MAP_FILE) $(PCF_FILE)
	@echo "Running PAR"
	@par $(PAR_OPTS) $(NCD_MAP_FILE) $(NCD_FILE) $(PCF_FILE);
	@cp $(NCD_FILE) $(STA_FILE)
	@cp $(WORK_DIR)/$(TARGET_NAME).par $(REPORT_DIR)
	@mv $(foreach top, $(TOP_LEVEL_MODULE), $(top)_par.xrpt) $(WORK_DIR)
	@grep -q "Timing Score: 0 " $(WORK_DIR)/$(TARGET_NAME).par || rm -f $(NCD_FILE)
	@grep -q "Timing Score: 0 " $(WORK_DIR)/$(TARGET_NAME).par

$(BIT_FILE): $(NCD_FILE)
	@echo "Running BITGEN"
	@bitgen $(BITGEN_OPTS) $(NCD_FILE) $@ $(PCF_FILE)
	-@rm -f xilinx_device_details.xml smartpreview.twr par_usage_statistics.html
	-@mv -f $(TARGET_DIR)/$(TARGET_NAME).drc $(REPORT_DIR)
	-@mv -f $(TARGET_DIR)/$(TARGET_NAME).bgn $(REPORT_DIR)

$(TWX_FILE): $(NGD_FILE) $(USER_CONST_FILE) $(STA_FILE) $(PCF_FILE)
	@echo "Running Trace"
	@trce  $(TRCE_OPTS) $(STA_FILE) $(PCF_FILE) -f $(BLD_ROOT)/trce.xtm -o $(TWR_FILE) -tsi $(TSI_FILE) -xml $(TWX_FILE)

xst: $(NGC_FILE)

map: $(NCD_MAP_FILE)

sta: $(TWX_FILE)
	@echo "Running Timing Analiser"
	@timingan -intstyle xflow -ngd $(NGD_FILE) -ucf $(USER_CONST_FILE) $(STA_FILE) $(PCF_FILE) $(TWX_FILE)

clean:
	@rm -rf $(WORK_DIR) $(BIT_FILE) _impactbatch.log xilinx_device_details.xml > /dev/null

download: $(BIT_FILE)
	@echo "Downloading the bitstream file..."
	@LD_PRELOAD=/usr/local/lib/libusb-driver.so impact -batch $(TARGET_NAME).imp



