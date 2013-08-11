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
 * Testbench for the 35x18 bit pipelined signed multiplier.
 * This file implements the testbench for the 35x18 bit pipelined signed 
 * multiplier module.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"
`include "unittest.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/

/** Transactor for the 35x18 bit pipelined signed multiplier testbench.
 * This module implements the transactor for the 35x18 bit pipelined signed
 * multiplier testbench.
 */
module mult_35x18s_xct #(
    parameter          X_WDTH = 0,
    parameter          Y_WDTH = 0
  )
  (
    input  wire                     clk, 
    output reg                      rst_n,
    output wire signed [X_WDTH-1:0] x,
    output wire signed [Y_WDTH-1:0] y,
    output reg                      xy_nd
  );

  integer n, m;
  reg     done;
  reg     ce;

  initial rst_n = 1'b1;

  initial
    begin
     `ifndef USE_RESET
      n     = -(2**(X_WDTH-1));
      m     = -(2**(Y_WDTH-1));
      done  = 1'b0;
      xy_nd = 1'b0;
     `endif
    end

  assign x = n[X_WDTH-1:0];
  assign y = m[Y_WDTH-1:0];

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          n     <= -(2**(X_WDTH-1));
          m     <= -(2**(Y_WDTH-1));
          done  <= 1'b0;
          xy_nd <= 1'b0;
         `endif
        end
      else if (ce & !done)
        begin
          if (m == 2**(Y_WDTH-1) - 1)
            begin
              if (n == 2**(X_WDTH-1) - 1)
                begin
                  done <= 1'b1;
                end
              n <= n + 1;
              m <= -(2**(Y_WDTH-1));
            end
          else
            begin
              m <= m + 1;
            end
          xy_nd <= 1'b1;
        end
      else
        begin
          xy_nd <= 1'b0;
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
      clk_delay (2);

      /* Assert the reset line, wait for 1 cycle and then de-assert the reset. 
       */
     `ifdef USE_RESET
      rst_n = 1'b0;
     `endif
      ce    = 1'b0;
      clk_delay (2);
      rst_n = 1'b1;

      /* Wait for 2 dummy cycles to see reset values in the waveform. */
      clk_delay (2);
    end
  endtask

  task run ();
    begin
      ce = 1'b1;
      wait (done);
      ce = 1'b0;
      clk_delay (8);
    end
  endtask

endmodule

/** Monitor for the 35x18 bit pipelined signed multiplier testbench.
 * This module implements the monitor for the 35x18 bit pipelined signed
 * multiplier testbench.
 */
module mult_35x18s_mon #(
    parameter          X_WDTH  = 0,
    parameter          Y_WDTH  = 0,
    parameter          Z_WDTH  = 0
  )
  (
    input wire                     clk,
    input wire                     rst_n,
    input wire signed [X_WDTH-1:0] x,
    input wire signed [Y_WDTH-1:0] y,
    input wire                     xy_nd,
    input wire signed [Z_WDTH-1:0] z,
    input wire                     z_nd
  );

  localparam  PPLN_DPTH = 2;

  integer                  ecntr, tcntr;
  reg  signed [X_WDTH-1:0] x_mon[PPLN_DPTH-1:0];
  reg  signed [Y_WDTH-1:0] y_mon[PPLN_DPTH-1:0];
  reg  signed [Z_WDTH-1:0] z_ref;
  integer                  i;

 `ifndef USE_RESET
  initial
    begin
      ecntr = 0;
      tcntr = 0;
      z_ref = {Z_WDTH{1'b0}};
      for (i = 0; i < PPLN_DPTH-1; i = i+1) x_mon[i] = {X_WDTH{1'b0}};
      for (i = 0; i < PPLN_DPTH-1; i = i+1) y_mon[i] = {Y_WDTH{1'b0}};
    end
 `endif

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          ecntr <= 0;
          tcntr <= 0;
          z_ref <= {Z_WDTH{1'b0}};
          for (i = 0; i < PPLN_DPTH-1; i = i+1) x_mon[i] <= {X_WDTH{1'b0}};
          for (i = 0; i < PPLN_DPTH-1; i = i+1) y_mon[i] <= {Y_WDTH{1'b0}};
         `endif
        end
      else
        begin
          x_mon[0] <= x;
          y_mon[0] <= y;
          x_mon[1] <= x_mon[0];
          y_mon[1] <= y_mon[0];
          z_ref    <= x_mon[PPLN_DPTH-2] * y_mon[PPLN_DPTH-2];

          tcntr <= tcntr + z_nd;
          if (z_nd && (z != z_ref))
            begin
              ecntr <= ecntr+1;
            end
          if (z_nd & 1'b0)
            begin
              $fdisplay (ut.tvout_chan, "%d: %d %d => %d", tcntr,
                  x_mon[PPLN_DPTH-1], 
                  y_mon[PPLN_DPTH-1], 
                  z_ref, z);
            end
        end
    end

  task log_res ();
    begin
      if ((tcntr > 0) && (ecntr == 0))
        begin
          $fdisplay (ut.tvout_chan, "PASSED");
        end
      else
        begin
          $fdisplay (ut.tvout_chan, "FAILED: %0d/%0d failed", ecntr,  tcntr);
        end
    end
  endtask


endmodule

/** Main entry point of the 35x18 bit pipelined signed multiplier testbench.
 */
module mult_35x18s_tb;

  localparam  X_WDTH = 7;
  localparam  Y_WDTH = 4;
  localparam  Z_WDTH = X_WDTH + Y_WDTH;

  /* Declare simulation clock/reset lines. */
  reg                      clk = 1'b1;
  wire                     rst_n;

  /* Declare wires to connect the DUT to a transactor and a monitor. */
  wire signed [X_WDTH-1:0] x;
  wire signed [Y_WDTH-1:0] y;
  wire signed [Z_WDTH-1:0] z;
  wire                     xy_nd;
  wire                     z_nd;


  /* Make a regular pulsing clock. */
  always #5 clk = !clk;

  /* Instantiate the DUT. */
  mult_35x18s #(
      .X_WDTH      (X_WDTH),
      .Y_WDTH      (Y_WDTH)
    )
    dut_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .x           (x),
      .y           (y),
      .xy_nd       (xy_nd),
      .z           (z),
      .z_nd        (z_nd)
    );

  /* Instantiate the transactor for the DUT. */
  mult_35x18s_xct #(
      .X_WDTH      (X_WDTH),
      .Y_WDTH      (Y_WDTH)
    )
    xct_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .x           (x),
      .y           (y),
      .xy_nd       (xy_nd)
    );

  /* Instantiate the monitor for the DUT. */
  mult_35x18s_mon #(
      .X_WDTH      (X_WDTH),
      .Y_WDTH      (Y_WDTH),
      .Z_WDTH      (Z_WDTH)
    )
    mon_u1 (
      .clk         (clk),
      .rst_n       (rst_n),
      .x           (x),
      .y           (y),
      .xy_nd       (xy_nd),
      .z           (z),
      .z_nd        (z_nd)
    );

  initial
    begin: tb_main
      /* Assert global reset. */
      xct_u1.gen_reset;

      /* Run the simulation. */
      xct_u1.run;
      mon_u1.log_res;
      $finish;
    end
endmodule

/* END OF FILE */
