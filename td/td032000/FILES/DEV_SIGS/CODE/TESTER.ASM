; �� �室� � ��楤���,DS:Si - ᬥ饭�� �� �஢��塞� ���
;			ES:BX - ⥪��� ᨣ�����

loc_quit:	retf

tester		proc	far
		xor	ax,ax
		mov	word ptr cs:[48h],ax	; ���⨬ ������� ��६����
		mov	word ptr cs:[58h],ax
		mov	word ptr cs:[5Ah],ax
		mov	word ptr cs:[5Ch],ax
		mov	word ptr cs:[5Eh],ax
		mov	word ptr cs:[54h],ax
		mov	word ptr cs:[56h],ax

		mov	cx,10h			; ���᫨� CRC ��� 16 ����
		call	CRC
		mov	word ptr cs:[40h],ax
		mov	word ptr cs:[42h],dx

		mov	cx,20h			; ���᫨� CRC ��� 32 ����
		call	CRC
		mov	word ptr cs:[44h],ax
		mov	word ptr cs:[46h],dx

		nop
loc_1:
		mov	ax,es:[bx]		; ��६ ���� ᨣ������ � AL
						; (��� �������� ��⨬�����)
		cmp	ax,0FFFFh		; = - 1?
		je	loc_quit		; �� ��室
		mov	di,es:[bx+1]		; ��६ ᬥ饭��
		add	di,si			; �������� ⥪���� ������
		cmp	al,[di]			; �ࠢ���� ����
		jne	loc_6			; �� ��宦 ?
		mov	cl,es:[bx+3]		; Cl - ࠧ��� ᨣ������
		cmp	si,di			; SI = DI ? �᫨ ࠢ��,�
						; ����� CRC �� ���� - ��
						; 㦥 �����⠭
		jne	loc_3			; ���...�������� �㦭�

		cmp	cl,10h			; � ࠧ��� ��砩�� ����� 16 ?
		jb	loc_3			; �����...����� �ਤ����...
		jnz	loc_2			; ���...�� �����,�� � �� 16.
		mov	ax,word ptr cs:[40h]	; ���쬥� �����⠭�� ࠭��
		mov	dx,word ptr cs:[42h]	; CRC
		jmp	short loc_5		; �� �ࠢ�����
loc_2:
		cmp	cl,20h			; � ����� ��砩�� �� 32 ����?
		jne	loc_3			; ���....��⠥�
		mov	ax,word ptr cs:[44h]	; ��. �� ⠪�� 㦥 ��⠫�.
		mov	dx,word ptr cs:[46h]	; �ࠢ������...
		jmp	short loc_5
loc_3:
		xor	ax,ax			; ���⨬ AX � DX
		mov	dx,ax

		xchg	bx,bx			; ????
loc_4:
		xor	dh,dl			; ���� CRC
		xor	dl,ah
		xor	ah,al
		mov	al,[di]
		inc	di
		xor	al,dh
		dec	cl			; ���稪 㬥��訫� �� 1
		jnz	loc_4			; = 0 ?
loc_5:
		mov	cx,100h			; ����稬 �����७�� �� 
						; ����䨪��� ������-� �����
		cmp	ax,es:[bx+4]
		jne	loc_6			; ���� ��᮪ CRC
		cmp	dx,es:[bx+6]
		je	loc_7			; ��ன ��᮪ CRC

		xchg	bx,bx			; ??? Lameness !
loc_6:
		xor	cx,cx			; Cx = 0. ��﫨 �����७��
		cmp	byte ptr cs:[70h],1	;
		je	loc_9			;
		cmp	byte ptr es:[bx+3],0Ah
		jb	loc_9			;
loc_7:
		add	cl,es:[bx+0Bh]		; �� ��� ᫮���� ! ��������
		jz	loc_12			; ᨣ������ ����. �� ����
						; �������� ���� � ���� ?
		mov	dl,es:[bx+8]		; ����. DL - ���� ��ன 
						; ᨣ������
		mov	di,es:[bx+9]		; Di - ᬥ饭�� ᨣ������
		add	di,si			; �������� ᬥ饭��
		cmp	dl,[di]			; �ࠢ����
		je	loc_10			; ���� !
loc_8:
		cmp	ch,1			; ���� �����७�� � ����� ?
		je	loc_13			; ��...�ᢥ����� �
loc_9:
		mov	di,es:[bx+10h]		; ��﫨 ⨯ ᨣ������
		and	di,0Fh			; ��⠢�� 4 ���
		add	di,di			; 㬭���� �� 2
		add	bx,cs:data_16e[di]	; ������� ࠧ��� ������� �����
		jmp	loc_1			; �� ⠡���� � �� ᫥������
						; ᨣ������
loc_10:
		xor	ax,ax			; ���⨬ AX � DX
		mov	dx,ax
		nop
loc_11:
		xor	dh,dl
		xor	dl,ah
		xor	ah,al
		mov	al,[di]
		inc	di
		xor	al,dh
		dec	cl
		jnz	loc_11			; ����� ��⠥� ᨣ������

		cmp	ax,es:[bx+0Ch]
		jne	loc_8			; � ��� ࠢ�� ?
		cmp	dx,es:[bx+0Eh]
		jne	loc_8			; ��⥭쪠,�� � ��� ����� !
loc_12:
		cmp	ch,1
		je	loc_14			; ��...�㣠�� �

		mov	al,es:[bx+0Bh]		; ��﫨 ࠧ��� ��ன ᨣ������
		cmp	al,10h
		jb	loc_9			; < 16 ?

		cmp	al,30h			; > 48 ?
		ja	loc_9

loc_13:
		mov	al,es:[bx+3]		; ��६ ࠧ��� ��ࢮ� ᨣ������
		cmp	al,0Ah
		jb	loc_9			; < 10 ?

		cmp	al,30h			; > 48 ?
		ja	loc_9

		test	byte ptr es:[bx+10h],30h; �஢�ਬ �����-� ���
						; 祣�-�....
		jnz	loc_9			; �⮨�

		call	$+4993h			; � � ���� ������� �ࠢ�����
						; �� ��������.

		jmp	short loc_9		; ����. ᨣ�����
loc_14:
		mov	ax,es:[bx+11h]		; ��९��뢠�� �㦭� ���祭��
		mov	word ptr cs:[80h],ax

		mov	ax,es:[bx+13h]		; �����-� �� ��� ����� �����
						; ����� � ⠡���,�����-�
		mov	word ptr cs:[82h],ax	; ࠧ��� ����� � �...

		mov	ax,es:[bx+15h]
		mov	word ptr cs:[84h],ax

		test	byte ptr es:[bx+10h],30h;��� ?
		jnz	Quit			; �� ��室.

		callf	ShowMsg			; �㣠�� � !
		jnc	$+73h			; ���� ����� ?
		mov	sp,bp
Quit:
		retf				; Return far

tester		endp
