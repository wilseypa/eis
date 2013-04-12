def movingAverage(i,x,DC):
	if (i-30 < 0):
		sum = 0
		for i in range(0,i):
			sum += x(i) + DC
		return sum/i
	else:
		sum = 0
		for i in range(i-30,i):
			sum += x(i) + DC
		return sum/30
	return 0
			
def dynamicRangeRestore(x):
	DR = 1.5 # volts
	DC = 0; # No offset
	negCount = 0;
	posCount = 0;
	sample 
	for i in x:
		sample = movingAverage(i,x,DC)
		if (sample > DR):
			posCount++;
		if (sample < DR):
			negCount++;
		DC = DC  - posCount*DR + negCount*DR
