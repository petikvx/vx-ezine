
/***************************************************************************

  Real Permutating Engine (RPME)
  version 1.00

  (x) 2000 Z0MBiE, z0mbie.cjb.net


  DISASSEMBLING ALGORITHM
  ~~~~~~~~~~~~~~~~~~~~~~~

  mark entrypoint as NEXT
  while (NEXT-marked opcode found)
  {
    find offset of the opcode marked as NEXT
    for (;;)
    {
      get opcode length
      mark opcode bytes as CODE (alredy analyzed)
      if opcode is JMP,CALL or JCC mark label it points to as NEXT
      if opcode is RET or JMP then break
      go to next opcode
      if opcode is alredy processed break
    }
  }

  ASSEMBLING ALGORITHM
  ~~~~~~~~~~~~~~~~~~~~

  while (there is commands)
  {
    take random command, which is not stored yet
    for (;;)
    {
      select random place in output buffer
      store current command to output buffer
      go to next command
      if command is alredy stored, link with jmp and break
    }
  }

 ***************************************************************************/

void id1() { __emit__( 0xEB,0x02,0xFF,1 ); }

DWORD pascal engine(
        BYTE    ibuf[],         // input buffer
        DWORD   isize,          // size of input buffer
        DWORD   ientry,         // entrypoint, relative
        BYTE    obuf[],         // output buffer
        DWORD   osize,          // max size of output buffer
        DWORD*  poentry,        // ptr to entrypoint, relative. (=0 if NULL)
        DWORD   ofiller,        // outbuf filler byte, -1=transparent
        DWORD   extrelfix,   // DWORD to be added to external relocations (*)
        DWORD   jmprob,         // jmp-probablity, 0=no jmps
        DWORD   rnd(DWORD),          // routine: rnd
        void    pascal user_mutate(hooy*,DWORD(*)(DWORD),BYTE*(*)(DWORD)),
                                      // routine: mutate list
        DWORD   user_disasm(BYTE*),  // routine: disassemble
        BYTE*   user_malloc(DWORD)   // routine: malloc
       )

 // (*) extrelfix -- means some delta offset.
 // If you will execute 'obuf' at the address of the 'xxxx', you should
 // specify extrelfix=(offset xxxx - offset obuf)
 // If you will execute 'obuf' at its current location, extrelfix=0.

