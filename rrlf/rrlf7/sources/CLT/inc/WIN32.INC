.xlist
;=============================================================================
.486
;-----------------------------------------------------------------------------

UCHAR                           EQU <db>
USHORT                          EQU <dw>
UINT                            EQU <dd>
ULONG                           EQU <dd>

;-----------------------------------------------------------------------------
NULL                            =       0
FALSE                           =       0
TRUE                            =       1
MAX_PATH                        =       260
INVALID_HANDLE_VALUE            =       -1
STANDARD_RIGHTS_REQUIRED        =       000F0000h

;-----------------------------------------------------------------------------
GENERIC_READ                    =       80000000h
GENERIC_WRITE                   =       40000000h


;-----------------------------------------------------------------------------
        FILE_SHARE_READ         =       00000001h
        FILE_SHARE_WRITE        =       00000002h

;-----------------------------------------------------------------------------
tCreateFileStrategy             ENUM {
        CREATE_NEW              =       1
        CREATE_ALWAYS,
        OPEN_EXISTING,
        OPEN_ALWAYS,
        TRUNCATE_EXISTING
}

;-----------------------------------------------------------------------------
fa_READONLY             =       00000001h
fa_HIDDEN               =       00000002h
fa_SYSTEM               =       00000004h
fa_DIRECTORY            =       00000010h
fa_ARCHIVE              =       00000020h
fa_NORMAL               =       00000080h
fa_TEMPORARY            =       00000100h
fa_ATOMIC_WRITE         =       00000200h
fa_XACTION_WRITE        =       00000400h
fa_COMPRESSED           =       00000800h
fa_HAS_EMBEDDING        =       00001000h

; flags -
fa_POSIX_SEMANTICS      =       01000000h
fa_BACKUP_SEMANTICS     =       02000000h
fa_DELETE_ON_CLOSE      =       04000000h
fa_SEQUENTIAL_SCAN      =       08000000h
fa_RANDOM_ACCESS        =       10000000h
fa_NO_BUFFERING         =       20000000h
fa_OVERLAPPED           =       40000000h
fa_WRITE_THROUGH        =       80000000h


;-----------------------------------------------------------------------------
SECTION_QUERY                   EQU     00001h
SECTION_MAP_WRITE               EQU     00002h
SECTION_MAP_READ                EQU     00004h
SECTION_MAP_EXECUTE             EQU     00008h
SECTION_EXTEND_SIZE             EQU     00010h

SECTION_ALL_ACCESS      =       (STANDARD_RIGHTS_REQUIRED       OR\
                                SECTION_QUERY                   OR\
                                SECTION_MAP_WRITE               OR\
                                SECTION_MAP_READ                OR\
                                SECTION_MAP_EXECUTE             OR\
                                SECTION_EXTEND_SIZE)

FILE_MAP_COPY       EQU     SECTION_QUERY
FILE_MAP_WRITE      EQU     SECTION_MAP_WRITE
FILE_MAP_READ       EQU     SECTION_MAP_READ
FILE_MAP_ALL_ACCESS EQU     SECTION_ALL_ACCESS

;-----------------------------------------------------------------------------
PAGE_NOACCESS           EQU     001h
PAGE_READONLY           EQU     002h
PAGE_READWRITE          EQU     004h
PAGE_WRITECOPY          EQU     008h
PAGE_EXECUTE            EQU     010h
PAGE_EXECUTE_READ       EQU     020h
PAGE_EXECUTE_READWRITE  EQU     040h
PAGE_EXECUTE_WRITECOPY  EQU     080h
PAGE_GUARD              EQU     0100h
PAGE_NOCACHE            EQU     0200h
       
