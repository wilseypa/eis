#!/usr/bin/python

def signedFromHex16(s):
	v = int(s,16)
	if not 0 <= v < 16777216:
		raise ValueError, "bad hex val"
	if v >= 8388608:
		v = v - 16777216
	return v
def main():
	fp = open('noise','r')

	vref = 5.0;

	for line in fp:
		line = line.strip()
		data = line.split("\t")
		for i in range(0,len(data)):
			x = signedFromHex16(data[i])	
			x = float(x)
			p = x / 8388608.0
			x = p*vref
			print x,
		print ""


if __name__ == "__main__":
	main()

		
		
