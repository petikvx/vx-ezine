; �ண� ����� ���� १����⭮ � ���� ᨣ������,����묨 DrWeb �஢����
; 䠩��.

.model tiny
.386
.code
	org 100h
Main:	jmp	Install
snift	db	0			; ��� �맮��
sigp	dw	0
Sniff:	cmp	cs:[snift],0
	jz	StoreOfs
	mov	cs:[snift],0

	pusha
	push	ds es
	Call	OpenFile
	pop	es ds
	popa

	push	bp
	mov	bp,sp
	push	ax
	mov	ax,cs:[OldPos]		; ����� ᬥ饭��
	add	[bp][2],ax
	pop	ax
	pop	bp
	iret

StoreOfs:
	add	di,di
	mov	cs:[snift],1
	mov	cs:[sigp],bx		; ������ ᨣ������
	iret

	nop				; For sure

zName	db	'sig.out',0

OpenFile	proc
	push	cs
	pop	ds
	mov	ax,3D02h
	mov	dx,offset zName
	int	21h
	jnc	Opened
	mov	ah,3Ch
	xor	cx,cx
	mov	dx,offset zName
	int	21h
Opened:	xchg	ax,bx
	mov	ax,4202h
	xor	cx,cx
	cwd
	int	21h
	mov	ah,40h
	mov	dx,[Sigp]
	mov	cx,16			; ��訬 ᨣ������
	push	es
	pop	ds
	int	21h
	mov	ah,3eh
	int	21h			; ����뢠�� 䠩�
	ret
OpenFile	endp

Install:mov	ax,2599h
	mov	dx,offset Sniff
	int	21h
	mov	dx,offset EndProg+10
	int	27h
OldPos	dw	0FF63h
EndProg:
End	main