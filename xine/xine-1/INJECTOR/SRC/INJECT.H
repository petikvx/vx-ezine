
void inject(void);
void injectip(void);
void rawlog(void);
void flood(void);
void getarp(void);
void getarpto(void);
void synflood(void);

int dopkt(char *, int);

extern int ishooked;
extern void (*hookfun) (unsigned char *, int , struct netpacket *);
