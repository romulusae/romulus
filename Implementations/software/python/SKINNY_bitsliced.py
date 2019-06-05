# Skinny-AEAD and Skinny-HASH Reference Python Implementation

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

#####################################################################
## SKINNY-AEAD
#####################################################################

# # MEMBER M1
NONCE_LENGTH = 16
TAG_LENGTH = 16
SKINNY_VERSION = 5

# # MEMBER M2
# NONCE_LENGTH = 12
# TAG_LENGTH = 16
# SKINNY_VERSION = 5

## MEMBER M3
# NONCE_LENGTH = 16
# TAG_LENGTH = 8
# SKINNY_VERSION = 5

# # MEMBER M4
# NONCE_LENGTH = 12
# TAG_LENGTH = 8
# SKINNY_VERSION = 5

# # MEMBER M5
# NONCE_LENGTH = 12
# TAG_LENGTH = 16
# SKINNY_VERSION = 4

## MEMBER M6
# NONCE_LENGTH = 12
# TAG_LENGTH = 8
# SKINNY_VERSION = 4

#####################################################################
## SKINNY-HASH
#####################################################################

# MEMBER M1
#RATE = 16
#CAPACITY = 32
#SKINNY_VERSION = 5

# # MEMBER M2
# RATE = 4
# CAPACITY = 28
# SKINNY_VERSION = 4

# constants in SKINNY
c = [0x01,0x03,0x07,0x0F,0x1F,0x3E,0x3D,0x3B,0x37,0x2F,0x1E,0x3C,0x39,0x33,0x27,0x0E,0x1D,0x3A,0x35,0x2B,0x16,0x2C,0x18,0x30,0x21,0x02,0x05,0x0B,0x17,0x2E,0x1C,0x38,0x31,0x23,0x06,0x0D,0x1B,0x36,0x2D,0x1A,0x34,0x29,0x12,0x24,0x08,0x11,0x22,0x04,0x09,0x13,0x26,0x0C,0x19,0x32,0x25,0x0A,0x15,0x2A,0x14,0x28,0x10,0x20]

# PT permutation in SKINNY
PT = [9, 15, 8, 13, 10, 14, 12, 11, 0, 1, 2, 3, 4, 5, 6, 7]

# functions that implements the Skinny TBC encryption
#VERSION 0 is SKINNY-64-64
#VERSION 1 is SKINNY-64-128
#VERSION 2 is SKINNY-64-192
#VERSION 3 is SKINNY-128-128
#VERSION 4 is SKINNY-128-256
#VERSION 5 is SKINNY-128-384
TAB_ROUNDS = [32, 36, 40, 40, 48, 56]
TAB_TWEAK_LENGTH = [16, 32, 48, 16, 32, 48]
TAB_BITSLICE_WORDS = [4, 4, 4, 8, 8, 8]


