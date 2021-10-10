
callW                   macro   x
                        extern  x:proc
                        call    x
                        endm

                        p386
                        model   flat

                        locals  __

                        .data

msg_searching           db      'searching for LDT in memory: ',0
msg_notfound            db      'not found',0
msg_realaddr            db      13,10,'real LDT address (via GDT) : ',0

                        .code
start:

                        lea     edx, msg_searching
                        call    dump_asciiz

                        call    find_ldt_prepare
                        call    find_ldt_scanmemory
                        jc      __notfound

__found:                mov     eax, ebx
                        call    dump_hexdword

                        jmp     __showreal

__notfound:             lea     edx, msg_notfound
                        call    dump_asciiz

__showreal:             lea     edx, msg_realaddr
                        call    dump_asciiz

                        call    find_ldt_via_gdt

                        mov     eax, ebx
                        call    dump_hexdword
                        call    dump_crlf

                        push    -1
                        callW   ExitProcess

include                 console.inc
include                 ..\FIND_LDT\find_ldt.inc

                        end     start
