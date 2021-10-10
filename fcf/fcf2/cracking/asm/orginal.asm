;DosNavigator checker.
code    segment
        assume  cs:code,ds:code
        org     100h
start:  mov     ah,99h        ; This part checks, that
        mov     al,00h        ; DosNavigator is loaded
        int     02fh          ; Into memory or not.
        cmp     bx,0444eh     ; If bx="DN" then it is installed
        je      @2
        xor     ax,ax         ; If DN not found
        mov     ah,09h
        lea     dx,msg2
        int     021h
        jmp     @1
@2:     xor     ax,ax         ; If we found DN...
        mov     ah,09h
        lea     dx,msg1
        int     021h
@1:
        mov     ax,4c00h      ; Exit to dos
        int     21h
msg1    db "Dos Navigator founded in memory!$"
msg2    db "Dos Navigator not founded in memory!$"
code    ends
        end     start