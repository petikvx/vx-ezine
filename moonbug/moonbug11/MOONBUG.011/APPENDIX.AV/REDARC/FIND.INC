;‘¥à¢¨á­ë¥ ¯à®æ¥¤ãàë ¤«ï ¯®¨áª  ¢¨àãá®¢
;(c) TAVC

;BlockPresent - ¯à®¢¥àª  ­ «¨ç¨ï ¡«®ª  ¢ ãç áâª¥ ¯ ¬ïâ¨
;BlockOffs - á¬¥é¥­¨¥ ¡«®ª  ¢ ãç áâª¥ ¯ ¬ïâ¨

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;function BlockPresent(var memaddr,baddr;msize,bsize:word):boolean;
BlockPresent proc near
        mov     cx,msize
        mov     dx,bsize
        push    ds
        les     di,memaddr
        lds     si,baddr
@@find_block:
        mov     al,byte ptr [si]
        repne   scasb
        or      cx,cx
        jcxz    @@block_not_found
        jmp     @@chk_equ_block
@@block_not_found:
        xor     ax,ax
        jmp     @@end_find_block
@@chk_equ_block:
        push    di
        push    si
        push    cx
        dec     di
        mov     cx,dx
        repe    cmpsb
        mov     ax,cx
        pop     cx
        pop     si
        pop     di
        or      ax,ax
        jnz     @@find_block
        mov     ax,1
@@end_find_block:
        pop     ds
        ret
BlockPresent endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;function BlockOffs (var memaddr,baddr;msize,bsize:word):Word;
BlockOffs proc near
        mov     cx,msize
        mov     dx,bsize
        push    ds
        les     di,memaddr
        lds     si,baddr
@@find_block1:
        mov     al,byte ptr [si]
        repne   scasb
        or      cx,cx
        jcxz    @@block_not_found1
        jmp     @@chk_equ_block1
@@block_not_found1:
        xor     ax,ax
        jmp     @@end_find_block1
@@chk_equ_block1:
        push    di
        push    si
        push    cx
        dec     di
        mov     cx,dx
        repe    cmpsb
        mov     ax,cx
        pop     cx
        pop     si
        pop     di
        or      ax,ax
        jnz     @@find_block1
        mov     ax,di
@@end_find_block1:
        pop     ds
        ret
BlockOffs endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
