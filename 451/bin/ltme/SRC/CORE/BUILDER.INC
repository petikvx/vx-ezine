
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;Builder
;
;IN:	EBX=list
;
;OUT:   ECX=new code size
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

                mov esi,[ebx.list_first]
	

;± CREATE BUFER ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

		push esi

		xor ecx,ecx

buider_calcsize:

		movzx eax,[esi.one_data.ltmed_desc.lc_size]
		add ecx,eax
	
		cmp esi,[ebx.list_last]
		je buider_calcsize_exit

		mov esi,[esi.one_next]
		jmp buider_calcsize		

buider_calcsize_exit:

		pop esi

		push ecx
		call core__malloc
		add esp,4
		
		or eax,eax                                      ; error?
		jz @@core_error					;

		xchg edi,eax					; EDI = BUFER

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

		push edi

builder_main:

		push esi					; write to bufer
		movzx ecx,[esi.one_data.ltmed_desc.lc_size]
		lea esi,[esi.one_data.ltmed_command]
		rep movsb
                pop esi

		cmp esi,[ebx.list_last]
		je builder_exit

                mov esi,[esi.one_next]
		jmp builder_main

builder_exit:
		pop edx						; EDX = BUFER
		sub edi,edx					; EDI = size

		mov eax,core__params
		mov [eax.build_size],edi
		mov [eax.build_offset],edx

