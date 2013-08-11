/******************************************************************************
 * Copyright (c) 2010-2012, XIONLOGIC LIMITED                                 *
 * Copyright (c) 2009-2012, Niroshan Mahasinghe                               *
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
 * \ingroup CoreUtSup
 * Unit test support tasks.
 * This file implements the unit test support tasks for testbenches.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"
`include "unittest.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/

/** \addtogroup CoreUtSup
 * @{
 */

`ifndef __DOXYGEN__
module ut;
`endif

  /** Testbench output channel.
   * This variable holds a file handle to the the testbench output log file. If
   * the plusarg +TVOUT_FILE is present, this process initialises this variable 
   * to the file specified in the plusarg +TVOUT_FILE. Otherwise, it returns a
   * handle to stdout.
   */
  integer  tvout_chan = 32'h8000_0001;

  /** Standard output channel.
   * Reading this variable gives a channel that can be used to write to the
   * standard output.
   * \par
   * Usage example:
   * \code
   * module my_module (...);
   *   begin
   *     ...
   *     ...
   *     $fdisplay (ut.stdout, "Hello world...");
   *     ...
   *     ...
   *   end
   * endmodule 
   * \endcode
   * 
   */
  integer  stdout = 32'h8000_0001;


`ifndef __DOXYGEN__
  initial
    begin : tvout_open
      reg [(8*512)-1:0] ut_tvout_file;

      if ($value$plusargs ("TVOUT_FILE=%s", ut_tvout_file))
        begin
          $display ("UTTV: ut_tvout => %0s", ut_tvout_file);
          tvout_chan = $fopen (ut_tvout_file, "w");
        end
      else
        begin
          $display ("UTTV: ut_tvout => STDOUT");
          tvout_chan = 32'h8000_0001;
        end
    end

endmodule
`endif

/** @} */ /* End of addtogroup CoreUtSup */
/* END OF FILE */
