pd		STRUC
		_edi		DD		?
		_esi		DD		?
		_ebp		DD		?
		_esp		DD		?
		_ebx		DD		?
		_edx		DD		?
		_ecx		DD		?
		_eax		DD		?
		ENDS


ascii_size	macro	x

		db 10,13,10,13,10,13, 'лллллллллллллллллллллллл',10,13
		db 'Х SIZE Х'
		db x/1000 MOD 10 +'0'
		db x/100  MOD 10 +'0'
		db x/10   MOD 10 +'0'
		db x/1    MOD 10 +'0'
		db ' BYTES =',10,13
		db 'лллллллллллллллллллллллл',10,13,10,13,10,13


		endm
