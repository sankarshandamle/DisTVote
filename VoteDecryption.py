# takes as input your manager our encrypted vote

import os, sys
import Crypto
from Crypto.PublicKey import RSA
from Crypto import Random
import ast

f=open("keys.txt","rb")
arr=f.read().split(":")
key=arr[2*(int(sys.argv[1]))+1]
f.close()
#converting to RSA key format
key=RSA.importKey(key)
decrypted = key.decrypt(ast.literal_eval(sys.argv[2]))
print decrypted
