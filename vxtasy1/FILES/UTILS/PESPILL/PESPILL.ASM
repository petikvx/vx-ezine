;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; PESpill V1.0
;
; Portable Executable Dump Utility
;
; (C) Lord Julus 1999
;
; (lordjulus@geocities.com)
;
; This utility doesn't use any IMAGEHLP.DLL imports.
;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
.586p                                  ;
.model flat, stdcall                   ;
                                       ;
jumps                                  ;
                                       ;
extrn IsBadReadPtr:proc                ;
extrn IsBadStringPtrA:proc             ;
extrn LoadLibraryA:proc                ;
extrn FreeLibrary:proc                 ;
extrn ExitProcess:proc                 ;
extrn WriteFile:proc                   ;
extrn GetStdHandle:proc                ;
extrn lstrlen:proc                     ;
extrn lstrcpy:proc                     ;
extrn GetLastError:proc                ;
extrn AllocConsole:proc                ;
extrn CloseHandle:proc                 ;
extrn CreateFileA:proc                 ;
extrn GetCommandLineA:proc             ;
                                       ;
include w32nt_lj.inc                   ;
                                       ;
.data                                  ;
                                       ;
mzheader   dd 0                        ;
peheader   dd 0                        ;
opheader   dd 0                        ;
scheader   dd 0                        ;
datadir    dd 0                        ;
firstsec   dd 0                        ;
                                       ;
outhandle  dd 0                        ;
hconsole   dd 0                        ;
temp       dd 0                        ;
outputfile db 260 dup(0), 0            ;
                                       ;
maphandle  dd 0                        ;
filehandle dd 0                        ;
filesize   dd 0                        ;
memory     dd 0                        ;
imagebase  dd 0                        ;
                                       ;
hexoutput db 10 dup(0)                 ;
hexstuff  db '0123456789ABCDEF'        ;
                                       ;
emptyline db 260 dup(0)                ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
d1        EQU <db 20h, 76 dup('Ä'), 0dh, 0ah>
d2        EQU <db 20h, 76 dup('Í'), 0dh, 0ah>
d3        EQU <db 20h, 76 dup('±'), 0dh, 0ah>
sep1      d1, 0
sep2      d2, 0
sep3      d3, 0

startuplines label
d3
db '                   PE-Spill Version 1.0 (C) 1999 Lord Julus',0dh,0ah
d3, 0

CRLF db 0dh, 0ah, 0

error_table label
            db 1, "Error #001: No file specified",0ah,0dh,0
            db 2, "Error #002: File has no valid DOS header",0ah,0dh,0
            db 3, "Error #003: File has no valid PE Header",0ah,0dh,0
            db 4, "Error #004: File has no valid Optional Header",0ah,0dh,0
            db 5, "Error #005: Error opening specified file",0ah,0dh,0
            db 6, "Error #006: Error creating output file",0ah,0dh,0
            db 7, "Error #007: Not enough memory to perform action",0ah,0dh,0
            db 0FFh
lasterror   dd 0

mzstartup label
db ' MS-DOS header dump:',0dh,0ah,0dh,0ah,0

mzfields label
 db 'Magic number                     : ',0
 db 'Bytes on last page of file       : ',0
 db 'Pages in file                    : ',0
 db 'Relocations                      : ',0
 db 'Size of header in paragraphs     : ',0
 db 'Minimum extra paragraphs needed  : ',0
 db 'Maximum extra paragraphs needed  : ',0
 db 'Initial (relative) SS value      : ',0
 db 'Initial SP value                 : ',0
 db 'Checksum                         : ',0
 db 'Initial IP value                 : ',0
 db 'Initial (relative) CS value      : ',0
 db 'File address of relocation table : ',0
 db 'Overlay number                   : ',0
 db 4 DUP('Reserved word                    : ',0)
 db 'OEM identifier                   : ',0
 db 'OEM information                  : ',0
 db 10 DUP('Reserved word                    : ',0)
 db 'Address of PE header             : ',0
 db 0FFh

pestartup label
db ' PE Header dump:',0dh,0ah,0dh,0ah,0

pefields label
 db 'PE Magic signature      : ',0
 db 'Machine type            : ',0
 db 'Number of sections      : ',0
 db 'Time/Date stamp         : ',0
 db 'Pointer to symbols      : ',0
 db 'Number of symbols       : ',0
 db 'Size of Optional header : ',0
 db 'File Characteristics    : ',0
 db 0FFh

machines label
dw 0
db '(Unknown)',0
dw 014ch
db '(Intel 386)',0
dw 0162h
db '(MIPS little-endian, 160 big-endian)',0
dw 0166h
db '(MIPS little-endian)',0
dw 0168h
db '(MIPS little-endian)',0
dw 0169h
db '(MIPS little-endian WCE v2)',0
dw 0184h
db '(Alpha_AXP)',0
dw 01F0h
db '(IBM PowerPC Little-Endian)',0
dw 01a2h
db '(SH3 little-endian)',0
dw 01a4h
db '(SH3E little-endian)',0
dw 01a6h
db '(SH4 little-endian)',0
dw 01c0h
db '(ARM Little-Endian)',0
dw 01c2h
db '(Thumb)',0
dw 0200h
db '(Intel 64)',0
dw 0266h
db '(MIPS)',0
dw 0366h
db '(MIPS)',0
dw 0466h
db '(MIPS)',0
dw 0284h
db '(ALPHA64)',0
db 0FFh

pecharacteristics label
dw 0001h
db '- Relocation info stripped from file.',0
dw 0002h
db '- File is executable.',0
dw 0004h
db '- Line numbers stripped from file.',0
dw 0008h
db '- Local symbols stripped from file.',0
dw 0010h
db '- Agressively trim working set.',0
dw 0020h
db '- App can handle >2gb addresses.',0
dw 0080h
db '- Bytes of machine word are reversed.',0
dw 0100h
db '- 32 bit word machine.',0
dw 0200h
db '- Debugging info stripped from file',0
dw 0400h
db '- If Image is on removable media, copy and run from the swap file.',0
dw 0800h
db '- If Image is on Net, copy and run from the swap file.',0
dw 1000h
db '- System File.',0
dw 2000h
db '- File is a DLL.',0
dw 4000h
db '- File should only be run on a UP machine.',0
dw 8000h
db '- Bytes of machine word are reversed.',0
db 0FFh

