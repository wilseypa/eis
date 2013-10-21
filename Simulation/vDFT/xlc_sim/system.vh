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
 * System-wide definitions.
 * This file contains the system-wide definitions.
 */
`ifndef __system_vh__
`define __system_vh__

/***************************************************************************
 * Pre-defined Switches
 ***************************************************************************/

/***************************************************************************
 * Compiler Directives
 ***************************************************************************/
`default_nettype none

/***************************************************************************
 * Manifest Constants
 ***************************************************************************/
/** \addtogroup CoreRtlSys
 * @{ */

/** Declaration of constant function, clogb2.
 * This macro defines the constant function, clogb2. clogb2 (v) returns an
 * integer which has the value of the ceiling of the log base2 of v.
 * \code
 * Usage example:
 *   ...
 *   // Define the constant function, clogb2.
 *  `DEF_CLOGB2
 *   ...
 *   localparam  MY_PARAM      = 10;
 *   localparam  MY_PARAM_BITS = clogb2 (MY_PARAM);
 *   ...
 * \endcode
 * \hideinitializer
 */
`define DEF_CLOGB2 \
   function integer clogb2 (input integer v); \
      integer r; \
      begin \
        for (r = 0; (1 << r) < v; r = r+1) \
          begin \
          end \
        clogb2 = r; \
      end \
   endfunction

/** @} */ /* End of addtogroup CoreRtlSys */
`endif
/* END OF FILE */
