; ����䨪��� LZSS
; P.S. ����⢥���,��� ����� �⪠����� �� i386 ������権,�� ��祬 :) ?
; (c) Deviator/HAZARD

BufL	=	5			; ������ ��-�����஢����

EqPos	dw	0			; ������� ��६����� 
					; (ॣ���஢ �� 墠⨫�)

LzSSp	proc
	pusha
	mov bp,sp

	xchg ax,cx			; ������
	stosw

	xor bx,bx

	mov cx,Bufl			; ��-������㥬
DoCopy:	push cx
	mov al,1
	mov cx,1
	Call BitStore
	lodsb
	mov cl,8
	Call BitStore
	pop  cx
	loop DoCopy

	mov cx,[bp][12]				; �㦭� ࠧ���
	add cx,[bp][2]
Pack:	push cx
	push di
	xor  cx,cx
	mov  di,[bp][2]

	mov  dx,si
	xor  ax,ax

Scan:	push si di
NChar:	cmpsb					; �ࠢ������ ����
	jnz  NotSym				; �� ᮢ���� ?
	inc  cx					; ������. �����稬 ���-�� 
						; ᮢ�������
	cmp  di,dx				; �� ��諨 �� �࠭��� ?
	jb   NChar				; ���

NotSym:	cmp  cx,3				; ��� ������� 3 ���� ?
	jl   NFd
	cmp  ax,cx				; �� �� �� ��諨,�����
	ja   NFd				; �।���饣� ��������� ?
	xchg ax,cx				; ��. ���ᨬ���� ࠧ���
	pop  di
	mov  EqPos,di				; ���饭�� �� ���������
	push di
NFd:	pop  di si
	xor  cx,cx
	inc  di					; ���頥���
	cmp  di,si
	jb   Scan				; ���� ����
	push si
	or   ax,ax				; ���� ��-� ��諨 ?
	jnz  Founded				; ��諨
	pop  si di
	mov	al,1				; �� ��諨
	mov	cx,1				; ���뫠�� 1-�� ���
	Call	BitStore
	lodsb
	mov	cx,8				; ���뫠�� ᠬ ����
	Call	BitStore
	jmp  nByte
Founded:xchg ax,cx
	pop  si di
	mov  ax,EqPos
	sub  ax,[bp][2]				; ���᫨�� ᬥ饭��
	push cx ax
	mov  cx,1
	xor  ax,ax
	Call BitStore				; ���뫠�� 0-��� ���
	pop  ax
	mov  cl,15				; 15 ��� ᬥ饭��
	Call BitStore				; ���饭�e
	pop  cx
	xchg ax,cx
	add  si,ax
	mov  cx,8				; ����� ᮢ�������
	Call BitStore
nByte:	pop  cx
	cmp  si,cx
	jbe  Pack				; ���� �� �����

	shr  bx,3
	inc  bx
	mov  ax,di
	sub  ax,[bp][0]				; ���� ࠧ���
	add  ax,bx
	mov  [bp][12],ax
	popa
	ret
LzSSp	endp

LzSSd	proc
	xor bx,bx
	mov dx,di
	lodsw					; ���쬥� ࠧ���
	push ax
	add ax,di
	xchg ax,bp
UP:	mov cx,1
	Call GetBit				; ��६ ���
	dec  ax
	jz  JustCopy				; = 1 ?
	push si
	mov cx,15				; ���. ��६ 15 ���
	Call GetBit
	add  ax,dx				; ������塞 ��砫� �����
	push ax
	mov cx,8				; ��६ 8 ���
	Call GetBit				; ��९��뢠��
	xchg ax,cx
	pop  si
rep	movsb
	pop  si
	jmp  xByte
JustCopy:
	mov  cx,8
	Call GetBit				; ��६ 8 ���
	stosb					; �����뢠�� ����
xByte:	cmp  di,bp
	jbe UP
	pop  cx
	ret
LzSSd	endp

BitStore	proc
	push	dx
	xor	dx,dx
tbit:	bt	ax,dx
	inc	dx
	jc	bSetBit
	btr	es:[di],bx
	jmp	xBit
bSetBit:bts	es:[di],bx
xBit:	inc	bx
	cmp	bx,8000h
	jb	bSetOk
	xor	bx,bx
	add	di,4096
bSetOk:	loop	tBit
	pop	dx
	ret
BitStore	endp

GetBit	proc
	push	dx
	xor	dx,dx
	xor	ax,ax
gbit:	bt	[si],bx
	inc	bx
	jnc	gnBit
	bts	ax,dx
gnBit:	inc	dx
	cmp	bx,8000h
	jb	gSetOk
	xor	bx,bx
	add	si,4096
gSetOk:	loop	gBit
	pop	dx
	ret
GetBit	endp