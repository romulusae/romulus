# Skinny constant time Python Implementation

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

# constants in SKINNY
c = [0x01,0x03,0x07,0x0F,0x1F,0x3E,0x3D,0x3B,0x37,0x2F,0x1E,0x3C,0x39,0x33,0x27,0x0E,0x1D,0x3A,0x35,0x2B,0x16,0x2C,0x18,0x30,0x21,0x02,0x05,0x0B,0x17,0x2E,0x1C,0x38,0x31,0x23,0x06,0x0D,0x1B,0x36,0x2D,0x1A,0x34,0x29,0x12,0x24,0x08,0x11,0x22,0x04,0x09,0x13,0x26,0x0C,0x19,0x32,0x25,0x0A,0x15,0x2A,0x14,0x28,0x10,0x20]

# PT permutation in SKINNY
PT = [9, 15, 8, 13, 10, 14, 12, 11, 0, 1, 2, 3, 4, 5, 6, 7]


#VERSION 0 is SKINNY-64-64
#VERSION 1 is SKINNY-64-128
#VERSION 2 is SKINNY-64-192
#VERSION 3 is SKINNY-128-128
#VERSION 4 is SKINNY-128-256
#VERSION 5 is SKINNY-128-384
TAB_ROUNDS = [32, 36, 40, 40, 48, 56]
TAB_TWEAK_LENGTH = [16, 32, 48, 16, 32, 48]

# functions that implement the Skinny TBC encryption
def skinny_enc(plaintext, tweakey, version):
    
    tk = [[0]*TAB_TWEAK_LENGTH[version]]*(TAB_ROUNDS[version]+1)
    
    if version in [0,1,2]: 
        s = [(plaintext[i>>1] >> 4*((i+1)%2)) & 0xf for i in range(16)] 
        tk[0] = [(tweakey[i>>1] >> 4*((i+1)%2)) & 0xf for i in range(TAB_TWEAK_LENGTH[version])]
    elif version in [3,4,5]: 
        s = [plaintext[i] for i in range(16)]
        tk[0] = [tweakey[i]  for i in range(TAB_TWEAK_LENGTH[version])]
        
    for i in range(TAB_ROUNDS[version]-1):
        tk[i+1] = tk[i][:]
        for j in range(TAB_TWEAK_LENGTH[version]): tk[i+1][j] = tk[i][j-j%16+PT[j%16]]
        for j in range(8): 
            if version in [1,2]: tk[i+1][j+16] = ((tk[i+1][j+16]<<1)&0xe) ^ (((tk[i+1][j+16]>>3) ^ (tk[i+1][j+16]>>2))&0x1)
            elif version in [4,5]: tk[i+1][j+16] = ((tk[i+1][j+16]<<1)&0xfe) ^ (((tk[i+1][j+16]>>7) ^ (tk[i+1][j+16]>>5))&0x1)
            if version in [2]: tk[i+1][j+32] = (tk[i+1][j+32]>>1) ^ (((tk[i+1][j+32]<<3) ^ (tk[i+1][j+32]))&0x8)
            elif version in [5]: tk[i+1][j+32] = (tk[i+1][j+32]>>1) ^ (((tk[i+1][j+32]<<7) ^ (tk[i+1][j+32]<<1))&0x80)

    for i in range(TAB_ROUNDS[version]):
        
        if version in [0,1,2]: 
            for j in range(16): 
                for k in range(3): 
                    s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x1) ^ 0x1 
                    s[j] = ((s[j]<<1)&0xe) ^ ((s[j]>>3)&0x1)
                s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x1) ^ 0x1 
        elif version in [3,4,5]: 
            for j in range(16): 
                for k in range(3): 
                    s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x11) ^ 0x11 
                    s[j] = ((s[j]>>2)&0x32) ^ ((s[j]<<5)&0xc0) ^ ((s[j]<<2)&0x04) ^ ((s[j]>>1)&0x08) ^ ((s[j]>>5)&0x01)
                s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x11) ^ 0x11 
                s[j] ^= (s[j] & 0x06) ^ ((s[j]>>1)&0x02) ^ ((s[j]<<1)&0x04)
        
        s[0] ^= c[i] & 0xf
        s[4] ^= (c[i]>>4) & 0xf
        s[8] ^= 0x2
        
        for j in range(8): s[j] ^= tk[i][j]   
        if version in [1,4]:
            for j in range(8): s[j] ^= tk[i][j+16]
        if version in [2,5]:
            for j in range(8): s[j] ^= tk[i][j+16] ^ tk[i][j+32]

        s[4], s[5], s[6], s[7] = s[7], s[4], s[5], s[6]
        s[8], s[9], s[10], s[11] = s[10], s[11], s[8], s[9]
        s[12], s[13], s[14], s[15] = s[13], s[14], s[15], s[12]
        
        for j in range(4): s[j], s[4+j], s[8+j], s[12+j] = s[j] ^ s[8+j] ^ s[12+j] , s[j], s[4+j] ^ s[8+j] , s[0+j] ^ s[8+j]   
        
    if version in [0,1,2]:  ciphertext = [(s[2*i]<<4) ^ s[2*i+1] for i in range(8)]
    if version in [3,4,5]:  ciphertext = [s[i] for i in range(16)]
    
    return ciphertext