opstartup label
db ' PE Optional Header dump:',0dh,0ah,0dh,0ah,0

opfields label
db 'Magic word             : ',0 ;       DW
db 'Major Linker version   : ',0 ;       DB
db 'Minor Linker version   : ',0 ;       DB
db 'Size of code section   : ',0 ;       DD
db 'Initialized Data       : ',0 ;       DD
db 'Uninitialized Data     : ',0 ;       DD
db 'Initial entrypoint     : ',0 ;       DD
db 'Code Virtual Address   : ',0 ;       DD
db 'Data Virtual Address   : ',0 ;       DD
db 'Base of image          : ',0 ;       DD
db 'Section Alignment      : ',0 ;       DD
db 'File Alignment         : ',0 ;       DD
db 'Major OS version       : ',0 ;       DW
db 'Minor OS version       : ',0 ;       DW
db 'Major Image version    : ',0 ;       DW
db 'Minor Image version    : ',0 ;       DW
db 'Major Subsys version   : ',0 ;       DW
db 'Minor Subsys version   : ',0 ;       DW
db 'Win32 version          : ',0 ;       DD
db 'Size of image          : ',0 ;       DD
db 'Size of headers        : ',0 ;       DD
db 'Checksum               : ',0 ;       DD
db 'Subsystem              : ',0 ;       DW
db 'DLL characteristic     : ',0 ;       DW
db 'Stack reserve          : ',0 ;       DD
db 'Stack commit           : ',0 ;       DD
db 'Heap reserve           : ',0 ;       DD
db 'Heap commit            : ',0 ;       DD
db 'Loader flags           : ',0 ;       DD
db 'Number of directories  : ',0 ;       DD
db 0FFh

subsystem label
dw 0
db "(Unknown subsystem.)",0
dw 1
db "(Image doesn't require a subsystem.)",0
dw 2
db "(Image runs in the Windows GUI subsystem.)",0
dw 3
db "(Image runs in the Windows character subsystem.)",0
dw 5
db "(Image runs in the OS/2 character subsystem.)",0
dw 7
db "(Image runs in the Posix character subsystem.)",0
dw 8
db "(Image is a native Win9x driver.)",0
dw 9
db "(Image runs in the Windows CE subsystem.)",0
db 0FFh

dllcharacteristics label
dw 1
db 'Call  when  DLL is attached',0
dw 2
db 'Call when a thread terminates.',0
dw 4
db 'Call when a thread starts up.',0
dw 8
db 'Call when DLL exits, or when it gets dettached.',0
db 0FFh

ddstartup label
db ' Data Directory',0dh,0ah,0dh,0ah,0

ddfields label
db 'Export directory',0
db 'Import directory',0
db 'Resource directory',0
db 'Exception directory',0
db 'Security directory',0
db 'Base Relocation directory',0
db 'Debug directory',0
db 'Copyright directory',0
db 'GlobalPtr directory',0
db 'Thread Local Storage directory',0
db 'LoadConfig directory',0
db 'Bound Import directory',0
db 'IAT',0
reserved label
db  'Reserved',0

virtualaddress db '    (virtual address)',0
virtualsize    db '    (virtual size)',0

scstartup label
db ' Section Headers',0dh,0ah,0dh,0ah, 0

scfields label
db 'Section name            : ',0
db 'Virtual size            : ',0
db 'Virtual address         : ',0
db 'Size of raw data        : ',0
db 'Pointer to raw data     : ',0
db 'Pointer to relocations  : ',0
db 'Pointer to line numbers : ',0
db 'Number of relocations   : ',0
db 'Number of line numbers  : ',0
db 'Characteristics         : ',0
db 0FFh

seccharacteristics label
dd 00000020h
db 'Section contains code.',0
dd 00000040h
db 'Section contains initialized data.',0
dd 00000080h
db 'Section contains uninitialized data.',0
dd 00000200h
db 'Section contains comments or some other type of information.',0
dd 00000800h
db 'Section contents will not become part of image.',0
dd 00001000h
db 'Section contents comdat.',0
dd 00004000h
db 'Reset speculative exceptions handling bits in the TLB entries.',0
dd 00008000h
db 'Section content can be accessed relative to GP.',0
dd 00008000h
db 'Section contains far data.',0
dd 00020000h
db 'Section is purgeable.',0
dd 00020000h
db 'Section is 16bit.',0
dd 00040000h
db 'Section is locked.',0
dd 00080000h
db 'Section must load first.',0
dd 00100000h
db '1 byte alignment.',0
dd 00200000h
db '2 bytes alignment.',0
dd 00300000h
db '4 bytes alignment.',0
dd 00400000h
db '8 bytes alignment.',0
dd 00500000h
db '16 bytes alignment.',0
dd 00600000h
db '32 bytes alignment.',0
dd 00700000h
db '64 bytes alignment.',0
dd 00800000h
db '128 bytes alignment.',0
dd 00900000h
db '256 bytes alignment.',0
dd 00A00000h
db '512 bytes alignment.',0
dd 00B00000h
db '1024 bytes alignment.',0
dd 00C00000h
db '2048 bytes alignment.',0
dd 00D00000h
db '4096 bytes alignment.',0
dd 00E00000h
db '8192 bytes alignment.',0
dd 00F00000h
db 'Aligned by mask.',0
dd 01000000h
db 'Section contains extended relocations.',0
dd 02000000h
db 'Section can be discarded.',0
dd 04000000h
db 'Section is not cachable.',0
dd 08000000h
db 'Section is not pageable.',0
dd 10000000h
db 'Section is shareable.',0
dd 20000000h
db 'Section is executable.',0
dd 40000000h
db 'Section is readable.',0
dd 80000000h
db 'Section is writeable.',0
db 0ffh

secname db 10 dup(0)
sectionoff dd 0

importstartup label
db ' Import Section',0dh, 0ah, 0dh, 0ah, 0

importfields label
db 'Original first thunk : ',0
db 'Time/Date Stamp      : ',0
db 'Forwarder chain      : ',0
db 'Offset to name       : ',0
db 'First Thunk address  : ',0
db 0FFh

bline1 db '    Ordinal  Address      Name',0dh,0ah
       db '    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',0dh,0ah, 0

nameless db "(nameless)", 0
noord    db "?????", 0

