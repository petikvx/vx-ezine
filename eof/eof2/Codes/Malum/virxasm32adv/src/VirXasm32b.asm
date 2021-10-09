
	;;      \\  /      ;;
	;;  \\/  \\/ASM    ;;
	;;   VIR /\\       ;;
	;;      /  \\      ;;
	;;                 ;;
	;; VirXasm32 v1.5b ;;
	;; (X) Malum 2006  ;;

; Length Disassembler Engine VirXasm32 v1.5b
; Total size: 348 (15Ch) bytes
; INPUT:  esi = address of instruction
; OUTPUT: eax = instruction length

_salc equ <db 0D6h>     ;sbb al,al but not change flags
_aam macro num	;ah=al/num;al=al mod num
 db 0D4h, num
endm
_aad macro num	;al=ah*num+al;ah=0
 db 0D5h, num
endm

NrmTabLen = 53

; ==========[ disassemble instruction from esi ]===========
VirXasm32:
	pushad
; ==========[ push packed tables to stack]=========
	push	000001510h
	push	0100101FFh
	push	0FFFFFF55h
	push	0FFFFFFF8h
	push	0F8FF7FA0h
	push	00F0EC40Dh
	push	007551004h
	push	001D005FFh
	push	0550D5D55h
	push	0555F0F88h
	push	0F3F3FFFFh
	push	00A0C1154h
	mov	edx, esi	; store esi
	mov	esi, esp	; esi = address of unpacked tables
; ==========[ push unpack info bits to stack]==========
	push	11001b
	push	10110000101011000000101110000000b
	push	10111111101100011111001100111110b
	push	00000000000100011110101001011000b
	mov	ebx, esp	; ebx = address of unpack info bits
	sub	esp, 110	; reserve stack for unpacked tables
	mov	edi, esp	; edi = address of buffer for unpacked tables
; ==========[ unpack tables to stack ]==========
	cld
	push	100
	pop	ecx		; total size of unpacked tables is 100 bytes
xa_nxtIndx:			;*xor al,al
	bt	[ebx], ecx	; get unpack bit to CF
	_salc			; if bit==0 then al=0 (salc==sbb al,al)
	jnc	xa_is0		; if bit!=0 then ...
	lodsb			; ... load byte from tables in AL ...
xa_is0: stosb			; ... else write zero
	loop	xa_nxtIndx	; next byte
	mov	esi, edx	; restore esi
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
	cmove	edx, ecx	; ... edx=ecx=0 (current addr. mode - 16 bits)
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
	cmp	al, 5		; if (RM==5||BASE==5) && Mod==00 then ... (32)
	jne	xa_enModRM	; if            RM==6 && Mod==00 then ... (16)
xa_iWD: add	esi, ebp	; ... offset 16/32
	inc	esi
xa_i8:	inc	esi		; offset 8
; ==========[ fucking TEST!!! ]==========
xa_enModRM:
	test	ah, 60h 	; if RO!=0 || RO!=1 then ...
	jnz	xa_noModRM	; ... go away
	xchg	eax, ecx	; ... else al=cl=opcode
	cmp	al, 0F6h	; TEST rm,i8
	je	xa_ti8
	cmp	al, 0F7h	; TEST rm,i16/i32
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
	add	esp, 110+64	; clear stack
	sub	esi, [esp+4]	; esi=esi-old esi
	mov	[esp+7*4], esi	; eax=esi
	popad
	ret

; That's all!

