; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Protected users

	; in:	nick!user@host
	; out:	nothing

add_mask:	push	esi edi
		mov	esi, [esp+12]
		stdcall	find_mask,esi
		or	eax, eax
		jnz	.done
		xor	eax, eax
		cmp	dword [userlist], 0
		jz	.listempty
.loop:		cmp	dword [userlist+eax], 0
		jz	.endfound
		inc	eax
		jmp	.loop
.endfound:	inc	eax
		cmp	eax, 4000		; ** limit
		ja	.done
.listempty:	lea	edi, [userlist+eax]
.copy:		mov	al, [esi]
		mov	[edi], al
		inc	esi
		inc	edi
		or	al, al
		jnz	.copy
		and	dword [edi], 0		; to be sure
.done:		pop	edi esi
		ret	4

	; in:	nick!user@host
	; out:	nothing

remove_mask:	push	esi edi
		mov	esi, [esp+12]
		stdcall	find_mask,esi
		or	eax, eax
		jz	.done
		mov	edi, eax
		mov	esi, edi
.findend:	inc	esi
		cmp	byte [esi], 0
		jnz	.findend
		inc	esi
.movedown:	xor	al, al
		xchg	al, [esi]
		mov	[edi], al
		inc	esi
		inc	edi
		cmp	dword [esi], 0
		jnz	.movedown
		and	dword [edi], 0
.done:		pop	edi esi
		ret	4

	; in:	nick!user@host
	; out:	eax = ptr to nick!user@host

find_mask:	push	esi edi
		lea	edi, [userlist]
.loop:		xor	eax, eax
		cmp	dword [edi], eax
		jz	.done
		stdcall	compare_mask,edi,[esp+12]
		jz	.found
.next:		cmp	byte [edi], 0
		lea	edi, [edi+1]
		jz	.loop
		jmp	.next
.found:		mov	eax, edi
.done:		pop	edi esi
		ret	4

        ; in:   push    ptr to mask
        ;       push    string to compare to
	; out:	zero flag

compare_mask:   push    esi edi
                mov     esi, [esp+12]
                mov     edi, [esp+16]
.compare:       cmp     byte [edi], "*"
                jz      .star
                cmp     byte [edi], "?"
                jz      .question
                mov     al, [edi]
                cmp     [esi], al
                jnz     .done
                or      al, al
                jz      .done
                inc     esi
                inc     edi
                jmp     .compare
.star:          inc     edi
		cmp	byte [edi], 0
		jz	.done
.starloop:      stdcall compare_mask,esi,edi
                jz      .done
                inc     esi
                cmp     byte [esi], 0
                jz      .notfound
                jmp     .starloop
.question:      inc     edi
                stdcall compare_mask,esi,edi
                jz      .done
                inc     esi
                stdcall compare_mask,esi,edi
.done:          pop     edi esi
                ret     8
.notfound:      cmp     byte [esi], 1
                jmp     .done


