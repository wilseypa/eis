#!/usr/bin/python
import struct
import math

f = open("data.bin","rb")

vref = 2.5

try:
	bytes = f.read(3)
	while bytes != "":
		unsigned = struct.unpack('>I','\00' + bytes )[0]
		signed = unsigned if not (unsigned & 0x00800000) else unsigned - 0x00100000
		print (signed)*vref / pow(2,23)
		bytes = f.read(3)
finally:
	f.close()