# data is assumed to arrive in bitslice form, row-wise, i.e.
# 0  1  2  3
# 4  5  6  7 
# 8  9 10 11
#12 13 14 15
#
# where the data is coming as LSB 0 1 2 3 4 5 ... 16 MSB
def skinny_enc_bitslice(plaintext, tweakey, version):
    
    tk = [[0]*int(TAB_TWEAK_LENGTH[version]/2)]*(TAB_ROUNDS[version]+1)
    s = [plaintext[2*i] ^ (plaintext[2*i+1]<<8) for i in range(TAB_BITSLICE_WORDS[version])]
    tk[0] = [tweakey[2*TAB_BITSLICE_WORDS[version]*j+2*i] ^ (tweakey[2*TAB_BITSLICE_WORDS[version]*j+2*i+1]<<8) for j in range(int(TAB_TWEAK_LENGTH[version]/16)) for i in range(TAB_BITSLICE_WORDS[version])]
    
    for i in range(TAB_ROUNDS[version]-1):
        tk[i+1] = tk[i][:]        
        for j in range(int(TAB_BITSLICE_WORDS[version]*TAB_TWEAK_LENGTH[version]/16)): 
            tk[i+1][j] = 0
            for k in range(16):                
                tk[i+1][j] ^= ((tk[i][j]>>PT[k])&1)<<k
        
        if version in [1,2]: tk[i+1][4], tk[i+1][4+1], tk[i+1][4+2], tk[i+1][4+3] = (tk[i+1][4+3] ^ tk[i+1][4+2])&0x00ff ^ (tk[i+1][4] &0xff00), (tk[i+1][4])&0x00ff ^ (tk[i+1][4+1] &0xff00), (tk[i+1][4+1])&0x00ff ^ (tk[i+1][4+2] &0xff00), (tk[i+1][4+2])&0x00ff ^ (tk[i+1][4+3] &0xff00)
        elif version in [4,5]: tk[i+1][8], tk[i+1][8+1], tk[i+1][8+2], tk[i+1][8+3], tk[i+1][8+4], tk[i+1][8+5], tk[i+1][8+6], tk[i+1][8+7] = (tk[i+1][8+5] ^ tk[i+1][8+7])&0x00ff ^ (tk[i+1][8] &0xff00), (tk[i+1][8])&0x00ff ^ (tk[i+1][8+1] &0xff00), (tk[i+1][8+1])&0x00ff ^ (tk[i+1][8+2] &0xff00), (tk[i+1][8+2])&0x00ff ^ (tk[i+1][8+3] &0xff00), (tk[i+1][8+3])&0x00ff ^ (tk[i+1][8+4] &0xff00), (tk[i+1][8+4])&0x00ff ^ (tk[i+1][8+5] &0xff00), (tk[i+1][8+5])&0x00ff ^ (tk[i+1][8+6] &0xff00), (tk[i+1][8+6])&0x00ff ^ (tk[i+1][8+7] &0xff00)
        if version in [2]: tk[i+1][8], tk[i+1][8+1], tk[i+1][8+2], tk[i+1][8+3] = (tk[i+1][8+1])&0x00ff ^ (tk[i+1][8] &0xff00), (tk[i+1][8+2])&0x00ff ^ (tk[i+1][8+1] &0xff00) , (tk[i+1][8+3]) &0x00ff ^ (tk[i+1][8+2] &0xff00), (tk[i+1][8] ^ tk[i+1][8+3]) &0x00ff ^ (tk[i+1][8+3] &0xff00)
        elif version in [5]: tk[i+1][16], tk[i+1][16+1], tk[i+1][16+2], tk[i+1][16+3], tk[i+1][16+4], tk[i+1][16+5], tk[i+1][16+6], tk[i+1][16+7] = (tk[i+1][16+1])&0x00ff ^ (tk[i+1][16] &0xff00), (tk[i+1][16+2])&0x00ff ^ (tk[i+1][16+1] &0xff00) , (tk[i+1][16+3]) &0x00ff ^ (tk[i+1][16+2] &0xff00), (tk[i+1][16+4]) &0x00ff ^ (tk[i+1][16+3] &0xff00), (tk[i+1][16+5]) &0x00ff ^ (tk[i+1][16+4] &0xff00), (tk[i+1][16+6]) &0x00ff ^ (tk[i+1][16+5] &0xff00) , (tk[i+1][16+7]) &0x00ff ^ (tk[i+1][16+6] &0xff00), (tk[i+1][16] ^ tk[i+1][16+6])&0x00ff ^ (tk[i+1][16+7] &0xff00)
            
    for i in range(TAB_ROUNDS[version]):
        
        if version in [0,1,2]:  
            for _ in range(3): s[0], s[1], s[2], s[3] = s[3], 0xffff ^ s[0] ^ (s[3] | s[2]), s[1], s[2]
            s[0] = 0xffff ^ s[0] ^ (s[3] | s[2])
        elif version in [3,4,5]: 
            for _ in range(3): s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7] = s[5], s[3], 0xffff ^ s[0] ^ (s[3] | s[2]), 0xffff ^ s[4] ^ (s[7] | s[6]), s[6], s[7], s[1], s[2]
            s[0], s[1], s[2], s[4] = 0xffff ^ s[0] ^ (s[3] | s[2]), s[2], s[1], 0xffff ^ s[4] ^ (s[7] | s[6])
            
        s[0] ^= c[i] & 0x11
        s[1] ^= (c[i] & 0x22) >> 1
        s[2] ^= (c[i] & 0x44) >> 2
        s[3] ^= (c[i] & 0x88) >> 3
        s[1] ^= 0x0100
            
        for j in range(TAB_BITSLICE_WORDS[version]): s[j] ^= (tk[i][j]&0x00ff)   
        if version in [1,4]:
            for j in range(TAB_BITSLICE_WORDS[version]): s[j] ^= (tk[i][j+TAB_BITSLICE_WORDS[version]]&0x00ff)
        if version in [2,5]:
            for j in range(TAB_BITSLICE_WORDS[version]): s[j] ^= ((tk[i][j+TAB_BITSLICE_WORDS[version]] ^ tk[i][j+2*TAB_BITSLICE_WORDS[version]])&0x00ff)
                
        for j in range(TAB_BITSLICE_WORDS[version]): 
            s[j]  = (s[j]&0x0f0f) ^ ((s[j]<<1)&0xe0e0) ^ ((s[j]>>3)&0x1010)
            s[j]  = (s[j]&0x00ff) ^ ((s[j]<<2)&0xcc00) ^ ((s[j]>>2)&0x3300)
            
        for j in range(TAB_BITSLICE_WORDS[version]):  
            t = (s[j]&0xff0f) ^ ((s[j]<<4)&0xfff0)
            s[j] = t ^ ((t>>12)&0x000f) ^ (((s[j]<<12) ^ s[j])&0xf000)
            
    ciphertext = [(s[k>>1]>>(8*(k&1))) & 0xff for k in range(2*TAB_BITSLICE_WORDS[version])]
    
    return ciphertext


