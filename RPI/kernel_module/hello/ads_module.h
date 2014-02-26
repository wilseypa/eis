#ifndef HELLO_H
#define HELLO_H

#include <linux/ioctl.h>

enum ADC_SPEED {
	S_250_SPS	= 0x96,
	S_500_SPS 	= 0x95,
	S_1_KSPS	= 0x94,
	S_2_KSPS 	= 0x93,
	S_4_KSPS	= 0x92,
	S_8_KSPS	= 0x91,
	S_16_KSPS	= 0x90
};

enum ACQ_CONFIG {
	NO_TEST = 0xC2,
	ACQ_TEST = 0xD5
};

enum CHAN_CONFIG {
	LOW = 0x00,
	NORMAL = 0x60,
	CHAN_TEST = 0x65
};

struct ADS_CONFIG {
	enum ADC_SPEED speed;
	enum ACQ_CONFIG config;
	enum CHAN_CONFIG channel;
};

#define MAJOR_NUM 2

#define IOCTL_SET_ADS_CONFIG _IOR(MAJOR_NUM, 0, struct ADS_CONFIG *)
#define IOCTL_GET_INT_COUNT _IOWR(MAJOR_NUM, 1, int)
#define IOCTL_SEND_DATA _IOR(MAJOR_NUM, 3, unsigned char *)
#define DEVICE_FILE_NAME "/dev/my_device"


#endif