exportstartup label
db ' Export Section',0dh, 0ah, 0dh, 0ah, 0

exportfields label
db 'Flags                        : ',0
db 'Date / Time                  : ',0
db 'Major version                : ',0
db 'Minor version                : ',0
db 'Pointer to name              : ',0
db 'Base ordinal                 : ',0
db 'Number of exported functions : ',0
db 'Number of exported names     : ',0
db 'Array of function addresses  : ',0
db 'Array of name addresses      : ',0
db 'Array of name ordinals       : ',0
db 0FFh

addr_nr dd 0

initstring db 'PE-Spill V.1.0 (C) 1999',0dh,0ah,0
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
.code                                  ;
                                       ;
start:                                 ;
       call Initialize                 ; initialize console
       call OpenInputFile              ; read input file
       jc exit                         ;
                                       ;
       call CreateOutputFile           ; create output .dmp file
       jc exit                         ;
                                       ;
       call OutputInit                 ;
                                       ;
       call LocateMZHeader C, imagebase, mzheader ; Locate DOS header
       call Error                      ;
       jc exit                         ;
       mov [mzheader], eax             ;
                                       ;
       call LocatePEHeader C, imagebase, mzheader, peheader ; Locate PE
       call Error                      ;                      header
       jc exit                         ;
       mov [peheader], eax             ;
                                       ;
       call LocateOptionalHeader C, peheader, opheader ; Locate optional
       call Error                      ;                 header
       jc exit                         ;
       mov [opheader], eax             ;
                                       ;
       call LocateDataDirectory C, peheader, datadir ; Locate data directory
       mov [datadir], eax              ;
                                       ;
       call LocateSectionHeaders C, peheader, firstsec ; Locate first section
       mov [firstsec], eax             ;
                                       ;
       call DumpMZHeader               ; dump!
                                       ;
       call DumpPEHeader               ; dump!
                                       ;
       call DumpOPHeader               ; dump!
                                       ;
       call DumpDataDirectory          ; dump!
                                       ;
       call DumpSections               ; dump!
                                       ;
       call HandleExportSection        ; dump!
                                       ;
       call HandleImportSection        ; dump!
                                       ;
;      call HandleResourceSection      ; \
;                                      ;  > maybe in next version
;      call HandleRelocationSection    ; /
                                       ;
       call CloseOutputFile            ; close files
                                       ;
       call CloseInputFile             ;
                                       ;
exit:                                  ;
       call OutputLastError            ;
                                       ;
       push 0                          ; and exit.
       call ExitProcess                ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
OpenInputFile proc near                ;
      call GetCommandLineA             ; get the command line.
                                       ;
      cmp eax, 0                       ;
      je open_error                    ;
                                       ;
      mov edi, eax                     ; locate the specified file
      xor eax, eax                     ;
      mov al, '.'                      ;
      mov ecx, 260                     ;
      repnz scasb                      ;
      add edi, 2                       ;
                                       ;
scan_2:                                ;
      inc edi                          ;
      cmp byte ptr [edi], 0            ;
      je open_error                    ;
      cmp byte ptr [edi], '"'          ;
      je scan_2                        ;
      cmp byte ptr [edi], 20h          ;
      jne found_cmd                    ;
      jmp scan_2                       ;
                                       ;
found_cmd:                             ;
      mov esi, edi                     ;
                                       ;
      push esi                         ;
      push offset outputfile           ;
      call lstrcpy                     ;
      lea edi, outputfile              ;
      push edi                         ;
      call lstrlen                     ;
      add edi, eax                     ;
      sub edi, 3                       ;
      mov byte ptr [edi+0], 'D'        ; create <filename>.DMP
      mov byte ptr [edi+1], 'M'        ;
      mov byte ptr [edi+2], 'P'        ;
                                       ;
      push offset esi                  ; load the input file
      call LoadLibraryA                ;
                                       ;
      mov imagebase, eax               ; save the imagebase
                                       ;
      cmp eax, 0                       ;
      je open_error2                   ; can't open file ?!?
      cmp eax, -1                      ;
      je open_error2                   ;
      clc                              ;
      ret                              ;
                                       ;
open_error:                            ;
      call SetLastError, 1             ;
      stc                              ;
open_error2:                           ;
      call SetLastError, 5             ;
      stc                              ;
      ret                              ;
OpenInputFile endp                     ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
CreateOutputFile proc near             ;
       lea esi, outputfile             ; create output file
       push 0                          ;
       push 0                          ;
       push 2                          ;
       push 0                          ;
       push 1                          ;
       push 80000000h or 40000000h     ;
       push esi                        ;
       Call CreateFileA                ;
       cmp eax, -1                     ;
       je open_error_                  ;
       mov [outhandle], eax            ;
       clc                             ;
       ret                             ;
                                       ;
open_error_:                           ;
       stc                             ;
       ret                             ;
CreateOutputFile endp                  ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
CloseOutputFile proc near              ;
       push [outhandle]                ;
       call CloseHandle                ;
       ret                             ;
CloseOutputFile endp                   ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
CloseInputFile proc near               ;
       push imagebase                  ;
       call FreeLibrary                ;
       ret                             ;
CloseInputFile endp                    ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Error proc near                        ; return CF set if EAX=0
       or eax, eax                     ;        CF clear if EAX!=0
       jz zero                         ;
       clc                             ;
       ret                             ;
                                       ;
zero:                                  ;
       stc                             ;
       ret                             ;
Error endp                             ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
LocateMZHeader proc near imagebase_, mzoffset
; Entry:  imagabese = file load address
; Return: EAX = pointer to MZ header  / 0 if fail
       pushad                          ;
       mov esi, imagebase_             ;
       cmp word ptr [esi], 'ZM'        ;
       jne mz_error                    ;
       mov mzoffset, esi               ;
       jmp mz_exit                     ;
                                       ;
mz_error:                              ;
       mov mzoffset, 0                 ;
       call SetLastError, 2            ;
                                       ;
mz_exit:                               ;
       popad                           ;
       mov eax, mzoffset               ;
       ret                             ;
