
;          This is [GCAE] GEN v2.0
;  Written by Golden Cicada in Taipei, Taiwan.
;      (C) Copyright CVEX Corp. , 1995.

        .286
        .model  small
        .code
        extrn GCAE:near,GCAE_E:near

msg_addr equ OFFSET msg-OFFSET proc_start-5

        org 0100h
start:
        mov ah,09h
        mov dx,OFFSET gen_msg
        int 21h
        mov ax,OFFSET GCAE_E+000fh
        shr ax,4
        mov bx,cs
        add bx,ax
        mov es,bx
        mov cx,50
gen_l1:
        push cx
        mov ah,3ch
        xor cx,cx
        mov dx,OFFSET file_name
        int 21h
        xchg bx,ax
        mov cx,OFFSET proc_end-OFFSET proc_start
        mov dx,OFFSET proc_start
        push bx
        mov bx,0100h
        push ax
        in ax,40h
        and ax,0001h
        mov bp,ax
        pop ax
        call GCAE
        pop bx
        mov ah,40h
        int 21h
        mov ah,3eh
        int 21h
        push cs
        pop ds
        mov bx,OFFSET file_no
        inc BYTE PTR ds:[bx+0001h]
        cmp BYTE PTR ds:[bx+0001h],'9'
        jbe gen_l2
        inc BYTE PTR ds:[bx]
        mov BYTE PTR ds:[bx+0001h],'0'
gen_l2:
        pop cx
        loop gen_l1
        mov ah,4ch
        int 21h

file_name db 'T'
file_no db '00.COM',00h
gen_msg db 0dh,0ah,'Generates 50 [GCAE] encrypted test files...',0dh,0ah,'$'

proc_start:
        push cs              ;*** NOTE!!! ***
        pop ds               ;*** In the coding virus DS: must be set to the original value
        call $+0003h
        pop dx
        add dx,msg_addr
        mov ah,09h
        int 21h
        int 20h
msg db 'Hi!This is a [GCAE] test file!$'
proc_end:

         end start

