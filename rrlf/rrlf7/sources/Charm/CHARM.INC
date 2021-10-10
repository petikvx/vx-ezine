CREATE_ALWAYS           equ     2
OPEN_EXISTING           equ     3

GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h

FILE_SHARE_READ         equ     1

CLSCTX_INPROC_SERVER    equ     1
STGM_READ               equ     0
STGM_WRITE              equ     1
STGM_SHARE_EXCLUSIVE    equ     10h
STGTY_STORAGE           equ     1
STGTY_STREAM            equ     2

MAX_PATH                equ     260

Release                 equ     08h
StgCreateDocfile        equ     0ch
StgOpenStorage          equ     1ch
EnumElements            equ     2ch
Next                    equ     0ch
CreateStream            equ     0ch
OpenStream              equ     10h
Read                    equ     0ch
Write                   equ     10h

MOVEFILE_REPLACE_EXISTING       equ     1
MOVEFILE_WRITE_THROUGH          equ     8

align           1                               ;byte-packed structures
krncrcstk       struct
        findhand                dd      ?
        oCoUninitialize         dd      ?
        oCoTaskMemFree          dd      ?
        oCoInitialize           dd      ?
        oCoCreateInstance       dd      ?
        klstrlenW               dd      ?
        kSetFileTime            dd      ?
        kSetFileAttributesW     dd      ?
        kMoveFileExW            dd      ?
        kLoadLibraryA           dd      ?
        kGlobalFree             dd      ?
        kGlobalAlloc            dd      ?
        kFindNextFileW          dd      ?
        kFindFirstFileW         dd      ?
        kFindClose              dd      ?
        kExitProcess            dd      ?
        kCreateFileW            dd      ?
        kCloseHandle            dd      ?
krncrcstk       ends
krncrc_count    equ     (size krncrcstk - 14h) shr 2
olecrc_count    equ     4

FILETIME        struc
dwLowDateTime           dd      ?
dwHighDateTime          dd      ?
FILETIME        ends

WIN32_FIND_DATAW        struc
dwFileAttributes        dd              ?
ftCreationTime          FILETIME        ?
ftLastAccessTime        FILETIME        ?
ftLastWriteTime         FILETIME        ?
nFileSizeHigh           dd              ?
nFileSizeLow            dd              ?
dwReserved0             dd              ?
dwReserved1             dd              ?
cFileName               dw              MAX_PATH dup (?)
cAlternateFileName      dw              14 dup (?)
WIN32_FIND_DATAW        ends

ULARGE_INTEGER  struc
LowPart                 dd      ?
HighPart                dd      ?
ULARGE_INTEGER  ends

CLSID           struc
Data1                   dd      ?
Data2                   dw      ?
Data3                   dw      ?
Data4                   db      ?
Data5                   db      ?
Data6                   db      ?
Data7                   db      ?
Data8                   db      ?
Data9                   db      ?
Dataa                   db      ?
Datab                   db      ?
CLSID           ends

STATSTG         struc
pwcsName                dd              ?
type                    dd              ?
cbSize                  ULARGE_INTEGER  ?
mtime                   FILETIME        ?
ctime                   FILETIME        ?
atime                   FILETIME        ?
grfMode                 dd              ?
grfLocksSupported       dd              ?
clsid                   CLSID           ?
grfStateBits            dd              ?
reserved                dd              ?
STATSTG         ends

coffhdr         struct
        pemachine       dw      ?               ;04
        pesectcount     dw      ?               ;06
        petimedate      dd      ?               ;08
        pesymbrva       dd      ?               ;0C
        pesymbcount     dd      ?               ;10
        peopthdrsize    dw      ?               ;14
        peflags         dw      ?               ;16
coffhdr         ends

pedir           struct
        dirrva          dd      ?
        dirsize         dd      ?
pedir           ends

pehdr           struct
        pesig           dd      ?               ;00
        pecoff          coffhdr <?>
        pemagic         dw      ?               ;18
        pemajorlink     db      ?               ;1A
        peminorlink     db      ?               ;1B
        pecodesize      dd      ?               ;1C
        peidatasize     dd      ?               ;20
        peudatasize     dd      ?               ;24
        peentrypoint    dd      ?               ;28
        pecodebase      dd      ?               ;2C
        pedatabase      dd      ?               ;30
        peimagebase     dd      ?               ;34
        pesectalign     dd      ?               ;38
        pefilealign     dd      ?               ;3C
        pemajoros       dw      ?               ;40
        peminoros       dw      ?               ;42
        pemajorimage    dw      ?               ;44
        peminorimage    dw      ?               ;46
        pemajorsubsys   dw      ?               ;48
        peminorsubsys   dw      ?               ;4A
        pereserved      dd      ?               ;4C
        peimagesize     dd      ?               ;50
        pehdrsize       dd      ?               ;54
        pechksum        dd      ?               ;58
        pesubsys        dw      ?               ;5C
        pedllflags      dw      ?               ;5E
        pestackmax      dd      ?               ;60
        pestacksize     dd      ?               ;64
        peheapmax       dd      ?               ;68
        peheapsize      dd      ?               ;6C
        peldrflags      dd      ?               ;70
        pervacount      dd      ?               ;74
        peexport        pedir   <?>             ;78
        peimport        pedir   <?>             ;80
        persrc          pedir   <?>             ;88
        peexcpt         pedir   <?>             ;90
        pesecurity      pedir   <?>             ;98
        pereloc         pedir   <?>             ;A0
        pedebug         pedir   <?>             ;A8
        pearch          pedir   <?>             ;B0
        peglobal        pedir   <?>             ;B8
        petls           pedir   <?>             ;C0
        peconfig        pedir   <?>             ;C8
        pebound         pedir   <?>             ;D0
        peiat           pedir   <?>             ;D8
        pedelay         pedir   <?>             ;E0
        pecom           pedir   <?>             ;E8
        persrv          pedir   <?>             ;F0
pehdr           ends

peexp           struct
        expflags        dd      ?
        expdatetime     dd      ?
        expmajorver     dw      ?
        expminorver     dw      ?
        expdllrva       dd      ?
        expordbase      dd      ?
        expadrcount     dd      ?
        expnamecount    dd      ?
        expadrrva       dd      ?
        expnamerva      dd      ?
        expordrva       dd      ?
peexp           ends

mzhdr           struct
        mzsig           dw      ?               ;00
        mzpagemod       dw      ?               ;02
        mzpagediv       dw      ?               ;04
        mzrelocs        dw      ?               ;06
        mzhdrsize       dw      ?               ;08
        mzminalloc      dw      ?               ;0A
        mzmaxalloc      dw      ?               ;0C
        mzss            dw      ?               ;0E
        mzsp            dw      ?               ;10
        mzchksum        dw      ?               ;12
        mzip            dw      ?               ;14
        mzcs            dw      ?               ;16
        mzreloff        dw      ?               ;18
        mzfiller        db      22h dup (?)     ;1A
        mzlfanew        dd      ?               ;3C
mzhdr           ends
align                                           ;restore default alignment