LocateMZHeader endp                    ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
LocatePEHeader proc near imagebase_, mzoffset, peoffset
; Entry:  imagebase = file load address
;         mzoffset  = offset to MZ header
; Return: EAX = offset to PE header / 0 if fail
       pushad                          ;
       mov esi, [mzoffset]             ;
       mov esi, [esi.MZ_lfanew]        ;
       add esi, imagebase_             ;
       cmp word ptr [esi], 'EP'        ;
       jne peheader_error              ;
       mov [peoffset], esi             ;
       jmp peheader_quit               ;
                                       ;
peheader_error:                        ;
       mov [peoffset], 0               ;
       call SetLastError, 3            ;
                                       ;
peheader_quit:                         ;
       popad                           ;
       mov eax, [peoffset]             ;
       ret                             ;
LocatePEHeader endp                    ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
LocateOptionalHeader proc near peoffset, opoffset
; Entry:  peoffset = offset to peheader
; Return: EAX = offset to optional header / 0 if fail
       pushad                          ;
       mov eax, peoffset               ;
       add eax, IMAGE_FILE_HEADER_SIZE ;
       cmp word ptr [eax], 010Bh       ;
       mov [opoffset], eax             ;
       jne op_error                    ;
       jmp opheader_quit               ;
                                       ;
op_error:                              ;
       xor eax, eax                    ;
       mov [opoffset], eax             ;
       call SetLastError, 4            ;
                                       ;
opheader_quit:                         ;
       popad                           ;
       mov eax, [opoffset]             ;
       ret                             ;
LocateOptionalHeader endp              ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
LocateDataDirectory proc near peoffset, datadiroffset
; Entry:  peoffset = offset to pe header
; Return: EAX = offset to DataDirectory
       pushad                          ;
       mov eax, peoffset               ;
       xor ebx, ebx                    ;
       mov bx, word ptr [eax.SizeOfOptionalHeader]
       mov esi, peoffset               ;
       add esi, IMAGE_FILE_HEADER_SIZE ;
       mov eax, [esi.OH_NumberOfRvaAndSizes]
       add esi, ebx                    ;
       mov ecx, SIZE IMAGE_DATA_DIRECTORY
       mul ecx                         ;
       sub esi, eax                    ;
       mov [datadiroffset], esi        ;
       popad                           ;
       mov eax, [datadiroffset]        ;
       ret                             ;
LocateDataDirectory endp               ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
LocateSectionHeaders proc near peoffset, firstsection
; Entry:  peoffset = offset to pe header
; Return: EAX = offset to First Section header
       pushad                          ;
       mov eax, peoffset               ;
       xor ebx, ebx                    ;
       mov bx, word ptr [eax.SizeOfOptionalHeader]
       mov esi, peoffset               ;
       add esi, IMAGE_FILE_HEADER_SIZE ;
       add esi, ebx                    ;
       mov [firstsection], esi         ;
       popad                           ;
       mov eax, [firstsection]         ;
       ret                             ;
LocateSectionHeaders endp              ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
LocateSection proc near firstsection, sectionnr, sectionoffset
; Entry:  firstsection = offset to first section header
;         sectionnr    = what section to search (start from 0!)
; Return: EAX          = offset to the sectionnr section header
       pushad                          ;
       mov esi, [peheader]             ;
       xor eax, eax                    ;
       mov ax, [esi.NumberOfSections]  ;
       cmp sectionnr, eax              ;
       ja section_error                ;
       mov esi, firstsection           ;
       mov ecx, SIZE IMAGE_SECTION_HEADER
       mov eax, sectionnr              ;
       mul ecx                         ;
       add esi, eax                    ;
       mov [sectionoffset], esi        ;
       jmp section_quit                ;
                                       ;
section_error:                         ;
       mov [sectionoffset], 0          ;
                                       ;
section_quit:                          ;
       popad                           ;
       mov eax, [sectionoffset]        ;
       ret                             ;
LocateSection endp                     ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
AddToString proc near destination, source
; destination = string to add to
; source      = string to add to destination
; terminatorZ is preserved
       pushad                          ; works just like lstrcat
       mov edi, destination            ;
       mov esi, source                 ;
       push edi                        ;
       call lstrlen                    ;
       add edi, eax                    ;
       push esi                        ;
       call lstrlen                    ;
       inc eax                         ;
       mov ecx, eax                    ;
       rep movsb                       ;
       popad                           ;
       ret                             ;
AddToString endp                       ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpString proc near handle, address
; Entry:  handle  = file/console to dump to
;         address = address of ascizz string to dump
       pushad                          ;
       push address                    ;
       call lstrlen                    ;
       push 0                          ;
       push offset temp                ;
       push eax                        ;
       push address                    ;
       push handle                     ;
       call WriteFile                  ;
       popad                           ;
       ret                             ;
DumpString endp                        ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SetLastError proc near errornumber     ;
       push eax                        ;
       mov eax, errornumber            ;
       mov [lasterror], eax            ;
       pop eax                         ;
       ret                             ;
SetLastError endp                      ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
OutputLastError proc near              ;
       pushad                          ;
       mov eax, lasterror              ;
       or eax, eax                     ;
       jz no_error                     ;
                                       ;
       lea esi, error_table            ;
                                       ;
error_look_up:                         ;
       cmp byte ptr [esi], 0FFh        ;
       je no_error                     ;
       cmp byte ptr [esi], al          ;
       je do_error                     ;
       mov edi, esi                    ;
       call SeekEOL                    ;
       mov esi, edi                    ;
       jmp error_look_up               ;
                                       ;
do_error:                              ;
       inc esi                         ;
       call DumpString stdcall, [hconsole], esi
                                       ;
no_error:                              ;
       popad                           ;
       ret                             ;
OutputLastError endp                   ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Initialize proc near                   ;
       push STD_OUTPUT_HANDLE          ;
       call GetStdHandle               ;
       cmp eax, -1                     ;
       jne ok_console                  ;
       ret                             ;
                                       ;
ok_console:                            ;
       mov [hconsole], eax             ;
       call DumpString stdcall, [hconsole], offset initstring
       ret                             ;
Initialize endp                        ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpMZHeader proc near                 ;
       lea edi, mzfields               ;
       mov ecx, 31                     ;
       mov esi, mzheader               ;
       xor eax, eax                    ;
                                       ;
       call DumpString stdcall, [outhandle], offset sep1
       call DumpString stdcall, [outhandle], offset mzstartup
                                       ;
