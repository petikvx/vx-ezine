; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
; Lempel-Ziv-Welch compression (c) herm1t@vx.netlux.org, 2006-04-19
;
; int lzw_compress(unsigned char *src, unsigned char *dst, int len, unsigned char *temp)
; int lzw_expand(unsigned char *src, unsigned char *dst, unsigned char *temp)
;
; Size of temp buffer
; Bits	Compress	Expand
; -----------------------------
; 14	90225		58143
; 13	45165		40136
; 12	25125		19083
;
		BITS	32
		CPU	386

		global	lzw_compress, lzw_expand

%define MAX_BITS	14
%if MAX_BITS == 14
%define TABLE_SIZE 18041
%endif
%if MAX_BITS == 13
%define TABLE_SIZE 9029
%endif
%if MAX_BITS <= 12
%define TABLE_SIZE 5021
%endif

%define HASHING_SHIFT	(MAX_BITS - 8)
%define MAX_VALUE	((1 << MAX_BITS) - 1)
%define MAX_CODE	(MAX_VALUE - 1)	
	
%define	pos			[ebp + 0]			;4
%define	buf			[ebp + 4]			;4
%define next_code		[ebp + 8]			;4
%define	length			[ebp + 12]			;4
%define	save_esp		[ebp + 16]			;4
%define append_character	[ebp + 20]			;1*TABLE_SIZE
%define	prefix_code		[ebp + 20 + TABLE_SIZE]		;2*TABLE_SIZE
%define	code_value		[ebp + 20 + TABLE_SIZE * 3]	;2*TABLE_SIZE

%define decode_stack		[ebp + 20 + TABLE_SIZE * 3]	;4000

lzw_compress:	pusha
		cld
		mov	ebp, [esp + 48]
		mov	save_esp, esp
		mov	eax, [esp + 40]
		mov	buf, eax
		xor	eax, eax
		mov	pos, eax
		mov	ecx, TABLE_SIZE
		lea	edi, code_value
		dec	eax
		rep	stosw
		mov	esi, [esp + 36]
		mov	dword next_code, 256
		xor	eax, eax
		lodsb
		mov	edi, eax
		mov	ecx, [esp + 44]
		mov	length, ecx
		dec	ecx
.while:		xor	eax, eax
		lodsb
		push	ecx
		mov	ecx, next_code
		push	eax
			push	eax
			push	edi
			call	find_match
			mov	ebx, eax
		pop	eax
		lea	edx, code_value
		cmp	[edx + ebx * 2], word -1
		je	.else
			mov	di, [edx + ebx * 2]
			jmp	.end_if
.else:		cmp	cx, MAX_CODE
		ja	.L2
			lea	edx, append_character
			mov	[edx + ebx], al
			lea	edx, prefix_code
			mov	[edx + ebx * 2], di
			lea	edx, code_value
			mov	[edx + ebx * 2], cx
			inc	ecx
.L2:		push	edi
		call	output_code
		mov	edi, eax
.end_if:	mov	next_code, ecx
		pop	ecx
		loop	.while
		push	edi
		call	output_code
		push	MAX_VALUE
		call	output_code
		push	ecx
		call	output_code
		mov	eax, pos
		shr	eax, 3

.error:		mov	[esp + 28], eax
		popa
		ret

output_code:	pusha
		mov	eax, [esp + 36]
		mov	esi, buf
		mov	edx, pos
		push	MAX_BITS
		pop	ecx
.bit:		rcr	eax, 1
		jnc	.zero
		bts	[esi], edx
		jmp	.done
.zero:		btr	[esi], edx
.done:		inc	edx
		loop	.bit
		mov	pos, edx
		
		shr	edx, 3
		cmp	edx, length
		jb	.ok
		mov	esp, save_esp
		xor	eax, eax
		jmp	lzw_compress.error	
	.ok:	popa
		retn	4

find_match:	pusha
		mov	eax, [esp + 36]
		mov	ebx, [esp + 40]
		xor	edx, edx
		inc	edx
		mov	ecx, ebx
		shl	ecx, HASHING_SHIFT
		xor	ecx, eax
		or	ecx, ecx
		jz	.fm_while
		mov	edx, TABLE_SIZE
		sub	edx, ecx
.fm_while:	lea	esi, code_value
		cmp	word [esi + ecx * 2], -1
		je	.fm_done
		lea	esi, prefix_code
		cmp	[esi + ecx * 2], ax
		jne	.fm_L1
			lea	esi, append_character
			cmp	[esi + ecx], bl
			je	.fm_done
.fm_L1:		sub	ecx, edx
		jns	.fm_while
		add	ecx, TABLE_SIZE
		jmp	.fm_while
.fm_done:	mov	[esp + 28], ecx
		popa
		retn	8

lzw_expand:	pusha
		cld
		mov	esi, [esp + 36]
		mov	edi, [esp + 40]
		mov	ebp, [esp + 44]
		mov	buf, esi
		xor	eax, eax
		mov	pos, eax
		mov	dword next_code, 256
		call	input_code
		mov	ecx, eax
		mov	ebx, eax
		stosb
.while:		call	input_code
		mov	esi, eax
		cmp	ax, MAX_VALUE
		je	.end_while
		lea	eax, decode_stack
		mov	edx, eax
		cmp	esi, next_code
		jb	.else
			mov	byte [eax], bl
			inc	eax
			push	ecx
			jmp	.end_if
	.else:		push	esi
	.end_if:	push	eax
			call	decode_string

		mov	bl, [eax]
.while2:	cmp	eax, edx
		jb	.end_while2
			push	eax
			mov	al, [eax]
			stosb
			pop	eax
			dec	eax
			jmp	.while2
.end_while2:	cmp	dword next_code, MAX_CODE
		ja	.end_if2
			lea	edx, prefix_code
			mov	eax, next_code
			mov	[edx + eax * 2], cx
			lea	edx, append_character
			mov	[edx + eax], bl
			inc	dword next_code
.end_if2:	mov	ecx, esi
		jmp	.while
.end_while:
		sub	edi, [esp + 40]
		mov	[esp + 28], edi
		popa
		ret

input_code:	pusha
		mov	edx, pos
		mov	esi, buf
		push	MAX_BITS
		pop	ecx
		xor	eax, eax
.bits:		bt	[esi], edx
		rcr	eax, 1
		inc	edx
		loop	.bits
		shr	eax, (32 - MAX_BITS)
		mov	pos, edx
		mov	[esp + 28], eax
		popa
		ret

decode_string:	pusha
		mov	ecx, [esp + 36]
		mov	edx, [esp + 40]
		lea	esi, append_character
		lea	edi, prefix_code
.ds_while:	cmp	dx, 255
		jbe	.ds_done
			mov	al, [esi + edx]
			mov	[ecx], al
			inc	ecx
			mov	dx, [edi + edx * 2]
		jmp	.ds_while
.ds_done:	mov	[ecx], dl
		mov	[esp + 28], ecx
		popa
		retn	8
