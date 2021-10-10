;
;Below are the following data structures, constants and
; external functions the program uses

.radix 16

; Our imported Win32 API - for the host only
extrn                   ExitProcess : PROC
extrn                   MessageBoxA : PROC

; A couple of useful constants
L                                   equ   <LARGE>
NULL                                equ   L 0

FALSE                               equ   L 0
TRUE                                equ   L 1

; Win32 constants
STANDARD_RIGHTS_REQUIRED            equ   L 0F0000h

CP_ACP                              equ   L 0
CP_OEMCP                            equ   L 1
CP_MACCP                            equ   L 2

PAGE_READONLY                       equ   L 2     
PAGE_READWRITE                      equ   L 4     
PAGE_WRITECOPY                      equ   L 8     

SECTION_QUERY                       equ   L 1
SECTION_MAP_WRITE                   equ   L 2
SECTION_MAP_READ                    equ   L 4
SECTION_MAP_EXECUTE                 equ   L 8
SECTION_MAP_EXTEND_SIZE             equ   L 10

FILE_MAP_COPY                       equ   SECTION_QUERY
FILE_MAP_WRITE                      equ   SECTION_MAP_WRITE
FILE_MAP_READ                       equ   SECTION_MAP_READ

_MAX_PATH                           equ   L 140
_MAX_DRIVE                          equ   L 3
_MAX_DIR                            equ   L 100
_MAX_FNAME                          equ   L 100
_MAX_EXT                            equ   L 100

CREATE_NEW                          equ   L 1
CREATE_ALWAYS                       equ   L 2
OPEN_EXISTING                       equ   L 3
OPEN_ALWAYS                         equ   L 4
TRUNCATE_EXISTING                   equ   L 5

FILE_ATTRIBUTE_READONLY             equ   L 1  
FILE_ATTRIBUTE_HIDDEN               equ   L 2  
FILE_ATTRIBUTE_SYSTEM               equ   L 4  
FILE_ATTRIBUTE_DIRECTORY            equ   L 10  
FILE_ATTRIBUTE_ARCHIVE              equ   L 20  
FILE_ATTRIBUTE_NORMAL               equ   L 80  
FILE_ATTRIBUTE_TEMPORARY            equ   L 100  
FILE_ATTRIBUTE_COMPRESSED           equ   L 800  
FILE_ATTRIBUTE_OFFLINE              equ   L 1000  
FILE_SHARE_NOTSHARED                equ   L 0     ;lapse's constant
FILE_SHARE_READ                     equ   L 1  
FILE_SHARE_WRITE                    equ   L 2  
FILE_SHARE_DELETE                   equ   L 4  
FILE_BEGIN                          equ   L 0
FILE_CURRENT                        equ   L 1
FILE_END                            equ   L 2

GENERIC_WRITE                       equ   L 40000000
GENERIC_READ                        equ   L 80000000

SP_COPY_DELETESOURCE                equ   L 1
SP_COPY_REPLACEONLY                 equ   L 2
SP_COPY_NEWER                       equ   L 4
SP_COPY_NOOVERWRITE                 equ   L 8
SP_COPY_NODECOMP                    equ   L 10
SP_COPY_LANGUAGEAWARE               equ   L 20
SP_COPY_SOURCE_ABSOLUTE             equ   L 40
SP_COPY_SOURCEPATH_ABSOLUTE         equ   L 80
SP_COPY_IN_USE_NEEDS_REBOOT         equ   L 100
SP_COPY_FORCE_IN_USE                equ   L 200
SP_COPY_NOSKIP                      equ   L 400
SP_FLAG_CABINETCONTINUATION         equ   L 800
SP_COPY_FORCE_NOOVERWRITE           equ   L 1000
SP_COPY_FORCE_NEWER                 equ   L 2000
SP_COPY_WARNIFSKIP                  equ   L 4000
SP_COPY_NOBROWSE                    equ   L 8000

