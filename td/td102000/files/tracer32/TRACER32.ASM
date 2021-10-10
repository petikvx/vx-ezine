
; TRACER -- win32 process tracer
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

; DO NOT FORGET to write in soft-ice: 'i3here off' before launching tracer32

; syntax:
;   tracer <program> [cmdline]

; tracer text.exe
; tracer c:\windows\pbrush.exe

include                 debug.inc
include                 consts.inc

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

titlemsg                db      'Tracer32 1.00 (x) 2000 Z0MBiE',13,10,0
error1msg               db      'error loading program',13,10
                        db      'syntax: tracer32 program [cmdline]',13,10,0

include                 tracer.inc

c_mode                  dd      ?
imagebase               dd      ?
curhandle               dd      ?       ; current thread handle

; STARTUP_INFO
sinfo                   db      40h,0,0,0, 40h dup (?)

; PROCESS_INFO
pinfo                   label   dword
pinfo_phandle           dd      ?
pinfo_thandle           dd      ?
pinfo_pid               dd      ?
pinfo_tid               dd      ?

; DEBUG_EVENT
de                      label   byte
de_code                 dd      ?
de_pid                  dd      ?
de_tid                  dd      ?
de_data                 db      1024 dup (?)

ctx                     label   byte
c_contextflags          dd      00010000h+1+2+4+10h  ; 386/486, control,integer,segments,debug
c_dr0                   dd      ?
c_dr1                   dd      ?
c_dr2                   dd      ?
c_dr3                   dd      ?
c_dr6                   dd      ?
c_dr7                   dd      ?
                        db      112 dup (?)     ; fpu
c_gs                    dd      ?
c_fs                    dd      ?
c_es                    dd      ?
c_ds                    dd      ?
c_edi                   dd      ?
c_esi                   dd      ?
c_ebx                   dd      ?
c_edx                   dd      ?
c_ecx                   dd      ?
c_eax                   dd      ?
c_ebp                   dd      ?
c_eip                   dd      ?
c_cs                    dd      ?
c_eflags                dd      ?
c_esp                   dd      ?
c_ss                    dd      ?

opcode                  db      32 dup (?)

tbl                     db      2048 dup (?)

i3_count                dd      ?
i3_addr                 dd      8192 dup (?)    ; const=8191 -- used in code
i3_byte                 db      8192 dup (?)

t2h_id                  dd      256 dup (?)
t2h_handle              dd      256 dup (?)

selector                dq      ?

                        .code
start:
                        lea     edx, titlemsg
                        call    dump_asciiz_edx

                        push    offset tbl
                        call    disasm_init

                        callW   GetCommandLineA
                        xchg    esi, eax
                        lodsb
                        cmp     al, '"'
                        je      __1
                        mov     al, 32
__1:                    mov     edi, esi
                        repnz
__2:                    scasb
                        cmp     byte ptr [edi], 32
                        je      __2

                        push    offset pinfo
                        push    offset sinfo
                        push    0
                        push    0
                        push    DEBUG_PROCESS+DEBUG_ONLY_THIS_PROCESS ; flags
                        push    0
                        push    0
                        push    0
                        push    edi     ; program+cmdline
                        push    0       ; program
                        callW   CreateProcessA
                        or      eax, eax
                        jz      __errorcmdline


;                       push    SLE_WARNING
;                       callW   SetDebugErrorLevel

__cycle:                push    -1
                        push    offset de
                        callW   WaitForDebugEvent
                        or      eax, eax
                        jz      __exit

                        mov     c_mode, DBG_EXCEPTION_NOT_HANDLED

                        cmp     de_code, CREATE_PROCESS_DEBUG_EVENT
                        jne     __skip0

                        mov     eax, de_tid              ; id
                        mov     ebx, de_data.dword ptr 8 ; handle
                        mov     curhandle, ebx
                        call    t2h_add

                        mov     eax, de_data.dword ptr 0Ch  ; imagebase
                        mov     imagebase, eax

                        mov     esi, de_data.dword ptr 1Ch  ; eip
                        call    insert_int3
__skip0:

                        cmp     de_code, CREATE_THREAD_DEBUG_EVENT
                        jne     __skip1

                        mov     eax, de_tid               ; id
                        mov     ebx, de_data.dword ptr 0  ; handle
                        call    t2h_add

                        mov     esi, de_data.dword ptr 8    ; eip
                        call    insert_int3
