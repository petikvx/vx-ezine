#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <process.h>
#include <stdlib.h>
#include <alloc.h>
#include <io.h>
#include <bios.h>

 /*
  * This program will restore your hard disk's track zero data.  It
  * is specifically designed to provide a remedy against the the so-called
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
	fprintf(stderr, "Unable to open file A:TRACK.000\n");
	break;
    case 4:
	fprintf(stderr, "Unable to complete reading floppy disk\n");
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

    printf("Restoring hard disk track zero from A:TRACK.000\n"
    "More public domain software from John Clason [70441,2456]\n");

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

    fd = _open("a:track.000", 0);
    if (fd < 0)
	error(2);

    for (h = 0; h <= maxhead; h++) {
	if (_read(fd, buffer, bytes) != bytes)
	    error(4);
	biosdisk(3, 0x80, h, 0, 1, maxsectors, buffer);
    }
    close(fd);
    return 0;
}
