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

	data = 0xE0;
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

	printf("Writing to addr %02x-%02x\n",CHNSET_LOW,CHNSET_HIGH);
	data = writeRegAddr(CHNSET_LOW);
	bcm2835_spi_transfer(data);

	data = writeRegNum(8);
	bcm2835_spi_transfer(data);

	data = 0x05;

	for (ctr = 0; ctr < 8; ctr++)
	{
		bcm2835_spi_transfer(data);
	}

}

void getData()
{
	char buf[27];
	unsigned int i;
	bzero(buf,27);
	

	while (gAppRunning) 
	{
		if (!bcm2835_gpio_lev(DRDY))
		{	
			if (bcm2835_gpio_lev(DRDY)) 
			{
				bcm2835_spi_transfern(buf,sizeof(buf));
				printf("status %02X%02X%02X ",buf[0],buf[1],buf[2]);
				printf("\n\n");
				printf("Channel\t1\t2\t3\t4\t5\t6\t7\t8\n");
				printf("\t");
				for (i = 3; i < 9*3; i = i + 3) 
				{
					printf("%02X%02X%02X\t",buf[i],buf[i+1],buf[i+2]);
				}
				printf("\n"); 
			}
		}
	}
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
    	bcm2835_spi_setDataMode(BCM2835_SPI_MODE0);                   // The default
    	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_65536); // The default
    	bcm2835_spi_chipSelect(BCM2835_SPI_CS0);                      // The default
    	bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);      // the default


	// Enable internal clock
        bcm2835_gpio_write(CLKSEL, HIGH);
	bcm2835_gpio_write(PWDN,HIGH);
	bcm2835_gpio_write(RESET, HIGH);

        // wait 1s for POR
        bcm2835_delay(1000);

        // Begin reset cycle
	bcm2835_gpio_write(RESET, LOW);

	bcm2835_delay(2);

	// Activate chip
	bcm2835_gpio_write(RESET, HIGH);
	bcm2835_gpio_write(CS, LOW);


	// Tell ADS1299 to stop continuous data transfer mode so we can configure it
	uint8_t data = bcm2835_spi_transfer(SDATAC);
        printf("Read from SPI: %02X\n", data);

	// Configure the chip
	writeConfigRegisters();
	
	// Let's begin
	bcm2835_gpio_write(START, HIGH);


	// Tell ADS1299 to start continuous data transfer mode
    	data = bcm2835_spi_transfer(RDATAC);
    	printf("Read from SPI: %02X\n", data);

	getData();

	bcm2835_spi_end();
	bcm2835_close();
	return 0;
}
