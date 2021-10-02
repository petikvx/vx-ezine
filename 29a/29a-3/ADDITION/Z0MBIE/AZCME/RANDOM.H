
int rndword;

word random_word(void);
word rnd_word(word range);
word rnd_word_minmax(word min, word max);

word random_word(void)
  {
    asm
        mov     bx, rndword
        in      al, 40h
        xor     bl, al
        in      al, 40h
        add     bh, al
        in      al, 41h
        sub     bl, al
        in      al, 41h
        xor     bh, al
        in      al, 42h
        add     bl, al
        in      al, 42h
        sub     bh, al
        mov     ax, bx
        rol     ax, 1
        xor     dx, dx
        mov     cx, 10007
        mul     cx
        inc     ax
        rol     ax, 1
        mov     rndword, ax
    end;
  }

word rnd_word(word range)
  {
    if (range == 0)
      return(0);
    else
      return(random_word() % range);
  }

word rnd_word_minmax(word min, word max)
  {
    return(rnd_word(max-min+1) + min);
  }
