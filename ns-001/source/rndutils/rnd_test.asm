; ============================================================================
; Natural Selection Issue #1
; ============================================================================
;
;  Random Number Test Program Template
;
; compile with:
;    tasm32 /m /ml rnd_test.asm
;    tlink32 /Tpe /x rnd_test.obj, rnd_test.exe,, import32.lib
;    pewrsec rnd_test.exe
;

.386
.model flat, stdcall

extrn   GetTickCount:PROC
extrn	ExitProcess:PROC
extrn	_lcreat:PROC
extrn	_lwrite:PROC
extrn	_lclose:PROC

BufSize	equ	10000			; Size of output file

.data
FileName	db 'out.dat',0		; Filename of output file
buffer		db BufSize dup (0)	; Buffer for random Data

Random_Seed     DD      0		; 32-Random Seed (if needed)

.code
HOST:
        call    GetTickCount            ; Initialize random seed.
	and	eax, 7FFFffffh		; Some RNG like only positive nums
        mov     Random_Seed, EAX        ; Initialize Seed.
	xor	ebp, ebp		; No Delta offset (eases import pain)

	call	_lcreat, offset FileName, 0	; create output file
	push	eax				; save handle on stack

	mov	ecx, BufSize		; Setup counter for loop
	lea	edi, buffer		; Setup ptr to buffer
rnd_fillbuf:
	push	ecx			; Save regs
	push	edi
	call	Random			; Get Random Number
	pop	edi			; Restore Registers
	stosb				; Save Random Number
	pop	ecx
	loop	rnd_fillbuf		; and loop for next number

	pop	ebx			; Close file and exit
	call	_lwrite, ebx, offset buffer, BufSize
	call	_lclose, ebx
	call	ExitProcess, 0

Random:
;___________________________________________________________________________
; Random program goes here:
; ~~~~~~~~~~~~~~~~~~~~~~~~~

	call	GetTickCount		; ...For example...

;___________________________________________________________________________
	ret


end HOST
