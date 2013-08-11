function fft_r2_rom_gen (romDir, N, tfBits)
%Radix-2 DIF FFT twiddle-factor ROM generator.
%
%   Parameters:
%       romDir  - Destination directory for storing generated ROM files.
%       N       - FFT length for which the ROM files are required.
%       tfBits  - Twiddle-factor bit-width.
%
%   Returns:
%       Nothing.
%
%   Example:
%       fft_r2_rom_gen ('../roms', 1024, 12)
%
%*******************************************************************************
%* Copyright (c) 2010-2012, XIONLOGIC LIMITED                                  *
%* Copyright (c) 2010-2012, Niroshan Mahasinghe                                *
%* All rights reserved.                                                        *
%*                                                                             *
%* Redistribution and use in source and binary forms, with or without          *
%* modification, are permitted provided that the following conditions          *
%* are met:                                                                    *
%*                                                                             *
%*  o  Redistributions of source code must retain the above copyright          *
%*     notice, this list of conditions and the following disclaimer.           *
%*                                                                             *
%*  o  Redistributions in binary form must reproduce the above copyright       *
%*     notice, this list of conditions and the following disclaimer in         *
%*     the documentation and/or other materials provided with the              *
%*     distribution.                                                           *
%*                                                                             *
%*  o  Neither the name of XIONLOGIC LIMITED nor the names of its              *
%*     contributors may be used to endorse or promote products                 *
%*     derived from this software without specific prior                       *
%*     written permission.                                                     *
%*                                                                             *
%* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" *
%* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE   *
%* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE  *
%* ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE   *
%* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR         *
%* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF        *
%* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS    *
%* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     *
%* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)     *
%* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF      *
%* THE POSSIBILITY OF SUCH DAMAGE.                                             *
%*******************************************************************************

  % Check arguments.
  if nargin ~= 3
    fprintf ('Error: Invalid number of arguments\n');
    fprintf ('Usage: fft_r2_rom_gen (romDir, N, tfBits)\n');
    fprintf ('  Type ''help fft_r2_rom_gen'' for more information\n');
    return;
  end

  % Compute the ROM address width for the first butterfly stage.
  addr_wdth = log2(N)-1;

  % Compute the multiplication factor required to move the decimal point 
  % for the requested fixed-point precision.
  fpMult = 2^(tfBits-1);

  % Create the ROM RTL file.
  rom_file_name = sprintf ('%s/fft_r2_rom_%d.v', romDir, N);
  h = fopen (rom_file_name, 'wt');
  if (h == -1)
    error (sprintf ('Failed to open `%s'' for writing', rom_file_name));
  end

  % Write the ROM RTL file header.
  fprintf (h, '/******************************************************************************\n');
  fprintf (h, ' * Copyright (c) 2010-2012, XIONLOGIC LIMITED                                 *\n');
  fprintf (h, ' * Copyright (c) 2010-2012, Niroshan Mahasinghe                               *\n');
  fprintf (h, ' * All rights reserved.                                                       *\n');
  fprintf (h, ' *                                                                            *\n');
  fprintf (h, ' * Redistribution and use in source and binary forms, with or without         *\n');
  fprintf (h, ' * modification, are permitted provided that the following conditions         *\n');
  fprintf (h, ' * are met:                                                                   *\n');
  fprintf (h, ' *                                                                            *\n');
  fprintf (h, ' *  o  Redistributions of source code must retain the above copyright         *\n');
  fprintf (h, ' *     notice, this list of conditions and the following disclaimer.          *\n');
  fprintf (h, ' *                                                                            *\n');
  fprintf (h, ' *  o  Redistributions in binary form must reproduce the above copyright      *\n');
  fprintf (h, ' *     notice, this list of conditions and the following disclaimer in        *\n');
  fprintf (h, ' *     the documentation and/or other materials provided with the             *\n');
  fprintf (h, ' *     distribution.                                                          *\n');
  fprintf (h, ' *                                                                            *\n');
  fprintf (h, ' *  o  Neither the name of XIONLOGIC LIMITED nor the names of its             *\n');
  fprintf (h, ' *     contributors may be used to endorse or promote products                *\n');
  fprintf (h, ' *     derived from this software without specific prior                      *\n');
  fprintf (h, ' *     written permission.                                                    *\n');
  fprintf (h, ' *                                                                            *\n');
  fprintf (h, ' * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS        *\n');
  fprintf (h, ' * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  *\n');
  fprintf (h, ' * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR *\n');
  fprintf (h, ' * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR          *\n');
  fprintf (h, ' * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,      *\n');
  fprintf (h, ' * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,        *\n');
  fprintf (h, ' * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR         *\n');
  fprintf (h, ' * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF     *\n');
  fprintf (h, ' * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING       *\n');
  fprintf (h, ' * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS         *\n');
  fprintf (h, ' * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               *\n');
  fprintf (h, ' *****************************************************************************/\n');
  fprintf (h, '\n');
  fprintf (h, '/*****************************************************************************\n');
  fprintf (h, ' *  Original Author(s):\n');
  fprintf (h, ' *      Niroshan Mahasinghe, nmahasinghe@xionlogic.com\n');
  fprintf (h, ' *****************************************************************************/\n');
  fprintf (h, '/** \\file\n');
  fprintf (h, ' * \\ingroup ModMiscIpDspFftR2Rom\n');
  fprintf (h, ' * Twiddle-factor ROM for %d-point radix-2 FFT processors.\n', N);
  fprintf (h, ' * This file implements the twiddle-factor ROM for %d-point radix-2 FFT\n', N);
  fprintf (h, ' * processors.\n');
  fprintf (h, ' */\n');
  fprintf (h, '\n');
  fprintf (h, '/***************************************************************************\n');
  fprintf (h, ' * Include files\n');
  fprintf (h, ' ***************************************************************************/\n');
  fprintf (h, '`include "system.vh"\n');
  fprintf (h, '\n');
  fprintf (h, '/***************************************************************************\n');
  fprintf (h, ' * Modules\n');
  fprintf (h, ' ***************************************************************************/\n');
  fprintf (h, '/** \\addtogroup ModMiscIpDspFftR2Rom\n');
  fprintf (h, ' * @{\n');
  fprintf (h, ' */\n');
  fprintf (h, '\n');
  fprintf (h, '/** Twiddle-factor ROM for %d-point radix-2 FFT processors.\n', N);
  fprintf (h, ' * This module implements the twiddle-factor ROM for %d-point radix-2 FFT\n', N);
  fprintf (h, ' * processors. It outputs the twiddle-factor, W<sup>nk</sup> for a given\n');
  fprintf (h, ' * \\a nk one cycle later.\n');
  fprintf (h, ' *\n');
  fprintf (h, ' * \\param[in]  clk      System clock.\n');
  fprintf (h, ' * \\param[in]  rst_n    Active low asynchronous reset line.\n');
  fprintf (h, ' * \\param[in]  addr     Twiddle-factor ROM address (i.e. \\a nk) to read.\n');
  fprintf (h, ' * \\param[in]  addr_vld Indicates that the read address is valid.\n');
  fprintf (h, ' * \\param[out] tf_re    Twiddle-factor output (real part).\n');
  fprintf (h, ' * \\param[out] tf_im    Twiddle-factor output (imaginary part).\n');
  fprintf (h, ' */\n');
  fprintf (h, 'module fft_r2_rom_%d (\n', N);
  fprintf (h, '    input  wire               clk,\n');
  fprintf (h, '    input  wire               rst_n,\n');
  fprintf (h, '    input  wire        [%2d:0] addr,\n', addr_wdth-1);
  fprintf (h, '    input  wire               addr_vld,\n');
  fprintf (h, '    output wire signed [%2d:0] tf_re,\n', tfBits-1);
  fprintf (h, '    output wire signed [%2d:0] tf_im\n', tfBits-1);
  fprintf (h, '  );\n');
  fprintf (h, '\n');
  fprintf (h, '  reg  [%d:0] dout;\n', 2*tfBits-1);
  fprintf (h, '\n');
  fprintf (h, '  assign tf_re = dout[%d:%d];\n', 2*tfBits-1, tfBits);
  fprintf (h, '  assign tf_im = dout[%d:%d];\n', tfBits-1, 0);
  fprintf (h, '\n');
  fprintf (h, '  initial\n');
  fprintf (h, '    begin\n');
  fprintf (h, '     `ifndef USE_RESET\n');
  fprintf (h, '      dout = %d''d0;\n', 2*tfBits);
  fprintf (h, '     `endif\n');
  fprintf (h, '    end\n');
  fprintf (h, '\n');
  fprintf (h, '  always @ (posedge clk or negedge rst_n)\n');
  fprintf (h, '    begin\n');
  fprintf (h, '      if (!rst_n)\n');
  fprintf (h, '        begin\n');
  fprintf (h, '         `ifdef USE_RESET\n');
  fprintf (h, '          dout <= %d''d0;\n', 2*tfBits);
  fprintf (h, '         `endif\n');
  fprintf (h, '        end\n');
  fprintf (h, '      else if (addr_vld)\n');
  fprintf (h, '        begin\n');
  fprintf (h, '          case (addr)\n');

  % Compute the twiddle-factors for nk = 0..N/2-1.
  for nk = 0:N/2-1
    % Compute the twiddle-factor:
    %   If X(k) represents the frequency bin k of an N-point DFT of a 
    %   time series x(n), where n = 0, 1, 2, ..., N-1
    %       i.e.
    %                N-1
    %         X(k) = SUM x(n).exp(-j*2*pi*nk/N)
    %                n=0
    w      = exp(-1j*2*pi*nk/N);
    w_real = real (w);
    w_imag = imag (w);
    w_real = round (w_real*fpMult);
    w_imag = round (w_imag*fpMult);

    if (w_real == fpMult)
      w_real = fpMult-1;
    end
    if (w_imag == fpMult)
      w_imag = fpMult-1;
    end
    if (sign(w_real) >= 0)
      s_real = ' ';
    else
      s_real = '-';
    end
    if (sign(w_imag) >= 0)
      s_imag = ' ';
    else
      s_imag = '-';
    end

    fprintf (h, '            %d''h', addr_wdth);
    if (addr_wdth <= 4)
      fprintf (h, '%X: ', nk);
    elseif (addr_wdth <= 8)
      fprintf (h, '%02X: ', nk);
    elseif (addr_wdth <= 12)
      fprintf (h, '%03X: ', nk);
    elseif (addr_wdth <= 16)
      fprintf (h, '%04X: ', nk);
    elseif (addr_wdth <= 20)
      fprintf (h, '%05X: ', nk);
    else
      fprintf (h, '%06X: ', nk);
    end
    fprintf (h, 'dout <= {%c%d''sd%-6s, %c%d''sd%-6s}; ',...
      s_real, tfBits, num2str(abs(w_real), '%d'), ...
      s_imag, tfBits, num2str(abs(w_imag), '%d'));
    fprintf (h, '/* W[%4d] = %7.4f  %7.4fi */\n', nk, w_real/fpMult, w_imag/fpMult);
  end
  fprintf (h, '            default:\n');
  fprintf (h, '              begin\n');
  fprintf (h, '                dout <= %d''d0;\n', 2*tfBits);
  fprintf (h, '              end\n');
  fprintf (h, '         endcase\n');
  fprintf (h, '      end\n');
  fprintf (h, '  end\n');
  fprintf (h, 'endmodule\n');
  fprintf (h, '\n');
  fprintf (h, '/** @} */ /* End of addtogroup ModMiscIpDspFftR2Rom */\n');
  fprintf (h, '/* END OF FILE */\n');
  fclose  (h);
end
