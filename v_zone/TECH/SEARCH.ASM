;
;	�����ᨢ�� ���� 䠩���.
;	(c) Ak Kort [SOS group]
;	Microsoft Assembler 6.0
;
	.model tiny
	.486
	.code
	.startup
	org 100h
	jmp beg
	
msk	db '*.exe',0	; ����� 䠩�� �᪠��.
pth	db '\',0	; ��� �᪠��.
dsk	db 3		; �� ����� ��᪥ (ᥩ�� - �)
all	db '*.*',0	; �⮡� �室��� �� �� �����⠫���
old	db '..',0	; �।��騩 ��⠫��
oldpath	db 64 dup (0)	; ���� ��⠫��
curpath db 64 dup (0)	; ⥪�騩 ��⠫��

beg:
	mov ah,19h
	int 21h
	mov ah,0Eh
	push ax
	mov dl,dsk
	int 21h
	mov ah,47h
	cwd
	lea si,oldpath
	push si
	int 21h
	lea dx,pth
	call Recurse
	pop dx
	mov ah,3Bh
	int 21h
	pop ax
	mov dl,al
	int 21h
	retn
		
Recurse:
	mov ah,3Bh	; ���室�� � ���� ��⠫��
	int 21h
	sub sp,44	; ᮧ���� �������� DTA
	mov dx,sp	; �ᥣ� ����� ���� �� ����� 31 �����⠫��� => �ᥣ�
	mov si,dx	; ����� ���ॡ������� (44+4)*31=1488 ���� �⥪�
	add si,1Eh	; �� ⠪ � � �����
	mov ah,1Ah
	int 21h
	lea dx,msk	; ���� 䠩���
	xor cx,cx
	mov ah,4Eh
	int 21h
	jc @1
@2:	call PrintName	; ��諨!
	mov ah,4Fh
	int 21h
	jnc @2
@1:
	mov cx,16	; ���� ��� ��⠫����
	lea dx,all
	mov ah,4Eh
	int 21h
	jc @3
@5:	
	test byte ptr [si-9],16	; ������ ms-dos ����� � ��⠫����� �뤠��
				; � 䠩�� - �㤥� ��ᥪ���
	jz @4
	cmp word ptr [si],'.'		; ��୥��� ��४���
	jz @4
	cmp word ptr [si],'..'		; �����⠫��
	jz @4
	
	push si
	mov dx,si
	call Recurse	; ४��ᨢ�� �맮�
	lea dx,old	; �뮤�� �� �����⠫���
	mov ah,3Bh
	int 21h
	pop si
	lea dx,[si-1Eh]	; �����砥� ����� dta
	mov ah,1Ah
	int 21h
@4:
	mov ah,4Fh
	int 21h
	jnc @5
@3:
	add sp,44	; 㤠��塞 �������� dta
	retn

PrintName:
	push si
	mov al,dsk
	add al,'A'
	int 29h		; int 29h - fast put char
	mov al,':'
	int 29h
	mov al,'\'
	int 29h
	lea dx,curpath
	mov ah,47h
	mov si,dx
	cwd
	int 21h
	call PrintStr
	mov al,'\'	; ��� 䠩��� � ��୥��� �����⠥��� ��� ᫥�,
	int 29h		; �� � �ਭ樯� �� ���譮
	pop si
	call PrintStr
	mov al,13
	int 29h
	mov al,10
	int 29h
	retn
	
PrintStr:
	push si
@6:	lodsb
	or al,al
	jz @7
	int 29h
	jmp @6
@7:	
	pop si
	retn

end

