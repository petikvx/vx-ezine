;
; ��稫�� ��� SUBURBS-393 � �����
;
SigLen	EQU	14
;
Start:
; ============== ��易⥫쭠� ���� =================
        jmp     Dalee
	db	'(M)'
Ident	db	' SUBURBS-393',0
Flag	dw	0
;
Dalee:
	db	60h
	push	ds
	push	es
	call	Next
Next:
	pop	bp
	sub	bp, offset Next - (offset Start+100h)
	mov	cs:Flag[bp], ax
; ===================================================
; ��⠭�������� ᥣ�����
	push	20h
	pop	es
	push	cs
	pop	ds
; �ࠢ������ �� ᨣ������
	lea	si, Signat[bp]
	sub	di, di
	mov	cx, SigLen
Compar:
	lodsb
	cmp	al, es:byte ptr [di]
	jnz	MemOK
	inc	di
	loop	Compar
; �����?
	cmp	Flag[bp], 1
	jnz	MemBad
; �������� ������ NOP-���
	mov	al, 90h
	mov	di, 6
	mov	cx, 5
	cli
	rep	stosb
	sti
; �뤠�� ᮮ�饭��
	mov	ah, 9
	cmp	cs:Flag[bp], 1
	jnz	NoCured
Cured:
	lea	dx, Messag1[bp]
	jmp	Print
NoCured:
	lea	dx, Messag2[bp]
Print:
	int	21h
MemBad:
	stc
	jmp	Ready
; �����蠥� ࠡ���
MemOK:
	clc
Ready:
; ============== ��易⥫쭠� ���� =================
	pop	es
	pop	ds
	db	61h
	db	0CAh, 02, 00
; ===================================================
Messag1 db      '����� SUBURBS-393 � ����� �����०��!', 13, 10, '$'
Messag2 db	'����� SUBURBS-393 � �����!', 13, 10, '$'
Signat  db      0E9h, 0EDh, 000h, 0B0h, 003h, 0CFh, 080h
	db	0FCh, 04Bh, 074h, 003h, 0E9h, 0DDh, 000h
        db
        End     Start