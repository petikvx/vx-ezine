; ���⨥ �� LZ78
;  � �� ��ࠫ�� ������ �祭� ������� ��㪥��� - ������� ��-�� ࠡ�⠫�.
;  � �ਭ樯� ����� ������ ��⨬���஢��� (� �� ᪮��� � �� ࠧ����).
;  LZ78 ������ 䠩�� ᦨ���� ����
;  ��� �� �� ࠡ�⠥� - �⠩� ��� ��⥩�� � �����⬠� ᦠ��.
;  ��ᯠ����� ࠡ�⠥� ������� ����॥ 祬 㯠�����
;  �⥯��� ᦠ�� �।���. (�㦥 祬 PkZip �� ~40% :)

; Deviator/HAZARD.

BitLim	equ	12			; ����. ࠧ��୮��� ����. ��� �����
					; ⥬ ��� �⥯��� ᦠ�� �� � �����
					; �ॡ���� �����,� ࠡ�⠥� � n-ࠧ
					; ���������

LZ78c	proc		; Ds:Si - Source; Es:Di - Dest; Cx - Length
			; ��� ��� �� ⮫쪮 ����������,� ᫮���� ����� �
			; ��襬 ������� ᥣ����.
	push di
	mov cs:[Dictnum],0		; ������ ᫮����
	mov 1 ptr cs:[Dict],0		; ����� 0�� �������
	mov bx,di			; ���࠭塞 � Bx Di
	mov di,offset P			; Di - �� ���� ��ப�
	mov cs:[DictBit],1		; ��砫쭮� ���-�� ��� ��� ����
	mov cs:[DictLim],2		; 2^1 = 2
        xor bp,bp
Pack:	lodsb				; ��६ ����
	mov cs:[di],al			; ������塞 ��� � ��ப�
	inc di

	dec cx
	cmp cx,0			; ���� �� ����� ?
	jle Packed

	Call FindInDict			; ��...�饬 ��ப� � ᫮���
	jc Pack				; ���� ⠪��...������� �� ���� ᨬ���

	dec di				; ��ப� � ��᫥���� ���������� ���⮬
	Call FindInDict			; ����..�饬 ����� ��ப� ��� �����.
	inc di				; ����⠭���� �����

	push ax
	xchg ax,dx			; ���࠭�� ��� ��ப�
	Call StoreCode
	pop  ax
	Call StoreByte			; ���࠭�� ���� ����� �� �室�� �
					; ������ ��ப�

	Call AddEntry			; ������� � ᫮���� ��� ��ப�

	mov di,offset P			; ����� ��ப� = 0
	jmp Pack			; ���堫�

Packed:	dec  di
	Call FindInDict			; �� ᤥ����,�� � ��ப� ��⠫���
					; ᨬ����...����訬 ��
	push ax
	xchg ax,dx
	Call StoreCode
	pop  ax
	Call StoreByte

	mov ax,cs:[DictLim]		; ����訬 ����� ����
	dec ax
	Call StoreCode

	mov ax,bp			; ����⠥� �����
	xor dx,dx
	mov cx,8
	div cx
	inc ax
	add ax,bx
	pop cx
	sub ax,cx
	xchg ax,cx

	ret
LZ78c	endp

LZ78u	proc				; ��ᯠ�����. Ds:Si - 㯠������� �����
					; Es:Di - �㤠 ������ �ᯠ��������
	push di				; ���࠭�� Di
	mov cs:[DictNum],0		; �ந��樠�����㥬 ᫮����
	mov 1 ptr cs:[Dict],0
	mov bx,di
	mov di,offset P
	mov cs:[DictBit],1
	mov cs:[DictLim],2
	xor bp,bp
UnPack:	Call GetCode			; ��६ ���
	push ax
	Call GetByte			; ��६ ���� �� �����
	pop  dx
	inc dx				; �����稬 ��� �� 1
	cmp cs:[DictLim],dx		; ����� ������ ?
	jz xDone			; ��. �� �� ��� ����砭�� ��⮪� ����
	dec dx				; Undo
	Call StoreString		; ��९�訬 � ��ப� ��᫥����⥫쭮���
					; ᮮ⢥�������� ���� � Dx
	mov cs:[di],al			; ������� � ����� Al
	inc di
	Call AddEntry			; ������� � ᫮���� ��ப�

	push si ds cs			; ����뢠�� ��ப� �� �����祭��
	pop  ds

	mov si,offset P			; Si - ��ப�
	xchg bx,di			; Di - �㤠
	mov cx,bx
	sub cx,si			; Cx - ࠧ��� (���. 1)
rep	movsb
	xchg bx,di
	mov di,offset P			; ����� ��ப� = 0
	pop ds
	pop si
	jmp UnPack			; ��ᯠ���뢠��

xDone:	pop cx				; �����뢠�� ���� ࠧ���
	sub cx,bx
	neg cx
	ret
LZ78u	endp

StoreString	proc			; �८�ࠧ��뢠�� ��� � ��ப�
	push ax cx si ds es cs cs	; ��⪠� 楯�窠 Push'��
	pop  es ds
	or dx,dx			; ��� = 0 ?
	jz EmptyString
	mov cx,dx
	xor ax,ax
	mov si,offset Dict		; ���...�饬 � ᫮���
xFind:	lodsb
	add si,ax
	loop xFind
	lodsb				; ��६ �����
	xchg ax,cx
