;
; ��稫�� ��� SEEYOU � �����
;
Start:
; ============== ��易⥫쭠� ���� =================
        jmp     Dalee
	db	'(M)'
Ident	db	' SEEYOU.B',0
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
; �饬 jmp xxxx:xxxx
        sub     ax, ax
	mov	ds, ax
	cmp	ds:byte ptr [03C3h], 0EAh
	jnz	MemOk
; �롨ࠥ� ᬥ饭�� � ᥣ����
	mov	bx, ds: word ptr [03C4h]
	mov	es, ds: word ptr [03C6h]
; �ࠢ������ �� ᨣ������
	push	cs
	pop	ds
	lea	si, cs:Sign[bp]
	mov	di, bx
	sub	di, 3
	mov	cx, 6
MemRep:
	mov	al, byte ptr es:[di]
	mov	ah, byte ptr ds:[si]
	cmp	ah, al
	jnz	MemOk
	inc	si
	inc	di
	loop	MemRep
; ��稬 ( � �� ��砥 !!! )
	cli
	mov	es: byte ptr [bx+0], 90h
	mov	es: byte ptr [bx+1], 90h
	mov	es: byte ptr [bx+2], 90h
	mov	es: byte ptr [bx+3], 90h
	mov	es: byte ptr [bx+4], 90h
	mov	es: byte ptr [bx+7], 90h
	mov	es: byte ptr [bx+8], 90h
	sti
; ��⮢�
	mov	ah, 9
	lea	dx, Messag1 [bp]
	int	21h
	stc
	jmp	Ready
; ���஢
MemOK:
        clc
Ready:
; ============== ��易⥫쭠� ���� =================
	pop	es
	pop	ds
	db	61h
	db	0CAh, 02, 00
; ===================================================
Messag1 db      '����� SEEYOU � ����� �����०��!', 13, 10, '$'
Sign    db      06h, 57h, 0CBh, 02Eh, 88h, 26h
        End     Start