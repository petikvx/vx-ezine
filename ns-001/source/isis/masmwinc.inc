NULL                                EQU  0          ; FROM NTDEF  .H
TRUE                                EQU  1
FALSE                               EQU  0
LOCALE_SYSTEM_DEFAULT               EQU  0
INVALID_HANDLE_VALUE                EQU -1          ; FROM WINBASE.H
FILE_TYPE_UNKNOWN                   EQU 0
FILE_TYPE_DISK                      EQU 1
FILE_TYPE_CHAR                      EQU 2
FILE_TYPE_PIPE                      EQU 3
FILE_TYPE_REMOTE                    EQU 00008000H
MAX_PATH                            EQU 260         ; FROM WINDEF .H
NORM_IGNORECASE                     EQU 00000001H   ; FROM WINNLS .H
NORM_IGNORENONSPACE                 EQU 00000002H
NORM_IGNORESYMBOLS                  EQU 00000004H
NORM_IGNOREKANATYPE                 EQU 00010000H
NORM_IGNOREWIDTH                    EQU 00020000H
GENERIC_READ                        EQU 80000000H   ; FROM WDM    .H
GENERIC_WRITE                       EQU 40000000H
GENERIC_EXECUTE                     EQU 20000000H
GENERIC_ALL                         EQU 10000000H
STANDARD_RIGHTS_REQUIRED            EQU 000F0000H   ; FROM WINNT  .H
SECTION_QUERY                       EQU 00000001H
SECTION_MAP_WRITE                   EQU 00000002H
SECTION_MAP_READ                    EQU 00000004H
SECTION_MAP_EXECUTE                 EQU 00000008H
SECTION_EXTEND_SIZE                 EQU 00000010H
SECTION_ALL_ACCESS                  EQU STANDARD_RIGHTS_REQUIRED OR SECTION_QUERY OR \
                                        SECTION_MAP_WRITE   OR SECTION_MAP_READ   OR \
                                        SECTION_MAP_EXECUTE OR SECTION_EXTEND_SIZE
PAGE_NOACCESS                       EQU 00000001H
PAGE_READONLY                       EQU 00000002H
PAGE_READWRITE                      EQU 00000004H
PAGE_WRITECOPY                      EQU 00000008H
PAGE_EXECUTE                        EQU 00000010H
PAGE_EXECUTE_READ                   EQU 00000020H
PAGE_EXECUTE_READWRITE              EQU 00000040H
PAGE_EXECUTE_WRITECOPY              EQU 00000080H
PAGE_GUARD                          EQU 00000100H
PAGE_NOCACHE                        EQU 00000200H
PAGE_WRITECOMBINE                   EQU 00000400H
MEM_COMMIT                          EQU 00001000H
MEM_RESERVE                         EQU 00002000H
MEM_DECOMMIT                        EQU 00004000H
MEM_RELEASE                         EQU 00008000H
MEM_FREE                            EQU 00010000H
MEM_PRIVATE                         EQU 00020000H
MEM_MAPPED                          EQU 00040000H
MEM_RESET                           EQU 00080000H
MEM_TOP_DOWN                        EQU 00100000H
MEM_LARGE_PAGES                     EQU 20000000H
MEM_4MB_PAGES                       EQU 80000000H
FILE_ATTRIBUTE_READONLY             EQU 00000001H
FILE_ATTRIBUTE_HIDDEN               EQU 00000002H
FILE_ATTRIBUTE_SYSTEM               EQU 00000004H
FILE_ATTRIBUTE_DIRECTORY            EQU 00000010H
FILE_ATTRIBUTE_ARCHIVE              EQU 00000020H
FILE_ATTRIBUTE_DEVICE               EQU 00000040H
FILE_ATTRIBUTE_NORMAL               EQU 00000080H
FILE_ATTRIBUTE_TEMPORARY            EQU 00000100H
FILE_ATTRIBUTE_SPARSE_FILE          EQU 00000200H
FILE_ATTRIBUTE_REPARSE_POINT        EQU 00000400H
FILE_ATTRIBUTE_COMPRESSED           EQU 00000800H
FILE_ATTRIBUTE_OFFLINE              EQU 00001000H
FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  EQU 00002000H
FILE_ATTRIBUTE_ENCRYPTED            EQU 00004000H
CREATE_NEW                          EQU 1
CREATE_ALWAYS                       EQU 2
OPEN_EXISTING                       EQU 3
OPEN_ALWAYS                         EQU 4
TRUNCATE_EXISTING                   EQU 5
FILE_MAP_COPY                       EQU SECTION_QUERY
FILE_MAP_WRITE                      EQU SECTION_MAP_WRITE
FILE_MAP_READ                       EQU SECTION_MAP_READ
FILE_MAP_ALL_ACCESS                 EQU SECTION_ALL_ACCESS
IMAGE_DOS_SIGNATURE                 EQU 'ZM'
IMAGE_OS2_SIGNATURE                 EQU 'EN'
IMAGE_OS2_SIGNATURE_LE              EQU 'EL'
IMAGE_VXD_SIGNATURE                 EQU 'EL'
IMAGE_NT_SIGNATURE                  EQU 'EP'
IMAGE_SIZEOF_FILE_HEADER            EQU 20
IMAGE_SIZEOF_ROM_OPTIONAL_HEADER    EQU 56
IMAGE_SIZEOF_STD_OPTIONAL_HEADER    EQU 28
IMAGE_SIZEOF_NT_OPTIONAL32_HEADER   EQU 224
IMAGE_SIZEOF_NT_OPTIONAL64_HEADER   EQU 240
IMAGE_NT_OPTIONAL_HDR32_MAGIC       EQU 10BH
IMAGE_NT_OPTIONAL_HDR64_MAGIC       EQU 20BH
IMAGE_ROM_OPTIONAL_HDR_MAGIC        EQU 107H
IMAGE_FILE_EXECUTABLE_IMAGE         EQU 0002H
IMAGE_FILE_BYTES_REVERSED_LO        EQU 0080H
IMAGE_FILE_32BIT_MACHINE            EQU 0100H
IMAGE_FILE_SYSTEM                   EQU 1000H
IMAGE_FILE_DLL                      EQU 2000H
IMAGE_FILE_BYTES_REVERSED_HI        EQU 8000H
IMAGE_FILE_MACHINE_I386             EQU 014CH
IMAGE_SCN_CNT_CODE                  EQU 00000020H
IMAGE_SCN_CNT_INITIALIZED_DATA      EQU 00000040H
IMAGE_SCN_CNT_UNINITIALIZED_DATA    EQU 00000080H
IMAGE_SCN_MEM_EXECUTE               EQU 20000000H
IMAGE_SCN_MEM_READ                  EQU 40000000H
IMAGE_SCN_MEM_WRITE                 EQU 80000000H
IMAGE_SCN_MEM_DISCARDABLE           EQU 02000000H
IMAGE_SCN_MEM_NOT_CACHED            EQU 04000000H
IMAGE_SCN_MEM_NOT_PAGED             EQU 08000000H
IMAGE_SCN_MEM_SHARED                EQU 10000000H


