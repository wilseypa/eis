#!/usr/bin/python
import os
import math
import scipy as sp
import numpy as np
import matplotlib.pyplot as plt

class Measurement:
	input = []
	chan1 = []
	chan2 = []
	chan3 = []
	chan4 = []
	
def print_stats(m):
	total = 0.0
	for i in m.input:
		total = total + i*i
	total = total / 1024.0
	print "Average input power: " + str(10*math.log(total)) + " dB"

def print_fft(m, h1):
	Fs = 4000.0
	N = len(m.input)
	k = sp.arange(N)
	T = N/Fs
	frq = k/T
	frq = frq[0:N/2]
	I = sp.fft(m.input)[0:N/2]
	C1 = sp.fft(m.chan1)
	C2 = sp.fft(m.chan2)
	C3  = sp.fft(m.chan3)
	C4 = sp.fft(m.chan4)
	plt.title("Input Spectrum ")	
	plt.ylabel("Amplitude (V)")
	plt.xlabel("Frequency (Hz)")
	plt.axis([0, 1024, min(m.input), max(m.input)])
#	plt.axis([min(frq), max(frq), min(np.abs(I))/N, (max(np.abs(I))/N)*2.0])
	h1.set_xdata(range(0,N))
	h1.set_ydata(m.input)

#	h1.set_xdata(frq)
#	h1.set_ydata(np.abs(I) / N)
	plt.draw()

def estimate_tf(m,h1):
	print_stats(m)
	print_fft(m,h1)
	del(m)
def get_data(fifo):
	temp = ""
	sample = 0.0	
	while True:
		rbyte = fifo.read(1)
		if rbyte != ":":
			temp = temp + rbyte
			continue
		else:
			sample = float(temp)
			break
	return sample

class AddData: 
	def __init__(self):
		self.ctr = 0
	def __call__(self,m,sample):
		if self.ctr == 0:
			m.input.append(sample)
		elif self.ctr == 1:
			m.chan1.append(sample)
		elif self.ctr == 2:
			m.chan2.append(sample)
		elif self.ctr == 3:
			m.chan3.append(sample)
		elif self.ctr == 4:
			m.chan4.append(sample)
			self.ctr = 0
			return
		self.ctr = self.ctr + 1

def begin():
	m = Measurement()
	sample_count = 0
	try:
		fifo = open("npipe","r")
		add_data = AddData()	
		h1, = plt.plot([],[])
		plt.show(block=False)
		while True:
			if sample_count == 1024*5:
				estimate_tf(m,h1)
				del(m)
				sample_count = 0
				m = Measurement()
			sample = get_data(fifo)
			add_data(m,sample)	
			sample_count = sample_count + 1
	except Exception as e:
		print "Failure: ",
		print e
		fifo.close()
		exit(0)
	except KeyboardInterrupt:
		fifo.close()
		exit(0)
if __name__=="__main__":
	begin()