__skip1:
                        cmp     de_code, EXIT_THREAD_DEBUG_EVENT
                        jne     __skip4

                        mov     eax, de_tid
                        call    t2h_del
__skip4:

                        cmp     de_code, EXCEPTION_DEBUG_EVENT
                        jne     __skip2

                        mov     eax, de_tid
                        call    t2h_convert
                        mov     curhandle, eax

                        mov     al, '('
                        call    dump_al
                        xchg    eax, ebx
                        call    dump_dec ; thread # (neither id nor handle)
                        mov     al, ')'
                        call    dump_al

                        cmp     de_data.dword ptr 0, EXCEPTION_SINGLE_STEP
                        je      __my_except1
                        cmp     de_data.dword ptr 0, EXCEPTION_BREAKPOINT
                        je      __my_except3
__skip2:
                        lea     esi, msgA
                        mov     eax, de_code
                        call    xmsg

                        cmp     de_code, EXIT_PROCESS_DEBUG_EVENT
                        je      __exit
                        cmp     de_code, RIP_EVENT
                        je      __exit

                        cmp     de_code, EXCEPTION_DEBUG_EVENT
                        je      __except

__continue:             push    c_mode  ; DBG_CONTINUE||DBG_EXCEPTION_NOT_HANDLED
                        push    de_tid
                        push    de_pid
                        callW   ContinueDebugEvent

                        jmp     __cycle

__exit:                 callW   GetLastError

                        push    -1
                        callW   ExitProcess

__errorcmdline:         lea     edx, error1msg
                        call    dump_asciiz_edx
                        jmp     __exit

__my_except1:           call    set_tf

                        mov     esi, de_data.dword ptr 12       ; eip at INT1

                        mov     eax, esi
                        call    eax_in_range
                        jnc     __notinrange
                        ; in range

                        call    get_opcode

                        mov     eax, opcode.dword ptr 0
                        and     ax, 0FEFEh  ; f2/f3
                        cmp     al, 0F2h    ; repe/ne
                        jne     __skip8
                        cmp     ah, 0A4h    ; movs
                        je      __skipit
                        cmp     ah, 0A6h    ; cmps
                        je      __skipit
                        cmp     ah, 0AAh    ; stos
                        je      __skipit
                        cmp     ah, 0AEh    ; scas
                        je      __skipit
                        jmp     __skip8
__skipit:
                        push    esi
                        add     esi, 2
                        call    insert_int3
                        call    clear_tf
                        pop     esi
__skip8:

__exc1cont:             call    dump_opcode

                        mov     c_mode, DBG_CONTINUE
                        jmp     __continue

__notinrange:           call    clear_tf

                        push    esi
                        mov     esi, c_esp
                        call    get_opcode
                        pop     esi

                        mov     eax, dword ptr opcode  ; stack: return addr
                        call    eax_in_range
                        jnc     __exc1cont
                        ; in range

                        push    esi
                        mov     esi, dword ptr opcode  ; stack: return addr
                        call    insert_int3
                        pop     esi

                        jmp     __exc1cont

__my_except3:           mov     esi, de_data.dword ptr 12
                        cmp     esi, 80000000h  ; if KERNEL's INT 3 found
                        ja      __krnl_i3         ; do nothing

                        call    set_tf
                        call    delete_int3

__krnl_i3:              call    dump_opcode

                        mov     c_mode, DBG_CONTINUE
                        jmp     __continue

__except:               lea     esi, msgB
                        mov     eax, de_data.dword ptr 0
                        call    xmsg

                        ; no matter what the fuck this exception means

                        call    get_context     ; get FS into ctx struc
                        call    set_context

                        push    offset selector
                        push    c_fs
                        push    curhandle
                        callW   GetThreadSelectorEntry

                        mov     bh, selector.byte ptr 7
                        mov     bl, selector.byte ptr 4
                        shl     ebx, 16
                        mov     bx, selector.word ptr 2

                        mov     esi, ebx
                        call    get_opcode

                        mov     esi, opcode.dword ptr 0   ; SEH's esp
                        add     esi, 4
                        call    get_opcode
                        mov     esi, opcode.dword ptr 0   ; seh handler addr

                        call    insert_int3

                        jmp     __continue

get_context:            push    curhandle
                        callW   SuspendThread

                        push    offset ctx
                        push    curhandle
                        callW   GetThreadContext

                        retn

set_context:            push    offset ctx
                        push    curhandle
                        callW   SetThreadContext

                        push    curhandle
                        callW   ResumeThread

                        retn

