Jay Hamlin <redwoodranch@mac.com>
Date: February 15, 2013

---------------------------------------WHAT THE IRQTEST CODE DOES--------------------------------------------
This project started with my friend Larry announcing that he was building an A/D convertor which would
produce 1.4 million, 16 bit samples per second and was there any way I could capture the data to a file
for later analysis?  I had just received my rPi and was wondering if I could hook the A/D up to 16 gpio bits
with a 17th as /WR strobe.  Ignoring for the time being that the rPi doesn't have 16 contiguous gpios coming
out to a header, I set out to test the concept and see how good I could do.  It was quite an experience.

The first experiment was some simple test code which wrote a big file to a USB HDD, I discovered that the 
rPi can write 18MB/second to a file pretty much continuously. Larry's requirement ws 2.8MB/s, so far so good.

The next experiment used the wiringPi library ISR code to measure interrupt latency.
  https://projects.drogon.net/raspberry-pi/wiringpi/
Which turned out to be 25us at a minimum and 75us or more possible.  Look at the oscilloscope screenshot 
"user_isr_latency.png" in this folder for the results.  It is well known that Linux user level ISRs are 
slow, this wasn't going to work for me.

Check out the gpio hardware hacking here: http://elinux.org/RPi_Low-level_peripherals.

The next experiment was to make a kernel level ISR.  I was going to have to compile the kernel.  Uggh.
My host machine is a Macintosh which seemed like it should work and it did, sort of. You will find
instructions for compiling the kernel here: http://elinux.org/RPi_Kernel_Compilation.  The problem I
had was that the instructions aren't quite right and, on top of that, there are bugs which only happen
when cross compiling from Macintosh which made it quite a nightmare.  I was eventually able to build a
working kernel but, be warned, its not easy.  To make matters worse, I found when writing the ISR, that
all the help available on the web assumes you are either compiling for the machine you are running on or
,at best, cross compiling from another Linux machine.  

I ended up abandoning the Mac cross compile for a virtual machine running in VMWare fusion with Mint
Linux. http://www.linuxmint.com/ Both VMWare fusion and Mint Linux are great products, I recommend them.
Compiling for rPi under a Linux host has been far easier than on Macintosh, in my opinion, it is
worth the trouble of installing the VM.  Try it, you'll like it.

Oh, I should mention, since we are talking about writing a kernel driver that rPi uses kernel version 3.2.27
but nearly all the documentation and help on the web assumes you are running version 2.6.xx ... some of the
APIs have changed just to add to the fun.

Back to my project.  The code in this project implements a kernel level ISR tied to a rising edge interrupt
on gpio 23.  For testing, I am driving gpio 23 from a function generator and using an oscilloscope on gpio 23
and gpio 22 (where there is an LED).  On each rising edge of gpio 23, the ISR toggles the LED and writes a
16 bit incrementing value to a buffer which is shared with the user code.  Check out the oscilloscope
screenshot "kernel_isr1_latency.png", the latency is reduced by about 10x over the user level version.  Wow!

I ran the code today with an 11us interrupt rate (thats 90,909 interrupts per second!), it writes to the file
perfectly.  I didn't want to push it faster because I have seens interrupts out to 7 or 8us so, 11 is fast enough.
It won't quite fit Larry's needs but I'm going to start working on a hardware fifo so we don't have to service
every single word.

Enjoy!
Jay.

---------------------------------------NOTES FOR COMPILING --------------------------------------------------
Once you have compiled the kernel, put the irqtest folder in the linux kernel directory, on my machine it is
here: '/home/jay/rpi/linux-rpi-3.2.27/irqtest/'

You are going to need the CCPREFIX and KERNEL_SRC shell variables setup.  In Mint Linux, these can be saved in
~/.bashrc so they will always be available.  Mine look like this:
    export CCPREFIX=~/rpi/tools/arm-bcm2708/arm-bcm2708-linux-gnueabi/bin/arm-bcm2708-linux-gnueabi-
    export KERNEL_SRC=~/rpi/linux-rpi-3.2.27/

After that, just run the make file.  Build the ISR with 'make driver' and the user code with 'make user'.


---------------------------------------NOTES FOR USING ISR TEST CODE--------------------------------------
installing and running the isr test code on rPi:
   STEP 1:  ssh into the pi
         $>> ssh 192.168.xx.xx -l pi
   STEP 2: copy usrisr and irqtest.ko to the rPi
         $>> rsync -a -e ssh '~/rpi/linux-rpi-3.2.27/irqtest/userisr' pi@192.168.xx.xx:/home/pi/usrisr       
         $>> rsync -s -e ssh '~/rpi/linux-rpi-3.2.27/irqtest/irqtest.ko' pi@192.168.xx.xx:/home/pi/irqtest.ko

   STEP 3: if needed, mount the USB stick or HDD on the rPi using the instruction below.  
           The SD card may be used for testing but it's slow.
   STEP 4: mount the debug file system on the pi.
         $>> sudo mount -t debugfs none /sys/kernel/debug
   STEP 5: load the irqtest.ko kernel driver
         $>> sudo insmod ./irqtest.ko
   STEP 6: load the usrisr test code.  In this case I have passed "jay.txt" as the output file.
         $>> sudo ~/userisr /home/pi/jay.log
   STEP 7: debug messages are seen with the 'dmesg' command.


---------------------------------------GENERAL NOTES FOR USING THE RASPBERRY PI--------------------------------------
The pi's IP = 192.168.xx.xx
  user = pi
  pass = ------

useful commands:
    great help--> http://elinux.org/RPi_Tutorials
    great help--> http://www.computerworld.com/s/article/9030259/Linux_Command_Line_Cheat_Sheet?taxonomyId=122&pageNumber=1
    great help--> http://elinux.org/RPi_Low-level_peripherals
    shell--> ssh 192.168.xx.xx -l pi
    editor--> nano hello.c
    compiler--> gcc -o hello hello.c
    installing extra programs like rsync--> sudo apt-get install rsync
    shutdown--> sudo shutdown -h now

transferring files from Macintosh or Linux host:
    rsync -a -e ssh <path/filename> pi@192.168.xx.xx:/home/pi/<filename>
    Mac example= "rsync -a -e ssh /Users/jhamlin/Desktop/jayqueue.c pi@192.168.xx.xx:/home/pi/main.c"
    Linux example= "rsync -a -e ssh /home/jhamlin/rpi/main.c pi@192.168.xx.xx:/home/pi/main.c"

mounting flash drive on rPi:
    use 'dmesg' command to see devices.
    sudo mkdir /media/usbstick
    sudo mount -t vfat -o rw /dev/sda1 /media/usbstick/
    cd /media/usbstick

unmounting flash drive:
    sudo umount  /media/usbstick/
    cd /home

example copy file:
    sudo cp /home/pi/hello.c  /media/usbstick/hello.c

mounting hdd:
    sudo mount -t vfat -o uid=pi,gid=pi /dev/sda1 /media/usbhdd/
    cd /media/usbhdd

    sudo cp /home/pi/hello.c  /media/usbhdd/hello.c



