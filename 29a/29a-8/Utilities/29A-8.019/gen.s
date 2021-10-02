
; *******************************************
;  [X87ME.32] test files generator for Linux
; *******************************************

section	.data
global	main

%include "x87me.s"

main:
	mov eax,4
	mov ebx,1
	mov ecx,gen_msg
	mov edx,gen_msg_len
	int 80h

	mov ecx,50
gen_l1:
	push ecx

	mov eax,8
	mov ebx,filename
	mov ecx,000111111101b		; 000rwxrwxrwx
	int 80h
	
	push eax
	
	mov ebx,host_entry
	mov ecx,host
	mov edx,host_len
	mov ebp,[e_entry]
	call X87ME
	
	pop ebx
	
	mov eax,4
	mov ecx,elf_head
	add edx,host_entry-elf_head
	mov [p_filsz],edx
	mov [p_memsz],edx
	int 80h
	
	mov eax,6
	int 80h
	
	lea ebx,[filename+1]
	inc byte [ebx+1]
	cmp byte [ebx+1],'9'
	jbe gen_l2
	inc byte [ebx]
	mov byte [ebx+1],'0'
gen_l2:
	pop ecx
	loop gen_l1

	mov eax,1
	xor ebx,ebx
	int 80h
	
gen_msg	db 'Generates 50 [X87ME.32] encrypted test files...',0dh,0ah
gen_msg_len equ	$-gen_msg

host:
	call host_reloc
host_reloc:
	pop ecx
	add ecx,host_msg-host_reloc
	mov eax,4
	mov ebx,1
	mov edx,host_msg_len
	int 80h
	mov eax,1
	xor ebx,ebx
	int 80h

host_msg db 'This is a [X87ME.32] test file! ...('
filename db 't00',0
	 db ')',0dh,0ah
host_msg_len equ $-host_msg
host_len equ $-host

elf_head:
e_ident	db 7fh,'ELF',1,1,1
	times 9	db 0
e_type	dw 2
e_mach	dw 3
e_ver	dd 1
e_entry	dd host_entry-elf_head+08048000h
e_phoff	dd 34h
e_shoff	dd 0
e_flags	dd 0
e_elfhs	dw 34h
e_phes	dw 20h
e_phec	dw 01h
e_shes	dw 0
e_shec	dw 0
e_shsn	dw 0	
elf_ph:
p_type	dd 1
p_off	dd 0
p_vaddr	dd 08048000h
p_paddr	dd 08048000h
p_filsz	dd file_len
p_memsz	dd file_len
p_flags	dd 7
p_align	dd 1000h
	times 20h db 0
host_entry:
	times 1024*4 db	0

file_len equ $-elf_head
