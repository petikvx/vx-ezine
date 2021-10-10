;-----------------------------------------------------------------------------
PE_Hdr          STRUC
		; PE File Header.
		peh_Marker              dd      ?
		peh_Machine             dw      ?
		peh_SectionCount        dw      ?
		peh_TimeDateStamp       dd      ?
		peh_SymbTable_Ptr       dd      ?
		peh_SymbTable_Count     dd      ?
		peh_NTHdrSize           dw      ?
		peh_Flags               dw      ?
		; NT Optional Header.
		; Standard Fields.
		peh_Magic               dw      ?
		peh_LinkMajor           db      ?
		peh_LinkMinor           db      ?
		peh_CodeSize            dd      ?
		peh_DataSize            dd      ?
		peh_BSSSize             dd      ?
		peh_EntryPointRVA       dd      ?
		peh_CodeBase            dd      ?
		peh_DataBase            dd      ?
		; NT Additional Fields.
		peh_ImageBase           dd      ?
		peh_SectionAlign        dd      ?
		peh_FileAlign           dd      ?
		peh_OSMajor             dw      ?
		peh_OSMinor             dw      ?
		peh_UserMajor           dw      ?
		peh_UserMinor           dw      ?
		peh_SubSysMajor         dw      ?
		peh_SubSysMinor         dw      ?
		peh_Win32_Version       dd      ?
		peh_ImageSize           dd      ?
		peh_HeaderSize          dd      ?
		peh_FileChecksum        dd      ?
		peh_SubSystem           dw      ?
		peh_DLLFlags            dw      ?
		peh_StackReserveSize    dd      ?
		peh_StackCommitSize     dd      ?
		peh_HeapReserveSize     dd      ?
		peh_HeapCommitSize      dd      ?
		peh_LoaderFlags         dd      ?
		peh_RVATableCount       dd      ?
PE_Hdr          ENDS

		peh_DirectoryTable      =       (SIZE PE_Hdr)

;-----------------------------------------------------------------------------
PE_DirEntry     STRUC
		pedir_VA                dd      ?
		pedir_Size              dd      ?
PE_DirEntry     ENDS

;-----------------------------------------------------------------------------
PE_Export       STRUC
		peexp_Flags             dd      ?
		peexp_TimeDateStamp     dd      ?
		peexp_MajorVersion      dw      ?
		peexp_MinorVersion      dw      ?
		peexp_ModuleNamePtr     dd      ?
		peexp_OrdinalBase       dd      ?
		peexp_ProcCount         dd      ?
		peexp_NameCount         dd      ?
		peexp_ProcListPtr       dd      ?
		peexp_NameListPtr       dd      ?
		peexp_OrdinalListPtr    dd      ?
PE_Export       ENDS

;-----------------------------------------------------------------------------
PE_Import       STRUC
		peimp_ProcNameListRVA   dd      ?
		peimp_Reserved0         dd      ?
		peimp_Reserved1         dd      ?
		peimp_ModuleNameRVA     dd      ?
		peimp_ProcAddrListRVA   dd      ?
PE_Import       ENDS

;-----------------------------------------------------------------------------
IMAGE_SIZEOF_SHORT_NAME = 8

PE_Sec          STRUC
		pesec_Name              db      IMAGE_SIZEOF_SHORT_NAME dup(?)
		UNION
			pesec_PhysicalAddress   dd      ?
			pesec_VirtualSize       dd      ?
		ENDS
		pesec_VirtualAddress    dd      ?
		pesec_RawDataSize       dd      ?
		pesec_RawDataPtr        dd      ?
		pesec_RelocationsPtr    dd      ?
		pesec_LineNumbersPtr    dd      ?
		pesec_nRelocations      dw      ?
		pesec_nLineNumbers      dw      ?
		pesec_Flags             dd      ?
PE_Sec          ENDS
