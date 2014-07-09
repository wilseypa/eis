#!/usr/bin/python
import csv
import math
import random
import time
import os
from optparse import OptionParser
from Debug import Debug
#Debugging interface
d = Debug()

class Model:
	elements = []
	def __init__(self,reader):
		for (resistance,capacitance) in reader:
			d.dprint("Model:Model()","Read R =" + resistance + " Ohm C = " + capacitance + " F") 
			self.elements.append( (resistance,capacitance) )
	def getElements(self):
		return self.elements

	def getElementImpedance(self,element,frequency):
		(r,c) = element
		z = complex(float(r),1.0 / ( float(c)*(frequency / (2*math.pi))))
		d.dprint("Model:Model:getElementImpedance()","Calculated " + str(z))	
		return z

def generateData(fifo,model):
	totalImpedance = 0.0
	current = 0.0
	for (r,c) in model.getElements():
		totalImpedance = totalImpedance + float(r)
	totalImpedance = totalImpedance / 2
	t = 0
	while True:
		t = time.time()
		while time.time() - t < 0.00025:
			continue
		samples = []
		try:
				fp = open('../Data/noise.csv')
				for line in fp:
					line = line.strip().split(",")
					if len(line) > 1:
						sample = float(line[0].strip())
						#sample = random.gauss(0.0,30.0)
						current = sample
						current = sample / totalImpedance
						samples.append(current)
						for (r,c) in model.getElements():
							sample = (current)*float(r)
							samples.append(sample)
						for sample in samples:
							fifo.write(str(float(sample)) + "\n")
					else:
						raise IOError
		except Exception as e:
				raise IOError

def begin():
	parser = OptionParser()
	parser.add_option("-f", "--file", dest="filename", help="Use model file", metavar="FILE")
	parser.add_option("-q", "--quiet", action="store_false", dest="verbose", default=True, help="Don't print status messages")

	(options, args) = parser.parse_args()

	# Get command line options
	if not options.filename:
		print "Please supply a model file with -f"
		exit(0)
	if options.verbose:
		d.setDebug()
		
	
	d.dprint("Model:begin()","Opening model file")
	try:
		# Open Model file and build Model object
		csvfile = open(options.filename,"rb")
		reader = csv.reader(csvfile,delimiter=',',quotechar='#')
		model = Model(reader);
		csvfile.close()	

		# Create named pipe
		os.mkfifo("npipe")
		fifo = open("npipe",'w')
		generateData(fifo,model)
		fifo.close()
		os.remove("npipe")		
	except Exception as e:
		print "Failure: ",
		print e
		os.remove("npipe") 	
		exit(0)
	return


if __name__=="__main__":
	begin()
