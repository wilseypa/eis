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
 * \ingroup ModMiscIpDspGpR2FftBf
 * Radix-2 DIF FFT butterfly.
 * This file implements a radix-2 DIF FFT butterfly.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/
/** \addtogroup ModMiscIpDspGpR2FftBf
 * @{ */

/** Radix-2 DIF FFT butterfly.
 * This module implements a radix-2 DIF FFT butterfly unit suitable for Cooley-Tukey
 * algorithm and its variants. The module computes a single butterfly including
 * the twiddle-factor multiplication as shown in the figure below. The butterfly
 * outputs, z<sub>a</sub> and z<sub>b</sub> are time multiplexed on to \a z_re/z_im
 * lines such that when \a z_nd is high, \a z_re/z_im will contain z<sub>a</sub>
 * and on the following clock cycle \a z_re/z_im will contain z<sub>b</sub>.
 * \image html fft_r2_bf.svg "Radix-2 DIF FFT Butterfly"
 *
 * \param[in]  clk      System clock.
 * \param[in]  rst_n    Active low asynchronous reset line.
 * \param[in]  m_in     Meta-data to pass through the pipeline.
 * \param[in]  w_re     Real part of the twiddle factor, Re{w(n)}.
 * \param[in]  w_im     Imaginary part of the twiddle factor, Im{w(n)}.
 * \param[in]  xa_re    Real part of the input, \a Re{x<sub>a</sub>}.
 * \param[in]  xa_im    Imaginary part of the input, \a Im{x<sub>a</sub>}.
 * \param[in]  xb_re    Real part of the input, \a Re{x<sub>b</sub>}.
 * \param[in]  xb_im    Imaginary part of the input, \a Im{x<sub>b</sub>}.
 * \param[in]  x_nd     Indicates new data on \a xa/xb inputs.
 * \param[out] m_out    Meta-data passed through the pipeline.
 * \param[out] z_re     Real part of the output, \a Re{z<sub>a</sub>} or \a Re{z<sub>b</sub>}.
 * \param[out] z_im     Imaginary part of the output, \a Im{z<sub>a</sub>} or \a Im{z<sub>b</sub>}.
 * \param[out] z_nd     Indicates new data on \a z_re/z_im outputs.
 * \par
 * \param[in]  W_WDTH   \a Re{w(n)}/Im{w(n)} data width.
 * \param[in]  X_WDTH   \a Re{x(n)}/Im{x(n)} data width.
 * \param[in]  Z_WDTH   \a Re{z(n)}/Im{x(n)} data width.
 * \param[in]  M_WDTH   Meta-data width.
 */