GMEM_FIXED                          equ   L 0
GMEM_MOVEABLE                       equ   L 2
GMEM_NOCOMPACT                      equ   L 10
GMEM_NODISCARD                      equ   L 20
GMEM_ZEROINIT                       equ   L 40
GMEM_MODIFY                         equ   L 80
GMEM_DISCARDABLE                    equ   L 100
GMEM_NOT_BANKED                     equ   L 1000
GMEM_SHARE                          equ   L 2000
GMEM_DDESHARE                       equ   L 2000
GMEM_NOTIFY                         equ   L 4000
GMEM_LOWER                          equ   GMEM_NOT_BANKED
GMEM_VALID_FLAGS                    equ   L 7F72
GMEM_INVALID_HANDLE                 equ   L 8000

IMAGE_SCN_TYPE_REG                  equ   L 0
IMAGE_SCN_TYPE_DSECT                equ   L 1
IMAGE_SCN_TYPE_NOLOAD               equ   L 2
IMAGE_SCN_TYPE_GROUP                equ   L 4
IMAGE_SCN_TYPE_NO_PAD               equ   L 8
IMAGE_SCN_TYPE_COPY                 equ   L 10

IMAGE_SCN_CNT_CODE                  equ   L 20
IMAGE_SCN_CNT_INITIALIZED_DATA      equ   L 40
IMAGE_SCN_CNT_UNINITIALIZED_DATA    equ   L 80

IMAGE_SCN_LNK_OTHER                 equ   L 100
IMAGE_SCN_LNK_INFO                  equ   L 200
IMAGE_SCN_TYPE_OVER                 equ   L 400
IMAGE_SCN_LNK_REMOVE                equ   L 800
IMAGE_SCN_LNK_COMDAT                equ   L 1000

IMAGE_SCN_LNK_NRELOC_OVFL           equ   L 1000000
IMAGE_SCN_MEM_DISCARDABLE           equ   L 2000000
IMAGE_SCN_MEM_NOT_CACHED            equ   L 4000000
IMAGE_SCN_MEM_NOT_PAGED             equ   L 8000000
IMAGE_SCN_MEM_SHARED                equ   L 10000000
IMAGE_SCN_MEM_EXECUTE               equ   L 20000000
IMAGE_SCN_MEM_READ                  equ   L 40000000
IMAGE_SCN_MEM_WRITE                 equ   L 80000000

IMAGE_SCN_MEM_FARDATA               equ   L 8000
IMAGE_SCN_MEM_SYSHEAP               equ   L 10000
IMAGE_SCN_MEM_PURGEABLE             equ   L 20000     ;\yup the same
IMAGE_SCN_MEM_16BIT                 equ   L 20000     ;/
IMAGE_SCN_MEM_LOCKED                equ   L 40000
IMAGE_SCN_MEM_PRELOAD               equ   L 80000

IMAGE_DOS_SIGNATURE                 equ   5A4Dh
IMAGE_OS2_SIGNATURE                 equ   454E
IMAGE_OS2_SIGNATURE_LE              equ   454C
IMAGE_NT_SIGNATURE                  equ   L 4550

IMAGE_FILE_RELOCS_STRIPPED          equ   L 1
IMAGE_FILE_EXECUTABLE_IMAGE         equ   L 2
IMAGE_FILE_LINE_NUMS_STRIPPED       equ   L 4
IMAGE_FILE_LOCAL_SYMS_STRIPPED      equ   L 8
IMAGE_FILE_AGGRESIVE_WS_TRIM        equ   L 10
IMAGE_FILE_BYTES_REVERSED_LO        equ   L 80
IMAGE_FILE_32BIT_MACHINE            equ   L 100
IMAGE_FILE_DEBUG_STRIPPED           equ   L 200
IMAGE_FILE_NET_RUN_FROM_SWAP        equ   L 800
IMAGE_FILE_SYSTEM                   equ   L 1000
IMAGE_FILE_DLL                      equ   L 2000
IMAGE_FILE_UP_SYSTEM_ONLY           equ   L 4000
IMAGE_FILE_BYTES_REVERSED_HI        equ   L 8000

MAGIC                               equ   L 0B4h

; useful Win32 structures
FILETIME        struc
dwLowDateTime       dd      ?
dwHighDateTime      dd      ?
FILETIME        ends

