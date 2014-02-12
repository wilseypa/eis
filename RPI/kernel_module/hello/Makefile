obj-m += hello.o

all:
	make ARCH=arm CROSS_COMPILE=${CCPREFIX} -C /home/xooxies/Public/eis/RPI/kernel_module/linux M=$(PWD) modules