# function that implements the Skinny TBC decryption
def skinny_dec(ciphertext, tweakey, version):
        
    tk = [[0]*TAB_TWEAK_LENGTH[version]]*TAB_ROUNDS[version]
    
    if version in [0,1,2]: 
        s = [(ciphertext[i>>1] >> 4*((i+1)%2)) & 0xf for i in range(16)] 
        tk[0] = [(tweakey[i>>1] >> 4*((i+1)%2)) & 0xf for i in range(TAB_TWEAK_LENGTH[version])]
    elif version in [3,4,5]: 
        s = [ciphertext[i] for i in range(16)]
        tk[0] = [tweakey[i]  for i in range(TAB_TWEAK_LENGTH[version])]
        
    for i in range(TAB_ROUNDS[version]-1):
        tk[i+1] = tk[i][:]
        for j in range(TAB_TWEAK_LENGTH[version]): tk[i+1][j] = tk[i][j-j%16+PT[j%16]]
        for j in range(8): 
            if version in [1,2]: tk[i+1][j+16] = ((tk[i+1][j+16]<<1)&0xe) ^ (((tk[i+1][j+16]>>3) ^ (tk[i+1][j+16]>>2))&0x1)
            elif version in [4,5]: tk[i+1][j+16] = ((tk[i+1][j+16]<<1)&0xfe) ^ (((tk[i+1][j+16]>>7) ^ (tk[i+1][j+16]>>5))&0x1)
            if version in [2]: tk[i+1][j+32] = (tk[i+1][j+32]>>1) ^ (((tk[i+1][j+32]<<3) ^ (tk[i+1][j+32]))&0x8)
            elif version in [5]: tk[i+1][j+32] = (tk[i+1][j+32]>>1) ^ (((tk[i+1][j+32]<<7) ^ (tk[i+1][j+32]<<1))&0x80)

    for i in reversed(range(TAB_ROUNDS[version])):
        
        for j in range(4): s[j], s[4+j], s[8+j], s[12+j] = s[4+j] , s[4+j] ^ s[8+j] ^ s[12+j] , s[4+j] ^ s[12+j], s[j] ^ s[12+j]   
        
        s[4], s[5], s[6], s[7] = s[5], s[6], s[7], s[4]
        s[8], s[9], s[10], s[11] = s[10], s[11], s[8], s[9]
        s[12], s[13], s[14], s[15] = s[15], s[12], s[13], s[14]
        
        for j in range(8): s[j] ^= tk[i][j]   
        if version in [1,4]:
            for j in range(8): s[j] ^= tk[i][j+16]
        if version in [2,5]:
            for j in range(8): s[j] ^= tk[i][j+16] ^ tk[i][j+32]
    
        s[0] ^= c[i] & 0xf
        s[4] ^= (c[i]>>4) & 0xf
        s[8] ^= 0x2
        
        if version in [0,1,2]: 
            for j in range(16): 
                s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x1) ^ 0x1
                for k in range(3):
                    s[j] = ((s[j]>>1)&0x7) ^ ((s[j]<<3)&0x8)
                    s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x1) ^ 0x1 
                           
        elif version in [3,4,5]: 
            for j in range(16): 
                s[j] ^= (s[j] & 0x06) ^ ((s[j]>>1)&0x02) ^ ((s[j]<<1)&0x04)
                s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x11) ^ 0x11 
                for k in range(3): 
                    s[j] = ((s[j]<<2)&0xc8) ^ ((s[j]>>5)&0x06) ^ ((s[j]>>2)&0x01) ^ ((s[j]<<5)&0x20) ^ ((s[j]<<1)&0x10)
                    s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x11) ^ 0x11 
                    

    if version in [0,1,2]:  plaintext = [(s[2*i]<<4) ^ s[2*i+1] for i in range(8)]
    if version in [3,4,5]:  plaintext = [s[i] for i in range(16)]

    return plaintext


# to print some internal state
def print_state(s,tk):
    print("\nstate : " + "".join('{:02x}'.format(_) for _ in s))
    print("TK1   : " + "".join('{:02x}'.format(_) for _ in tk[0:16]))
    if len(tk)>16: print("TK2   : " + "".join('{:02x}'.format(_) for _ in tk[16:32]))
    if len(tk)>32: print("TK3   : " + "".join('{:02x}'.format(_) for _ in tk[32:48]))


# to generate test vectors and decryption (when the data is )
def test_vectors(plaintext,key,version):
    ct = skinny_enc(plaintext,key,version)
    print("\nEncryption of " + "".join('{:02x}'.format(_) for _ in plaintext))
    print("with key      " + "".join('{:02x}'.format(_) for _ in key))
    print("gives         " + "".join('{:02x}'.format(_) for _ in ct))
    pt = skinny_dec(ct,key,version)
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
