#include <stdio.h>
#include <wiringPi.h>
#include "Globals.h"

static volatile int numDRDY;
char zbuf[BYTES_PER_SAMPLE*NUM_CHAN];
char buf[BYTES_PER_SAMPLE*NUM_CHAN];
void doDRDYcount(void) { 
    ++numDRDY; 
	bcm2835_spi_transfernb(zbuf,buf,BYTES_PER_SAMPLE*NUM_CHAN);
//	printf("%.2X%.2X%.2X,%.2X%.2X%.2X,%.2X%.2X%.2X,%.2X%.2X%.2X,%.2X%.2X%.2X,%.2X%.2X%.2X,%.2X%.2X%.2X,%.2X%.2X%.2X,%.2X%.2X%.2X\n",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5],buf[6],buf[7],buf[8],buf[9],buf[10],buf[11],buf[12],buf[13],buf[14],buf[15],buf[16],buf[17],buf[18],buf[19],buf[20],buf[21],buf[22],buf[23],buf[24],buf[25],buf[26]);
	printf("Hit the interrupt %d times\n", numDRDY);  
  if (buf[0] != 0xC0) {
        printf("Bad value!\n");
    }
}

int setupADS()
{
   	uint8_t data;
	uint8_t ctr;
	// Enable SPI comms

	if (!bcm2835_init())
	{
		printf("%s","ERROR Couldn't start the bcm2835\n");
	}


	bcm2835_spi_begin();
	bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // MSB is first
    bcm2835_spi_setDataMode(BCM2835_SPI_MODE1);                   // CPOL=0 CPHA=1
    bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_64);     // 1MHz
    bcm2835_spi_chipSelect(BCM2835_SPI_CS_NONE);                  // Control CS manually
//    bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);  
    bcm2835_gpio_write(BCM2835_SPI_CS0,LOW);
	
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
		printf("Sanity check failed! Read: 0x%x\n",data);
		return 0;
	}
	else
	{
		printf("%s","Got magic value!!!\n");
	}
	
    // Write CONFIG1
	bcm2835_spi_transfer(WREG_ADDR | CONFIG1);
	bcm2835_delay(1);

	bcm2835_spi_transfer(WREG_NUMR);
	bcm2835_delay(1);

	bcm2835_spi_transfer(0x93); // Enable 2 ksps conversions
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
		bcm2835_spi_transfer(0x60); // normal channels
		bcm2835_delay(1);
	}
	
    /* Resume continuous data conversion mode */
	bcm2835_spi_transfer(RDATAC);
	bcm2835_delay(1);

	/* Start conversions */
	bcm2835_spi_transfer(START);
	

	return 1;
}

int main()
{
    int mycount = 0;
    wiringPiSetupGpio();

	// Set the pins to be an output
  	pinMode(CLKSEL, OUTPUT);
	pinMode(RESET_P, OUTPUT);
	pinMode(START_P, OUTPUT);
	pinMode(PWDN, OUTPUT);

	// Enable internal clock
	digitalWrite(CLKSEL, HIGH);
	digitalWrite(PWDN,HIGH);
	digitalWrite(RESET_P, HIGH);
	digitalWrite(START_P,LOW);
	
	sleep(1);    

    if (!setupADS()) {
        printf("Setup failed!\n");
        goto EXIT;
    }
    if(!piHiPri(0)) {
        printf("Can't set high priority\n");
        goto EXIT;
    }
    
    wiringPiISR(DRDY, INT_EDGE_FALLING, &doDRDYcount); 

    for (;;) {
        if (mycount != numDRDY) {
            mycount = numDRDY;
        }
     }
EXIT:
	bcm2835_spi_end();
	bcm2835_close();
    return 0;
}
