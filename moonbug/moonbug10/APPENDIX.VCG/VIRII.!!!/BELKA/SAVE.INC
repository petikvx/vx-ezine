;(c) RedArc
;���࠭����
_SaveFileVCG:
       pusha
       mov dx,bx
;--- ���।��塞 ������
       mov bx,0ffffh
       mov ah,48h
       int 21h
       mov ah,48h
       int 21h
;--- ������㥬 ���� ���
       mov si,bp
       sub si,3
       mov si,word ptr ds:[si]
       add si,bp
       add si,1ah+16
       push cx
       mov cx,word ptr cs:[si]
       add cx,3
       mov di,100h
       mov ds,ax
       pop ax
       call _Generator
;--- �᢮������� ������
       push ds
       pop es
       mov ah,49h
       int 21h
;--- ����⠭�������� ॣ�����
       push cs
       pop ds
       push cs
       pop es
       popa
       ret
