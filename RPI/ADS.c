#include "Globals.h"
#include "ADS.h"
#include "Allocator.h"
#include "Preprocessor.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <unistd.h>
#include <wiringPi.h>

boolean g_ads_running = false;
unsigned char zbuf[BYTES_PER_SAMPLE*NUM_CHAN];
Block *block = NULL;
GAsyncQueue *inq, *outq;


void handleDRDY_interrupt()
{
    allocmsg_t *msg;

	
    piHiPri(99);

    if (!gAppExiting) {
        /* Begin read when DRDY goes low */

	    /* Read in all the data */
	    bcm2835_spi_transfernb(zbuf,block->begin,BYTES_PER_SAMPLE*NUM_CHAN);

	    /* We send off the block here for processing */		
	    debug_printf("Sending block 0x%X for processing...\n",block);

	    /*Sending to preprocessor */
	    g_async_queue_push(g_preproc_inq,block);
	    			
	    /* Try to get a new block */
	    block = g_async_queue_try_pop(inq);

	    /* If no new blocks are available */
	    if (block == NULL) {
        	/* Send a message to the allocator to create one */
            msg = malloc(sizeof(allocmsg_t));
            msg->destination = inq;
            msg->payload = NULL;
            debug_printf("Sending 0x%X message to allocator",msg);
	    	g_async_queue_push(outq,msg);

	    	/* Wait until a new block arrives */
    	    block = g_async_queue_pop(inq);
	    }
	}
    
}


boolean writeConfigRegisters()
{
	uint8_t data;
	uint8_t ctr;


	/* Sanity check */

	/* Stop all conversions */
	bcm2835_spi_transfer(STOP);
	usleep(1);	

	/* Disable continuous conversion mode */
	bcm2835_spi_transfer(SDATAC);
	usleep(1);

	/* Read from register CONFIG1 */
	bcm2835_spi_transfer(RREG_ADDR | CONFIG1);
	usleep(1);

	/* Read one register */
	bcm2835_spi_transfer(RREG_NUMR);
	usleep(1);
	
	/* read the data from the bus */
	data = bcm2835_spi_transfer(DONT_CARE);

	/* On startup, CONFIG1 should equal MAGIC_VALUE;
		if we read that value, our comms are good */
	if (data != MAGIC_VALUE)
	{
		debug_printf("Sanity check failed! Read: 0x%x\n",data);
		return false;
	}
	else
	{
		debug_printf("%s","Got magic value!!!\n");
	}

	// Write CONFIG1
	bcm2835_spi_transfer(WREG_ADDR | CONFIG1);
	usleep(1);

	bcm2835_spi_transfer(WREG_NUMR);
	usleep(1);

	bcm2835_spi_transfer(0x95); // Enable 250, 500, 1, 2, 4, 8, 16 kSps conversions
	usleep(1);

	// Write CONFIG2
	bcm2835_spi_transfer(WREG_ADDR | CONFIG2);
	usleep(1);

	bcm2835_spi_transfer(WREG_NUMR);
	usleep(1);

	bcm2835_spi_transfer(0xC2); // No test signals
	usleep(1);

	// Write CHnSet
	bcm2835_spi_transfer(WREG_ADDR | CHNSET_LOW);
	usleep(1);

	bcm2835_spi_transfer(WREG_NUMR | 0x07);
	usleep(1);

	for ( ctr = 0; ctr < 8; ctr++)	
	{
		bcm2835_spi_transfer(0x60); // normal channels
		usleep(1);
	}


	return true;
}

