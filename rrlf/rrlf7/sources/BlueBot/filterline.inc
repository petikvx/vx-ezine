; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Filter line function

processping:    lea     eax, [readline]
                mov     byte [eax+1], "O"
                stdcall sendstring,eax
                ret
filterline:     mov     eax, [readline]
                add     eax, -"PING"
                jz      processping
                cmp     byte [readline], ":"
                jz      processline
                ret
sendstring:     mov     eax, [esp+4]
                or      ecx, -1
.loop:          inc     ecx
                cmp     byte [eax+ecx], 0
                jnz     .loop
                invoke  send,[hsock],eax,ecx,0
                ret     4
copystring:     push    esi edi ecx
                mov     esi, [esp+20]
                mov     edi, [esp+16]
                xor     eax, eax
.loop:          mov     cl, [esi+eax]
                or      cl, cl
                jz      .done
                mov     byte [edi], cl
                inc     eax
                inc     edi
                jmp     .loop
.done:          pop     ecx edi esi
                ret     8
comparestring:  push    esi edi
                mov     esi, [esp+12]
                mov     edi, [esp+16]
.loop:          mov     al, [esi]
                cmp     al, [edi]
                jnz     .done
                inc     esi
                inc     edi
                or      al, al
                jnz     .loop
.done:          pop     edi esi
                ret     8
copytobyte:	push	esi edi edx ecx
		mov	edi, [esp+20]
		mov	esi, [esp+24]
		mov	edx, [esp+28]
		xor	eax, eax
.loop:		mov	cl, [esi+eax]
		cmp	cl, dl
		jz	.done
		mov	[edi+eax], cl
		inc	eax
		jmp	.loop
.done:		pop	ecx edx edi esi
		ret	12



