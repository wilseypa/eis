#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/fs.h>
#include <asm/uaccess.h>

#include "hello.h"
#include "bcm2835.c"
#define SUCCESS 0
#define DEVICE_NAME "my_device"
#define BUF_LEN 80

static int deviceOpen = 0;

static char message[BUF_LEN];

static char *messagePtr;

static ssize_t device_read(struct file *file,
			   char __user * buffer,
			   size_t length,
			   loff_t * offset)
{
	int bytes_read = 0;

	if (*messagePtr == 0)
	{
		return 0; // end of message
	}

	// Put data in the buffer
	while (length && *messagePtr) {
		put_user(*(messagePtr++), buffer++);
		length--;
		bytes_read++;
	}

	return bytes_read;
}

static ssize_t device_write (struct file *file,
			     const char __user * buffer,
			     size_t length,
			     loff_t * offset)
{
	int i;
	
	// Read the user buffer into our buffer
	for (i = 0; i < length && i < BUF_LEN; i++)
	{
		get_user(message[i], buffer + i);
	}

	messagePtr = message;

	return i;
}

static long device_ioctl( struct file *file,
		  unsigned int ioctl_num,
		  unsigned long ioctl_param)
{
	int i;
	char *temp;
	char ch;

	switch (ioctl_num) {

	case IOCTL_SET_MSG:
		temp = (char *)ioctl_param;

		get_user(ch, temp);
		for (i = 0; ch && i < BUF_LEN; i++, temp++) {
			get_user(ch,temp);

		}
		device_write(file, (char *)ioctl_param, i, 0);
		break;
	case IOCTL_GET_MSG:
		i = device_read(file, (char *)ioctl_param, 99, 0);
		put_user('\0', (char *)ioctl_param + i);
		break;
	case IOCTL_GET_NTH_BYTE:
		return message[ioctl_param];
		break;
	case IOCTL_TOGGLE_LED:
		bcm2835_gpio_write(14,HIGH);
		msleep(500);
		bcm2835_gpio_write(14,LOW);
		msleep(500);
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

	messagePtr = message;
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

	bcm2835_gpio_fsel(14,BCM2835_GPIO_FSEL_OUTP);

	printk("Loading finished, mknod %s c %d 0\n", DEVICE_FILE_NAME, MAJOR_NUM);

	return 0;
}

void cleanup_module()
{
	unregister_chrdev(MAJOR_NUM, DEVICE_NAME);

	bcm2835_close();
	printk("We're done\n");

}

MODULE_LICENSE("GPL");
