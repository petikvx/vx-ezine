
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#pragma hdrstop

#include "util.cpp"
#include "random.cpp"
#include "rndstr.cpp"

void main(int argc, char* argv[])
{
  if (argc!=2) return;

  printf("%s\n", host2real(argv[1]));
}
