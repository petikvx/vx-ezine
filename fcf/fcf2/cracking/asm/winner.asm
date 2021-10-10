code    segment
        assume  cs:code,ds:code
        org     100h

start:  mov     ah,99h
        int     2Fh

        mov     ah,09h                 ; Print message function
        lea     dx,msg1
        int     21h

        or      bx,bx                  ; Does bx==0?
        mov     dl,offset msg2-100h    ; Because dh alredy setted
        jnz     @2                     ; If it isn't then probaly it is "DN"

        mov     dl,offset msg3-100h    ; Because dh alredy setted
@2:     int     21h

        ret
msg3    db      "not "
msg2    db      "founded in memory!$"
msg1    db      "Dos Navigator $"
code    ends
        end     start
