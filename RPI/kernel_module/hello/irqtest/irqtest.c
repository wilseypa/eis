/*
	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***
	***		Raspberry Pi gpio hardware interrupt test.												***
	***		This is the ISR code.  The user code is in userMain.c									***
	***																								***
	***																								***
	***		by Jay F. Hamlin , February 2013.    GPL licensed										***
	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	***	
*/
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/irq.h>
#include <linux/interrupt.h>
#include <linux/gpio.h>
#include <linux/fs.h>
#include <linux/debugfs.h>
#include <linux/mm.h>  		/* mmap related stuff */

#include <linux/slab.h>  	/* kmalloc / kfree */

#include "irqtest.h"  

struct dentry  *irqfileD;

struct mmap_info {
	irq_user_info *usrData;		/* the data */
	int reference;       		/* how many times it is mmapped */  	
};

irq_user_info	*myUsrData;
int		 irq_number;

static int fops_mmap(struct file *filp, struct vm_area_struct *vma);
static int fops_open(struct inode *inode, struct file *filp);
static int fops_close(struct inode *inode, struct file *filp);

static void mmap_open(struct vm_area_struct *vma);
static void mmap_close(struct vm_area_struct *vma);
static int mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf);

static const struct file_operations my_fops = {
	.open = fops_open,
	.mmap = fops_mmap,
	.release = fops_close,
};

static struct vm_operations_struct mmap_vm_ops = {
	.open =     mmap_open,
	.close =    mmap_close,
	.fault =   mmap_fault,
};

/*
 * myInterrupt service routine:
 *********************************************************************************
 */

static irqreturn_t gpio_rising_interrupt(int irq, void* dev_id) {
	int	i;
	if(myUsrData) {
		gpio_set_value(kREDled,(myUsrData->irqCounter&0x00000001));	// toggle led
	
		i= (myUsrData->irqCounter&0x0003ff);			// wraps at 1023
		myUsrData->buffer[i]= myUsrData->irqCounter++;	// write something (anything) to the buffer.
	}

	return(IRQ_HANDLED);
}

static int __init mymodule_init(void) {

	myUsrData = 0;
	
	irq_number = gpio_to_irq(kSwitch1);
	
	if ( request_irq(irq_number, gpio_rising_interrupt, IRQF_TRIGGER_RISING|IRQF_ONESHOT, "gpio_rising", NULL) ) {
		printk(KERN_ERR "GPIO_RISING: trouble requesting IRQ %d",irq_number);
		return(-EIO);
	} else {
		printk(KERN_ERR "GPIO_RISING: requesting IRQ %d-> fine\n",irq_number);

		// create the debugfs file used to communicate buffer address to user space
		irqfileD = debugfs_create_file("irqtest_mmap", 0644, NULL, NULL, &my_fops);

		if(myUsrData) myUsrData->irqCounter=0;

		gpio_direction_output(kREDled,0);
	}
	
	return 0;
}

static void __exit mymodule_exit(void) {

	debugfs_remove(irqfileD);

	free_irq(irq_number, NULL);
	printk ("gpio_reset module unloaded\n");
	return;
}

/* keep track of how many times it is mmapped */
static void mmap_open(struct vm_area_struct *vma)
{
	struct mmap_info *info = (struct mmap_info *)vma->vm_private_data;
	info->reference++;
}

static void mmap_close(struct vm_area_struct *vma)
{
	struct mmap_info *info = (struct mmap_info *)vma->vm_private_data;
	info->reference--;
}

/* fault is called the first time a memory area is accessed which is not in memory,
 * it does the actual mapping between kernel and user space memory
 */
static int mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
{
	struct page *page;
 	struct mmap_info *info = (struct mmap_info *)vma->vm_private_data;
	
	printk("mmap_fault called info=0x%8X\n",(unsigned int)info);

	/* the data is in vma->vm_private_data */
	if (!info) {
		printk("mmap_fault return VM_FAULT_OOM\n");
		return VM_FAULT_OOM;	
	}
	if (!info->usrData) {
		printk("mmap_fault return VM_FAULT_OOM\n");
		return VM_FAULT_OOM;	
	}

	page = virt_to_page(info->usrData);

	if (!page) {
		printk("mmap_fault return VM_FAULT_SIGBUS\n");
		return VM_FAULT_SIGBUS;
	}

	get_page(page);
	vmf->page = page;

	printk("mmap_fault return 0\n");
	return 0;
}


static int fops_mmap(struct file *filp, struct vm_area_struct *vma)
{
	printk("fops_mmap called\n");

	vma->vm_ops = &mmap_vm_ops;
	vma->vm_flags |= VM_RESERVED;
	/* assign the file private data to the vm private data */
	vma->vm_private_data = filp->private_data;
	mmap_open(vma);
	return 0;
}

static int fops_close(struct inode *inode, struct file *filp)
{
/*		We don't want to release our data here because the user code is going to need it.	*/

//	struct mmap_info *info = filp->private_data;
	printk("fops_close called\n");
//	free_page((unsigned long)info->usrData);
//   kfree((const void *)info);
//	filp->private_data = NULL;

	return 0;
}

static int fops_open(struct inode *inode, struct file *filp)
{
	struct mmap_info *info = kmalloc(sizeof(struct mmap_info), GFP_KERNEL);
	
	if (info) {
		info->usrData = (irq_user_info *)get_zeroed_page(GFP_KERNEL);	/* obviously, if usrData were large than 1 page we would have a problem here */
																		/* note: pages are 4096 bytes on the rPi				*/
		printk("fops_open called buffer=0x%8X\n",(unsigned int)info->usrData);
		myUsrData = info->usrData;  // set the global for our ISR
	}

	/* assign this info struct to the file */
	filp->private_data = info;
	inode->i_private = info;

	return 0;
}

module_init(mymodule_init);
module_exit(mymodule_exit);

MODULE_LICENSE("GPL");

/*
------------ Makefile ---------------------------------------------------------------
###
### make sure the kernel gets recompiled with 'CONFIG_DEBUG_FS=y' to enable debugfs.
###
### Before having access to the debugfs it has to be mounted with the following command.
### 'mount -t debugfs none /sys/kernel/debug'
###

obj-m=irqtest.o
PWD=$(shell pwd)
KDIR=~/rpi/linux-rpi-3.2.27/

all: driver user

driver: irqtest.c irqtest.h
	make -C $(KDIR) ARCH=arm CROSS_COMPILE=${CCPREFIX} M=$(PWD) modules

user: userMain.c irqtest.h
	$(CCPREFIX)gcc -o $(PWD)/userisr $(PWD)/userMain.c

clean:
	make -C $(KDIR) ARCH=arm CROSS_COMPILE=${CCPREFIX} M=$(PWD) clean



*/


