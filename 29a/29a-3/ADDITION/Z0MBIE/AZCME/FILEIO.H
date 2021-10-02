
#define handle          word

handle openfile(pchar fname);
handle createfile(pchar fname);
void closefile(handle h);
word readfile(handle h, pchar buf, word bufsize);
word writefile(handle h, pchar buf, word bufsize);
dword filepos(handle h);
dword seekfile(handle h, dword newpos);
dword seekeof(handle h);
dword filesize(handle h);

handle openfile(pchar fname)
  {
    asm
        push    ds
        mov     ax, 3d02h
        lds     dx, fname
        int     21h
        pop     ds
    end;
  }

handle createfile(pchar fname)
  {
    asm
        push    ds
        mov     ah, 3Ch
        xor     cx, cx
        lds     dx, fname
        int     21h
        pop     ds
    end;
  }

void closefile(handle h)
  {
    asm
        mov     ah, 3Eh
        mov     bx, h
        int     21h
    end;
  }

word readfile(handle h, pchar buf, word bufsize)
  {
    asm
        push    ds
        mov     ah, 3Fh
        mov     bx, h
        mov     cx, bufsize
        lds     dx, buf
        int     21h
        pop     ds
    end;
  }

word writefile(handle h, pchar buf, word bufsize)
  {
    asm
        push    ds
        mov     ah, 40h
        mov     bx, h
        mov     cx, bufsize
        lds     dx, buf
        int     21h
        pop     ds
    end;
  }

dword filepos(handle h)
  {
    asm
        mov     ax, 4201h
        mov     bx, h
        int     21h
    end;
  }

dword seekfile(handle h, dword newpos)
  {
    asm
        mov     ax, 4200h
        mov     bx, h
        mov     cx, word ptr newpos + 2
        mov     dx, word ptr newpos + 0
        int     21h
    end;
  }

dword seekeof(handle h)
  {
    asm
        mov     ax, 4202h
        mov     bx, h
        xor     cx, cx
        cwd
        int     21h
    end;
  }

dword filesize(handle h)
  {
    dword savepos, retvalue;
    savepos = filepos(h);
    retvalue = seekeof(h);
    seekfile(h, savepos);
    return(retvalue);
  }

