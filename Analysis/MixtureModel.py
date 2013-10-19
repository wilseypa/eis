'''
Created on Aug 3, 2009

@author: lee
'''

#this function will read the included pickle file and run on one of the curves
#what running the 


if __name__ == '__main__':
      workFile = '/home/lee/Desktop/work/xanthostat/BRshortv100.pickle'#change this
      from numpy import  *
      from numpy.ma.core import zeros
      from scipy import optimize
      from math import *
      import itertools,pylab
      import random
      
      def loadPickle():
            import pickle
            print 'loading data...'
            comment, paths, x, usbLabels, plateLabels, usbData, plateData = pickle.load(open(workFile))
            print 'done'
            return [usbLabels, plateLabels, usbData, plateData,x]
            
      
      
      specRange = 1040
      [usbLabels, plateLabels, usbData, plateData,x] = loadPickle()
      y = usbData
      x = array(range(0,specRange))
      sqrtPI = sqrt(2.*pi)
      
      def normcurv(x,mu,sigma,scaler):
            return scaler * (exp( -(x-mu)**2./sigma**2. )/(sigma*sqrtPI))
      
      numOfComponents = 4
      
      
      def mixtureFNC(x,v):
            sum = 0.0
            i=0
            while i < numOfComponents:
                  sum+=normcurv(x,v[i*3],v[i*3+1],v[i*3+2])
                  i+=1
            return sum
      ## Error function
      
      
      def e(v,x,y):
            #sse = 0.0
            sse =range(0,specRange)
            i=0
            while i < specRange:
                  sse[i]= y[i]*(y[i] - mixtureFNC(i,v))**2
                  i+=1
            return sse
      
      
      def printALL(specRange,numOfComponents,y,v):
      # make some graphs of the components
            error = range(0,specRange)
            estimate = range(0,specRange)
            for i in range(0,specRange):
                  estimate[i] = mixtureFNC(i, v)
                  error[i] = (estimate[i] - y[i])**2
                  
            models = zeros((numOfComponents,specRange))
            
            for i in range(0,numOfComponents):
                  for j in range(0,specRange):
                        models[i][j] = normcurv(x[j],v[i*3],v[i*3+1],v[i*3+2])
                  pylab.plot(x,models[i], linestyle='--')
                  
            print v
            #pylab.plot(x,estimate)
            

###########Training###############################      
#training the model, use some bilirubin curves to teach this
      step = len(x)/(numOfComponents+1)
      v0=[]
      means = [i*100 for i in range(numOfComponents)]#[361,400,500,200,100]# this is a vector of where you suspect the principle wavelength peaks will be

      for i in range(0,numOfComponents):
            v0.append(means[i])#v0.append((i+1)*step)
            v0.append(40) # variance
            v0.append(100) #num of photons
      v0 = array(v0)
      

#this loop isnt looping over stuff currently, it is just doing one curve, which is what you want
      numplots = 2
      for i in range(numplots*numplots):
            ## Fitting
            m = random.randint(0,len(y))
            y [m]= y[m]-(min(y[m])-max(y[m])) # discard the noise floor
            [v, K] = optimize.leastsq(e, v0, args=(x,y[m]),maxfev=1000)
            printALL(specRange,numOfComponents,y[m],v)
            b=[]
            for j in range(0,specRange):
                  b.append(mixtureFNC(j, v))
            pylab.subplot(numplots,numplots,1+i)
            pylab.plot(x,b)
            pylab.plot(x,y[m])
      pylab.show()

##########generating the curves
#this and the vector (v) from above are what you need to make a curve
#v is a flat vector,w/ format of every three items defines a normal component ie wavelength
#the order is mu, sigma, magnitude; monkeying with the magnitude corresponds to different 
#amounts of components. the mu and sigma computed above, should not be messed with.

## this example pushes all the amounts of component up a little
## generally one or two components will model the noise floor
for b in range(0,numOfComponents):
      v[b*3+2]=v[b*3+2]+100

# simply plot using the composite mixture function
for i in range(0,specRange):
      b.append(mixtureFNC(i, v))
pylab.plot(x,b)


