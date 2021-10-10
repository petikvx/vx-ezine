; CyDr-448 version 0.1
; copyright (c) 1997 by scout, sps
;
; 4 compile it:
; tasm /m CyDr.asm
; tlink /x /t CyDr.obj

_rc             =       1dh or 01000000b
_ra             =       38h or 01000000b
_rs             =       36h
_lc             =       1dh
_la             =       38h
_ls             =       2ah

                model   tiny
                .code
                jumps
                org     81h
com_line:
                org     100h
start:
; mode 1
tbl:            jmp     initialize      ; '123'

                db      '4567890-='                             ,0,0
                db      '©Ê„™•≠£ËÈßÂÍ'                          ,0,0
                db      '‰Î¢†Ø‡Æ´§¶Ì'                           ,0,0,0
                db      'ÔÁ·¨®‚Ï°Ó'                             ,0
tbl_size        =       $-tbl
                db      '!"#$:,.;()_+'                          ,0,0
                db      'âñìäÖçÉòôáïö'                          ,0,0
                db      'îõÇÄèêéãÑÜù'                           ,0,0,0
                db      'üóëåàíúÅû'                             ,0
; mode 2
                db      'ƒÕ≥∫∞±≤€ﬂ‹ﬁ›'                          ,0,0
                db      '⁄¬ø…Àª',10h,11h,1eh,1fh,0bh,0ch        ,0,0
                db      '√≈¥ÃŒπ',14h,15h,0fbh,0fch,0fh          ,0,0,0
                db      '¿¡Ÿ» º',18h,19h,1ah,1bh
                                             
                db      'ƒÕ≥∫Òˆ˜¯˘˝˛'                          ,0,0
                db      '’—∏÷¬∑',0,0,0,0,0,0                    ,0,0
                db      '∆ÿµ«≈∂',0,0,0,0,0                      ,0,0,0
                db      '‘œæ”¡Ω',03h,04h,05h,06h

flags           db      00000000b
;                        ≥  ≥≥≥¿ƒƒƒ 1-1st mode
;                        ≥  ≥≥¿ƒƒƒƒ 1-2nd mode
;                        ≥  ≥¿ƒƒƒƒƒ 1-hot key make
;                        ≥  ¿ƒƒƒƒƒƒ 1-shit key
;                        ¿ƒƒƒƒƒƒƒƒƒ 1-ext code

int_09h:        push    ds ax dx
                mov     ah,cs:flags
                in      al,60h
                cmp     al,0e0h
                jne     cmp_code
                or      ah,01000000b
                jmp     pass_09h
cmp_code:       mov     dx,381dh or 0100000001000000b
make_code       =       word ptr $-2
                call    chk_keys
                jne     chk_break
hot_key:        test    ah,00000100b
                jnz     clear_ext_flg
                or      ah,00000100b
                and     ah,11110111b
clear_ext_flg:  and     ah,10111111b
                jmp     pass_09h
chk_break:      mov     dx,381dh or 1000000010000000b or 0100000001000000b
break_code      =       word ptr $-2
                call    chk_keys
                je      good_key
                or      ah,00001000b
                jmp     clear_ext_flg
good_key:       and     ah,10111011b
                test    ah,00001000b
                jnz     pass_09h
                xor     ah,00000001b
                cmp     dl,al
                je      gluck
                xor     ah,00000011b
gluck:          mov     dx,3dah
                in      al,dx
                mov     dx,3c0h
                mov     al,00010001b
                out     dx,al
                mov     al,ah
                and     al,00000011b
                test    al,00000010b
                jz      wow
                and     al,11111110b
wow:            out     dx,al
                mov     al,00100000b
                out     dx,al
pass_09h:       mov     cs:flags,ah
                push    si
                mov     si,0040h
                mov     ds,si
                mov     si,word ptr ds:[si-40h+1ch]
                pushf
                db      09ah
old_int_09h     dd      ?
                cmp     si,word ptr ds:[1ch]
                je      exit_09h
                test    ah,00000011b
                jz      exit_09h
                mov     ax,word ptr ds:[si]
                cmp     al,20h
                jbe     exit_09h
                dec     ah
                dec     ah
                cmp     ah,33h
                ja      exit_09h
                push    bx
                mov     bx,offset tbl
                mov     al,byte ptr ds:[17h]
                test    al,00000011b
                jz      no_shifts
                xor     bx,tbl_size
no_shifts:      cmp     ah,0dh-2
                jbe     fucker
                test    al,01000000b
                jz      fucker
                xor     bx,tbl_size
fucker:         test    byte ptr cs:flags,00000010b
                jz      fuck
                add     bx,2*tbl_size
fuck:           mov     al,ah
                xlat    cs:[bx]
                pop     bx
                or      al,al
                jz      exit_09h
                xor     ah,ah
                mov     word ptr ds:[si],ax
click:          jmp     exit_09h                ; in al,61h
                and     al,11111110b
                xor     al,00000010b
                out     61h,al
exit_09h:       pop     si dx ax ds
                iret

chk_keys:       push    ax
                mov     al,ah
                and     ax,0100000001000000b
                xor     dx,ax
                pop     ax
                test    dl,01000000b
                jnz     chk_1
                cmp     dl,al
                je      end_chk
chk_1:          test    dh,01000000b
                jnz     end_chk
                cmp     dh,al
end_chk:        retn

tsr_size        =       $-start

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

; initialize data
                mov     di,offset start
                mov     ax,'21'
                stosw
                mov     al,'3'
                stosb

                mov     dx,offset copyright_msg
                mov     ah,09h
                int     21h

; analyze com string
                mov     si,offset com_line
