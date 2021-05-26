# for generation of Romulus-N test vectors
#from ROMULUS_N import *
#filename = "Python_AEAD_KAT_ROMULUS-N.txt"

# for generation of Romulus-M test vectors
#from ROMULUS_M import *
#filename = "Python_AEAD_KAT_ROMULUS-M.txt"

# for generation of Romulus-T test vectors
from ROMULUS_T import *
filename = "Python_AEAD_KAT_ROMULUS-T.txt"

MAX_MESSAGE_LENGTH = 32
MAX_ASSOCIATED_DATA_LENGTH = 32

CRYPTO_KEYBYTES = 16
CRYPTO_NPUBBYTES = 16
CRYPTO_ABYTES = 16

fic = open(filename, "w")

count = 0
for mlen in range(MAX_MESSAGE_LENGTH+1):
    for adlen in range(MAX_ASSOCIATED_DATA_LENGTH+1):
        count += 1

        key = [i%256 for i in range(CRYPTO_KEYBYTES)]
        nonce = [i%256 for i in range(CRYPTO_NPUBBYTES)]
        msg = [i%256 for i in range(mlen)]
        ad = [i%256 for i in range(adlen)]
        
        print("\n\n***************************************** \n Count = %i" %(count))
        
        fic.write("Count = {}".format(count) + "\n")
        fic.write("Key = " + "".join("{:02X}".format(_) for _ in key) + "\n")
        fic.write("Nonce = " + "".join("{:02X}".format(_) for _ in nonce) + "\n")
        fic.write("PT = " + "".join("{:02X}".format(_) for _ in msg) + "\n")
        fic.write("AD = " + "".join("{:02X}".format(_) for _ in ad) + "\n")

        print("\n-------- ENCRYPT --------\n")
        ct = crypto_aead_encrypt(msg, ad, nonce, key)
                
        fic.write("CT = " + "".join("{:02X}".format(_) for _ in ct) + "\n")
        fic.write("" + "\n")

        print("\n-------- DECRYPT --------\n")
        ret, msg2 = crypto_aead_decrypt(ct, ad, nonce, key)
        
        print("ret = %i" %(ret))
        print("msg =")
        print(msg)
        print("ct =")
        print(ct)
        print("msg2 =")
        print(msg2)
        
        if ret:
            fic.write("Error: crypto_aead_decrypt returned non-zero (ret={}).".format(ret) + "\n")
            exit(1)

        if msg != msg2:
            fic.write("Error: crypto_aead_decrypt did not recover the plaintext" + "\n")
            exit(1)

mlen = 243
adlen = 147     
count += 1
key = [i%256 for i in range(CRYPTO_KEYBYTES)]
nonce = [i%256 for i in range(CRYPTO_NPUBBYTES)]
msg = [i%256 for i in range(mlen)]
ad = [i%256 for i in range(adlen)]

print("\n\n***************************************** \n Count = %i" %(count))

fic.write("Count = {}".format(count) + "\n")
fic.write("Key = " + "".join("{:02X}".format(_) for _ in key) + "\n")
fic.write("Nonce = " + "".join("{:02X}".format(_) for _ in nonce) + "\n")
fic.write("PT = " + "".join("{:02X}".format(_) for _ in msg) + "\n")
fic.write("AD = " + "".join("{:02X}".format(_) for _ in ad) + "\n")

print("\n-------- ENCRYPT --------\n")
ct = crypto_aead_encrypt(msg, ad, nonce, key)
        
fic.write("CT = " + "".join("{:02X}".format(_) for _ in ct) + "\n")
fic.write("" + "\n")

print("\n-------- DECRYPT --------\n")
ret, msg2 = crypto_aead_decrypt(ct, ad, nonce, key)

print("ret = %i" %(ret))
print("msg =")
print(msg)
print("ct =")
print(ct)
print("msg2 =")
print(msg2)

if ret:
    fic.write("Error: crypto_aead_decrypt returned non-zero (ret={}).".format(ret) + "\n")
    exit(1)

if msg != msg2:
    fic.write("Error: crypto_aead_decrypt did not recover the plaintext" + "\n")
    exit(1)
            
fic.close()
#t = input("press key")
