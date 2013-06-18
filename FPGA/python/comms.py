#!/usr/bin/python

import serial
import time

ser = serial.Serial('/dev/ttyUSB0',115200,8,serial.PARITY_NONE,serial.STOPBITS_TWO)
print ser.portstr

reads = 1;


while 1:
	try:
		ser.write("Hello!");
		x = ser.read(6);
		print "RX'd: " + x
		reads = reads + 1
		if (x != "Hello!"):
			print "Failure!"
			raise KeyboardInterrupt
	except KeyboardInterrupt:
		ser.close()
		print str(reads) + " reads"
		break
