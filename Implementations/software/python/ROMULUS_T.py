
# ROMULUS-T Python Implementation

# Copyright 2021:
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
from ROMULUS_H import crypto_hash
import math

# ####################################################################
# # ROMULUS-T
# ####################################################################

# # ROMULUS-T
COUNTER_LENGTH = 7
MEMBER_MASK = 64


def increase_counter(counter):
    if counter[COUNTER_LENGTH - 1] & 0x80 != 0: mask = 0x95
    else: mask = 0
    for i in reversed(range(1, COUNTER_LENGTH)):
        counter[i] = ((counter[i] << 1) & 0xfe) ^ (counter[i - 1] >> 7)
    counter[0] = ((counter[0] << 1) & 0xfe) ^ mask
    return counter


def parse(L_in,x): 
    L_out = []
    cursor = 0
    while len(L_in) - cursor >= x:
       L_out.extend([L_in[cursor:cursor+x]])
       cursor = cursor + x 
    if len(L_in) - cursor > 0:
       L_out.extend([L_in[cursor:]])
    if L_in == []:
        L_out = [[]]
    L_out.insert(0,[])
    return L_out


def ipad_star(x, pad_length):
    if len(x) == 0: return x
    return x + [0]*(pad_length - 1 - (len(x) % pad_length)) + [(len(x) % pad_length)]
    

def tk_encoding(counter, b, t, k):
    return counter + [b ^ MEMBER_MASK] + [0] * 8 + t + k


# function that implements the AE encryption
# inputs: M the message, A the associated data, N the nonce, K the key
# outputs: C the ciphertext (the last 16 bytes representing the authentication tag)
def crypto_aead_encrypt(M, A, N, K):
    S = [0] * 16
    C = []
    m = 0
    
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    
    if M != []:   
        M_parsed = parse(M,16)
        m = len(M_parsed)-1
        S = skinny_enc(N, tk_encoding([0] * COUNTER_LENGTH, 2, [0] * 16, K))        
        for i in range(1,m):
            X = skinny_enc(N, tk_encoding(counter, 0, [0] * 16, S))
            C.extend([X[u] ^ M[16*(i-1)+u] for u in range(16)])
            S = skinny_enc(N, tk_encoding(counter, 1, [0] * 16, S))
            counter = increase_counter(counter)
    
        X = skinny_enc(N, tk_encoding(counter, 0, [0] * 16, S)) 
        C.extend([X[u] ^ M_parsed[m][u] for u in range(len(M_parsed[m]))])
        counter = increase_counter(counter)

    H = crypto_hash(ipad_star(A,16) + ipad_star(C,16) + N + counter)
    T = skinny_enc(H[0:16], tk_encoding([0] * COUNTER_LENGTH, 4, H[16:32], K))    
    C.extend(T)
    return C    

        

# function that implements the AE decryption
# inputs: C the ciphertext (the last 16 bytes representing the authentication tag), A the associated data, N the nonce, K the key
# outputs: (0,M) with M the message if the tag is verified, returns (-1,[]) otherwise
def crypto_aead_decrypt(C, A, N, K):
    S = [0] * 16
    T = C[-16:]
    C[-16:] = []
    M = []
    
    c = int((len(C)+15 - ((len(C)+15)%16))/16)          
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    for i in range(0,c):  counter = increase_counter(counter)
    H = crypto_hash(ipad_star(A,16) + ipad_star(C,16) + N + counter)
    T_computed = skinny_enc(H[0:16], tk_encoding([0] * COUNTER_LENGTH, 4, H[16:32], K)) 
    compare = 0
    for i in range(16):
        compare |= (T[i] ^ T_computed[i])

    if compare != 0:
        return -1, []
    else:
        if C == []:  return 0, M

        S = skinny_enc(N, tk_encoding([0] * COUNTER_LENGTH, 2, [0] * 16, K))
        counter = [1] + [0] * (COUNTER_LENGTH - 1)
        for i in range(1,c):
            X = skinny_enc(N, tk_encoding(counter, 0, [0] * 16, S))
            M.extend([X[u] ^ C[16*(i-1)+u] for u in range(16)])
            S = skinny_enc(N, tk_encoding(counter, 1, [0] * 16, S))
            counter = increase_counter(counter)
    
        X = skinny_enc(N, tk_encoding(counter, 0, [0] * 16, S)) 
        M.extend([X[u] ^ C[16*(c-1)+u] for u in range(1+((len(C)+15)%16))])
        
    return 0, M   

