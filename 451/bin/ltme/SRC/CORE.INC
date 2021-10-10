;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;  LTME core
;
;  2002 (c) 451
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

include src\keys.ash
include src\macros.ash

@d		equ	<+8*4+4>

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

core__seed		equ	4 ptr [ebp+40 @d]
core__rnd		equ	4 ptr [ebp+36 @d]
core__params		equ	4 ptr [ebp+32 @d]
core__flags		equ	4 ptr [ebp+28 @d]
core__dtbl		equ	4 ptr [ebp+24 @d]
core__dasm		equ	4 ptr [ebp+20 @d]
core__mutator		equ	4 ptr [ebp+16 @d]
core__csize		equ	4 ptr [ebp+12 @d]

;------------------------------------------------------------------------------

core__free		equ	4 ptr [ebp+8  @d]
core__malloc		equ	4 ptr [ebp+4  @d]
core__ibuf		equ	4 ptr [ebp    @d]

;------------------------------------------------------------------------------

core__last_label    	equ     4 ptr [ebp-SIZE ltmedata-8]
core__list		equ 	4 ptr [ebp-SIZE ltmedata-4]
core__temp		equ	      [ebp-SIZE ltmedata]

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
core:
		pusha

		mov ebp,esp
		ntsub <SIZE ltmedata+8>
		
;-----------------------------------------------------------------------------
ifdef DYNAMIC_LIST

		push 8						; list header size
else 
		imul eax,core__csize,(SIZE one)*5		;
                push eax                                        ; static list bufer
endif
;-----------------------------------------------------------------------------
		call core__malloc
		add esp,4

		or eax,eax					; error?
		jz @@core_error                                 ;


		xchg ebx,eax
		mov core__list,ebx

		call list_init					; INIT LIST

		;EBX=list
		mov ecx,core__csize
		mov esi,core__ibuf
		lea edi,core__temp

		xor edx,edx					; EDX = FFFFFFFF
		dec edx                                         ; (for list_add)
		
@@dasm_main:
		call data_clear                                 ; clear bufer

		push core__dtbl					; - tables
		push edi					; - temp.cmd
		push esi                                        ; - in bufer
		call core__dasm					
		add esp,4*3

		sub ecx,eax
		jb @@dasm_exit

		inc eax                                         ;
		jz @@core_error                                 ; error?
		dec eax                                         ;

;-----------------------------------------------------------------------------
		;ESI=ibuf
		push ecx
                push edi
		xchg ecx,eax					; ecx=command size
		lea edi,[edi.ltmed_command]				
		rep movsb					; copy command
                pop edi
		pop ecx

                ;esi=esi+cmd_size
;-----------------------------------------------------------------------------

		call list_add                                   ; add to list
		jmp  @@dasm_main
@@dasm_exit:

;EBX=bufer		
;------------------------------------------------------------------------------

		include src\core\fixer.inc			; fix labels

		include src\core\jmps.inc			; convert jmp/call/...

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		push core__free                                 ; free
		push core__malloc				; malloc
		push core__seed                                 ; seed
		push core__rnd                                  ; rnd
		push core__params				; params
		push core__flags                                ; flags

		lea eax,core__last_label                        ; last label ptr
		push eax                                        ;
		push ebx					; list
		push core__csize				; code size

		call core__mutator
		add esp,4*9
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°


		include src\core\linker.inc			;link list

		include src\core\builder.inc			;build code

;------------------------------------------------------------------------------


		push ebx					;
		call core__free					; release list
		add esp,4                                       ;
		
                xor eax,eax                                     ; error code = 0
@@core_exit:

		ntadd <SIZE ltmedata+8>				; release stack bufer
		mov [esp._eax],eax				; eax=size
		popa
		ret

@@core_error:
		xor eax,eax	                                ; error code
		dec eax
		jmp @@core_exit	


include src\core\list.inc
include src\core\add.inc
