#ifndef ALLOCATOR_H
#define ALLOCATOR_H

#include <glib.h>
typedef void * alloc_thread;

extern GAsyncQueue *g_allocator_inq;

typedef struct
{
	GAsyncQueue *destination;
	gpointer payload;

} allocmsg_t;


typedef struct
{
	unsigned char *begin;
	unsigned int size;

} Block;

alloc_thread Allocator (void *n);

#endif