def skinny_dec_bitslice(ciphertext, tweakey, version):
    
    tk = [[0]*int(TAB_TWEAK_LENGTH[version]/2)]*(TAB_ROUNDS[version]+1)      
    s = [ciphertext[2*i] ^ (ciphertext[2*i+1]<<8) for i in range(TAB_BITSLICE_WORDS[version])]
    tk[0] = [tweakey[2*TAB_BITSLICE_WORDS[version]*j+2*i] ^ (tweakey[2*TAB_BITSLICE_WORDS[version]*j+2*i+1]<<8) for j in range(int(TAB_TWEAK_LENGTH[version]/16)) for i in range(TAB_BITSLICE_WORDS[version])]

    for i in range(TAB_ROUNDS[version]-1):
        tk[i+1] = tk[i][:]        
        for j in range(int(TAB_BITSLICE_WORDS[version]*TAB_TWEAK_LENGTH[version]/16)): 
            tk[i+1][j] = 0
            for k in range(16):                
                tk[i+1][j] ^= ((tk[i][j]>>PT[k])&1)<<k
        
        if version in [1,2]: tk[i+1][4], tk[i+1][4+1], tk[i+1][4+2], tk[i+1][4+3] = (tk[i+1][4+3] ^ tk[i+1][4+2])&0x00ff ^ (tk[i+1][4] &0xff00), (tk[i+1][4])&0x00ff ^ (tk[i+1][4+1] &0xff00), (tk[i+1][4+1])&0x00ff ^ (tk[i+1][4+2] &0xff00), (tk[i+1][4+2])&0x00ff ^ (tk[i+1][4+3] &0xff00)
        elif version in [4,5]: tk[i+1][8], tk[i+1][8+1], tk[i+1][8+2], tk[i+1][8+3], tk[i+1][8+4], tk[i+1][8+5], tk[i+1][8+6], tk[i+1][8+7] = (tk[i+1][8+5] ^ tk[i+1][8+7])&0x00ff ^ (tk[i+1][8] &0xff00), (tk[i+1][8])&0x00ff ^ (tk[i+1][8+1] &0xff00), (tk[i+1][8+1])&0x00ff ^ (tk[i+1][8+2] &0xff00), (tk[i+1][8+2])&0x00ff ^ (tk[i+1][8+3] &0xff00), (tk[i+1][8+3])&0x00ff ^ (tk[i+1][8+4] &0xff00), (tk[i+1][8+4])&0x00ff ^ (tk[i+1][8+5] &0xff00), (tk[i+1][8+5])&0x00ff ^ (tk[i+1][8+6] &0xff00), (tk[i+1][8+6])&0x00ff ^ (tk[i+1][8+7] &0xff00)
        if version in [2]: tk[i+1][8], tk[i+1][8+1], tk[i+1][8+2], tk[i+1][8+3] = (tk[i+1][8+1])&0x00ff ^ (tk[i+1][8] &0xff00), (tk[i+1][8+2])&0x00ff ^ (tk[i+1][8+1] &0xff00) , (tk[i+1][8+3]) &0x00ff ^ (tk[i+1][8+2] &0xff00), (tk[i+1][8] ^ tk[i+1][8+3]) &0x00ff ^ (tk[i+1][8+3] &0xff00)
        elif version in [5]: tk[i+1][16], tk[i+1][16+1], tk[i+1][16+2], tk[i+1][16+3], tk[i+1][16+4], tk[i+1][16+5], tk[i+1][16+6], tk[i+1][16+7] = (tk[i+1][16+1])&0x00ff ^ (tk[i+1][16] &0xff00), (tk[i+1][16+2])&0x00ff ^ (tk[i+1][16+1] &0xff00) , (tk[i+1][16+3]) &0x00ff ^ (tk[i+1][16+2] &0xff00), (tk[i+1][16+4]) &0x00ff ^ (tk[i+1][16+3] &0xff00), (tk[i+1][16+5]) &0x00ff ^ (tk[i+1][16+4] &0xff00), (tk[i+1][16+6]) &0x00ff ^ (tk[i+1][16+5] &0xff00) , (tk[i+1][16+7]) &0x00ff ^ (tk[i+1][16+6] &0xff00), (tk[i+1][16] ^ tk[i+1][16+6])&0x00ff ^ (tk[i+1][16+7] &0xff00)
            
    for i in reversed(range(TAB_ROUNDS[version])):
        for j in range(TAB_BITSLICE_WORDS[version]):  
            s[j] = (s[j]&0xf0f0) ^ ((s[j]>>4)&0x0fff) ^ ((s[j]<<12)&0xf000) ^ ((s[j]<<4)&0x0f00) ^ ((s[j]>>8)&0x00f0)
            
        for j in range(TAB_BITSLICE_WORDS[version]): 
            s[j]  = (s[j]&0x00ff) ^ ((s[j]<<2)&0xcc00) ^ ((s[j]>>2)&0x3300)
            s[j]  = (s[j]&0x0f0f) ^ ((s[j]>>1)&0x7070) ^ ((s[j]<<3)&0x8080)
                      
        for j in range(TAB_BITSLICE_WORDS[version]): s[j] ^= (tk[i][j]&0x00ff)   
        if version in [1,4]:
            for j in range(TAB_BITSLICE_WORDS[version]): s[j] ^= (tk[i][j+TAB_BITSLICE_WORDS[version]]&0x00ff)
        if version in [2,5]:
            for j in range(TAB_BITSLICE_WORDS[version]): s[j] ^= ((tk[i][j+TAB_BITSLICE_WORDS[version]] ^ tk[i][j+2*TAB_BITSLICE_WORDS[version]])&0x00ff)
                                        
        s[0] ^= c[i] & 0x11
        s[1] ^= (c[i] & 0x22) >> 1
        s[2] ^= (c[i] & 0x44) >> 2
        s[3] ^= (c[i] & 0x88) >> 3
        s[1] ^= 0x0100
        
        if version in [0,1,2]:  
            s[0] = 0xffff ^ s[0] ^ (s[3] | s[2])
            for _ in range(3): s[0], s[1], s[2], s[3] = 0xffff ^ s[1] ^ (s[3] | s[0]), s[2], s[3], s[0]
            
        elif version in [3,4,5]: 
            s[0], s[1], s[2], s[4] = 0xffff ^ s[0] ^ (s[3] | s[1]), s[2], s[1], 0xffff ^ s[4] ^ (s[7] | s[6])
            for _ in range(3): s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[7] = 0xffff ^ s[2] ^ (s[1] | s[7]), s[6], s[7], s[1], 0xffff ^ s[3] ^ (s[5] | s[4]), s[0], s[4], s[5]
            
    plaintext = [(s[k>>1]>>(8*(k&1))) & 0xff for k in range(2*TAB_BITSLICE_WORDS[version])]
    
    return plaintext

    
# TEST AGAINST THE NON BITSLICED IMPLEMENTATION 
from SKINNY import *

def convert_to_bitslice(t,version):
    s = [0]*TAB_BITSLICE_WORDS[version]
    for i in range(TAB_BITSLICE_WORDS[version]):
        for j in range(16):
            s[i] ^= ((t[j>>int(TAB_BITSLICE_WORDS[version]==4)]>> (i+(TAB_BITSLICE_WORDS[version]*(1-j&1)&0x7)) &1) <<j)
    return s

def convert_to_normal(s,version):
    t = [0]*2*TAB_BITSLICE_WORDS[version]
    for i in range(TAB_BITSLICE_WORDS[version]):
        for j in range(16):
            t[j>>int(TAB_BITSLICE_WORDS[version]==4)] ^= ((s[i]>>j)&1)<<(i+(TAB_BITSLICE_WORDS[version]*(1-j&1)&0x7))
    return t

def convert_16_to_byte(s,version):
    return [(s[i>>1]>>((i&1)*8))&0xff for i in range(2*TAB_BITSLICE_WORDS[version])]

def convert_byte_to_16(s,version):
    return [s[2*i] ^ s[2*i+1]<<8 for i in range(TAB_BITSLICE_WORDS[version])]

def test_version(plaintext,key,version):
    
    key_bitslice = []
    for i in range(int(TAB_TWEAK_LENGTH[version]/16)): key_bitslice.extend(convert_to_bitslice(key[2*TAB_BITSLICE_WORDS[version]*i:2*TAB_BITSLICE_WORDS[version]*(i+1)],version))
    key_bitslice_byte = []
    for i in range(int(TAB_TWEAK_LENGTH[version]/16)): key_bitslice_byte.extend(convert_16_to_byte(key_bitslice[TAB_BITSLICE_WORDS[version]*i:TAB_BITSLICE_WORDS[version]*(i+1)],version))
    
    print("\nENCRYPTION")
    ct = skinny_enc(plaintext,key,version)
    print("non-bitsliced version: ", end="")
    print("".join('{:02x}'.format(_) for _ in ct))
    plaintext_bitslice = convert_to_bitslice(plaintext,version)
    ciphertext_bitslice = skinny_enc_bitslice(convert_16_to_byte(plaintext_bitslice,version),key_bitslice_byte,version)
    ciphertext = convert_to_normal(convert_byte_to_16(ciphertext_bitslice,version),version)
    print("bitsliced version:     ", end="")
    print("".join('{:02x}'.format(_) for _ in ciphertext))
    
    print("DECRYPTION")
    pt = skinny_dec(ct,key,version)
    if plaintext != pt: 
        print("non-bitsliced version: PROBLEM !")
    else: 
        print("non-bitsliced version: OK")
    ciphertext_bitslice = convert_to_bitslice(ciphertext,version)
    plaintext_bitslice = skinny_dec_bitslice(convert_16_to_byte(ciphertext_bitslice,version),key_bitslice_byte,version)
    pt = convert_to_normal(convert_byte_to_16(plaintext_bitslice,version),version)
    if plaintext != pt:
        print("bitsliced version:     PROBLEM !")
    else: 
        print("bitsliced version:     OK")

