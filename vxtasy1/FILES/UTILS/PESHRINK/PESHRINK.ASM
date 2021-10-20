;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
; PEShrink V1.0
;
; Portable Executable Shrink Utility
;
; (C) Lord Julus 1999
;
; (lordjulus@geocities.com)
;
; The import32.lib library must also contain the exports from IMAGEHLP.DLL
; for the checksum calculation...
;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
.586p                                  ;
.model flat, stdcall                   ;
                                       ;
extrn ExitProcess:proc                 ;
extrn GetCommandLineA:proc             ;
extrn CreateFileA:proc                 ;
extrn WriteFile: proc                  ;
extrn GetStdHandle: proc               ;
extrn CloseHandle:proc                 ;
extrn GetFileSize:proc                 ;
extrn CreateFileMappingA:proc          ;
extrn MapViewOfFile:proc               ;
extrn UnmapViewOfFile:proc             ;
extrn SetFilePointer:proc              ;
extrn SetEndOfFile:proc                ;
extrn CheckSumMappedFile:proc          ;
                                       ;
include w32nt_lj.inc                   ;
                                       ;
.data                                  ;
handle           dd 0                  ;
maphandle        dd 0                  ;
mapaddress       dd 0                  ;
filesize         dd 0                  ;
peheader         dd 0                  ;
numberofsections dw 0                  ;
relocs           dd 0                  ;
relocations      dd 0                  ;
newfilesize      dd 0                  ;
checksum         dd 0                  ;
headersum        dd 0                  ;
text             db 13,10,"PEShrink V1.0 by Lord Julus (C) 1999",13,10
text_len =       $-offset text         ;
error            db 13,10,"Error processing specified file!",13,10
error_len =      $-offset error        ;
temp             dd 0                  ;
console          dd 0                  ;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
.code                                  ;
start:                                 ;
        push 0FFFFFFF5h                ; print text on screen...
        call GetStdHandle              ;
        mov console, eax               ;
                                       ;
        or eax, eax                    ;
        jz invalid_console             ;
        push 0                         ;
        push offset temp               ;
        push text_len                  ;
        push offset text               ;
        push eax                       ;
        call WriteFile                 ;
                                       ;
invalid_console:                       ;
        call GetCommandLineA           ;
                                       ;
        cmp eax, 0                     ;
        je open_error                  ;
                                       ;
        mov edi, eax                   ;
        xor eax, eax                   ;
        mov al, '.'                    ;
        mov ecx, 260                   ;
        repnz scasb                    ;
        add edi, 2                     ;
                                       ;
scan_2:                                ;
        inc edi                        ;
        cmp byte ptr [edi], 0          ;
        je open_error                  ;
        cmp byte ptr [edi], '"'        ;
        je scan_2                      ;
        cmp byte ptr [edi], 20h        ;
        jne found_cmd                  ;
        jmp scan_2                     ;
                                       ;
found_cmd:                             ;
        mov esi, edi                   ;
                                       ;
        push 0                         ;
        push 0                         ;
        push OPEN_EXISTING             ;
        push 0                         ;
        push 0                         ;
        push GENERIC_READ or GENERIC_WRITE
        push esi                       ;
        Call CreateFileA               ;
        cmp eax, -1                    ;
        je open_error                  ;
        mov [handle], eax              ;
                                       ;
        push 0                         ;
        push handle                    ;
        call GetFileSize               ;
        cmp eax, -1                    ;
        je close_file                  ;
        mov [filesize], eax            ;
        mov [newfilesize], eax         ;
                                       ;
        push 0                         ;
        push eax                       ;
        push 0                         ;
        push PAGE_READWRITE            ;
        push 0                         ;
        push handle                    ;
        call CreateFileMappingA        ;
                                       ;
        cmp eax, 0                     ;
        je close_file                  ;
        mov [maphandle], eax           ;
                                       ;
        push 0                         ;
        push 0                         ;
        push 0                         ;
        push FILE_MAP_ALL_ACCESS       ;
        push eax                       ;
        call MapViewOfFile             ;
        cmp eax, 0                     ;
        je close_map                   ;
        mov [mapaddress], eax          ;
                                       ;
        call Shrink_File               ;
                                       ;
        push mapaddress                ;
        call UnmapViewOfFile           ;
                                       ;
close_map:                             ;
        push maphandle                 ;
        call CloseHandle               ;
                                       ;
close_file:                            ;
        push FILE_BEGIN                ;
        push 0                         ;
        push newfilesize               ;
        push handle                    ;
        call SetFilePointer            ;
                                       ;
        push handle                    ;
        call SetEndOfFile              ;
                                       ;
        push handle                    ;
        call CloseHandle               ;
        jmp quit                       ;
                                       ;
open_error:                            ;
        mov eax, console               ;
        or eax, eax                    ;
        jz quit                        ;
        push 0                         ;
        push offset temp               ;
        push error_len                 ;
        push offset error              ;
        push eax                       ;
        call WriteFile                 ;
                                       ;
quit:                                  ;
        push 0                         ;
        call ExitProcess               ;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
