;Video Capture for 320x200x256 mode - hit print-screen to capture.
;creates file message.scr
.model tiny
.radix 16
.code
        org 100
start:
        mov     ax,2505
        mov     dx,offset Int05
        int     21

        mov     dx,offset end_prog+1
        int     27



Int05:
        pushf
        push    ax bx cx dx es ds si di bp

        push    cs cs        
        pop     es ds
CheckIf320x200x256:        
        mov     ah,0f
        int     10
        cmp     al,13
        jne     EndCapture

CreateFile:        
        mov     ah,3c
        mov     dx,offset filename
        xor     cx,cx
        int     21
        jc      EndCapture

        xchg    bx,ax
                
        call    Getcolors
WriteColors:
        mov     dx,offset colors
        mov     cx,300
        mov     ah,40
        int     21
        
WriteScreen:        
        mov     dx,0a000
        mov     ds,dx
        xor     dx,dx
        mov     cx,320d*200d
        mov     ah,40
        int     21

CloseFile:        
        mov     ah,3e
        int     21
EndCapture:        
        pop     bp di si ds es dx cx bx ax
        popf
        iret

Getcolors:
        push    bx
        mov     ax,1017
        mov     bx,0
        mov     cx,0ff
        mov     dx,offset colors
        push    cs
        pop     es
        int     10
        pop     bx
        ret

filename        db      'Message.Scr',0
colors  db      300 dup(?)

end_prog:
end start
