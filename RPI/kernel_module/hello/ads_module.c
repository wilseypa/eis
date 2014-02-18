#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/gpio.h>
#include <linux/irq.h>
#include <linux/interrupt.h>
#include <linux/sched.h>
#include <linux/proc_fs.h>
#include <linux/fs.h>
#include <asm/uaccess.h>

#include "ads_module.h"
#include "bcm2835.c"
#include "Globals.h"

#define SUCCESS 0
#define DEVICE_NAME "my_device"

static int deviceOpen = 0;
int irq_number = 0;
unsigned int intCount = 0;
static unsigned char rbuf[27];
static unsigned int data_ready = 0;

static ssize_t device_read(struct file *file,
			   char __user * buffer,
			   size_t length,
			   loff_t * offset)
{
	int bytes_read = 0;

	return bytes_read;
}

static ssize_t device_write (struct file *file,
			     const char __user * buffer,
			     size_t length,
			     loff_t * offset)
{
	return 0;
}

static void set_config_registers(struct ADS_CONFIG *userConfig)
{
	uint8_t data;
	uint8_t ctr;

	struct ADS_CONFIG config;

	int rc = copy_from_user(&config, (void *)userConfig, sizeof(struct ADS_CONFIG));	

	if (rc < 0) {
		printk("Failed to copy user config\n");
		return;
	}

	/* Stop all conversions */
	bcm2835_spi_transfer(STOP);
	msleep(1);	

	/* Disable continuous conversion mode */
	bcm2835_spi_transfer(SDATAC);
	msleep(1);

	/* Read from register CONFIG1 */
	bcm2835_spi_transfer(RREG_ADDR | CONFIG1);
	msleep(1);

	/* Read one register */
	bcm2835_spi_transfer(RREG_NUMR);
	msleep(1);

	/* read the data from the bus */
	data = bcm2835_spi_transfer(DONT_CARE);
	msleep(1);
	/* On startup, CONFIG1 should equal MAGIC_VALUE;
	   if we read that value, our comms are good */
	if (data != MAGIC_VALUE)
	{
		printk("Sanity check failed! Read: 0x%x\n",data);
	}
	else
	{
		printk("%s","Got magic value!!!\n");
	}
	// Write CONFIG1
	bcm2835_spi_transfer(WREG_ADDR | CONFIG1);
	msleep(1);

	bcm2835_spi_transfer(WREG_NUMR);
	msleep(1);

	bcm2835_spi_transfer(config.speed);
	msleep(1);

	// Write CONFIG2
	bcm2835_spi_transfer(WREG_ADDR | CONFIG2);
	msleep(1);

	bcm2835_spi_transfer(WREG_NUMR);
	msleep(1);

	bcm2835_spi_transfer(config.config);
	msleep(1);

	// Write CHnSet
	bcm2835_spi_transfer(WREG_ADDR | CHNSET_LOW);
	msleep(1);

	bcm2835_spi_transfer(WREG_NUMR | 0x07);
	msleep(1);

	for ( ctr = 0; ctr < 8; ctr++)	
	{
		bcm2835_spi_transfer(config.channel); // normal channels
		msleep(1);
	}

	bcm2835_spi_transfer(RDATAC);
	msleep(1);

	/* Stop all conversions */
	bcm2835_spi_transfer(START);
}

DECLARE_WAIT_QUEUE_HEAD(WaitQ);

static int send_ads_data(unsigned char *buffer)
{
	int rc;
	while (!data_ready) {
		int i, is_sig = 0;

		wait_event_interruptible(WaitQ, data_ready);

		for (i = 0; i < _NSIG_WORDS && !is_sig; i++) {
			is_sig = current->pending.signal.sig[i] & ~current->blocked.sig[i];
		}
		if (is_sig) {
			module_put(THIS_MODULE);
			return -EINTR;
		}	
	}

	data_ready = 0;
	rc = copy_to_user(buffer,rbuf,27);

	return SUCCESS;
}