rep_dump_mz:                           ;
       cmp byte ptr [edi], 0FFh        ;
       je exit_dump_mz                 ;
                                       ;
       mov eax, 4                      ;
       call IntendChars                ;
                                       ;
       call DumpString stdcall, [outhandle], edi
                                       ;
       cmp ecx, 1                      ;
       jne ok_this                     ;
       mov eax, dword ptr [esi]        ;
       call OutputEAX                  ;
       jmp dump_mz                     ;
                                       ;
ok_this:                               ;
       mov ax, word ptr [esi]          ;
       call OutputAX                   ;
       add esi, 2                      ;
                                       ;
dump_mz:                               ;
       call DumpString stdcall, [outhandle], offset CRLF
       call SeekEOL                    ;
       dec ecx                         ;
       jmp rep_dump_mz                 ;
                                       ;
exit_dump_mz:                          ;
       ret                             ;
DumpMZHeader endp                      ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpPEHeader proc near                 ;
       lea edi, pefields               ;
       mov esi, peheader               ;
       xor eax, eax                    ;
                                       ;
       call DumpString stdcall, [outhandle], offset sep1
       call DumpString stdcall, [outhandle], offset pestartup
       mov ecx, 0                      ;
                                       ;
rep_dump_pe:                           ;
       cmp byte ptr [edi], 0FFh        ;
       je exit_dump_pe                 ;
                                       ;
       mov eax, 4                      ;
       call IntendChars                ;
                                       ;
       call DumpString stdcall, [outhandle], edi
       call DumpPEValue                ;
                                       ;
       cmp ecx, 1                      ;
       jne __not_1                     ;
       call DumpMachineType            ;
                                       ;
__not_1:                               ;
       cmp ecx, 7                      ;
       jne dump_pe                     ;
       call DumpString stdcall, [outhandle], offset CRLF
       call DumpCharacteristics        ;
                                       ;
dump_pe:                               ;
       call DumpString stdcall, [outhandle], offset CRLF
       call SeekEOL                    ;
       inc ecx                         ;
       jmp rep_dump_pe                 ;
                                       ;
exit_dump_pe:                          ;
       ret                             ;
DumpPEHeader endp                      ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpPEValue proc                       ;
       cmp ecx, 1                      ;
       je __word                       ;
       cmp ecx, 2                      ;
       je __word                       ;
       cmp ecx, 6                      ;
       je __word                       ;
       cmp ecx, 7                      ;
       je __word                       ;
                                       ;
       mov eax, [esi]                  ;
       call OutputEAX                  ;
       add esi, 4                      ;
       jmp __quit                      ;
                                       ;
__word:                                ;
       xor eax, eax                    ;
       mov ax, word ptr [esi]          ;
       call OutputAX                   ;
       add esi, 2                      ;
                                       ;
__quit:                                ;
       ret                             ;
DumpPEValue endp                       ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpMachineType proc                   ;
       pushad                          ;
       lea edi, machines               ;
                                       ;
machine_loop:                          ;
       cmp byte ptr [edi], 0FFh        ;
       je machine_quit                 ;
       cmp word ptr [edi], ax          ;
       jne not_machine                 ;
                                       ;
       add edi, 2                      ;
       mov eax, 2                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
       jmp machine_quit                ;
                                       ;
not_machine:                           ;
       inc edi                         ;
       call SeekEOL                    ;
       jmp machine_loop                ;
                                       ;
machine_quit:                          ;
       popad                           ;
       ret                             ;
DumpMachineType endp                   ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpCharacteristics proc near          ;
       pushad                          ;
       lea edi, pecharacteristics      ;
                                       ;
characteristics_loop:                  ;
       cmp byte ptr [edi], 0FFh        ;
       je characteristics_quit         ;
       test ax, word ptr [edi]         ;
       jz not_characteristics          ;
                                       ;
       push eax                        ;
       add edi, 2                      ;
       mov eax, 9                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
       call DumpString stdcall, [outhandle], offset CRLF
       pop eax                         ;
                                       ;
not_characteristics:                   ;
       inc edi                         ;
       inc edi                         ;
       call SeekEOL                    ;
       jmp characteristics_loop        ;
                                       ;
characteristics_quit:                  ;
       popad                           ;
       ret                             ;
DumpCharacteristics endp               ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpOPHeader proc near
       lea edi, opfields               ;
       mov ecx, 0                      ;
       mov esi, opheader               ;
       xor eax, eax                    ;
                                       ;
       call DumpString stdcall, [outhandle], offset sep1
       call DumpString stdcall, [outhandle], offset opstartup
                                       ;
rep_dump_op:                           ;
       cmp byte ptr [edi], 0FFh        ;
       je exit_dump_op                 ;
                                       ;
       mov eax, 4                      ;
       call IntendChars                ;
                                       ;
       call DumpString stdcall, [outhandle], edi
       call DumpOPValue                ;
       cmp ecx, 22                     ;
       jne not__1                      ;
       call DumpString stdcall, [outhandle], offset CRLF
       call DumpSubsystem              ;
                                       ;
not__1:                                ;
       cmp ecx, 23                     ;
       jne not__2                      ;
       call DumpDLLCharacteristics     ;
                                       ;
not__2:                                ;
       cmp ecx, 28                     ;
       jne dump_op                     ;
       call DumpLoaderFlags            ;
                                       ;
dump_op:                               ;
       call DumpString stdcall, [outhandle], offset CRLF
       call SeekEOL                    ;
       inc ecx                         ;
       jmp rep_dump_op                 ;
                                       ;
exit_dump_op:                          ;
       ret                             ;
DumpOPHeader endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpOPValue proc                       ;
       cmp ecx, 0                      ;
       je _word                        ;
       cmp ecx, 12                     ;
       je _word                        ;
       cmp ecx, 13                     ;
       je _word                        ;
       cmp ecx, 14                     ;
       je _word                        ;
       cmp ecx, 15                     ;
       je _word                        ;
       cmp ecx, 16                     ;
       je _word                        ;
       cmp ecx, 17                     ;
       je _word                        ;
       cmp ecx, 22                     ;
       je _word                        ;
       cmp ecx, 23                     ;
       je _word                        ;
                                       ;
       cmp ecx, 1                      ;
       je _byte                        ;
       cmp ecx, 2                      ;
       je _byte                        ;
                                       ;
       mov eax, [esi]                  ;
       call OutputEAX                  ;
       add esi, 4                      ;
       jmp _quit                       ;
                                       ;
_word:                                 ;
       xor eax, eax                    ;
       mov ax, word ptr [esi]          ;
       call OutputAX                   ;
       add esi, 2                      ;
       jmp _quit                       ;
                                       ;
_byte:                                 ;
       xor eax, eax                    ;
       mov al, byte ptr [esi]          ;
       call OutputAX                   ;
       add esi, 1                      ;
       jmp _quit                       ;
                                       ;
_quit:                                 ;
       ret                             ;
DumpOPValue endp                       ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpSubsystem proc near                ;
       pushad                          ;
       lea edi, subsystem              ;
                                       ;
locate_subsystem:                      ;
       cmp byte ptr [edi], 0FFh        ;
       je unknown                      ;
       cmp word ptr [edi], ax          ;
       je found                        ;
       call SeekEOL                    ;
       jmp locate_subsystem            ;
                                       ;
found:                                 ;
       inc edi                         ;
       inc edi                         ;
       mov eax, 29                     ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
       jmp quit_subsystem              ;
                                       ;
unknown:                               ;
       lea edi, subsystem              ;
       jmp found                       ;
                                       ;
quit_subsystem:                        ;
       popad                           ;
       ret                             ;
DumpSubsystem endp                     ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpDLLCharacteristics proc near       ;
       pushad                          ;
       lea edi, dllcharacteristics     ;
                                       ;
locate_dllcharact:                     ;
       cmp byte ptr [edi], 0FFh        ;
       je quit_dllcharact              ;
       cmp word ptr [edi], ax          ;
       je _found                       ;
       call SeekEOL                    ;
       jmp locate_dllcharact           ;
                                       ;
_found:                                ;
       inc edi                         ;
       inc edi                         ;
       mov eax, 29                     ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
                                       ;
quit_dllcharact:                       ;
       popad                           ;
       ret                             ;
DumpDLLCharacteristics endp            ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpLoaderFlags proc near              ;
       pushad                          ;
       popad                           ;
       ret                             ;
DumpLoaderFlags endp                   ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpDataDirectory proc near            ;
       mov esi, opheader               ;
       mov ecx, [esi.OH_NumberOfRvaAndSizes]
       lea edi, ddfields               ;
       mov esi, datadir                ;
       xor eax, eax                    ;
                                       ;
       call DumpString stdcall, [outhandle], offset sep1
       call DumpString stdcall, [outhandle], offset ddstartup
       xor ebx, ebx                    ;
                                       ;
rep_dump_dd:                           ;
       cmp byte ptr [edi], 0FFh        ;
       je exit_dump_dd                 ;
       inc ebx                         ;
                                       ;
       cmp ebx, 13                     ;
       jbe no_change                   ;
       lea edi, reserved               ;
                                       ;
no_change:                             ;
       mov eax, 4                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
       call DumpString stdcall, [outhandle], offset CRLF
                                       ;
       mov eax, 40                     ;
       call IntendChars                ;
       mov eax, dword ptr [esi]        ;
       call OutputEAX                  ;
       call DumpString stdcall, [outhandle], offset virtualaddress
       call DumpString stdcall, [outhandle], offset CRLF
       mov eax, 40                     ;
       call IntendChars                ;
       mov eax, dword ptr [esi+4]      ;
       call OutputEAX                  ;
       call DumpString stdcall, [outhandle], offset virtualsize
       add esi, 8                      ;
                                       ;
       call DumpString stdcall, [outhandle], offset CRLF
       call SeekEOL                    ;
       loop rep_dump_dd                ;
                                       ;
exit_dump_dd:                          ;
       ret                             ;
DumpDataDirectory endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpSections proc near                 ;
       mov esi, peheader               ;
       xor ecx, ecx                    ;
       mov cx, [esi.NumberOfSections]  ;
       mov esi, firstsec               ;
       call DumpString stdcall, [outhandle], offset sep1
       call DumpString stdcall, [outhandle], offset scstartup
                                       ;
sections_loop:                         ;
       lea edi, scfields               ;
       mov ebx, 1                      ;
                                       ;
                                       ;
section_loop:                          ;
       cmp byte ptr [edi], 0FFh        ;
       je no_more                      ;
       mov eax, 4                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
       call SeekEOL                    ;
                                       ;
       cmp ebx, 1                      ;
       jne not___1                     ;
                                       ;
       push edi esi ecx                ;
       mov ecx, 8                      ;
       lea edi, secname                ;
small_loop:                            ;
       rep movsb                       ;
       mov al, 0                       ;
       stosb                           ;
       call DumpString stdcall, [outhandle], offset secname
       pop ecx esi edi                 ;
       add esi, 8                      ;
       jmp dump_sec                    ;
                                       ;
not___1:                               ;
       cmp ebx, 8                      ;
       je ___2                         ;
       cmp ebx, 9                      ;
       je ___2                         ;
                                       ;
       mov eax, [esi]                  ;
       call OutputEAX                  ;
       add esi, 4                      ;
       jmp dump_sec                    ;
                                       ;
___2:                                  ;
       xor eax, eax                    ;
       mov ax, word ptr [esi]          ;
       call OutputAX                   ;
       add esi, 2                      ;
                                       ;
dump_sec:                              ;
       call DumpString stdcall, [outhandle], offset CRLF
       cmp ebx, 10                     ;
       jne _not_                       ;
       call DumpSectionCharacteristics ;
                                       ;
_not_:                                 ;
       inc ebx                         ;
       jmp section_loop                ;
                                       ;
no_more:                               ;
       call DumpString stdcall, [outhandle], offset CRLF
       loop sections_loop              ;
       ret                             ;
DumpSections endp                      ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DumpSectionCharacteristics proc
       pushad                          ;
       lea edi, seccharacteristics     ;
                                       ;
sec_characteristics_loop:              ;
       cmp byte ptr [edi], 0FFh        ;
       je sec_characteristics_quit     ;
       test eax, [edi]                 ;
       jz sec_not_characteristics      ;
                                       ;
       push eax                        ;
       add edi, 4                      ;
       mov eax, 9                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
       call DumpString stdcall, [outhandle], offset CRLF
       pop eax                         ;
                                       ;
sec_not_characteristics:               ;
       add edi, 4                      ;
       call SeekEOL                    ;
       jmp sec_characteristics_loop    ;
                                       ;
sec_characteristics_quit:              ;
       popad                           ;
       ret                             ;
DumpSectionCharacteristics endp        ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
HandleExportSection proc near          ;
       pushad                          ;
       mov esi, datadir                ;
       mov ebx, [esi.DE_Export.DD_VirtualAddress]
       cmp ebx, 0                      ;
       je no_exports                   ;
       mov esi, peheader               ;
       xor ecx, ecx                    ;
       mov cx, word ptr [esi.NumberOfSections]
                                       ;
export_look_up:                        ;
       mov eax, ecx                    ;
       dec eax                         ;
       call LocateSection stdcall, firstsec, eax, sectionoff
       call Error                      ;
       jc section_not_found_1          ;
       mov esi, eax                    ;
       mov eax, [esi.SH_VirtualAddress];
       cmp eax, ebx                    ;
       jbe found_section_1             ;
                                       ;
section_not_found_1:                   ;
       loop export_look_up             ;
       jmp no_exports                  ;
                                       ;
found_section_1:                       ;
;       mov esi, [esi.SH_PointerToRawData];(debug only)
;       mov esi, [esi.SH_VirtualAddress]  ;(          )
       mov esi, ebx                    ;
       add esi, imagebase              ;
       push esi                        ;
       call DumpString stdcall, [outhandle], offset sep1
       call DumpString stdcall, [outhandle], offset exportstartup
                                       ;
       lea edi, exportfields           ;
       mov ebx, 1                      ;
                                       ;
export_loop:                           ;
       cmp byte ptr [edi], 0FFh        ;
       je ready_export                 ;
       mov eax, 4                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
                                       ;
no_number:                             ;
       cmp ebx, 3                      ;
       je ____word                     ;
       cmp ebx, 4                      ;
       je ____word                     ;
                                       ;
       mov eax, [esi]                  ;
       call OutputEAX                  ;
       add esi, 4                      ;
       jmp all_done                    ;
                                       ;
____word:                              ;
       xor eax, eax                    ;
       mov ax, word ptr [esi]          ;
       call OutputAX                   ;
       add esi, 2                      ;
                                       ;
all_done:                              ;
       cmp ebx, 5                      ;
       jne no_name_                    ;
       add eax, imagebase              ;
       mov ebx, eax                    ;
       push 260                        ;
       push eax                        ;
       call IsBadStringPtrA            ;
       or eax, eax                     ;
       jnz no_name_                    ;
       mov eax, 4                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], ebx
                                       ;
no_name_:                              ;
       call DumpString stdcall, [outhandle], offset CRLF
       call SeekEOL                    ;
       inc ebx                         ;
       jmp export_loop                 ;
                                       ;
ready_export:                          ;
       pop esi                         ;
       mov ecx, [esi.ED_NumberOfFunctions]
       mov eax, [esi.ED_AddressOfFunctions]
       mov ebx, [esi.ED_AddressOfNames];
       mov edi, [esi.ED_AddressOfNameOrdinals]
       add eax, imagebase              ;
       add edi, imagebase              ;
       add ebx, imagebase              ;
                                       ;
       call DumpString stdcall, [outhandle], offset CRLF
       call DumpString stdcall, [outhandle], offset bline1
                                       ;
exports_loop:                          ;
       pushad                          ;
                                       ;
       push eax                        ;
       mov eax, 4                      ;
       call IntendChars                ;
       xor eax, eax                    ;
       mov ax, word ptr [edi]          ;
       call OutputAX                   ;
       mov eax, 4                      ;
       call IntendChars                ;
       pop eax                         ;
       mov eax, [eax]                  ;
       call OutputEAX                  ;
       mov eax, 4                      ;
       call IntendChars                ;
       mov ebx, [ebx]                  ;
       add ebx, imagebase              ;
       push 260                        ;
       push ebx                        ;
       call IsBadStringPtrA            ;
       or eax, eax                     ;
       jnz can_t_read                  ;
                                       ;
       call DumpString stdcall, [outhandle], ebx
       call DumpString stdcall, [outhandle], offset CRLF
       jmp read_ok                     ;
                                       ;
can_t_read:                            ;
       call DumpString stdcall, [outhandle], offset nameless
                                       ;
read_ok:                               ;
       popad                           ;
       add eax, 4                      ;
       add ebx, 4                      ;
       add edi, 2                      ;
       loop exports_loop               ;
                                       ;
no_exports:                            ;
       call DumpString stdcall, [outhandle], offset CRLF
       popad                           ;
       ret                             ;
HandleExportSection endp               ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
HandleImportSection proc near          ;
       pushad                          ;
       mov esi, datadir                ;
       mov ebx, [esi.DE_Import.DD_VirtualAddress]
       cmp ebx, 0                      ;
       je no_imports                   ;
       mov esi, peheader               ;
       xor ecx, ecx                    ;
       mov cx, word ptr [esi.NumberOfSections]
       mov edx, 0                      ;
                                       ;
import_look_up:                        ;
       mov eax, ecx                    ;
       dec eax                         ;
       call LocateSection stdcall, firstsec, eax, sectionoff
       call Error                      ;
       jc section_not_found            ;
       mov esi, eax                    ;
       mov eax, [esi.SH_VirtualAddress];
       cmp eax, ebx                    ;
       je found_section                ;
                                       ;
section_not_found:                     ;
       inc edx                         ;
       loop import_look_up             ;
       jmp no_imports                  ;
                                       ;
found_section:                         ;
       mov esi, [esi.SH_VirtualAddress];
       add esi, imagebase              ;
       mov edx, esi                    ;
       call DumpString stdcall, [outhandle], offset sep1
       call DumpString stdcall, [outhandle], offset importstartup
                                       ;
imports_loop:                          ;
       lea edi, importfields           ;
       mov ebx, 1                      ;
       cmp dword ptr [esi], 0          ;
       je no_imports                   ;
       mov edx, esi                    ;
       push edx                        ;
                                       ;
import_loop:                           ;
       cmp byte ptr [edi], 0FFh        ;
       je ready_import                 ;
       mov eax, 4                      ;
       call IntendChars                ;
       call DumpString stdcall, [outhandle], edi
       mov eax, [esi]                  ;
       call OutputEAX                  ;
       add esi, 4                      ;
       call DumpString stdcall, [outhandle], offset CRLF
       call SeekEOL                    ;
       jmp import_loop                 ;
                                       ;
