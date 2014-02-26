/*
 *  ioctl.c - the process to use ioctl's to control the kernel module
 *
 *  Until now we could have used cat for input and output.  But now
 *  we need to do ioctl's, which require writing our own process.
 */

/* 
 * device specifics, such as ioctl numbers and the
 * major device file. 
 */
#include "ads_module.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>		/* open */
#include <unistd.h>		/* exit */
#include <sys/ioctl.h>		/* ioctl */

/* 
 * Functions for the ioctl calls 
 */

ioctl_get_int_count(int fd)
{
	printf("Current int count: %d\n",ioctl(fd, IOCTL_GET_INT_COUNT, NULL));
}

ioctl_set_ads_config(int fd, int value)
{
	struct ADS_CONFIG config;

	switch (value) {

	case 250:
		config.speed = S_250_SPS;
		break;
	case 500:
		config.speed = S_500_SPS;
		break;
	case 1000:
		config.speed = S_1_KSPS;
		break;
	case 2000:
		config.speed = S_2_KSPS;
		break;
	case 4000:
		config.speed = S_4_KSPS;
		break;
	case 8000:
		config.speed = S_8_KSPS;
		break;
	case 16000:
		config.speed = S_16_KSPS;
		break;

	default:
		config.speed = S_250_SPS;
		break;
	}
	printf("Using %.2X for speed parameter\n",config.speed);
	config.config = NO_TEST;
//	config.channel = NORMAL;
	config.channel = LOW;
 
	ioctl(fd, IOCTL_SET_ADS_CONFIG,&config);
}

void print_data(unsigned char buf[27])
{
	int status = 0;
	double channels[8];
	double scale = 5.36441803e-7;
	unsigned char *iterator = buf + 3;
	int i, temp;

	status = buf[0];
	status = (status << 8) | buf[1];
	status = (status << 8) | buf[2];

//	printf("Status: %X \n", status);

	for (i = 0; i < 8; i++) {
		temp = iterator[0];
		temp = (temp << 8) | iterator[1];
		temp = (temp << 8) | iterator[2];

		if (temp & 0x800000) {
			temp |= ~0xffffff;
		}

		channels[i] = (double)temp * scale;
		printf("%.10e\t", channels[i]);
		iterator += 3;
	}
	printf("\n");
}

ioctl_get_data(int fd)
{
	unsigned char buf[27];

	int sample;

	while (1) {
		ioctl(fd, IOCTL_SEND_DATA, &buf);
		
		print_data(buf);
	}
}

/* 
 * Main - Call the ioctl functions 
 */
int main(int argc, char **argv)
{
	int fd;
	int i;
	char *command;
	int value = 0;
	
	if (argc < 2 || argc > 3) {
		printf("Usage: ioctl <COMMAND> <VALUE>\n");
		printf("Commands: config, interrupt_count, get_data\n");
		exit(-1);
	}

	if (argc == 3) {

		value = atoi(argv[2]);
	}
	command = argv[1];

	fd = open(DEVICE_FILE_NAME, 0);
	if (fd < 0) {
		printf("Can't open device file: %s\n", DEVICE_FILE_NAME);
		exit(-1);
	}

	if (!strcmp(command, "config") && value > 0) {
		ioctl_set_ads_config(fd,value);
	}
	else if(!strcmp(command, "interrupt_count")) {
		ioctl_get_int_count(fd);
	}
	else if(!strcmp(command, "get_data")) {
		ioctl_get_data(fd);
	}

	close(fd);
	return 0;
}
