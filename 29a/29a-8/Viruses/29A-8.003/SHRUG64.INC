MAX_PATH                        =       260

DLL_PROCESS_ATTACH              =       1
DLL_THREAD_ATTACH               =       2

FILE_ATTRIBUTE_DIRECTORY        =       4 //log2(0x00000010)

GMEM_FIXED                      =       0x0000

OPEN_EXISTING                   =       3

GENERIC_WRITE                   =       0x40000000
GENERIC_READ                    =       0x80000000

IMAGE_FILE_MACHINE_IA64         =       0x200

IMAGE_FILE_RELOCS_STRIPPED      =       0x0000 //log2(0x0001)
IMAGE_FILE_EXECUTABLE_IMAGE     =       0x0002
IMAGE_FILE_SYSTEM               =       0x1000
IMAGE_FILE_DLL                  =       0x2000
IMAGE_FILE_UP_SYSTEM_ONLY       =       0x4000

IMAGE_SUBSYSTEM_WINDOWS_GUI     =       2
IMAGE_SUBSYSTEM_WINDOWS_CUI     =       3

IMAGE_DLLCHARACTERISTICS_WDM_DRIVER =   0x0d //log2(0x2000)

IMAGE_SCN_MEM_EXECUTE           =       0x20000000
IMAGE_SCN_MEM_WRITE             =       7 //log2(0x80)

RANDPADMIN                      =       4096
RANDPADMAX                      =       2048 //RANDPADMIN is added to this

SECTION_MAP_WRITE               =       0x0002

FILE_MAP_WRITE                  =       SECTION_MAP_WRITE

PAGE_READWRITE                  =       04

EXCEPTION_CONTINUE_EXECUTION    =       -1

ContextRecord_StIIP             =       0xa18

//tlsstruc        struct
//        tlsrawbeg       dq      ?               ;00
//        tlsrawend       dq      ?       ;08
//        tlsindex        dq      ?       ;10
//        tlsfuncptr      dq      ?       ;18
//        tlsfiller       dd      ?       ;20
//        tlsflags        dd      ?       ;24
//        tlsfunc     dq      3 dup (?)   ;28
//        tlsfuncind      dq      ?       ;40
//        tlsfuncgp       dq      ?       ;48
//tlsstruc        ends
tlsrawbeg = 0
tlsindex = 0x10
tlsfuncptr = 0x18
tlsflags = 0x24
tlsfunc = 0x28
tlsfuncind = 0x40

//FILETIME        struct
//    dwLowDateTime   dd      ?
//    dwHighDateTime  dd      ?
//FILETIME        ends

//WIN32_FIND_DATA struct
//    dwFileAttributes        dd              ?
//    ftCreationTime          FILETIME        <?>
//    ftLastAccessTime        FILETIME        <?>
//    ftLastWriteTime         FILETIME        <?>
//    dwFileSizeHigh          dd              ?
//    dwFileSizeLow           dd              ?
//    dwReserved0             dd              ?
//    dwReserved1             dd              ?
//    cFileName               dw              260 dup (?)
//    cAlternateFileName      dw              14 dup (?)
//WIN32_FIND_DATA ends
dwFileAttributes = 0
ftCreationTime = 4
ftLastAccessTime = 0x0c
ftLastWriteTime = 0x14
dwFileSizeLow = 0x20
cFileName = 0x2c

//findlist        struct
//    findprev        dq                      ?
//    findhand        dq                      ?
//    finddata        WIN32_FIND_DATA         <?>
//findlist        ends
size_findlist = 0x260
findhand = 8
finddata = 0x10

//coffhdr         struct
//    pemachine       dw      ?               ;04
//    pesectcount     dw      ?               ;06
//    petimedate      dd      ?               ;08
//    pesymbrva       dd      ?               ;0C
//    pesymbcount     dd      ?               ;10
//    peopthdrsize    dw      ?               ;14
//    peflags         dw      ?               ;16
//coffhdr         ends
pemachine = 4
pesectcount = 6
peflags = 0x16
peopthdrsize = 0x14

//pedir           struct
//    dirrva          dd      ?
//    dirsize         dd      ?
//pedir           ends

