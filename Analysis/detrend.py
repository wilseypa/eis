import sys
datfile = "run1.bin"
if sys.platform=="win32":datfile = "C:\\Temp\\carrahle\\run1.bin"


def readFile(f,start=0,stop=300,channels = 8, sfreq = 100000,detrend_Kernel_Length=10):   
    import struct
    f = open(f,"rb")

    if stop - start <= detrend_Kernel_Length*2:
        stop = start + detrend_Kernel_Length*2
    data = [[0.0]*sfreq*(stop-start) for i in range(8)]
    try:                     
        byte = f.read(4)
        
        #throw away until start time
        seek = 0
        while not byte=="" and seek < start*sfreq:
            for c in range(channels):
                byte = f.read(4)
            seek = seek +1
        #actual reading
        while not byte=="" and seek < stop*sfreq:
            for c in range(channels):
                data[c][seek -(start*sfreq)] = struct.unpack('>f',byte)[0]
                #print struct.unpack('>f',byte)
                #print c,seek -(start*sfreq),data[c][seek -(start*sfreq)]
                byte = f.read(4)
            seek = seek +1

    finally:
        f.close()
    return data



def detrend(data,detrend_Kernel_Length = 10,sampling_Frequency = 100000,channels = 8):
    from pylab import fft, ifft, sin , cos,log,plot,show,conj,legend
    import random

    n=len(data[0])
    detrend_fft_Length = (2**((log(detrend_Kernel_Length * sampling_Frequency)/log(2)))) 

    ma = [1.0]*sampling_Frequency
    ma.extend([0.0]*(detrend_fft_Length - sampling_Frequency))
    mafft = fft(ma)
    trend = [0.0]*n
    
    for nch in range(channels):
        count = 0
        while count + detrend_fft_Length <= len(data[nch]):
            temp = data[nch][count:count+int(detrend_fft_Length)]
            y = fft(temp)
            z = ifft( conj(mafft)*y)
            for cc in xrange(count,count+(int(detrend_fft_Length)-sampling_Frequency)):
                trend[cc] = z[cc-count].real / sampling_Frequency 
            count = count+(int(detrend_fft_Length)-sampling_Frequency)     
        for cc in xrange(len(trend)):
            data[nch][cc] = data[nch][cc] - trend[cc]


#1,2,5,6,8,4 ... 012345
def generateBipolar(data):
    ch = [1,2,5,6,8,4]
    bipolar  = [[0.0]*len(data[0]) for i in ch]
    #not this may be bad access methods
    for i in xrange(len(data)):
        bipolar[0][i] = data[1][i] - data[0][i]
        bipolar[1][i] = data[2][i] - data[1][i]
        
        bipolar[2][i] = data[4][i] - data[5][i]
        bipolar[3][i] = data[5][i] - data[6][i]
        
        bipolar[4][i] = data[7][i]
        bipolar[5][i] = data[3][i]
    for i in range(len(bipolar)):
        print str(ch[i])+" " + str(bipolar[i][1000:1020])+ str(sum(bipolar[i]))
        #print str(ch[i])+" " + str(sum(bipolar[i])/2.0)
    return bipolar



def testDataRead():
    channels = [0,1,2,3,4,5,6,7]

    import pylab
    for i in range(50):
        print i
        data = readFile(datfile,start=1*i,stop=1*(i+1))
        for c in channels:
            pylab.subplot(4,2,c+1)
            px,freq = pylab.psd(data[c])
    pylab.show()



    

def testDataVariance():

    class varState:
       n = 0.0                
       mean = 0.0
       M2 = 0.0
       var = 0.0
    def online_variance(x,S):
       S.n = S.n + 1.0
       delta = x - S.mean
       S.mean = S.mean + delta/S.n
       if S.n > 1:
           S.M2 = S.M2 + delta*(x - S.mean)
       S.var = S.M2/(S.n)
       return S


    channels = [0,1,2,3,4,5,6,7]
    varChannels = [[varState() for j in range(129)] for i in channels]



    import pylab
    pylab.figure()
    for i in range(50):
        print i
        data = readFile(datfile,start=1*i,stop=1*(i+1))
        for c in channels:
            pylab.subplot(4,2,c+1)
            px,freq = pylab.psd(data[c])
            varChannels[c] = [online_variance(px[i],varChannels[c][i] ) for i in range(129)]
            #fftX = pylab.fft(data[c])
            #filter(lambda x: (x>100 and x<10000),fftX)
            #print min(fftX),max(fftX)
            #pylab.semilogx(fftX)

    pylab.show()
    pylab.figure()
    for v in varChannels:
        print sum([v[c].var for i in range(129)])/129.0
        pylab.plot([v[c].var for i in range(129)])
    pylab.show()

def testDetrend():
    import pylab
    #something random to test with
    data = [[ (sin(random.gauss(0,1)*.01+float(i)/(n/51.0)))*(cos(random.gauss(0,1)*.01+float(i)/(n/31.0))) for i in range(n)] ]
    plot(data,'--',label="Original Data")
    detrend(data,channels = 1)
    plot(data,label="Detrended Data")


def testReadAndDetrend(detrend_length=10,s_freq=100000):
    import copy
    channels = [0,1,2,3,4,5,6,7]
    data = readFile(datfile,start=0,stop=1,sfreq = s_freq)
    detrendData = copy.deepcopy(data)
    detrend(detrendData,detrend_Kernel_Length = detrend_length,sampling_Frequency = s_freq)
    #import pylab
    #for c in channels:
    #    pylab.subplot(4,2,c+1)
    #    pylab.plot(data[c],'--')
    #    pylab.plot(detrendData[c])
        
    #pylab.show()
    
    
def testReadAndDetrendAndBP(detrend_length=10,s_freq=100000):
    import copy,pylab
    channels = [0,1,2,3,4,5,6,7]
    data = readFile(datfile,start=0,stop=1,sfreq = s_freq)
    #detrendData = copy.deepcopy(data)
    
    bipolar = generateBipolar(data)
    pylab.plot(bipolar)
    detrend(data,detrend_Kernel_Length = detrend_length,sampling_Frequency = s_freq)
    
    bipolar = generateBipolar(data)
    pylab.psd(bipolar[0])
    pylab.psd(bipolar[1])
    pylab.psd(bipolar[2])
    pylab.psd(bipolar[3])
    pylab.show()
    
#testReadAndDetrend(10,100000)
testReadAndDetrendAndBP(1,100000)
    
