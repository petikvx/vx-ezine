; DosNavigator checker.

; Optimalizalta :
; ---------------
; Szabby [SCT]
; www.szabby.com
; szabby@buli.net

code    segment
        assume  cs:code,ds:code
        org     100h

start:  mov     ax,9900h      ; This part checks, that DosNavigator is loaded
        int     2fh           ; Into memory or not.
        cmp     bx,444eh      ; If bx="DN" then it is installed

        mov     ah,09h
        lea     dx,msg0
        int     21h
        je      @1

        lea     dx,msg1
        int     21h

@1:     lea     dx,msg2
        int     21h

        mov     ax, 4Ch      ; Exit to dos
        int     21h
msg0    db "Dos Navigator $"
msg1    db "not $"
msg2    db "founded in memory!$"
code    ends
        end start