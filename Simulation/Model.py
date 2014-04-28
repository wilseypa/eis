#!/usr/bin/python
from optparse import OptionParser

def begin():
	parser = OptionParser()
	parser.add_option("-f", "--file", dest="filename", help="Use model file", metavar="FILE")
	parser.add_option("-q", "--quiet", action="store_false", dest="verbose", default=True, help="Don't print status messages")

	(options, args) = parser.parse_args()

	if not options.filename:
		print "Please supply a model file with -f"
		exit(0) 

if __name__=="__main__":
	begin()
