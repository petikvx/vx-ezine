;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
; Jmp Mutation Module
;
;IN:	EBX = list
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

		lea edi,m__temp

		mov esi,[ebx.list_first]

		xor edx,edx
		inc edx

jmp_mut_main:
		cmp esi,[ebx.list_last]				; last?
		je jmp_mut_exit

		cmp 2 ptr[esi.one_data.ltmed_desc.lc_mask1],800Fh 
		jne jmp_mut_next

;-----------------------------------------------------------------------------

		mov eax,[esi.one_next]				; JCC+1

		cmp [eax.one_data.ltmed_desc.lc_mask1],0E9h	; <JMP> ?
		jne jmp_mut_inverse				;

		cmp eax,[ebx.list_last]
		je jmp_mut_inverse

		mov ecx,[eax.one_next]				; JCC+2

		mov ecx,[ecx.one_data.ltmed_label]
		mov eax,[eax.one_data.ltmed_link]

		cmp [esi.one_data.ltmed_link],ecx		; mutated ?
		jne jmp_mut_inverse

;° REPAIR °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;------------------------------------------------------------------------------
		push eax

                push 30                                         ;Ä¿
		push m__seed					; ³
                call m__rnd                                     ; ³ RANDOMIZE
                add esp,8                                       ; ³    1/30 
                or eax,eax                                      ;ÄÙ

		pop eax
                jnz jmp_mut_next                                
;------------------------------------------------------------------------------

		xor [esi.one_data.ltmed_command+1],1
		mov [esi.one_data.ltmed_link],eax

		inc edx
		call list_kill

		dec edx
		jmp jmp_mut_next


;° MUTATE °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
jmp_mut_inverse:

;------------------------------------------------------------------------------
                push 5                                          ;Ä¿
		push m__seed					; ³
                call m__rnd                                     ; ³
                add esp,8                                       ; ³ RANDOMIZE
                or eax,eax                                      ; ³    1/5
                jnz jmp_mut_next                                ;ÄÙ
;------------------------------------------------------------------------------

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		xor [esi.one_data.ltmed_command+1],1            ; inverse condition

		lea eax,[esi.one_data.ltmed_link]		; EAX =ofs. link
		mov ecx,[eax]                                   ; ECX =link

		push edx
		inc edx
		call verify_label
		mov [eax],edx
		pop edx

;-----------------------------------------------------------------------------
		call data_clear

		mov AL,0E9h					; 
		mov 1 ptr[edi.ltmed_command],AL                 ;
		mov [edi.ltmed_desc.lc_mask1],AL                ;
		                                                ;
		mov [edi.ltmed_desc.lc_soperand],4              ;    <JMP>
		mov [edi.ltmed_desc.lc_size],5                  ;
		mov [edi.ltmed_link],ecx                        ;
		call list_add					;


		inc edx
		mov esi,[esi.one_next]				; esi= jmp ofst.

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

jmp_mut_next:

		inc edx
		mov esi,[esi.one_next]
		jmp jmp_mut_main

jmp_mut_exit:
