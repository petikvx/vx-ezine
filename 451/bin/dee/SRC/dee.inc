
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
; DEE v 1.32
; (c) 451 2002-03
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

include src\1.ash
include dee.ash

@d		      equ	      <+4*8+4>

@@__dflags	      equ             4 ptr[ebp+32 @d]
@@__dasmtbl	      equ             4 ptr[ebp+28 @d]
@@__dasm	      equ             4 ptr[ebp+24 @d]
@@__seed	      equ             4 ptr[ebp+20 @d]
@@__rnd		      equ             4 ptr[ebp+16 @d]
@@__free              equ             4 ptr[ebp+12 @d]
@@__malloc            equ             4 ptr[ebp+8  @d]
@@__csize             equ             4 ptr[ebp+4  @d]
@@__code              equ             4 ptr[ebp    @d]

dee:
                pusha
		mov ebp,esp

                mov esi,@@__code                                ; ESI = code
                mov ecx,@@__csize                               ; ECX = code size

                mov eax,ecx      				;
		shl eax,2                                       ;
		push eax                                        ; EDI = 
		call @@__malloc                                 ;  offsets bufer
		add esp,4                                       ;

		or eax,eax   					; error?
		jz _dee_error                                   ;

		xchg edi,eax
		push edi

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_dee_main:
                push @@__dasmtbl                                ; Table
		push 0                                          ;
                push esi                                        ; Cmd offset
		call @@__dasm
		add esp,4*3

                inc eax						; EBX 
                jz _dee_random                                  ;   = FFFFFFFF?
                dec eax                                         ;

		mov BL,AL					; BL = size

;------------------------------------------------------------------------------

		mov BH,1 ptr @@__dflags				; BH = flags
		mov AX,2 ptr[esi]

                cmp AL,0C3h                                     ; <RETN>
                je _dee_random                                  ;

                cmp AL,0CBh                                     ; <RETF>
                je _dee_random                                  ;

                cmp AL,0C2h                                     ; <RETN IM2>
                je _dee_random                                  ;

                cmp AL,0CAh                                     ; <RETF IM2>
                je _dee_random                                  ;

                cmp AL,0CFh                                     ; <IRET>
                je _dee_random                                  ;

                cmp AX,25FFh                                    ; <JMP [MEM]>
                je _dee_random					;


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		test BH,DEE_LINKS
		jz _dee_test5

		mov edx,4 ptr[esi+1]				; operand

                cmp AL,0EBh                                     ; <JMP IM8>
                je _dee_jump1

                cmp AL,0E9h                                     ; <JMP IM32>
                je _dee_jump4

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

_dee_test5:
		test BH,DEE_CMD5
		jnz _dee_testreal5

		cmp AL,0E8h					; <CALL> ?
		jne _dee_analyze_next

_dee_testreal5:

		cmp BL,5					; cmd_size > 5?
		jb _dee_analyze_next                            ;

		mov eax,esi					; save offset
		stosd                                           ;  to bufer

		jmp _dee_analyze_next

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
_dee_jump1:
		movsx edx,dl
_dee_jump4:
		add esi,edx

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
_dee_analyze_next:

		movzx ebx,bl
                add esi,ebx
				
		sub ecx,ebx
		jns _dee_main


;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
_dee_random:
		pop ecx						; ecx = bufer

		sub edi,ecx
		shr edi,2    					; EDI=entries cnt
		jz _dee_error                                   ; =0 ? 

		push edi
		push @@__seed
		call @@__rnd
		add esp,8
		
                mov eax,[ecx+eax*4]				; Adress

                push ecx
		call @@__free
		add esp,4
		
;------------------------------------------------------------------------------
_dee_exit:
		mov [esp._eax],eax
                popa
                ret

;------------------------------------------------------------------------------
_dee_error:
		xor eax,eax
		dec eax
		jmp _dee_exit

