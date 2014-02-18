#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "Globals.h"
#include "ADS.h"
#include "Allocator.h"
#include "Preprocessor.h"
GAsyncQueue *g_allocator_inq = NULL;

Block * CreateBlock()
{
    // Allocate space for data in a block
	Block * block = (Block *)malloc(1*sizeof(Block));
	
	block->size = BLOCK_SIZE;
	block->begin = (unsigned char *)calloc(BLOCK_SIZE,sizeof(unsigned char));
	return block;
}

alloc_thread Allocator (void *n)
{
	GQueue *free_blocks;
	GList *list;
	GList *node;
	Block * block;
	unsigned int ctr = 0;
	unsigned int init_blocks = 10;
	unsigned allocated = 0;


	allocmsg_t *msg = NULL;

    /* Register the allocator message interface */
	if (g_allocator_inq == NULL)
	{
		debug_printf("%s","Allocator starting...\n");
		
		g_allocator_inq = g_async_queue_new();
		if (g_allocator_inq == NULL) {
			debug_printf("%s","Failed to create a queue for Allocator!!!!\n");
			pthread_exit(NULL);
		}
	}

    /* Create a queue of free blocks */
	free_blocks = (GQueue *)g_queue_new();

	if (free_blocks == NULL) {
		debug_printf("%s","Failed to create a queue for Blocks!!!!\n");
		pthread_exit(NULL);
	}
	
	debug_printf("%s","Creating 10 blocks to start...\n");

    /* Allocate space for a bunch of initial blocks */
	for (ctr = 0; ctr < init_blocks; ctr++) {

		block = CreateBlock();
		allocated += sizeof(Block) + BLOCK_SIZE*sizeof(unsigned char);
		g_queue_push_head(free_blocks, block);
	}


    /* Sanity check on the initial block queue */
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
				while (g_preproc_running || g_ads_running) sleep(1);
				break; // Leave the processing loop
			}
			else 
			{
                /* Send the block back to the free queue */
			    debug_printf("Returning block 0x%X to pool\n",msg->payload);
			    g_queue_push_head(free_blocks,msg->payload);
			}
		}

		else /* Someone wants a block */ 
		{
            /* Grab a free block */
 			block = (Block *)g_queue_pop_tail(free_blocks);
		
			if (block == NULL) /* We're fresh out... */
			{
                /* Allocate a new block */
				block = CreateBlock();
				allocated += sizeof(Block) + BLOCK_SIZE*sizeof(unsigned char);

			}

			debug_printf("Sending block 0x%X to 0x%X\n",block,msg->destination);

			g_async_queue_push(msg->destination,block); /* Send it! */
		}
		free(msg); 
		
	}

	while (g_preproc_running || g_ads_running) sleep(1);

	/* Cleanup */
	msg = g_async_queue_try_pop(g_allocator_inq); 
    
    /* Handle remaining messages */
	while (msg != NULL)
	{
        /* Return all the free'd blocks to the free list */
		if (msg->destination == NULL && msg->payload != NULL) {
			g_queue_push_head(free_blocks,msg->payload);
		}
		free(msg);
		msg = g_async_queue_try_pop(g_allocator_inq); 
	}

    /* Try to free the blocks */
	block = g_queue_pop_tail(free_blocks);
	printf("We need to destroy %d bytes\n",allocated);
	while (block != NULL)
	{
        /* See if we already free'd this block */
        node = g_list_find(list,block);

        /* If not go ahead and free it */
        if (node == NULL) {        
            /* Add it to the list of things free */
            list = g_list_append(list,block);
   	    	free(block->begin);
	    	free(block);
	    	allocated -= (sizeof(Block) + BLOCK_SIZE*sizeof(unsigned char));
	    	block = g_queue_pop_tail(free_blocks);
	    } 
	    else {
	        debug_printf("%s","Block already free'd, skipping...");
	    }
	}
	g_list_free(list);

	if (allocated != 0) {
		printf("%d bytes left :(\n",allocated);
	}
	g_async_queue_unref(g_allocator_inq);
	g_queue_free(free_blocks);

	debug_printf("%s","Leaving the Allocator thread...\n");	
	pthread_exit(NULL);
}


