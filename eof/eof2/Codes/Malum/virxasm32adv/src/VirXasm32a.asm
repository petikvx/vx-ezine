
	;;      \\  /      ;;
	;;  \\/  \\/ASM    ;;
	;;   VIR /\\       ;;
	;;      /  \\      ;;
	;;                 ;;
	;; VirXasm32 v1.5a ;;
	;; (X) Malum 2006  ;;

; Length Disassembler Engine VirXasm32 v1.5a
; Total size: 333 (14Dh) bytes
; INPUT:  esi = address of instruction
; OUTPUT: eax = instruction length

_salc equ <db 0D6h>     ;sbb al,al but not change flags
_aam macro num	;ah=al/num;al=al mod num
 db 0D4h, num
endm
_aad macro num	;al=ah*num+al;ah=0
 db 0D5h, num
endm

; ==========[ disassemble instruction from esi ]===========
VirXasm32:
	pushad
	sub	esp, 110	; reserve stack for unpacked tables
; ==========[ unpack tables to stack ]==========
	cld
	mov	edi, esp	; edi = addr. of buffer for unpacked tables
	push	esi		; store esi
	call	xa_skip_tab	; trick from roy g biv's lde :)
	
; total packed tables' size is 60 bytes

_00h equ <>
d0   equ <>

; Unpack info bits
xa_UnpackInfoBits:
dd 00000000000100011110101001011000b
dd 10111111101100011111001100111110b
dd 10110000101011000000101110000000b
db 11001b

xa_StartTables:
; line info bits (0xh-Fxh)
xa_NrmLnAttrs:
db 054h, 011h
; mod r/m info bits
db _00h  _00h  00Ch, 00Ah  ; 040h-060h
db _00h  0FFh, 0FFh  _00h  ; 070h-090h
db _00h  _00h  _00h  0F3h  ; 0A0h-0C0h
db _00h  0F3h, _00h  088h  ; 0C0h-0F0h
db 00Fh 		   ; 00h-30h
; immediate values info bits
d0 _00h  _00h  _00h  _00h  ; 040h, 050h
db _00h  _00h  05Fh  _00h  ; 060h, 060h
db 055h, 055h, 05Dh  _00h  ; 070h, 080h
d0 _00h  _00h  _00h  _00h  ; 080h, 090h
db _00h  _00h  00Dh  _00h  ; 0A0h, 0A0h
db 055h, 0FFh, 005h, 0D0h  ; 0B0h, 0C0h
db 001h, 004h, 010h  _00h  ; 0C0h, 0D0h
db 055h, 007h  _00h  _00h  ; 0E0h, 0F0h
db _00h  00Dh		   ; 00h-30h
NrmTabLen = 53

; line info bits (0xh-Fxh)
xa_ExtLnAttrs:
db 0C4h, 00Eh
; mod r/m info bits
db 00Fh, 0A0h  _00h  _00h  ; 000h, 030h
db 07Fh, 0FFh  _00h  _00h  ; 070h, 080h
db 0F8h, 0F8h, 0FFh, 0FFh  ; 0A0h, 0B0h
db 0FFh  _00h  _00h  _00h  ; 0C0h  null
d0 _00h 		   ; null
; immediate values info bits
d0 _00h  _00h  _00h  _00h  ; 000h
d0 _00h  _00h  _00h  _00h  ; 030h
db 055h  _00h  _00h  _00h  ; 070h
db 0FFh, 0FFh, 0FFh, 0FFh  ; 080h
db _00h  001h, _00h  001h  ; 0A0h
db _00h  _00h  010h  _00h  ; 0B0h
db 010h, 015h  _00h  _00h  ; 0C0h

xa_skip_tab:	
	pop	ebx		; ebx = address of unpack info bits
	lea	esi, [ebx+13]	; esi = address of packed tables
	push	100
	pop	ecx		; total size of unpacked tables is 100 bytes
xa_nxtIndx:			;*xor al,al
	bt	[ebx], ecx
	_salc			; if bit==0 then al=0
	jnc	xa_is0		; if bit!=0 then ...
	lodsb			; ... load byte from tables in AL ...
xa_is0: stosb			; ... else write zero
	loop	xa_nxtIndx	; next byte
	pop	esi		; restore esi
; ==========[ process fucking opcodes ]==========
	push	2
	pop	ebx		; ebx=2 (current mode - 32 bits)
	mov	edx, ebx	; edx=2 (current addressing mode - 32 bits)
xa_NxtByte:
	lodsb
	push	eax
	push	eax		; double store AL
	cmp	al, 66h 	; if 66h present then ...
	cmove	ebx, ecx	; ... ebx=ecx=0 (current mode - 16 bits)
	cmp	al, 67h 	; if 67h present then ...
	cmove	edx, ecx	; ... edx=ecx=0 (current addr mode - 16 bits)
	cmp	al, 0EAh	; JMP FAR
	je	xa_jmp
	cmp	al, 09Ah	; CALL FAR
	jne	xa_nocall
