SW_SHOW                         EQU     5

PAGE_NOACCESS			equ	00000001h
PAGE_READONLY			equ	00000002h
PAGE_READWRITE			equ	00000004h
PAGE_WRITECOPY			equ	00000008h

GENERIC_ALL			equ	10000000h
GENERIC_EXECUTE			equ	20000000h
GENERIC_WRITE			equ	40000000h
GENERIC_READ			equ	80000000h
GENERIC_READWRITE               equ     GENERIC_READ+GENERIC_WRITE

FILE_SHARE_NONE			equ	0000h
FILE_SHARE_READ			equ	0001h
FILE_SHARE_WRITE		equ	0002h
FILE_SHARE_READWRITE		equ	FILE_SHARE_READ+FILE_SHARE_WRITE

CREATE_NEW			equ	1
CREATE_ALWAYS			equ	2
OPEN_EXISTING			equ	3
OPEN_ALWAYS			equ	4
TRUNCATE_EXISTING		equ	5

FILE_ATTRIBUTE_READONLY		equ	00000001h
FILE_ATTRIBUTE_HIDDEN		equ	00000002h
FILE_ATTRIBUTE_SYSTEM		equ	00000004h
FILE_ATTRIBUTE_DIRECTORY	equ	00000010h
FILE_ATTRIBUTE_ARCHIVE		equ	00000020h
FILE_ATTRIBUTE_NORMAL		equ	00000080h

FILE_BEGIN                      EQU     0
FILE_CURRENT                    EQU     1
FILE_END                        EQU     2
OF_READ                         EQU     0
OF_READWRITE                    EQU     2
OF_WRITE                        EQU     1

NULL                            EQU     0
FALSE                           EQU     0
TRUE                            EQU     1
MAX_PATH                        EQU     260
INVALID_HANDLE_VALUE            EQU     -1
STANDARD_RIGHTS_REQUIRED        EQU     000F0000h

FILETIME                        STRUC
        FT_dwLowDateTime        DD ?
        FT_dwHighDateTime       DD ?
FILETIME                        ENDS

WIN32_FIND_DATA                 STRUC
        WFD_dwFileAttributes    DD ?
        WFD_ftCreationTime      FILETIME ?
        WFD_ftLastAccessTime    FILETIME ?
        WFD_ftLastWriteTime     FILETIME ?
        WFD_nFileSizeHigh       DD ?
        WFD_nFileSizeLow        DD ?
        WFD_dwReserved0         DD ?
        WFD_dwReserved1         DD ?
        WFD_szFileName          DB MAX_PATH DUP (?)
        WFD_szAlternateFileName DB 13 DUP (?)
                                DB 3 DUP (?)    ; dword padding
WIN32_FIND_DATA                 ENDS

SIZEOF_WIN32_FIND_DATA  EQU     SIZE WIN32_FIND_DATA