plaintext = [0x06,0x03,0x4f,0x95,0x77,0x24,0xd1,0x9d]
key = [0xf5,0x26,0x98,0x26,0xfc,0x68,0x12,0x38]
test_version(plaintext,key,0)

plaintext = [0xcf,0x16,0xcf,0xe8,0xfd,0x0f,0x98,0xaa]
key = [0x9e,0xb9,0x36,0x40,0xd0,0x88,0xda,0x63,0x76,0xa3,0x9d,0x1c,0x8b,0xea,0x71,0xe1]
test_version(plaintext,key,1)

plaintext = [0x53,0x0c,0x61,0xd3,0x5e,0x86,0x63,0xc3]
key = [0xed,0x00,0xc8,0x5b,0x12,0x0d,0x68,0x61,0x87,0x53,0xe2,0x4b,0xfd,0x90,0x8f,0x60,0xb2,0xdb,0xb4,0x1b,0x42,0x2d,0xfc,0xd0]
test_version(plaintext,key,2)

plaintext = [0xf2,0x0a,0xdb,0x0e,0xb0,0x8b,0x64,0x8a,0x3b,0x2e,0xee,0xd1,0xf0,0xad,0xda,0x14]
key = [0x4f,0x55,0xcf,0xb0,0x52,0x0c,0xac,0x52,0xfd,0x92,0xc1,0x5f,0x37,0x07,0x3e,0x93]
test_version(plaintext,key,3)

plaintext = [0x3a,0x0c,0x47,0x76,0x7a,0x26,0xa6,0x8d,0xd3,0x82,0xa6,0x95,0xe7,0x02,0x2e,0x25]
key = [0x00,0x9c,0xec,0x81,0x60,0x5d,0x4a,0xc1,0xd2,0xae,0x9e,0x30,0x85,0xd7,0xa1,0xf3,0x1a,0xc1,0x23,0xeb,0xfc,0x00,0xfd,0xdc,0xf0,0x10,0x46,0xce,0xed,0xdf,0xca,0xb3]
test_version(plaintext,key,4)