MEM_COMMIT              EQU     01000h
MEM_RESERVE             EQU     02000h
MEM_DECOMMIT            EQU     04000h
MEM_RELEASE             EQU     08000h
MEM_FREE                EQU     010000h
MEM_PRIVATE             EQU     020000h
MEM_MAPPED              EQU     040000h
MEM_RESET               EQU     080000h
MEM_TOP_DOWN            EQU     0100000h
MEM_4MB_PAGES           EQU     080000000h
SEC_FILE                EQU     0800000h
SEC_IMAGE               EQU     01000000h
SEC_VLM                 EQU     02000000h
SEC_RESERVE             EQU     04000000h
SEC_COMMIT              EQU     08000000h
SEC_NOCACHE             EQU     010000000h
MEM_IMAGE               EQU     SEC_IMAGE

;------------------------------------------------------------------------------
INVALID_FILE_SIZE   EQU     0FFFFFFFFh
        
tSeekOrigin                     ENUM {        
        FILE_BEGIN              =       0,
        FILE_CURRENT            =       1,
        FILE_END                =       2
}


;-----------------------------------------------------------------------------
IMAGE_DOS_SIGNATURE                     EQU     05A4Dh
IMAGE_OS2_SIGNATURE                     EQU     0454Eh
IMAGE_OS2_SIGNATURE_LE                  EQU     0454Ch
IMAGE_VXD_SIGNATURE                     EQU     0454Ch
IMAGE_NT_SIGNATURE                      EQU     000004550h

IMAGE_SIZEOF_FILE_HEADER                EQU     20

IMAGE_FILE_RELOCS_STRIPPED              EQU     00001h
IMAGE_FILE_EXECUTABLE_IMAGE             EQU     00002h
IMAGE_FILE_LINE_NUMS_STRIPPED           EQU     00004h
IMAGE_FILE_LOCAL_SYMS_STRIPPED          EQU     00008h
IMAGE_FILE_AGGRESIVE_WS_TRIM            EQU     00010h
IMAGE_FILE_BYTES_REVERSED_LO            EQU     00080h
IMAGE_FILE_32BIT_MACHINE                EQU     00100h
IMAGE_FILE_DEBUG_STRIPPED               EQU     00200h
IMAGE_FILE_REMOVABLE_RUN_FROM_SW        EQU     00400h
IMAGE_FILE_NET_RUN_FROM_SWAP            EQU     00800h
IMAGE_FILE_SYSTEM                       EQU     01000h
IMAGE_FILE_DLL                          EQU     02000h
IMAGE_FILE_UP_SYSTEM_ONLY               EQU     04000h
IMAGE_FILE_BYTES_REVERSED_HI            EQU     08000h

tIMAGE_FILE_MACHINE_                    ENUM {
        IMAGE_FILE_MACHINE_UNKNOWN      =       0,
        IMAGE_FILE_MACHINE_I386         =       014ch,
        IMAGE_FILE_MACHINE_R3000        =       0162h,
        IMAGE_FILE_MACHINE_R4000        =       0166h,
        IMAGE_FILE_MACHINE_R10000       =       0168h,
        IMAGE_FILE_MACHINE_ALPHA        =       0184h,
        IMAGE_FILE_MACHINE_POWERPC      =       01F0h,
}

IMAGE_NUMBEROF_DIRECTORY_ENTRIES        EQU     16

IMAGE_SIZEOF_ROM_OPTIONAL_HEADER        EQU     56
IMAGE_SIZEOF_STD_OPTIONAL_HEADER        EQU     28
IMAGE_SIZEOF_NT_OPTIONAL_HEADER         EQU     224

IMAGE_NT_OPTIONAL_HDR_MAGIC             EQU     010bh
IMAGE_ROM_OPTIONAL_HDR_MAGIC            EQU     0107h

tIMAGE_SUBSYSTEM_                       ENUM {
        IMAGE_SUBSYSTEM_UNKNOWN         =       0,
        IMAGE_SUBSYSTEM_NATIVE,
        IMAGE_SUBSYSTEM_WINDOWS_GUI,
        IMAGE_SUBSYSTEM_WINDOWS_CUI,
        IMAGE_SUBSYSTEM_OS2_CUI         =       5,
        IMAGE_SUBSYSTEM_POSIX_CUI,
        IMAGE_SUBSYSTEM_RESERVED8       =       8
}

