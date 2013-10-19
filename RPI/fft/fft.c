#include <stdlib.h>
#include <stdio.h>
#include <fftw3.h>
#include <string.h>

int main () 
{
	fftw_complex *in, *out;
	fftw_plan p;
	unsigned int N = 8;
	unsigned int ctr = 0;
	
	FILE *fp = fopen("/dev/urandom","r");
	out = NULL;
	in = NULL;

	if (fp == NULL) {
		printf("Can't open /dev/urandom!!!!\n");
		goto EXIT;
	}

	in = (fftw_complex*)fftw_malloc(sizeof(fftw_complex)*N);
	out = (fftw_complex*)fftw_malloc(sizeof(fftw_complex)*N);

	if (in == NULL || out == NULL) {
		printf("Out of memory\n");
		goto  ERROR;
	}

	bzero(in,sizeof(fftw_complex)*N);
	in[0][0] = 1.0f;

	p = fftw_plan_dft_1d(N,in,out,FFTW_FORWARD, FFTW_ESTIMATE);

	fftw_execute(p);

	for (ctr = 0; ctr < N; ctr++) {
		printf("%f + %fi\n",out[ctr][0],in[ctr][1]);
	}

ERROR:
	fftw_destroy_plan(p);
	fftw_free(in);
	fftw_free(out);

EXIT:
	return 0;
}
