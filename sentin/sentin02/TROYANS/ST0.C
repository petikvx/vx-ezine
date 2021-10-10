#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <process.h>
#include <stdlib.h>
#include <alloc.h>
#include <io.h>
#include <bios.h>

 /*
  * This program will save your hard disk's track zero data.  It is
  * specifically designed to provide a remedy against the the so-called
  * "Columbus day" virus. 
  *
  * This program may be freely copied. 
  *
  * Author:  John Clason, KZ1O [70441,2456] 
  *
  */

void error(int code)
{
    switch (code) {
	case 1:
	 fprintf(stderr, "Unable to allocate enough memory\n");
	break;
    case 2:
	fprintf(stderr, "Unable to create file A:TRACK.000\n");
	break;
    case 4:
	fprintf(stderr, "Unable to complete writing to floppy disk\n");
	break;
    default:
	fprintf(stderr, "Unknown error occurred: %d\n", code);
	break;
    }
    exit(code);
}

int main(void)
{
    char *buffer;

    unsigned cx, dx;
    int maxhead, maxsectors, h;
    int fd;
    unsigned bytes;

    printf("Saving hard disk track zero onto A:TRACK.000\n"
    "More public domain software from J. Clason [70441,2456]\n");

    _DL = 0x80;
    _AH = 8;
    geninterrupt(0x13);		/* get params */

    cx = _CX;
    dx = _DX;

    maxhead = dx >> 8;
    maxsectors = cx & 0x3f;

#ifndef ALLCYLINDER
    maxhead=0;
#endif

    buffer = calloc(bytes = (maxsectors * 512), 1);
    if (buffer == NULL)
	error(1);

    fd = _creat("a:track.000", 0);
    if (fd < 0)
	error(2);

    for (h = 0; h <= maxhead; h++) {
	biosdisk(2, 0x80, h, 0, 1, maxsectors, buffer);
	if (_write(fd, buffer, bytes) != bytes)
	    error(4);
    }
    close(fd);
    return 0;
}