module fft_r2_bf #(
    parameter                        W_WDTH = 0,
    parameter                        X_WDTH = 0,
    parameter                        Z_WDTH = 0,
    parameter                        M_WDTH = 0
  )
  (
    input  wire                      clk,
    input  wire                      rst_n,
    input  wire         [M_WDTH-1:0] m_in,
    input  wire signed  [W_WDTH-1:0] w_re,
    input  wire signed  [W_WDTH-1:0] w_im,
    input  wire signed  [X_WDTH-1:0] xa_re,
    input  wire signed  [X_WDTH-1:0] xa_im,
    input  wire signed  [X_WDTH-1:0] xb_re,
    input  wire signed  [X_WDTH-1:0] xb_im,
    input  wire                      x_nd,
    output reg          [M_WDTH-1:0] m_out,
    output reg  signed  [Z_WDTH-1:0] z_re,
    output reg  signed  [Z_WDTH-1:0] z_im,
    output reg                       z_nd
  );

  localparam                            B_WDTH    = X_WDTH + 1;
  localparam                            P_WDTH    = B_WDTH + W_WDTH;
  localparam                            S_WDTH    = P_WDTH + 1;
  localparam signed [S_WDTH-Z_WDTH-2:0] RND_CONST = 2**(S_WDTH-Z_WDTH-3);
  localparam                            PPLN_DPTH = 6;

  reg  signed [B_WDTH-1:0] ppln_ba_re [0:0];
  reg  signed [B_WDTH-1:0] ppln_ba_im [0:0];
  reg  signed [B_WDTH-1:0] ppln_bb_re [0:0];
  reg  signed [B_WDTH-1:0] ppln_bb_im [0:0];
  reg  signed [W_WDTH-1:0] ppln_mul1_y[0:0];
  reg  signed [W_WDTH-1:0] ppln_mul2_y[0:0];
  reg  signed [P_WDTH-1:0] ppln_mul1_z[3:3];
  reg  signed [P_WDTH-1:0] ppln_mul2_z[3:3];
  reg  signed [B_WDTH-1:0] ppln_za_re [4:1];
  reg  signed [B_WDTH-1:0] ppln_za_im [4:1];
  reg  signed [S_WDTH-1:0] ppln_zb_re [5:3];
  reg  signed [S_WDTH-1:0] ppln_zb_im [5:4];
  reg         [M_WDTH-1:0] ppln_meta  [PPLN_DPTH-2:0];
  reg      [PPLN_DPTH-2:0] ppln_nd;

  wire signed [P_WDTH-1:0] mul1_z;
  wire signed [P_WDTH-1:0] mul2_z;

  integer                  i;

  initial
    begin
     `ifndef USE_RESET
      z_nd           = 1'b0;
      z_re           = {Z_WDTH{1'b0}};
      z_im           = {Z_WDTH{1'b0}};
      m_out          = {M_WDTH{1'b0}};
      ppln_ba_re [0] = {B_WDTH{1'b0}};
      ppln_ba_im [0] = {B_WDTH{1'b0}};
      ppln_bb_re [0] = {B_WDTH{1'b0}};
      ppln_bb_im [0] = {B_WDTH{1'b0}};
      ppln_mul1_y[0] = {W_WDTH{1'b0}};
      ppln_mul2_y[0] = {W_WDTH{1'b0}};
      ppln_za_re [1] = {B_WDTH{1'b0}};
      ppln_za_im [1] = {B_WDTH{1'b0}};
      ppln_za_re [2] = {B_WDTH{1'b0}};
      ppln_za_im [2] = {B_WDTH{1'b0}};
      ppln_mul1_z[3] = {S_WDTH{1'b0}};
      ppln_mul2_z[3] = {S_WDTH{1'b0}};
      ppln_zb_re [3] = {S_WDTH{1'b0}};
      ppln_zb_re [4] = {S_WDTH{1'b0}};
      ppln_zb_im [4] = {S_WDTH{1'b0}};
      ppln_zb_re [5] = {S_WDTH{1'b0}};
      ppln_zb_im [5] = {S_WDTH{1'b0}};
      ppln_nd        = {PPLN_DPTH-1{1'b0}};
      for (i = 0; i < PPLN_DPTH-1; i = i+1) ppln_meta[i] = {M_WDTH{1'b0}};
     `endif
    end

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          z_nd           <= 1'b0;
          z_re           <= {Z_WDTH{1'b0}};
          z_im           <= {Z_WDTH{1'b0}};
          m_out          <= {M_WDTH{1'b0}};
          ppln_ba_re [0] <= {B_WDTH{1'b0}};
          ppln_ba_im [0] <= {B_WDTH{1'b0}};
          ppln_bb_re [0] <= {B_WDTH{1'b0}};
          ppln_bb_im [0] <= {B_WDTH{1'b0}};
          ppln_mul1_y[0] <= {W_WDTH{1'b0}};
          ppln_mul2_y[0] <= {W_WDTH{1'b0}};
          ppln_za_re [1] <= {B_WDTH{1'b0}};
          ppln_za_im [1] <= {B_WDTH{1'b0}};
          ppln_za_re [2] <= {B_WDTH{1'b0}};
          ppln_za_im [2] <= {B_WDTH{1'b0}};
          ppln_mul1_z[3] <= {S_WDTH{1'b0}};
          ppln_mul2_z[3] <= {S_WDTH{1'b0}};
          ppln_zb_re [3] <= {S_WDTH{1'b0}};
          ppln_zb_re [4] <= {S_WDTH{1'b0}};
          ppln_zb_im [4] <= {S_WDTH{1'b0}};
          ppln_zb_re [5] <= {S_WDTH{1'b0}};
          ppln_zb_im [5] <= {S_WDTH{1'b0}};
          ppln_nd        <= {PPLN_DPTH-1{1'b0}};
          for (i = 0; i < PPLN_DPTH-1; i = i+1) ppln_meta[i] <= {M_WDTH{1'b0}};
         `endif
        end
      else
        begin
          /* PIPELINE STAGE 0:
           *   1. Compute butterfly outputs:
           *        x'(2n)   = x(n) + x(n+N/2)
           *        x'(2n+1) = x(n) - x(n+N/2)
           *          where:
           *            Re{x(n)}     = xa_re
           *            Im{x(n)}     = xa_im
           *            Re{x(n+N/2)} = xb_re
           *            Im{x(n+N/2)} = xb_im
           *            Re{x'(2n)}   = ba_re
           *            Im{x'(2n)}   = ba_im
           *            Re{x'(2n+1)} = bb_re
           *            Im{x'(2n+1)} = bb_im
           */
          if (x_nd)
            begin
              ppln_ba_re[0] <= xa_re + xb_re;
              ppln_ba_im[0] <= xa_im + xb_im;
              ppln_bb_re[0] <= xa_re - xb_re;
              ppln_bb_im[0] <= xa_im - xb_im;
            end
          ppln_meta     [0] <= m_in;
          ppln_mul1_y   [0] <= x_nd ? w_re : w_im;
          ppln_mul2_y   [0] <= x_nd ? w_im : w_re;
          ppln_nd       [0] <= x_nd;

          /* PIPELINE STAGE 1:
           *   1. Wait for the multiplier to complete its pipleine stateg-0.
           */
          ppln_za_re    [1] <= ppln_ba_re[0];
          ppln_za_im    [1] <= ppln_ba_im[0];
          ppln_meta     [1] <= ppln_meta [0];
          ppln_nd       [1] <= ppln_nd   [0];

          /* PIPELINE STAGE 2:
           *   1. Wait for the multiplier to complete its pipleine stateg-1.
           */
          ppln_za_re    [2] <= ppln_za_re[1];
          ppln_za_im    [2] <= ppln_za_im[1];
          ppln_meta     [2] <= ppln_meta [1];
          ppln_nd       [2] <= ppln_nd   [1];

          /* PIPELINE STAGE 3:
           *   1. Add the rounding constant to the complex multiplication result.
           */
          ppln_mul1_z   [3] <= mul1_z + RND_CONST;
          ppln_mul2_z   [3] <= mul2_z;
          ppln_za_re    [3] <= ppln_za_re [2];
          ppln_za_im    [3] <= ppln_za_im [2];
          ppln_meta     [3] <= ppln_meta  [2];
          ppln_nd       [3] <= ppln_nd    [2];

          /* PIPELINE STAGE 4:
           *   1. Compute the real part of the complex multiplication.
           */
          ppln_zb_re    [4] <= ppln_mul1_z[3] - ppln_mul2_z[3];
          ppln_za_re    [4] <= ppln_za_re [3];
          ppln_za_im    [4] <= ppln_za_im [3];
          ppln_meta     [4] <= ppln_meta  [3];
          ppln_nd       [4] <= ppln_nd    [3];

          /* PIPELINE STAGE 5:
           *   1. Compute the imaginary part of the complex multiplication.
           */
          ppln_zb_im    [5] <= ppln_mul1_z[3] + ppln_mul2_z[3];
          ppln_zb_re    [5] <= ppln_zb_re [4];

          /* PIPELINE STAGE 6:
           *   1. Scale the sums and update the outputs.
           */
          z_re <= ppln_nd[PPLN_DPTH-2] ? ppln_za_re[PPLN_DPTH-2] : ppln_zb_re[PPLN_DPTH-1][S_WDTH-3 -:Z_WDTH];
          z_im <= ppln_nd[PPLN_DPTH-2] ? ppln_za_im[PPLN_DPTH-2] : ppln_zb_im[PPLN_DPTH-1][S_WDTH-3 -:Z_WDTH];
          z_nd <= ppln_nd[PPLN_DPTH-2];
          if (ppln_nd    [PPLN_DPTH-2])
            begin
              m_out <= ppln_meta[PPLN_DPTH-2];
            end
        end
    end

  /* Instantiate the multipliers. */
  mult_35x18s #(
      .X_WDTH      (B_WDTH),
      .Y_WDTH      (W_WDTH)
    )
    mult_35x18s_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .x           (ppln_bb_re [0]),
      .y           (ppln_mul1_y[0]),
      .xy_nd       (1'b0),
      .z           (mul1_z),
      .z_nd        ()
    );

  mult_35x18s #(
      .X_WDTH      (B_WDTH),
      .Y_WDTH      (W_WDTH)
    )
    mult_35x18s_u2 (
      .clk         (clk),
      .rst_n       (rst_n),
      .x           (ppln_bb_im [0]),
      .y           (ppln_mul2_y[0]),
      .xy_nd       (1'b0),
      .z           (mul2_z),
      .z_nd        ()
    );

endmodule

/** @} */ /* End of addtogroup ModMiscIpDspGpR2FftBf */
/* END OF FILE */
