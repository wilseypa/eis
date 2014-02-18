
// wiringPi pin numbers are like Arduino....
#define	kGREENled	27		// gpio 27
#define	kREDled		22		// gpio 22
#define	kSwitch1	23		// gpio 23
#define	kSwitch2	24		// gpio 24

// size of my buffer in 16 bit words
#define	kIRQbuffSize	1024

typedef struct irq_user_info {
	unsigned short buffer[kIRQbuffSize]; /* the data */
	int irqCounter;
} irq_user_info;