rep	movsb				; ��襬 ᠬ� ��ப�
EmptyString:
	pop  es ds
	pop  si cx ax
	ret
StoreString	endp
;-----------------------------
FindInDict	proc			; ��楤�ઠ ���᪠ � ��ப�
	push ax cx si di es ds cs cs	; ��⪨� (� �ମ���) Push'�
	pop  ds es
	mov dx,di
	sub dx,offset P
	cmp dl,255			; ����� = 255 ?
	jz NotInDict			; ��. ����ਬ �� ���� � ᫮���,
					; � ����� �� �㤥� ��९�������

	mov cx,DictNum			; ������ ᫮����
	cmp cx,0
	jle NotInDict			; <= 0 ?

	mov di,offset P			; ���...�饬 � ᫮���
	mov si,offset Dict
	inc cx
FindIt:	push cx di
	xor ax,ax
	lodsb
	xchg ax,cx
	cmp cx,dx			; ����� ᮢ������ ?
	jnz NChar
rep	cmpsb				; ��. �ࠢ������
NChar:	pushf
	add si,cx
	popf	
	pop  di cx
	jz InDict			; ��諨 !
	loop FindIt			; ���..
NotInDict:
	clc
	pop ds es
	pop di si cx ax			; ����⠭�������� ॣ�����
	xor dx,dx
	ret
InDict:	mov dx,DictNum			; ��諨
	sub dx,cx			; ����⠥� ������
	inc dx
	pop ds es
	pop di si cx ax
	stc
	ret
FindInDict	endp
;-----------------------------
AddEntry	proc			; ������� � ᫮���� ��ப�
	push ax si di cx ds es cs cs	; Arggh !
	pop  es ds
	mov si,offset Dict
	inc [DictNum]			; �����稬 ���-�� ��ப � ᫮���
	mov ax,DictNum			; �ࠢ��� � ����⮬-1
	inc ax
	cmp ax,DictLim			; ����� ?
	jb  LimOk			; ��...
	shl [DictLim],1			; ���... ������� ����� �� 2
	inc [DictBit]			; ������� ���-�� ���
	cmp [DictBit],BitLim		; ���-�� ��� > BitLim (13) ?
	jb LimOk			; ���
	mov [DictNum],0			; ��. �ந��樠�����㥬 ᫮����
	mov [DictBit],1
	mov [DictLim],2
	mov ax,1
LimOk:	xchg ax,cx			; �ய�᪠��
	xor ax,ax
Skip:	lodsb
	add si,ax
	loop Skip
NoSkip:	mov ax,di
	sub ax,offset P			; ��訬 ����� ��ப�
	xchg si,di
	stosb
	xchg ax,cx
	mov si,offset P
rep	movsb				; ���� ��ப�
	pop  es ds
	pop  cx di si ax
	ret
AddEntry	endp
;-----------------------------
StoreCode	proc			; ��楤�ઠ �����뢠��� �� Ax 
					; DictBit ��� � ��室��� ��⮪
	push cx dx
	mov cx,cs:[DictBit]
	xor dx,dx
StoreIt:bt ax,dx			; �⮨� ��� #dx ?
	inc dx
	jnc DropBit			; ���...������ � ��室��� ��⮪�
					; ᮮ⢥�����騩
	bts es:[bx],bp			; �⮨�...��⠭����...
	jmp NBit
DropBit:btr es:[bx],bp
NBit:	inc bp
	cmp bp,8000h
	jb nLim
	sub bp,8000h
	add bx,1000h
nLim:	loop StoreIt			; ����

	pop dx cx
	ret
StoreCode	endp
;-----------------------------
StoreByte	proc			; �������筮 StoreCode,�� �������
					; �⠡��쭮 8 ���
	push cx dx
	mov cx,8
	xor dx,dx
Store8:	bt ax,dx
	inc dx
	jnc xdBit
	bts es:[bx],bp
	jmp xnBit
xdBit:	btr es:[bx],bp
xnBit:	inc bp
	cmp bp,8000h
	jb zLim
	add bx,1000h
	sub bp,8000h
zLim:	loop Store8
	pop dx cx
	ret
StoreByte	endp
;-----------------------------
GetCode	proc				; ��६ �� �室���� ��⮪� DictBit
					; ���
	push cx dx
        xor ax,ax
	mov cx,cs:[DictBit]
	xor dx,dx

zIt:    bt ds:[si],bp
	inc bp
	jnc  bDBit
	bts ax,dx
	jmp bNBit
bDBit:  btr ax,dx
bNBit:	inc dx
	cmp bp,8000h
	jb XLim
	sub bp,8000h
	add si,1000h
XLim:	loop zIt

	pop dx cx
	ret
GetCode	endp
;-----------------------------
GetByte	proc				; ��६ �� �室���� ��⮪� 8 ���
	push cx dx
	mov cx,8
	xor dx,dx

zGet8:	bt ds:[si],bp
	inc bp
	jnc zDBit
	bts ax,dx
	jmp znBit
zdBit:	btr ax,dx
znBit:	inc dx
	cmp bp,8000h
	jb  LLim
	add si,1000h
	sub bp,8000h
LLim:	loop zGet8

	pop dx cx
	ret
GetByte	endp
;-----------------------------

P	db	127 dup (?)			; ��ப�

DictBit	dw	?				; ���-�� ���
DictLim	dw	?				; �����

DictNum	dw	?				; ������ ᫮����
Dict	db	30000 dup (?)			; ������� � ����ᮬ ࠧ���
