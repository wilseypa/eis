class Debug:
	gDebug = False

	def dprint(self,ss,str):
		if self.gDebug == True:
			print ss + " " + str + "..."
	def getDebug(self):
		return self.gDebug
	def setDebug(self):
		self.gDebug = True