FILETIME                STRUCT
    LowDateTime                     DD ?
    HighDateTime                    DD ?
FILETIME                ENDS

IMAGE_DOS_HEADER        STRUCT
    e_magic                         DW ?
    e_cblp                          DW ?
    e_cp                            DW ?
    e_crlc                          DW ?
    e_cparhdr                       DW ?
    e_minalloc                      DW ?
    e_maxalloc                      DW ?
    e_ss                            DW ?
    e_sp                            DW ?
    e_csum                          DW ?
    e_ip                            DW ?
    e_cs                            DW ?
    e_flarlc                        DW ?
    e_ovno                          DW ?
    e_res                           DW 4  DUP (?)
    e_oemid                         DW ?
    e_oeminfo                       DW ?
    e_res2                          DW 10 DUP (?)
    e_lfanew                        DD ?
IMAGE_DOS_HEADER        ENDS

IMAGE_DATA_DIRECTORY    STRUCT
    RVA                             DD ?
    Sizes                           DD ?
IMAGE_DATA_DIRECTORY    ENDS

PE STRUCT
    ; IMAGE_NT_HEADERS STRUCT
    Signature               DD ?

        ; IMAGE_FILE_HEADER32 STRUCT
        Machine                     DW ?
        NumberOfSections            DW ?
        TimeDateStamp               DD ?
        PointerToSymbolTable        DD ?
        NumberOfSymbols             DD ?
        SizeOfOptionalHeader        DW ?
        Characteristics             DW ?
        ; IMAGE_FILE_HEADER32 ENDS

        ; IMAGE_OPTIONAL_HEADER32 STRUCT
        Magic                       DW ?
        MajorLinkerVersion          DB ?
        MinorLinkerVersion          DB ?
        SizeOfCode                  DD ?
        SizeOfInitializedData       DD ?
        SizeOfUninitializedData     DD ?
        AddressOfEntryPoint         DD ?
        BaseOfCode                  DD ?
        BaseOfData                  DD ?
        ImageBase                   DD ?
        SectionAlignment            DD ?
        FileAlignment               DD ?
        MajorOperatingSystemVersion DW ?
        MinorOperatingSystemVersion DW ?
        MajorImageVersion           DW ?
        MinorImageVersion           DW ?
        MajorSubsystemVersion       DW ?
        MinorSubsystemVersion       DW ?
        Reserved1                   DD ?
        SizeOfImage                 DD ?
        SizeOfHeaders               DD ?
        CheckSum                    DD ?
        Subsystem                   DW ?
        DllCharacteristics          DW ?
        SizeOfStackReserve          DD ?
        SizeOfStackCommit           DD ?
        SizeOfHeapReserve           DD ?
        SizeOfHeapCommit            DD ?
        LoaderFlags                 DD ?
        NumberOfRvaAndSizes         DD ?

        ; IMAGE_DATA_DIRECTORY      STRUCT
        STRUCT                      DataDirectory
            Export                  IMAGE_DATA_DIRECTORY    {}
            Import                  IMAGE_DATA_DIRECTORY    {}
            Resource                IMAGE_DATA_DIRECTORY    {}
            Exception               IMAGE_DATA_DIRECTORY    {}
            Security                IMAGE_DATA_DIRECTORY    {}
            BaseReloc               IMAGE_DATA_DIRECTORY    {}
            Debug                   IMAGE_DATA_DIRECTORY    {}
            UNION
                Copyright           IMAGE_DATA_DIRECTORY    {}
                Architecture        IMAGE_DATA_DIRECTORY    {}
            ENDS
            GlobalPtr               IMAGE_DATA_DIRECTORY    {}
            TLS                     IMAGE_DATA_DIRECTORY    {}
            LoadConfig              IMAGE_DATA_DIRECTORY    {}
            BoundImport             IMAGE_DATA_DIRECTORY    {}
            IAT                     IMAGE_DATA_DIRECTORY    {}
            DelayImport             IMAGE_DATA_DIRECTORY    {}
            ComDescriptor           IMAGE_DATA_DIRECTORY    {}
            Reserved                IMAGE_DATA_DIRECTORY    {}
        ENDS
        ; IMAGE_DATA_DIRECTORY      ENDS
        ; IMAGE_OPTIONAL_HEADER32   ENDS
    ; IMAGE_NT_HEADERS ENDS
