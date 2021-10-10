;(C) Saxon
;Запись файла boot.dmp в boot сектор загрузочного диска винчестера
;определение boot'а из Partition table
.model tiny
.code
org 100h
start:
        push       cs cs  
        pop        ds es
      
        xor        dx,dx
        xor        cx,cx
        mov        dl,80h
        mov        cl,1
        mov        bx,offset buf
        mov        ax,201h
        int        13h
        add        bx,1beh
        mov        si,bx
        mov        cx,4
l:
             cmp        byte ptr ds:[si],80h
             je         el
             add        si,10h
             loop       l
             jmp        err_
el:        
             mov        ax,ds:[si]
             mov        word ptr ds:dx_,ax
             mov        ax,ds:[si][2]
             mov        word ptr ds:[cx_],ax

        mov     ax,3d00h     
        mov     dx,offset fn
        int     21h
        mov     bx,ax    
        jc      err_
             
        mov     ah,3fh
        mov     cx,200h
        mov     dx,offset buf     
        int     21h
        jc      err_
        cmp     ax,cx
        jnz    err_

        mov     ah,3eh
        int     21h
        jc      err_

        mov     cx,word ptr ds:[cx_]
        mov     dx,word ptr ds:[dx_]
        mov     bx,offset buf
        mov     ax,301h
        int     13h

        jc      fatal_









        jmp     ok_
exit:        
        int     20h
err_:        
        mov     dx,offset error        
wr:        
        push    cs
        pop     ds
        mov     ah,09h
        int     21h
        jmp     exit
ok_:        
        mov     dx,offset ok
        jmp     wr
fatal_:
        mov     dx,offset fatal
        jmp     wr
ok      db      10,13,'Ok. $'        
error   db      10,13,'**** Error **** $'
fatal   db      10,13,'***** Warning ! Fatal error. Don^t reboot ! ***** $'
fn      db      'boot.dmp',0
cx_     dw      ?
dx_     dw      ?
buf     db      200h dup (?)
        db      '$'
        end     start
