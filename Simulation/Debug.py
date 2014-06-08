#!/usr/bin/python
class Debug:
	def __init__(self):
		self.debug = False
	def setDebug(self):
		self.debug = True
	def dprint(self, msg, msg2):
		print msg + " " + msg2
