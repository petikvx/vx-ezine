; VirusHalt v1.2 (c) by Andrew V. Basharimoff
; 2:454/2.175@fidonet

LenCRC		=	3F2h
Save_15h_seg	=	186h
SelfCRC 	equ	LenCRC
ID		equ	SelfCRC-6
crcMBR_new	equ	SelfCRC-4
crcMBR_old	equ	SelfCRC-2
LenLoader	=	600h
OldSector	=	4
StartSector	=	5
Sec		=	2

model Tiny
codeseg
startupcode

	cld
	xor	dl,dl
	mov	ax,3302h
	int	21h
	mov	ah,0Dh
	int	21h
	mov	StoreBreak,dl
	mov	ax,3513h
	int	21h
	push	bx es
	mov	ah,30h
	int	21h
	xchg	ah,al
	cmp	ax,31Eh
	jb	NoGetDrv
	mov	ah,13h
	int	2Fh
	push	dx ds
	mov	ah,13h
	int	2Fh
	pop	ds dx
	mov	ax,2513h
	int	21h
NoGetDrv:
	push	cs cs
	pop	ds es
	lea	dx,Logo
	mov	ah,9
	int	21h
	mov	si,81h
	mov	cl,[si-1]
	xor	ch,ch
	lea	dx,Help
	jcxz	DosPrintZero
NextCheck:
	lodsb
	cmp	al,'/'
	loopnz	NextCheck
DosPrintZero:
	test	cx,cx
	jz	GoDosPrint
	lodsb
	and	al,0DFh
	cmp	al,'I'
	je	Install
	cmp	al,'R'
	jne	NextCheck
Install:
	push	ax
	mov	cx,1
	mov	dx,80h
	lea	bx,Buffer
	mov	ax,201h
	int	13h
	pop	ax
	jc	GoErrInst
	mov	di,bx
	lea	si,MBR
	mov	cx,LenHead
	repe	cmpsb
	lahf
	cmp	al,'R'
	jne	NoRemove
	jmp	Remove
NoRemove:
	sahf
	lea	dx,AlreadyInst
	je	DosPrint
	lea	dx,CannotInstall
	lea	di,[bx+1BFh]
	mov	cl,4
NextPartition:
	cmp	ch,[di+3]
	je	EmptyPart
	cmp	ch,[di]
	jne	EmptyPart
	test	word ptr [di+1],0FFC0h
GoDosPrint:
	jz	DosPrint
EmptyPart:
	add	di,10h
	loop	NextPartition
	mov	si,bx
	mov	di,200h
	call	CheckCRC
	mov	word ptr ds:MainVHP+crcMBR_old,ax
	mov	cx,OldSector
	mov	dx,80h
	mov	ax,301h
	int	13h
GoErrInst:
	jc	ErrInst
	lea	si,MBR
	lea	di,Buffer
	mov	bx,di
	mov	cx,LenHead
	rep	movsb
	xchg	cx,ax
	mov	cx,1BEh-LenHead
	rep	stosb
	mov	si,bx
	mov	di,200h
	call	CheckCRC
	mov	word ptr ds:MainVHP+crcMBR_new,ax
	mov	cl,StartSector
	push	bx
	lea	bx,MainVHP
	mov	ax,300h+Sec
	int	13h
	pop	bx
	jc	ErrInst
	mov	cl,1
	mov	ax,301h
	int	13h
	lea	dx,Okay
	jnc	DosPrint
ErrInst:
	lea	dx,Error
DosPrint:
	mov	ah,9
	int	21h
	xchg	dx,ax
	sub	ax,offset Okay
	jnz	Exit
	int	16h
	db	0EAh
	dw	0,-1
Exit:
	pop	ds dx
	mov	ax,2513h
	int	21h
	mov	dl,0
StoreBreak	=	byte ptr $-1
	mov	ax,3301h
	int	21h
	retn
Remove:
	lea	dx,NotPrs
	sahf
	jne	DosPrint
	mov	cl,OldSector
	mov	dx,80h
	mov	ax,201h
	int	13h
	jc	ErrInst
	mov	ax,0AA55h
	cmp	word ptr ds:Buffer+1FEh,ax
	lea	dx,NotRemove
	jne	DosPrint
	mov	cl,1
	mov	dx,80h
	int	13h
	jnc	NoErr
	mov	ax,301h
	int	13h
	jc	ErrInst
NoErr:
	lea	dx,RemoveStr
	jmp	DosPrint

MBR:
	xor	bx,bx
	cli
	mov	ss,bx
	mov	sp,7C00h
	sti
	mov	di,40h
	mov	ds,di
	int	12h
	mov	cl,6
	shl	ax,cl
	mov	es,ax
	cmp	word ptr es:ID,'HV'
	je	AlreadyInMem
	dec	word ptr [bx+13h]
	sub	ax,di
	mov	es,ax
