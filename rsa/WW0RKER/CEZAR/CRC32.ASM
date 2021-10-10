c_crc32:
                push    cs
                pop     es
                push    di
                mov     word ptr ds:[crc],0ffffh
                mov     word ptr ds:[crc+2],0ffffh

                call    gentable

read_next:
                mov     cx,200h                         ; !!!!
                mov     dx,bp
                add     dx,1024
                mov     bx,word ptr ds:[demohandle]
                call    read
                mov     cx,ax
                or      cx,cx
                je      crc32_ret
                mov     si,bp
                add     si,1024
                call    calc_crc32
                jmp     short read_next

crc32_ret:
                not     word ptr ds:[crc]
                not     word ptr ds:[crc+2]
                pop     di
                ret


calc_crc32:
                push    es
                les     ax,dword ptr ds:[crc]
                mov     dx,es
c_crc:
                xor     bh,bh
                mov     bl,al
                lodsb
                xor     bl,al
                mov     al,ah
                mov     ah,dl
                mov     dl,dh
                xor     dh,dh
                shl     bx,1
                shl     bx,1
                push    di
                mov     di,bp
                les     bx,dword ptr ds:[di+bx]
                pop     di
                xor     ax,bx
                mov     bx,es
                xor     dx,bx
                loop    c_crc
                mov     word ptr ds:[crc],ax
                mov     word ptr ds:[crc+2],dx
                pop     es
                ret


; bp - where make table
gentable:
                push    cs
                pop     es
                mov     di,bp
                xor     cx,cx
gentab_1:
                xor     ax,ax
                xor     dx,dx
                mov     al,cl
                push    cx
                mov     cx,8
gentab_2:
                clc
                rcr     dx,1
                rcr     ax,1
                jnb     gentab_3
                xor     dx,0edb8h
                xor     ax,8320h
gentab_3:
                loop    gentab_2
                mov     word ptr es:[di],ax
                mov     word ptr es:[di+2],dx
                add     di,4
                pop     cx
                inc     cx
                cmp     cx,100h
                jnz     gentab_1
                ret

