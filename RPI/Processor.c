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
	
	current_channel = (NamedVector *)channels->data;
	
	while(current_channel != NULL) {
 
		printf("%s: ",current_channel->name);
	
		for (current_sample = 0; current_sample < MAX_SAMPLES; current_sample++) {
		
			printf("%.4f ", current_channel->vector[current_sample][0]);
		}

		/* Crashes here ? */
		fftw_free(current_channel->vector);
		free(current_channel);
		printf("\n");

		node = node->next;

		if (node == NULL) {
			debug_printf("%s","Unexpected EOL\n");
			break;
		}

		current_channel = (NamedVector *)node->data;
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
		nv_list = g_async_queue_pop(g_proc_inq);
	
		printChannels(nv_list);

		debug_printf("%s","Got a list to process!\n");

		

	}

	debug_printf("%s","Exiting the processor thread");
	pthread_exit(NULL);
}
