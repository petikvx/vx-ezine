; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
mk:		pusha
		cld
		mov	edi, [esp + 36]
		mov	esi, [esp + 40]

		mov	eax, esi
		xor	ebx, ebx
		inc	eax
		shr	eax, 1
		jz	.s1
.s0:		inc	ebx
		sub	eax, ebx
		jg	.s0
.s1:
		mov	edx, ebx
.next:		mov	eax, ebx
		push	edx
		mul	edx
		pop	edx
		cmp	eax, esi
		jae	.done
		inc	edx
		jmp	.next
.done:		sub	eax, esi
		mov	ebp, eax
	
		mov	al, '>'
		stosb
	
		mov	al, '+'
		mov	ecx, ebx
		rep	stosb
	
		mov	ax, '[<'
		stosw
		
		mov	al, '+'
		mov	ecx, edx
		rep	stosb
	
		mov	eax, '>-]<'
		stosd
	
		or	ebp, ebp
		js	.do_add
		mov	al, '-'
		jmp	.do
.do_add:	mov	al, '+'
		neg	ebp
.do:		mov	ecx, ebp
		rep	stosb

		mov	al, '>'
		stosb
	
		mov	[esp + 28], edi
		popa
		retn	8

; obfuscate key (BrainFuck)
okey_bf:	pusha
		mov	esi, [esp + 36]	; key
		mov	edi, [esp + 40] ; out
		movb	ecx, KEY_LENGTH
		
.okey:		xor	eax, eax
		lodsb
		push	eax
		push	edi
		call	mk
		xchg	eax, edi
		loop	.okey
		mov	[esp + 28], edi
		popa
		retn	8
