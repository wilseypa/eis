#ifndef PREPROCESSOR_H
#define PREPROCESSOR_H

#define MAX_SAMPLES 1024
#define PI 3.14159265359

#include <glib.h>
#include <fftw3.h>

typedef void * preproc_thread;

extern GAsyncQueue *g_preproc_inq;
extern boolean g_preproc_running;
typedef struct {

	char name[256];
	fftw_complex *vector;	

} NamedVector;

preproc_thread Preprocessor (void *n);

#endif
