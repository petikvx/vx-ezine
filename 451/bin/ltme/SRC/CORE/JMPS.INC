
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;
; Jmps/call/loop  JMP/CALL converter 
;
;IN: 	EBX = list
;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�

		lea edi,core__temp
        	mov esi,[ebx.list_first]
		             
		xor edx,edx
		inc edx

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
jmps_find:
		mov AL,[esi.one_data.ltmed_desc.lc_mask1]
		           	
		cmp AL,0EBh 				  	; JMPS a8 
		je ___jmp                                       ;

		cmp AL,070h 	   			   	; JCC a8 
		je ___jcc                                       ;

		cmp AL,0E0h					; LOOPNZ 
		jb jmps_find_next                               ;   
		                                                ;   
		cmp AL,0E3h                                     ; JECXZ
		ja jmps_find_next                               ; 
	

;� E0 - E3 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�

		xchg eax,ecx					; CL =mask
		call data_clear

		mov eax,[esi.one_data.ltmed_link]		; EAX = link

		push 4 ptr[esi.one_data.ltmed_label]            ;
		pop 4 ptr [edi.ltmed_label]			; copy label

		;EBX=list
		;EDX=elem num
		call list_kill
                dec edx

		cmp CL,0E0h 	   			   	;LOOPNZ/LOOPNE
		je ___loopnz                                    ;

		cmp CL,0E1h 	   			   	;LOOPZ/LOOPE
		je ___loopz                                     ;

		cmp CL,0E3h 	   			   	;JECXZ/JCXZ a8
		je ___jecxz                                     ;

;		cmp AL,0E2h 	   			   	;LOOP
;		je ___loop                                      ;


;� LOOP 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
;
; 	LOOP LABEL 	 DEC ECX
;  			 JNZ LABEL
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
___loop:
		mov 1 ptr[edi.ltmed_command],49h		; 
		mov 1 ptr[edi.ltmed_desc.lc_mask1],48h		; <DEC ECX>
		inc [edi.ltmed_desc.lc_size]			;
		call list_add

		mov CH,05h                                      ; <NZ>
		jmp ___E0_ZNZ


;� LOOPNZ 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
;
;	  LOOPNZ LABEL   JZ LABEL_EXIT
;			 DEC ECX
;			 JNZ LABEL
;	     LABEL_EXIT:
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�

___loopnz:		
		mov CH,04h					; <Z>
__loop_ZNZ:

		push eax					;
		mov AX,800Fh                                    ;
        	mov 2 ptr[edi.ltmed_desc.lc_mask1],AX           ;
		or AH,CH                                        ; <JZ /JNZ>
		mov 2 ptr[edi.ltmed_command],AX                 ;
		pop eax                                         ;

		push edx
		add edx,4
		call verify_label
		mov [edi.ltmed_link],edx
		pop edx

		mov [edi.ltmed_desc.lc_size],6
		mov [edi.ltmed_desc.lc_soperand],4

		call list_add
		inc edx

		call data_clear
		jmp ___loop


;� LOOPZ 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇
;        
; LOOPZ  ->  		JNZ LABEL_EXIT
;			DEC ECX
;               	JNZ LABEL
;	     LABEL_EXIT:
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�

___loopz:		
		mov CH,05h					; <NZ>
		jmp __loop_ZNZ


	
;� JMP 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�

___jmp:
		mov AL,0E9h
		mov [esi.one_data.ltmed_desc.lc_mask1],AL
		mov 1 ptr[esi.one_data.ltmed_command],AL
		
		mov CL,5                                        ; lc_size(5)
		jmp __jmpcc_size
		  
;� JCC 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
___jcc:
                mov AX,800Fh					; JCC mask

		mov 2 ptr[esi.one_data.ltmed_desc.lc_mask1],AX
                or AH,[esi.one_data.ltmed_desc.lc_tttn]         ; add tttn
		mov 2 ptr[esi.one_data.ltmed_command],AX

		mov CL,6                                        ; lc_size(6)

__jmpcc_size:

		mov [esi.one_data.ltmed_desc.lc_size],CL
		mov [esi.one_data.ltmed_desc.lc_soperand],4

		jmp jmps_find_next


;� JECXZ 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
___jecxz:		
		push eax		

		mov EAX,000C90B66h			        ;<OR CX,CX>
		mov CL,3					;

		test [esi.one_data.ltmed_desc.lc_flags],LF_POF
		jnz ___jcxz

		shr EAX,8
		dec ecx						; CL = 2
___jcxz:

		mov 4 ptr[edi.ltmed_command],EAX
		mov [edi.ltmed_desc.lc_size],CL
		call list_add

		pop eax

		mov CH,04h                                       ; <Z>

;------------------------------------------------------------------------------
___E0_ZNZ:
		call data_clear
		inc edx

		mov [edi.ltmed_link],eax
		mov [edi.ltmed_desc.lc_size],6
		mov [edi.ltmed_desc.lc_soperand],4

		mov AX,800Fh					;
		mov 2 ptr[edi.ltmed_desc.lc_mask1],AX           ; <JZ/JNZ A32>
		or  AH,CH					;
		mov 2 ptr[edi.ltmed_command],AX                 ;

		call list_add
		inc edx

		call list_get
		xchg esi,eax


;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
jmps_find_next:

		cmp esi,[ebx.list_last]
		je jmps_exit

		inc edx
		mov esi,[esi.one_next]
		jmp jmps_find

jmps_exit:




