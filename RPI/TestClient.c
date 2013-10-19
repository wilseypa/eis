#include <stdio.h>
#include <stdlib.h>
#include "Globals.h"
#include "Allocator.h"
#include "TestClient.h"


testclient_thread TestClient (void *n)
{
	GAsyncQueue *inq = g_async_queue_new();
	allocmsg_t *msg = NULL;
	GAsyncQueue *outq = NULL;
	unsigned int ctr = 0;
	Block * block = NULL;

	debug_printf("%s","TestClient started...\n");

	while (g_allocator_inq == NULL) sleep(1);

	outq = g_allocator_inq;

	/* Send 10 meessages to the allocator */
	for (ctr = 0; ctr < 10; ctr++) {

		msg = (allocmsg_t *)malloc(1*sizeof(allocmsg_t));
		msg->destination = inq;
		msg->payload = NULL;
		debug_printf("Pushing msg 0x%X...\n",msg);

		g_async_queue_push(outq,msg);
	}

	ctr = 10;


	while (ctr != 0) {
		block = g_async_queue_pop(inq);
		debug_printf("Got block 0x%X, Freeing\n",block);
		if (block != NULL) free(block->begin);
		free(block);
		ctr--;
	}

	/* Kill the allocator and die */
	msg = (allocmsg_t *)malloc(1*sizeof(allocmsg_t));
	msg->destination = NULL;
	msg->payload = NULL;

	g_async_queue_push(outq,msg);

	g_async_queue_unref(inq);
	
	pthread_exit(NULL);
}
