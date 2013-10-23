#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "Globals.h"
#include "Allocator.h"
#include "Preprocessor.h"
GAsyncQueue *g_allocator_inq = NULL;

Block * CreateBlock()
{
	Block * block = (Block *)malloc(1*sizeof(Block));
	
	block->size = BLOCK_SIZE;
	block->begin = (unsigned char *)calloc(BLOCK_SIZE,sizeof(unsigned char));
	return block;
}

alloc_thread Allocator (void *n)
{
	GQueue *free_blocks;
	Block * block;
	unsigned int ctr = 0;
	unsigned int init_blocks = 10;

	allocmsg_t *msg = NULL;

	if (g_allocator_inq == NULL)
	{
		debug_printf("%s","Allocator starting...\n");
		
		g_allocator_inq = g_async_queue_new();
		if (g_allocator_inq == NULL) {
			debug_printf("%s","Failed to create a queue for Allocator!!!!\n");
			pthread_exit(NULL);
		}
	}

	free_blocks = (GQueue *)g_queue_new();

	if (free_blocks == NULL) {
		debug_printf("%s","Failed to create a queue for Blocks!!!!\n");
		pthread_exit(NULL);
	}
	
	debug_printf("%s","Creating 10 blocks to start...\n");

	for (ctr = 0; ctr < init_blocks; ctr++) {

		block = CreateBlock();

		g_queue_push_head(free_blocks, block);
	}


	if (g_queue_get_length(free_blocks) != init_blocks) {
		debug_printf("%s","Sanity check failed...\n");
		pthread_exit(NULL);
	}

	/* Main loop */
	while (!gAppExiting) {

		/* Wait for message from other threads */
		debug_printf("%s","Waiting for message...\n");
		msg = (allocmsg_t *)g_async_queue_pop(g_allocator_inq);
	
		debug_printf("Got message 0x%X!\n",msg);
		/* We got a message! */
		if (msg->destination == NULL) /* Return to the free queue */
		{

			if (msg->payload == NULL) /* NULL payload means we stop! */
			{
				debug_printf("%s","We have to stop the allocator\n");
				while (g_preproc_running) sleep(1);
				break;
			}
			debug_printf("Returning block 0x%X to pool\n",msg->payload);
			g_queue_push_head(free_blocks,msg->payload);
		}

		else /* Someone wants a block */ 
		{
			block = (Block *)g_queue_pop_tail(free_blocks);
		
			if (block == NULL) /* We're fresh out... */
			{
				block = CreateBlock();
			}

			debug_printf("Sending block 0x%X to 0x%X\n",block,msg->destination);

			g_async_queue_push(msg->destination,block); /* Send it! */
		} 
		
	}

	/* Cleanup */
	msg = g_async_queue_try_pop(g_allocator_inq); 
	while (msg != NULL)
	{
		msg = g_async_queue_try_pop(g_allocator_inq); 
	}

	block = g_queue_pop_tail(free_blocks);
	while (block != NULL)
	{
		free(block->begin);
		free(block);
		block = g_queue_pop_tail(free_blocks);
	}
	g_async_queue_unref(g_allocator_inq);
	g_queue_free(free_blocks);

	debug_printf("%s","Leaving the Allocator thread...\n");	
	pthread_exit(NULL);
}


