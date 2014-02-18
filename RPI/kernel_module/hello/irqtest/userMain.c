/*
	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***
	***		Raspberry Pi gpio hardware interrupt test.												***
	***		This is the user level code.  The ISR is in irqtest.c									***
	***																								***
	***																								***
	***		by Jay F. Hamlin , February 2013.    GPL licensed										***
	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	
*/

//
// Necessary linux headers
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <termios.h>

//
// my header
#include "irqtest.h"  

static irq_user_info  *getDriver_myMap_info (void);

//
//  non-blocking key input without using ncurses 
static int key_is_hit(void);
static void key_init_nonblock(int state);
#define		NB_ENABLE	1
#define		NB_DISABLE	2
#define		ASCII_ESC	27

//
//
int main(int argc, const char * argv[])
{
	int fdWrite, myCounter,i;
	long  wordCount,endCount;
	ssize_t n;
	irq_user_info  *usrInfo;
	char c;
	
	if(argc!=2){
		fprintf(stderr,"Usage :userisr  </path/file> %d\n",argc);
		return -1;
	}

	key_init_nonblock(NB_ENABLE);	// initialize key input

	// see if our driver is present
	usrInfo = getDriver_myMap_info();
	if(usrInfo) {
		//	buffer; 	/* the data */ 	
		/* the buffer is 1k words or 2k bytes long			*/
		/* we want to be 1/2 cycle behind so we wait until the 512 word boundry is crossed by the ISR	*/
		/* then write the block behind it				*/


		// open our log file
		fdWrite=open(argv[1],O_CREAT | O_RDWR,S_IRWXG);
		if(fdWrite!=-1){
			fprintf(stderr, "file is created.\n");
			myCounter=0;
			while(1) {		// go until break
	
				i=((usrInfo->irqCounter)>>8);  // 512 words
				myCounter=i;
				while(myCounter==i) {
					if(key_is_hit()) {
						c=fgetc(stdin);
					} else {
						c=0;
					}
           			if (c == ASCII_ESC || c == 'x' || c == 'q')		// break on ESC or x or q
 						goto outahere;
					else if(c=='p' || c==' ') {
						fprintf(stderr," irq=%d  usr= %d\n",usrInfo->irqCounter,myCounter); // print status
					}
					usleep(250); // 0.250 ms
					i=(usrInfo->irqCounter)>>8;  // 512 words
				}
				myCounter=i;
				if(myCounter&0x00000001)
					write(fdWrite,(const char*)(&usrInfo->buffer[0]),1024);
				else
					write(fdWrite,(const char*)(&usrInfo->buffer[512]),1024);
			}
  outahere:   	 		 
			key_init_nonblock(NB_DISABLE);	// done with key input
			close(fdWrite);			// close our file
		} else {
			fprintf(stderr, "Failed to open user file!\n");
		}
	} else {
		fprintf(stderr, "Failed to get driver data!\n");
	}
    
	fprintf(stderr, "Exiting! count=%d\n",usrInfo->irqCounter);
    
	return 0;
}

#define PAGE_SIZE 4096

static irq_user_info  *getDriver_myMap_info ( void)
{
	int 	configfd;
	irq_user_info  *buffer;
	configfd = open("/sys/kernel/debug/irqtest_mmap", O_RDWR);
	if(configfd < 0) {
		perror("open");
		return 0;
	}

	char * address = NULL;
	buffer = (irq_user_info  *)mmap(NULL, PAGE_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, configfd, 0);
	if (buffer == MAP_FAILED) {
		perror("mmap");
		return 0;
	}

	fprintf(stderr,"got irq  buffer=0x%8X\n",(unsigned int)buffer);

	close(configfd);	
	return (buffer);
}

//
//
//  non-blocking key input without using ncurses below
//  From: http://cc.byexamples.com/2007/04/08/non-blocking-user-input-in-loop-without-ncurses/
//
//
static int key_is_hit(void)
{
    struct timeval tv;
    fd_set fds;
    tv.tv_sec = 0;
    tv.tv_usec = 0;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
    select(STDIN_FILENO+1, &fds, NULL, NULL, &tv);
    return FD_ISSET(STDIN_FILENO, &fds);
}

static void key_init_nonblock(int state)
{
    struct termios ttystate;
 
    //get the terminal state
    tcgetattr(STDIN_FILENO, &ttystate);
 
    if (state==NB_ENABLE)
    {
        //turn off canonical mode
        ttystate.c_lflag &= ~ICANON;
        //minimum of number input read.
        ttystate.c_cc[VMIN] = 1;
    }
    else if (state==NB_DISABLE)
    {
        //turn on canonical mode
        ttystate.c_lflag |= ICANON;
    }
    //set the terminal attributes.
    tcsetattr(STDIN_FILENO, TCSANOW, &ttystate);
 
}

#if 0

non blocking key test sample code.

int main(int argc, const char * argv[])
{
	int myCounter,i;
	char c;
	
	key_init_nonblock(NB_ENABLE);	// initialize key input
	i=1;
	myCounter=0;
	while(i) {
		if(key_is_hit()) {
			c=fgetc(stdin);

    		if (c == ASCII_ESC || c == 'x' || c == 'q')		// break on ESC or x or q
 				i=0;
			else
				fprintf(stderr," c=%c  count= %d\n",c,myCounter); // print status
		} 

		usleep(250); // 0.250 ms
		myCounter++;
	}
	key_init_nonblock(NB_DISABLE);	// done with key input
	return 0;
}

#endif

