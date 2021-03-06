; ������ = 135 bytes
; �������� PackBits
; Ds:Si - Data to pack
; Es:Di - Where put packed data
; Cx    - Source data length

RLEP	proc
	push di cx
	add di,4
	mov NoMatched,si
	xor dx,dx
	xor bx,bx
RLEPack:
	lodsb				; ��६ ����
	cmp al,dl			; �।���騩 ⠪�� ?
	jne NotEqual			; ���
	cmp bl,0			; �����. �뫨 ����宦�� ᨬ����
	jz IncEqual
	Call DropNotEqual		; ����뢠�� ��
IncEqual:
	inc bh				; �����稢��� ���-�� ᮢ�����
	cmp bh,126			; > 126 ?
	jb OkMatch			; �� ��ଠ�쭮
	Call DropEqual			; ��९�������. ����뢠�� ��宦��
OkMatch:jmp RLEPLoop			; C���. ����
NotEqual:
	cmp bh,0			; �뫨 �������騥�� ?
	jz IncNotEqual
	Call DropEqual			; ��. ����뢠�� ��
IncNotEqual:
	inc bl
	cmp bl,126
	jb OkNoMatch
	Call DropNotEqual		; ��९������� ?
OkNoMatch:
RLEPLoop:
	mov dl,al
	loop RLEPack			; ���堫�

	cmp bl,0
	jz NoDrop1
	Call DropNotEqual		; ��⠫��� 墮��� ?
NoDrop1:
	cmp bh,0
	jz NoDrop2
	Call DropEqual
NoDrop2:
	pop cx si
	mov ax,di
	sub ax,si
	mov es:[si],ax			; ������ ������������ ������
	mov es:[si][2],cx		; ��ᯠ��뢠����
	ret
RLEP	endp

DropEqual	proc			; ����뢠�� ��宦��
	push ax
	mov al,bh
	add al,127
	stosb
	mov al,dl
	stosb
	mov bh,0
	mov ax,si
	dec ax
	mov NoMatched,ax
	pop ax
	ret
DropEqual	endp

DropNotEqual	proc			; ����뢠�� �� ��宦��
	push si cx ax
	mov al,bl
	stosb
	mov si,NoMatched
	xor cx,cx
	mov cl,bl
rep	movsb
	mov bl,0
	mov NoMatched,si
	pop  ax cx si
	ret
DropNotEqual	endp

NoMatched	dw	?
