#ifndef GLOBALS_H
#define GLOBALS_H

#include <bcm2835.h>
/*
    // RPi Version 2
    RPI_V2_GPIO_P1_03     =  2,  ///< Version 2, Pin P1-03
    RPI_V2_GPIO_P1_05     =  3,  ///< Version 2, Pin P1-05
    RPI_V2_GPIO_P1_07     =  4,  ///< Version 2, Pin P1-07
    RPI_V2_GPIO_P1_08     = 14,  ///< Version 2, Pin P1-08, defaults to alt function 0 UART0_TXD
    RPI_V2_GPIO_P1_10     = 15,  ///< Version 2, Pin P1-10, defaults to alt function 0 UART0_RXD
    RPI_V2_GPIO_P1_11     = 17,  ///< Version 2, Pin P1-11
    RPI_V2_GPIO_P1_12     = 18,  ///< Version 2, Pin P1-12
    RPI_V2_GPIO_P1_13     = 27,  ///< Version 2, Pin P1-13
    RPI_V2_GPIO_P1_15     = 22,  ///< Version 2, Pin P1-15
    RPI_V2_GPIO_P1_16     = 23,  ///< Version 2, Pin P1-16
    RPI_V2_GPIO_P1_18     = 24,  ///< Version 2, Pin P1-18
    RPI_V2_GPIO_P1_19     = 10,  ///< Version 2, Pin P1-19, MOSI when SPI0 in use
    RPI_V2_GPIO_P1_21     =  9,  ///< Version 2, Pin P1-21, MISO when SPI0 in use
    RPI_V2_GPIO_P1_22     = 25,  ///< Version 2, Pin P1-22
    RPI_V2_GPIO_P1_23     = 11,  ///< Version 2, Pin P1-23, CLK when SPI0 in use
    RPI_V2_GPIO_P1_24     =  8,  ///< Version 2, Pin P1-24, CE0 when SPI0 in use
    RPI_V2_GPIO_P1_26     =  7,  ///< Version 2, Pin P1-26, CE1 when SPI0 in use

*/

// Setup our pins
#define CLKSEL 2
#define DRDY 3
#define START_P 4
#define RESET 17
#define CS 8
#define PWDN 27

// These are the opcodes for the ADS1299
#define SDATAC 0x11 // Stops continuous data transfer mode
#define RDATAC 0x10 // Start continuous data transfer mode
#define STOP 0x0a
#define START 0x08

// Read
#define RREG_ADDR 0x20 // 001r rrrr : rrrr is register adress
#define RREG_NUMR 0x00 // 000n nnnn : nnnn is number of registers to read

// Write
#define WREG_ADDR 0x40 // 001r rrrr : rrrr is address
#define WREG_NUMR 0x00 // 000n nnnn : nnnn is number of registers to write


#define DONT_CARE 0x00
#define MAGIC_VALUE 0x96

#define BYTES_PER_SAMPLE 3
#define NUM_CHAN 9


// These are control registers for the ADS1299
#define CONFIG1 0x01
/*
Bit	7	6		5	4	3	2	1	0
Val	1	~DAISY_EN	CLK_EN	1	0	DR2	DR1	DR0

~DAISY_EN:
	0	Enabled (default)
	1	Multiple readback mode
CLK_EN:
	0	Oscillator clock output disabled (default)
	1	Oscillator clock output enabled
Bits[4:3]	Must equal 10

Bits[2:0]	Output data rate
	000	16kSPS
	001	8kSPS
	...
	110	250 SPS (default)
	111	DO NOT USE

Test value :10110110 -> 0xB6
*/
#define CONFIG1_TEST_MODE 0xB6

#define CONFIG2 0x02
/*
Bit	7	6	5	4	3	2		1		0
Val	1	1	0	INT_CAL	0	CAL_AMP0	CAL_FREQ1	CAL_FREQ0

INT_CAL:
	0 Test signals are driven externally (default)
	1 Test signals are driven internally

CAL_AMP0:	Test signal amplitude
		0	1x(VREFP - VREFN / 2.4mV (default)
		1	2x(VREFP - VREFN / 2.4mV

Bits[1:0]	Test signal frequency
		00	fclk / 2^21 (default)
		01	fclk / 2^20 
		10	Not used
		11	DC

Test value: 11010000 -> 0xD0 
*/
#define CONFIG2_TEST_MODE 0xD0

#define CHNSET_LOW 0x05
#define CHNSET_HIGH 0x0C

/*
Bit	7	6	5	4	3	2	1	0
Val	PD1	GAIN12	GAIN11	GAIN10	SRB2	MUX12	MUX11	MUX10

PD1		Power Down
		0	Normal (default)
		1	Off

Bits[6:4]	PGA Gain
		000 = 1
		001 = 2
		010 = 4
		011 = 6
		100 = 8
		101 = 12
		110 = 24 (default)
		111 = n/a

Bit 3		Source, reference bias channel
		0 Open (off) (default)
		1 Closed (on)

Bits [2:0]	Channel Input
		000 Normal electorde input
		001 Input shorted
		010 Used with BIAS_MEAS
		011 MVDD for supply measurement
		100 Temp sensor
		101 Test signal
		110 BIAS_DRP (pos electrode is the driver)
		111 BIAS_DRN (neg electrode is the driver)
Test value: 00000001 -> 0x01
*/
#define CHNSET_TEST_MODE 0x01

#define CONFIG3 0x03
#define CONFIG3_TEST_MODE 0xE0

#define false 0
#define true 1
#define boolean unsigned int
#define BLOCK_SIZE BYTES_PER_SAMPLE*NUM_CHAN
#define debug_printf(fmt, ...) \
do { if (DEBUG) fprintf(stderr, "%s:%d:%s(): " fmt, __FILE__, \
                        __LINE__, __func__, __VA_ARGS__); } while (0)

extern boolean gAppExiting;
#endif