boolean getData()
{
    unsigned int ctr;
    allocmsg_t *msg;
    
	/* Create a incoming queue for blocks */
	inq = g_async_queue_new();

	/* Draft a message to the Allocator thread */
    msg = malloc(sizeof(allocmsg_t));
	msg->destination = inq;
	msg->payload = NULL;

	/* Wait for the allocator interface to come online */
	while (g_allocator_inq == NULL) usleep(1);

	/* Register the allocator interface */
	outq = g_allocator_inq;

	/* Request that NUM_CHAN blocks be made available */
	for (ctr = 0; ctr < NUM_CHAN; ctr++) {
        msg = malloc(sizeof(allocmsg_t));
        msg->destination = inq;
        msg->payload = NULL;
		g_async_queue_push(outq,msg);
	}

	/* This is our buffer to send over the SPI bus */
	bzero(zbuf,BYTES_PER_SAMPLE*NUM_CHAN);

	/* Get an initial block from the queue */
	block = g_async_queue_pop(inq);

	g_ads_running = true;
	
	debug_printf("%s","Getting data...\n");

	/* Resume continuous data conversion mode */
	bcm2835_spi_transfer(RDATAC);
	usleep(1);

	/* Start conversions */
	bcm2835_spi_transfer(START);

	while (!gAppExiting) 
	{

        /* Check the status of the incoming block queue */
		if (g_async_queue_length(inq) < 10) {
			/* Tell the allocator to create some more if we are running low */
            msg = malloc(sizeof(allocmsg_t));
            msg->destination = inq;
            msg->payload = NULL;
			g_async_queue_push(outq,msg);
		}
		/* Sleep for a bit */
		usleep(1);
	}

    /* Return unused blocks to the allocator */
    block = g_async_queue_try_pop(inq);
    
    while (block != NULL) 
    {
        msg = malloc(sizeof(allocmsg_t));
        msg->destination = NULL;
        msg->payload = block;
        g_async_queue_push(outq,msg);
        block = g_async_queue_try_pop(inq);
    }

	/* The program is exiting, turn off the ADS chip */
	bcm2835_spi_transfer(0x0A);
	debug_printf("%s","Closing ADS...\n");
	return true;
}

ads_thread ADS(void *n)
{
    allocmsg_t *msg;
	debug_printf("%s","Starting the ADS thread...\n");

    // Initialize the broadcom interface
	if (!bcm2835_init())
	{
		debug_printf("%s","ERROR Couldn't start the bcm2835\n");
	        pthread_exit(NULL);
	}

	// Enable SPI comms
	bcm2835_spi_begin();

	// Set the pins to be outputs
    bcm2835_gpio_fsel(CLKSEL, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(RESET, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(START_P, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(PWDN, BCM2835_GPIO_FSEL_OUTP);

    // SPI config
    bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // MSB is first
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE1);                   // CPOL=0 CPHA=1
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_16);     // 31.25MHz
    bcm2835_spi_chipSelect(BCM2835_SPI_CS_NONE);                  // Control CS manually
    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);    // CS is enable low


	// Enable internal clock
    bcm2835_gpio_write(CLKSEL, HIGH);

    // Prevent chip from going into standby
	bcm2835_gpio_write(PWDN,HIGH);

    // Prevent chip from reseting
	bcm2835_gpio_write(RESET, HIGH);

    // Keep the start pin low, we will trigger via SPI
	bcm2835_gpio_write(START_P,LOW);

    // Keep the SPI chip select tied low to enable the chip
	bcm2835_gpio_write(BCM2835_SPI_CS0,LOW);

	// Configure the chip registers
	if (!writeConfigRegisters()) goto EXIT;
	
    // Enable interrupts on DRDY, so that we can handle data conversions
    wiringPiSetupGpio();
    wiringPiISR(DRDY, INT_EDGE_FALLING, &handleDRDY_interrupt);
	
	// Let's get data!
	if (!getData()) goto EXIT;

EXIT:
    // End the SPI sessions
	bcm2835_spi_end();
	bcm2835_close();

	/* Tell Allocator we're done */
    msg = malloc(sizeof(allocmsg_t));
	msg->destination = NULL;
	msg->payload = block;

	if (g_allocator_inq != NULL) {
		g_async_queue_push(g_allocator_inq,msg);
		usleep(1);
	}
	
	msg = malloc(sizeof(allocmsg_t));
	msg->destination = NULL;
	msg->payload = NULL;

	if (g_allocator_inq != NULL) {
		g_async_queue_push(g_allocator_inq,msg);
		usleep(1);
	}

	g_ads_running = false;
	
	debug_printf("%s","Leaving ADS thread...\n");
	pthread_exit(NULL);
}
