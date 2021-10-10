;
; Classical example of self permutating
; Permutates it's body , writes it in file dumpXXXXXXX0 , permutates again,
; writes body in dumpXXXXXXX1 and etc.
;
; 2002-2003 (c) 451

include ..\src\keys.ash


include ..\src\opz.ash
include ..\src\macros.ash
include ..\src\1.ash
include ..\src\ldizx.ash

include ..\list.ash
include ..\ltme.ash

include win32api.ash
include import.ash

includelib import32.lib
extrn	ExitProcess:near

	.586p
	.model flat
	.data

myparam 	ltmeparam<0,0,1>

fname		db 'dump'
fasciinum	db 8 dup ('0')
		db 0

fnum		dd 0




;malog		db 'malloc.log',0
;malloc_ascii   db 'Allocated memory block at:'
;malloc_ascii_size = $ - offset malloc_ascii
;malloc_data	db 8 dup ('0')
;		db 13,10

value		dd 1
seed		dd ?

	.code
_start:
;		int 3

		nop
		nop
_ventry:
		mov ecx,psize
		call randomize
		mov seed,eax
		
;------------------------------------------------------------------------------
		call delta
delta:
		pop edi
		sub edi,5

comment ~
		or value,1234h
		mov value,1234h

		jmp _after_extrn
		jmp _start			; external
_after_extrn:
~
		push 1000h
		call malloc
		add esp,4

		xchg esi,eax
		push esi			;esi=ldizx tables
		call ldizx_init
		add esp,4
	

		push offset seed                ; * seed
		pusho rnd			; * rnd
	
		push offset myparam		; * params
		push LTMEF_ALL xor LTMEF_MSTACK	; * flags
		push esi			; * dtbl
		pusho ldizx			; * dasm
		pusho ltme_mutator		; * mutator
		push ecx			; * csize
		pusho free			; * free
		pusho malloc			; * malloc
		push offset edi			; * ibuf
		call ltme_core
		add esp,11*4

		push esi                        ;
		call free			; Free tables
		add esp,4                       ;

		mov esi,myparam.build_offset
		mov ecx,myparam.build_size

		push esi


		mov eax,fnum
		inc fnum

		mov edx,offset fasciinum
		call hex2ascii

		mov edx,offset  fname
		call fcreate
		xchg eax,ebx

		mov edx,esi			; bufer
		;ecx=size
		;ebx=handle
		call fwrite

		call fclose

;		int 3
;		mov esi,myparam.build_offset
ifndef DEBUG
		mov ecx,myparam.build_size
		jmp esi
endif
;		push eax			;
		call free                       ;
		add esp,4                       ; Release bufer
		                                ;
		push 0
		KernelCall ExitProcess

include ..\ltme_core.inc
include ..\ltme_mutator.inc

include ldizx\ldizx.inc
include rnd\rnd.inc

include memory.inc
include import.inc
include fio.inc
include system.inc
include hex2ascii.inc

		int 3
psize	= ($ - offset _ventry)

end	_start