{
  hooy* root = NULL;            // root of instruction list

/* DISASSEMBLE */
#ifdef DEBUG_PRINTF
  printf("■ DISASSEMBLING\n");
#endif

  BYTE* imap = (BYTE*)user_malloc(isize);   // allocate imap array
  if (!imap) return ERR_NOMEMORY;
  for (DWORD i=0; i<isize; i++)
    imap[i]=C_NONE;  // clear imap

  imap[ientry] = C_NEXT;        // mark entrypoint(s)

  for (hooy**h = &root;;)              // main disasm cycle
  {
    DWORD ip;                           // current address (relative)
    for (ip=0; ip<isize; ip++)          // search for C_NEXT
      if (imap[ip]==C_NEXT)
        break;
    if (imap[ip]!=C_NEXT) break;        // break if not found
    for (;;)                            // disasm cycle -- until RET found
    {
      DWORD len=user_disasm(&ibuf[ip]);      // get instruction length
      if (len>=MAXCMDLEN)               // check error (len=-1,len>MAXCMDLEN)
        return ERR_DISASM;
      for (DWORD i=0; i<len; i++) imap[ip+i]=C_CODE; // mark as code
      // analyze instruction
      DWORD nxt=ip+len;                 // default nxt-entry
      DWORD rel=NONE;                   // default jxx-entry
      BYTE  o=ibuf[ip];                 // opcode, 1 byte
      WORD  w=*(WORD*)&ibuf[ip];        // opcode, 2 bytes
      DWORD b=ip+len+(char)ibuf[ip+len-1];  // rel.arg, VA, 1-byte
      DWORD d=ip+len+*(long*)&ibuf[ip+len-4]; // ..., 4-byte
      if (((o&0xF0)==0x70)||((o&0xFC)==0xE0)) rel=b; // jcc,jcxz,loop/z/nz
      if ((w&0xF0FF)==0x800F) rel=d;    // jcc near
      if (o==0xE8) rel=d;               // call
      if (o==0xEB) { rel=b; nxt=NONE; };// jmp short
      if (o==0xE9) { rel=d; nxt=NONE; };// jmp
      if (((o&0xF6)==0xC2)||(o==0xCF)||((w&0x38FF)==0x20FF))
        nxt=NONE; // ret/ret#/retf/retf#/iret/jmp modrm
      if (rel<isize)                    // in range?
        if (imap[rel]==C_NONE)          // if not processed yet
          imap[rel]=C_NEXT;             // mark as C_NEXT
      // add instruction into list
      hooy* h0 = *h;
      if (*h!=NULL) h=&(*h)->next;
      *h = (hooy*)user_malloc(sizeof(hooy)); // allocate entry
      if (!*h) return ERR_NOMEMORY;
      (*h)->ofs=&ibuf[ip];
      if (h0) if (!h0->nxt) h0->nxt = (hooy*)(*h)->ofs;
      for (DWORD i=0; i<len; i++)
        (*h)->cmd[i]=(*h)->ofs[i];
      (*h)->len=len;
      (*h)->flags=0;
      if (*h==root) (*h)->flags|=CM_XREF;       // mark entrypoint as XREF-ed
      (*h)->rel=NULL;
      if (rel!=NONE)
      {
        (*h)->flags|=CM_HAVEREL|CM_EXTREL;
        (*h)->rel=(hooy*)&ibuf[rel];
      };
      if (nxt==NONE) (*h)->flags|=CM_STOP;
      (*h)->nxt=NULL;
      (*h)->next=NULL;

      if (rel<isize)                    // range check
      {
        if (imap[rel]==C_NONE)          // if not processed yet
          imap[rel]=C_NEXT;             // mark as C_NEXT
      }

      // continue disasm cycle
      ip=nxt;                           // go to next instruction
      if (ip>=isize) break;             // NONE/out of range?
      if (imap[ip]==C_CODE)
      {
        (*h)->nxt=(hooy*)&ibuf[ip];
        break;      // break if alredy code
      }

    } // cycle until RET found
  } // main disasm cycle

#ifdef DEBUG_PRINTF
  printf("■ PROCESSING LIST, MARKING XREFs\n");
#endif

#ifdef FASTHOOY

// здесь возник трабл следующего содержания:
// для пост-обработки списка нужен был цикл для каждой команды и в нем (цикле)
// еще такой же цикл. То есть порядка N*N*a+N*b операций для N команд.
// При ~5000 команд имеем ~25 лимонов итераций. При 20 командах во 2м цикле
// и двух тактах на одну команду и частоте проца в 100 MHz в рантайме имеем
// ~10 теоретических секунд. А на самом деле получается ~5 минут.
// Чтобы избежать подобной хуйни генерим таблицу поинтеров на записи списка
// для каждого возможного адреса.

  hooy** hooybyoffs=(hooy**)user_malloc(isize*4);
  if (!hooybyoffs) return ERR_NOMEMORY;
  for (DWORD i=0; i<isize; i++) hooybyoffs[i]=0;
  for (hooy* h=root; h; h=h->next)      // for each entry
  {
    DWORD d = (DWORD)h->ofs - (DWORD)ibuf;
    if (d<isize)
      hooybyoffs[d]=h;
  }

  for (hooy* h=root; h; h=h->next)      // for each entry
  {
    if (h->flags&CM_STOP) h->nxt=NULL;
#ifdef DEBUG_DUMPLIST
    printf("(%02X)  nxt=%08X rel=%08X --> ",h->cmd[0],h->nxt,h->rel);
#endif

    DWORD d=(DWORD)h->nxt-(DWORD)ibuf;
    if (d<isize)
    {
      hooy* q=hooybyoffs[d];
      if (!q) return ERR_BADJMP;                // check error
      if ((DWORD)h->nxt==(DWORD)q->ofs)
        h->nxt=q;
    }

    d=(DWORD)h->rel-(DWORD)ibuf;
    if (d<isize)
    {
      hooy* q=hooybyoffs[d];
      if (!q) return ERR_BADJMP;                // check error
      if ((DWORD)h->rel==(DWORD)q->ofs)
      {
        h->flags&=~CM_EXTREL;           // clear CM_EXTREL
        q->flags|=CM_XREF;              // set XREF
        h->rel=q;                       // replace VA with hooy*
      }
    }

#ifdef DEBUG_DUMPLIST
    printf("%08X, %08X  (%02X)\n",h->nxt,h->rel,(h->nxt==NULL)?0xFF:h->nxt->cmd[0]);
#endif
  }

  user_malloc(-(long)(isize*4));        // free allocated buffer :-)

#else // not FASTHOOY

  for (hooy* h=root; h; h=h->next)      // for each entry
  {
    if (h->flags&CM_STOP) h->nxt=NULL;
#ifdef DEBUG_DUMPLIST
    printf("(%02X)  nxt=%08X rel=%08X --> ",h->cmd[0],h->nxt,h->rel);
#endif
    hooy*nxt=h->nxt;
    hooy*rel=h->rel;
    for (hooy* q=root; q; q=q->next)    // for each entry
    {
      if ((DWORD)h->nxt==(DWORD)q->ofs)
        nxt=q;
      if ((DWORD)h->rel==(DWORD)q->ofs)
      {
        h->flags&=~CM_EXTREL;           // clear CM_EXTREL
        q->flags|=CM_XREF;              // set XREF
        rel=q;                          // replace VA with hooy*
      }
    }
    h->nxt=nxt;
    h->rel=rel;

#ifdef DEBUG_DUMPLIST
    printf("%08X, %08X  (%02X)\n",h->nxt,h->rel,(h->nxt==NULL)?0xFF:h->nxt->cmd[0]);
#endif
  }

#endif // FASTHOOY

#ifdef DEBUG_DUMPLIST
  printf("■ DUMP LIST\n");
  int i=0;
  for (hooy* h=root; h; h=h->next, i++)      // for each entry
    (DWORD)h->ofs=i;
  for (hooy* h=root; h; h=h->next)      // for each entry
  {
    printf("(a) %2i.  nxt=%2i rel=%2i next=%2i  HAVEREL=%i EXTREL=%i XREF=%i STOP=%i   ",
      h->ofs,
      ((DWORD)h->nxt ==NULL)?-1:(DWORD)h->nxt->ofs,
      ((DWORD)h->rel ==NULL)?-1:(DWORD)h->rel->ofs,
      ((DWORD)h->next==NULL)?-1:(DWORD)h->next->ofs,
      (h->flags&CM_HAVEREL)!=0,
      (h->flags&CM_EXTREL)!=0,
      (h->flags&CM_XREF)!=0,
      (h->flags&CM_STOP)!=0
     );
    for (int i=0; i<h->len;  i++)
      printf("%02X ",h->cmd[i]);
    printf("\n");
  }
#endif

#ifdef DEBUG_PRINTF
  printf("■ EXPANDING SHORT-JCCs\n");
#endif

  for (hooy* h=root; h; h=h->next)      // for each entry
  {
    BYTE b=h->cmd[0];
    if ((b&0xF0)==0x70)                 // short jcc?
    {
      h->cmd[0]=0x0F;
      h->cmd[1]=0xF0^b;                 // -> near (70-->80)
      h->len=6;
    }
    if (b==0xEB)                        // short jmp?
    {
      h->cmd[0]=0xE9;                   // -> near
      h->len=5;
    }
    if ((b&0xFC)==0xE0)                 // loop/z/nz,jcxz?
    {
      if (b==0xE2)                      // loop
      {
        h->cmd[0]=0x49;                 // dec ecx
        *(WORD*)&h->cmd[1]=0x850F;      // jnz near ...
        h->len=1+6;
      }
      else
      if (b==0xE3)                      // jcxz
      {
        *(WORD*)&h->cmd[0]=0xC909;      // or ecx, ecx
        *(WORD*)&h->cmd[2]=0x840F;      // jz near ...
        h->len=2+6;
      }
      else
        return ERR_NOTPROGRAMMED;
    }
  }

#ifdef DEBUG_PRINTF
  printf("■ REMOVING JMPs\n");
#endif

  for (int npass=0; npass<2; npass++)
  for (hooy* h=root; h; h=h->next)      // for each entry
    if (h->cmd[0]==0xE9)                // if jmp,
    if (!(h->flags&CM_EXTREL))          //   but only within input buffer
      if (npass==0)
      {
        for (hooy* q=root; q; q=q->next)  // for each entry
        {
          if (q->nxt==h) q->nxt=h->rel;
          if (q->rel==h) q->rel=h->rel;
        }
      } else { //npass
        for (hooy* q=root; q; q=q->next)  // for each entry
          if (q->next==h) q->next=h->next;
      } //npass

/* MUTATING LIST */

  if (user_mutate) user_mutate(root,rnd,user_malloc);

#ifdef DEBUG_DUMPLIST
  printf("■ DUMP LIST\n");
  i=0;
  for (hooy* h=root; h; h=h->next, i++)      // for each entry
    (DWORD)h->ofs=i;
  for (hooy* h=root; h; h=h->next)      // for each entry
  {
    printf("(b) %2i.  nxt=%2i rel=%2i next=%2i  HAVEREL=%i EXTREL=%i XREF=%i STOP=%i   ",
      h->ofs,
      ((DWORD)h->nxt ==NULL)?-1:(DWORD)h->nxt->ofs,
      ((DWORD)h->rel ==NULL)?-1:(DWORD)h->rel->ofs,
      ((DWORD)h->next==NULL)?-1:(DWORD)h->next->ofs,
      (h->flags&CM_HAVEREL)!=0,
      (h->flags&CM_EXTREL)!=0,
      (h->flags&CM_XREF)!=0,
      (h->flags&CM_STOP)!=0
     );
    for (int i=0; i<h->len;  i++)
      printf("%02X ",h->cmd[i]);
    printf("\n");
  }
#endif

#ifdef DEBUG_PRINTF
  printf("■ ASSEMBLING\n");
#endif

  DWORD ip=0;                           // select entrypoint
  if (poentry)
    *poentry=ip=SPACE_START+rnd(osize-SPACE_START-SPACE_END);

#ifdef DEBUG_PRINTF
  printf("entrypoint at %08X\n", ip);
#endif

  if (ofiller!=NONE)
    for (DWORD i=0; i<osize; i++)         // fill output buffer
      obuf[i]=ofiller;

  BYTE* omap = (BYTE*)user_malloc(osize);
  if (!omap) return ERR_NOMEMORY;
  for (DWORD i=0; i<osize; i++)
    omap[i]=0;

  for (hooy* q=root; q; q=q->next)      // for each entry
  if (!(q->flags&CM_ASSEMBLED))         // if not assembled yet
  {
    for (hooy* h=q; h; h=h->nxt)          // for nxt-linked entries
    {

//    omap[ip]=1;
//    obuf[ip++]=0x90;

      int i;                                  // calculate space available
      for (i=0; (i<SPACE_BETWEEN)&&(ip+i<osize-SPACE_END); i++)
        if (omap[ip+i])
          break;
      if ( (i<SPACE_BETWEEN) || ( (jmprob!=0)&&(rnd(jmprob)==0) ) )
      {
        DWORD newip;
        int ntry=0;
        do {
          if (ntry++>NTRY) return ERR_SMALLBUF;
//if (ntry==1) newip=ip+2; else
          newip=SPACE_START+rnd(osize-SPACE_START-SPACE_END);
          for (i=0; (i<SPACE_BETWEEN*2)&&(newip+i<osize-SPACE_END); i++)
            if (omap[newip+i])
              break;
        } while (i<SPACE_BETWEEN*2);
        newip+=SPACE_BETWEEN;
        omap[ip]=1;
        obuf[ip++]=0xE9;                // link with jmp
        *(DWORD*)&omap[ip]=0x01010101;
        ip+=4;
        *(DWORD*)&obuf[ip-4]=newip-ip;
        ip=newip;
#ifdef DEBUG_PRINTF
        printf("new entrypoint at %08X\n", ip);
#endif
      };

      if (h->flags&CM_ASSEMBLED)          // alredy assembled?
      {
        omap[ip]=1;
        obuf[ip++]=0xE9;                  // link with jmp
        *(DWORD*)&omap[ip]=0x01010101;
        ip+=4;
        *(DWORD*)&obuf[ip-4]=(DWORD)h->ofs-(DWORD)&obuf[ip];
        break;                            // break
      }
      else                                // not assembled yet
      {
        h->flags|=CM_ASSEMBLED;
        for (DWORD i=0; i<h->len; i++)
          omap[ip+i]=1;
        h->ofs=&obuf[ip];
        for (DWORD i=0; i<h->len; i++)
          h->ofs[i]=h->cmd[i];
        ip+=h->len;
      }

      if (h->flags&CM_STOP) break;        // RET/JMP-alike
    }

  }

#ifdef DEBUG_PRINTF
  printf("■ LINKING\n");
#endif

  for (hooy* h=root; h; h=h->next)      // for each entry
    if (h->flags&CM_HAVEREL)            // have relative argument?
    {
      *(DWORD*)&h->ofs[h->len-4]=
        (h->flags&CM_EXTREL ? ((DWORD)h->rel+extrelfix) : (DWORD)h->rel->ofs)
        - (DWORD)h->ofs - h->len;
    }

#ifdef DEBUG_PRINTF
  printf("■ WRITING FILES\n");
#endif

#ifdef DEBUG_DUMP_FILES
/* dump files */

  FILE*f=fopen("_imap","wb");
  fwrite(imap, 1,isize, f);
  fclose(f);
  for (DWORD i=0; i<isize; i++)
    if (imap[i]!=C_NONE) imap[i]=ibuf[i]; else imap[i]=0xCC;
  f=fopen("_ibuf","wb");
  fwrite(imap, 1,isize, f);
  fclose(f);
  f=fopen("_obuf","wb");
  fwrite(obuf, 1,osize, f);
  fclose(f);
#endif

#ifdef DEBUG_PRINTF
  printf("■ EXITING\n");
#endif

  return ERR_SUCCESS;
} // engine

void id2() { __emit__( 0xEB,0x02,0xFF,2 ); }