AlreadyInMem:
	mov	cx,StartSector
	mov	dx,80h
	mov	si,cx
NextRead:
	dec	si
	jnz	NoBasic
	int	18h
NoBasic:
	xor	ah,ah
	int	13h
	mov	ax,200h+Sec
	int	13h
	jc	NextRead
	push	es
	pop	ds
	cmp	word ptr ds:ID,'HV'
	jne	VHerror
	cmp	word ptr ds:Save_15h_Seg,0AA55h
	je	VHexit
	xor	si,si
	call	CheckSelfCRC
	cmp	ax,word ptr ds:SelfCRC
	jne	VHerror
VHexit:
	push	es bx
	retf
VHerror:
	mov	si,AddrCorruptBody+7C00h
RealHlt:
	call	Print
	cli
	jmp	$

Print:
	cld
	push	bx
	mov	ah,0Fh
	int	10h
	mov	bl,7
NextPrint:
	lods	byte ptr cs:[si]
	neg	al
	jz	ExitPrn
	mov	ah,0Eh
	int	10h
	jmp	NextPrint
ExitPrn:
	pop	bx
	retn

;ds:si=ptr
;di=size
;return:    ax=crc16 (cx:dx=crc32)

CheckSelfCRC:
	mov	di,LenCRC
CheckCRC:
	cld
	push	bx cx dx si
	mov	cx,-1
	mov	dx,cx
NextByte:
	xor	ax,ax
	xor	bx,bx
	lodsb
	xor	al,cl
	mov	cl,ch
	mov	ch,dl
	mov	dl,dh
	mov	dh,8
NextBit:
	shr	bx,1
	rcr	ax,1
	jnc	NoCarry
	xor	ax,08320h
	xor	bx,0EDB8h
NoCarry:
	dec	dh
	jnz	NextBit
	xor	cx,ax
	xor	dx,bx
	dec	di
	jnz	NextByte
	not	dx
	not	cx
	mov	ax,dx
	ror	ax,cl
	add	ax,cx
	pop	si dx cx bx
	retn

AddrCorruptBody equ	$-MBR
CorruptBody	db	not 7-1,not'V'-1,not'H'-1,not'-'-1,not'P'-1,not' '-1,not'h'-1,not'a'-1,not's'-1,not' '-1
		db	not'b'-1,not'e'-1,not'e'-1,not'n'-1,not' '-1,not'c'-1,not'o'-1,not'r'-1,not'r'-1,not'u'-1
		db	not'p'-1,not't'-1,not'e'-1,not'd'-1,not'.'-1,not' '-1,not'S'-1,not'y'-1,not's'-1,not't'-1
		db	not'e'-1,not'm'-1,not' '-1,not'h'-1,not'a'-1,not'l'-1,not't'-1,not'e'-1,not'd'-1,not'.'-1,0
ErrCRC		equ	$-MBR
LenHead 	equ	$-MBR

Logo		db	0dh,0ah
		db	'ีออออออออออออออออออออออออออออธ',0dh,0ah
		db	'ณ  þþ VirusHalt Protect þþ   ณ',0dh,0ah
		db	'ณ version 1.2.1 (21/04/1997) ณ',0dh,0ah
		db	'ณ    (c) 1995-7 Copyright    ณ',0dh,0ah
		db	'ณ    Andrew V. Basharimoff   ณ',0dh,0ah
		db	'ิออออออออออออออออออออออออออออพ',0dh,0ah,0ah,'$'
Help		db	'Used to protect MBR and hard disk.',0dh,0ah
		db	'Usage: VIRUHALT /Option',0dh,0ah
		db	'Options:',0dh,0ah
		db	' I - install VH-P into hard disk.',0dh,0ah
		db	' R - remove VH-P from hard disk.',0dh,0ah,0ah
		db	'Please see VIRUHALT.DOC for full information.',0dh,0ah,'$'
Okay		db	'VH-P installed successfully.',0dh,0ah
		db	'Press any key for rebooting...',0dh,0ah,'$'
AlreadyInst	db	'VH-P is already installed.',0dh,0ah,'$'
RemoveStr	db	'VH-P has removed from hard disk.',0dh,0ah,'$'
NotPrs		db	7,'VH-P is not present on hard disk.',0dh,0ah,'$'
CannotInstall	db	7,'VH-P cannot to install on hard disk.',0dh,0ah,'$'
NotRemove	db	7,'Cannot to remove VH-P from hard disk.',0dh,0ah,'$'
Error		db	7,'Disk I/O error.',0dh,0ah,'$'


MainVHP db	LenLoader dup (?)
Buffer	db	200h dup (?)

		end

