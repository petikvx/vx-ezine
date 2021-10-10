
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;Linker
;
;IN:  EBX=list
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²


;° HASH LABELS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		mov eax,core__last_label                ; Labels list
		shl eax,2				;
		push eax
		call core__malloc
		add esp,4

		or eax,eax				; error?
		jz @@core_error                         ;


		xchg edi,eax				; EDI = hash table
;------------------------------------------------------------------------------

		xor edx,edx                             ; start from 1
		inc edx					;

		mov esi,[ebx.list_first]

		push edx
		push esi

;------------------------------------------------------------------------------

@@__hash_lab:
		mov eax,[esi.one_data.ltmed_label]

		or eax,eax					
		jz @@__hash_lab_next

		mov [edi+eax*4],edx

@@__hash_lab_next:

		cmp esi,[ebx.list_last]
		je @@__hash_exit

		inc edx
		mov esi,[esi.one_next]
		jmp @@__hash_lab
@@__hash_exit:
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;EDI = hash table
		pop esi					; first
		pop edx
	
;		xor edx,edx                             ; current elementh num
;		inc edx                                 ;


@@link_main:
		mov ecx,[esi.one_data.ltmed_link]	;ECX =link

		or ecx,ecx
		jz @@link_next

;° PROCESS LINK °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

;EDX=cur_elem num
;ESI=current elementh
;ECX=link
		push edi
		push edx

		mov eax,[edi+ecx*4]			; EAX=label num

		mov edi,esi
		xor ecx,ecx

;-----------------------------------------------------------------------------

		cmp edx,eax
		jb @@link_forward
;CUR >= LABEL
   		sub edx,eax
		inc edx

		opzmov eax,one_prev
		jmp @@link_calc

@@link_forward:
; CUR < LABEL

		sub eax,edx
		xchg eax,edx
		dec edx

		mov edi,[edi.one_next]
		opzmov eax,one_next

;-----------------------------------------------------------------------------
@@link_calc:
		or edx,edx
		jz @@link_patch
		
		dec edx

		push eax
		movzx eax,[edi.one_data.ltmed_desc.lc_size]
		add ecx,eax
		pop eax

		mov edi,[edi+eax]
		jmp @@link_calc

;------------------------------------------------------------------------------

@@link_patch:
                pop edx
		pop edi

		opzcmp eax,one_next
		je @@link_noneg

		neg ecx					; previous label delta
@@link_noneg:

		movzx eax,[esi.one_data.ltmed_desc.lc_size]
		sub AL,[esi.one_data.ltmed_desc.lc_soperand]
 		mov 4 ptr [esi.one_data.ltmed_command+eax],ecx
@@link_next:
		inc edx
	        cmp esi,[ebx.list_last]
	        je @@link_end
 
		mov esi,[esi.one_next]
		jmp @@link_main
@@link_end:

		push edi				;
		call core__free                         ; release bufer
		add esp,4                               ;

