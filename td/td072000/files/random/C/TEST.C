
#include <stdio.h>

#include "random.c"

#define RANGE   2000
#define COUNT   2000

#define NC      20

#define XX      79
#define YY      20

void main()
{
  int T=GetTickCount();

  int a[RANGE];
  memset(a,0,sizeof(a));

  for (int i=0; i<RANGE*COUNT; i++)
    a[rndW(RANGE)]++;

  int max_a=0;
  for (int i=0; i<RANGE; i++)
    if (a[i]>max_a) max_a=a[i];

  int b[COUNT*NC];
  memset(b,0,sizeof(b));

  for (int i=0; i<RANGE; i++)
  {
    if (a[i]>=COUNT*NC)
    {
      printf("ERROR 1\n");
      exit(0);
    }
    b[a[i]]++;
  }

  int max_b=0;
  for (int i=0; i<COUNT*NC; i++)
    if (b[i]>max_b) max_b=b[i];

  int l=0;
  int r=COUNT*NC-1;
  while (b[l]==0) l++;
  while (b[r]==0) r--;
  int c=(l+r)/2;

  printf("a [0..%i-1]\n",RANGE);
  for (int i=0; i<RANGE; i++)
    printf("%6i%c",a[i],(i%10)==9 ? '\n':' ');
  printf("\n");

  printf("b [%i..%i]\n",l,r);
  for (int i=l; i<=r; i++)
    printf("%6i%c",b[i],((i-l)%10)==9 ? '\n':' ');
  printf("\n");

  char s[YY+1][XX+1];

  memset(s,'ú',sizeof(s));
  for (int i=0; i<=YY; i++) s[i][XX]='\n';
  s[YY][0]=0;

  for (int i=0; i<RANGE; i++)
  {
    int ix = (float)i*(XX-1)/(RANGE-1);
    for (int j=0; j <= (float)a[ i ] *(YY-1)/max_a; j++)
      s[YY-1-j][ ix ]='þ';
  }

  printf("%s\n",s);

  memset(s,'ú',sizeof(s));
  for (int i=0; i<=YY; i++) s[i][XX]='\n';
  s[YY][0]=0;

  for (int i=l; i<=r; i++)
  {
    int ix = (float)(i-l)*(XX-1)/(r-l);
    if (b[ i ]!=0) s[YY-1][ ix ]='x';
    for (int j=0; j <= (float) b[ i ] *(YY-1)/max_b; j++)
      s[YY-1-j][ ix ]='þ';
  }

  printf("%s",s);

  printf("[%i.. l=%i c=%i r=%i ..%i-1]  RANGE=%i COUNT=%i\n",0,l,c,r,COUNT*2,RANGE,COUNT);
  printf("dl=%.2f%% dc=%.2f%% dr=%.2f%%\n",
    (float)(l-COUNT)*100/COUNT,
    (float)(c-COUNT)*100/COUNT,
    (float)(r-COUNT)*100/COUNT);

  T=GetTickCount()-T;

  printf("time=%.3f s\n",(float)T/1000);
}
