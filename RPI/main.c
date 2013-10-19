#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <glib.h>
#include <signal.h>
#include "Globals.h"
#include "Allocator.h"
#include "ADS.h"

#ifdef TEST_CLIENT
	#include "TestClient.h" 
	#define NUM_THREADS 3
#else
	#define NUM_THREADS 2
#endif

boolean gAppExiting = false;

void exit_handler(int signum)
{
	gAppRunning = 0;

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
	pthread_create(&threads[0], NULL, Allocator, NULL);

#ifdef TEST_CLIENT
	debug_printf("%s","Starting the test client\n");
	pthread_create(&threads[2], NULL, TestClient, NULL);
#endif

	debug_printf("%s","Starting data acquisition thread\n");
	pthread_create(&threads[1], NULL, ADS, NULL);

	/* Wait for all threads to complete */
  	for (ctr=0; ctr<NUM_THREADS; ctr++) {
		pthread_join(threads[ctr], NULL);
  	}

	pthread_attr_destroy(&attr);
	pthread_exit(NULL);
}
