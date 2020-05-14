
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

from SKINNY import *
import math

# ####################################################################
# # ROMULUS-M
# ####################################################################

# # ROMULUS-M1+
SKINNY_VERSION = 6
T_LENGTH = 16
COUNTER_LENGTH = 7
MEMBER_MASK = 32

# # ROMULUS-M1
# SKINNY_VERSION = 5
# T_LENGTH = 16
# COUNTER_LENGTH = 7
# MEMBER_MASK = 32

# ROMULUS-M2
# SKINNY_VERSION = 5
# T_LENGTH = 12
# COUNTER_LENGTH = 6
# MEMBER_MASK = 96

# # ROMULUS-M3
# SKINNY_VERSION = 4
# T_LENGTH = 12
# COUNTER_LENGTH = 3
# MEMBER_MASK = 160

N_LENGTH = T_LENGTH

def increase_counter(counter):
    if COUNTER_LENGTH == 6:
        if counter[2] & 0x80 != 0:
            mask = 0x1b
        else:
            mask = 0
        for i in reversed(range(1, 2)):
            counter[i] = ((counter[i] << 1) & 0xfe) ^ (counter[i - 1] >> 7)
        counter[0] = ((counter[0] << 1) & 0xfe) ^ mask
        if counter[0] == 1 and counter[1] == 0 and counter[2] == 0:
            if counter[3] & 0x80 != 0:
                mask = 0x1b
            else:
                mask = 0
            for i in reversed(range(1, 3)):
                counter[i + 3] = ((counter[i + 3] << 1) & 0xfe) ^ (counter[3 + i - 1] >> 7)
            counter[3] = ((counter[3] << 1) & 0xfe) ^ mask
    elif COUNTER_LENGTH in [3, 7]:
        if counter[COUNTER_LENGTH - 1] & 0x80 != 0:
            if COUNTER_LENGTH == 7:
                mask = 0x95
            elif COUNTER_LENGTH == 3:
                mask = 0x1b
        else:
            mask = 0
        for i in reversed(range(1, COUNTER_LENGTH)):
            counter[i] = ((counter[i] << 1) & 0xfe) ^ (counter[i - 1] >> 7)
        counter[0] = ((counter[0] << 1) & 0xfe) ^ mask
    return counter


def parse_alternate(L_in,x,y): 
    L_out = []
    cursor = 0
    while len(L_in) - cursor >= x + y :
       L_out.extend([L_in[cursor:cursor+x],L_in[cursor+x:cursor+x+y]])
       cursor = cursor + x + y
    if len(L_in) - cursor >= x:
       L_out.extend([L_in[cursor:cursor+x]])
       cursor = cursor + x
    if len(L_in) - cursor > 0:
       L_out.extend([L_in[cursor:]])
    if L_in == []:
        L_out = [[]]
    L_out.insert(0,[])
    return L_out


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
    if COUNTER_LENGTH == 7:
        return counter + [b[0] ^ MEMBER_MASK] + [0] * 8 + t + k
    elif COUNTER_LENGTH == 6:
        return counter[0:3] + [b[0] ^ MEMBER_MASK] + t + k + counter[3:6] + [0] * 13
    elif COUNTER_LENGTH == 3:
        return counter + [b[0] ^ MEMBER_MASK] + t + k


