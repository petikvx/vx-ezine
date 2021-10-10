
; ---------------------------------------------------------------------------
; DSCRIPT demo
; this program:
;   convert 1k code buffer into script-files 'test1.scr' and 'test2.scr'
; script #1: assemble and create file 'test.bin'
; script #2: assemble and execute code
; ---------------------------------------------------------------------------

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

testscript1             db      'test1.scr',0 ; files created by this program
testscript2             db      'test2.scr',0

testfile                db      'test.bin',0 ; file created by the script

testcode:               db      1000 dup (0CCh) ; code to convert to script
testcode_size           equ     $-testcode

obufsize                dd      ?              ; resulting buffer with script
obuf                    db      512+1000*3 dup (?)

                        .code

start:

 ; file 1

                        push    offset testcode  ; input buffer
                        push    testcode_size    ; input buffer size
                        push    offset obuf      ; output buffer
                        push    size obuf        ; output buffer max size
                        push    offset obufsize  ; ptr to output buffer size
                        push    offset testfile  ; file to be created by the script
                        push    DS_FL_WRITEFILE  ; script action: write file
                        call    dscript

                        cmp     eax, DS_ERR_SUCCESS     ; check error
                        jne     __exit

                        lea     edx, testscript1 ; dump script to file
                        call    fcreate
                        xchg    ebx, eax
                        lea     edx, obuf
                        mov     ecx, obufsize
                        call    fwrite
                        call    fclose

 ; file 2

                        push    offset testcode  ; input buffer
                        push    testcode_size    ; input buffer size
                        push    offset obuf      ; output buffer
                        push    size obuf        ; output buffer max size
                        push    offset obufsize  ; ptr to output buffer size
                        push    0                ; ip, 16-bit, 100h-relative
                        push    DS_FL_EXECUTE    ; script action: exec code
                        call    dscript

                        cmp     eax, DS_ERR_SUCCESS     ; check error
                        jne     __exit

                        lea     edx, testscript2 ; dump script to file
                        call    fcreate
                        xchg    ebx, eax
                        lea     edx, obuf
                        mov     ecx, obufsize
                        call    fwrite
                        call    fclose

__exit:                 push    -1               ; exit
                        callW   ExitProcess

include                 ..\DSCRIPT\dscript.inc   ; DSCRIPT subroutine
include                 fioexlow.inc             ; file io library

                        end     start
