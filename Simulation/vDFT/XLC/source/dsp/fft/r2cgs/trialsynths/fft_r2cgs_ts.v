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
 * Radix-2 constant geomentry structure FFT processor trialsynth wrapper.
 * This file implements the trialsynth wrapper for the radix-2 constant 
 * geomentry structure FFT processor.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"

/***************************************************************************
 * Manifest constants
 ***************************************************************************/
`define  N_LOG2       `DUT_CNFG_FFT_LEN_LOG2
`define  TF_WDTH      `DUT_CNFG_TF_WDTH
`define  DIN_WDTH     `DUT_CNFG_DIN_WDTH
`define  DOUT_WDTH   (`DUT_CNFG_DIN_WDTH+`DUT_CNFG_FFT_LEN_LOG2+`DUT_CNFG_EXT_PRECISION_BITS)
`define  EXT_FP_BITS  `DUT_CNFG_EXT_PRECISION_BITS

/***************************************************************************
 * Modules
 ***************************************************************************/

/** Radix-2 constant geomentry structure FFT processor trialsynth wrapper.
 * This module implements the trialsynth wrapper for the radix-2 constant 
 * geomentry structure FFT processor.
 */
module fft_r2cgs_ts (
    input  wire                         clk,
   `ifdef USE_RESET
    input  wire                         e_rst_n,
   `endif
    input  wire signed  [`DIN_WDTH-1:0] din_re,
    input  wire signed  [`DIN_WDTH-1:0] din_im,
    input  wire                         din_nd,
    output wire signed [`DOUT_WDTH-1:0] dout_re,
    output wire signed [`DOUT_WDTH-1:0] dout_im,
    output wire                         dout_nd
  );

  wire  rst_n;


 `ifdef USE_RESET
  assign rst_n = e_rst_n;
 `else
  assign rst_n = 1'b1;
 `endif

  /* Instantiate the DUT. */
  fft_r2cgs #(
      .N_LOG2      (`N_LOG2),
      .TF_WDTH     (`TF_WDTH),
      .DIN_WDTH    (`DIN_WDTH),
      .DOUT_WDTH   (`DOUT_WDTH),
      .EXT_FP_BITS (`EXT_FP_BITS)
    )
    dut_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .din_re      (din_re),
      .din_im      (din_im),
      .din_nd      (din_nd),
      .dout_re     (dout_re),
      .dout_im     (dout_im),
      .dout_nd     (dout_nd)
    );

endmodule

/* END OF FILE */
