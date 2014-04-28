#!/usr/bin/python
import os
def begin():
	try:
		fifo = open("npipe","r")
		while True:
			sample = fifo.read(4)
			print sample
	except Exception as e:
		print "Failure: ",
		print e
		exit(0)

if __name__=="__main__":
	begin()
