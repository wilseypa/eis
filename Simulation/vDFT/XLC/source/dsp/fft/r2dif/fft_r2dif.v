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
 * \ingroup TopMiscIpDspFftR2Dif
 * Configurable radix-2 decimation in frequency FFT core.
 * This file implements a radix-2 decimation in frequency FFT processor 
 * core with configurable FFT lengths and I/O widths.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/
/** \addtogroup TopMiscIpDspFftR2Dif
 * @{ */

/** Configurable radix-2 decimation in frequency FFT core.
 * This module implements a radix-2 decimation in frequency FFT processor 
 * core with configurable FFT lengths and I/O widths.
 * \image html fft_r2dif_sfg_8pt.svg "Signal Flow Graph for 8-point DIF FFT"
 *
 * \param[in]  clk         System clock.
 * \param[in]  rst_n       Active low asynchronous reset line.
 * \param[in]  din_re      Real-part input data, \a Re{x(n)}.
 * \param[in]  din_im      Imaginary-part input data, \a Re{x(n)}.
 * \param[in]  din_nd      Indicates new data on \a din_re/din_im buses.
 * \param[out] dout_re     Real-part output, \a Re{X(k)}.
 * \param[out] dout_im     Imaginary-part output, \a Im{X(k)}.
 * \param[out] dout_nd     Indicates new data on \a dout_re/dout_im buses.
 * \par
 * \param[in]  N_LOG2      Desired FFT length in log<sub>2</sub>.
 * \param[in]  TF_WDTH     Twiddle factor width.
 * \param[in]  DIN_WDTH    Input data width.
 * \param[in]  DOUT_WDTH   Output data width.
 * \param[in]  EXT_FP_BITS Extended finite-pricision bits.
 */
