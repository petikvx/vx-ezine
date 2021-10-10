title	tsr_3.plm
subttl	PLM 1.5  Moscow, 8-Jul-92

 _keyboardflags  	equ	 0417h
 request         	equ	       0abbah
reply           	equ	       0babah
hotkey          	equ	       1c0dh
shiftstatus     	equ	       00000001b
 buffersize      	equ	       0

.model	tiny, pascal
LOCALS
.code
JUMPS
	org    100h
tsr_3:
	locals _@
	jmp	initialize
flags	db	00000000b
saveah	db	?
	PUBLIC	int_16h

int_16h	PROC	 far
	USES	
	test	cs:flags,00000001b
	jne	@@l1
	test	ah,11101110b
	je	@@l2
	cmp	ax,request
	jne	pass_16h
	mov	ax,reply
	push	cs
	pop	es
	iret
@@l2:
	test	ah,00000001b
	jne	@@l3
@@l4:
	mov	cs:saveah,ah
	sti
	pushf
	cli
	call	dword ptr cs:old_int_16h
	cmp	ax,hotkey
	je	@@l6
	iret
@@l6:
	call	chkshiftstatus
	je	@@l7
	iret
@@l7:
	call	main
	mov	ah,cs:saveah
	jmp	@@l4
@@l5	equ	@@l3
@@l3:
	mov	cs:saveah,ah
	dec	cs:saveah
	sti
	pushf
	cli
	call	dword ptr cs:old_int_16h
	je	@@l8
	cmp	ax,hotkey
	jne	@@l8
	call	chkshiftstatus
	je	@@l9
	retf	2
@@l9:
	mov	ah,cs:saveah
	pushf
	cli
	call	dword ptr cs:old_int_16h
	call	main
@@l8:
	retf	2
pass_16h:
@@l1:
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

	PUBLIC	main

main	PROC
	USES	ax
	or	cs:flags,00000001b
	mov	ax,0e07h
	int	10h
	and	cs:flags,11111110b
	ret
main	ENDP

initialize:
	mov	ax,request
	int	16h
	cmp	ax,reply
	je	@@l10
	mov	ax,3516h
	int	21h
	mov	word ptr [old_int_16h],bx
	mov	word ptr [old_int_16h+2],es
	mov	dx,offset int_16h
	mov	ah,25h
	int	21h
	mov	es,word ptr ds:[2ch]
	mov	ah,49h
	int	21h
	mov	dx,offset initialize
	add	dx,buffersize
	int	27h
@@l10:
	mov	dx,es
	mov	ax,3516h
	int	21h
	sub	bx,offset int_16h
	mov	ax,es
	sub	ax,dx
	or	ax,bx
	jne	finish
	lds	dx,dword ptr es:old_int_16h
	mov	ax,2516h
	int	21h
	mov	ah,49h
	int	21h
finish:
	mov	ax,4c00h
	int	21h
end	tsr_3