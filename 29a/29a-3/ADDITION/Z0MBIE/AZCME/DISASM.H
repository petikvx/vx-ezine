
#define cf_is66         0x0001
#define cf_is67         0x0002
#define cf_isSEG        0x0004
#define cf_isREP        0x0008
#define cf_isLOCK       0x0010
#define cf_is0F         0x0020
#define cf_isMODRM      0x0040
#define cf_isSIB        0x0080
#define cf_isMEM        0x0100
#define cf_isDATA       0x0200
#define cf_isDATAREL    0x0400

#define ct_UNKNOWN      0
#define ct_JMP          1
#define ct_JCC          2
#define ct_CALL         3
#define ct_RET          4

typedef union datauion
  {
    word       w[3];
    byte       b[6];
  } dataunion;

typedef struct tcmdrec
  {
    word       flags;           // cf_xxxx
    word       type;            // ct_xxxx
    word       size;            // total cmd. size
    word       base;            // instruction offset (16-bit)
    byte       px_SEG;          // prefix: segment prefix
    byte       px_REP;          // prefix: repz/repnz
    byte       opcode;
    byte       modrm;
    byte       mod;
    byte       reg;
    byte       rm;
    byte       sib;
    word       memsize;
    byte       mem[4];
    word       datasize;

    dataunion   data;

    word       jmpptr;          // jmp/call ABSOLUTE pointer (+base), 16-bit
  } tcmdrec;

void dump(pchar cmd, word size)
  {
    printf("%W ",(word) cmd);
    for (; size>0; size--, cmd++)
      printf(" %B", (byte) (*cmd));
    printf("\n");
  }

#define getbyte(x)    { x = (byte)  (*cmd_ptr++);   };
#define getword(x)    { x = (word)  (*cmd_ptr+=1);  };
#define getdword(x)   { x = (dword) (*cmd_ptr+=2);  };

#define getnextbyte(x) { x = ((byte) (*cmd_ptr)); }

tcmdrec r;
pchar cmd_ptr;
word disasm_base;

void modrm_proc(void)
  {

    getbyte(r.modrm);

    r.mod = r.modrm >> 6;
    r.reg = (r.modrm >> 3) & 7;
    r.rm  = r.modrm  & 7;

    if ((r.flags & cf_is67) == 0)
    {
       // 16-bit MODR/M

      if (((r.mod == 0) && (r.rm == 6)) || (r.mod == 2)) r.memsize = 2;
      if (r.mod == 1) r.memsize = 1;

    }
    else
    {
       // 32-bit MODR/M

      if (((r.mod == 0) && (r.rm == 5)) || (r.mod == 2)) r.memsize = 4;
      if (r.mod == 1) r.memsize = 1;

      if (r.rm == 4)
        {
          r.flags |= cf_isSIB;
          getbyte(r.sib);
        };

    };

  }

