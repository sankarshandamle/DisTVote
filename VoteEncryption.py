# takes as input your manager, your hash and your vote to find the key pair to encrypt
# First Manager => 0 and so on ..
import os, sys
import Crypto
from Crypto.PublicKey import RSA
from Crypto import Random
import ast

f=open("keys.txt","rb")
arr=f.read().split(":")
key=arr[2*(int(sys.argv[1]))]
f.close()
#converting to public key format
pub_key=RSA.importKey(key)
encrypted = pub_key.encrypt(sys.argv[3], 32)
f=open("encryptions.txt","a+")
f.write(sys.argv[1]+","+sys.argv[2]+",")
f.write(str(encrypted))
f.write("\n")

'''
#decrypted code below

decrypted = key.decrypt(ast.literal_eval(str(encrypted)))
print 'decrypted', decrypted
'''
