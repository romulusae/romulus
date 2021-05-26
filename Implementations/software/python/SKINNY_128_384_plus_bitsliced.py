# Skinny-128-384+ bitsliced Python Implementation

# Copyright 2018:
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

# constants in Skinny-128-384+ Sbox
c = [0x01,0x03,0x07,0x0F,0x1F,0x3E,0x3D,0x3B,0x37,0x2F,0x1E,0x3C,0x39,0x33,0x27,0x0E,0x1D,0x3A,0x35,0x2B,0x16,0x2C,0x18,0x30,0x21,0x02,0x05,0x0B,0x17,0x2E,0x1C,0x38,0x31,0x23,0x06,0x0D,0x1B,0x36,0x2D,0x1A]

# PT permutation in Skinny-128-384+ Sbox
PT = [9, 15, 8, 13, 10, 14, 12, 11, 0, 1, 2, 3, 4, 5, 6, 7]


ROUNDS = 40
TWEAK_LENGTH = 48
BITSLICE_WORDS = 8

# functions that implements the Skinny-128-384+ TBC encryption

# data is assumed to arrive in bitslice form, row-wise, i.e.
# 0  1  2  3
# 4  5  6  7 
# 8  9 10 11
#12 13 14 15
#
# where the data is coming as LSB 0 1 2 3 4 5 ... 16 MSB
def skinny_enc_bitslice(plaintext, tweakey):
    
    tk = [[0]*int(TWEAK_LENGTH/2)]*(ROUNDS+1)
    s = [plaintext[2*i] ^ (plaintext[2*i+1]<<8) for i in range(BITSLICE_WORDS)]
    tk[0] = [tweakey[2*BITSLICE_WORDS*j+2*i] ^ (tweakey[2*BITSLICE_WORDS*j+2*i+1]<<8) for j in range(int(TWEAK_LENGTH/16)) for i in range(BITSLICE_WORDS)]
    
    for i in range(ROUNDS-1):
        tk[i+1] = tk[i][:]        
        for j in range(int(BITSLICE_WORDS*TWEAK_LENGTH/16)): 
            tk[i+1][j] = 0
            for k in range(16):                
                tk[i+1][j] ^= ((tk[i][j]>>PT[k])&1)<<k
        
        tk[i+1][8], tk[i+1][8+1], tk[i+1][8+2], tk[i+1][8+3], tk[i+1][8+4], tk[i+1][8+5], tk[i+1][8+6], tk[i+1][8+7] = (tk[i+1][8+5] ^ tk[i+1][8+7])&0x00ff ^ (tk[i+1][8] &0xff00), (tk[i+1][8])&0x00ff ^ (tk[i+1][8+1] &0xff00), (tk[i+1][8+1])&0x00ff ^ (tk[i+1][8+2] &0xff00), (tk[i+1][8+2])&0x00ff ^ (tk[i+1][8+3] &0xff00), (tk[i+1][8+3])&0x00ff ^ (tk[i+1][8+4] &0xff00), (tk[i+1][8+4])&0x00ff ^ (tk[i+1][8+5] &0xff00), (tk[i+1][8+5])&0x00ff ^ (tk[i+1][8+6] &0xff00), (tk[i+1][8+6])&0x00ff ^ (tk[i+1][8+7] &0xff00)
        tk[i+1][16], tk[i+1][16+1], tk[i+1][16+2], tk[i+1][16+3], tk[i+1][16+4], tk[i+1][16+5], tk[i+1][16+6], tk[i+1][16+7] = (tk[i+1][16+1])&0x00ff ^ (tk[i+1][16] &0xff00), (tk[i+1][16+2])&0x00ff ^ (tk[i+1][16+1] &0xff00) , (tk[i+1][16+3]) &0x00ff ^ (tk[i+1][16+2] &0xff00), (tk[i+1][16+4]) &0x00ff ^ (tk[i+1][16+3] &0xff00), (tk[i+1][16+5]) &0x00ff ^ (tk[i+1][16+4] &0xff00), (tk[i+1][16+6]) &0x00ff ^ (tk[i+1][16+5] &0xff00) , (tk[i+1][16+7]) &0x00ff ^ (tk[i+1][16+6] &0xff00), (tk[i+1][16] ^ tk[i+1][16+6])&0x00ff ^ (tk[i+1][16+7] &0xff00)
            
    for i in range(ROUNDS):
        
        for _ in range(3): s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7] = s[5], s[3], 0xffff ^ s[0] ^ (s[3] | s[2]), 0xffff ^ s[4] ^ (s[7] | s[6]), s[6], s[7], s[1], s[2]
        s[0], s[1], s[2], s[4] = 0xffff ^ s[0] ^ (s[3] | s[2]), s[2], s[1], 0xffff ^ s[4] ^ (s[7] | s[6])
            
        s[0] ^= c[i] & 0x11
        s[1] ^= (c[i] & 0x22) >> 1
        s[2] ^= (c[i] & 0x44) >> 2
        s[3] ^= (c[i] & 0x88) >> 3
        s[1] ^= 0x0100
            
        for j in range(BITSLICE_WORDS): s[j] ^= (tk[i][j]&0x00ff)   
        for j in range(BITSLICE_WORDS): s[j] ^= ((tk[i][j+BITSLICE_WORDS] ^ tk[i][j+2*BITSLICE_WORDS])&0x00ff)
                
        for j in range(BITSLICE_WORDS): 
            s[j]  = (s[j]&0x0f0f) ^ ((s[j]<<1)&0xe0e0) ^ ((s[j]>>3)&0x1010)
            s[j]  = (s[j]&0x00ff) ^ ((s[j]<<2)&0xcc00) ^ ((s[j]>>2)&0x3300)
            
        for j in range(BITSLICE_WORDS):  
            t = (s[j]&0xff0f) ^ ((s[j]<<4)&0xfff0)
            s[j] = t ^ ((t>>12)&0x000f) ^ (((s[j]<<12) ^ s[j])&0xf000)
            
    ciphertext = [(s[k>>1]>>(8*(k&1))) & 0xff for k in range(2*BITSLICE_WORDS)]
    
    return ciphertext


