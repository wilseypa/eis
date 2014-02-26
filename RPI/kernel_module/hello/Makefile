obj-m += ads_module.o

all:
	make ARCH=arm CROSS_COMPILE=${CCPREFIX} -C /home/xooxies/Public/eis/RPI/kernel_module/linux M=$(PWD) modules

user:
	gcc ioctl.c -o ioctl.out
#	gcc -g ads_proc.c -o proc.out -lm

clean:
	make ARCH=arm CROSS_COMPILE=${CCPREFIX} -C /home/xooxies/Public/eis/RPI/kernel_module/linux M=$(PWD) clean
