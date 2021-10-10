;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;Code mixing part
;
;IN: EBX = list
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

mixing:

		lea edi,m__temp
		mov eax,m__params

		push 4 ptr[eax.mixer_maxswp]		;
		push m__seed				;
		call m__rnd                             ;
		add esp,8                               ; ECX = Blocks count
		                                        ;
		xchg ecx,eax                            ;
		inc ecx                                 ;

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
mixing_main:
		push ecx
		push edi

		call data_clear				; Clear bufer

		call list_getmax

		mov ecx,eax				; ECX = EAX = Max
		sub eax,2

;° LINK 2 NEAR CMD 1°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		push eax				;
		push m__seed				;
		call m__rnd				;
		add esp,8                               ; EDX = #1 (1  max-2) 
		xchg edx,eax				; 
		inc edx					; 

		sub ecx,edx     			; 
		dec ecx         			;

		push ecx				;
		push m__seed				;
		call m__rnd                             ; ECX = (#1  max-1)
		add esp,8				;
		xchg ecx,eax				;
		inc ecx					;

		push edx
		inc edx
		call verify_label
		mov [edi.ltmed_link],EDX
		pop edx
		
		mov 1 ptr[edi.ltmed_command],0E9h	;  
		mov [edi.ltmed_desc.lc_soperand],4      ;  <JMP  #1+1>
		mov [edi.ltmed_desc.lc_size],5          ;
		call list_add                           ;

;° LINK 2 NEAR CMD 2°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		inc edx
		inc edx					; EDX = #1+1
		call list_get                           ;

		lea edx,[(edx-1) + ecx]			; EDX = # 2

		xchg ecx,eax				; ECX = Adr #1+1
		
		push edx
		inc edx
		call verify_label
		mov [edi.ltmed_link],EDX
		pop edx

		call list_add           		; <JMP  #2+1>

		inc edx                                 ;
		call list_get				;
		xchg esi,eax				; ESI = Adr <JMP  #2+1>

;° CUT BLOCK °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;ECX = Adr #1 + 1
;ESI = Adr JMP  (#2+1)

		mov eax,[ecx.one_prev]                  ; EAX = (#1 + 1)-1 = JMP  (#1+1)
		mov edx,[esi.one_next]			; EDX = (JMP  (#2 + 1))+1

                mov [eax.one_next],edx			; (#1-1).next = (#2+1)
		mov [edx.one_prev],eax                  ; (#2+1).prev = (#1-1)
		
;° CREATE HOLE °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		call list_getmax			;
		sub eax,2				;
		push eax				; 
		push m__seed				;
		call m__rnd                             ;
		add esp,8                               ; EDX = #R1 (1  (max-1))
		xchg edx,eax                            ;
		inc edx                                 ;  

		push edx
		inc edx
		call verify_label
		mov [edi.ltmed_link],edx		
		pop edx
		call list_add                           ; <JMP #R1+1>

		inc edx
		call list_get
		xchg edi,eax				; EDI = Adr <JMP #R1+1>

		mov edx,[edi.one_next]			; EDX = Adr <JMP (#R1+1)>+1


;° INSERT BLOCK °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;ECX = Adr #1+1
;ESI = Adr #2

;EDI = JMP
;EDX = LABEL

		mov [edi.one_next],ecx
		mov [ecx.one_prev],edi

		mov [esi.one_next],edx
		mov [edx.one_prev],esi


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

		pop edi
		pop ecx

		dec ecx
		jnz mixing_main



