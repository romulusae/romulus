
# ROMULUS-H Python Implementation

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

from SKINNY_128_384_plus import *
import math

# ####################################################################
# # ROMULUS-H
# ####################################################################


# # ROMULUS-HASH
M_LENGTH = 32

# function that implements the Hash function
# inputs: M the message
# outputs: the 256-bit hash value
def crypto_hash(M):
    L = [0] * 16
    R = [0] * 16
    M_pad = M + [0]*(M_LENGTH - 1 - (len(M) % M_LENGTH)) + [(len(M) % M_LENGTH)]
    for i in range(0,len(M_pad),M_LENGTH):
        if i==len(M_pad)-M_LENGTH:  L[0] = L[0] ^ 0x02
        L_new = skinny_enc(L, R + M_pad[i:i+M_LENGTH])
        for j in range(0,len(L)): L_new[j] = L_new[j] ^ L[j]
        L[0] = L[0] ^ 0x01
        R_new = skinny_enc(L, R + M_pad[i:i+M_LENGTH])
        for j in range(0,len(R)): R_new[j] = R_new[j] ^ L[j]
        L = L_new.copy()
        R = R_new.copy()
        
    return L + R   
        

