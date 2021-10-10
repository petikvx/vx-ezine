; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
;------------------------------------------------------------------------------
get_delta:	call	.get
.get:		pop	eax
		sub	eax, O(get_delta.get)
		ret

%ifdef CMP_CRC32
crc32:		pusha
		xor	ebx, ebx
		dec	ebx
		cld
		mov	esi, [esp + 36]
		mov	ecx, [esp + 40]
		xor	eax, eax
.l0:		lodsb
		xor	ebx, eax
		push	ecx
		mov	ecx, 8
.l1:		rcr	ebx, 1
		jnc	.l2
		xor	ebx, 0xedb88320
.l2:		loop	.l1
		pop	ecx
		loop	.l0
		not	ebx
		mov	[esp + 28], ebx
		popa
		retn	8
%endif
%ifdef DEBUG
hex_print:	pusha
		mov	ebx, [esp + 36]
		mov	ecx, 8
.L:		mov	eax, ebx
		shr	eax, 28
		cmp	al, 9
		ja	.l1
		add	al, '0'
		jmp	.print
	.l1:	add	al, ('a' - 10)
	.print:	push	eax
		call	putchar
		shl	ebx, 4
		loop	.L
		push	10
		call	putchar
		popa
		retn	4
putchar:	pusha
		mov	eax, 4
		mov	ebx, 0
		lea	ecx, [esp + 36]
		mov	edx, 1
		int	0x80
		popa
		retn	4
%endif
;EOF
