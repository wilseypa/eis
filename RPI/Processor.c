#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <fftw3.h>
#include "Globals.h"
#include "Processor.h"

GAsyncQyeye *g_proc_inq = NULL;

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

	/* Wait for incoming list to process */
	nv_list = g_async_queue_pop(g_proc_inq);
	
	debug_printf("%s","Got a list to process!\n");

	

	debug_printf("%s","Exiting the processor thread");
	pthread_exit(NULL);
}
