;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
; Code exchanging part
;
;IN: EBX = list
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²


;Exchanges commands:
;
;  1  opc r8/16/32,i8/16/32    
;  2  opc r8/16/32,r8/16/32    
;  3  opc r8/16/32,m8/16/32


                mov esi,[ebx.list_first]

                xor edx,edx
		inc edx

xchg_find:
                cmp esi,[ebx.list_last] 
		je xchg_end

		push ebx

                mov edi,[esi.one_next]				; EDI = next

;°° CHECK LABELS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		xor eax,eax

;		cmp [esi.one_data.ltmed_label],eax
;		jne xchg_next

		cmp [edi.one_data.ltmed_label],eax
		jne xchg_next


;°° CHECK MASKS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

                mov ax,2 ptr[esi.one_data.ltmed_desc.lc_mask1]
                cmp 2 ptr[edi.one_data.ltmed_desc.lc_mask1],ax
                jne xchg_next

;° TEST REGS °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

                mov eax,[esi.one_data.ltmed_desc.lc_flags]      ; EAX = flags #1
                mov ecx,[edi.one_data.ltmed_desc.lc_flags]      ; ECX = flags #2 
                                                                ;
                test eax,LF_REG2        		        ; #1 REG2 (r/o)?
                jz xchg_next

                test eax,(LF_REG1+LF_BASE)  	                ; #1 REG1/BASE?
                jnz xchg_test_reg_im2				;

		test eax,LF_OPERAND     			; #1 Operand?
		jz xchg_next

;------------------------------------------------------------------------------

xchg_test_reg_im2:

                test ecx,LF_REG2				; #2 REG2?
                jz xchg_next

                test ecx,(LF_REG1+LF_BASE)               	; #2 REG1/BASE?
                jnz xchg_test_flags				;
                                             			
		test ecx,LF_OPERAND     			; #2 Operand
		jz xchg_next

xchg_test_flags:
;° TEST D °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;EAX = #1  flags
;ECX = #2  flags

                test eax,LF_D					; D or S/nothing ?
		jz xchg_references
		
		test eax,LF_MEM					; #1 Memory use?
		jz xchg_1_no_mem

		test eax,LF_SDV                                 ; #1 d=0 r/o->[r/w]
		jz xchg_next					;    d=1 [r/w]->r/o

xchg_1_no_mem:
                test ecx,LF_D					; D or S/nothing ?
		jz xchg_references

                test ecx,LF_MEM                                 ; #2 Memory use?
		jz xchg_references

		test ecx,LF_SDV                                 ; #2 d=0 r/o->[r/m]
		jz xchg_next					;    d=1 [r/m]->r/o


;° CHECK REFERENCES °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

xchg_references:

                mov AL,[esi.one_data.ltmed_desc.lc_ro]          ; #1 AL = REG2(r/o)
                mov AH,[edi.one_data.ltmed_desc.lc_ro]          ; #2 AH = REG2(r/o)

                mov CL,[esi.one_data.ltmed_desc.lc_index]       ; #1 CL = INDEX
                mov CH,[edi.one_data.ltmed_desc.lc_index]       ; #2 CH = INDEX

;-----------------------------------------------------------------------------
xchg_1baserw:
		test [esi.one_data.ltmed_desc.lc_flags],LF_BASE
		jz xchg_1_rw

                mov BL,[esi.one_data.ltmed_desc.lc_base]    	; #1 BL = BASE
        	jmp xchg_2baserw                                ;       
xchg_1_rw:                                                      ;       
                mov BL,[esi.one_data.ltmed_desc.lc_rm]    	; #1 BL = REG1(r/m)

;-----------------------------------------------------------------------------
xchg_2baserw:
		test [edi.one_data.ltmed_desc.lc_flags],LF_BASE
		jz xchg_2_rw

                mov BH,[edi.one_data.ltmed_desc.lc_base]    	; #2 BH = BASE
		jmp xchg_getregs                                ;       
xchg_2_rw:                                                      ;       
                mov BH,[edi.one_data.ltmed_desc.lc_rm]          ; #2 BH = REG1(r/m)