ready_import:                          ;
       call DumpString stdcall, [outhandle], offset CRLF
                                       ;
       mov eax, 8                      ;
       call IntendChars                ;
                                       ;
       mov edi, [edx.ID_Name]          ;
       add edi, imagebase              ;
       call DumpString stdcall, [outhandle], edi
                                       ;
       call DumpString stdcall, [outhandle], offset CRLF
       call DumpString stdcall, [outhandle], offset CRLF
       call DumpString stdcall, [outhandle], offset bline1
                                       ;
       mov edi, [edx.ID_OriginalFirstThunk]
       mov edx, [edx.ID_FirstThunk]    ;
       add edi, imagebase              ;
       add edx, imagebase              ;
       pushad                          ;
                                       ;
rep_imported_names:                    ;
       cmp dword ptr [edi], 0          ;
       je no_more_names                ;
                                       ;
       mov esi, [edi]                  ;
                                       ;
       test esi, 80000000h             ;
       jz not_ordinal                  ;
       xor esi, 80000000h              ;
       mov eax, 4                      ;
       call IntendChars                ;
       mov eax, esi                    ;
       jmp no_no_yes                   ;
                                       ;
not_ordinal:                           ;
       add esi, imagebase              ;
       add esi, 2                      ;
                                       ;
       mov eax, 4                      ;
       call IntendChars                ;
                                       ;
       mov eax, esi                    ;
       sub eax, 2                      ;
                                       ;
       push edx                        ;
       push 10h                        ;
       push eax                        ;
       call IsBadReadPtr               ;
       pop edx                         ;
       or eax, eax                     ;
       jnz no_no_no                    ;
                                       ;
       mov eax, dword ptr [esi-2]      ;
                                       ;
no_no_yes:                             ;
       call OutputAX                   ;
       jmp yes_yes_yes                 ;
                                       ;
no_no_no:                              ;
       lea eax, noord                  ;
       call DumpString stdcall, [outhandle], eax
                                       ;
yes_yes_yes:                           ;
       mov eax, 4                      ;
       call IntendChars                ;
                                       ;
       mov eax, [edx]                  ;
       call OutputEAX                  ;
       mov eax, 4                      ;
       call IntendChars                ;
                                       ;
       push edx                        ;
       push 260                        ;
       push esi                        ;
       call IsBadStringPtrA            ;
       pop edx                         ;
       or eax, eax                     ;
       jnz no_no                       ;
       call DumpString stdcall, [outhandle], esi
       jmp yes_yes                     ;
                                       ;
no_no:                                 ;
       lea eax, nameless               ;
       call DumpString stdcall, [outhandle], eax
                                       ;
yes_yes:                               ;
       call DumpString stdcall, [outhandle], offset CRLF
                                       ;
       add edi, 4                      ;
       add edx, 4                      ;
       jmp rep_imported_names          ;
                                       ;
no_more_names:                         ;
       call DumpString stdcall, [outhandle], offset CRLF
       call DumpString stdcall, [outhandle], offset sep2
       call DumpString stdcall, [outhandle], offset CRLF
       popad                           ;
       pop edx                         ;
       jmp imports_loop                ;
                                       ;
no_imports:                            ;
       popad                           ;
       ret                             ;
HandleImportSection endp               ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
HandleResourceSection proc near        ;
       ret                             ;
HandleResourceSection endp             ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
HandleRelocationSection proc near      ;
       ret                             ;
HandleRelocationSection endp           ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
SeekEOL proc near                      ;
       push eax ecx                    ;
       xor eax, eax                    ;
       mov ecx, 1000                   ;
       repnz scasb                     ;
       pop ecx eax                     ;
       ret                             ;
SeekEOL endp                           ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
WordToHexa proc near                   ;
       push esi edi ecx                ;
       xor ecx, ecx                    ;
       mov cx, ax                      ;
       lea esi, hexstuff               ;
       push ecx                        ;
       and ecx, 0F000h                 ;
       shr ecx, 12                     ;
       mov al, byte ptr [esi+ecx]      ;
       stosb                           ;
       pop ecx                         ;
       push ecx                        ;
       and ecx, 00F00h                 ;
       shr ecx, 8                      ;
       mov al, byte ptr [esi+ecx]      ;
       stosb                           ;
       pop ecx                         ;
       push ecx                        ;
       and ecx, 000F0h                 ;
       shr ecx, 4                      ;
       mov al, byte ptr [esi+ecx]      ;
       stosb                           ;
       pop ecx                         ;
       and ecx, 0000Fh                 ;
       mov al, byte ptr [esi+ecx]      ;
       stosb                           ;
       mov al, 'h'                     ;
       stosb                           ;
       mov al, 0                       ;
       stosb                           ;
       pop ecx edi esi                 ;
       ret                             ;
WordToHexa endp                        ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
DwordToHexa proc near                  ;
       push edi eax                    ;
       push eax                        ;
       shr eax, 16                     ;
       call WordToHexa                 ;
       add edi, 4                      ;
       pop eax                         ;
       and eax, 0000FFFFh              ;
       call WordToHexa                 ;
       pop eax edi                     ;
       ret                             ;
DwordToHexa endp                       ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
OutputAX proc near                     ;
       pushad                          ;
       lea edi, hexoutput              ;
       call WordToHexa                 ;
       call DumpString stdcall, [outhandle], offset hexoutput
       popad                           ;
       ret                             ;
OutputAX endp                          ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
OutputEAX proc near                    ;
       pushad                          ;
       lea edi, hexoutput              ;
       call DwordToHexa                ;
       call DumpString stdcall, [outhandle], offset hexoutput
       popad                           ;
       ret                             ;
OutputEAX endp                         ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
IntendChars proc near                  ;
       push edi ecx                    ;
       mov ecx, eax                    ;
       lea edi, emptyline              ;
       mov al, 20h                     ;
       rep stosb                       ;
       mov al, 0                       ;
       stosb                           ;
       call DumpString stdcall, [outhandle], offset emptyline
       pop ecx edi                     ;
       ret                             ;
IntendChars endp                       ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
OutputInit proc near                   ;
       call DumpString stdcall, [outhandle], offset startuplines
OutputInit endp
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
end start                              ;
end                                    ;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
