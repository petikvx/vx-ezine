title	tsr_2.plm
subttl	PLM 1.5  Moscow, 8-Jul-92

 _keyboardflags  	equ	 0417h
 hotkey          	equ	       3920h
shiftstatus     	equ	       00000001b
 buffersize      	equ	       0
 request         	equ	       5678h
reply  	equ	 8765h
maxattempt      	equ	       3

.model	tiny, pascal
LOCALS
.code
JUMPS
	org 100h
tsr_2:
	locals _@
	jmp	initialize
flags	db	00000000b
attempts	db	?
saveah	db	?
in_dos_flag	dd	?
	PUBLIC	int_28h

int_28h	PROC	 far
	USES	
	sti
	test	cs:flags,00000001b
	je	@@l1
	or	cs:flags,00000010b
	call	process
	and	cs:flags,11111101b
@@l1:
	cli
	db	0eah
old_int_28h	db	4 dup(?)
int_28h	ENDP

	PUBLIC	int_16h

int_16h	PROC	 far
	USES	
	test	cs:flags,00000100b
	jne	@@l2
	test	ah,11101110b
	je	@@l3
	cmp	ax,request
	jne	pass_16h
	mov	ax,reply
	push	cs
	pop	es
	iret
@@l3:
	test	cs:flags,00000001b
	je	@@l4
	call	process
@@l4:
	test	ah,00000001b
	jne	@@l5
@@l6:
	mov	cs:saveah,ah
	sti
	pushf
	cli
	call	dword ptr cs:old_int_16h
	cmp	ax,hotkey
	je	@@l8
	iret
@@l8:
	call	chkshiftstatus
	je	@@l9
	iret
@@l9:
	call	process
	mov	ah,cs:saveah
	jmp	@@l6
@@l7	equ	@@l5
@@l5:
	mov	cs:saveah,ah
	dec	cs:saveah
	sti
	pushf
	cli
	call	dword ptr cs:old_int_16h
	je	@@l10
	cmp	ax,hotkey
	jne	@@l10
	call	chkshiftstatus
	je	@@l11
	retf	2
@@l11:
	mov	ah,cs:saveah
	pushf
	cli
	call	dword ptr cs:old_int_16h
	call	process
@@l10:
	retf	2
pass_16h:
@@l2:
	db	0eah
old_int_16h	db	4 dup(?)
int_16h	ENDP

	PUBLIC	chkshiftstatus

chkshiftstatus	PROC
	USES	ax,es
	xor	ax,ax
	mov	es,ax
	mov	al,byte ptr es:[_keyboardflags]
	and	al,00001111b
	cmp	al,shiftstatus
	ret
chkshiftstatus	ENDP

	PUBLIC	process

process	PROC
	USES	
	cli
	test	cs:flags,00000100b
	jne	@@l12
	or	cs:flags,00000100b
	call	main_shell
	and	cs:flags,11111011b
@@l12:
	sti
	ret
process	ENDP

	PUBLIC	main_shell

main_shell	PROC
	USES	
	test	cs:flags,00000010b
	jne	@@l13
	push	bx
	push	ds
	lds	bx,cs:in_dos_flag
	cmp	byte ptr ds:[bx],00h
	pop	ds
	pop	bx
	jne	skip_popup
@@l13:
	sti
	call	main
	cli
	and	cs:flags,11111110b
	ret
skip_popup:
	test	cs:flags,00000001b
	je	@@l14
	dec	cs:attempts
	je	@@l15
	ret
@@l15:
	push	ax
	mov	ax,0e07h
	int	10h
	pop	ax
	and	cs:flags,11111110b
	ret
@@l14:
	or	cs:flags,00000001b
	mov	cs:attempts,maxattempt
	ret
main_shell	ENDP

	PUBLIC	main

main	PROC
	USES	ax,cx
	mov	ax,0e07h
	int	10h
	ret
main	ENDP

initialize:
	mov	ax,request
	int	16h
	cmp	ax,reply
	je	@@l16
	mov	ah,34h
	int	21h
	mov	word ptr in_dos_flag,bx
	mov	(word ptr in_dos_flag+2),es
	mov	di,offset old_int_16h
	mov	dx,offset int_16h
	mov	al,16h
	call	set_vector
	mov	di,offset old_int_28h
	mov	dx,offset int_28h
	mov	al,28h
	call	set_vector
	mov	es,word ptr ds:[2ch]
	mov	ah,49h
	int	21h
	mov	dx,offset initialize
	add	dx,buffersize
	int	27h
@@l16:
	mov	dx,es
	mov	al,16h
	mov	si,offset int_16h
	call	chk_vector
	jc	finish
	mov	al,28h
	mov	si,offset int_28h
	call	chk_vector
	jc	finish
	mov	si,offset old_int_16h
	mov	al,16h
	call	restore_vector
	mov	si,offset old_int_28h
	mov	al,28h
	call	restore_vector
	mov	ah,49h
	int	21h
	jmp	finish
finish:
	mov	ax,4c00h
	int	21h
	PUBLIC	set_vector

set_vector	PROC
	USES	
	mov	ah,35h
	int	21h
	mov	word ptr [di],bx
	mov	word ptr [di+2],es
	mov	ah,25h
	int	21h
	ret
set_vector	ENDP

	PUBLIC	restore_vector

restore_vector	PROC
	USES	ds
	lds	dx,dword ptr es:[si]
	mov	ah,25h
	int	21h
	ret
restore_vector	ENDP

	PUBLIC	chk_vector

chk_vector	PROC
	USES	
	mov	ah,35h
	int	21h
	sub	bx,si
	mov	ax,es
	sub	ax,dx
	or	ax,bx
	clc
	je	@@l17
	stc
@@l17:
	ret
chk_vector	ENDP

end	tsr_2