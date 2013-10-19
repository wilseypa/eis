#include "Globals.h"
#include "ADS.h"
#include "Allocator.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <unistd.h>

boolean writeConfigRegisters()
{
	uint8_t data;
	uint8_t ctr;


	/* Sanity check */

	/* Stop all conversions */
	bcm2835_spi_transfer(STOP);
	bcm2835_delay(1);	

	/* Disable continuous conversion mode */
	bcm2835_spi_transfer(SDATAC);
	bcm2835_delay(1);

	/* Read from register CONFIG1 */
	bcm2835_spi_transfer(RREG_ADDR | CONFIG1);
	bcm2835_delay(1);

	/* Read one register */
	bcm2835_spi_transfer(RREG_NUMR);
	bcm2835_delay(1);
	
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
	bcm2835_delay(1);

	bcm2835_spi_transfer(WREG_NUMR);
	bcm2835_delay(1);

	bcm2835_spi_transfer(0x96); // Enable 250Sps conversions
	bcm2835_delay(1);

	// Write CONFIG2
	bcm2835_spi_transfer(WREG_ADDR | CONFIG2);
	bcm2835_delay(1);

	bcm2835_spi_transfer(WREG_NUMR);
	bcm2835_delay(1);

	bcm2835_spi_transfer(0xC2); // No test signals
	bcm2835_delay(1);

	// Write CHnSet
	bcm2835_spi_transfer(WREG_ADDR | CHNSET_LOW);
	bcm2835_delay(1);

	bcm2835_spi_transfer(WREG_NUMR | 0x07);
	bcm2835_delay(1);

	for ( ctr = 0; ctr < 8; ctr++)	
	{
		bcm2835_spi_transfer(0x61); // short each channel
		bcm2835_delay(1);
	}


	return true;
}

boolean getData()
{
	unsigned char zbuf[BYTES_PER_SAMPLE*NUM_CHAN];
	unsigned char rbuf[BYTES_PER_SAMPLE*NUM_CHAN];
	unsigned int nCon = 0;
	unsigned int ctr = 0;

	GAsyncQueue *inq, *outq;
	allocmsg_t msg;

	/*TODO: Figure out blocksize / how to pass to processing thread */


	inq = g_async_queue_new();

	msg.destination = inq;
	msg.payload = NULL;

	while (g_allocator_inq == NULL) sleep(1);

	outq = g_allocator_inq;

	for (ctr = 0; ctr < NUM_CHAN; ctr++) {
	
		g_async_queue_push(outq,&msg);
	}


	bzero(zbuf,BYTES_PER_SAMPLE*NUM_CHAN);
	

	

	debug_printf("%s","Getting data...\n");

	/* Resume continuous data conversion mode */
	bcm2835_spi_transfer(RDATAC);
	bcm2835_delay(1);

	/* Start conversions */
	bcm2835_spi_transfer(START);

	while (!gAppExiting) 
	{
		/* Check data conversion ready line */
		if (!bcm2835_gpio_lev(DRDY))
		{	
			/* Begin read when DRDY goes low */
//			while (!bcm2835_gpio_lev(DRDY)) {} /* Spin on DRDY */

			/* Read in all the data */
			bcm2835_spi_transferb(zbuf,rbuf,BYTES_PER_SAMPLE*NUM_CHAN);
			debug_printf("\nConversion: %d\n",nCon);
			nCon++;
			if (nCon == 4096) {
				bcm2835_spi_transfer(0x0A);
			}

		}
		else {
			usleep(1);
		}
	}

	debug_printf("%s","Closing...\n");
	return true;
}

ads_thread ADS(void *n)
{
	if (!bcm2835_init())
	{
	        pthread_exit(NULL);
	}


	// Enable SPI comms
	bcm2835_spi_begin();

	// Set the pins to be an output
    	bcm2835_gpio_fsel(CLKSEL, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(RESET, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(START_P, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(PWDN, BCM2835_GPIO_FSEL_OUTP);

	// DRDY is an input, use a pullup resistor
	bcm2835_gpio_fsel(DRDY, BCM2835_GPIO_FSEL_INPT);
	bcm2835_gpio_set_pud(DRDY, BCM2835_GPIO_PUD_UP);

    	bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // MSB is first
    	bcm2835_spi_setDataMode(BCM2835_SPI_MODE1);                   // CPOL=0 CPHA=1
    	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_32);     // 31.25MHz
    	bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                  // Control CS manually
    	bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);  


	// Enable internal clock
        bcm2835_gpio_write(CLKSEL, HIGH);
	bcm2835_gpio_write(PWDN,HIGH);
	bcm2835_gpio_write(RESET, HIGH);
	bcm2835_gpio_write(START_P,LOW);
	bcm2835_gpio_write(BCM2835_SPI_CS0,LOW);

	// Configure the chip
	if (!writeConfigRegisters()) goto EXIT;
	
	// Let's get data!
	if (!getData()) goto EXIT;

EXIT:
	bcm2835_spi_end();
	bcm2835_close();

	pthread_exit(NULL);
}
