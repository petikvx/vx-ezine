;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
; Garbage Generator
;
;IN: EBX = list 		
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

GARBAGE_ENTRIES		equ		4
garbage_gen:

		lea edi,m__temp
		mov esi,[ebx.list_first]

		xor edx,edx
		inc edx


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

garb_main:
                mov AX,2 ptr[esi.one_data.ltmed_desc.lc_mask1]

		cmp AL,00h					; <ADD>
		je garb_flagsm                                  ;

		cmp AL,08h					; <OR>
		je garb_flagsm                                  ;

		cmp AL,20h					; <AND>
		je garb_flagsm                                  ;

		cmp AL,28h					; <SUB>
		je garb_flagsm                                  ;

		cmp AL,30h					; <XOR>
		je garb_flagsm                                  ;

		cmp AL,38h					; <CMP>
		je garb_flagsm					;

		cmp AL,40h					; <INC>
		je garb_flagsm                                  ;

		cmp AL,48h					; <DEC>
		je garb_flagsm                                  ;

		cmp AL,69h					; <IMUL>
		je garb_flagsm                                  ;

		cmp AL,6Bh					; <IMUL>
		je garb_flagsm                                  ;

		cmp AL,84h					; <TEST>
		je garb_flagsm                                  ;

		cmp AL,9Dh					; <POPF>
		je garb_flagsm                                  ;

		cmp AX,0A40Fh					; 
		je garb_flagsm                                  ;
		                                                ; <SHLD>
		cmp AX,0A50Fh					; 
		je garb_flagsm                                  ;

		cmp AX,0AC0Fh					;
		je garb_flagsm                                  ;
		                                                ; <SHRD>  
		cmp AX,0AD0Fh					;
		je garb_flagsm                                  ;


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		mov AH,[esi.one_data.ltmed_desc.lc_ro]

		cmp AL,80h					; 80 group
		je garb_C0_80

		cmp AL,0C0h					; C0 group
		je garb_C0_80

		cmp AL,0D0h					; C0 group
		je garb_C0_80

		cmp AL,0D2h					; C0 group
		je garb_C0_80

		cmp AL,0F6h					; F6 group
		je garb_F6

		cmp AL,0FEh					; FE group
		je garb_FE                                      ;

		jmp garb_neutral

;° C0/80 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
garb_C0_80:
		cmp AH,010b					; <RCL/ADC>?
		je garb_neutral					;

		cmp AH,011b					; <RCR/SBB>?
		je garb_neutral					;

		jmp garb_flagsm

;° F6 °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
garb_F6:
		cmp AH,010b					; <NOT>?
		je garb_neutral					;

		jmp garb_flagsm

;° FE °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
garb_FE:
		cmp AH,000b					; <INC>?
		je garb_flagsm

		cmp AH,001b					; <DEC>?
		je garb_flagsm

		jmp garb_neutral


;± FLAGS-MODIFYNG GARBAGE ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
garb_flagsm:

;------------------------------------------------------------------------------
                push 80h                                        ;Ä¿
		push m__seed					; ³
                call m__rnd                                     ; ³
                add esp,8                                       ; ³ RANDOMIZE
                or eax,eax                                      ; ³    1/128
                jnz garb_next                                   ;ÄÙ
;------------------------------------------------------------------------------

		dec edx
		mov esi,[esi.one_prev]
		call data_clear
	
garb_80_get_ro:

		push 8						;
		push m__seed					;
		call m__rnd                                     ; CL= random
		add esp,8                                       ;   operation

		xchg eax,ecx

		cmp CL,010b					; <ADC>
		je garb_80_get_ro                               ;

		cmp CL,011b                                     ; <SBB>
		je garb_80_get_ro                               ;
		
		push 8    					;
		push m__seed					;
		call m__rnd                                     ; 
		add esp,8                                       ; CH = register
		                                                ;
		mov CH,AL					;


		xor EAX,EAX					; EAX =0

;------------------------------------------------------------------------------

		cmp CL,100b					; <AND> ?
		jne garb_80_cmp                                 ;

		dec EAX						; EAX= FFFFFFFF

;------------------------------------------------------------------------------
garb_80_cmp:		

		cmp CL,111b					; <CMP> ?
		jne garb_80_build                               ;

		dec eax						; push FFFFFFFF
		push eax                                        ;
		push m__seed					
                call m__rnd
                add esp,8

;------------------------------------------------------------------------------
garb_80_build:

		shl CL,3					;
		or CH,CL                                        ; CH = modrm
		or CH,11000000b                                 ;

		mov CL,80h					; 80 group

		push ebx
		push eax

		mov BL,2					; size opcode&modrm=2
		mov BH,1                                        ; operand size=1

