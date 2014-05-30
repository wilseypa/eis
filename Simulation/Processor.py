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
	N = 1024
	T = 1.0 / 4000.0
	xf = np.linspace(0.0, 1.0/(2.0*T), N/2)
	I = sp.fft(m.input)
	C1 = sp.fft(m.chan1)
	C2 = sp.fft(m.chan2)
	C3  = sp.fft(m.chan3)
	C4 = sp.fft(m.chan4)

	h1.set_xdata(xf)
	h1.set_ydata(np.abs(I[0:N/2]))
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
			if sample_count == 1024:
				estimate_tf(m,h1)
				sample_count = 0
				m = Measurement()
			sample = get_data(fifo)
			add_data(m,sample)	
			sample_count = sample_count + 1
	except Exception as e:
		print "Failure: ",
		print e
		exit(0)

if __name__=="__main__":
	begin()
