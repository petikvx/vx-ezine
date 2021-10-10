; By using this file, you agree to the terms and
; conditions set forth in the COPYING file which
; can be  found  at  the   top  level   of  this
; distribution.
;
; special "virus edition", changes marked with *
;
;                                         bf-0.9
;      The BrainFuck interpreter (c) herm1t'2005
;                   http://vx.netlux.org/herm1t/
;
;            Believe it or not  this language is
;            indeed Turing complete. It combines
;            the speed of BASIC with the ease of
;            INTERCAL  and the readability of an
;            IOCCC entry.
;                                -- Ben Olmstead
;
;            Where would we be without effective
;            programming languages?
;                              -- Charles Stross
;
;      The brainfuck language  is a minimalistic
;      imperative programming language, designed
;      by Urban Mueller around 1993.
;
; LANGUAGE SUMMARY
;	+  Increases element under pointer      
;	-  Decrases element under pointer       
;	>  Increases pointer                    
;	<  Decreases pointer                    
;	[  Starts loop, flag under pointer      
;	]  Indicates end of loop                
;	.  Outputs ASCII code under pointer     
;	,  Reads char and stores ASCII under ptr
;
; NOTES
; 	the end of code ought to be marked by \0
;	additional features will add 32 bytes to
;	the code, therefore they were sacrificed
;	for size, enable them if you wish:
;		NEED_CT - clear tape before exec
;		NEED_BC - perform bound checking
;		NEED_CE - EOF  on input will not
;			  change the cell
;		NEED_CB - check brackets
;
; HISTORY
; Jul 04 2005 - initial realease (ver. 0.9)

%define	CORE_SIZE	30000

;		BITS	32
;		CPU	386
;		global	bf
;		section	.text

; void bf(uint8_t *code, uint8_t *core,
;	int(*gc)(void),int(*pc)(int))
bf:		pusha
		mov	ebp, esp
		mov	esi, [ebp + 36]
		mov	edi, [ebp + 40]
		cld

%ifdef		NEED_CT
		mov	ecx, (CORE_SIZE / 4)
		push	edi
		xor	eax, eax
		rep	stosd
		pop	edi
%endif

bf0:		call	bf1
		jmp	bf0

bf1:		xor	eax, eax
		lodsb
	
%ifdef	NEED_BC
		mov	edx, [ebp + 40]
		cmp	edi, edx
		jb	finish
		lea	edx, [edx + CORE_SIZE-1]
		cmp	edi, edx
		ja	finish
%endif

		or	eax, eax
		jz	finish

		cmp	al, '+'
		jne	.l0
			inc	byte [edi]
			ret

.l0:		cmp	al, '-'
		jne	.l1
			dec	byte [edi]
			ret

.l1:		cmp	al, '>'
		jne	.l2
			inc	edi
			ret

.l2:		cmp	al, '<'

;*
;		jne	.l3
		jne	.l5
		
			dec	edi
;*
;			ret
.ret:			ret

;*
;.l3:		cmp	al, '.'
;		jne	.l4
;			mov	al, byte [edi]
;			push	eax
;			call	[ebp + 48]
;			pop	eax
;			ret
;
;.l4:		cmp	al, ','
;		jne	.l5
;			call	[ebp + 44]
;
;%ifdef	NEED_CE
;			or	eax, eax
;			js	.ret
;%endif
;			mov	[edi], al
;.ret:			ret

.l5:
%ifdef	NEED_CB
		cmp	al, ']'
		je	finish
%endif		
		cmp	al, '['
		jne	.ret

		mov	ebx, esi
		movzx	ecx, byte [edi]
	
.for:		lodsb
%ifdef	NEED_CB
		or	eax, eax
		jz	finish
%endif
		cmp	al, ']'
		jne	.l6
	
			cmp	byte [edi], 0
			je	.ret

				mov 	esi, ebx
				jmp	.for
	
.l6:		cmp	al, '['
		je	.l7
		jcxz	.for

.l7:			push	ebx
			push	ecx
			dec	esi
			call	bf1
			pop	ecx
			pop	ebx
			jmp	.for

finish:		mov	esp, ebp
		popa
;*	
;		ret
		retn	8
;EOF
