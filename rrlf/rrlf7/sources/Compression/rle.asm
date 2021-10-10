; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
; Run-Length Encoding (c) herm1t@vx.netlux.org, 2005-04-13
;
; int rle_compress(unsigned char *in, unsigned char *out, int length);
; int rle_expand(unsigned char *in, unsigned char *out, int length);
;
		BITS	32
		CPU	386

%define	BITS	2
%define	MASK1	(~1 & ~((1 << (8 - BITS)) - 1))
%define MASK2	((~MASK1) & 0xff)

		global	rle_compress, rle_expand
rle_compress:	pusha
		cld
		add	esp, 36
		pop	esi
		pop	edi
		pop	ecx
		sub	esp, 48
		xor	eax, eax
		lodsb
		mov	ebx, eax
.rstc:		xor	edx, edx
.loop:		lodsb
		cmp	eax, ebx
		jne	.fseq
		cmp	dl, MASK2
		je	.fseq
		cmp	cl, 1
		jz	.fseq
		inc	edx
		loop	.loop
		inc	ecx
.fseq:		xchg	eax, ebx
		or	edx, edx
		jnz	.long
		cmp	al, MASK1
		jb	.stos
.long:		or	dl, MASK1
		mov	[edi], dl
		inc	edi
.stos:		stosb
		mov	ebp, edi
		sub	ebp, [esp + 40]
		cmp	ebp, [esp + 44]
		jb	.ok
		xor	ebp, ebp
		jmp	.return
.ok:		loop	.rstc
.return:	mov	[esp + 28], ebp
		popa
		ret

rle_expand:	pusha
		cld
		add	esp, 36
		pop	esi
		pop	edi
		pop	edx
		sub	esp, 48
		xor	eax, eax
.loop:		lodsb
		cmp	al,MASK1
		jb	.stos
		and	al, MASK2
		mov	ecx, eax
		inc	ecx
		lodsb
		dec	edx
		rep
.stos:		stosb
.next:		dec	edx
		jnz	.loop
		sub	edi, [esp + 40]
		mov	[esp + 28], edi
		popa
		ret
