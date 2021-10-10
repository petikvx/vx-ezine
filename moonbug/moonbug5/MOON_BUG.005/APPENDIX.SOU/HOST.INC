; Host programm
hoststart:
        mov     ah,9
        lea     dx,hostmsg-hoststart+s
        int     21h
        ret
hostmsg db      'I''m HOST',eol