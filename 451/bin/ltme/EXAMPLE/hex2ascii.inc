;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;In:	eax=hex
;	edx=bufer
;out:	data in bufer
hex2ascii:
		push edi
		push ecx

		push eax

		mov edi,edx

	        mov ecx,8
h2a_c:
		rol eax,4

		push eax
		and al,0Fh

		cmp al,10
		sbb al,69h
		das

		stosb
		pop eax
                loop h2a_c

		pop eax
		pop ecx
		pop edi
	        ret

