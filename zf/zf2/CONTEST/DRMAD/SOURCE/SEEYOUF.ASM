;
; ��稫�� ��� SEEYOU.B �� 䫮���
;
Start:
; ============== ��易⥫쭠� ���� =================
        jmp     Dalee
	db	'(F)'
Ident	db	' SEEYOU.B',0
Flag	dw	0
Drive	dw	0
;
Dalee:
	push	ds
	push	es
	call	Next
Next:
	pop	bp
	sub	bp, offset Next - (offset Start+100h)
	mov	cs:Flag[bp], ax
	mov	cs:Drive[bp], bx
; ====================================================
; ��⠥� boot-ᥪ�� ��᪥��
	mov	dx, cs:Drive[bp]
        mov     ax, 0201h
	mov	cx, 1
	push	cs
	pop	es
	push	cs
	pop	ds
	lea	bx, cs:Buf[bp]
	call	Int40
	jnc	OK1
	jmp	Err
OK1:
; �ࠢ������ �� ᨣ������
	mov	cx, 6
	lea	si, cs:Sign[bp]
	lea	di, cs:Buf[bp]
ChkFDD:
	mov	al, cs:byte ptr [di+0FAh]
	mov	ah, cs:byte ptr [si]
	cmp	ah, al
	jz	Contin
	jmp	OkFDD
Contin:
	inc	si
	inc	di
	Loop	ChkFDD
; ��।��塞 ⨯ ��᪥��
	mov	al, cs:byte ptr Buf[bp+16h]
	cmp	al, 2
	jz	d360
	cmp	al, 7
	jz	d1200
	cmp	al, 3
	jz	d720
	cmp	al, 9
	jz	d1440
	jmp	Err
; ������뢠�� ���⮯�������� ���⠭���� ᥪ��
d360:
	mov	cx, 2
	jmp	RdSave
d1200:
	mov	cx, 13
	jmp	RdSave
d720:
	mov	cx, 4
	jmp	RdSave
d1440:
	mov	cx, 14
RdSave:
	mov	ax, 201h
	mov	dx, cs:Drive[bp]
	mov	dh, 1
	lea	bx, cs:Buf[bp]
	Call	Int40
	jc	Err
; �����஢뢠�� ���⠭�� ᥪ��
	push	bx
	mov	ax, 506Fh
	mov	cx, 1FFh
LL:
	xor	es:[bx], ax
	add	ax, 7075h
	inc	bx
	loop	LL
	pop	bx
; �������⥫�� ����஫�
	cmp	cs:byte ptr Buf[bp], 0E9h
	jz	IsBoot
	cmp	cs:byte ptr Buf[bp], 0EBh
	jz	IsBoot
	jmp	NewVir
IsBoot:
; �����?
	cmp	cs:Flag[bp], 1
	jnz	SkipCure
; �����뢠�� � BOOT
	mov	ax, 301h
	mov	dx, cs:Drive[bp]
	mov	cx, 1
	lea	bx, cs:Buf[bp]
	call	Int40
; �뫥稫�
	mov	ah, 9
	lea	dx, Messag1[bp]
	int	21h
	stc
	jmp	Ready
; �訡��
Err:
	mov	ah, 9
	lea	dx, Messag3[bp]
	int	21h
	clc
	jmp	Ready
; ���஢�
OkFDD:
	clc
	jmp	Ready
; ���������
NewVir:
        mov     ah, 9
	lea	dx, Messag4[bp]
	int	21h
	clc
	jmp	Ready
; �� ��稬 :-(
SkipCure:
	mov	ah, 9
	lea	dx, Messag2[bp]
	int	21h
	stc
	jmp	Ready
; ============= ��楤�� "�ࠬ�⭮��" Int13 =========
Int40:
	mov	si, 3
Rep40:
	push	ax
	int	40h
	jnc	Ok40
	sub	ax, ax
	int	40h
	pop	ax
	dec	si
	cmp	si, 0
	jnz	Rep40
Bad40:
	stc
	ret
Ok40:
	pop	ax
	clc
	ret
Ready:
; ============== ��易⥫쭠� ���� =================
	pop	es
	pop	ds
	db	0CAh, 02, 00
; ===================================================
Messag1 db	'FDD ����� SEEYOU.B � ��楫��', 13, 10, '$'
Messag2 db	'FDD ����� SEEYOU.B',13, 10, '$'
Messag3 db      'FDD �訡�� ����㯠',13, 10, '$'
Messag4 db	'FDD ����� ����䨪�樥� SEEYOU', 13, 10, '$'
Sign	db	06h, 057h, 0CBh, 02Eh, 088h, 026h
Buf	db	512 dup (0)
        End     Start