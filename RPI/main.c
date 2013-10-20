#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <glib.h>
#include <signal.h>
#include "Globals.h"
#include "Allocator.h"
#include "ADS.h"
#include "Preprocessor.h"
#include "Processor.h"

#ifdef TEST_CLIENT
	#include "TestClient.h" 
	#define NUM_THREADS 5
#else
	#define NUM_THREADS 4
#endif

boolean gAppExiting = false;

void exit_handler(int signum)
{
	gAppExiting = true;
	debug_printf("%s","Got Ctrl+C, Killing!\n");
}

int main()
{
	unsigned int ctr = 0;
	pthread_t threads[NUM_THREADS];
	pthread_attr_t attr;

	signal(SIGINT, exit_handler);

	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

	debug_printf("%s","Starting the allocator thread\n");
	pthread_create(&threads[0], &attr, Allocator, NULL);

#ifdef TEST_CLIENT
	debug_printf("%s","Starting the test client\n");
	pthread_create(&threads[4], NULL, TestClient, NULL);
#endif

	debug_printf("%s","Starting data acquisition thread\n");
	pthread_create(&threads[1], &attr, ADS, NULL);

	debug_printf("%s","Starting preprocessing thread\n");
	pthread_create(&thread[2], &attr, Preprocessor, NULL); 

	debug_printf("%s","Starting processing thread\n");
	pthread_create(&thread[3], &attr, Processor, NULL);

	/* Wait for all threads to complete */
  	for (ctr=0; ctr<NUM_THREADS; ctr++) {
		pthread_join(threads[ctr], NULL);
  	}

	pthread_attr_destroy(&attr);
	pthread_exit(NULL);
}
