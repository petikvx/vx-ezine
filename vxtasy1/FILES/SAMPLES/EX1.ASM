EXTERN ExitProcess

SECTION CODE USE32 CLASS=CODE
..start:
	xor	eax,eax
	push	eax
	call ExitProcess
	
SECTION DATA USE32 CLASS=DATA

