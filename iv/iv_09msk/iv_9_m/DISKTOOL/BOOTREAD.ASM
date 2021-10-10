;(C) Saxon 
;Чтение boot'а загрузочного диска винчестера в файл boot.dmp
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
             mov        dx,ds:[si]
             mov        cx,ds:[si][2]
             mov        ax,201h           
             mov        bx,offset buf
             int        13h
             jc          err_

             mov        ah,3ch
             mov        cx,0
             mov        dx,offset fn
             int        21h
             mov        bx,ax
             mov        ah,40h
             mov        dx,offset buf
             mov        cx,200h
             int        21h
             jc         err_
             cmp        ax,cx
             jnz        err_

             mov        ah,3eh
             int        21h














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
ok      db      10,13,'Ok. $'        
error   db      10,13,'**** Error **** $'
fn      db      'boot.dmp',0
buf     db      200h dup (?)
        db      '$'
        end     start
