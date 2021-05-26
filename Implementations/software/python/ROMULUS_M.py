
# ROMULUS-M Python Implementation

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
# # ROMULUS-M
# ####################################################################

# # ROMULUS-M
T_LENGTH = 16
COUNTER_LENGTH = 7
MEMBER_MASK = 32


N_LENGTH = T_LENGTH

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


def pad(x, pad_length):
    if len(x) == 0:
        return [0] * pad_length
    if len(x) == pad_length:
        return x[:]
    y = x[:]
    for _ in range(pad_length - len(x) - 1):
        y.append(0)
    y.append(len(x))
    return y

def G(A):
    return [(x >> 1) ^ ((x ^ x << 7) & 0x80) for x in A]


def rho(S, M):
    G_S = G(S)
    C = [M[i] ^ G_S[i] for i in range(16)]
    S_prime = [S[i] ^ M[i] for i in range(16)]
    return S_prime, C


def rho_inv(S, C):
    G_S = G(S)
    M = [C[i] ^ G_S[i] for i in range(16)]
    S_prime = [S[i] ^ M[i] for i in range(16)]
    return S_prime, M


def tk_encoding(counter, b, t, k):
    return counter + [b ^ MEMBER_MASK] + [0] * 8 + t + k


# function that implements the AE encryption
# inputs: M the message, A the associated data, N the nonce, K the key
# outputs: C the ciphertext (the last 16 bytes representing the authentication tag)
def crypto_aead_encrypt(M, A, N, K):
    S = [0] * 16
    counter = [1] + [0] * (COUNTER_LENGTH - 1)

    A_parsed = parse(A,16)
    a = len(A_parsed)-1
    M_parsed = parse(M,16)
    m = len(M_parsed)-1
    X = A_parsed[1:] + M_parsed[1:]
    X.insert(0,[])

    w = 16
    if len(X[a]) < 16: w = w ^ 2  
    if len(X[a+m]) < 16: w = w ^ 1  
    if a%2 == 0: w = w ^ 8
    if m%2 == 0: w = w ^ 4

    X[a] = pad(X[a],16)
    X[a+m] = pad(X[a+m],16)

    x = 8

    for i in range(1,math.floor((a+m)/2)+1):
        S, _ = rho(S, X[2*i-1])
        counter = increase_counter(counter)
        if i == math.floor(a/2)+1: x = x ^ 4
        S = skinny_enc(S, tk_encoding(counter, x, X[2*i], K))
        counter = increase_counter(counter)
        

    if a%2 == m%2: S, _ = rho(S, [0]*16)
    else: 
        S, _ = rho(S, X[a+m])
        counter = increase_counter(counter)
    S = skinny_enc(S, tk_encoding(counter, w, N, K))
    _, T = rho(S, [0]*16)

    if len(M) == 0: return T
    S = T[:]
    C = []

    z = len(M_parsed[m])
    M_parsed[m] = pad(M_parsed[m],16)

    counter = [1] + [0] * (COUNTER_LENGTH - 1)

    for i in range(1,m+1):
        S = skinny_enc(S, tk_encoding(counter, 4, N, K))
        S, X = rho(S, M_parsed[i])
        counter = increase_counter(counter)
        if i<m: C.extend(X)
        else: C.extend(X[:z])          
        
    C.extend(T)
    return C 


# function that implements the AE decryption
# inputs: C the ciphertext (the last 16 bytes representing the authentication tag), A the associated data, N the nonce, K the key
# outputs: (0,M) with M the message if the tag is verified, returns (-1,[]) otherwise
def crypto_aead_decrypt(C, A, N, K):
    M = []
    T = C[-16:]
    C[-16:] = []

    if len(C) != 0: 
        S = T[:]
        C_parsed = parse(C,16)
        c = len(C_parsed)-1
        z = len(C_parsed[c])
        C_parsed[c] = pad(C_parsed[c],16)

        counter = [1] + [0] * (COUNTER_LENGTH - 1)

        for i in range(1,c+1):
            S = skinny_enc(S, tk_encoding(counter, 4, N, K))
            S, X = rho_inv(S, C_parsed[i])
            counter = increase_counter(counter)
            if i<c: M.extend(X)
            else: M.extend(X[:z])          

    else:
        S = []


    S = [0] * 16
    counter = [1] + [0] * (COUNTER_LENGTH - 1)

    A_parsed = parse(A,16)
    a = len(A_parsed)-1
    M_parsed = parse(M,16)
    m = len(M_parsed)-1
    X = A_parsed[1:] + M_parsed[1:]
    X.insert(0,[])

    w = 16
    if len(X[a]) < 16: w = w ^ 2  
    if len(X[a+m]) < 16: w = w ^ 1  
    if a%2 == 0: w = w ^ 8
    if m%2 == 0: w = w ^ 4

    X[a] = pad(X[a],16)
    X[a+m] = pad(X[a+m],16)

    x = 8

    for i in range(1,math.floor((a+m)/2)+1):
        S, _ = rho(S, X[2*i-1])
        counter = increase_counter(counter)
        if i == math.floor(a/2)+1: x = x ^ 4
        S = skinny_enc(S, tk_encoding(counter, x, X[2*i], K))
        counter = increase_counter(counter)

    if a%2 == m%2: S, _ = rho(S, [0]*16)
    else: 
        S, _ = rho(S, X[a+m])
        counter = increase_counter(counter)
    S = skinny_enc(S, tk_encoding(counter, w, N, K))
    _, T_computed = rho(S, [0]*16)


    compare = 0
    for i in range(16):
        compare |= (T[i] ^ T_computed[i])

    if compare != 0:
        return -1, []
    else:
        return 0, M