xa_cll: inc	esi
xa_jmp: lea	esi, [esi+ebx+3]	; for JMP byte imm will be later
xa_nocall:
	cmp	al, 0C8h	; fucking ENTER i16,i8  :[|
	je	xa_i16
	and	al, 0F7h	; C2h, CAh
	cmp	al, 0C2h	; IRET i16 RET i16  :[
	jne	xa_no16
xa_i16: inc	esi
	inc	esi		; imm16
; ==========[ process prefixes ]==========
xa_no16:
	and	al, 0E7h
	cmp	al, 26h 	; 26h,2Eh,36h,3Eh (ES,CS,SS,DS)
	pop	eax		; first restore AL (don't change flags)
	je	xa_PopNxt
	cmp	al, 0F1h	; int1
	je	xa_F1
	and	al, 0FCh
	cmp	al, 0A0h	; mov eax,[off16/32]
	jne	xa_noMOV
	lea	esi, [esi+edx+2]
xa_noMOV:
	cmp	al, 0F0h	; F0h-F3h (LOCK,..,REPE,REPNE)
	je	xa_PopNxt
xa_F1:	cmp	al, 64h 	; 64h,65h,66h,67h (FS,GS,Prfx66,Prfx67)
xa_PopNxt:
	pop	eax		; second restore AL (don't change flags)
	je	xa_NxtByte
; ==========[ prepare opcode ]==========
xa_end_find:
	mov	edi, esp	; edi = normal table (line info bits)
	push	edx		; store addressing mode flag
	push	eax		; store opcode value
	cmp	al, 0Fh
	jne	xa_Nrm		; if ext. group code then ...
	lodsb			; ... load byte of ext. code
xa_Nrm: pushfd			; store FLAGS
	_aam	10h		;*mov ah,al;shr ah,4;and al,0Fh
	xchg	cl, ah		; high part of ecx still is zero
	cwde			;*nothing
	cdq			;*xor edx,edx (bicoz eax>0)
	xor	ebp, ebp
	popfd			; restore FLAGS
	jne	xa_NrmGroup
; ==========[ extended group ]==========
xa_ExtGroup:
	add	edi, NrmTabLen	; edi = extended table (line info bits)
	jecxz	xa_@3
xa_@1:	bt	[edi], ebp
	jnc	xa_@2		; is not ModR/M only line?
	inc	edx		; yeah
xa_@2:	inc	ebp
	loop	xa_@1
	jc	xa_@3
	_salc			;*xor al,al
	cdq			;*xor edx,edx
xa_@3:	shl	edx, 1
	jmp	xa_ProcOpcode
; ==========[ normal group ]==========
xa_NrmGroup:
	sub	cl, 4
	jns	xa_@4
	mov	cl, 0Ch 	; bicoz 0xh,1xh,2xh,3xh are equal
	and	al, 7
xa_@4:	jecxz	xa_4x
xa_@5:	adc	dl, 1		; in first pass CF==0
	inc	ebp
	bt	[edi], ebp
	loop	xa_@5
	jc	xa_ProcOpcode
xa_4x:	shr	al, 1		; al/2
; ==========[ process additional fields ]==========
xa_ProcOpcode:
	xchg	cl, al
	lea	edx, [edx*8+ecx]; edx=index of opcode in table
	pop	ecx		; restore opcode value to CL
	pop	ebp		; restore 67h flag
	bt	[edi+2], edx	; edi+2=mod r/m info bits
	jnc	xa_noModRM
; ==========[ process mod r/m bytes ]===========
xa_ModRM:
	lodsb
	_aam	8		; ah=Mod|RO; al=RM
	shl	ah, 4		; CF=hi Mod; SF=lo Mod
	jnc	xa_isModRM
	js	xa_enModRM	; Mod==11
xa_isModRM:
	pushfd			; store FLAGS
	test	ebp, ebp	; prefix 67 present
	jnz	xa_addr32	
	sub	al, 6		; 16 bit addressing
	jnz	xa_noSIB	; if RM==6(BP) then ...
	mov	al, 5		; ... offset 16
xa_addr32:			; 32 bit addressing
	cmp	al, 4
	jne	xa_noSIB	; if RM==4 then ... (note: after addr16 al<2)
	lodsb			; ... get SIB
	and	al, 7		; al=BASE
xa_noSIB:
	popfd			; restore FLAGS
	jc	xa_iWD		; Mod==10
	js	xa_i8		; Mod==01
	cmp	al, 5		; if (RM==5||BASE==5) && Mod==00 then... (32)
	jne	xa_enModRM	; if            RM==6 && Mod==00 then... (16)
xa_iWD: add	esi, ebp	; ... offset 16/32
	inc	esi
xa_i8:	inc	esi		; offset 8
; ==========[ fucking TEST!!! ]==========
xa_enModRM:
	test	ah, 60h 	; if RO!=0 || RO!=1 then ...
	jnz	xa_noModRM	; ... go away
	xchg	eax, ecx	; ... else al=cl=opcode
	cmp	al, 0F6h
	je	xa_ti8
	cmp	al, 0F7h
	jne	xa_noModRM
	add	esi, ebx	; imm16/imm32 (66h prefix dependence)
	inc	esi
xa_ti8: inc	esi		; imm8
; ==========[ process immediate values ]==========
xa_noModRM:
	shl	edx, 1		; edx*2
	bt	[edi+2+17], edx ; edi+2+17=immediate values info bits
	jnc	xa_Exit
	inc	edx
	bt	[edi+2+17], edx
	jnc	xa_im8
	adc	esi, ebx	; imm16/imm32, 66h prefix dependence (ebx)
xa_im8: inc	esi
; ==========[ return result and exit ]==========
xa_Exit:
	add	esp, 110	; clear stack
	sub	esi, [esp+4]	; esi=esi-old esi
	mov	[esp+7*4], esi	; eax=esi
	popad
	ret

; That's all!