next_blank:
                lodsb
                cmp     al,20h
                je      next_blank
                cmp     al,09h
                je      next_blank
                cmp     al,0dh
                je      check_install
                cmp     al,'/'
                je      check_key
                cmp     al,'-'
                je      check_key
make_help:
                mov     dx,offset help_msg
                jmp     finish
check_key:
                lodsb
                cmp     al,'?'
                je      make_help
                and     al,11011111b
                cmp     al,'H'
                je      make_help
                cmp     al,'U'
                jne     next_key
                or      flg,00001000b
                jmp     next_blank
next_key:
                cmp     al,'C'
                jne     make_data
                mov     word ptr click,0abbah
                org     $-2
                in      al,61h
                jmp     next_blank
make_data:
                call    make_hot_key
                jc      make_help
                mov     byte ptr make_code,ah
                mov     bl,ah
                or      ah,10000000b
                mov     byte ptr break_code,ah
                lodsb
                call    make_hot_key
                jc      make_help
                cmp     bl,ah
                mov     dx,offset error_msg
                je      finish
                mov     byte ptr make_code+1,ah
                or      ah,10000000b
                mov     byte ptr break_code+1,ah
                jmp     next_blank

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
                cmp     word ptr ds:[di],'DC'           ; check signature
                jne     last_mcb_?
                cmp     byte ptr ds:[di+02h],'r'
                jne     last_mcb_?
                cmp     word ptr ds:[di-04h],0000h      ; free mcb?
                je      last_mcb_?

; already installed
                pop     ax bx
                int     21h             ; restore upper-memory link state

                mov     si,offset old_int_09h-100h+10h  ; set int09h
                mov     di,offset old_int_09h
                movsw
                movsw

                test    cs:flg,00001000b                ; uninstall_?
                jz      move_data
; check vector
                mov     dx,ds
                sub     dx,10h-01h
                mov     ax,3509h
                int     21h
                sub     bx,offset int_09h
                mov     ax,es
                sub     ax,dx
                or      ax,bx
                push    cs
                pop     es
                mov     dx,offset c_uninstall_msg
                jnz     finish
; uninstall
                mov     word ptr ds:[bx+01h],ax
                mov     word ptr ds:[bx+05h],ax
                mov     byte ptr ds:[bx+07h],al
                lds     dx,ds:[old_int_09h-100h+10h]
                mov     ax,2509h
                int     21h
                mov     dx,offset uninstall_msg
                jmp     finish

move_data:
                push    ds cs
                pop     ds es
                mov     di,0f5h-100h+10h
                call    m_data
                mov     dx,offset alr_inst_msg
                jmp     finish

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

                test    flg,00001000b
                mov     dx,offset not_install_msg
                jnz     finish

install:
                mov     ax,3509h
                int     21h
                mov     word ptr ds:[old_int_09h],bx
                mov     word ptr ds:[old_int_09h+2],es

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
                push    ax
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

                mov     dx,offset int_09h
                mov     ax,2509h
                int     21h

                push    cs
                pop     ds

                mov     di,0f5h
                call    m_data

                pop     ax bx
                int     21h

                pop     bx
                mov     ah,50h
                int     21h

                mov     dx,offset install_msg

finish:
                push    cs
                pop     ds
                mov     ah,09h
                int     21h

                mov     byte ptr pass_09h,00h
                org     $-1
                retn
                xor     ah,ah
                call    gluck
get_out:
                mov     ax,4c00h
                int     21h

make_hot_key:   mov     ah,al
                lodsb
                and     ax,1101111111011111b
                cmp     ah,'R'
                je      right
                cmp     ah,'L'
                jne     chk_error
                mov     ah,_lc
                cmp     al,'C'
                je      chk_ok
                mov     ah,_la
                cmp     al,'A'
                je      chk_ok
                mov     ah,_ls
                cmp     al,'S'
                je      chk_ok
chk_error:
                stc
                retn
right:
                mov     ah,_rc
                cmp     al,'C'
                je      chk_ok
                mov     ah,_ra
                cmp     al,'A'
                je      chk_ok
                mov     ah,_rs
                cmp     al,'S'
                jne     chk_error
chk_ok:
                clc
                retn

m_data:
                mov     si,offset mcb_part
                mov     cx,mcb_size
                rep     movsb
                mov     si,offset start
                mov     cx,tsr_size
                rep     movsb
                retn

mcb_part:       db      'CDr'                   ; signature
                db      'CyDr 0.1'
mcb_size        =       $-mcb_part

copyright_msg   db      'Cyrillic Keyboard Driver Version 0.1 Copyright (C) '
                db      '1997 by Scout, SPS.$'
help_msg        db      0dh,0ah,'Usage : CyDr.Com [/Key]'
                db      0dh,0ah,'Keys  : /H, /?        - Display this Help.'
                db      0dh,0ah,'        /U            - Remove program from memory.'
                db      0dh,0ah,'        /C            - Click ON.'
                db      0dh,0ah,'        /{key1}{key2} - Set hot keys: RC|RA|RS|LC|LA|LS.'
                db      0dh,0ah,'$'
install_msg     db      0dh,0ah,'CyDr is installed.',0dh,0ah,'$'
uninstall_msg   db      0dh,0ah,'CyDr was uninstalled.',0dh,0ah,'$'
c_uninstall_msg db      0dh,0ah,'Can''t uninstall because there is another '
                db      'program loaded after the CyDr.',0dh,0ah,'$'
not_install_msg db      0dh,0ah,'CyDr not installed.',0dh,0ah,'$'
error_msg       db      0dh,0ah,'Hot keys should be are different.',0dh,0ah,'$'
alr_inst_msg    db      0dh,0ah,'CyDr already installed. Options updated.',0dh,0ah,'$'

flg             db      00000000b

end_ptr         =       $-start+100h

                end     start

