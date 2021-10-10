xcall 		macro	x
			extrn  x:near
			call x
		endm


Pushad_Struc	STRUC
_edi		DD	?
_esi		DD	?
_ebp		DD	?
_esp		DD	?
_ebx		DD	?
_edx		DD	?
_ecx		DD	?
_eax		DD	?
Pushad_Struc	ENDS

