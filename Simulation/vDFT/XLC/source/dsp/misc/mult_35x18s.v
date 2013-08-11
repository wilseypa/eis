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
 * \ingroup ModMiscIpDspGpMult35x18s
 * 35x18 bit signed multiplier.
 * This file implements a 2-stage pipelined signed multiplier with configurable
 * input widths up to 35x18 bits.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/
/** \addtogroup ModMiscIpDspGpMult35x18s
 * @{ */

/** 35x18 bit signed multiplier.
 * This module implements a 2-stage pipelined signed multiplier with configurable
 * input widths up to 35x18 bits.
 *
 * \param[in]  clk     System clock.
 * \param[in]  rst_n   Active low asynchronous reset line.
 * \param[in]  x       Wide input to the multiplier (up to 35-bits).
 * \param[in]  y       The multiplicand (up to 18-bits).
 * \param[in]  xy_nd   Indicates new data on \a x/y inputs. Can be tied to GND
 *                     if pipeline tracking is not required.
 * \param[out] z       The result of the multiplication, \a x*y, valid after 2 cycles.
 * \param[out] z_nd    Indicates new data on \a z.
 * \par
 * \param[in]  X_WDTH  \a x input data width (min = 19, max = 35).
 * \param[in]  Y_WDTH  \a y input data width (max = 18).
 */
module mult_35x18s #(
    parameter                              X_WDTH    = 0,
    parameter                              Y_WDTH    = 0
  )
  (
    input  wire                            clk,
    input  wire                            rst_n,
    input  wire signed        [X_WDTH-1:0] x,
    input  wire signed        [Y_WDTH-1:0] y,
    input  wire                            xy_nd,
    output wire signed [X_WDTH+Y_WDTH-1:0] z,
    output reg                             z_nd
  );

  localparam  Z_WDTH = X_WDTH + Y_WDTH;

  wire signed        [Y_WDTH-1:0] x_hi;
  wire signed   [X_WDTH-Y_WDTH:0] x_lo;

  reg  signed      [2*Y_WDTH-1:0] prod_hi;
  reg  signed          [X_WDTH:0] prod_lo;
  wire signed        [Y_WDTH-1:0] prod_lh;
  reg                             prod_nd;

  reg  signed      [2*Y_WDTH-1:0] z_hi;
  reg  signed [X_WDTH-Y_WDTH-1:0] z_lo;

  initial
    begin
     `ifndef USE_RESET
      prod_hi = {   2*Y_WDTH-1{1'b0}};
      prod_lo = {     X_WDTH+1{1'b0}};
      prod_nd = 1'b0;
      z_hi    = {     2*Y_WDTH{1'b0}};
      z_lo    = {X_WDTH-Y_WDTH{1'b0}};
      z_nd    = 1'b0;
     `endif
    end

  assign x_hi    = x[X_WDTH-1 -: Y_WDTH];
  assign x_lo    = {1'b0, x[X_WDTH-Y_WDTH-1:0]};
  assign prod_lh = prod_lo[X_WDTH-1:X_WDTH-Y_WDTH];
  assign z       = {z_hi, z_lo};

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          prod_hi <= {   2*Y_WDTH-1{1'b0}};
          prod_lo <= {     X_WDTH+1{1'b0}};
          prod_nd <= 1'b0;
          z_hi    <= {     2*Y_WDTH{1'b0}};
          z_lo    <= {X_WDTH-Y_WDTH{1'b0}};
          z_nd    <= 1'b0;
         `endif
        end
      else
        begin
          prod_hi <= x_hi * y;
          prod_lo <= x_lo * y;
          prod_nd <= xy_nd;

          z_hi    <= prod_hi + prod_lh;
          z_lo    <= prod_lo[X_WDTH-Y_WDTH-1:0];
          z_nd    <= prod_nd;
        end
    end

endmodule

/** @} */ /* End of addtogroup ModMiscIpDspGpMult35x18s */
/* END OF FILE */