# function that implements the AE encryption
def crypto_aead_encrypt(M, A, N, K):
    S = [0] * 16
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    if COUNTER_LENGTH == 6: counter[3] = 1

    A_parsed = parse_alternate(A,16,T_LENGTH)
    a = len(A_parsed)-1
    if a%2 == 0: u = T_LENGTH
    else: u = 16

    M_parsed = parse_alternate(M,16+T_LENGTH-u,u)
    m = len(M_parsed)-1
    if m%2 == 0: v = u
    else: v = 16 + T_LENGTH - u

    X = A_parsed[1:] + M_parsed[1:]
    X.insert(0,[])

    w = 16
    if len(X[a]) < u: w = w ^ 2  
    if len(X[a+m]) < v: w = w ^ 1  
    if a%2 == 0: w = w ^ 8
    if m%2 == 0: w = w ^ 4

    X[a] = pad(X[a],u)
    X[a+m] = pad(X[a+m],v)

    x = 8

    print(A_parsed)
    print(M_parsed)
    print(X)
    for i in range(1,math.floor((a+m)/2)+1):
        S, _ = rho(S, X[2*i-1])
        counter = increase_counter(counter)
        if i == math.floor(a/2)+1: x = x ^ 4
        S = skinny_enc(S, tk_encoding(counter, [x], X[2*i], K[0:16]), SKINNY_VERSION)
        counter = increase_counter(counter)
        

    if a%2 == m%2: S, _ = rho(S, [0]*16)
    else: 
        S, _ = rho(S, X[a+m])
        counter = increase_counter(counter)
    S = skinny_enc(S, tk_encoding(counter, [w], N[0: T_LENGTH], K[0:16]), SKINNY_VERSION)
    _, T = rho(S, [0]*16)

    if len(M) == 0: return T
    S = T[:]
    C = []

    M_parsed = parse(M,16)
    m = len(M_parsed)-1
    z = len(M_parsed[m])
    M_parsed[m] = pad(M_parsed[m],16)

    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    if COUNTER_LENGTH == 6: counter[3] = 1

    for i in range(1,m+1):
        S = skinny_enc(S, tk_encoding(counter, [4], N[0: T_LENGTH], K[0:16]), SKINNY_VERSION)
        S, x = rho(S, M_parsed[i])
        counter = increase_counter(counter)
        if i<m: C.extend(x)
        else: C.extend(x[:z])          
        
    C.extend(T)
    return C 


# function that implements the AE decryption
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
        if COUNTER_LENGTH == 6: counter[3] = 1

        for i in range(1,c+1):
            S = skinny_enc(S, tk_encoding(counter, [4], N[0: T_LENGTH], K[0:16]), SKINNY_VERSION)
            S, x = rho_inv(S, C_parsed[i])
            counter = increase_counter(counter)
            if i<c: M.extend(x)
            else: M.extend(x[:z])          

    else:
        S = []


    S = [0] * 16
    counter = [1] + [0] * (COUNTER_LENGTH - 1)
    if COUNTER_LENGTH == 6: counter[3] = 1

    A_parsed = parse_alternate(A,16,T_LENGTH)
    a = len(A_parsed)-1
    if a%2 == 0: u = T_LENGTH
    else: u = 16

    M_parsed = parse_alternate(M,16+T_LENGTH-u,u)
    m = len(M_parsed)-1
    if m%2 == 0: v = u
    else: v = 16 + T_LENGTH - u

    X = A_parsed[1:] + M_parsed[1:]
    X.insert(0,[])

    w = 16
    if len(X[a]) < u: w = w ^ 2  
    if len(X[a+m]) < v: w = w ^ 1  
    if a%2 == 0: w = w ^ 8
    if m%2 == 0: w = w ^ 4

    X[a] = pad(X[a],u)
    X[a+m] = pad(X[a+m],v)

    x = 8

    for i in range(1,math.floor((a+m)/2)+1):
        S, _ = rho(S, X[2*i-1])
        counter = increase_counter(counter)
        if i == math.floor(a/2)+1: x = x ^ 4
        S = skinny_enc(S, tk_encoding(counter, [x], X[2*i], K[0:16]), SKINNY_VERSION)
        counter = increase_counter(counter)

    if a%2 == m%2: S, _ = rho(S, [0]*16)
    else: 
        S, _ = rho(S, X[a+m])
        counter = increase_counter(counter)
    S = skinny_enc(S, tk_encoding(counter, [w], N[0: T_LENGTH], K[0:16]), SKINNY_VERSION)
    _, T_computed = rho(S, [0]*16)


    compare = 0
    for i in range(16):
        compare |= (T[i] ^ T_computed[i])

    if compare != 0:
        return -1, []
    else:
        return 0, M
