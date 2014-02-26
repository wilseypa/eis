#include "ads_module.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <fcntl.h>		/* open */
#include <unistd.h>		/* exit */
#include <sys/ioctl.h>		/* ioctl */
#include <math.h>
#include "mailbox.h"
#include "gpu_fft.h"

#define log2N 10 // 1024 = 2^10

#define N 1024
#define CHANNELS 8
#define SAMPLE_RATE 8000;
unsigned short appRunning = 1;
unsigned int estimates = 0;
double *global_estimate;

struct GPU_FFT_COMPLEX *base;
struct GPU_FFT *fft;
int mb;
static void handler(int singo)
{
	appRunning = 0;
}

void init_fft() {
	int ret;
	mb = mbox_open();
	ret = gpu_fft_prepare(mb, log2N, GPU_FFT_FWD, 1, &fft);
}

void do_fft(double *buffer) {
	unsigned int ctr = 0;

	// Copy the buffer into the fft data structure
	for (ctr = 0; ctr < N; ctr++) {
		fft->in[ctr].re = buffer[ctr];
		fft->in[ctr].im = 0.0;
	}

	// Push to the GPU
	gpu_fft_execute(fft);

	// Copy back the square magnitudes for welching
	for (ctr = 0; ctr < N; ctr++) {
		buffer[ctr] = sqrt( pow(fft->out[ctr].re,2) + pow(fft->out[ctr].im,2));
	}
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
	printf("\n");

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


void window(double *buffer) {
	unsigned int ctr = 0;
	double scale = 0.00614192112;
	// Hanning window -> Raised cosine of 0.5*(1 - cos( (2*pi*n) / (N - 1) )
	for (ctr = 0; ctr < N; ctr++)
	{
		buffer[ctr] *= 0.5*(1 - cos( scale * (ctr/N-1))); 
	}
}


void update_pwelch(double *buffer)
{
	unsigned int ctr = 0;
	// Hanning window the new segment
	window(buffer);

	// Do the FFT, we get square magnitudes in return
	do_fft(buffer);

	// If this is the first segment, just update the global estimate
	if (estimates == 0) {
		for (ctr = 0; ctr < N; ctr++) {
			global_estimate[ctr] += buffer[ctr];	
		}
		estimates++;
	}
	else
	{
		for (ctr = 0; ctr < N; ctr++) {
			// Unroll the last time average, generate a new time average per bin
			global_estimate[ctr] = global_estimate[ctr]*estimates + buffer[ctr];
			global_estimate[ctr] /= (float)(estimates+1);
		}
		estimates++;
	}
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
	update_pwelch(buffer);
	display_signal_power(buffer);
//	display_spectrum(buffer);
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

	init_fft();

	while (appRunning) {
		for (ctr = 0; ctr < N; ctr++) {
			get_data(fd,buffer + ctr*CHANNELS);
		}
		
		process(buffer);
		buffer = (double *)malloc(N*CHANNELS*sizeof(double));
	}

	gpu_fft_release(fft);	
	free(global_estimate);
	close(fd);
	return 0;
}