plaintext = [0xa3,0x99,0x4b,0x66,0xad,0x85,0xa3,0x45,0x9f,0x44,0xe9,0x2b,0x08,0xf5,0x50,0xcb]
key = [0xdf,0x88,0x95,0x48,0xcf,0xc7,0xea,0x52,0xd2,0x96,0x33,0x93,0x01,0x79,0x74,0x49,0xab,0x58,0x8a,0x34,0xa4,0x7f,0x1a,0xb2,0xdf,0xe9,0xc8,0x29,0x3f,0xbe,0xa9,0xa5,0xab,0x1a,0xfa,0xc2,0x61,0x10,0x12,0xcd,0x8c,0xef,0x95,0x26,0x18,0xc3,0xeb,0xe8]
test_version(plaintext,key,5)


# to generate test vectors and decryption (when the data is )
def test_vectors(plaintext,key,version):
    ct = skinny_enc_bitslice(plaintext,key,version)
    print("\nEncryption of " + "".join('{:02x}'.format(_) for _ in plaintext))
    print("with key      " + "".join('{:02x}'.format(_) for _ in key))
    print("gives         " + "".join('{:02x}'.format(_) for _ in ct))
    pt = skinny_dec_bitslice(ct,key,version)
    print("Decryption:   " + "".join('{:02x}'.format(_) for _ in pt))


plaintext = [0x06,0x03,0x4f,0x95,0x77,0x24,0xd1,0x9d]
key = [0xf5,0x26,0x98,0x26,0xfc,0x68,0x12,0x38]
test_vectors(plaintext,key,0)

plaintext = [0xcf,0x16,0xcf,0xe8,0xfd,0x0f,0x98,0xaa]
key = [0x9e,0xb9,0x36,0x40,0xd0,0x88,0xda,0x63,0x76,0xa3,0x9d,0x1c,0x8b,0xea,0x71,0xe1]
test_vectors(plaintext,key,1)
 
plaintext = [0x53,0x0c,0x61,0xd3,0x5e,0x86,0x63,0xc3]
key = [0xed,0x00,0xc8,0x5b,0x12,0x0d,0x68,0x61,0x87,0x53,0xe2,0x4b,0xfd,0x90,0x8f,0x60,0xb2,0xdb,0xb4,0x1b,0x42,0x2d,0xfc,0xd0]
test_vectors(plaintext,key,2)

plaintext = [0xf2,0x0a,0xdb,0x0e,0xb0,0x8b,0x64,0x8a,0x3b,0x2e,0xee,0xd1,0xf0,0xad,0xda,0x14]
key = [0x4f,0x55,0xcf,0xb0,0x52,0x0c,0xac,0x52,0xfd,0x92,0xc1,0x5f,0x37,0x07,0x3e,0x93]
test_vectors(plaintext,key,3)

plaintext = [0x3a,0x0c,0x47,0x76,0x7a,0x26,0xa6,0x8d,0xd3,0x82,0xa6,0x95,0xe7,0x02,0x2e,0x25]
key = [0x00,0x9c,0xec,0x81,0x60,0x5d,0x4a,0xc1,0xd2,0xae,0x9e,0x30,0x85,0xd7,0xa1,0xf3,0x1a,0xc1,0x23,0xeb,0xfc,0x00,0xfd,0xdc,0xf0,0x10,0x46,0xce,0xed,0xdf,0xca,0xb3]
test_vectors(plaintext,key,4)

plaintext = [0xa3,0x99,0x4b,0x66,0xad,0x85,0xa3,0x45,0x9f,0x44,0xe9,0x2b,0x08,0xf5,0x50,0xcb]
key = [0xdf,0x88,0x95,0x48,0xcf,0xc7,0xea,0x52,0xd2,0x96,0x33,0x93,0x01,0x79,0x74,0x49,0xab,0x58,0x8a,0x34,0xa4,0x7f,0x1a,0xb2,0xdf,0xe9,0xc8,0x29,0x3f,0xbe,0xa9,0xa5,0xab,0x1a,0xfa,0xc2,0x61,0x10,0x12,0xcd,0x8c,0xef,0x95,0x26,0x18,0xc3,0xeb,0xe8]
test_vectors(plaintext,key,5)