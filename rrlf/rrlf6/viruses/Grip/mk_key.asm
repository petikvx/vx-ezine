; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
; (*key, seed, count)
mk_key:		pusha
		mov	edi, [esp + 36]
		mov	ebx, [esp + 40]
		mov	ecx, [esp + 44]
		or	ebx, ebx
		jnz	.gkey
	; generate seed
		movb	eax, 13
		int	0x80		; time
		xchg	eax, ebx
		movb	eax, 20
		int	0x80		; getpid
		xor	ebx, eax
%ifdef	USE_RDTSC
		rdtsc
		xor	ebx, eax
		xor	ebx, edx
%endif
.gkey:	; random
		mov	eax, ebx
		imul	eax, 214013
		add	eax, 2531011
		mov	ebx, eax
		shr	eax, 24
	; save key
		stosb
		loop	.gkey
		popa
		retn	12

;EOF