tIMAGE_DIRECTORY_ENTRY_                 ENUM {
        IMAGE_DIRECTORY_ENTRY_EXPORT,
        IMAGE_DIRECTORY_ENTRY_IMPORT,
        IMAGE_DIRECTORY_ENTRY_RESOURCE,
        IMAGE_DIRECTORY_ENTRY_EXCEPTION,
        IMAGE_DIRECTORY_ENTRY_SECURITY,
        IMAGE_DIRECTORY_ENTRY_BASERELOC,
        IMAGE_DIRECTORY_ENTRY_DEBUG,
        IMAGE_DIRECTORY_ENTRY_COPYRIGHT,
        IMAGE_DIRECTORY_ENTRY_GLOBALPTR,
        IMAGE_DIRECTORY_ENTRY_TLS,
        IMAGE_DIRECTORY_ENTRY_LOAD_CONFI,
        IMAGE_DIRECTORY_ENTRY_BOUND_IMPO,
        IMAGE_DIRECTORY_ENTRY_IAT
}

WFILETIME       STRUC
		wft_dwLowDateTime        dd ?
		wft_dwHighDateTime       dd ?
WFILETIME       ENDS

WFF             STRUC
		wff_FileAttributes      dd      ?
		wff_wftCreationTime     WFILETIME ?
		wff_wftLastAccessTime   WFILETIME ?
		wff_wftLastWriteTime    WFILETIME ?
		wff_FileSizeHigh        dd      ?
		wff_FileSizeLow         dd      ?
		wff_Reserved0           dd      ?
		wff_Reserved1           dd      ?
		wff_FileName            db      MAX_PATH dup(?)
		wff_AlternateFileName   db      13 dup(?)
		align 4
WFF             ENDS

IMAGE_SCN_TYPE_NO_PAD                   EQU     000000008h
IMAGE_SCN_CNT_CODE                      EQU     000000020h
IMAGE_SCN_CNT_INITIALIZED_DATA          EQU     000000040h
IMAGE_SCN_CNT_UNINITIALIZED_DATA        EQU     000000080h
IMAGE_SCN_LNK_OTHER                     EQU     000000100h
IMAGE_SCN_LNK_INFO                      EQU     000000200h
IMAGE_SCN_LNK_REMOVE                    EQU     000000800h
IMAGE_SCN_LNK_COMDAT                    EQU     000001000h
IMAGE_SCN_MEM_FARDATA                   EQU     000008000h
IMAGE_SCN_MEM_PURGEABLE                 EQU     000020000h
IMAGE_SCN_MEM_16BIT                     EQU     000020000h
IMAGE_SCN_MEM_LOCKED                    EQU     000040000h
IMAGE_SCN_MEM_PRELOAD                   EQU     000080000h
IMAGE_SCN_ALIGN_1BYTES                  EQU     000100000h
IMAGE_SCN_ALIGN_2BYTES                  EQU     000200000h
IMAGE_SCN_ALIGN_4BYTES                  EQU     000300000h
IMAGE_SCN_ALIGN_8BYTES                  EQU     000400000h
IMAGE_SCN_ALIGN_16BYTES                 EQU     000500000h
IMAGE_SCN_ALIGN_32BYTES                 EQU     000600000h
IMAGE_SCN_ALIGN_64BYTES                 EQU     000700000h
IMAGE_SCN_LNK_NRELOC_OVFL               EQU     001000000h
IMAGE_SCN_MEM_DISCARDABLE               EQU     002000000h
IMAGE_SCN_MEM_NOT_CACHED                EQU     004000000h
IMAGE_SCN_MEM_NOT_PAGED                 EQU     008000000h
IMAGE_SCN_MEM_SHARED                    EQU     010000000h
IMAGE_SCN_MEM_EXECUTE                   EQU     020000000h
IMAGE_SCN_MEM_READ                      EQU     040000000h
IMAGE_SCN_MEM_WRITE                     EQU     080000000h

;=============================================================================
.list
