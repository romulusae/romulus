from ROMULUS_HASH import *

MAX_MESSAGE_LENGTH = 128

filename = "Python_HASH_KAT.txt"
fic = open(filename, "w")

count = 0
for mlen in range(MAX_MESSAGE_LENGTH+1):
    count += 1
    msg = [i%256 for i in range(mlen)]
    
    print("\n\n***************************************** \n Count = %i" %(count))
    
    fic.write("Count = {}".format(count) + "\n")
    fic.write("Msg = " + "".join("{:02X}".format(_) for _ in msg) + "\n")

    hash_value = crypto_hash(msg)
            
    fic.write("MD = " + "".join("{:02X}".format(_) for _ in hash_value) + "\n")
    fic.write("" + "\n")
        
fic.close()
#t = input("press key")
