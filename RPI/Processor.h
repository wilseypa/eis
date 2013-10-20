#ifndef PROCESSOR_H
#define PROCESSOR_H

#include <glib.h>

typedef void * proc_thread;

extern GAsyncQueue *g_proc_inq;

proc_thread Processor (void *n);

#endif
