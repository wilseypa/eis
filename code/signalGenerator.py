#!/usr/bin/python

# Generates a random number with a Gaussian distribution with a linearly increasing mean in time
# Author: Benjamin Jones
# Project: EIS - University of Cincinnati

# Data is pushed out to a named pipe 
import os, tempfile, signal, sys
import random, time

tmpdir = tempfile.mkdtemp()
filename = os.path.join(tmpdir,'sigen')
stop = False
global fifo
def signal_handler(signal, frame):
	closePipe()
	stop = True

# Sets up a named pipe
def initPipe():
	print "Creating named pipe " + filename
	try:
		os.mkfifo(filename,os.O_WRONLY)
	except OSError, e:
		print "Failed to create FIFO: %s" % e
	else:
		fifo = open(filename,'w',os.O_NONBLOCK)
		return

# Closes up the named pipe
def closePipe():
	fifo.close()
	os.remove(filename)
	os.rmdir(tmpdir)
	return

def pushData(i):
	print >> fifo, i
	return
	
def main():
	mu = 0.0
	sigma = 1.0
	epoch = time.time()
	diff = 0
	while stop == False:
		pushData(random.gauss(mu,sigma))
		diff = time.time() - epoch
		mu = 0.0001*diff	 
	return

if __name__ == "__main__":
	signal.signal(signal.SIGINT, signal_handler)
	initPipe()
	main()
	sys.exit(0)