Shrink_File:                           ;
        mov esi, mapaddress            ;
        cmp word ptr [esi], 'ZM'       ;
        jne exit                       ;
        mov eax, [esi.MZ_lfanew]       ;
        cmp eax, 1000h                 ;
        ja exit                        ;
        add eax, mapaddress            ;
        mov esi, eax                   ;
        mov peheader, esi              ;
        cmp word ptr [esi], 'EP'       ;
        jne exit                       ;
        mov ax, [esi.NumberOfSections] ;
        mov numberofsections, ax       ;
                                       ;
        add esi, IMAGE_FILE_HEADER_SIZE;
                                       ;
        mov ebx, [esi.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress]
        cmp ebx, 0                     ;
        je no_relocations              ;
        mov relocs, ebx                ;
                                       ;
        mov eax, peheader              ;
        xor ebx, ebx                   ;
        mov bx, word ptr [eax.SizeOfOptionalHeader]
        mov esi, peheader              ;
        add esi, IMAGE_FILE_HEADER_SIZE;
        add esi, ebx                   ;
                                       ;
        xor ecx, ecx                   ;
        mov cx, numberofsections       ;
                                       ;
locate_section:                        ;
        mov eax, [esi.SH_VirtualAddress]
        cmp eax, relocs                ;
        je found                       ;
                                       ;
        add esi, IMAGE_SIZEOF_SECTION_HEADER
        loop locate_section            ;
        jmp exit                       ;
                                       ;
found:                                 ;
        mov relocations, esi           ;
                                       ;
        mov eax, peheader              ;
        xor ebx, ebx                   ;
        mov bx, word ptr [eax.SizeOfOptionalHeader]
        mov esi, peheader              ;
        add esi, IMAGE_FILE_HEADER_SIZE;
        add esi, ebx                   ;
                                       ;
        xor eax, eax                   ;
        mov ax, numberofsections       ;
        dec eax                        ;
        mov ecx, IMAGE_SIZEOF_SECTION_HEADER
        xor edx, edx                   ;
        mul ecx                        ;
        add esi, eax                   ;
                                       ;
        cmp esi, relocations           ;
        jne no_relocations             ;
                                       ;
; Relocations is last:                 ;
        push esi                       ; save pointer
                                       ;
        mov ebx, [esi.SH_SizeOfRawData]; get sections' size
        cmp ebx, [esi.SH_VirtualSize]  ;
        jnb ok                         ;
                                       ;
        mov ebx, [esi.SH_VirtualSize]  ;
                                       ;
ok:                                    ;
        mov esi, [esi.SH_PointerToRawData]; get pointer to section data
        push FILE_BEGIN                ; move from beginning
        push 0                         ;
        push esi                       ; new size
        push handle                    ;
        call SetFilePointer            ; set it!
        mov newfilesize, eax           ; and save it!
                                       ;
        pop edi                        ; get the pointer to section header
        mov al, 0                      ; and fill the section header with
        mov ecx, IMAGE_SIZEOF_SECTION_HEADER; zeroes
        repnz stosb                    ;
                                       ;
        mov esi, peheader              ;
        dec [esi.NumberOfSections]     ; decrement number of sections
        add esi, IMAGE_FILE_HEADER_SIZE; go to optional header
                                       ;
        sub [esi.OH_SizeOfImage], ebx  ; decrease size of image
                                       ;
        mov [esi.OH_DataDirectory.DE_BaseReloc.DD_VirtualAddress], 0; reset
        mov ebx, [esi.OH_DataDirectory.DE_BaseReloc.DD_Size]        ; relocs.
        mov [esi.OH_DataDirectory.DE_BaseReloc.DD_Size], 0          ; entry.
        mov edx, 2                     ;
        jmp over_edx                   ;
                                       ;
no_relocations:                        ; Now kill the filesize padding...
        mov edx, 1                     ;
                                       ;
over_edx:                              ;
        mov eax, peheader              ;
        xor ebx, ebx                   ;
        mov bx, word ptr [eax.SizeOfOptionalHeader]
        mov esi, peheader              ;
        add esi, IMAGE_FILE_HEADER_SIZE;
        add esi, ebx                   ;
                                       ;
        xor eax, eax                   ;
        mov ax, numberofsections       ;
        sub eax, edx                   ;
        mov ecx, IMAGE_SIZEOF_SECTION_HEADER
        xor edx, edx                   ;
        mul ecx                        ;
        add esi, eax                   ;
                                       ;
        mov eax, [esi.SH_PointerToRawData]
        mov ebx, [esi.SH_SizeOfRawData];
        cmp ebx, [esi.SH_VirtualSize]  ;
        jnb add_virtual                ;
                                       ;
        add eax, [esi.SH_SizeOfRawData];
        jmp crop_file2                 ;
                                       ;
add_virtual:                           ;
        add eax, [esi.SH_VirtualSize]  ;
                                       ;
crop_file2:                            ;
        push FILE_BEGIN                ; move from beginning
        push 0                         ;
        push eax                       ; new size
        push handle                    ;
        call SetFilePointer            ; set it!
        mov newfilesize, eax           ; and save it!
                                       ;
exit:                                  ;
        mov esi, peheader              ;
        add esi, IMAGE_FILE_HEADER_SIZE;
        cmp dword ptr [esi.OH_CheckSum], 0
        je no_checksum                 ;
        push offset checksum           ; recompute the file checksum
        push offset headersum          ; if necesary
        push newfilesize               ;
        push mapaddress                ;
        call CheckSumMappedFile        ;
        mov eax, dword ptr [checksum]  ;
        mov dword ptr [esi.OH_CheckSum], eax
                                       ;
no_checksum:                           ;
        ret                            ;
                                       ;
end start                              ;
end                                    ;
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