;-----------------------------------------------------------------------------
xchg_getregs:
		test [esi.one_data.ltmed_desc.lc_flags],LF_D
		jz xchg_mem2_coll

		test [esi.one_data.ltmed_desc.lc_flags],LF_SDV
		jnz xchg_mem2_coll				; D=0?

		xchg  AL,BL					; #1 REG1 = r/o
		                                                ; #1 REG2 = r/m(base)
xchg_mem2_coll:
		test [edi.one_data.ltmed_desc.lc_flags],LF_D
		jz xchg__collisions

		test [edi.one_data.ltmed_desc.lc_flags],LF_SDV
		jnz xchg__collisions                              ; D(present) = 0?

		xchg  AH,BH					; #2 REG1 = r/o
		                                                ; #2 REG2 = r/m (base)
xchg__collisions:

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


;#1       CMD REG2,[REG1+INDEX]
;                   ³     ³
;              ³     ³     ³
;              ³ÚÄÄÄÄÁÄÄÄÄÄÙ
;              ÀÅÄÄÄÄÄÄÄ¿
;               ³       ³
;               ³    ÚÄÄÁÄÄ¿
;                   ³     ³
;#2       CMD REG2,[REG1+INDEX]
;
;
;AL= 1#REG2	BL= 1#REG1	CL= 1#INDEX
;AH= 2#REG2	BH= 2#REG1	CH= 2#INDEX

		test [edi.one_data.ltmed_desc.lc_flags],(LF_REG1+LF_BASE)
		jz xchg_coll1_index

                cmp AL,BH					; 1#REG2 
                je xchg_next                                    ; = 2#REG1 ?

xchg_coll1_index:

                test [edi.one_data.ltmed_desc.lc_flags],LF_INDEX
                jz xchg_coll1_no_index

                cmp AL,CH		 			; 1#REG2 
                je xchg_next                                    ; =2#INDEX ?

xchg_coll1_no_index:

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


		test [esi.one_data.ltmed_desc.lc_flags],(LF_REG1+LF_BASE)
		jz xchg_coll2_index

                cmp AH,BL					; 2#REG2 
                je xchg_next                                    ;  = 1#REG1 ?

xchg_coll2_index:

                test [esi.one_data.ltmed_desc.lc_flags],LF_INDEX
                jz xchg_coll2_no_index

                cmp AH,CL             				; 2#REG2 
                je xchg_next                                    ;  =1#INDEX ?
                                                                   

xchg_coll2_no_index:

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;[TEST LOW-HIGH WORD(S) COLLISIONS]

		cmp AL,AH
		jne xchg_swap

                mov eax,[esi.one_data.ltmed_desc.lc_flags]
                mov ecx,[edi.one_data.ltmed_desc.lc_flags]

		and eax,LF_WV+LF_W
		and ecx,LF_WV+LF_W

		cmp eax,ecx				
		jne xchg_next

;[TEST PREFIXES]

		mov eax,[esi.one_data.ltmed_desc.lc_flags]
		mov ecx,[edi.one_data.ltmed_desc.lc_flags]

		and eax,LF_POF+LF_POP
		and ecx,LF_POF+LF_POP
		
		cmp eax,ecx
		jne xchg_next
xchg_swap:
                ;ebx = list
		;edx = #1

;------------------------------------------------------------------------------

                push 5                                          ;Ä¿
		push m__seed					; ³
                call m__rnd                                     ; ³
                add esp,8                                       ; ³ RANDOMIZE
                or eax,eax                                      ; ³    4/5
                jz xchg_next                                    ;ÄÙ

;------------------------------------------------------------------------------

                mov eax,[esi.one_data.ltmed_label]
		mov ecx,[edi.one_data.ltmed_label]

		mov [esi.one_data.ltmed_label],ecx
		mov [edi.one_data.ltmed_label],eax

		mov ebx,m__list
		mov ecx,edx
		inc ecx

                call list_swap

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

xchg_next:
		pop ebx

                inc edx
                mov esi,[esi.one_next]
                jmp xchg_find

xchg_end: