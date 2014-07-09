#!/usr/bin/python
import os
import math
import scipy as sp
import numpy as np
import matplotlib.pyplot as plt

global estimate
global n_estimates
class Measurement:

	def __init__(self):
		self.input = []
		self.chan1 = []
		self.chan2 = []
		self.chan3 = []
		self.chan4 = []
	
def update_estimate(est, frq, N, sp5):
	global estimate
	global n_estimates
	if not estimate:
		estimate = est
		print "Created first estimate"
		n_estimates = 1
		return
	n_estimates = n_estimates + 1

	print "Averaging with " + str(n_estimates) + " estimates"
	# Simple time average as in Welch's method
	for i in range(0,len(estimate)):
		estimate[i] = estimate[i] + est[i]

	
	sp5.clear()
	hist = sp5.loglog(frq,np.abs(estimate) / N*n_estimates)
	sp5.set_title("Estimated Spectral Impedence ")	
	sp5.set_ylabel("Magnitude (|Ohm|)")
	sp5.set_xlabel("Frequency (Hz)")
	
	sp5.axis([min(frq), max(frq), min(np.abs(estimate))/N*n_estimates, (min(np.abs(estimate))/N*n_estimates)*10000.0])

	return
def print_stats(m):
	total = 0.0
	for i in m.input:
		total = total + i*i
	total = total / 1024.0
	rms = math.sqrt(total)
	print "Average input power: " + str(10*math.log(total)) + " dB"

def hanning_window(input):
	output = []
	c = 0
	for i in input:
		d = i*0.5*(1 - math.cos( (2*math.pi*c) / (len(input)-1)) )
		c = c + 1
		output.append(d)
	return output	


def print_fft(m, hlist, f1, slist):
	# Sampling information
	Fs = 2000.0
	N = len(m.input)
	k = sp.arange(N)
	T = N/Fs
	frq = k/T
	frq = frq[0:N/2]

	#Window and FFT the data
	I = sp.fft(hanning_window(m.input))
	C1 = sp.fft(hanning_window(m.chan1))
	C2 = sp.fft(hanning_window(m.chan2))
	C3 = sp.fft(hanning_window(m.chan3))
	C4 = sp.fft(hanning_window(m.chan4))

	# Compute Cross Spectrum
	Z1 = []
	Z2 = []
	Z3 = []
	Z4 = []

	for i in range(0,len(I)): 
		Z1.append(C1[i]*np.conjugate(I[i]) / I[i])
		Z2.append(C2[i]*np.conjugate(I[i]) / I[i])
		Z3.append(C3[i]*np.conjugate(I[i]) / I[i])
		Z4.append(C4[i]*np.conjugate(I[i]) / I[i])

	# We only need the first half
	Z1 = Z1[0:N/2]  
	Z2 = Z2[0:N/2]  
	Z3 = Z3[0:N/2]  
	Z4 = Z4[0:N/2]  


	# Update the subplots
	for s in slist:
		s.set_title("Estimated Spectral Impedence ")	
		s.set_ylabel("Magnitude (|Ohm|)")
		s.set_xlabel("Frequency (Hz)")
		if s != slist[4]:
			s.axis([min(frq), max(frq), min(np.abs(Z1))/N, (min(np.abs(Z1))/N)*1000.0])
	
	#print "Setting imp data"
	#print hlist[0]
	hlist[0].set_xdata(frq)
	hlist[0].set_ydata(np.abs(Z1) / N)
	
	hlist[1].set_xdata(frq)
	hlist[1].set_ydata(np.abs(Z2) / N)
	
	hlist[2].set_xdata(frq)
	hlist[2].set_ydata(np.abs(Z3) / N)
	
	hlist[3].set_xdata(frq)
	hlist[3].set_ydata(np.abs(Z4) / N)

	
	# Update the global estimate
	update_estimate(Z1, frq, N , slist[4])

	# Compute the size metric and print
	Z1mag = np.abs(Z1)
	Z2mag = np.abs(Z2)
	Z3mag = np.abs(Z3)
	Z4mag = np.abs(Z4)

	total1 = 0
	total2 = 0
	total3 = 0
	total4 = 0

	for i in range(0,len(Z1mag)):
		total1 = Z1mag[i]*Z1mag[i] + total1
		total2 = Z2mag[i]*Z2mag[i] + total2
		total3 = Z3mag[i]*Z3mag[i] + total3
		total4 = Z4mag[i]*Z4mag[i] + total4

	total1 = total1 / len(Z1mag)
	total2 = total2 / len(Z2mag)
	total3 = total3 / len(Z3mag)
	total4 = total4 / len(Z4mag)

	total1 = math.sqrt(total1)
	total2 = math.sqrt(total2)
	total3 = math.sqrt(total3)
	total4 = math.sqrt(total4)

	print "Chan 1 RMS |Z| " + str(total1)	 
	print "Chan 2 RMS |Z| " + str(total2)
	print "Chan 3 RMS |Z| " + str(total3)
	print "Chan 4 RMS |Z| " + str(total4)
	plt.draw()

def estimate_tf(m,hlist, f1, slist):
	print_stats(m)
	print_fft(m,hlist, f1, slist)
	del(m)
def get_data(fifo):
	temp = ""
	sample = 0.0	
	while True:
		rbyte = fifo.read(1)
		if rbyte != "\n":
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
			self.ctr = self.ctr + 1
			return
		elif self.ctr == 1:
			m.chan1.append(sample)
			self.ctr = self.ctr + 1
			return
		elif self.ctr == 2:
			m.chan2.append(sample)
			self.ctr = self.ctr + 1
			return
		elif self.ctr == 3:
			m.chan3.append(sample)
			self.ctr = self.ctr + 1
			return
		elif self.ctr == 4:
			m.chan4.append(sample)
			self.ctr = 0
			return

def begin():
	m = Measurement()
	sample_count = 0
	try:
		fifo = open("npipe","r")
		add_data = AddData()

		f1 = plt.figure(figsize=(15,8))
		
		[sp1, sp2, sp3, sp4, sp5] = [f1.add_subplot(231), f1.add_subplot(232), f1.add_subplot(233), f1.add_subplot(234), f1.add_subplot(235)]	
		h1, = sp1.plot([],[])
		h2, = sp2.plot([],[])
		h3, = sp3.plot([],[])
		h4, = sp4.plot([],[])
		plt.subplots_adjust(hspace = 0.3)
		plt.show(block=False)

		while True:
			if sample_count == 1024*5:
				estimate_tf(m,[h1,h2,h3,h4],f1,[sp1, sp2, sp3, sp4, sp5])
				sample_count = 0
				m = Measurement()
				add_data = AddData()
			sample = get_data(fifo)
			add_data(m,sample)	
			sample_count = sample_count + 1
	except KeyboardInterrupt:
		fifo.close()
		exit(0)
if __name__=="__main__":
	global n_estimates
	global estimate

	n_estimates = 0
	estimate = []
	begin()
