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
	mov	ah, 52h
	int	21h
; ��������� ᥣ���� 1-�� �����
	mov	ax, es:[bx-2]
RepFnd:
; ����ࠨ���� es:bx
	mov	es, ax
	sub	bx, bx
	cmp	es:byte ptr [bx], 'Z'
	jz	NoMore
; �� �⮫쪮 ࠧ �饬.
	mov	cx, es:[bx+3]
	shl	cx, 1
	shl	cx, 1
	shl	cx, 1
	shl	cx, 1
; �饬 ����� �� ᨣ�����
	mov	di, bx
Search:
	cmp	es:byte ptr [di], 06h
	jnz	MOK
	cmp	es:byte ptr [di+1], 57h
	jnz	MOK
	cmp	es:byte ptr [di+2], 0CBh
	jnz	MOK
	cmp	es:byte ptr [di+3], 02Eh
	jnz	MOK
	cmp	es:byte ptr [di+4], 088h
	jnz	MOK
        cmp     es:byte ptr [di+5], 026h
        jnz     MOK
; ���� � ����� � es:di - ��稬!
	cli
	mov	es: byte ptr [di+3], 90h
	mov	es: byte ptr [di+4], 90h
	mov	es: byte ptr [di+5], 90h
	mov	es: byte ptr [di+6], 90h
	mov	es: byte ptr [di+7], 90h
	mov	es: byte ptr [di+10], 90h
	mov	es: byte ptr [di+11], 90h
	jmp	MemBad
	sti
;
MOK:
	inc	di
	loop	Search
; ���頥��� �� ᫥���騩
	add	ax, es:word ptr [bx+3]
	inc	ax
	jmp	RepFnd
NoMore:
	jmp	MemOK
MemBad:
; �����
	push	cs
	pop	ds
        mov     ah, 9
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
        db      0CAh, 02, 00
; ===================================================
Messag1 db      '����� SEEYOU � ����� �����०��!', 13, 10, '$'
        End     Start