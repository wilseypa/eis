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
 * \ingroup CoreUtMathLib
 * Unit test math library.
 * This file implements the math library functions for unit-test testbenches.
 */

/***************************************************************************
 * Include files
 ***************************************************************************/
`include "system.vh"
`include "unittest.vh"

/***************************************************************************
 * Modules
 ***************************************************************************/

`ifndef __DOXYGEN__
module math;
`endif

/** \addtogroup CoreUtMathLib
 * @{
 */

/** Rounds a given value to the specified decimal places.
 * This function rounds a given real value to the specified decimal places.
 * \param v - Input value to round.
 * \param n - Number of decimal places to round to.
 * \return round (v, n).
 */
function real round (input real v, input integer n);
  real    v_tmp1;
  integer v_tmp2;
  begin : round_fnc
    v_tmp1 = v * 10**n;
    v_tmp1 = v_tmp1 > 0 ? v_tmp1 + 0.5 : v_tmp1 - 0.5;
    v_tmp2 = $rtoi (v_tmp1);
    v_tmp1 = $itor (v_tmp2);
    round  = v_tmp1 / 10**n;
  end
endfunction

/** @} */ /* End of addtogroup CoreUtMathLib */

`ifndef __DOXYGEN__
/* Functions private to the math library module. 
 */

`endif

endmodule

/* END OF FILE */