;= Process list of Win32 Imported Kernel32 functions (c) 2006 JPanic ======
;
; Imported Functions:
;	FindFirstFileA, FindNextFileA, FindClose, CreateFileA,
;	SetFilePointer, CloseHandle, CreateFileMappingA, MapViewOfFile
;	UnmapViewOfFile, SetEndOfFile.
;
;- Import List Processing Macro -------------------------------------------
W32_IMP_LIST	MACRO	_code
		
                IRP     _impname,<FindFirstFileA,FindNextFileA,FindClose,CreateFileA,SetFilePointer,CloseHandle,CreateFileMappingA,MapViewOfFile,UnmapViewOfFile,SetEndOfFile>
			IRP	_codeline, <_code>
				&_codeline&
			ENDM
			purge	_codeline
		ENDM
		purge	_impname
ENDM

;- Set Imported Proc Count ------------------------------------------------
K32ProcCount	=	0
W32_IMP_LIST	<<K32ProcCount = K32ProcCount + 1>>

;==========================================================================




