; VGAxx-144 version 1.81
; copyright (c) 1997 by scout, sps
;
; 4 compile it:
; tasm /m VGAxx.asm
; tlink /x /t VGAxx.obj

                model   tiny
                .code
                jumps
                org     81h
com_line:
                org     100h
start:

seq_data:       jmp     initialize      ; dw 00100h
                db      00h             ; dw 00001h

                dw      0302h
                dw      0003h
                dw      0204h
                dw      0300h
                dw      0c11h
                dw      0b06h
                dw      3e07h
                dw      4f09h           ; 04f09h for 30 rows
d1              =       $-1             ; 04d09h for 34 rows
                                        ; 04709h for 60 rows
                dw      0ea10h
                dw      8c11h
                dw      0df12h          ; 0df12h for 30 rows
d2              =       $-1             ; 0db12h for 34 rows
                                        ; 0ee12h for 60 rows
                dw      0e715h
                dw      0416h

int_10h:
                push    ax
                or      al,00010000b
                cmp     ax,word ptr cs:d3
                pop     ax
                push    ax
                je      set_char

                or      ah,ah
                jne     pass_10h

                and     al,01111111b
                cmp     al,3
                je      set_mode
                cmp     al,2
                je      set_mode
pass_10h:
                pop     ax
                db      0eah
old_int_10h     dd      ?

set_mode:
                pop     ax

                pushf
                call    dword ptr cs:[old_int_10h]

                push    ax

                mov     ax,1114h        ; 1114h for 30 rows - 8x16
d3              =       $-2             ; 1111h for 34 rows - 8x14
                                        ; 1112h for 60 rows - 8x8
                xor     bl,bl
set_char:
                push    ds cx dx si cs
                pop     ds

                pushf
                call    dword ptr ds:[old_int_10h]

                cld
                mov     si,offset seq_data

                mov     dx,3c4h
                mov     cx,5
loop_1:         lodsw
                out     dx,ax
                loop    loop_1

                mov     dl,0c2h
                mov     al,0e7h
                out     dx,al

                mov     dl,0c4h
                lodsw
                out     dx,ax

                mov     dl,0d4h
                mov     cl,9
loop_2:         lodsw
                out     dx,ax
                loop    loop_2

                mov     ds,cx
                mov     byte ptr ds:[0484h],29          ; text rows-1 (29,33,59)
d4              =       $-1
                mov     word ptr ds:[044ch],30*80*2     ; length of video area
d5              =       $-2                             ; (4800,5440,9600)

                pop     si dx cx ds ax

                iret

tsr_size        =       $-seq_data

initialize:
; check shifts
                pop     ds
                push    ds
                mov     al,byte ptr ds:[0417h]
                and     al,00000011b
                cmp     al,00000011b
                je      get_out

                push    cs
                pop     ds

; analyze com string
                mov     si,offset com_line
next_blank:
                lodsb
                cmp     al,20h
                je      next_blank
                cmp     al,09h
                je      next_blank
                cmp     al,0dh
                je      init_data
                cmp     al,'/'
                je      check_key
                cmp     al,'-'
                je      check_key
make_help:
                mov     eo_copyright,' '
                jmp     finish
check_key:
                lodsb
                cmp     al,'0'
                jne     check_help
kill:
; kill int10h
                mov     di,offset int_10h
                mov     al,0e9h
                stosb
                mov     ax,offset pass_10h-offset int_10h-2
                stosw
                and     flags,11111110b
                jmp     check_blank
check_help:
                cmp     al,'?'
                je      make_help
                and     al,11011111b
                cmp     al,'H'
                je      make_help
                cmp     al,'U'
                jne     check_mode
                or      flags,00001000b
                jmp     check_blank
check_mode:
                or      flags,00000001b
                cmp     al,'A'
                je      check_blank
                or      flags,00000010b
                cmp     al,'B'
                je      check_blank
                cmp     al,'C'
                jne     make_help
                or      flags,00000100b
check_blank:
                lodsb
                cmp     al,20h
                je      check_blank
                cmp     al,09h
                je      check_blank
                cmp     al,0dh
                jne     make_help

init_data:
; initialize data
                mov     di,offset seq_data
                mov     ax,0100h
                stosw
                mov     al,01h
                stosb

                test    flags,00001000b
                jnz     check_install

                mov     al,flags
                shr     al,1
                jnc     check_install
                shr     al,1
                mov     si,offset data_1
                jnc     set_data
                mov     si,offset data_2
                shr     al,1
                jnc     set_data
                mov     si,offset data_3
set_data:
                mov     di,offset mode
                mov     ax,'08'
                stosw
                mov     al,'x'
                stosb
                movsw

                mov     di,offset data_offs
                mov     cl,data_count
next_byte:
                push    di
                mov     di,word ptr [di]
                movsb
                pop     di
                stosw
                loop    next_byte

check_install:
; check install
                mov     ax,5802h
                int     21h             ; query upper-memory link state
                cbw
                push    ax

                mov     bx,0001h
                mov     ax,5803h
                push    ax
                int     21h             ; link upper-memory 4 allocation

                mov     ah,52h
                int     21h
                mov     ax,es:[bx-2]
                mov     di,05h
                push    cs
                pop     es
next_mcb:
                mov     ds,ax
                cmp     word ptr ds:[di],'ez'           ; check signature
                jne     last_mcb_?
                cmp     byte ptr ds:[di+02h],'a'
                jne     last_mcb_?
                cmp     word ptr ds:[di-04h],0000h      ; free mcb?
                je      last_mcb_?

