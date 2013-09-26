#include "Globals.h"
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <signal.h>

static uint8_t gAppRunning = 1;

void exit_handler(int signum)
{
	gAppRunning = 0;

}

uint8_t writeRegAddr(uint8_t addr)
{
	return addr | WREG_ADDR;
}

uint8_t writeRegNum(uint8_t num)
{
	return num | WREG_NUMR;
}

void writeConfigRegisters()
{
	uint8_t data;
	uint8_t ctr;

	/* Set internal reference */
        printf("Writing to addr %02x\n",CONFIG3);
	data = writeRegAddr(CONFIG3);
	bcm2835_spi_transfer(data);

	data = writeRegNum(1);
	bcm2835_spi_transfer(data);

	data = 0x60;
	bcm2835_spi_transfer(data);

	bcm2835_delay(2);

	/* Setup chip and channels */
	printf("Writing to addr %02x\n",CONFIG1);
	data = writeRegAddr(CONFIG1);
	bcm2835_spi_transfer(data);

	data = writeRegNum(1);
	bcm2835_spi_transfer(data);


	data = 0x96;
	bcm2835_spi_transfer(data);

	printf("Writing to addr %02x\n",CONFIG2);
	data = writeRegAddr(CONFIG2);
	bcm2835_spi_transfer(data);

	data = writeRegNum(1);
	bcm2835_spi_transfer(data);

	data = 0xD0;
	bcm2835_spi_transfer(data);

	printf("Writing to addr %02x-%02x\n",CHNSET_LOW,CHNSET_HIGH-1);
	data = writeRegAddr(CHNSET_LOW);
	bcm2835_spi_transfer(data);

	data = writeRegNum(7);
	bcm2835_spi_transfer(data);

	data = 0x80;

	for (ctr = 0; ctr < 7; ctr++)
	{
		bcm2835_spi_transfer(data);
	}

	data = writeRegAddr(CHNSET_HIGH);
	bcm2835_spi_transfer(data);
	data = writeRegNum(1);
	bcm2835_spi_transfer(data);

	data = 0x05;

	bcm2835_spi_transfer(data);

}

void getData()
{
	char buf[6];
	unsigned int nCon = 0;
	FILE *f = fopen("/home/pi/EIS/Data/data.bin","w");

	if (f == NULL) {
		printf("Can't open file!\n");
	}
	bzero(buf,6);
	
	printf("Getting data...\n");

	while (gAppRunning) 
	{
		if (!bcm2835_gpio_lev(DRDY))
		{	
			while (!bcm2835_gpio_lev(DRDY)) {} /* Spin on DRDY */
			//bcm2835_spi_transfern(buf,6);
			//printf("%x%x%x: %x%x%x\n",buf[0],buf[1],buf[2],buf[3],buf[4],buf[5]);
			//fwrite(buf+3,3,1,f);	
			//bzero(buf,6); 
			nCon++;
			printf("Conversion: %d\n",nCon);
		}
	}
	printf("Closing...\n");
	fclose(f);
}

int main(int argc, char **argv)
{
	if (!bcm2835_init())
	{
	        return 1;
	}

	signal(SIGINT, exit_handler);

	// Enable SPI comms
	bcm2835_spi_begin();

	// Set the pins to be an output
    	bcm2835_gpio_fsel(CLKSEL, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(RESET, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(START, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(PWDN, BCM2835_GPIO_FSEL_OUTP);

	bcm2835_gpio_fsel(DRDY, BCM2835_GPIO_FSEL_INPT);
	bcm2835_gpio_set_pud(DRDY, BCM2835_GPIO_PUD_UP);

    	bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);      // The default
    	bcm2835_spi_setDataMode(BCM2835_SPI_MODE1);                   // The default
    	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_8); // The default
    	bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                      // The default
    	bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);      // the default


	// Enable internal clock
        bcm2835_gpio_write(CLKSEL, HIGH);
	bcm2835_gpio_write(PWDN,HIGH);
	bcm2835_gpio_write(RESET, HIGH);

        // wait 1s for POR
        //bcm2835_delay(1000);

	// Tell ADS1299 to stop continuous data transfer mode so we can configure it
	//uint8_t data = bcm2835_spi_transfer(SDATAC);
        //printf("Read from SPI: %02X\n", data);

	//bcm2835_delay(200);

	// Configure the chip
	//writeConfigRegisters();
	
	bcm2835_gpio_write(START,LOW);

	// Tell ADS1299 to start continuous data transfer mode
    	//data = bcm2835_spi_transfer(RDATAC);
    	//printf("Read from SPI: %02X\n", data);

	getData();

	bcm2835_spi_end();
	bcm2835_close();
	return 0;
}