static long device_ioctl( struct file *file,
		  unsigned int ioctl_num,
		  unsigned long ioctl_param)
{

	switch (ioctl_num) {

	case IOCTL_SET_ADS_CONFIG:
		set_config_registers((struct ADS_CONFIG *)ioctl_param);
		break;		
	case IOCTL_GET_INT_COUNT:
		return intCount;
		break;
	case IOCTL_SEND_DATA:
		send_ads_data((unsigned char *)ioctl_param);
		break;
	}

	return SUCCESS;	
}

static int device_open(struct inode *inode,
		       struct file *file)
{
	if (deviceOpen) {
		return -EBUSY;
	}

	deviceOpen++;

	try_module_get(THIS_MODULE);
	
	return SUCCESS;
}

static int device_release(struct inode *inode,
			  struct file *file)
{
	deviceOpen--;

	module_put(THIS_MODULE);
	return SUCCESS;
}

struct file_operations fops = {
	.read = device_read,
	.write = device_write,
	.unlocked_ioctl = device_ioctl,
	.open = device_open,
	.release = device_release,
};

static irqreturn_t gpio_falling_interrupt(int irq, void *dev_id) {
	int ctr = 0;

	for (ctr = 0; ctr < 27; ctr++) {
		rbuf[ctr] = bcm2835_spi_transfer(DONT_CARE);
	}

	data_ready = 1;

	wake_up(&WaitQ);


	return (IRQ_HANDLED);
}

int init_module()
{

	int ret;

	ret = register_chrdev(MAJOR_NUM, DEVICE_NAME, &fops);

	if (ret < 0) // error check
	{
		printk(KERN_ALERT "%s failed with %d\n",
			"Sorry, registering the character device ", ret);
		return ret;
	}

	bcm2835_init();

	// Enable SPI comms
	bcm2835_spi_begin();

	// Set the pins to be outputs
	bcm2835_gpio_fsel(CLKSEL, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(RESET, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(START_P, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(PWDN, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(31, BCM2835_GPIO_FSEL_OUTP);
	bcm2835_gpio_fsel(DRDY, BCM2835_GPIO_FSEL_INPT);

	// SPI config
    	bcm2835_spi_setBitOrder(BCM2835_SPI_BIT_ORDER_MSBFIRST);	// MSB is first
    	bcm2835_spi_setDataMode(BCM2835_SPI_MODE1);                   	// CPOL=0 CPHA=1
    	bcm2835_spi_setClockDivider(BCM2835_SPI_CLOCK_DIVIDER_16);     	// 16MHz
    	bcm2835_spi_chipSelect(BCM2835_SPI_CS_NONE);                  	// Control CS manually
    	bcm2835_spi_setChipSelectPolarity(BCM2835_SPI_CS0, LOW);    	// CS is enable low


	// Enable internal clock
    	bcm2835_gpio_write(CLKSEL, HIGH);
	bcm2835_gpio_write(31, LOW);
    	// Prevent chip from going into standby
	bcm2835_gpio_write(PWDN,HIGH);

    	// Prevent chip from reseting
	bcm2835_gpio_write(RESET, HIGH);

    	// Keep the start pin low, we will trigger via SPI
	bcm2835_gpio_write(START_P,LOW);

    	// Keep the SPI chip select tied low to enable the chip
	bcm2835_gpio_write(BCM2835_SPI_CS0,LOW);

	irq_number = gpio_to_irq(DRDY);

	if ( request_irq(irq_number, gpio_falling_interrupt, IRQF_TRIGGER_FALLING|IRQF_ONESHOT,
			"gpio_falling", NULL) ) {
		printk(KERN_ERR "Trouble requesting IRQ");
		return (-EIO);
	} 
	
	printk("Using IRQ %d\n",irq_number);
	printk("Loading finished, mknod %s c %d 0\n", DEVICE_FILE_NAME, MAJOR_NUM);

	return 0;
}

void cleanup_module()
{
	free_irq(irq_number, NULL);
	unregister_chrdev(MAJOR_NUM, DEVICE_NAME);

	// End the SPI sessions
	bcm2835_spi_end();
	bcm2835_close();

	printk("We're done\n");

}

MODULE_LICENSE("GPL");
