

def readFile(f = "eis/PhantomJan112012/EIS_simulations_new_phantom_500nF.txt"):
    cnt = 0
    F = file(f,'r')
    r = F.readline()
    names = r.split("  ")[1:-1]#there are beginning and end characters
    while F.readline()!='':
        cnt=cnt+1
    
    F = file(f,'r')

    ret = [[0.0]*cnt for i in range(len(names))]
    cnt=0
    while F.readline()!='':
        r = F.readline()
        temp = r.split("  ")
        if len(temp)>1:

            for i in xrange(len(names)):
                ret[i][cnt]=float(temp[i+1])
        cnt = cnt+1
    return ret
        
traces = readFile()
cnt = 0


Fout = file("eis/PhantomJan112012/EIS_simulations_new_phantom_500nFfixed.txt",'w')

for trace in traces:
    for z in trace:
        Fout.write(str(z)+'\t')
    Fout.write('\n')
    
print cnt


