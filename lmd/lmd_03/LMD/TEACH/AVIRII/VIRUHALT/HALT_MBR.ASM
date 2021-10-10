; VirusHalt v1.2 (c) by Andrew V. Basharimoff
; 2:454/2.175@fidonet

Sec		=	(LenMBR+511)/200h
StartSector	=	5
OldSector	=	4

model tiny
codeseg
startupcode

	lea	si,Logo
	call	Print
	cmp	Save_15h_seg,0AA55h
	jne	AlreadySaved
	les	ax,dword ptr ss:[bx+13h*4]
	mov	Save_13h_off,ax
	mov	Save_13h_seg,es
	les	ax,dword ptr ss:[bx+15h*4]
	mov	Save_15h_off,ax
	mov	Save_15h_seg,es
	les	ax,dword ptr ss:[76h*4]
	mov	Save_76h_off,ax
	mov	Save_76h_seg,es
	xor	si,si
	call	CheckSelfCRC
	mov	SelfCRC,ax
	mov	ax,300h+Sec
	push	cs
	pop	es
	int	13h
AlreadySaved:
	les	ax,dword ptr ds:Save_15h_off
	mov	ss:[bx+15h*4],ax
	mov	ss:[bx+15h*4+2],es
	mov	word ptr ss:[76h*4],0
Save_76h_off	=	word ptr $-2
	mov	word ptr ss:[76h*4+2],0
Save_76h_seg	=	word ptr $-2
	push	ss ss
	pop	ds es
	mov	bh,7Eh
	mov	ax,200h+Sec
	call	Int_13h_common
	jc	LoadError
	mov	si,bx
	call	CheckSelfCRC
	lea	si,CorruptBody
	cmp	ax,cs:SelfCRC
	stc
	jne	GoPrintHlt
	mov	bh,7Ch
	mov	si,bx
	call	CheckCRCsec
	jne	BadCheck
	mov	cl,1
	call	Int_13h_read
	jc	LoadError
	call	CheckCRCsec
	je	OkayCheck
BadCheck:
	lea	si,Warning
	call	Print
	call	ReadOriginal
	jc	ErrRestore
	jne	ErrRestore
	lea	si,MBR
	mov	cx,LenHead
	mov	di,bx
	rep	movs byte ptr es:[di],cs:[si]
	xchg	cx,ax
	mov	cx,200h-42h-LenHead
	rep	stosb
	inc	cx
	mov	ah,3
	call	Int_13h
	lea	si,Restore
	jnc	OkayRestore
ErrRestore:
	lea	si,NoRestore
OkayRestore:
	call	Print
	lea	si,Press
	call	Print
	cbw
	int	16h
	db	0EAh
	dw	0,-1
OkayCheck:
	cli
	mov	word ptr ds:[13h*4],offset Int_13h_entry
	mov	ds:[13h*4+2],cs
	mov	word ptr ds:[15h*4],offset Int_15h_entry
	mov	ds:[15h*4+2],cs
	sti
	call	ReadOriginal
LoadError:
	lea	si,ErrorLoad
	jc	GoPrintHlt
	je	NoPrintHlt
GoPrintHlt:
	jmp	RealHlt
NoPrintHlt:
	push	ss bx
	retf

ReadOriginal:
	mov	cl,OldSector
	call	Int_13h_read
	jc	ErrReadOriginal
CheckCRCoriginal:
	mov	si,bx
	call	CheckCRCsec
	cmp	ax,cs:crcMBR_old
ErrReadOriginal:
	retn

Int_13h_entry:
	pushf
	push	ax ss
	pop	ss
	db	36h			;SS:
	pushf
	pop	ax
	test	ah,1
	pop	ax
	jz	NoTrace
GetError:
	popf
	mov	ax,300h
ErrRet:
	stc
	jmp	RetFar
NoTrace:
	or	dl,dl
	jns	NoMBR
	cmp	ah,5
	jb	NoFormat
	cmp	ah,7
	jbe	WriteMBR
NoFormat:
	or	dh,dh
	jne	NoMBR
	cmp	ah,3
	je	Write2MBR
	cmp	ax,0AA55h
	je	Write2MBR
	cmp	ah,0Bh
	jne	NoMBR
Write2MBR:
	push	cx
	and	cl,0C0h
	test	cx,cx
	pop	cx
	jz	WriteMBR
NoMBR:
	popf
	call	Int_13h_common
RetFar:
	retf	2
WriteMBR:
	cmp	ax,0AA55h
	jne	NoMyself
	cmp	cx,1
	jne	NoMBR
	push	ds si es
	pop	ds
	call	CheckCRCoriginal
	pop	si ds
	mov	ax,301h
	je	NoMBR
	jmp	GetError
NoMyself:
	mov	ah,0Fh
	int	10h
	xor	ah,ah
	int	10h
	mov	bx,4
	mov	ah,0Bh
	int	10h
	lea	si,Virus
PrintHlt:
	jmp	RealHlt

Int_15h_entry:
	pushf
	cmp	ax,9000h
	jne	NoMyHook
	cmp	cs:Flag,al
	je	ErrRet
NoMyHook:
	popf
	db	0EAh
Save_15h_off	dw	?
Save_15h_seg	dw	0AA55h

Int_13h_read:
	mov	ah,2
Int_13h:
	mov	al,1
Int_13h_common:
	mov	cs:Flag,1
	pushf
	cli
	db	9Ah
Save_13h_off	dw	?
Save_13h_seg	dw	?
	mov	cs:Flag,0
	retn

CheckCRCsec:
	mov	di,200h
	call	CheckCRC
	cmp	ax,cs:crcMBR_new
	retn

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
	cmp	es:ID,'HV'
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
	cmp	ID,'HV'
	jne	VHerror
	cmp	Save_15h_Seg,0AA55h
	je	VHexit
	xor	si,si
	call	CheckSelfCRC
	cmp	ax,SelfCRC
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
CorruptBody	db	7,'VH-P has been corrupted. System halted.',0
ErrCRC		equ	$-MBR
LenHead 	equ	$-MBR


Logo		db	0Dh,0Ah,'/VirusHalt-Protect/ version 1.2.1 (c) 1995-1997 by Andrew V. Basharimoff.',0Dh,0Ah,0Ah,0
Warning 	db	7,'Warning!',0dh,0ah
		db	7,'MBR was changed by VIRUS possible.',0dh,0ah
		db	'Restoring MBR...',0dh,0ah,0
Restore 	db	'Ok.',0dh,0ah,0
NoRestore	db	7,'Error. Your hard disk is infected by VIRUS!',0dh,0ah,0
Press		db	'Press any key for rebooting...',0
ErrorLoad	db	7,'Error loading operating system.',0
Virus		db	7,'Attention!',0dh,0ah
		db	7,'Writing MBR sector DETECTED.',0dh,0ah
		db	7,'It may be VIRUS!',0dh,0ah
		db	7,'SYSTEM HALTED.',0
Flag		db	0
ID		dw	'HV'
crcMBR_new	dw	0
crcMBR_old	dw	0
LenCRC		equ	$-@startup
SelfCRC 	dw	?
LenMBR		equ	$-@startup

		end
