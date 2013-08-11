/******************************************************************************
 * Copyright (c) 2010-2012, XIONLOGIC LIMITED                                 *
 * Copyright (c) 2010-2012, Niroshan Mahasinghe                               *
 * All rights reserved.                                                       *
 *                                                                            *
 * Redistribution and use in source and binary forms, with or without         *
 * modification, are permitted provided that the following conditions         *
 * are met:                                                                   *
 *                                                                            *
 *  o  Redistributions of source code must retain the above copyright         *
 *     notice, this list of conditions and the following disclaimer.          *
 *                                                                            *
 *  o  Redistributions in binary form must reproduce the above copyright      *
 *     notice, this list of conditions and the following disclaimer in        *
 *     the documentation and/or other materials provided with the             *
 *     distribution.                                                          *
 *                                                                            *
 *  o  Neither the name of XIONLOGIC LIMITED nor the names of its             *
 *     contributors may be used to endorse or promote products                *
 *     derived from this software without specific prior                      *
 *     written permission.                                                    *
 *                                                                            *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS        *
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  *
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR *
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR          *
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,      *
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,        *
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR         *
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF     *
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING       *
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS         *
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               *
 *****************************************************************************/

/*****************************************************************************
 *  Original Author(s):
 *      Niroshan Mahasinghe, nmahasinghe@xionlogic.com
 *****************************************************************************/
/** \file
 * 35x18 bit pipelined signed multiplier trialsynth wrapper.
 * This file implements the trialsynth wrapper for the 35x18 bit pipelined
 * signed multiplier.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"

/***************************************************************************
 * Manifest constants
 ***************************************************************************/
`define X_WDTH  35
`define Y_WDTH  18

/***************************************************************************
 * Modules
 ***************************************************************************/

/** 35x18 bit pipelined signed multiplier trialsynth wrapper.
 * This module implements the trialsynth wrapper for the 35x18 bit pipelined
 * signed multiplier.
 */
module mult_35x18s_ts (
    input  wire                              clk,
   `ifdef USE_RESET
    input  wire                              e_rst_n,
   `endif
    input  wire signed         [`X_WDTH-1:0] x,
    input  wire signed         [`Y_WDTH-1:0] y,
    input  wire                              xy_nd,
    output wire signed [`X_WDTH+`Y_WDTH-1:0] z,
    output wire                              z_nd
  );

  wire  rst_n;


 `ifdef USE_RESET
  assign rst_n = e_rst_n;
 `else
  assign rst_n = 1'b1;
 `endif

  /* Instantiate the DUT. */
  mult_35x18s #(
      .X_WDTH    (`X_WDTH),
      .Y_WDTH    (`Y_WDTH)
    )
    dut_u1 (
      .clk       (clk),
      .rst_n     (rst_n),
      .x         (x),
      .y         (y),
      .xy_nd     (xy_nd),
      .z         (z),
      .z_nd      (z_nd)
    );

endmodule

/* END OF FILE */
