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
 * TFM stage-0 twiddle-factor ROM for 256-point radix-2<sup>2</sup> SDF FFT
 * processors.
 * This file implements the TFM stage-0 twiddle-factor ROM for 256-point
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

/** TFM stage-0 twiddle-factor ROM for 256-point radix-2<sup>2</sup> SDF FFT 
 * processors.
 * This module implements the stage-0 twiddle-factor ROM for 256-point radix-2<sup>2</sup>
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
module fft_r22sdf_rom_256_s0 (
    input  wire               clk,
    input  wire               rst_n,
    input  wire        [ 7:0] addr,
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
            8'h00: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h01: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h02: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h03: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h04: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h05: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h06: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h07: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h08: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h09: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h0A: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h0B: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h0C: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h0D: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h0E: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h0F: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h10: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h11: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h12: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h13: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h14: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h15: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h16: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h17: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h18: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h19: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h1A: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h1B: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h1C: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h1D: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h1E: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h1F: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h20: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h21: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h22: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h23: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h24: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h25: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h26: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h27: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h28: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h29: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h2A: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h2B: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h2C: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h2D: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h2E: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h2F: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h30: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h31: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h32: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h33: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h34: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h35: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h36: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h37: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h38: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h39: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h3A: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h3B: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h3C: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h3D: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h3E: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h3F: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h40: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h41: dout <= { 10'sd511   , -10'sd25    }; /* W[   2] =  0.9980  -0.0488i */
            8'h42: dout <= { 10'sd510   , -10'sd50    }; /* W[   4] =  0.9961  -0.0977i */
            8'h43: dout <= { 10'sd506   , -10'sd75    }; /* W[   6] =  0.9883  -0.1465i */
            8'h44: dout <= { 10'sd502   , -10'sd100   }; /* W[   8] =  0.9805  -0.1953i */
            8'h45: dout <= { 10'sd497   , -10'sd124   }; /* W[  10] =  0.9707  -0.2422i */
            8'h46: dout <= { 10'sd490   , -10'sd149   }; /* W[  12] =  0.9570  -0.2910i */
            8'h47: dout <= { 10'sd482   , -10'sd172   }; /* W[  14] =  0.9414  -0.3359i */
            8'h48: dout <= { 10'sd473   , -10'sd196   }; /* W[  16] =  0.9238  -0.3828i */
            8'h49: dout <= { 10'sd463   , -10'sd219   }; /* W[  18] =  0.9043  -0.4277i */
            8'h4A: dout <= { 10'sd452   , -10'sd241   }; /* W[  20] =  0.8828  -0.4707i */
            8'h4B: dout <= { 10'sd439   , -10'sd263   }; /* W[  22] =  0.8574  -0.5137i */
            8'h4C: dout <= { 10'sd426   , -10'sd284   }; /* W[  24] =  0.8320  -0.5547i */
            8'h4D: dout <= { 10'sd411   , -10'sd305   }; /* W[  26] =  0.8027  -0.5957i */
            8'h4E: dout <= { 10'sd396   , -10'sd325   }; /* W[  28] =  0.7734  -0.6348i */
            8'h4F: dout <= { 10'sd379   , -10'sd344   }; /* W[  30] =  0.7402  -0.6719i */
            8'h50: dout <= { 10'sd362   , -10'sd362   }; /* W[  32] =  0.7070  -0.7070i */
            8'h51: dout <= { 10'sd344   , -10'sd379   }; /* W[  34] =  0.6719  -0.7402i */
            8'h52: dout <= { 10'sd325   , -10'sd396   }; /* W[  36] =  0.6348  -0.7734i */
            8'h53: dout <= { 10'sd305   , -10'sd411   }; /* W[  38] =  0.5957  -0.8027i */
            8'h54: dout <= { 10'sd284   , -10'sd426   }; /* W[  40] =  0.5547  -0.8320i */
            8'h55: dout <= { 10'sd263   , -10'sd439   }; /* W[  42] =  0.5137  -0.8574i */
            8'h56: dout <= { 10'sd241   , -10'sd452   }; /* W[  44] =  0.4707  -0.8828i */
            8'h57: dout <= { 10'sd219   , -10'sd463   }; /* W[  46] =  0.4277  -0.9043i */
            8'h58: dout <= { 10'sd196   , -10'sd473   }; /* W[  48] =  0.3828  -0.9238i */
            8'h59: dout <= { 10'sd172   , -10'sd482   }; /* W[  50] =  0.3359  -0.9414i */
            8'h5A: dout <= { 10'sd149   , -10'sd490   }; /* W[  52] =  0.2910  -0.9570i */
            8'h5B: dout <= { 10'sd124   , -10'sd497   }; /* W[  54] =  0.2422  -0.9707i */
            8'h5C: dout <= { 10'sd100   , -10'sd502   }; /* W[  56] =  0.1953  -0.9805i */
            8'h5D: dout <= { 10'sd75    , -10'sd506   }; /* W[  58] =  0.1465  -0.9883i */
            8'h5E: dout <= { 10'sd50    , -10'sd510   }; /* W[  60] =  0.0977  -0.9961i */
            8'h5F: dout <= { 10'sd25    , -10'sd511   }; /* W[  62] =  0.0488  -0.9980i */
            8'h60: dout <= { 10'sd0     , -10'sd512   }; /* W[  64] =  0.0000  -1.0000i */
            8'h61: dout <= {-10'sd25    , -10'sd511   }; /* W[  66] = -0.0488  -0.9980i */
            8'h62: dout <= {-10'sd50    , -10'sd510   }; /* W[  68] = -0.0977  -0.9961i */
            8'h63: dout <= {-10'sd75    , -10'sd506   }; /* W[  70] = -0.1465  -0.9883i */
            8'h64: dout <= {-10'sd100   , -10'sd502   }; /* W[  72] = -0.1953  -0.9805i */
            8'h65: dout <= {-10'sd124   , -10'sd497   }; /* W[  74] = -0.2422  -0.9707i */
            8'h66: dout <= {-10'sd149   , -10'sd490   }; /* W[  76] = -0.2910  -0.9570i */
            8'h67: dout <= {-10'sd172   , -10'sd482   }; /* W[  78] = -0.3359  -0.9414i */
            8'h68: dout <= {-10'sd196   , -10'sd473   }; /* W[  80] = -0.3828  -0.9238i */
            8'h69: dout <= {-10'sd219   , -10'sd463   }; /* W[  82] = -0.4277  -0.9043i */
            8'h6A: dout <= {-10'sd241   , -10'sd452   }; /* W[  84] = -0.4707  -0.8828i */
            8'h6B: dout <= {-10'sd263   , -10'sd439   }; /* W[  86] = -0.5137  -0.8574i */
            8'h6C: dout <= {-10'sd284   , -10'sd426   }; /* W[  88] = -0.5547  -0.8320i */
            8'h6D: dout <= {-10'sd305   , -10'sd411   }; /* W[  90] = -0.5957  -0.8027i */
            8'h6E: dout <= {-10'sd325   , -10'sd396   }; /* W[  92] = -0.6348  -0.7734i */
            8'h6F: dout <= {-10'sd344   , -10'sd379   }; /* W[  94] = -0.6719  -0.7402i */
            8'h70: dout <= {-10'sd362   , -10'sd362   }; /* W[  96] = -0.7070  -0.7070i */
            8'h71: dout <= {-10'sd379   , -10'sd344   }; /* W[  98] = -0.7402  -0.6719i */
            8'h72: dout <= {-10'sd396   , -10'sd325   }; /* W[ 100] = -0.7734  -0.6348i */
            8'h73: dout <= {-10'sd411   , -10'sd305   }; /* W[ 102] = -0.8027  -0.5957i */
            8'h74: dout <= {-10'sd426   , -10'sd284   }; /* W[ 104] = -0.8320  -0.5547i */
            8'h75: dout <= {-10'sd439   , -10'sd263   }; /* W[ 106] = -0.8574  -0.5137i */
            8'h76: dout <= {-10'sd452   , -10'sd241   }; /* W[ 108] = -0.8828  -0.4707i */
            8'h77: dout <= {-10'sd463   , -10'sd219   }; /* W[ 110] = -0.9043  -0.4277i */
            8'h78: dout <= {-10'sd473   , -10'sd196   }; /* W[ 112] = -0.9238  -0.3828i */
            8'h79: dout <= {-10'sd482   , -10'sd172   }; /* W[ 114] = -0.9414  -0.3359i */
            8'h7A: dout <= {-10'sd490   , -10'sd149   }; /* W[ 116] = -0.9570  -0.2910i */
            8'h7B: dout <= {-10'sd497   , -10'sd124   }; /* W[ 118] = -0.9707  -0.2422i */
            8'h7C: dout <= {-10'sd502   , -10'sd100   }; /* W[ 120] = -0.9805  -0.1953i */
            8'h7D: dout <= {-10'sd506   , -10'sd75    }; /* W[ 122] = -0.9883  -0.1465i */
            8'h7E: dout <= {-10'sd510   , -10'sd50    }; /* W[ 124] = -0.9961  -0.0977i */
            8'h7F: dout <= {-10'sd511   , -10'sd25    }; /* W[ 126] = -0.9980  -0.0488i */
            8'h80: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'h81: dout <= { 10'sd511   , -10'sd13    }; /* W[   1] =  0.9980  -0.0254i */
            8'h82: dout <= { 10'sd511   , -10'sd25    }; /* W[   2] =  0.9980  -0.0488i */
            8'h83: dout <= { 10'sd511   , -10'sd38    }; /* W[   3] =  0.9980  -0.0742i */
            8'h84: dout <= { 10'sd510   , -10'sd50    }; /* W[   4] =  0.9961  -0.0977i */
            8'h85: dout <= { 10'sd508   , -10'sd63    }; /* W[   5] =  0.9922  -0.1230i */
            8'h86: dout <= { 10'sd506   , -10'sd75    }; /* W[   6] =  0.9883  -0.1465i */
            8'h87: dout <= { 10'sd504   , -10'sd88    }; /* W[   7] =  0.9844  -0.1719i */
            8'h88: dout <= { 10'sd502   , -10'sd100   }; /* W[   8] =  0.9805  -0.1953i */
            8'h89: dout <= { 10'sd500   , -10'sd112   }; /* W[   9] =  0.9766  -0.2188i */
            8'h8A: dout <= { 10'sd497   , -10'sd124   }; /* W[  10] =  0.9707  -0.2422i */
            8'h8B: dout <= { 10'sd493   , -10'sd137   }; /* W[  11] =  0.9629  -0.2676i */
            8'h8C: dout <= { 10'sd490   , -10'sd149   }; /* W[  12] =  0.9570  -0.2910i */
            8'h8D: dout <= { 10'sd486   , -10'sd161   }; /* W[  13] =  0.9492  -0.3145i */
            8'h8E: dout <= { 10'sd482   , -10'sd172   }; /* W[  14] =  0.9414  -0.3359i */
            8'h8F: dout <= { 10'sd478   , -10'sd184   }; /* W[  15] =  0.9336  -0.3594i */
            8'h90: dout <= { 10'sd473   , -10'sd196   }; /* W[  16] =  0.9238  -0.3828i */
            8'h91: dout <= { 10'sd468   , -10'sd207   }; /* W[  17] =  0.9141  -0.4043i */
            8'h92: dout <= { 10'sd463   , -10'sd219   }; /* W[  18] =  0.9043  -0.4277i */
            8'h93: dout <= { 10'sd457   , -10'sd230   }; /* W[  19] =  0.8926  -0.4492i */
            8'h94: dout <= { 10'sd452   , -10'sd241   }; /* W[  20] =  0.8828  -0.4707i */
            8'h95: dout <= { 10'sd445   , -10'sd252   }; /* W[  21] =  0.8691  -0.4922i */
            8'h96: dout <= { 10'sd439   , -10'sd263   }; /* W[  22] =  0.8574  -0.5137i */
            8'h97: dout <= { 10'sd433   , -10'sd274   }; /* W[  23] =  0.8457  -0.5352i */
            8'h98: dout <= { 10'sd426   , -10'sd284   }; /* W[  24] =  0.8320  -0.5547i */
            8'h99: dout <= { 10'sd419   , -10'sd295   }; /* W[  25] =  0.8184  -0.5762i */
            8'h9A: dout <= { 10'sd411   , -10'sd305   }; /* W[  26] =  0.8027  -0.5957i */
            8'h9B: dout <= { 10'sd404   , -10'sd315   }; /* W[  27] =  0.7891  -0.6152i */
            8'h9C: dout <= { 10'sd396   , -10'sd325   }; /* W[  28] =  0.7734  -0.6348i */
            8'h9D: dout <= { 10'sd388   , -10'sd334   }; /* W[  29] =  0.7578  -0.6523i */
            8'h9E: dout <= { 10'sd379   , -10'sd344   }; /* W[  30] =  0.7402  -0.6719i */
            8'h9F: dout <= { 10'sd371   , -10'sd353   }; /* W[  31] =  0.7246  -0.6895i */
            8'hA0: dout <= { 10'sd362   , -10'sd362   }; /* W[  32] =  0.7070  -0.7070i */
            8'hA1: dout <= { 10'sd353   , -10'sd371   }; /* W[  33] =  0.6895  -0.7246i */
            8'hA2: dout <= { 10'sd344   , -10'sd379   }; /* W[  34] =  0.6719  -0.7402i */
            8'hA3: dout <= { 10'sd334   , -10'sd388   }; /* W[  35] =  0.6523  -0.7578i */
            8'hA4: dout <= { 10'sd325   , -10'sd396   }; /* W[  36] =  0.6348  -0.7734i */
            8'hA5: dout <= { 10'sd315   , -10'sd404   }; /* W[  37] =  0.6152  -0.7891i */
            8'hA6: dout <= { 10'sd305   , -10'sd411   }; /* W[  38] =  0.5957  -0.8027i */
            8'hA7: dout <= { 10'sd295   , -10'sd419   }; /* W[  39] =  0.5762  -0.8184i */
            8'hA8: dout <= { 10'sd284   , -10'sd426   }; /* W[  40] =  0.5547  -0.8320i */
            8'hA9: dout <= { 10'sd274   , -10'sd433   }; /* W[  41] =  0.5352  -0.8457i */
            8'hAA: dout <= { 10'sd263   , -10'sd439   }; /* W[  42] =  0.5137  -0.8574i */
            8'hAB: dout <= { 10'sd252   , -10'sd445   }; /* W[  43] =  0.4922  -0.8691i */
            8'hAC: dout <= { 10'sd241   , -10'sd452   }; /* W[  44] =  0.4707  -0.8828i */
            8'hAD: dout <= { 10'sd230   , -10'sd457   }; /* W[  45] =  0.4492  -0.8926i */
            8'hAE: dout <= { 10'sd219   , -10'sd463   }; /* W[  46] =  0.4277  -0.9043i */
            8'hAF: dout <= { 10'sd207   , -10'sd468   }; /* W[  47] =  0.4043  -0.9141i */
            8'hB0: dout <= { 10'sd196   , -10'sd473   }; /* W[  48] =  0.3828  -0.9238i */
            8'hB1: dout <= { 10'sd184   , -10'sd478   }; /* W[  49] =  0.3594  -0.9336i */
            8'hB2: dout <= { 10'sd172   , -10'sd482   }; /* W[  50] =  0.3359  -0.9414i */
            8'hB3: dout <= { 10'sd161   , -10'sd486   }; /* W[  51] =  0.3145  -0.9492i */
            8'hB4: dout <= { 10'sd149   , -10'sd490   }; /* W[  52] =  0.2910  -0.9570i */
            8'hB5: dout <= { 10'sd137   , -10'sd493   }; /* W[  53] =  0.2676  -0.9629i */
            8'hB6: dout <= { 10'sd124   , -10'sd497   }; /* W[  54] =  0.2422  -0.9707i */
            8'hB7: dout <= { 10'sd112   , -10'sd500   }; /* W[  55] =  0.2188  -0.9766i */
            8'hB8: dout <= { 10'sd100   , -10'sd502   }; /* W[  56] =  0.1953  -0.9805i */
            8'hB9: dout <= { 10'sd88    , -10'sd504   }; /* W[  57] =  0.1719  -0.9844i */
            8'hBA: dout <= { 10'sd75    , -10'sd506   }; /* W[  58] =  0.1465  -0.9883i */
            8'hBB: dout <= { 10'sd63    , -10'sd508   }; /* W[  59] =  0.1230  -0.9922i */
            8'hBC: dout <= { 10'sd50    , -10'sd510   }; /* W[  60] =  0.0977  -0.9961i */
            8'hBD: dout <= { 10'sd38    , -10'sd511   }; /* W[  61] =  0.0742  -0.9980i */
            8'hBE: dout <= { 10'sd25    , -10'sd511   }; /* W[  62] =  0.0488  -0.9980i */
            8'hBF: dout <= { 10'sd13    , -10'sd512   }; /* W[  63] =  0.0254  -1.0000i */
            8'hC0: dout <= { 10'sd511   ,  10'sd0     }; /* W[   0] =  0.9980   0.0000i */
            8'hC1: dout <= { 10'sd511   , -10'sd38    }; /* W[   3] =  0.9980  -0.0742i */
            8'hC2: dout <= { 10'sd506   , -10'sd75    }; /* W[   6] =  0.9883  -0.1465i */
            8'hC3: dout <= { 10'sd500   , -10'sd112   }; /* W[   9] =  0.9766  -0.2188i */
            8'hC4: dout <= { 10'sd490   , -10'sd149   }; /* W[  12] =  0.9570  -0.2910i */
            8'hC5: dout <= { 10'sd478   , -10'sd184   }; /* W[  15] =  0.9336  -0.3594i */
            8'hC6: dout <= { 10'sd463   , -10'sd219   }; /* W[  18] =  0.9043  -0.4277i */
            8'hC7: dout <= { 10'sd445   , -10'sd252   }; /* W[  21] =  0.8691  -0.4922i */
            8'hC8: dout <= { 10'sd426   , -10'sd284   }; /* W[  24] =  0.8320  -0.5547i */
            8'hC9: dout <= { 10'sd404   , -10'sd315   }; /* W[  27] =  0.7891  -0.6152i */
            8'hCA: dout <= { 10'sd379   , -10'sd344   }; /* W[  30] =  0.7402  -0.6719i */
            8'hCB: dout <= { 10'sd353   , -10'sd371   }; /* W[  33] =  0.6895  -0.7246i */
            8'hCC: dout <= { 10'sd325   , -10'sd396   }; /* W[  36] =  0.6348  -0.7734i */
            8'hCD: dout <= { 10'sd295   , -10'sd419   }; /* W[  39] =  0.5762  -0.8184i */
            8'hCE: dout <= { 10'sd263   , -10'sd439   }; /* W[  42] =  0.5137  -0.8574i */
            8'hCF: dout <= { 10'sd230   , -10'sd457   }; /* W[  45] =  0.4492  -0.8926i */
            8'hD0: dout <= { 10'sd196   , -10'sd473   }; /* W[  48] =  0.3828  -0.9238i */
            8'hD1: dout <= { 10'sd161   , -10'sd486   }; /* W[  51] =  0.3145  -0.9492i */
            8'hD2: dout <= { 10'sd124   , -10'sd497   }; /* W[  54] =  0.2422  -0.9707i */
            8'hD3: dout <= { 10'sd88    , -10'sd504   }; /* W[  57] =  0.1719  -0.9844i */
            8'hD4: dout <= { 10'sd50    , -10'sd510   }; /* W[  60] =  0.0977  -0.9961i */
            8'hD5: dout <= { 10'sd13    , -10'sd512   }; /* W[  63] =  0.0254  -1.0000i */
            8'hD6: dout <= {-10'sd25    , -10'sd511   }; /* W[  66] = -0.0488  -0.9980i */
            8'hD7: dout <= {-10'sd63    , -10'sd508   }; /* W[  69] = -0.1230  -0.9922i */
            8'hD8: dout <= {-10'sd100   , -10'sd502   }; /* W[  72] = -0.1953  -0.9805i */
            8'hD9: dout <= {-10'sd137   , -10'sd493   }; /* W[  75] = -0.2676  -0.9629i */
            8'hDA: dout <= {-10'sd172   , -10'sd482   }; /* W[  78] = -0.3359  -0.9414i */
            8'hDB: dout <= {-10'sd207   , -10'sd468   }; /* W[  81] = -0.4043  -0.9141i */
            8'hDC: dout <= {-10'sd241   , -10'sd452   }; /* W[  84] = -0.4707  -0.8828i */
            8'hDD: dout <= {-10'sd274   , -10'sd433   }; /* W[  87] = -0.5352  -0.8457i */
            8'hDE: dout <= {-10'sd305   , -10'sd411   }; /* W[  90] = -0.5957  -0.8027i */
            8'hDF: dout <= {-10'sd334   , -10'sd388   }; /* W[  93] = -0.6523  -0.7578i */
            8'hE0: dout <= {-10'sd362   , -10'sd362   }; /* W[  96] = -0.7070  -0.7070i */
            8'hE1: dout <= {-10'sd388   , -10'sd334   }; /* W[  99] = -0.7578  -0.6523i */
            8'hE2: dout <= {-10'sd411   , -10'sd305   }; /* W[ 102] = -0.8027  -0.5957i */
            8'hE3: dout <= {-10'sd433   , -10'sd274   }; /* W[ 105] = -0.8457  -0.5352i */
            8'hE4: dout <= {-10'sd452   , -10'sd241   }; /* W[ 108] = -0.8828  -0.4707i */
            8'hE5: dout <= {-10'sd468   , -10'sd207   }; /* W[ 111] = -0.9141  -0.4043i */
            8'hE6: dout <= {-10'sd482   , -10'sd172   }; /* W[ 114] = -0.9414  -0.3359i */
            8'hE7: dout <= {-10'sd493   , -10'sd137   }; /* W[ 117] = -0.9629  -0.2676i */
            8'hE8: dout <= {-10'sd502   , -10'sd100   }; /* W[ 120] = -0.9805  -0.1953i */
            8'hE9: dout <= {-10'sd508   , -10'sd63    }; /* W[ 123] = -0.9922  -0.1230i */
            8'hEA: dout <= {-10'sd511   , -10'sd25    }; /* W[ 126] = -0.9980  -0.0488i */
            8'hEB: dout <= {-10'sd512   ,  10'sd13    }; /* W[ 129] = -1.0000   0.0254i */
            8'hEC: dout <= {-10'sd510   ,  10'sd50    }; /* W[ 132] = -0.9961   0.0977i */
            8'hED: dout <= {-10'sd504   ,  10'sd88    }; /* W[ 135] = -0.9844   0.1719i */
            8'hEE: dout <= {-10'sd497   ,  10'sd124   }; /* W[ 138] = -0.9707   0.2422i */
            8'hEF: dout <= {-10'sd486   ,  10'sd161   }; /* W[ 141] = -0.9492   0.3145i */
            8'hF0: dout <= {-10'sd473   ,  10'sd196   }; /* W[ 144] = -0.9238   0.3828i */
            8'hF1: dout <= {-10'sd457   ,  10'sd230   }; /* W[ 147] = -0.8926   0.4492i */
            8'hF2: dout <= {-10'sd439   ,  10'sd263   }; /* W[ 150] = -0.8574   0.5137i */
            8'hF3: dout <= {-10'sd419   ,  10'sd295   }; /* W[ 153] = -0.8184   0.5762i */
            8'hF4: dout <= {-10'sd396   ,  10'sd325   }; /* W[ 156] = -0.7734   0.6348i */
            8'hF5: dout <= {-10'sd371   ,  10'sd353   }; /* W[ 159] = -0.7246   0.6895i */
            8'hF6: dout <= {-10'sd344   ,  10'sd379   }; /* W[ 162] = -0.6719   0.7402i */
            8'hF7: dout <= {-10'sd315   ,  10'sd404   }; /* W[ 165] = -0.6152   0.7891i */
            8'hF8: dout <= {-10'sd284   ,  10'sd426   }; /* W[ 168] = -0.5547   0.8320i */
            8'hF9: dout <= {-10'sd252   ,  10'sd445   }; /* W[ 171] = -0.4922   0.8691i */
            8'hFA: dout <= {-10'sd219   ,  10'sd463   }; /* W[ 174] = -0.4277   0.9043i */
            8'hFB: dout <= {-10'sd184   ,  10'sd478   }; /* W[ 177] = -0.3594   0.9336i */
            8'hFC: dout <= {-10'sd149   ,  10'sd490   }; /* W[ 180] = -0.2910   0.9570i */
            8'hFD: dout <= {-10'sd112   ,  10'sd500   }; /* W[ 183] = -0.2188   0.9766i */
            8'hFE: dout <= {-10'sd75    ,  10'sd506   }; /* W[ 186] = -0.1465   0.9883i */
            8'hFF: dout <= {-10'sd38    ,  10'sd511   }; /* W[ 189] = -0.0742   0.9980i */
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
