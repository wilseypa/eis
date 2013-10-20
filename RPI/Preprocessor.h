#ifndef PREPROCESSOR_H
#define PREPROCESSOR_H

#include <glib.h>
#include <fftw3.h>

typedef void * preproc_thread;

extern GAsyncQueue *g_preproc_inq;

typedef struct {

	char name[256];
	fftw_complex *vector;	

} NamedVector;

preproc_thread Preprocessor (void *n);
NamedVector * CreateWindow(char *window);

#endif
