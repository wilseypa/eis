def TFE(x,y):
    from pylab import fft,zeros,arange,cos,pi,conj,log,plot,show
    #we just need cross-spectral Pxy  
    ## Fill in defaults for arguments that aren't specified
    
    
    Fs = 2
    overlap = .5
    seg_size =2 ** int( log((len(x)/(1-overlap))**.5)*1/log(2) +.5)
    
    #hanning window is H = .5*(1 - cos(2*pi*(0:n-1)'/(n-1)))
    #lets compute this infunctions
    overlap = seg_size*.5
    
    #window = [.5*(1 - cos(2*pi*(n)/(seg_size-1))) for n in xrange(seg_size)]
    window = [0.54 - 0.46 * cos( (2*pi/seg_size) * k) for k in range(0,seg_size)]

    step = seg_size - overlap
    nfft = max(256, len(window))    
    Pxx = [complex(0,0)]*(64)
    Pxy = [complex(0,0)]*(64)
    
    
    avg = sum(x)/len(x)
    x = [xx-avg for xx in x]
    avg = sum(y)/len(y)
    y = [yy-avg for yy in y]


    
    
    
  ## Average the slices
    l=64
    offset = arange(0,len(x)-overlap,step)
    N = len(offset)
    for i in xrange(0,N):
        
        A=x[int(offset[i]):int(offset[i]+seg_size)]
        print seg_size
        A=[A[j]*window[j] for j in xrange(seg_size)]
        #A.extend([0.0]*(len(window)-nfft))
        
        A = fft(A,l)
        
        for j in xrange(seg_size):
            temp = A[j]*conj(A[j])
            Pxx[j]=Pxx[j].real+temp.real
        
        
        B=y[int(offset[i]):int(offset[i]+seg_size)]
        B=[B[j]*window[j] for j in xrange(seg_size)]
        #B.extend([0.0]*(len(window)-nfft))
        B = fft(B,l)
        
        #P = [A[i]*conj(B[i]) for i in xrange(len(A))]
        
        for j in range(seg_size):
            temp = A[j]*conj(B[j])
            Pxy[j]=complex(Pxy[j].real+ temp.real ,Pxy[j].imag-temp.imag)
        #print sum(Pxy)
        
    #plot(Pxy)
    #plot(Pxx)
    #show()
        #print Pxx
        #t = 0
        #for t in range(len(Pxx)):
        #    t= t+int(Pxx[t] == 0.0)
        #    
        #if t:print t,offset[i],offset[i]+step,i
    P = [Pxy[j]/Pxx[j] for j in xrange(len(Pxx))] ;
    P = P[0:nfft/2]
    #print nfft,Fs
    f = arange(0.0,2.0,float(Fs)/(nfft/4))
    return f,P
  
from pylab import sin,cos,e,arange,loglog,show,semilogy,semilogx,title,log,plot,figure,psd
x = arange(0,16,.01).tolist()
y = [(sin(xx)*cos(xx-.5))*e**(sin(xx)) for xx in x]

f,P = TFE(x,y)
plot(f,[p.real for p in P])

title("Real Part")
figure()
plot(f,[p.imag for p in P])
title("Imaginary Part")
show()
#shapes of csd and psd are correct, needs some shift and scaling factors though
  
