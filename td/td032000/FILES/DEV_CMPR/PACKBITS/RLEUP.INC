; ��ᯠ����� PackBits. 32 ����

RLEUp	proc
	lodsw			; ��⠥� ࠧ���
	lodsw
	push ax
	add ax,di
	xchg ax,dx		; Dx - �����
	xor cx,cx
RLEUnpack:
	lodsb
	cmp al,127		; >127
	jb MakeCopy		; �����...�� �������騥�� ����稭�
	sub al,127		; -127
	xchg cl,al
	lodsb			; ���������� ����
rep	stosb
	jmp RLEUPLoop
MakeCopy:
	xchg cl,al		; ��९��뢠�� �� �������騥�� ����稭�
rep	movsb
RLEUPLoop:
	cmp di,dx
	jb RLEUnPack		; ���⨣�� �࠭���
	pop cx
	ret
RLEUp	endp
