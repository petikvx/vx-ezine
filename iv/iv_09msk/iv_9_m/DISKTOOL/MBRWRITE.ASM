;(C) Saxon
; ‡ ―¨αμ MBR ¨§ δ ©«  MBR.DMP

cseg    segment byte
assume  cs:cseg,ds:cseg
org 100h
start:
        push    cs cs
        pop     ds es
        mov     ax,3d00h     
        mov     DX,OFFSET fN
        int     21h
        jc      err_
        mov     bx,ax
        mov     ah,3fh
        mov     cx,200h
        mov     dx,offset buf
        int     21h
        jc      err_
        cmp     ax,cx
        jnz     err_
        mov     ah,3eh
        int     21h

        
        mov     ax,301h
        xor     dx,dx
        xor     cx,cx
        push    cs
        pop     es
        mov     bx,offset buf
        mov     dl,80h
        mov     cl,1
        int     13h
        jc      fat_

        mov     ah,09h
        mov     dx,offset mes
        int     21h


exit:
        int     20h
err_:    
        mov     dx,offset error
        
point:  mov     ah,09h
        push    cs
        pop     ds
        int     21h
        jmp     exit
fat_:
        mov     dx,offset fatal
        jmp     point

fn      DB      'mbr.dmp',0
buf     db      200h dup (?)
mes     db      10,13,'Ok. $'
error   db      10,13,'*** Error *** $'
fatal   db      10,13,'**** Warning ! Fatal error.Don^t reboot! **** $'
cseg    ends        
        end start

                           
