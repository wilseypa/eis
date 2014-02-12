#ifndef HELLO_H
#define HELLO_H

#include <linux/ioctl.h>

#define MAJOR_NUM 2

#define IOCTL_SET_MSG _IOR(MAJOR_NUM, 0, char *)
#define IOCTL_GET_MSG _IOR(MAJOR_NUM, 1, char *)
#define IOCTL_GET_NTH_BYTE _IOWR(MAJOR_NUM, 2, int)
#define IOCTL_TOGGLE_LED _IOR(MAJOR_NUM,3, char *)
#define DEVICE_FILE_NAME "/dev/my_device"


#endif
