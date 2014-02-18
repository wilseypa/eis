default:
	gcc -g -c main.c Allocator.c ADS.c Preprocessor.c Processor.c -I/usr/include/glib-2.0/ -I/usr/lib/arm-linux-gnueabihf/glib-2.0/include/ -DDEBUG
	gcc main.o Allocator.o ADS.o Preprocessor.o Processor.o -o eis_proc.out -lglib-2.0 -lpthread -lbcm2835 -lfftw3 -lm -lwiringPi

all:
#	gcc -g -c main.c Allocator.c ADS.c Preprocessor.c Processor.c -I/usr/include/glib-2.0/ -I/usr/lib/arm-linux-gnueabihf/glib-2.0/include/ -I/usr/local/include/  
	gcc -g -c main.c Allocator.c ADS.c Preprocessor.c Processor.c -I/usr/include/glib-2.0/ -I/usr/lib/arm-linux-gnueabihf/glib-2.0/include/
	gcc main.o Allocator.o ADS.o Preprocessor.o Processor.o -o eis_proc.out -lglib-2.0 -lpthread -lbcm2835 -lfftw3 -lm -lwiringPi

clean:
	rm *.o
#test_client:
#	gcc -g -c main.c Allocator.c TestClient.c -I/usr/include/glib-2.0/ -I/usr/lib/arm-linux-gnueabihf/glib-2.0/include/ -DTEST_CLIENT -DDEBUG
#	gcc main.o Allocator.o TestClient.o -o test.out -lglib-2.0 -lpthread