; our structures
exe_str         struc                   ;structure of EXE header
exe_sig         dw      ?               ;0
size_mod512     dw      ?               ;2
size_div512     dw      ?               ;4
num_reloc       dw      ?               ;6
exe_hdr_size    dw      ?               ;8
size_mem_min    dw      ?               ;0a
size_mem_max    dw      ?               ;0c
stack_ss        dw      ?               ;0e
stack_sp        dw      ?               ;10
exe_cksum       dw      ?               ;12
csip            dd      ?               ;14
reloc           dw      ?               ;18
overlay         dw      ?               ;1a
huhwhat         db      4 dup (?)       ;1c
behaviour       dw      ?               ;20
reserved        db      1a dup (?)      ;22
pe_offset       dd      ?               ;3c
exe_str         ends

pe_str          struc                   ;Portable Executable structure
pe_sig          dd      ?               ;0
cpu             dw      ?               ;4
num_obj         dw      ?               ;6
timestamp       dd      ?               ;8
symbol_tbl      dd      ?               ;0c
num_sym         dd      ?               ;10
size_NThdr      dw      ?               ;14
flags           dw      ?               ;16
majik           dw      ?               ;18
lmajor          db      ?               ;1a
lminor          db      ?               ;1b
size_code       dd      ?               ;1c
size_idata      dd      ?               ;20
size_udata      dd      ?               ;24
rva_entry       dd      ?               ;28
code_origin     dd      ?               ;2c
data_origin     dd      ?               ;30
image_base      dd      ?               ;34
align_obj       dd      ?               ;38
align_file      dd      ?               ;3c
os_major        dw      ?               ;40
os_minor        dw      ?               ;42
user_major      dw      ?               ;44
user_minor      dw      ?               ;46
subsys_major    dw      ?               ;48
subsys_minor    dw      ?               ;4a
reserved1       dd      ?               ;4c
size_image      dd      ?               ;50
size_hdr        dd      ?               ;54
pe_cksum        dd      ?               ;58
subsys          dw      ?               ;5c
flag_dll        dw      ?               ;5e
size_stack      dd      ?               ;60
commit_stack    dd      ?               ;64
size_heap       dd      ?               ;68
commit_heap     dd      ?               ;6c
flag_ldr        dd      ?               ;70
rva_sizes       dd      ?               ;74
export_tbl      dd      ?               ;78
export_tbl_size dd      ?               ;7c
pe_str          ends

obj_str         struc                   ;Object table structure
obj_name        db      8 dup (?)       ;0
obj_vsize       dd      ?               ;8
obj_rva         dd      ?               ;0c
obj_psize       dd      ?               ;10
obj_poffset     dd      ?               ;14
obj_reserved    db      0c dup (?)      ;18
obj_flags       dd      ?               ;24
obj_str         ends

edt_str         struc                   ;Export directory table structure
edt_flags       dd      ?               ;0
edt_timestamp   dd      ?               ;4
edt_major_ver   dw      ?               ;8
edt_minor_ver   dw      ?               ;0a
edt_dll_rva     dd      ?               ;0c
edt_ord_base    dd      ?               ;10
edt_eat_entries dd      ?               ;14
edt_name_ptrs   dd      ?               ;18
edt_addr_rva    dd      ?               ;1c
edt_name_rva    dd      ?               ;20
edt_ord_rva     dd      ?               ;24
edt_str         ends

;our personal structure for heap allocation
;instantiating multiple copies of this will prevent re-entrancy problems (if there are any?)
;(*) denotes used in kernel infection only
vir_str     struc
ddError             dd      ?
ddBytes             dd      ?

lpInfectMethod      dd      ?           ;the infection called (i.e., kernel or executable)

lpFileName          dd      ?           ;the path of the file we're infecting
lpSrcFile           dd      ?           ;(*)
lpDstFile           dd      ?           ;(*)

hFileMappingObject  dd      ?
hFile               dd      ?
ddFilterAttributes  dd      ?
ddFileSizeInfected  dd      ?

lpBaseAddress       dd      ?
lpKernelBase        dd      ?           ;(*)

ddCreationTime      FILETIME <?>
ddLastAccessTime    FILETIME <?>
ddLastWriteTime     FILETIME <?>
vir_str     ends
