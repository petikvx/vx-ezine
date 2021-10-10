; input: ds:dx - file name
; output: cf - if error, bx = handle
openfile:
                mov     ax,3d02h
                call    dos
                xchg    ax,bx
                ret

; input: bx - handle
closefile:
                mov     ah,3eh
                call    dos
                ret

; input: ds:dx - file name
; output: cf - if error, cx - attr
getattr:
                mov     ax,4300h
                call    dos
                ret

; input: ds:dx - file name, cx=attr
; output: cf - if error
setattr:
                mov     ax,4301h
                call    dos
                ret

; input: bx - handle, cx - count, ds:dx where
; output: cf - if error
read:
                mov     ah,3fh
                call    dos
                ret

; input: bx - handle, cx - count, ds:dx where
; output: cf - if error
write:
                mov     ah,40h
                call    dos
                ret

; input: bx - handle
; output: cf - if error, dx:ax - file pos
seekstart:
                mov     ax,4200h
                jmp     short doseek

seekend:
                mov     ax,4202h

doseek:
                xor     cx,cx
                cwd
                call    dos
                ret

cur_seek:
                mov     ax,4201h
                call    dos
                ret


; input: bx - handle, cx:dx - file pos
; output: cf - if error, dx:ax - file pos
seek:
                mov     ax,4200h
                call    dos
                ret

; input: bx - handle
; output: cf - if error, cx - time, dx - date
gettime:
                mov     ax,5700h
                call    dos
                ret

; input: bx - handle, cx - time, dx - date
; output: cf - if error
settime:
                mov     ax,5701h
                call    dos
                ret

; input: ds:dx - file name
; output: cf- if error, bx - handle
createfile:
                mov     ah,3ch
                xor     cx,cx
                call    dos
                xchg    ax,bx
                ret

; input: ds:dx - file name
deletefile:
                mov     ah,41h
                call    dos
                ret
