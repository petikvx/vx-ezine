
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#pragma hdrstop

#include "pswhash.cpp"

void main(int argc, char* argv[])
{
  if (argc!=2) return;

  printf("#define PSW_HASH        0x%08X        // %s\n",
     pswtohash(argv[1]), argv[1]);
}
