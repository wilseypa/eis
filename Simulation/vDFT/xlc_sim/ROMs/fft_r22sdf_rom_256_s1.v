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
 * TFM stage-1 twiddle-factor ROM for 256-point radix-2<sup>2</sup> SDF FFT
 * processors.
 * This file implements the TFM stage-1 twiddle-factor ROM for 256-point
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

/** TFM stage-1 twiddle-factor ROM for 256-point radix-2<sup>2</sup> SDF FFT 
 * processors.
 * This module implements the stage-1 twiddle-factor ROM for 256-point radix-2<sup>2</sup>
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
module fft_r22sdf_rom_256_s1 (
    input  wire               clk,
    input  wire               rst_n,
    input  wire        [ 5:0] addr,
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
            6'h00: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h01: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h02: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h03: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h04: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h05: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h06: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h07: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h08: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h09: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h0A: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h0B: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h0C: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h0D: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h0E: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h0F: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h10: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h11: dout <= { 10'sd502   , -10'sd100   }; /* W[   8] =  0.9805  -0.1953i */
            6'h12: dout <= { 10'sd473   , -10'sd196   }; /* W[  16] =  0.9238  -0.3828i */
            6'h13: dout <= { 10'sd426   , -10'sd284   }; /* W[  24] =  0.8320  -0.5547i */
            6'h14: dout <= { 10'sd362   , -10'sd362   }; /* W[  32] =  0.7070  -0.7070i */
            6'h15: dout <= { 10'sd284   , -10'sd426   }; /* W[  40] =  0.5547  -0.8320i */
            6'h16: dout <= { 10'sd196   , -10'sd473   }; /* W[  48] =  0.3828  -0.9238i */
            6'h17: dout <= { 10'sd100   , -10'sd502   }; /* W[  56] =  0.1953  -0.9805i */
            6'h18: dout <= { 10'sd0     , -10'sd512   }; /* W[  64] =  0.0000  -1.0000i */
            6'h19: dout <= {-10'sd100   , -10'sd502   }; /* W[  72] = -0.1953  -0.9805i */
            6'h1A: dout <= {-10'sd196   , -10'sd473   }; /* W[  80] = -0.3828  -0.9238i */
            6'h1B: dout <= {-10'sd284   , -10'sd426   }; /* W[  88] = -0.5547  -0.8320i */
            6'h1C: dout <= {-10'sd362   , -10'sd362   }; /* W[  96] = -0.7070  -0.7070i */
            6'h1D: dout <= {-10'sd426   , -10'sd284   }; /* W[ 104] = -0.8320  -0.5547i */
            6'h1E: dout <= {-10'sd473   , -10'sd196   }; /* W[ 112] = -0.9238  -0.3828i */
            6'h1F: dout <= {-10'sd502   , -10'sd100   }; /* W[ 120] = -0.9805  -0.1953i */
            6'h20: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h21: dout <= { 10'sd510   , -10'sd50    }; /* W[   4] =  0.9961  -0.0977i */
            6'h22: dout <= { 10'sd502   , -10'sd100   }; /* W[   8] =  0.9805  -0.1953i */
            6'h23: dout <= { 10'sd490   , -10'sd149   }; /* W[  12] =  0.9570  -0.2910i */
            6'h24: dout <= { 10'sd473   , -10'sd196   }; /* W[  16] =  0.9238  -0.3828i */
            6'h25: dout <= { 10'sd452   , -10'sd241   }; /* W[  20] =  0.8828  -0.4707i */
            6'h26: dout <= { 10'sd426   , -10'sd284   }; /* W[  24] =  0.8320  -0.5547i */
            6'h27: dout <= { 10'sd396   , -10'sd325   }; /* W[  28] =  0.7734  -0.6348i */
            6'h28: dout <= { 10'sd362   , -10'sd362   }; /* W[  32] =  0.7070  -0.7070i */
            6'h29: dout <= { 10'sd325   , -10'sd396   }; /* W[  36] =  0.6348  -0.7734i */
            6'h2A: dout <= { 10'sd284   , -10'sd426   }; /* W[  40] =  0.5547  -0.8320i */
            6'h2B: dout <= { 10'sd241   , -10'sd452   }; /* W[  44] =  0.4707  -0.8828i */
            6'h2C: dout <= { 10'sd196   , -10'sd473   }; /* W[  48] =  0.3828  -0.9238i */
            6'h2D: dout <= { 10'sd149   , -10'sd490   }; /* W[  52] =  0.2910  -0.9570i */
            6'h2E: dout <= { 10'sd100   , -10'sd502   }; /* W[  56] =  0.1953  -0.9805i */
            6'h2F: dout <= { 10'sd50    , -10'sd510   }; /* W[  60] =  0.0977  -0.9961i */
            6'h30: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            6'h31: dout <= { 10'sd490   , -10'sd149   }; /* W[  12] =  0.9570  -0.2910i */
            6'h32: dout <= { 10'sd426   , -10'sd284   }; /* W[  24] =  0.8320  -0.5547i */
            6'h33: dout <= { 10'sd325   , -10'sd396   }; /* W[  36] =  0.6348  -0.7734i */
            6'h34: dout <= { 10'sd196   , -10'sd473   }; /* W[  48] =  0.3828  -0.9238i */
            6'h35: dout <= { 10'sd50    , -10'sd510   }; /* W[  60] =  0.0977  -0.9961i */
            6'h36: dout <= {-10'sd100   , -10'sd502   }; /* W[  72] = -0.1953  -0.9805i */
            6'h37: dout <= {-10'sd241   , -10'sd452   }; /* W[  84] = -0.4707  -0.8828i */
            6'h38: dout <= {-10'sd362   , -10'sd362   }; /* W[  96] = -0.7070  -0.7070i */
            6'h39: dout <= {-10'sd452   , -10'sd241   }; /* W[ 108] = -0.8828  -0.4707i */
            6'h3A: dout <= {-10'sd502   , -10'sd100   }; /* W[ 120] = -0.9805  -0.1953i */
            6'h3B: dout <= {-10'sd510   ,  10'sd50    }; /* W[ 132] = -0.9961   0.0977i */
            6'h3C: dout <= {-10'sd473   ,  10'sd196   }; /* W[ 144] = -0.9238   0.3828i */
            6'h3D: dout <= {-10'sd396   ,  10'sd325   }; /* W[ 156] = -0.7734   0.6348i */
            6'h3E: dout <= {-10'sd284   ,  10'sd426   }; /* W[ 168] = -0.5547   0.8320i */
            6'h3F: dout <= {-10'sd149   ,  10'sd490   }; /* W[ 180] = -0.2910   0.9570i */
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