//pehdr           struct
//    pesig           dd      ?               ;000
//    pecoff          coffhdr <?>
//    pemagic         dw      ?               ;018
//    pemajorlink     db      ?               ;01A
//    peminorlink     db      ?               ;01B
//    pecodesize      dd      ?               ;01C
//    peidatasize     dd      ?               ;020
//    peudatasize     dd      ?               ;024
//    peentrypoint    dd      ?               ;028
//    pecodebase      dd      ?               ;02C
//    peimagebase     dq      ?               ;030
//    pesectalign     dd      ?               ;038
//    pefilealign     dd      ?               ;03C
//    pemajoros       dw      ?               ;040
//    peminoros       dw      ?               ;042
//    pemajorimage    dw      ?               ;044
//    peminorimage    dw      ?               ;046
//    pemajorsubsys   dw      ?               ;048
//    peminorsubsys   dw      ?               ;04A
//    pereserved      dd      ?               ;04C
//    peimagesize     dd      ?               ;050
//    pehdrsize       dd      ?               ;054
//    pechksum        dd      ?               ;058
//    pesubsys        dw      ?               ;05C
//    pedllflags      dw      ?               ;05E
//    pestackmax      dq      ?               ;060
//    pestacksize     dq      ?               ;068
//    peheapmax       dq      ?               ;070
//    peheapsize      dq      ?               ;078
//    peldrflags      dd      ?               ;080
//    pervacount      dd      ?               ;084
//    peexport        pedir   <?>             ;088
//    peimport        pedir   <?>             ;090
//    persrc          pedir   <?>             ;098
//    peexcpt         pedir   <?>             ;0A0
//    pesecurity      pedir   <?>             ;0A8
//    pereloc         pedir   <?>             ;0B0
//    pedebug         pedir   <?>             ;0B8
//    pearch          pedir   <?>             ;0C0
//    peglobal        pedir   <?>             ;0C8
//    petls           pedir   <?>             ;0D0
//    peconfig        pedir   <?>             ;0D8
//    pebound         pedir   <?>             ;0E0
//    peiat           pedir   <?>             ;0E8
//    pedelay         pedir   <?>             ;0F0
//    pecom           pedir   <?>             ;0F8
//    persrv          pedir   <?>             ;100
//pehdr           ends
peimagebase = 0x30
pesectalign = 0x38
pefilealign = 0x3c
peimagesize = 0x50
pechksum = 0x58
pesubsys = 0x5c
peexport = 0x88
pesecurity = 0xa8
pereloc = 0xb0
peglobal = 0xc8
petls = 0xd0

//peexp           struct
//        expflags        dd      ?       ;00
//        expdatetime     dd      ?       ;04
//        expmajorver     dw      ?       ;08
//        expminorver     dw      ?       ;0A
//        expdllrva       dd      ?       ;0C
//        expordbase      dd      ?       ;10
//        expadrcount     dd      ?       ;14
//        expnamecount    dd      ?       ;18
//        expadrrva       dd      ?       ;1C
//        expnamerva      dd      ?       ;20
//        expordrva       dd      ?       ;24
//peexp           ends

//mzhdr           struct
//    mzsig           dw      ?               ;00
//    mzpagemod       dw      ?               ;02
//    mzpagediv       dw      ?               ;04
//    mzrelocs        dw      ?               ;06
//    mzhdrsize       dw      ?               ;08
//    mzminalloc      dw      ?               ;0A
//    mzmaxalloc      dw      ?               ;0C
//    mzss            dw      ?               ;0E
//    mzsp            dw      ?               ;10
//    mzchksum        dw      ?               ;12
//    mzip            dw      ?               ;14
//    mzcs            dw      ?               ;16
//    mzreloff        dw      ?               ;18
//    mzfiller        db      22h dup (?)     ;1A
//    mzlfanew        dd      ?               ;3C
//mzhdr           ends
mzlfanew = 0x3c

//pesect          struct
//        sectname        db      8 dup (?)   ;00
//        sectvirtsize    dd      ?       ;08
//        sectvirtaddr    dd      ?       ;0C
//        sectrawsize     dd      ?       ;10
//        sectrawaddr     dd      ?       ;14
//        sectreladdr     dd      ?       ;18
//        sectlineaddr    dd      ?       ;1C
//        sectrelcount    dw      ?       ;20
//        sectlinecount   dw      ?       ;22
//        sectflags       dd      ?       ;24
//pesect          ends
sectvirtsize = 8
sectvirtaddr = 0x0c
sectrawaddr = 0x14
sectflags = 0x24
size_pesect = 0x28