# functions that implements the Skinny-128-384+ TBC decryption
    
def skinny_dec_bitslice(ciphertext, tweakey):
    
    tk = [[0]*int(TWEAK_LENGTH/2)]*(ROUNDS+1)      
    s = [ciphertext[2*i] ^ (ciphertext[2*i+1]<<8) for i in range(BITSLICE_WORDS)]
    tk[0] = [tweakey[2*BITSLICE_WORDS*j+2*i] ^ (tweakey[2*BITSLICE_WORDS*j+2*i+1]<<8) for j in range(int(TWEAK_LENGTH/16)) for i in range(BITSLICE_WORDS)]

    for i in range(ROUNDS-1):
        tk[i+1] = tk[i][:]        
        for j in range(int(BITSLICE_WORDS*TWEAK_LENGTH/16)): 
            tk[i+1][j] = 0
            for k in range(16):                
                tk[i+1][j] ^= ((tk[i][j]>>PT[k])&1)<<k
        
        tk[i+1][8], tk[i+1][8+1], tk[i+1][8+2], tk[i+1][8+3], tk[i+1][8+4], tk[i+1][8+5], tk[i+1][8+6], tk[i+1][8+7] = (tk[i+1][8+5] ^ tk[i+1][8+7])&0x00ff ^ (tk[i+1][8] &0xff00), (tk[i+1][8])&0x00ff ^ (tk[i+1][8+1] &0xff00), (tk[i+1][8+1])&0x00ff ^ (tk[i+1][8+2] &0xff00), (tk[i+1][8+2])&0x00ff ^ (tk[i+1][8+3] &0xff00), (tk[i+1][8+3])&0x00ff ^ (tk[i+1][8+4] &0xff00), (tk[i+1][8+4])&0x00ff ^ (tk[i+1][8+5] &0xff00), (tk[i+1][8+5])&0x00ff ^ (tk[i+1][8+6] &0xff00), (tk[i+1][8+6])&0x00ff ^ (tk[i+1][8+7] &0xff00)
        tk[i+1][16], tk[i+1][16+1], tk[i+1][16+2], tk[i+1][16+3], tk[i+1][16+4], tk[i+1][16+5], tk[i+1][16+6], tk[i+1][16+7] = (tk[i+1][16+1])&0x00ff ^ (tk[i+1][16] &0xff00), (tk[i+1][16+2])&0x00ff ^ (tk[i+1][16+1] &0xff00) , (tk[i+1][16+3]) &0x00ff ^ (tk[i+1][16+2] &0xff00), (tk[i+1][16+4]) &0x00ff ^ (tk[i+1][16+3] &0xff00), (tk[i+1][16+5]) &0x00ff ^ (tk[i+1][16+4] &0xff00), (tk[i+1][16+6]) &0x00ff ^ (tk[i+1][16+5] &0xff00) , (tk[i+1][16+7]) &0x00ff ^ (tk[i+1][16+6] &0xff00), (tk[i+1][16] ^ tk[i+1][16+6])&0x00ff ^ (tk[i+1][16+7] &0xff00)
            
    for i in reversed(range(ROUNDS)):
        for j in range(BITSLICE_WORDS):  
            s[j] = (s[j]&0xf0f0) ^ ((s[j]>>4)&0x0fff) ^ ((s[j]<<12)&0xf000) ^ ((s[j]<<4)&0x0f00) ^ ((s[j]>>8)&0x00f0)
            
        for j in range(BITSLICE_WORDS): 
            s[j]  = (s[j]&0x00ff) ^ ((s[j]<<2)&0xcc00) ^ ((s[j]>>2)&0x3300)
            s[j]  = (s[j]&0x0f0f) ^ ((s[j]>>1)&0x7070) ^ ((s[j]<<3)&0x8080)
                      
        for j in range(BITSLICE_WORDS): s[j] ^= (tk[i][j]&0x00ff)   
        for j in range(BITSLICE_WORDS): s[j] ^= ((tk[i][j+BITSLICE_WORDS] ^ tk[i][j+2*BITSLICE_WORDS])&0x00ff)
                                        
        s[0] ^= c[i] & 0x11
        s[1] ^= (c[i] & 0x22) >> 1
        s[2] ^= (c[i] & 0x44) >> 2
        s[3] ^= (c[i] & 0x88) >> 3
        s[1] ^= 0x0100
        
        s[0], s[1], s[2], s[4] = 0xffff ^ s[0] ^ (s[3] | s[1]), s[2], s[1], 0xffff ^ s[4] ^ (s[7] | s[6])
        for _ in range(3): s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7] = 0xffff ^ s[2] ^ (s[1] | s[7]), s[6], s[7], s[1], 0xffff ^ s[3] ^ (s[5] | s[4]), s[0], s[4], s[5]
            
    plaintext = [(s[k>>1]>>(8*(k&1))) & 0xff for k in range(2*BITSLICE_WORDS)]
    
    return plaintext

    