module fft_r2dif #(
    parameter                          N_LOG2      = 0,
    parameter                          TF_WDTH     = 0,
    parameter                          DIN_WDTH    = 0,
    parameter                          DOUT_WDTH   = 0,
    parameter                          EXT_FP_BITS = 0
  )
  (
    input  wire                        clk,
    input  wire                        rst_n,
    input  wire signed  [DIN_WDTH-1:0] din_re,
    input  wire signed  [DIN_WDTH-1:0] din_im,
    input  wire                        din_nd,
    output  reg signed [DOUT_WDTH-1:0] dout_re,
    output  reg signed [DOUT_WDTH-1:0] dout_im,
    output  reg                        dout_nd
  );

  /* Define the FFT length. */
  localparam  N = 2**N_LOG2;

  /* Define the butterfly unit I/O widths. */
  localparam  X_WDTH  = cmax (TF_WDTH, DIN_WDTH+N_LOG2+EXT_FP_BITS-1);
  localparam  Z_WDTH  = X_WDTH + 1;

  /* Define the control FSM states. */
  localparam  [1:0]  FSM_ST_IDLE            = 0;
  localparam  [1:0]  FSM_ST_RD_XA           = 1;
  localparam  [1:0]  FSM_ST_CALC_BFLY       = 2;

  /* Define the butterfly I/O workspace select enumerations. */
  localparam         BF_IN_DIN_BUF          = 1'b0;
  localparam         BF_IN_WKS_BUF          = 1'b1;

  /* Declare registers for twiddle-factor ROM address. Note that the twiddle-factor 
   * ROM only store 180 degrees worth of roots of unity. 
   */
  reg           [N_LOG2-2:0] tf_addr;
  reg                        tf_addr_nd;

  /* Declare storage for the input buffer. This double buffers input samples. */
  reg       [DIN_WDTH*2-1:0] din_buf[N-1:0];
  wire      [DIN_WDTH*2-1:0] din_buf_dout;
  wire signed [DIN_WDTH-1:0] din_buf_dout_re;
  wire signed [DIN_WDTH-1:0] din_buf_dout_im;
  reg           [N_LOG2-1:0] din_wr_addr;
  reg           [N_LOG2-2:0] din_rd_cntr;
  reg                        din_buf_nd;

  /* Declare storage for workspace buffer (infers dual-port RAM). */
  reg         [X_WDTH*2-1:0] wks_buf [N-1:0];
  wire          [N_LOG2-1:0] wks_wr_addr;
  wire        [X_WDTH*2-1:0] wks_wr_data;
  wire                       wks_wr_en;
  wire        [X_WDTH*2-1:0] wks_buf_dout;

  /* Declare registers for workspace/din buffer read address. */
  reg           [N_LOG2-1:0] buf_rd_addr;
  reg           [N_LOG2-2:0] addr_gen_mask1;
  reg           [N_LOG2-2:0] addr_gen_mask2;
  wire          [N_LOG2-2:0] addr_gen_addr1;
  wire          [N_LOG2-2:0] addr_gen_addr2;
  reg           [N_LOG2-1:0] addr_gen_addr3;

  /* Declare wires to connect twiddle-factor ROM outputs. */
  wire         [TF_WDTH-1:0] tf_re;
  wire         [TF_WDTH-1:0] tf_im;

  /* Declare wires to connect the butterfly unit. */
  reg  signed   [X_WDTH-1:0] xa_re;
  reg  signed   [X_WDTH-1:0] xa_im;
  reg  signed   [X_WDTH-1:0] xb_re;
  reg  signed   [X_WDTH-1:0] xb_im;
  reg                        x_nd;
  wire signed   [Z_WDTH-1:0] z_re;
  wire signed   [Z_WDTH-1:0] z_im;
  wire                       za_nd;
  reg                        zb_nd;

  /* Declare registers for meta-data to pass through the butterfly unit. */
  reg           [N_LOG2-1:0] bf_x_addr_a;
  reg           [N_LOG2-1:0] bf_x_addr_b;
  wire          [N_LOG2-1:0] bf_z_addr_a;
  wire          [N_LOG2-1:0] bf_z_addr_b;
  reg                        bfs_x_last;
  wire                       bfs_z_last;

  /* Declare registers for a counter to track the butterfly stage being
   * processed by the FSM.
   */
  reg   [clogb2(N_LOG2)-1:0] bfs_cntr;

  /* Declare storage for the control FSM state. */
  reg                 [ 1:0] fsm_state;

  /* Declare register for butterfly input buffer select lines. */
  reg                        bf_x_buf_sel;


  /* Define the constant function, clogb2. */
 `DEF_CLOGB2

  /* Constant function to calculate the max value of 2 parameters. */
  function integer cmax (input integer a, input integer b);
    begin
      cmax = a > b ? a : b;
    end
  endfunction

  /* Function to saturate input samples to +/-(2**(DIN_WDTH-1) - 1). */
  function signed [DIN_WDTH-1:0] saturate_din (input reg [DIN_WDTH-1:0] din);
    begin
      saturate_din = {din[DIN_WDTH-1:1], din[0] | (din[DIN_WDTH-1] & ~|din[DIN_WDTH-2:0])};
    end
  endfunction

  /* Instantiate twiddle-factor ROMs for the requested FFT length. */
  generate
    case (N)
      16:
        begin
          fft_r2_rom_16 fft_r2_rom_16_u1 (
              .clk      (clk),
              .rst_n    (rst_n),
              .addr     (tf_addr),
              .addr_vld (tf_addr_nd),
              .tf_re    (tf_re),
              .tf_im    (tf_im)
            );
        end

      256:
        begin
          fft_r2_rom_256 fft_r2_rom_256_u1 (
              .clk      (clk),
              .rst_n    (rst_n),
              .addr     (tf_addr),
              .addr_vld (tf_addr_nd),
              .tf_re    (tf_re),
              .tf_im    (tf_im)
            );
        end

      1024:
        begin
          fft_r2_rom_1024 fft_r2_rom_1024_u1 (
              .clk      (clk),
              .rst_n    (rst_n),
              .addr     (tf_addr),
              .addr_vld (tf_addr_nd),
              .tf_re    (tf_re),
              .tf_im    (tf_im)
            );
        end

      4096:
        begin
          fft_r2_rom_4096 fft_r2_rom_4096_u1 (
              .clk      (clk),
              .rst_n    (rst_n),
              .addr     (tf_addr),
              .addr_vld (tf_addr_nd),
              .tf_re    (tf_re),
              .tf_im    (tf_im)
            );
        end

      default:
        begin
          assign tf_re = {TF_WDTH{1'b0}};
          assign tf_im = {TF_WDTH{1'b0}};
        end
    endcase
  endgenerate

  /* Instantiate the generic butterfly unit. */
  fft_r2_bf #(
    .W_WDTH   (TF_WDTH),
    .X_WDTH   (X_WDTH),
    .Z_WDTH   (Z_WDTH),
    .M_WDTH   (1 + N_LOG2*2)
  )
  fft_r2_bf_u1 (
    .clk      (clk),
    .rst_n    (rst_n),
    .m_in     ({bfs_x_last, bf_x_addr_a, bf_x_addr_b}),
    .w_re     (tf_re),
    .w_im     (tf_im),
    .xa_re    (xa_re),
    .xa_im    (xa_im),
    .xb_re    (xb_re),
    .xb_im    (xb_im),
    .x_nd     (x_nd),
    .m_out    ({bfs_z_last, bf_z_addr_a, bf_z_addr_b}),
    .z_re     (z_re),
    .z_im     (z_im),
    .z_nd     (za_nd)
  );

  initial
    begin
     `ifndef USE_RESET
      din_buf_nd    = 1'b0;
      din_wr_addr   = {N_LOG2{1'b0}};
      xa_re         = {X_WDTH{1'b0}};
      xa_im         = {X_WDTH{1'b0}};
      xb_re         = {X_WDTH{1'b0}};
      xb_im         = {X_WDTH{1'b0}};
      fsm_state     = FSM_ST_IDLE;
      bfs_cntr      = {clogb2(N_LOG2){1'b0}};
      bfs_x_last    = 1'b0;
      din_rd_cntr   = {N_LOG2-1{1'b0}};
      bf_x_addr_a   = {N_LOG2  {1'b0}};
      bf_x_addr_b   = {N_LOG2  {1'b0}};
      bf_x_buf_sel  = 2'd0;
      tf_addr       = {N_LOG2-1{1'b0}};
      tf_addr_nd    = 1'b0;
      x_nd          = 1'b0;
      dout_re       = {DOUT_WDTH{1'b0}};
      dout_im       = {DOUT_WDTH{1'b0}};
      dout_nd       = 1'b0;
      zb_nd         = 1'b0;
     `endif
    end


  assign din_buf_dout    = din_buf[buf_rd_addr];
  assign wks_buf_dout    = wks_buf[buf_rd_addr];

  assign din_buf_dout_re = din_buf_dout[DIN_WDTH*1-1 -:DIN_WDTH];
  assign din_buf_dout_im = din_buf_dout[DIN_WDTH*2-1 -:DIN_WDTH];

  /* Build logic to write input samples to the FFT input buffer (din_buf) and
   * to generate a one cycle trigger signal (din_buf_nd) to the state-machine
   * to start a new FFT operation when the last sample of a transform period
   * has been written. 
   */
  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          din_buf_nd  <= 1'b0;
          din_wr_addr <= {N_LOG2{1'b0}};
         `endif
        end
      else
        begin
          din_buf_nd <= &din_wr_addr;
          if (din_nd)
            begin
              din_buf[din_wr_addr] <= {din_im, din_re};
              din_wr_addr          <= din_wr_addr + 1'b1;
            end
        end
    end

  /* Build logic to read the FFT input buffer (din_buf). */
  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          xa_re <= {X_WDTH{1'b0}};
          xa_im <= {X_WDTH{1'b0}};
          xb_re <= {X_WDTH{1'b0}};
          xb_im <= {X_WDTH{1'b0}};
         `endif
        end
      else
        begin
          xa_re <= xb_re;
          xa_im <= xb_im;
          case (bf_x_buf_sel)
            BF_IN_DIN_BUF:
              begin
                xb_re <= din_buf_dout_re <<< EXT_FP_BITS;
                xb_im <= din_buf_dout_im <<< EXT_FP_BITS;
              end

            BF_IN_WKS_BUF:
              begin
                xb_re <= {wks_buf_dout[X_WDTH*1-1 -:X_WDTH]};
                xb_im <= {wks_buf_dout[X_WDTH*2-1 -:X_WDTH]};
              end

            default:
              begin
              end
          endcase
        end
    end

  assign addr_gen_addr1 = din_rd_cntr & addr_gen_mask1;
  assign addr_gen_addr2 = din_rd_cntr & addr_gen_mask2;

  /* Create an FSM to push data into the butterfly unit. */
  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          fsm_state      <= FSM_ST_IDLE;
          bfs_cntr       <= {clogb2(N_LOG2){1'b0}};
          bfs_x_last     <= 1'b0;
          addr_gen_mask1 <= {N_LOG2-1{1'b0}};
          addr_gen_mask2 <= {N_LOG2-1{1'b0}};
          addr_gen_addr3 <= {N_LOG2  {1'b0}};
          buf_rd_addr    <= {N_LOG2  {1'b0}};
          din_rd_cntr    <= {N_LOG2-1{1'b0}};
          bf_x_addr_a    <= {N_LOG2  {1'b0}};
          bf_x_addr_b    <= {N_LOG2  {1'b0}};
          bf_x_buf_sel   <= 1'b0;
          tf_addr        <= {N_LOG2-1{1'b0}};
          tf_addr_nd     <= 1'b0;
          x_nd           <= 1'b0;
         `endif
        end
      else
        begin
          case (fsm_state)
            FSM_ST_IDLE:
              begin
                bf_x_buf_sel   <= BF_IN_DIN_BUF;
                bfs_cntr       <= {clogb2(N_LOG2){1'b0}};
                bfs_x_last     <= 1'b0;
                bf_x_addr_a    <= {N_LOG2  {1'b0}};
                bf_x_addr_b    <= {N_LOG2  {1'b0}};
                din_rd_cntr    <= {N_LOG2-1{1'b0}};
                buf_rd_addr    <= {N_LOG2  {1'b0}};
                addr_gen_mask1 <= {N_LOG2-1{1'b1}};
                addr_gen_mask2 <= {N_LOG2-1{1'b0}};
                addr_gen_addr3 <= {1'b1, {N_LOG2-1{1'b0}}};
                x_nd           <= 1'b0;
                if (din_buf_nd)
                  begin
                    fsm_state  <= FSM_ST_RD_XA;
                  end
              end

            FSM_ST_RD_XA:
              begin
                buf_rd_addr   <= buf_rd_addr | addr_gen_addr3;
                bf_x_addr_b   <= buf_rd_addr;
                tf_addr       <= din_rd_cntr << bfs_cntr;
                tf_addr_nd    <= 1'b1;
                x_nd          <= 1'b0;
                bfs_x_last    <= bfs_cntr == N_LOG2-1 ? 1'b1 : 1'b0;
                bfs_cntr      <= bfs_cntr + &din_rd_cntr;
                din_rd_cntr   <= din_rd_cntr + 1'b1;
                fsm_state     <= FSM_ST_CALC_BFLY;
              end

            FSM_ST_CALC_BFLY:
              begin
                buf_rd_addr   <= {1'b0, addr_gen_addr1} | {addr_gen_addr2, 1'b0};
                bf_x_addr_a   <= bf_x_addr_b;
                bf_x_addr_b   <= buf_rd_addr;
                x_nd          <= 1'b1;
                tf_addr_nd    <= 1'b0;
                fsm_state     <= bfs_x_last & ~|din_rd_cntr ? FSM_ST_IDLE : FSM_ST_RD_XA;
                if (~|din_rd_cntr)
                  begin
                    bf_x_buf_sel   <= BF_IN_WKS_BUF;
                    addr_gen_mask1 <= {1'b0, addr_gen_mask1[N_LOG2-2:1]};
                    addr_gen_mask2 <= {1'b1, addr_gen_mask2[N_LOG2-2:1]};
                    addr_gen_addr3 <= {1'b0, addr_gen_addr3[N_LOG2-1:1]};
                  end
              end

            default:
              begin
                fsm_state <= FSM_ST_IDLE;
              end
          endcase
        end
    end

  /* Create workspace RAM write address/data busses and write enable lines. */
  assign wks_wr_en   = za_nd | zb_nd;
  assign wks_wr_addr = za_nd ? bf_z_addr_a : bf_z_addr_b;
  assign wks_wr_data = {z_im[X_WDTH-1:0], z_re[X_WDTH-1:0]};

  /* Build logic to read the butterfly output and write back to workspace. This
   * also drives the FFT processor outputs.
   */
  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          dout_re <= {DOUT_WDTH{1'b0}};
          dout_im <= {DOUT_WDTH{1'b0}};
          dout_nd <= 1'b0;
          zb_nd   <= 1'b0;
         `endif
        end
      else
        begin
          zb_nd   <= za_nd;
          dout_re <= z_re;
          dout_im <= z_im;
          dout_nd <= bfs_z_last & (za_nd | zb_nd);

          if (wks_wr_en)
            begin
              wks_buf[wks_wr_addr] <= wks_wr_data;
            end
        end
    end

endmodule

/** @} */ /* End of addtogroup TopMiscIpDspFftR2Dif */
/* END OF FILE */
