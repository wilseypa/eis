#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <fftw3.h>
#include <math.h>
#include <string.h>
#include "Globals.h"
#include "Allocator.h"
#include "Preprocessor.h"
#include "Processor.h"


GAsyncQueue *g_preproc_inq = NULL;
boolean g_preproc_running = false;

fftw_complex * CreateVector()
{
	fftw_complex *vector = (fftw_complex *)malloc(sizeof(fftw_complex)*MAX_SAMPLES);
//	printf("Mallocing FFTW vector 0x%.8X\n",vector);

	bzero(vector,MAX_SAMPLES*sizeof(fftw_complex));
	return vector;
}
NamedVector * CreateNamedVector(char * name)
{
	NamedVector * nv = (NamedVector *)malloc(sizeof(NamedVector));

	strcpy(nv->name,name);

	nv->vector = CreateVector();

	return nv;
}

NamedVector * CreateWindow(char *window)
{
	NamedVector *nv = NULL;
	unsigned int ctr = 0;

	if(!strcmp(window,"Hanning")) {
		nv = CreateNamedVector("Hanning");
		for (ctr = 0; ctr < MAX_SAMPLES; ctr++) {
			nv->vector[ctr][0] = 0.5 * ( 1.0 - cos( (2.0*PI*ctr) / (MAX_SAMPLES-1)));
		}
		return nv;
	
	}
	else {
		debug_printf("%s","Unknown window!");
		return NULL;
	}
	
}


void build_bipolar_list_with_window(GSList *nv_list, Block *block, unsigned int current_sample_count,
					NamedVector *window)
{

	unsigned int ctr = 0;
	unsigned int nchan = 8;
	double values[8];
	double bivalues[8];
	double scale = 5.36441803e-7;
	unsigned char * stream = block->begin + 3;
	int temp;
	NamedVector *nv;
	GSList *list = nv_list;

	int status = block->begin[0];
	status = (status << 8) | block->begin[1];
	status = (status << 8) | block->begin[2];

	if (status != 0xC00000) {
		printf("Status: 0x%.6X\n",status);
	}

	if (window == NULL) {
		window = CreateWindow("Hanning");

		if (window->vector == NULL) {
			return;
		}
	}
	
	
	/* Copy 24-bit signed integers into 32-bit signed integers :( */
	for (ctr = 0; ctr < nchan ; ctr++)
	{	
		temp = stream[0];
		temp = (temp << 8) | stream[1];
		temp = (temp << 8) | stream[2];

 		if (temp & 0x800000) {
			temp |= ~0xffffff;
		}


		values[ctr] = (double)temp * scale;
		printf("Channel %d: %.6fV \n",ctr+1,values[ctr]);
		stream += 3;
	}

	/* Calculate the bipolar values */
	for (ctr = 0; ctr < nchan; ctr++)
	{
		if (ctr == 6) {
			bivalues[ctr] = values[ctr] - values[0];
		} 
		else if (ctr == 7) {
			bivalues[ctr] = values[ctr];
		} 
		else {
			bivalues[ctr] = values[ctr] - values[ctr+1];
		}
		/* Then window it */
	//	bivalues[ctr] *= window->vector[current_sample_count-1][0];
	}

	/* Update the list */
	ctr = 0;
	while (list != NULL) {
		nv = (NamedVector *)(list->data);
		nv->vector[current_sample_count-1][0] = bivalues[ctr];
		ctr++;
		list = g_slist_next(list);
	}
}
GSList * populate_list(GSList *list)
{
	GSList *nv_list = list;
	NamedVector *nv;

	/* Bipolar data between channel 1 and 2 */
	nv = CreateNamedVector("1>2");
	nv_list = g_slist_append(nv_list,nv);

	/* Bipolar data between channel 2 and 3 */
	nv = CreateNamedVector("2>3");
	nv_list = g_slist_append(nv_list,nv);

	/* Bipolar data between channel 3 and 4 */
	nv = CreateNamedVector("3>4");
	nv_list = g_slist_append(nv_list,nv);

	/* Bipolar data between channel 4 and 5 */
	nv = CreateNamedVector("4>5");
	nv_list = g_slist_append(nv_list,nv);

	/* Bipolar data between channel 5 and 6 */
	nv = CreateNamedVector("5>6");
	nv_list = g_slist_append(nv_list,nv);

	/* Bipolar data between channel 6 and 7 */
	nv = CreateNamedVector("6>7");
	nv_list = g_slist_append(nv_list,nv);

	/* Bipolar data between channel 7 and 1 */
	nv = CreateNamedVector("7>1");
	nv_list = g_slist_append(nv_list,nv);

	/* Reference channel*/
	nv = CreateNamedVector("Reference");
	nv_list = g_slist_append(nv_list,nv);

	return nv_list;
}
preproc_thread Preprocessor (void *n)
{
	GSList * nv_list = NULL;
	Block * block = NULL; 
	NamedVector *nv = NULL;
	GAsyncQueue *inq;
	allocmsg_t *msg = (allocmsg_t *)malloc(sizeof(allocmsg_t));
	NamedVector * window = NULL;
	unsigned int current_sample_count = 0;

	/* Create a vector to hold a standard Hanning window */
	window = CreateWindow("Hanning");

	if (window == NULL || window->vector == NULL) {
		debug_printf("%s","Could not create window \n");
		pthread_exit(NULL);
	}

	if (g_preproc_inq == NULL) {
		debug_printf("%s","Preprocessor starting...\n");
		g_preproc_running = true;
		/* Create the preproc interface */
		g_preproc_inq = g_async_queue_new();

		if (g_preproc_inq == NULL ) {
			debug_printf("%s","Failed to create a queue for Preprocessor!!!!!\n");
			pthread_exit(NULL);
		}

		/* Register the new preproc interface */
		inq = g_preproc_inq;
	}

	/*WARNING: This is platform specific! */
	if (nv_list == NULL) {
		debug_printf("%s","Creating first list \n");
		nv_list = populate_list(nv_list);
	}

	while (!gAppExiting) {
		/* Wait for incoming sample block */
		block = g_async_queue_try_pop(inq);

		if (block == NULL) {
			usleep(1);
			continue;

		}
		current_sample_count++;

		/* Create new data structure for processor */
		build_bipolar_list_with_window(nv_list,block,current_sample_count,window);
	
		/* Return the block to the allocator */
		msg->destination = NULL;
		msg->payload = block;
		g_async_queue_push(g_allocator_inq, msg);

		/* Reset the sample counter and send the list to processing*/
		if (current_sample_count == 1024) {
			current_sample_count = 0;
		
			/* Send the list */
			g_async_queue_push(g_proc_inq,nv_list);
			nv_list = populate_list(NULL);
			
		}
	}
	
	g_async_queue_push(g_proc_inq,nv_list);

	/* Return all the blocks to the allocator */
	block = g_async_queue_try_pop(inq);
	while (block != NULL)
	{
		msg->destination = NULL;
		msg->payload = block;
		g_async_queue_push(g_allocator_inq, msg);
		block = g_async_queue_try_pop(inq);
	}
	g_preproc_running = false;
	debug_printf("%s","Leaving the preprocessor...\n");
	pthread_exit(NULL);
}
