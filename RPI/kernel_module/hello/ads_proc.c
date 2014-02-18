#include "ads_module.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>		/* open */
#include <unistd.h>		/* exit */
#include <sys/ioctl.h>		/* ioctl */
#include <math.h>

#define N 1024
#define CHANNELS 8
#define SAMPLE_RATE 8000;
unsigned short appRunning = 1;
double *global_estimate;

static void handler(int singo)
{
	appRunning = 0;
}

void detrend(double *buffer)
{
	unsigned int ctr = 0;
	double trend[CHANNELS];

	bzero(trend,CHANNELS*sizeof(float));

	for (ctr = 0; ctr < N; ctr++)
	{
		trend[0] += buffer[ctr*CHANNELS];
		trend[1] += buffer[ctr*CHANNELS + 1];
		trend[2] += buffer[ctr*CHANNELS + 2];
		trend[3] += buffer[ctr*CHANNELS + 3];
		trend[4] += buffer[ctr*CHANNELS + 4];
		trend[5] += buffer[ctr*CHANNELS + 5];
		trend[6] += buffer[ctr*CHANNELS + 6];
		trend[7] += buffer[ctr*CHANNELS + 7];
	}

	for (ctr = 0; ctr < CHANNELS; ctr++)
	{
		trend[ctr] /= N;
	}

	for (ctr = 0; ctr < N; ctr++)
	{
		buffer[ctr*CHANNELS] = buffer[ctr*CHANNELS] - trend[0];
		buffer[ctr*CHANNELS + 1] = buffer[ctr*CHANNELS + 1] - trend[1];
		buffer[ctr*CHANNELS + 2] = buffer[ctr*CHANNELS + 2] - trend[2];
		buffer[ctr*CHANNELS + 3] = buffer[ctr*CHANNELS + 3] - trend[3];
		buffer[ctr*CHANNELS + 4] = buffer[ctr*CHANNELS + 4] - trend[4];
		buffer[ctr*CHANNELS + 5] = buffer[ctr*CHANNELS + 5] - trend[5];
		buffer[ctr*CHANNELS + 6] = buffer[ctr*CHANNELS + 6] - trend[6];
		buffer[ctr*CHANNELS + 7] = buffer[ctr*CHANNELS + 7] - trend[7];
	}
}

void update_pwelch(double *buffer)
{
	
}

void display_signal_power(double *buffer)
{
	unsigned int ctr = 0;
	double power[CHANNELS];

	bzero(power,CHANNELS*sizeof(double));
	
	for (ctr = 0; ctr < N; ctr++)
	{
		power[0] += buffer[ctr*CHANNELS]*buffer[ctr*CHANNELS];
		power[1] += buffer[ctr*CHANNELS + 1]*buffer[ctr*CHANNELS + 1];
		power[2] += buffer[ctr*CHANNELS + 2]*buffer[ctr*CHANNELS + 2];
		power[3] += buffer[ctr*CHANNELS + 3]*buffer[ctr*CHANNELS + 3];
		power[4] += buffer[ctr*CHANNELS + 4]*buffer[ctr*CHANNELS + 4];
		power[5] += buffer[ctr*CHANNELS + 5]*buffer[ctr*CHANNELS + 5];
		power[6] += buffer[ctr*CHANNELS + 6]*buffer[ctr*CHANNELS + 6];
		power[7] += buffer[ctr*CHANNELS + 7]*buffer[ctr*CHANNELS + 7];
	}
	
	for (ctr = 0; ctr < CHANNELS; ctr++)
	{
		power[ctr] /= N;
		power[ctr] = sqrt(power[ctr]);
		printf("%f\t",power[ctr]);
	}
	printf("\n");

	free(buffer);
}

void process(double *buffer)
{
	detrend(buffer);
//	update_pwelch(buffer);
	display_signal_power(buffer);
}

void fill_buffer(unsigned char *buf, double *bigbuff)
{
	int status = 0;
	double scale = 5.36441803e-7;
	unsigned char *iterator = buf + 3;
	int i, temp;

	status = buf[0];
	status = (status << 8) | buf[1];
	status = (status << 8) | buf[2];

	for (i = 0; i < 8; i++) {
		temp = iterator[0];
		temp = (temp << 8) | iterator[1];
		temp = (temp << 8) | iterator[2];

		if (temp & 0x800000) {
			temp |= ~0xffffff;
		}

		bigbuff[i] = (double)temp * scale;
		iterator += 3;
	}

}

void get_data(int fd, double *buffer) {

	unsigned char buf[27];

	ioctl(fd, IOCTL_SEND_DATA, &buf);

	fill_buffer(buf,buffer);

}

int main()
{
	double *buffer = (double *)malloc(N*CHANNELS*sizeof(double));
	global_estimate = (double *)calloc(N*CHANNELS,sizeof(double));
	
	unsigned int ctr = 0;
	int fd;

	fd = open(DEVICE_FILE_NAME, 0);
	
	if (fd < 0) {
		printf("Can't open device\n");
		exit(-1);
	}

	if (signal(SIGINT, handler) == SIG_ERR) {
		return 0;
	}

	while (appRunning) {
		for (ctr = 0; ctr < N; ctr++) {
			get_data(fd,buffer + ctr*CHANNELS);
		}
		
		process(buffer);
		buffer = (double *)malloc(N*CHANNELS*sizeof(double));
	}

	free(global_estimate);
	close(fd);
	return 0;
}
