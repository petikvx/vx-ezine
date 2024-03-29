org origin

ehdr:
        db 0x7F, "ELF", 1, 1, 1	;e_ident
times 9	db 0
        dw 2			;e_type
        dw 3			;e_machine
        dd 1			;e_version
        dd code 	        ;e_entry
        dd phdr - $$		;e_phoff
        dd 0			;e_shoff
        dd 0			;e_flags
        dw ehdrsize		;e_ehsize
        dw phdrsize		;e_phentsize

phdr:
        dw 1			;e_phnum	;p_type
        dw 0			;e_shentsize
        dw 0			;e_shnum	;p_offset
        dw 0			;e_shstrndx
ehdrsize equ $ - ehdr
        dw $$					;p_vaddr
  .eaxfinish:
        xchg eax, ebx
  .finish:
        xor eax, eax		;       	;p_paddr
        inc eax
        int 0x80
        dd code_end-code_start			;p_filesz
        dd code_end-code_start			;p_memsz
        dd 7					;p_flags
        dd 0x1000				;p_align
phdrsize equ $ - phdr
