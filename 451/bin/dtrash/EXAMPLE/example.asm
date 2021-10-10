
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
; Example of using GETD & DTRASH & LDIZX
; for generating data-trash.
; Opens file specified by '_file' variable.Gets data information from it
; and generates data-trash.
;
;
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

DEBUG = 1

include 1.ash
include klimport.ash
include win32api.ash
include pe.ash

include LDIZX\ldizx.ash
include GETD\getd.ash
include ..\dtrash.ash


includelib      import32.lib

        .386
        .model flat

        .data
_log    db      "trash.dmp",0
_file   db      "1.exe",0
_out    db      11+4+8 dup (0)
seed    dd      12345678h
        .code

_start:
                int 3

		xcall GetTickCount
                mov seed,eax

                mov edx,offset _file
                call fopen

                inc eax
                jz exit
		dec eax

                xchg eax,ebx

                call fsize
                xchg eax,ecx

                push ecx
                call malloc
                add esp,4

                xchg eax,edx
                call fread

;------------------------------------------------------------------------------

                push 1000h
                call malloc
                add esp,4

                xchg esi,eax
                push esi
                call ldizx_init
                add esp,4

                push esi
                push offset ldizx
                push offset free
                push offset malloc
                push edx
                call getd
                add esp,4*5

;------------------------------------------------------------------------------

                or eax,eax
                jz exit

                xchg esi,eax
                lodsd
                mov ecx,eax
                shl eax,4

                push eax                                        ; Allocate
                call malloc                                     ;   temp bufer
                add esp,4                                       ;

                xchg edi,eax
                push edi

                int 3
;°° Get needed elements °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

@dt_type_find:
                lodsd
                xchg eax,edx                                    ; EDX = Data RVA
                lodsd
                lodsd
                lodsd

                test al,1                                       ; Type 1 ?
                jnz @dt_type_next                                ;

@dt_type_stos:
                xchg eax,ebx
                xchg eax,edx                                    ; Write RVA
                stosd                                           ;
                stosd
                stosd

                xchg eax,ebx
                mov ah,4
                stosd                                           ; Write type

@dt_type_next:
                loop @dt_type_find

                mov edx,edi
                pop edi
                sub edx,edi
                shr edx,4                                       ; /4

                int 3

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

                mov ecx,1000
                imul eax,ecx,20
                push eax
                call malloc
                add esp,4
                xchg esi,eax

		int 3

		push 1000h
		call malloc
		add esp,4

		push eax
		call dtrash_init
		xchg eax,ebx

                push esi
gen:
                push offset rnd
                push offset seed
                push DTF_ALL xor DTF_ESP+DTF_MFLAGS+DTF_WRITE 

                push esi                        ; out bufer
                push ebx		        ; trash table
                push edx                        ; data size
                push edi                        ; data table
                call dtrash
                add esp,7*4

                add esi,eax
                loop gen

                mov ecx,esi
                pop esi
                sub ecx,esi

                mov edx,offset _log
                call fcreate
                xchg eax,ebx

                mov edx,esi
                call fwrite

                call fclose

                push esi
                call free

                push edi
                call free
                add esp,8


exit:
                push 0
                xcall ExitProcess

include LDIZX\ldizx.inc
include GETD\getd.inc
include ..\dtrash.inc

include fio.inc
include memory.inc
include rnd.inc

end _start