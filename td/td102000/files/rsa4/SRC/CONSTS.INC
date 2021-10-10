
pusha_eax               =       (dword ptr 7*4)
pusha_ecx               =       (dword ptr 6*4)
pusha_edx               =       (dword ptr 5*4)
pusha_ebx               =       (dword ptr 4*4)
pusha_esp               =       (dword ptr 3*4)
pusha_ebp               =       (dword ptr 2*4)
pusha_esi               =       (dword ptr 1*4)
pusha_edi               =       (dword ptr 0*4)

popa_eax                =       (dword ptr 7*4)
popa_ecx                =       (dword ptr 6*4)
popa_edx                =       (dword ptr 5*4)
popa_ebx                =       (dword ptr 4*4)
popa_esp                =       (dword ptr 3*4)
popa_ebp                =       (dword ptr 2*4)
popa_esi                =       (dword ptr 1*4)
popa_edi                =       (dword ptr 0*4)


VxDcall                 macro   VxD, Service
                        db      0CDh
                        db      020h
                        dw      Service
                        dw      VxD
                        endm

VMMcall                 macro   Service
                        VxDcall VMM, Service
                        endm


VMM                     equ     0001h
Get_Config_Directory    equ     00B7h
Out_Debug_String        equ     00C2h
Get_System_Time         equ     003Fh
GetDDBList              equ     013Fh
PageQuery               equ     0134h
PageAllocate            equ     0053h
PageFree                equ     0055h
PAGEZEROINIT            equ     00000001h
PAGEFIXED               equ     00000008h
PG_SYS                  equ     1
PG_VM                   equ     0
PageModifyPermissions   equ     0133h
PC_WRITEABLE            equ     00020000H
PC_USER                 equ     00040000H
PC_STATIC               equ     20000000H
Call_When_Idle          equ     003Ah
Get_System_Time         equ     003Fh
Hook_Device_Service     equ     0090h
Install_IO_Handler      equ     0096h
Get_DDB                 equ     0146h
IFSMGR                  equ     0040h
Get_Drive_Info          equ     0034h   ; w95: RETN
InstallFileSystemApiHook equ    0067h
GetHeap                 equ     000Dh
UniToBCSPath            equ     0041h
IFSFN_OPEN              equ     36
IFSFN_RENAME            equ     37
IFSFN_FILEATTRIB        equ     33
Ring0_FileIO            equ     0032h
R0_OPENCREATFILE        equ     0D500h  ; Open/Create a file
R0_OPENCREAT_IN_CONTEXT equ     0D501h  ; Open/Create file in current context
R0_READFILE             equ     0D600h  ; Read a file, no context
R0_WRITEFILE            equ     0D601h  ; Write to a file, no context
R0_READFILE_IN_CONTEXT  equ     0D602h  ; Read a file, in thread context
R0_WRITEFILE_IN_CONTEXT equ     0D603h  ; Write to a file, in thread context
R0_CLOSEFILE            equ     0D700h  ; Close a file
R0_GETFILESIZE          equ     0D800h  ; Get size of a file
R0_FINDFIRSTFILE        equ     04E00h  ; Do a LFN FindFirst operation
R0_FINDNEXTFILE         equ     04F00h  ; Do a LFN FindNext operation
R0_FINDCLOSEFILE        equ     0DC00h  ; Do a LFN FindClose operation
R0_FILEATTRIBUTES       equ     04300h  ; Get/Set Attributes of a file
GET_ATTRIBUTES          equ     00h
SET_ATTRIBUTES          equ     01h
R0_RENAMEFILE           equ     05600h  ; Rename a file
R0_DELETEFILE           equ     04100h  ; Delete a file
R0_LOCKFILE             equ     05C00h  ; Lock/Unlock a region in a file
R0_GETDISKFREESPACE     equ     03600h  ; Get disk free space
R0_READABSOLUTEDISK     equ     0DD00h  ; Absolute disk read
R0_WRITEABSOLUTEDISK    equ     0DE00h  ; Absolute disk write
VXDLDR                  equ     0027h
GetDeviceList           equ     0005h


MAXPATH                 equ     260
OPEN_EXISTING           equ     3
CREATE_ALWAYS           equ     2
GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h
FILE_SHARE_READ         equ     00000001h
FILE_SHARE_WRITE        equ     00000002h
FILE_ATTRIBUTE_NORMAL   equ     00000080h
IDLE_PRIORITY_CLASS     equ     00000040h
DETACHED_PROCESS        equ     00000008h

DRIVE_UNKNOWN           equ     0
DRIVE_NO_ROOT_DIR       equ     1
DRIVE_REMOVABLE         equ     2
DRIVE_FIXED             equ     3
DRIVE_REMOTE            equ     4
DRIVE_CDROM             equ     5
DRIVE_RAMDISK           equ     6

SW_NORMAL               equ     1
FILE_BEGIN              equ     0
HKEY_LOCAL_MACHINE      equ     80000002h
REG_SZ                  equ     1
Win32_Get_Ring0_Handle  equ     0033h

GET_ATTRIB_COMP_FILESIZE        equ     2       ; see also IFS.INC
SET_ATTRIB_MODIFY_DATETIME      equ     3
GET_ATTRIB_MODIFY_DATETIME      equ     4
SET_ATTRIB_LAST_ACCESS_DATETIME equ     5
GET_ATTRIB_LAST_ACCESS_DATETIME equ     6
SET_ATTRIB_CREATION_DATETIME    equ     7
GET_ATTRIB_CREATION_DATETIME    equ     8
GET_ATTRIB_FIRST_CLUST          equ     9

OPEN_EXISTING           equ     3
CREATE_ALWAYS           equ     2
GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h
FILE_SHARE_READ         equ     00000001h
FILE_SHARE_WRITE        equ     00000002h
FILE_ATTRIBUTE_NORMAL   equ     00000080h
FILE_BEGIN              equ     0
FILE_END                equ     2

PAGE_EXECUTE_READWRITE  equ     00000040h


ifs_onstack_struc       struc
                        dd      ? ; pushed EDI  ;; PUSHAD
                        dd      ? ; pushed ESI  ;;
                        dd      ? ; pushed EBP
                        dd      ? ; pushed ESP
                        dd      ? ; pushed EBX
                        dd      ? ; pushed EDX
                        dd      ? ; pushed ECX
                        dd      ? ; pushed EAX
                        dd      ? ; return address
                        dd      ? ; the address of the FSD function that is to be called for this API
_function               dd      ? ; the function that is being performed
_drive                  dd      ? ; the 1-based drive the operation is being performed on (-1 if UNC)
                        dd      ? ; the kind of resource the operation is being performed on
_codepage               dd      ? ; the codepage that the user string was passed in on
_ioreq_ptr              dd      ? ; pointer to IOREQ structure
                        ends

ff_struc                struc                   ; win32 "searchrec" structure
ff_attr                 dd      ?
ff_time_create          dd      ?,?
ff_time_lastaccess      dd      ?,?
ff_time_lastwrite       dd      ?,?
ff_size_hi              dd      ?
ff_size                 dd      ?
                        dd      ?,?
ff_fullname             db      260 dup (?)
ff_shortname            db      14 dup (?)
                        ends