void disasm(pchar cmd, tcmdrec far *rec)
  {
    byte b,nextbyte;
    int i;

    fillchar(&r, sizeof(tcmdrec), 0x00);

    r.base = (word) cmd;
    r.jmpptr = -1;

    cmd += disasm_base;
    cmd_ptr = cmd;

    // begin disasm

prefix:
    getbyte(b);

    if ((b==0x2E) ||
        (b==0x26) ||
        (b==0x3E) ||
        (b==0x36) ||
        (b==0x64) ||
        (b==0x65))
      {
        r.flags |= cf_isSEG;
        r.px_SEG = b;
        goto prefix;
      }

    if ((b==0xF2) ||
        (b==0xF3))
      {
        r.flags |= cf_isREP;
        r.px_REP = b;
        goto prefix;
      }

    switch(b)
      {
        case 0x66: r.flags |= cf_is66;
                   goto prefix;
        case 0x67: r.flags |= cf_is67;
                   goto prefix;
        case 0xF0: r.flags |= cf_isLOCK;
                   goto prefix;
      };

    // prefix analyzed

    r.opcode = b;

    if (b == 0x0F) goto prefix_0F;

    getnextbyte(nextbyte);

    if (b == 0xE9)
      {
        r.type     = ct_JMP;
        goto       data_offs_rel;
      }

    if (b == 0xE8)
      {
        r.type     = ct_CALL;
        goto       data_offs_rel;
      }

    if ((b & 0xF0) == 0x70)
      {
        r.type     = ct_JCC;
        goto       data_byte_rel;
      }

    if (b == 0xEB)
      {
        r.type     = ct_JMP;
        goto       data_byte_rel;
      }

    if ((b == 0xC3) || (b == 0xCF))
      {
        r.type     = ct_RET;
        goto       okey;
      }

    if (b == 0xC2)
      {
        r.type     = ct_RET;
        goto       data_word;
      }

    if (b == 0xC8)
      goto       data_3xbyte;

    if (
       (b == 0xC9) ||
       (b == 0xFC) ||
       (b == 0xAA) ||
       (b == 0xA4) ||
       (b == 0xAE) ||
       (b == 0x98) ||
       (b == 0x99) ||
       (b == 0xAC) ||
       (b == 0xCC)              // int 3
       )
      goto       okey;

    if ((b & 0xFC) == 0x88)
      goto modrm;

    if ((b & 0xFE) == 0xC6)
      goto modrm_data_w_66;

    if ((b & 0xF0) == 0xB0)
      goto data_w3_66;


    if ((b & 0xFC) == 0xA0)
      goto data_offs;

    if (
       (b == 0xCD) ||
       (b == 0xE4)
       )
      goto data_byte;

    if ((b & 0xF0) == 0x50)
      goto okey;

    if ((b == 0xFF) &&
       (
       (((nextbyte >> 3) & 7) == 0) || (((nextbyte >> 3) & 7) == 6)
       ))
       goto modrm;

    if ((b & 0xFE) == 0xC4)                //  gluk !
      goto modrm;

    if ((b & 0xE6) == 0x06)
      goto okey;

    if ((b & 0xC4) == 0x00)
      goto modrm;

    if ((b & 0xFC) == 0x80)
      goto modrm_data_sw_66;

    if ((b & 0xC6) == 0x04)
      goto data_w_66;

    if ( ((b & 0xFE) == 0xF6) && (((nextbyte >> 3) & 6) == 2) )
      goto modrm;

    if ((b & 0xF0) == 0x40)
      goto okey;

    if ( ((b & 0xFE) == 0xFE) && (((nextbyte >> 3) & 6) == 0) )
      goto modrm;

    if ((b & 0xF8) == 0x90)
      goto okey;

    if (b == 0x6A)
      goto data_byte;
    if (b == 0x68)
      goto data_66;

    if ( ((b & 0xFE) == 0xF6) && (((nextbyte >> 3) & 6) == 6) )
      goto modrm;

    if ((b & 0xFC) == 0xD0)
      goto modrm;

    if ((b & 0xFE) == 0xC0)
      goto modrm_data_byte;

    if ((b & 0xFE) == 0x84)
      goto modrm;

    if ( ((b & 0xF6) == 0xF6) && (((nextbyte >> 3) & 7) == 0) )
      goto modrm_data_w_66;

    if ((b & 0xFE) == 0xA8)
      goto data_w_66;

    if ((b & 0xFD) == 0x8C)
      goto modrm;

    if (b == 0x8D)
      goto modrm;

    if (  ((b & 0xFE) == 0xF6) && (((nextbyte >> 3) & 7) == 4)  )
      goto modrm;

    if ((b & 0xFE) == 0x86)
      goto modrm;

error:
    dump(cmd, 10);
    printf("<- unknown command\n");
    exit(1);


prefix_0F:

    r.flags |= cf_is0F;
    getbyte(b);
    r.opcode = b;
    getnextbyte(nextbyte);

    if ((b & 0xF0) == 0x80)
      {
        r.type     = ct_JCC;
        goto       data_offs_rel;
      }

    if ((b & 0xF6) == 0xB6)
      goto modrm;




   goto error;



modrm_data_byte:
   modrm_proc();
   goto data_byte;

modrm_data_w_66:
   modrm_proc();
   goto data_w_66;

modrm_data_sw_66:
   modrm_proc();
   goto data_sw_66;

modrm:
   modrm_proc();
   goto okey;

data_w3_66:
   if ((r.opcode & 0x08) != 0)
     goto data_66;
   else
     goto data_byte;

data_sw_66:
   if ((r.opcode & 0x02) != 0)
     goto data_byte;
   goto data_w_66;

data_w_66:
   if ((r.opcode & 0x01) != 0)
     goto data_66;
   else
     goto data_byte;

data_byte:
    r.datasize = 1;
    goto data;

data_66:
    if ((r.flags & cf_is66) == 0)
      goto data_word;
    else
      goto data_dword;

data_dword:
    r.datasize = 4;
    goto data;

data_word:
    r.datasize = 2;
    goto data;

data_3xbyte:
    r.datasize = 3;
    goto data;

data_offs:
    if ((r.flags & cf_is67) == 0)
      r.datasize = 2;
    else
      r.datasize = 4;
    goto data;

data_offs_rel:
    if ((r.flags & cf_is66) == 0)
      r.datasize = 2;
    else
      r.datasize = 4;
    goto data_rel;

data_byte_rel:
    r.datasize = 1;
    goto data_rel;

data_rel:
    r.flags |= cf_isDATAREL;
    goto data;

data:
    r.flags |= cf_isDATA;
    goto okey;

okey:
    if (r.datasize != 0)
      for (i=0; i<r.datasize; i++)
        getbyte(r.data.b[i]);

    if (r.memsize != 0)
      for (i=0; i<r.memsize; i++)
        getbyte(r.mem[i]);

    // end disasm

    r.size = cmd_ptr - cmd;

    if ((r.flags & cf_isDATAREL) != 0)
      {
        r.jmpptr = r.base + r.size;
        if (r.datasize == 1)
          r.jmpptr += (short) r.data.b[0];
        else
          if (r.datasize == 2)
            r.jmpptr += (int) r.data.w[0];
          else
            {
              printf("Disasm error calculating r.jmpptr: r.datasize=%w", r.datasize);
              exit(0);
            }
      }

    // dump(cmd, r.size);

    move(&r, rec, sizeof(tcmdrec));
  }

