import Crypto
from Crypto.PublicKey import RSA
from Crypto import Random
import ast

key_pair={}

for i in range(10):
    help_value = Random.new().read
    key = RSA.generate(1024,help_value)
    temp = key.publickey().exportKey(format='PEM', passphrase=None, pkcs=1)
    #temp = RSA.importKey(temp, passphrase=None)
    #print temp
    #temp=temp[40:100]
    key_pair[temp]=key

f=open("keys.txt",'w')
for x in key_pair:
    f.write(x+":"+str(key_pair[x])+":")
f.close()

