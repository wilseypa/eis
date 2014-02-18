obj-m=irqtest.o
PWD=$(shell pwd)
KDIR=~/rpi/linux-rpi-3.2.27/

all: driver user

driver: irqtest.c irqtest.h
	make -C $(KDIR) ARCH=arm CROSS_COMPILE=${CCPREFIX} M=$(PWD) modules

user: userMain.c irqtest.h
	$(CCPREFIX)gcc -o $(PWD)/userisr $(PWD)/userMain.c

clean:
	make -C $(KDIR) ARCH=arm CROSS_COMPILE=${CCPREFIX} M=$(PWD) clean


### 	$(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) modules
