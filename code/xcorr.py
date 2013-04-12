import pylab
from numpy import fft,log,conj,array,cos,pi
from autoRegressive import  ARLeastSquares as ar
from autoRegressive import  testAR



def xcorr(x,y):
    '''
        this function computes the cross correlation of x and y via the fft based(O(nlog(n))) convolution of
        the complex conjugate of x with y  
    ''' 
    l = 2**int(log(  max(len(x),len(y)) )/log(2)+1.5)
    #print l
    conRevY = conj(y[::-1])
    Fx = fft.fft(x,l)
    Fy = fft.fft(conRevY,l)
    return fft.ifft(Fx*Fy)
    
def readFile(f = file("eis/PhantomJan112012/EIS_simulations_new_phantom_500nFfixed.txt",'r')):
    dat = []
    
    temp = f.readline()
    while temp != "":
        tSplit = temp.split('\t')[:-1]
        dat.append( [float(t) for t in tSplit] )
        temp = f.readline()
    return dat



dat = readFile()


#lets just look at 10000 samples
import time


steps = (406052)/8
t=5



#pylab.plot(ar([5*dat[2][i] for i in range(len(dat[1]) ) ]))
#pylab.show()


for i in range(1,5):
    tim = time.time()
    sRange = [(i)*steps,(i+1)*steps]
    
    seg_size = (i+1)*steps-(i)*steps
    #window = array([0.54 - 0.46 * cos( (2*pi/seg_size) * k) for k in range(0,seg_size)])
    #t = dat[0][sRange[0]:sRange[1]]
    
    vin = array(dat[1][sRange[0]:sRange[1]])#*window
    vin2 = array(dat[2][sRange[0]:sRange[1]])#*window
    
    w1 = xcorr(array( dat[3][sRange[0]:sRange[1]]),vin2)#*window
    w2 = xcorr(array(dat[4][sRange[0]:sRange[1]]),vin2)#*window
    w3 = xcorr(array( dat[5][sRange[0]:sRange[1]]),vin2)#*window
    w4 = xcorr(array(dat[6][sRange[0]:sRange[1]]),vin2)#*window
    w5 = xcorr(array( dat[7][sRange[0]:sRange[1]]),vin2)#*window
    
    l=64
    
    print "Round "+str(i)
    pylab.subplot(221)
    #pylab.semilogx(log(fft.fft(xcorr(vin,vin2),l)))
    pylab.plot(ar(w1,4),label="Set "+str(i*steps) +"-"+str((i+1)*steps))
    pylab.subplot(222)
    #pylab.semilogx(log(fft.fft(xcorr(vin,w1),l)))
    pylab.plot(ar(w2,4),label="Set "+str(i*steps) +"-"+str((i+1)*steps))
    
    pylab.subplot(223)
    pylab.plot(ar(w3,4),label="Set "+str(i*steps) +"-"+str((i+1)*steps))
    #pylab.semilogx(log(fft.fft(xcorr(vin,w2),l)))
    pylab.subplot(224)
    pylab.plot(ar(w4,4),label="Set "+str(i*steps) +"-"+str((i+1)*steps))
    #w3 = w3 - w4
    #pylab.semilogx(log(fft.fft(xcorr(vin,w3),l)))
    #w4 = w4 - w5
    #pylab.subplot(235)
    #pylab.semilogx(log(fft.fft(xcorr(vin2,w4),l)))
    #pylab.subplot(236)
    #pylab.semilogx(log(fft.fft(xcorr(vin,w5),l)))
    print time.time()-tim
pylab.show()
pylab.legend()












     
