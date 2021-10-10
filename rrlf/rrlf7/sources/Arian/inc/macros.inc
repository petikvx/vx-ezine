; By using this file, you agree to the terms and conditions set
; forth in the COPYING file which can be found at the top level
; of this distribution.
;
;------------------------------------------------------------------------------
%define	O(x)		(x - _start)

%macro movb 2
%if %2 == 0
	xor	%1, %1
%else
	push	byte %2
	pop	%1
%endif
%endmacro
%macro  mpush 1-* 
	%rep  %0 
		push    %1 
		%rotate 1 
	%endrep 
%endmacro

%macro	pp 2
	db	10, %1
	%strlen l %1
	%rep (32 - l)
		db ' '
	%endrep
	%assign	i 1000
	%rep 4
		%assign	n %2/i
		%if (n > 0)
			db	(n % 10 + '0')
		%else
			db	' '
		%endif
		%assign i i/10
	%endrep
%endmacro
