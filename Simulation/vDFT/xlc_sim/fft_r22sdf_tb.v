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
 * Testbench for the radix-2^2 single-path delay feedback FFT processor.
 * This file implements the testbench for the radix-2^2 single-path delay 
 * feedback FFT processor.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"
`include "unittest.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/

/** Transactor for the radix-2^2 single-path delay feedback FFT processor testbench.
 * This module implements the transactor for the radix-2^2 single-path delay 
 * feedback FFT processor testbench.
 */
module fft_r22sdf_xct #(
    parameter          N_LOG2   = 0,
    parameter          DIN_WDTH = 0
  )
  (
    input  wire                       clk, 
    output reg                        rst_n,
    input  wire                       done,
    output reg  signed [DIN_WDTH-1:0] d_in_i,
    output reg  signed [DIN_WDTH-1:0] d_in_q,
    output reg                        d_in_nd
  );

  localparam  N                          = 2**N_LOG2;
  localparam  NUM_CYCLES_PER_SAMPLE_PAIR = 1;
  localparam  DIN_GAP_ENABLE_GAPS        = 1;
  localparam  DIN_GAP_SPAN_SAMPLES       = 9;
  localparam  DIN_GAP_WDTH_SAMPLES       = 3;
  localparam  DIN_GAP_START_SAMPLE       = 3;
  localparam  TVIN_BLOCK_LEN_MAX         = 2**16;

  /* Declare a memory array to hold a frame of Rx I/Q samples at sample the 
   * rate. */
  reg  signed [7:0] tvin_mem[2*TVIN_BLOCK_LEN_MAX-1:0];
  integer           tvin_mem_addr;
  integer           tvin_len;
  reg               send_next_d_in;
  reg               xct_ce;
  integer           ccntr;
  integer           gcntr;
  integer           wcntr;
  integer           i;


  initial rst_n = 1'b1;

  initial
    begin
     `ifndef USE_RESET
      d_in_i        = {DIN_WDTH{1'b0}};
      d_in_q        = {DIN_WDTH{1'b0}};
      tvin_mem_addr = 0;
      tvin_len      = 0;
      for (i = 0; i < TVIN_BLOCK_LEN_MAX; i = i + 1)
        begin
          tvin_mem[i][0] = 8'd0;
          tvin_mem[i][1] = 8'd0;
        end

      send_next_d_in = 1'b0;
      ccntr          = 0;
      gcntr          = DIN_GAP_START_SAMPLE+2;
      wcntr          = DIN_GAP_WDTH_SAMPLES;
     `endif
    end

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          d_in_i        <= {DIN_WDTH{1'b0}};
          d_in_q        <= {DIN_WDTH{1'b0}};
          tvin_mem_addr <= 0;
          tvin_len      <= 0;
          for (i = 0; i < TVIN_BLOCK_LEN_MAX; i = i + 1)
            begin
              tvin_mem[i][0] <= 8'd0;
              tvin_mem[i][1] <= 8'd0;
            end
         `endif
        end
      else
        begin
          if (xct_ce && send_next_d_in)
            begin
              /* Read a new sample pair. */
              d_in_i        <= tvin_mem[tvin_mem_addr][0];
              d_in_q        <= tvin_mem[tvin_mem_addr][1];
              d_in_nd       <= 1'b1;
              tvin_mem_addr <= tvin_mem_addr + 16'd1;
            end
          else
            begin
              d_in_i        <= {8{1'bX}};
              d_in_q        <= {8{1'bX}};
              d_in_nd       <= 1'b0;
            end
        end
    end

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          send_next_d_in <= 1'b0;
          ccntr          <= 0;
          gcntr          <= DIN_GAP_START_SAMPLE+2;
          wcntr          <= DIN_GAP_WDTH_SAMPLES;
         `endif
        end
      else 
        begin
          if ((ccntr == 0) && (gcntr != 0))
            begin
              send_next_d_in <= 1'b1;
            end
          else
            begin
              send_next_d_in <= 1'b0;
            end

          if (DIN_GAP_ENABLE_GAPS)
            begin
              if (gcntr == 0)
                begin
                  if (wcntr == 0)
                    begin
                      gcntr <= DIN_GAP_SPAN_SAMPLES;
                      wcntr <= DIN_GAP_WDTH_SAMPLES-1;
                    end
                  else
                    begin
                      wcntr <= wcntr - 1;
                    end
                end
              else
                begin
                  gcntr <= gcntr - 1;
                  wcntr <= DIN_GAP_WDTH_SAMPLES-1;
                end
            end

          if (ccntr == NUM_CYCLES_PER_SAMPLE_PAIR-1)
            begin
              ccntr <= 0;
            end
          else
            begin
              ccntr <= ccntr + 1;
            end
        end
    end

  task clk_delay (
      input integer num_delay_cycles
    );
    begin
      repeat (num_delay_cycles) @ (posedge clk);
    end
  endtask

  task gen_reset ();
    begin
      /* Assert the reset line, wait for 1 cycle and then de-assert the reset. 
       */
     `ifdef USE_RESET
      rst_n       = 1'b0;
     `endif
      mon_u1.done = 1'b0;
      xct_ce      = 1'b0;
      d_in_nd     = 1'b0;
      clk_delay (1);
      rst_n       = 1'b1;

      /* Wait for 2 dummy cycles to see reset values in the waveform. */
      clk_delay (2);
    end
  endtask

  task load_tvin (input reg [8*256:1] file_name);
    begin : load_tvin_task
      integer          file, i, n_items_read;
      reg signed [7:0] tvin_i, tvin_q;
      reg              read_done;

      read_done     = 0;
      tvin_len      = 0;
      tvin_mem_addr = 0;
      file          = $fopen (file_name, "r");
      if (file >= 0)
        begin
          $display ("Failed to open test vector input file, `%0s'", file_name);
          $finish;
        end

      while (!read_done)
        begin
          n_items_read = $fscanf (file,"%d  %d\n", tvin_i, tvin_q);
          if (n_items_read == 2)
            begin
              tvin_mem[tvin_len][0] = tvin_i;
              tvin_mem[tvin_len][1] = tvin_q;
              tvin_len              = tvin_len + 1;
              if (tvin_len == TVIN_BLOCK_LEN_MAX-1)
                begin
                  read_done = 1'b1;
                end
            end
          else
            begin
              read_done = 1'b1;
            end
        end
      $fclose (file);
    end
  endtask

  task run_fft ();
    begin
      xct_ce = 1'b1;
      wait (done || (tvin_mem_addr == tvin_len)) xct_ce = 1'b0;
    end
  endtask

endmodule

/** Monitor for the radix-2^2 single-path delay feedback FFT processor testbench.
 * This module implements the monitor for the radix-2^2 single-path delay 
 * feedback FFT processor testbench.
 */
module fft_r22sdf_mon #(
    parameter          N_LOG2     = 0,
    parameter          DOUT_WDTH  = 0,
    parameter          DOUT_SCALE = 0
  )
  (
    input wire                        clk,
    input wire                        rst_n,
    input wire signed [DOUT_WDTH-1:0] d_out_i,
    input wire signed [DOUT_WDTH-1:0] d_out_q,
    input wire                        d_out_nd,
    output reg                        done
  );

  localparam  MAX_SIM_TRANSFORMS = 5;

  reg        [ 7:0] blk_id;
  reg  [N_LOG2-1:0] bin_id;
  wire [N_LOG2-1:0] bin_id_rev;
  genvar       k;

  generate
    for (k = 0; k < N_LOG2; k = k+1)
      begin: gen_bit_rev
        assign bin_id_rev[N_LOG2-1-k] = bin_id[k];
      end
  endgenerate

 `ifndef USE_RESET
  initial
    begin
      bin_id = {N_LOG2{1'b0}};
      blk_id =  8'd0;
      done   =  1'b0;
    end
 `endif

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          bin_id <= {N_LOG2{1'b0}};
          blk_id <=  8'd0;
          done   <=  1'b0;
         `endif
        end
      else
        begin
          if (d_out_nd & !done)
            begin
              $fdisplay (ut.tvout_chan, "%d: X[%d] => %12.2f %12.2f",
                         blk_id,
                         bin_id_rev,
                         $itor(d_out_i)/DOUT_SCALE,
                         $itor(d_out_q)/DOUT_SCALE);

              bin_id <= bin_id + 1'b1;
              if (&bin_id)
                begin
                  $fdisplay (ut.tvout_chan, "");
                  blk_id <= blk_id + 1'b1;
                  done   <= blk_id == MAX_SIM_TRANSFORMS-1 ? 1'b1 : 1'b0;
                end
            end
        end
    end

endmodule

/** Main entry point of the radix-2^2 single-path delay feedback FFT processor
 * testbench.
 */
module fft_r22sdf_tb;

  /* Define the constant function, clogb2. */
 `DEF_CLOGB2

  /* Setup DUT configuration parameters. */
  localparam  N          = 256;
  localparam  TF_WDTH    = 10;
  localparam  DIN_WDTH   = 8;
  localparam  DOUT_WDTH  = 16;
  localparam  DOUT_SCALE = 1;

  /* Declare simulation clock/reset lines. */
  reg                         clk = 1'b1;
  wire                        rst_n;

  /* Declare wires to connect the DUT to a transactor and a monitor. */
  wire signed  [DIN_WDTH-1:0] d_in_i;
  wire signed  [DIN_WDTH-1:0] d_in_q;
  wire                        d_in_nd;
  wire signed [DOUT_WDTH-1:0] d_out_i;
  wire signed [DOUT_WDTH-1:0] d_out_q;
  wire                        d_out_nd;
  wire                        done;


  /* Make a regular pulsing clock. */
  always #5 clk = !clk;

  /* Instantiate the DUT. */
  fft_r22sdf #(
      .N_LOG2      (8),
      .TF_WDTH     (TF_WDTH),
      .DIN_WDTH    (DIN_WDTH),
      .DOUT_WDTH   (DOUT_WDTH),
      .META_WDTH   (1)
    )
    dut_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .din_meta    (1'b0),
      .din_re      (d_in_i),
      .din_im      (d_in_q),
      .din_nd      (d_in_nd),
      .dout_meta   (),
      .dout_re     (d_out_i),
      .dout_im     (d_out_q),
      .dout_nd     (d_out_nd)
    );

  /* Instantiate the transactor for the DUT. */
  fft_r22sdf_xct #(
      .N_LOG2      (8),
      .DIN_WDTH    (DIN_WDTH)
    )
    xct_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .done        (done),
      .d_in_i      (d_in_i),
      .d_in_q      (d_in_q),
      .d_in_nd     (d_in_nd)
    );

  /* Instantiate the monitor for the DUT. */
  fft_r22sdf_mon #(
      .N_LOG2      (8),
      .DOUT_WDTH   (DOUT_WDTH),
      .DOUT_SCALE  (DOUT_SCALE)
    )
    mon_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .d_out_i     (d_out_i),
      .d_out_q     (d_out_q),
      .d_out_nd    (d_out_nd),
      .done        (done)
    );

  initial
    begin: tb_main
      reg [8*256:1] tvin_file;

        $dumpfile("test.vcd");
        $dumpvars();

      /* Assert global reset. */
      xct_u1.gen_reset;

      /* Load test vectors. */
      $swrite (tvin_file, "./tvin/fft%0d_tv0.dat", N);
      xct_u1.load_tvin (tvin_file);

      /* Run the simulation. */
      xct_u1.run_fft;
      $finish;
    end
endmodule

/* END OF FILE */
