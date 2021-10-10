#include <stdio.h>
#include <sys/io.h>
#include <unistd.h>

// lp settings
#define	BASE	0x378
#define	RANGE	8

int biton (int bit);
int bitoff ();
void usage(char *arg);

int main (int argc, char *argv[]) {
	int ret;
	if (argc<2) { usage(argv[0]); return 0; }
	// Attempt to open lp
	ret=ioperm(BASE,RANGE,1); 
	if (ret!=0) {
		printf("Error: Unable to open port\n");
		return 0;
	}	
		{
			int b=-1,d=-1,c;
			sscanf(argv[1],"%d",&b);	
			if(b<0) { usage(argv[0]); return 0; }
			if(b>255) { usage(argv[0]); return 0; }
			if (argc>2) {
				sscanf(argv[2],"%d",&d);
				if(d<0) { usage(argv[0]); return 0; }
			}
			// Switch bit on
			biton(b);
			if (d>0) sleep(d);
			else if (d==0) return 0;
			else c=getchar();
			// Switch bit off
			bitoff(); 
		}
	// Attempt to close lp
	ret=ioperm(BASE,RANGE,0);
	if (ret!=0) {
		printf("Error: Unable to close port\n");
		return 0;
	}
	return 0;
}

int biton (int bit) {
	outb(bit,BASE);
}
int bitoff () {
	outb(0,BASE);
}
void usage(char *arg) {
	printf("Usage: %s 0-255 [delay]\n", arg);
}