; already installed
                pop     ax bx
                int     21h             ; restore upper-memory link state

                mov     si,offset old_int_10h-100h+10h  ; set int10h
                mov     di,offset old_int_10h
                movsw
                movsw

                test    cs:flags,00001000b              ; uninstall_?
                jz      make_data
; check vector
                mov     dx,ds
                sub     dx,10h-01h
                mov     ax,3510h
                int     21h
                sub     bx,offset int_10h
                mov     ax,es
                sub     ax,dx
                or      ax,bx
                push    cs
                pop     es
                jz      uninstall
; cant uninstall
                push    cs
                pop     ds
                mov     si,offset c_uninstall_msg
                call    make_msg
                and     flags,11110111b
                jmp     kill
uninstall:
; uninstall
                mov     word ptr ds:[bx+01h],ax
                mov     word ptr ds:[bx+05h],ax
                mov     byte ptr ds:[bx+07h],al
                lds     dx,ds:[old_int_10h-100h+10h]
                mov     ax,2510h
                int     21h
                push    cs
                pop     ds
                mov     si,offset uninstall_msg
                call    make_msg
                jmp     exit
make_data:
                push    ds cs
                pop     ds es
                mov     di,0f5h-100h+10h
                call    move_data                       ; move new data
                jmp     exit

last_mcb_?:
                add     ax,ds:[di-02h]
                inc     ax
                cmp     byte ptr ds:[di-05h],'Z'
                jne     next_mcb

; not installed
                push    cs
                pop     ds

                pop     ax bx
                int     21h             ; restore upper-memory link state

                test    flags,00001000b
                jz      install
                mov     si,offset not_install_msg
                call    make_msg
                jmp     finish

install:
                mov     si,offset install_msg
                call    make_msg

                mov     ax,3510h
                int     21h
                mov     word ptr ds:[old_int_10h],bx
                mov     word ptr ds:[old_int_10h+2],es

                mov     es,word ptr ds:[2ch]
                mov     ah,49h
                int     21h

                mov     dx,cs
                add     dx,(end_ptr+15) shr 4
                push    dx
                xor     si,si
                mov     ah,55h
                int     21h

                mov     es,dx
                mov     si,16h
                mov     di,si
                movsw

                push    cs
                pop     es
                mov     ah,49h
                int     21h

                mov     ax,5800h
                int     21h
                push    ax

                and     al,0fdh
                or      al,01h
                xchg    bx,ax
                mov     ax,5801h
                int     21h

                mov     bx,(tsr_size+15) shr 4
                mov     ah,48h
                int     21h

                push    ax
                sub     ax,10h
                mov     es,ax
                pop     ax

                push    es
                pop     ds

                mov     word ptr ds:[0f1h],ax

                mov     dx,offset int_10h
                mov     ax,2510h
                int     21h

                push    cs
                pop     ds

                mov     di,0f5h
                call    move_data

                pop     bx
                mov     ax,5801h
                int     21h

                pop     bx
                mov     ah,50h
                int     21h

exit:
                mov     ax,0003h
                int     10h
finish:
                mov     dx,offset copyright_msg
                mov     ah,09h
                int     21h
get_out:
                mov     ax,4c00h
                int     21h


move_data:      mov     si,offset mcb_part
                mov     cx,mcb_size
                rep     movsb
                mov     si,offset seq_data
                mov     cl,tsr_size
                rep     movsb
                retn

make_msg:       mov     di,offset eo_copyright
next_char:      lodsb
                stosb
                cmp     al,'$'
                jne     next_char
                retn

mcb_part:       db      'zea'                   ; signature
                db      'VGA'
mode            db      'xxOFF'
mode_size       =       $-mode
mcb_size        =       $-mcb_part

data_offs       dw      d1,d2,d3,d4,d5,d5+1
data_count      =       ($-data_offs) shr 1

data_1          db      '30',4fh,0dfh,14h,29,0c0h,12h        ; for 30 rows
data_size       =       $-data_1
data_2          db      '34',4dh,0dbh,11h,33,40h,15h         ; for 34 rows
data_3          db      '60',47h,0eeh,12h,59,80h,25h         ; for 60 rows

copyright_msg   db      'VGAxx-144 Version 1.81 Copyright (C) '
                db      '1997 by Scout, SPS.'
eo_copyright    db      '$'
help_msg        db      0dh,0ah,'Usage : VGAxx.Com [/Key]'
                db      0dh,0ah,'Keys  : /H, /?     - Display this Help.'
                db      0dh,0ah,'        /U         - Remove program from memory.'
                db      0dh,0ah,'        /{A|B|C|0} - Set {30|34|60|25} rows.'
                db      0dh,0ah,'$'
install_msg     db      0dh,0ah,'VGAxx is installed.',0dh,0ah,'$'
uninstall_msg   db      0dh,0ah,'VGAxx was uninstalled.',0dh,0ah,'$'
c_uninstall_msg db      0dh,0ah,'Can''t uninstall because there is another '
                db      'program loaded after the VGAxx.',0dh,0ah,'$'
not_install_msg db      0dh,0ah,'VGAxx not installed.',0dh,0ah,'$'

flags           db      00000001b
;                           ³ÀÁÁÄÄÄ 000-kill_int10h,001-30,011-34,111-60
;                           ÀÄÄÄÄÄÄ 1 - /U

end_ptr         =       $-start+100h

                end     start

