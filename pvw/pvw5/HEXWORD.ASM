hexword:
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds

        push cs
        pop ds
        mov     cx,4
hex0:
        xor     bx,bx
        shl     ax,1
        rcl     bx,1
        shl     ax,1
        rcl     bx,1
        shl     ax,1
        rcl     bx,1
        shl     ax,1
        rcl     bx,1
        xchg    bx,ax
        add     al,030h
        cmp     al,039h
        jbe     hex1
        add     al,7h
hex1:
        mov     ah,0eh
        int     10h
        xchg    bx,ax
        loop    hex0

        mov bh,0
        mov al,'H'
        mov ah,0eh
        int 10h
        mov al,0ah
        mov ah,0eh        
        int 10h
        mov al,0dh
        mov ah,0eh
        int 10h

        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        ret