;------------------------------------------------------------------------------

		push 2                                          ;
		push m__seed					;
		call m__rnd                                     ; random S
		add esp,8                                       ;

		or eax,eax					
		jz garb_80_w

		or CL,10b                                       ; S = 1
		jmp garb_80_store

;------------------------------------------------------------------------------
garb_80_w:

		push 2                                          ;
		push m__seed					;
		call m__rnd                                     ; random W
		add esp,8                                       ;

		or eax,eax					
		jz garb_80_store

		or CL,1 	                                ; W = 1
		mov BH,4					; operand size=4

;------------------------------------------------------------------------------
garb_80_prefix:

		push 2                                          ;
		push m__seed					;
		call m__rnd                                     ; random prefix
		add esp,8                                       ;

		or eax,eax
		jz garb_80_store

		shl ecx,8
		mov cl,66h
		inc BL
		mov BH,2					; word operand

garb_80_store:
		pop eax

		mov 4 ptr[edi.ltmed_command],ecx
		add BH,BL
		mov [edi.ltmed_desc.lc_size],BH
		movzx ebx,BL

		mov 4 ptr[edi.ltmed_command+ebx],eax		; operand
		mov [edi.ltmed_desc.lc_flags],LF_RAW

		pop ebx
		call list_add

		inc edx
		mov esi,[esi.one_next]

		jmp garb_refresh


;± NEUTRAL ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

garb_neutral:

;------------------------------------------------------------------------------
                push 100h                                       ;Ä¿
		push m__seed					; ³
                call m__rnd                                     ; ³
                add esp,8                                       ; ³ RANDOMIZE
                or eax,eax                                      ; ³    1/256
                jnz garb_next                                   ;ÄÙ
;------------------------------------------------------------------------------


		push GARBAGE_ENTRIES
		push m__seed
		call m__rnd
	        add esp,8

		call data_clear

		or eax,eax					; <0> NOP
		jz garb_nop                                     ;

		dec eax						; <1> XCHG
		jz garb_xchg                                    ;

		dec eax						; <2> MOV
		je garb_mov                                     ;

		jmp garb_lea					; <3> LEA
		                                                ;

;° NOP °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
garb_nop:
		mov 1 ptr[edi.ltmed_command],__CMD_NOP
		inc [edi.ltmed_desc.lc_size]			; Size = 1

		mov [edi.ltmed_desc.lc_flags],LF_RAW
		call list_add
		
		jmp garb_refresh

;° MOV °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
garb_mov:
		mov CL,__MASK_MOV
		jmp garb_mov_xchg


;° XCHG °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
garb_xchg:
		mov CL,__MASK_XCHG

garb_mov_xchg:

		push 2                                          ;
		push m__seed					;
		call m__rnd                                     ; 
		add esp,8					; set W = 0/1
		                                                ;
		or CL,AL					; 

		push 8                                          ;
		push m__seed					;
		call m__rnd					; get register
	        add esp,8                                       ; EAX= 0 .. 7

		mov AH,AL                                       ;
		shl AL,3                                        ; R/O=R/M
		or AH,AL                                        ;
		or AH,11000000b					; MOD = 11

		mov CH,AH					; CH = MODRM

		mov [edi.ltmed_desc.lc_size],2

		test CL,1					; W = 1 ??
		jz garb_xchg_mov_np

;-----------------------------------------------------------------------------

		push 2						;
		push m__seed					;
		call m__rnd                                     ;
		add esp,8                                       ; Add prefix?
								;
		or eax,eax                                      ; 
		jz garb_xchg_mov_np                             ;

		shl ECX,8
		mov CL,66h					; add prefix
		inc [edi.ltmed_desc.lc_size]

;-----------------------------------------------------------------------------
garb_xchg_mov_np:

		mov 4 ptr[edi.ltmed_command],ECX
		mov [edi.ltmed_desc.lc_flags],LF_RAW
		call list_add

		jmp garb_refresh

;° LEA °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
garb_lea:
		push 8   					;
		push m__seed					;
		call m__rnd                                     ; get register
		add esp,8                                       ;

		cmp AL,100b					; ESP?
		jne garb_lea_next				;
		inc eax						; EBP!
garb_lea_next:
		xor ecx,ecx

		mov CH,01000000b				; BYTE offset
		or CH,AL                                        ;
		shl AL,3                                        ;
		or CH,AL		                        ; R/O = R/W

		mov CL,__CMD_LEA 

		mov 4 ptr[edi.ltmed_command],ECX
		mov [edi.ltmed_desc.lc_size],3
		mov [edi.ltmed_desc.lc_flags],LF_RAW

		call list_add


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
garb_refresh:

		inc edx
		mov esi,[esi]

garb_next:
		cmp esi,[ebx.list_last]
		je garb_exit

		inc edx
		mov esi,[esi.one_next]
		jmp garb_main
garb_exit:


