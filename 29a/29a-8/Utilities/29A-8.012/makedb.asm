;VCL32 Snippet compiler
;
;this routine search for all *.ASI snippets, and create a database with all
;them. the .ASI files must begin with ';%%%', then the level, params, the
;name, and description (ex: ";%%%1 0 IAPI Import APIs by string").
;
;output struct: type(b)params(b)name(d)helpsize(b)help(?b)datasize(d)data(?b)

.586p
.model flat
locals

include header.inc

.code

include z_encode.inc

include cmdline.inc
include console.inc
include consts.inc


process_snippet:
	sub eax,eax
	pushad

	push 0
	push 80h
	push 3
	push 0
	push 0
	push 0c0000000h
	push dwo [esp.cPushad.Arg2.(Pshd*6)]
	callW CreateFileA
	mov ebx,eax
	inc eax
	jz @@error

	push dwo [esp.cPushad.Arg3]
	push 40h
	callW GlobalAlloc
	mov esi,eax
	mov ebp,eax
	test eax,eax
	jz @@error

	push 0
	mov eax,esp
	push 0
	push eax
	push dwo [esp.cPushad.Arg3.(Pshd*3)]
	push esi
	push ebx
	callW ReadFile

	mov [esp],ebx
	callW CloseHandle

	mov edi,[esp.cPushad.Arg1]
	lodsd
	sub eax, "%%%;"
	jne @@error

	lodsw
	sub al,"0"
	stosb				;save vc_header.type

	lodsw
	sub al,"0"
	stosb				;save vc_header.params

	movsd				;save vc_header.name
	lodsb

  	push edi
  	inc edi				;reserve space for vc_header.helpsize
  	sub ecx,ecx
  @@count_copy:
  	cmp dwo [esi],0a0d0a0dh
  	je @@skip2code
	movsb				;save vc_header.help
	inc ecx
  	jmp @@count_copy
  @@skip2code:
	lodsd
  	pop eax
  	mov [eax],cl			;set vc_header.helpsize

	mov ecx,ebp
	sub ecx,esi

	push edi
	stosd				;reserve space for vc_header.datasize

	add ecx,[esp.cPushad.Arg3.Pshd]
	call z_encode_asm		;generate vc_header.data
	mov eax,[edi]
  	pop ecx
  	mov [ecx],eax			;set vc_header.datasize

	add eax,edi
	sub eax,[esp.cPushad.Arg1]
	mov [esp.Pushad_eax],eax

  @@error2:
  	push ebp
  	callW GlobalFree

  @@error:
	popad
	ret 3*4


main:
	mov edx, ofs copyright
	call dump_asciiz_edx

	call getcmdline
	mov edx, ofs usage
	cmp dwo [argc],2
	jne @@exit

	push 256*1024
	push 40h
	callW GlobalAlloc
	mov esi,eax
	mov edi,eax
	test eax,eax
	jz @@exit_error

	push ofs fdata
	push ofs mask
	callW FindFirstFileA
	mov ebx,eax
	inc eax
  @@find_next:
	test eax,eax
	jz @@end_search

	push dwo [fdata.WFD_nFileSizeLow]
	push ofs fdata.WFD_szFileName
	push edi
	call process_snippet
	add edi,eax
	test eax,eax
	jz @@exit_error

	push ofs fdata
	push ebx
	callW FindNextFileA
	jmp @@find_next

  @@end_search:
  	push ebx
  	callW FindClose

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
	sub edi,esi
	push edi
	push esi
	push ebx
	callW WriteFile

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


.data

copyright 	db "VCL32 Snippet compiler",13,10,0
usage		db "USAGE: MAKEDB.EXE <LIBFILE>",13,10,0
error		db "Error!!",7,13,10,0
done 		db "Done!",13,10,0

mask	db "*.ASI",0

fdata	WIN32_FIND_DATA <?>

include cmdline2.inc


end	main