PE ENDS

SECTION STRUCT
    Names                           DB 8 DUP (?)
    UNION
    PhysicalAddress                 DD ?
    VirtualSize                     DD ?
    ENDS
    VirtualAddress                  DD ?
    SizeOfRawData                   DD ?
    PointerToRawData                DD ?
    PointerToRelocations            DD ?
    PointerToLinenumbers            DD ?
    NumberOfRelocations             DW ?
    NumberOfLinenumbers             DW ?
    Characteristics                 DD ?
SECTION ENDS

EXPORT  STRUCT
    Characteristics                 DD ?
    TimeDateStamp                   DD ?
    MajorVersion                    DW ?
    MinorVersion                    DW ?
    Names                           DD ?
    Base                            DD ?
    NumberOfFunctions               DD ?
    NumberOfNames                   DD ?
    AddressOfFunctions              DD ?
    AddressOfNames                  DD ?
    AddressOfNameOrdinals           DD ?
EXPORT  ENDS

IMPORT  STRUCT
    UNION
    Characteristics                 DD ?
    OriginalFirstThunk              DD ?
    ENDS
    TimeDateStamp                   DD ?
    ForwarderChain                  DD ?
    Names                           DD ?
    FirstThunk                      DD ?
IMPORT  ENDS

WIN32_FIND_DATA STRUCT
    FileAttributes                  DD ?
    CreationTime                    FILETIME {}
    LastAccessTime                  FILETIME {}
    LastWriteTime                   FILETIME {}
    FileSizeHigh                    DD ?
    FileSizeLow                     DD ?
    Reserved0                       DD ?
    Reserved1                       DD ?
    FileName                        DB MAX_PATH DUP(?)
    AlternateFileName               DB 14       DUP(?)
    FileType                        DD ?
    CreatorType                     DD ?
    FinderFlags                     DW ?
WIN32_FIND_DATA ENDS

BY_HANDLE_FILE_INFORMATION  STRUCT
    FileAttributes                  DD ?
    CreationTime                    FILETIME {}
    LastAccessTime                  FILETIME {}
    LastWriteTime                   FILETIME {}
    VolumeSerialNumber              DD ?
    FileSizeHigh                    DD ?
    FileSizeLow                     DD ?
    NumberOfLinks                   DD ?
    FileIndexHigh                   DD ?
    FileIndexLow                    DD ?
BY_HANDLE_FILE_INFORMATION  ENDS
