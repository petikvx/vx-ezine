
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;
;IN:	 EDI=bufer
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
data_clear:
		pusha

		xor eax,eax
		opzmov ecx,<SIZE ltmedata>
		rep stosb

		popa
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;
;VERIFY LABEL
;
;IN: 	 EBX = List
;	 EDX = EL. num
;
;OUT: 	 EDX = existed or new label
;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
verify_label:
		pusha

		call list_get		
                ;EAX=adress

		lea edi,[eax.one_data.ltmed_label]
		mov edx,[edi]				; EAX = label

		or edx,edx				; exist?
		jnz verify_exist
		
		mov edx,core__last_label
		inc core__last_label

		mov [edi],edx				; write label
verify_exist:
		mov [esp._edx],edx
		popa
		ret

