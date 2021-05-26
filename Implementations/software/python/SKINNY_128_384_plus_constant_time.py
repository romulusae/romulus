# Skinny-128-384+ constant time Python Implementation

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

# constants in Skinny-128-384+
c = [0x01,0x03,0x07,0x0F,0x1F,0x3E,0x3D,0x3B,0x37,0x2F,0x1E,0x3C,0x39,0x33,0x27,0x0E,0x1D,0x3A,0x35,0x2B,0x16,0x2C,0x18,0x30,0x21,0x02,0x05,0x0B,0x17,0x2E,0x1C,0x38,0x31,0x23,0x06,0x0D,0x1B,0x36,0x2D,0x1A]

# PT permutation in Skinny-128-384+
PT = [9, 15, 8, 13, 10, 14, 12, 11, 0, 1, 2, 3, 4, 5, 6, 7]


ROUNDS = 40
TAB_TWEAK_LENGTH = 48

# functions that implement the Skinny-128-384+ TBC encryption
def skinny_enc(plaintext, tweakey):
    
    tk = [[0]*TWEAK_LENGTH]*(ROUNDS+1)
    
    s = [plaintext[i] for i in range(16)]
    tk[0] = [tweakey[i]  for i in range(TWEAK_LENGTH)]
        
    for i in range(ROUNDS-1):
        tk[i+1] = tk[i][:]
        for j in range(TWEAK_LENGTH): tk[i+1][j] = tk[i][j-j%16+PT[j%16]]
        for j in range(8): 
            tk[i+1][j+16] = ((tk[i+1][j+16]<<1)&0xfe) ^ (((tk[i+1][j+16]>>7) ^ (tk[i+1][j+16]>>5))&0x1)
            tk[i+1][j+32] = (tk[i+1][j+32]>>1) ^ (((tk[i+1][j+32]<<7) ^ (tk[i+1][j+32]<<1))&0x80)

    for i in range(ROUNDS):
        
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
        for j in range(8): s[j] ^= tk[i][j+16] ^ tk[i][j+32]

        s[4], s[5], s[6], s[7] = s[7], s[4], s[5], s[6]
        s[8], s[9], s[10], s[11] = s[10], s[11], s[8], s[9]
        s[12], s[13], s[14], s[15] = s[13], s[14], s[15], s[12]
        
        for j in range(4): s[j], s[4+j], s[8+j], s[12+j] = s[j] ^ s[8+j] ^ s[12+j] , s[j], s[4+j] ^ s[8+j] , s[0+j] ^ s[8+j]   
        
    ciphertext = [s[i] for i in range(16)]
    
    return ciphertext


# function that implements the Skinny-128-384+ TBC decryption
def skinny_dec(ciphertext, tweakey):
        
    tk = [[0]*TWEAK_LENGTH]*ROUNDS
    
    s = [ciphertext[i] for i in range(16)]
    tk[0] = [tweakey[i]  for i in range(TWEAK_LENGTH)]
        
    for i in range(ROUNDS-1):
        tk[i+1] = tk[i][:]
        for j in range(TWEAK_LENGTH): tk[i+1][j] = tk[i][j-j%16+PT[j%16]]
        for j in range(8): 
            tk[i+1][j+16] = ((tk[i+1][j+16]<<1)&0xfe) ^ (((tk[i+1][j+16]>>7) ^ (tk[i+1][j+16]>>5))&0x1)
            tk[i+1][j+32] = (tk[i+1][j+32]>>1) ^ (((tk[i+1][j+32]<<7) ^ (tk[i+1][j+32]<<1))&0x80)

    for i in reversed(range(ROUNDS)):
        
        for j in range(4): s[j], s[4+j], s[8+j], s[12+j] = s[4+j] , s[4+j] ^ s[8+j] ^ s[12+j] , s[4+j] ^ s[12+j], s[j] ^ s[12+j]   
        
        s[4], s[5], s[6], s[7] = s[5], s[6], s[7], s[4]
        s[8], s[9], s[10], s[11] = s[10], s[11], s[8], s[9]
        s[12], s[13], s[14], s[15] = s[15], s[12], s[13], s[14]
        
        for j in range(8): s[j] ^= tk[i][j]   
        for j in range(8): s[j] ^= tk[i][j+16] ^ tk[i][j+32]
    
        s[0] ^= c[i] & 0xf
        s[4] ^= (c[i]>>4) & 0xf
        s[8] ^= 0x2 
 
        for j in range(16): 
            s[j] ^= (s[j] & 0x06) ^ ((s[j]>>1)&0x02) ^ ((s[j]<<1)&0x04)
            s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x11) ^ 0x11 
            for k in range(3): 
                s[j] = ((s[j]<<2)&0xc8) ^ ((s[j]>>5)&0x06) ^ ((s[j]>>2)&0x01) ^ ((s[j]<<5)&0x20) ^ ((s[j]<<1)&0x10)
                s[j] ^= (((s[j]>>3) | (s[j]>>2))&0x11) ^ 0x11 
                
    plaintext = [s[i] for i in range(16)]

    return plaintext


# to print some internal state
def print_state(s,tk):
    print("\nstate : " + "".join('{:02x}'.format(_) for _ in s))
    print("TK1   : " + "".join('{:02x}'.format(_) for _ in tk[0:16]))
    if len(tk)>16: print("TK2   : " + "".join('{:02x}'.format(_) for _ in tk[16:32]))
    if len(tk)>32: print("TK3   : " + "".join('{:02x}'.format(_) for _ in tk[32:48]))


# to generate test vectors and decryption 
def test_vectors(plaintext,key):
    ct = skinny_enc(plaintext,key)
    print("\nEncryption of " + "".join('{:02x}'.format(_) for _ in plaintext))
    print("with key      " + "".join('{:02x}'.format(_) for _ in key))
    print("gives         " + "".join('{:02x}'.format(_) for _ in ct))
    pt = skinny_dec(ct,key)
    print("Decryption:   " + "".join('{:02x}'.format(_) for _ in pt))


plaintext = [0xa3,0x99,0x4b,0x66,0xad,0x85,0xa3,0x45,0x9f,0x44,0xe9,0x2b,0x08,0xf5,0x50,0xcb]
key = [0xdf,0x88,0x95,0x48,0xcf,0xc7,0xea,0x52,0xd2,0x96,0x33,0x93,0x01,0x79,0x74,0x49,0xab,0x58,0x8a,0x34,0xa4,0x7f,0x1a,0xb2,0xdf,0xe9,0xc8,0x29,0x3f,0xbe,0xa9,0xa5,0xab,0x1a,0xfa,0xc2,0x61,0x10,0x12,0xcd,0x8c,0xef,0x95,0x26,0x18,0xc3,0xeb,0xe8]
test_vectors(plaintext,key)
