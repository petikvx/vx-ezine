
void clrscr(byte mode);

void pascal printf_char(char c);
void pascal printf_dword(dword d);
void printf_word(word w);
void printf_byte(byte b);
void pascal printf_long(long l);
void printf_int(int i);
void printf_short(short s);
void pascal printf_hexchar(byte b);
void pascal printf_hexbyte(byte b);
void pascal printf_hexword(word w);
void pascal printf_hexdword(dword d);
void pascal printf_crlf(void);

void printf(pchar format, ...);



void clrscr(byte mode)
  {
    asm
        xor     ax, ax
        mov     al, mode
        int     10h
    end;
  }

void pascal printf_char(char c)
  {
    asm
        mov     ah, 2
        mov     dl, c
        int     21h
    end;
  }

void pascal printf_crlf(void)
  {
    printf_char(13);
    printf_char(10);
  }

void pascal printf_dword(dword d)
  {
    asm
        mov     eax, d
        call    __1
        jmp     __3
__1:    xor     edx, edx
        mov     ebx, 10
        div     ebx
        push    dx
        or      eax, eax
        jz      __2
        call    __1
__2:    pop     ax
        add     al, '0'
        push    ax
        call    printf_char
        ret
__3:
    end;
  }

void printf_word(word w)
  {
    printf_dword(w);
  }

void printf_byte(byte b)
  {
    printf_dword(b);
  }

void pascal printf_long(long l)
  {
    if (l < 0)
      {
        printf_char('-');
        l = -l;
      }
    printf_dword(l);
  }

void printf_int(int i)
  {
    printf_long(i);
  }

void printf_short(short s)
  {
    printf_long(s);
  }

void pascal printf_hexchar(byte b)
  {
    if (b <= 9)
      printf_char('0'+b);
    else
      printf_char('A'+b-10);
  }

void pascal printf_hexbyte(byte b)
  {
     printf_hexchar(b >> 4);
     printf_hexchar(b & 15);
  }

void pascal printf_hexword(word w)
  {
     printf_hexbyte(w >> 8);
     printf_hexbyte(w & 255);
  }

void pascal printf_hexdword(dword d)
  {
     printf_hexword(d >> 16);
     printf_hexword(d & 65535);
  }

void printf(pchar format, ...)
  {
    int stack_ptr = 0;
    asm
        push    ds
        lds     si, format
        cld

__nextchar:
        lodsb

        or      al, al
        jz      __exit

        cmp     al, '%'
        je      __percent

        cmp     al, 10
        je      __crlf

__putchar:
        push    ax
        call    printf_char

        jmp     __nextchar

__crlf: call    printf_crlf

        jmp     __nextchar

__percent:
        lodsb

        or      al, al
        jz      __exit

        cmp     al, 'c'
        je      __c
        cmp     al, 'i'
        je      __i
        cmp     al, 'l'
        je      __l
        cmp     al, 'b'
        je      __b
        cmp     al, 'w'
        je      __w
        cmp     al, 'd'
        je      __d
        cmp     al, 'B'
        je      __B_
        cmp     al, 'W'
        je      __W_
        cmp     al, 'D'
        je      __D_

        jmp     __putchar

__pop_ax:
        mov     di, stack_ptr
        add     word ptr stack_ptr, 2
        mov     ax, [bp+8+di]
        ret

__pop_eax:
        mov     di, stack_ptr
        add     word ptr stack_ptr, 4
        mov     eax, [bp+8+di]
        ret

__c:    call    __pop_ax
        push    ax
        call    printf_char

        jmp     __nextchar

__s:    call    __pop_ax
        push    ax
        call    printf_short

        jmp     __nextchar

__i:    call    __pop_ax
        push    ax
        call    printf_int

        jmp     __nextchar

__l:    call    __pop_eax
        push    eax
        call    printf_long

        jmp     __nextchar

__b:    call    __pop_ax
        push    ax
        call    printf_byte

        jmp     __nextchar

__w:    call    __pop_ax
        push    ax
        call    printf_word

        jmp     __nextchar

__d:    call    __pop_eax
        push    eax
        call    printf_dword

        jmp     __nextchar

__B_:   call    __pop_ax
        push    ax
        call    printf_hexbyte

        jmp     __nextchar

__W_:   call    __pop_ax
        push    ax
        call    printf_hexword

        jmp     __nextchar

__D_:   call    __pop_eax
        push    eax
        call    printf_hexdword

        jmp     __nextchar


__exit:
        pop     ds
    end;
  }