# TEST AGAINST THE NON BITSLICED IMPLEMENTATION 
from SKINNY_128_384_plus import *

def convert_to_bitslice(t):
    s = [0]*BITSLICE_WORDS
    for i in range(BITSLICE_WORDS):
        for j in range(16):
            s[i] ^= ((t[j>>int(BITSLICE_WORDS==4)]>> (i+(BITSLICE_WORDS*(1-j&1)&0x7)) &1) <<j)
    return s

def convert_to_normal(s):
    t = [0]*2*BITSLICE_WORDS
    for i in range(BITSLICE_WORDS):
        for j in range(16):
            t[j>>int(BITSLICE_WORDS==4)] ^= ((s[i]>>j)&1)<<(i+(BITSLICE_WORDS*(1-j&1)&0x7))
    return t

def convert_16_to_byte(s):
    return [(s[i>>1]>>((i&1)*8))&0xff for i in range(2*BITSLICE_WORDS)]

def convert_byte_to_16(s):
    return [s[2*i] ^ s[2*i+1]<<8 for i in range(BITSLICE_WORDS)]

def test_version(plaintext,key):
    
    key_bitslice = []
    for i in range(int(TWEAK_LENGTH/16)): key_bitslice.extend(convert_to_bitslice(key[2*BITSLICE_WORDS*i:2*BITSLICE_WORDS*(i+1)]))
    key_bitslice_byte = []
    for i in range(int(TWEAK_LENGTH/16)): key_bitslice_byte.extend(convert_16_to_byte(key_bitslice[BITSLICE_WORDS*i:BITSLICE_WORDS*(i+1)]))
    
    print("\nENCRYPTION")
    ct = skinny_enc(plaintext,key)
    print("non-bitsliced version: ", end="")
    print("".join('{:02x}'.format(_) for _ in ct))
    plaintext_bitslice = convert_to_bitslice(plaintext)
    ciphertext_bitslice = skinny_enc_bitslice(convert_16_to_byte(plaintext_bitslice),key_bitslice_byte)
    ciphertext = convert_to_normal(convert_byte_to_16(ciphertext_bitslice))
    print("bitsliced version:     ", end="")
    print("".join('{:02x}'.format(_) for _ in ciphertext))
    
    print("DECRYPTION")
    pt = skinny_dec(ct,key)
    if plaintext != pt: 
        print("non-bitsliced version: PROBLEM !")
    else: 
        print("non-bitsliced version: OK")
    ciphertext_bitslice = convert_to_bitslice(ciphertext)
    plaintext_bitslice = skinny_dec_bitslice(convert_16_to_byte(ciphertext_bitslice),key_bitslice_byte)
    pt = convert_to_normal(convert_byte_to_16(plaintext_bitslice))
    if plaintext != pt:
        print("bitsliced version:     PROBLEM !")
    else: 
        print("bitsliced version:     OK")

