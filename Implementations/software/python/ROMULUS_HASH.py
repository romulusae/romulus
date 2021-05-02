
# ROMULUS-HASH Python Implementation

# Copyright 2020:
#     Thomas Peyrin <thomas.peyrin@gmail.com>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.

from SKINNY import *
import math

# ####################################################################
# # ROMULUS-HASH
# ####################################################################


# # ROMULUS-HASH
SKINNY_VERSION = 6
M_LENGTH = 32

# # ROMULUS-HASH
#SKINNY_VERSION = 4
#M_LENGTH = 16


# function that implements the Hash
def crypto_hash(M):
    S1 = [0] * 16
    S2 = [0] * 16
    M_pad = M + [0x80] + [0]*((M_LENGTH-1 - len(M)) % M_LENGTH)
    for i in range(0,len(M_pad),M_LENGTH):
        S1_new = skinny_enc(S2, M_pad[i:i+M_LENGTH] + S1, SKINNY_VERSION)
        S2[0] = S2[0] ^ 0x80
        S2_new = skinny_enc(S2, M_pad[i:i+M_LENGTH] + S1, SKINNY_VERSION)
        S1 = S1_new.copy()
        S2 = S2_new.copy()
        
    return S1 + S2   
        

