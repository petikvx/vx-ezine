
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;
;Fixer ( jmp/call/jcc/loop )
;
;IN: 	EBX=list
;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

		xor edx,edx                                     ; 
		inc edx						; LAST_LABEL=1

		mov esi,[ebx.list_first]

@@fix_find:
		movzx AX,2 ptr [esi.one_data.ltmed_desc.lc_mask1]

		cmp AX,800Fh 					; 
		je @@fix 	                            	; <JCC a32>

		cmp AL,070h 					; <JCC a8>
		je @@fix                                        ;

		cmp AL,0EBh 					; <JMPS a8>
		je @@fix                                        ;

		cmp AL,0E9h 					; <JMP a32>
		je @@fix                                        ;

		cmp AL,0E8h 					; <CALL a32>
		je @@fix					;

		cmp AL,0E0h 					; <LOOPNZ>
		je @@fix                                        ;

		cmp AL,0E1h 					; <LOOPZ>
		je @@fix                                        ;

		cmp AL,0E2h 					; <LOOP>
		je @@fix					;

		cmp AL,0E0h 					; <JECXZ>
		jne @@fix_next                                  ;

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

@@fix:
		mov edi,esi					
		;EDI=current command

		mov ecx,4 ptr[edi.one_data.ltmed_desc.lc_operand]	; ECX=operand
		
	        cmp [edi.one_data.ltmed_desc.lc_soperand],1	; byte?
		jne @@fix_sign

		movsx ecx,cl

@@fix_sign:
;-----------------------------------------------------------------------------

		test ecx,ecx					; Sign?
		js @@fix_back                                   ;

		opzmov eax,one_next				; used offset - forward
                mov edi,[edi.one_next]				; do it from next command
		jmp @@fneg

;-----------------------------------------------------------------------------
@@fix_back:

		opzmov eax,one_prev				; used offset - back
@@fneg:

		neg ecx						; absolute
		js @@fneg

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

@@fixcompare_main:

		or ecx,ecx					
		jz @@fix_compare_finded


		push eax
		movzx eax,[edi.one_data.ltmed_desc.lc_size]     ; eax= cmd. size
		sub ecx,eax                                     ;
		pop eax

		opzcmp eax,one_next				; cmp eax,one_next
		jz @@fix_compare_next                    	; go back?

;-----------------------------------------------------------------------------

		or ecx,ecx					; linked?
		jz @@fix_compare_finded                         ;

		cmp edi,[ebx.list_first]
		jne @@fix_compare_next

;-----------------------------------------------------------------------------
@@fix_external:

		mov [esi.one_data.ltmed_flags],LTMED_EXTERNAL
		jmp @@fix_next

;-----------------------------------------------------------------------------
@@fix_compare_next:

		cmp edi,[ebx.list_last]
		je @@fix_external

		mov edi,[edi+eax]				; go to some elem.
		jmp @@fixcompare_main


;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

@@fix_compare_finded:

;edi=referenced command, esi=(jmp/call/...), edx= link number

		lea ecx,[edi.one_data.ltmed_label]		;ECX=ref_label
		lea eax,[esi.one_data.ltmed_link]		;EAX=cond_link

		mov edi,[ecx]					;edi=ref_label

		or edi,edi
		jnz @@fix_compare_label
		
		mov [ecx],edx					; set label
		mov edi,edx					;

		inc edx

@@fix_compare_label:
		mov [eax],edi					; set link

;------------------------------------------------------------------------------
@@fix_next:
		cmp esi,[ebx.list_last]
		je @@fix_exit

		mov esi,[esi.one_next]
		jmp @@fix_find


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

@@fix_exit:
		mov core__last_label,edx			;save last link(label)