plaintext = [0xa3,0x99,0x4b,0x66,0xad,0x85,0xa3,0x45,0x9f,0x44,0xe9,0x2b,0x08,0xf5,0x50,0xcb]
key = [0xdf,0x88,0x95,0x48,0xcf,0xc7,0xea,0x52,0xd2,0x96,0x33,0x93,0x01,0x79,0x74,0x49,0xab,0x58,0x8a,0x34,0xa4,0x7f,0x1a,0xb2,0xdf,0xe9,0xc8,0x29,0x3f,0xbe,0xa9,0xa5,0xab,0x1a,0xfa,0xc2,0x61,0x10,0x12,0xcd,0x8c,0xef,0x95,0x26,0x18,0xc3,0xeb,0xe8]
test_version(plaintext,key)


# to generate test vectors and decryption 
def test_vectors(plaintext,key):
    ct = skinny_enc_bitslice(plaintext,key)
    print("\nEncryption of " + "".join('{:02x}'.format(_) for _ in plaintext))
    print("with key      " + "".join('{:02x}'.format(_) for _ in key))
    print("gives         " + "".join('{:02x}'.format(_) for _ in ct))
    pt = skinny_dec_bitslice(ct,key)
    print("Decryption:   " + "".join('{:02x}'.format(_) for _ in pt))

plaintext = [0xa3,0x99,0x4b,0x66,0xad,0x85,0xa3,0x45,0x9f,0x44,0xe9,0x2b,0x08,0xf5,0x50,0xcb]
key = [0xdf,0x88,0x95,0x48,0xcf,0xc7,0xea,0x52,0xd2,0x96,0x33,0x93,0x01,0x79,0x74,0x49,0xab,0x58,0x8a,0x34,0xa4,0x7f,0x1a,0xb2,0xdf,0xe9,0xc8,0x29,0x3f,0xbe,0xa9,0xa5,0xab,0x1a,0xfa,0xc2,0x61,0x10,0x12,0xcd,0x8c,0xef,0x95,0x26,0x18,0xc3,0xeb,0xe8]
test_vectors(plaintext,key)