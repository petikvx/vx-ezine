
#define make_ptr( seg,ofs ) ( (void _seg * )( seg ) +( void near * )( ofs ))
#define ptr_seg( fp )       ( (unsigned )( void _seg * )( void far * )( fp ))
#define ptr_ofs( fp )       ( (unsigned )( fp ))

typedef unsigned char     byte;
typedef unsigned int      word;
typedef unsigned long     dword;

#define short           signed char
#define pchar           const far char *

#define MAX(a,b)        a > b ? a : b
#define MIN(a,b)        a < b ? a : b

#define asm             asm {
#define end             }

void exit(byte exitcode);
void fillchar(pchar buf, word bufsize, char filler);
void move(pchar src, pchar dest, word size);
word len(pchar str);

void beep(void)
  {
    asm
        mov     al, 7
        int     29h
    end;
  }

void exit(byte exitcode)
  {
    asm
        mov     al, exitcode
        add     al, '0'
        int     29h
        mov     ah, 4Ch
        mov     al, exitcode
        int     21h
    end;
  }

void fillchar(pchar buf, word bufsize, char filler)
  {
    asm
        mov     cx, bufsize
        or      cx, cx
        jz      __1
        les     di, buf
        mov     al, filler
        cld
        rep     stosb
__1:
    end;
  }

void move(pchar src, pchar dest, word size)
  {
    asm
        mov     cx, size
        or      cx, cx
        jz      __1
        push    ds
        lds     si, src
        les     di, dest
        cld
        rep     movsb
        pop     ds
__1:
    end;
  }

word len(pchar str)
  {
    asm
        les     di, str
        mov     cx, 0ffffh
        xor     al, al
        repnz   scasb
        neg     cx
        dec     cx
        dec     cx
        xchg    cx, ax
    end;
  }

