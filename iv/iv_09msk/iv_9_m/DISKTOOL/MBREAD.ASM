;(C) Saxon
; Чтение MBR в файл MBR.DMP

cseg    segment byte
assume  cs:cseg,ds:cseg
org 100h
start:
        push    cs cs
        pop     ds es
        mov     bx,offset buf
        mov     dl,80h
        mov     ax,201h
        xor     dh,dh
        xor     cx,cx
        mov     cl,1 
        int     13h

        mov     ah,3ch
        mov     dx,offset fn
        mov     cx,0
        int     21h
        jc      err_
        mov     bx,ax
        mov     ah,40h
        mov     cx,200h
        mov     dx,offset buf
        int     21h
        jc      err_
        mov     ah,3eh
        int     21h

        mov     ah,09h
        mov     dx,offset mes
        int     21h


exit:
        int     20h
err_:    
        mov     ah,09h
        push    cs
        pop     ds
        mov     dx,offset error
        int     21h
        jmp     exit
fn      DB      'mbr.dmp',0
buf     db      200h dup (?)
mes     db      10,13,'Ok. $'
error   db      10,13,'*** Error *** $'
cseg    ends        
        end start

                           
