;��楤��� ��� ࠡ��� � 䠩����
;(c) RedArc

;GotoStart - ᬥ饭�� � 䠩�� �� ��砫�
;GotoEnd   - ᬥ饭�� � 䠩�� �� ����
;ReadFromFile - �⥭�� �� 䠩��

;����������������������������������������������������������������������������
GotoStart proc near
       mov ax,4200h
       int 21h
       ret
GotoStart endp

;����������������������������������������������������������������������������
GotoEnd proc near
       mov ax,4202h
       int 21h
       ret
GotoEnd endp

;����������������������������������������������������������������������������
ReadFromFile proc near
       mov ah,3fh
       int 21h
       ret
ReadFromFile endp
