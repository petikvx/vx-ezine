
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#pragma hdrstop

#include "vlong.cpp"
#include "rsa.cpp"

void dump_vlong(char* s, const vlong &x)
{
  printf("%s (len=%i)\n",s,x.value->z);
  for (unsigned i=0; i<x.value->z; i++)
    printf("  %08X",x.value->a[i]);
  printf("\n");
}

void main()
{
  private_key key;

  printf("*create\n");
  // key length depends on lengths of the following random strings
  key.create("ier8yerknm4fff4yhy8",
             "34wec0-rtgvesrloter");

  dump_vlong("m",key.m);
  dump_vlong("e",key.e);
  dump_vlong("d",modinv( key.e, (key.p-(vlong)1)*(key.q-(vlong)1) ) );

  vlong x = from_str("z0mbie f0rever");
  dump_vlong("x==plain    ",x);
  printf("*encrypt\n");
  vlong y = key.encrypt(x);
  dump_vlong("y==encrypted",y);
  printf("*decrypt\n");
  vlong z = key.decrypt(y);
  dump_vlong("z==decrypted",z);

}
