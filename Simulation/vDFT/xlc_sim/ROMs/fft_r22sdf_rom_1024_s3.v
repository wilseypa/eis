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
 * \ingroup ModMiscIpDspFftR22Sdc
 * TFM stage-3 twiddle-factor ROM for 1024-point radix-2<sup>2</sup> SDF FFT
 * processors.
 * This file implements the TFM stage-3 twiddle-factor ROM for 1024-point
 * radix-2<sup>2</sup> SDF FFT processors.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/
/** \addtogroup ModMiscIpDspFftR22Sdc
 * @{
 */

/** TFM stage-3 twiddle-factor ROM for 1024-point radix-2<sup>2</sup> SDF FFT 
 * processors.
 * This module implements the stage-3 twiddle-factor ROM for 1024-point radix-2<sup>2</sup>
 * SDF FFT processors. It outputs the twiddle-factor, W<sup>nk</sup> for a given
 * \a nk one cycle later.
 *
 * \param[in]  clk      System clock.
 * \param[in]  rst_n    Active low asynchronous reset line.
 * \param[in]  addr     Twiddle-factor ROM address (i.e. \a nk) to read.
 * \param[in]  addr_vld Indicates that the read address is valid.
 * \param[out] tf_re    Twiddle-factor output (real part).
 * \param[out] tf_im    Twiddle-factor output (imaginary part).
 */
module fft_r22sdf_rom_1024_s3 (
    input  wire               clk,
    input  wire               rst_n,
    input  wire        [ 3:0] addr,
    input  wire               addr_vld,
    output wire signed [ 9:0] tf_re,
    output wire signed [ 9:0] tf_im
  );

  reg  [19:0] dout;

  assign tf_re = dout[19:10];
  assign tf_im = dout[ 9: 0];

  initial
    begin
     `ifndef USE_RESET
      dout = 20'd0;
     `endif
    end

  always @ (posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
         `ifdef USE_RESET
          dout <= 20'd0;
         `endif
        end
      else if (addr_vld)
        begin
          case (addr)
            4'h0: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            4'h1: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            4'h2: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            4'h3: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            4'h4: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            4'h5: dout <= { 10'sd362   , -10'sd362   }; /* W[ 128] =  0.7070  -0.7070i */
            4'h6: dout <= { 10'sd0     , -10'sd512   }; /* W[ 256] =  0.0000  -1.0000i */
            4'h7: dout <= {-10'sd362   , -10'sd362   }; /* W[ 384] = -0.7070  -0.7070i */
            4'h8: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            4'h9: dout <= { 10'sd473   , -10'sd196   }; /* W[  64] =  0.9238  -0.3828i */
            4'hA: dout <= { 10'sd362   , -10'sd362   }; /* W[ 128] =  0.7070  -0.7070i */
            4'hB: dout <= { 10'sd196   , -10'sd473   }; /* W[ 192] =  0.3828  -0.9238i */
            4'hC: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            4'hD: dout <= { 10'sd196   , -10'sd473   }; /* W[ 192] =  0.3828  -0.9238i */
            4'hE: dout <= {-10'sd362   , -10'sd362   }; /* W[ 384] = -0.7070  -0.7070i */
            4'hF: dout <= {-10'sd473   ,  10'sd196   }; /* W[ 576] = -0.9238   0.3828i */
            default:
              begin
                dout <= 20'd0;
              end
         endcase
      end
  end
endmodule

/** @} */ /* End of addtogroup ModMiscIpDspFftR22Sdc */
/* END OF FILE */
