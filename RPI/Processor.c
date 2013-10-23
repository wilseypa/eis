#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <fftw3.h>
#include "Globals.h"
#include "ADS.h"
#include "Preprocessor.h"
#include "Processor.h"

GAsyncQueue *g_proc_inq = NULL;

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
		printf("Updating %s\n",current_channel->name);
		vector = current_channel->vector;
	
//		for (current_sample = 0; current_sample < MAX_SAMPLES; current_sample++) {
//		
//			printf("%.2e", vector[current_sample][0]);
//		}

		/* Crashes here ? */
//		printf("Trying to free the FFTW vector 0x%.8X\n",vector);
//		printf("Trying to free the NV 0x%.8X\n",current_channel);
		free(vector);
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

	debug_printf("%s","Exiting the processor thread");
	pthread_exit(NULL);
}
