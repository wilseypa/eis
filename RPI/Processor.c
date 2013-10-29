#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <fftw3.h>
#include "Globals.h"
#include "ADS.h"
#include "Preprocessor.h"
#include "Processor.h"

GAsyncQueue *g_proc_inq = NULL;
fftw_plan p;

double cmplx_mag_square(double real, double imag)
{
	return (real*real + imag*imag); 

}

double getAveragePower(fftw_complex *vector)
{
	unsigned int ctr = 0;
	double pwr = 0.0;
	for (ctr = 0; ctr < MAX_SAMPLES/2; ctr++)
	{
		pwr += 2*cmplx_mag_square(vector[ctr][0], vector[ctr][1]);
	}

	return pwr / (MAX_SAMPLES*250);
}

void removeOffset(fftw_complex *vector) {
	unsigned int ctr = 0;
	double dc = 0.0;

	for (ctr = 0; ctr < MAX_SAMPLES; ctr++)
	{
		dc += vector[ctr][0];

	}

	dc /= MAX_SAMPLES;

	printf("\n DC Offset: %.3fmV\n",dc*1000);

	for (ctr = 0; ctr < MAX_SAMPLES; ctr++)
	{
		vector[ctr][0] -= dc;
	}
}

void printChannels(GSList *channels)
{
	NamedVector * current_channel;
	GSList *node = channels;
	unsigned int ctr = 0;
	unsigned int current_sample = 0;
	fftw_complex * vector;	



	while(node != NULL) {
		current_channel = (NamedVector *)node->data;
		if (current_channel == NULL) {
			debug_printf("%s","Null channel ?\n");
			break;
		}
		printf("Channel %s\t",current_channel->name);
		vector = current_channel->vector;
		
		removeOffset(vector);

		p = fftw_plan_dft_1d(MAX_SAMPLES,vector,vector, FFTW_FORWARD, FFTW_ESTIMATE);
		fftw_execute(p);
		fftw_destroy_plan(p); 

		printf("Avg Power Level: %.3f mW / Hz\n",getAveragePower(vector)*1000);
		/* Crashes here ? */
//		printf("Trying to free the FFTW vector 0x%.8X\n",vector);
//		printf("Trying to free the NV 0x%.8X\n",current_channel);
		fftw_free(vector);
		free(current_channel);

		node = node->next;
	}

	g_slist_free(channels);

}

proc_thread Processor (void *n)
{
	GSList *nv_list = NULL;
	debug_printf("%s","Starting the main processor\n");

	if (g_proc_inq == NULL) {
		g_proc_inq = g_async_queue_new();

		if (g_proc_inq == NULL) {
			debug_printf("%s","ERROR could not create queue for processor\n");
			pthread_exit(NULL);
		}
	}


	/*TODO: Create main processing loop */
	while (!gAppExiting) {

		/* Wait for incoming list to process */
		nv_list = g_async_queue_try_pop(g_proc_inq);
		if (nv_list == NULL) {
			usleep(1);
			continue;
		}
	
		printChannels(nv_list);

		debug_printf("%s","Got a list to process!\n");

		

	}

	while (g_preproc_running) sleep(1);

	nv_list = g_async_queue_try_pop(g_proc_inq);
	while (nv_list != NULL) {
			printChannels(nv_list);
			nv_list = g_async_queue_try_pop(g_proc_inq);
	}

	debug_printf("%s","Exiting the processor thread");
	pthread_exit(NULL);
}