; input: EAX=#
;        ESI=structure of the following format:
;          DD #/DD asciizptr
;          ...
;          DD 0,0
xmsg:                   xchg    edi, eax
                        lea     edx, msg_unk
__cycle:                mov     ecx, [esi+4]
                        jecxz   __dump
                        cmp     edi, [esi]
                        je      __found
                        add     esi, 8
                        jmp     __cycle
__found:                mov     edx, [esi+4]
__dump:                 call    dump_asciiz_edx
                        call    dump_crlf
                        retn

get_opcode:             push    0
                        push    size opcode
                        push    offset opcode
                        push    esi
                        push    pinfo_phandle
                        callW   ReadProcessMemory
                        retn

set_opcode:             push    0
                        push    size opcode
                        push    offset opcode
                        push    esi
                        push    pinfo_phandle
                        callW   WriteProcessMemory
                        retn

dump_opcode:            pusha

                        call    get_opcode

__dump:                 mov     eax, esi        ; de_data.dword ptr 12
                        call    dump_hexdword
                        call    dump_space

                        push    offset opcode
                        push    offset tbl
                        call    disasm_main     ; just get opcode length

                        xchg    ecx, eax
                        lea     esi, opcode
__cycle:                call    dump_space
                        lodsb
                        call    dump_hexbyte
                        loop    __cycle

                        call    dump_crlf

                        popa
                        retn

set_tf:                 call    get_context
                        or      c_eflags, 0100h   ; TF
                        call    set_context
                        retn

clear_tf:               call    get_context
                        and     c_eflags, 0FEFFh
                        call    set_context
                        retn

; input: ESI=va (within the context of the debugging process)

insert_int3:            call    get_opcode

                        mov     al, 0CCh
                        xchg    al, byte ptr opcode
                        cmp     al, 0CCh
                        je      __ret

                        mov     ebx, i3_count
                        mov     i3_addr[ebx*4], esi
                        mov     i3_byte[ebx], al
                        inc     i3_count
                        and     i3_count, 8191

                        call    set_opcode

__ret:                  retn

; input:  esi = INT3 address + 1

delete_int3:            call    get_opcode

                        cmp     byte ptr opcode, 0CCh
                        jne     __ret

                        mov     ecx, 8192
                        lea     edi, i3_addr
                        mov     eax, esi
                        repnz   scasd
                        jnz     __ret

                        sub     ecx, 8191
                        neg     ecx

                        xor     eax, eax
                        mov     i3_addr[ecx*4], eax
                        xchg    al, i3_byte[ecx]

                        mov     byte ptr opcode, al
                        call    set_opcode

                        mov     eax, c_eip
                        dec     eax
                        cmp     eax, esi
                        jne     __ret

                        dec     c_eip           ; decrement EIP
                        call    set_context     ; 'coz points to next opcode

__ret:                  retn

; output: CF==1  in range
;         CF==0  not in range
eax_in_range:           push    eax
                        sub     eax, imagebase
                        cmp     eax, 8*1024*1024  ; 8 MB, change to ImageSize
                        pop     eax
                        retn

; input: EAX=id
;        EBX=handle

t2h_add:                pusha
                        xor     ecx, ecx
                        inc     ecx
__cycle:                cmp     t2h_id[ecx*4], 0
                        je      __found
                        inc     cl
                        jnz     __cycle
                        popa
                        retn
__found:                mov     t2h_id[ecx*4], eax
                        mov     t2h_handle[ecx*4], ebx
                        popa
                        retn

; input: EAX=id

t2h_del:                pusha
                        xor     ecx, ecx
                        inc     ecx
__cycle:                cmp     t2h_id[ecx*4], eax
                        je      __found
                        inc     cl
                        jnz     __cycle
                        popa
                        retn
__found:                mov     t2h_id[ecx*4], 0
                        mov     t2h_handle[ecx*4], 0
                        popa
                        retn

; input: EAX=id
; output:EAX=handle
;        EBX=index

t2h_convert:            pusha
                        xor     ecx, ecx
                        inc     ecx
__cycle:                cmp     t2h_id[ecx*4], eax
                        je      __found
                        inc     cl
                        jnz     __cycle
                        xor     eax, eax
                        xor     ebx, ebx
__exit:                 mov     [esp].popa_eax, eax
                        mov     [esp].popa_ebx, ecx
                        popa
                        retn
__found:                mov     eax, t2h_handle[ecx*4]
                        jmp     __exit

include                 console.inc
include                 lde32bin.inc

                        end     start
