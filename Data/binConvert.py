#!/usr/bin/python
import struct
import math

f = open("data.bin","rb")

vref = 4.5
channel = 1
try:
	bytes = f.read(3)
	while bytes != "":
		#for byte in bytes:
#			print str(byte.encode("hex")),
#		print " -> ",
		signed = struct.unpack('>i', ('\x00' if bytes[0] < '\x80' else '\xff') + bytes)[0] 
	
		if channel != 8:
			print str(vref*(signed / ( pow(2,23) - 1.0))) + ",",
			channel += 1
		else:
			print vref*(signed / ( pow(2,23) - 1.0))
			channel = 1

		bytes = f.read(3)
		
finally:
	f.close()
