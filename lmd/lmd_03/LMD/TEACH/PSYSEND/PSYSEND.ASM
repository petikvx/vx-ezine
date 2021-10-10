comment *
 PsychodelicMessageSender / v1.02
  (c) 1997 by Psychomancer,SPS.
      2:454/5.9@fidonet

 Under Novell Network 3.x-4.x send anonymous message 2 all users on all
 servers connected.

 build it ->
 tasm /m/t/z/q psysend.asm
 tlink /x/t psysend.obj
*

crlf		=	0d0ah xor 0aaaah

model tiny
codeseg
startupcode

		mov	dx,offset copyright
		call	print
		mov	dx,si
		mov	ah,0dch
		int	21h			;номер собственного соединения
		and	al,al
		je	shortprint
		mov	selfconumber,al
		mov	ax,0f001h
		int	21h			;получить в al номер текущего сервера
		mov	currentserver,al
		mov	ax,0ef04h
		int	21h			;получить в es:si таблицу серверов
						;по 30h байт на имя каждого сервера
						;(max 8 серверов); 0, если конец списка
		xor	al,al
		mov	cx,8
nextserver:	cmp	es:[si],ch
		je	endserverlist
		inc	ax
		add	si,30h
		loop	nextserver
endserverlist:	push	cs
		pop	es
		and	al,al
		je	print
		mov	servernumber,al
		mov	dx,offset help
		mov	di,81h
		mov	cl,[di-1]
		jcxz	print
		mov	al,'"'
		repne	scasb
		jne	print
		mov	si,di
		mov	di,offset msg
		mov	cl,lensendmsg
nextget:	lodsb
		cmp	al,'"'
		je	endget
		cmp	al,0dh
shortprint:	je	print
		stosb
		inc	cx
		inc	lenmsg
		jmp	nextget
endget: 	mov	si,offset request	;request buffer
		mov	[si],cx 		;length of request buffer
		inc	cx
		inc	cx
		mov	dl,1
setserver:	push	dx
		mov	ax,0f000h
		int	21h			;установить текущий сервер
		mov	dx,6			;length of reply buffer
nextmsg:	cmp	connection,0
selfconumber	=	byte ptr $-1
		je	selfconnection
		mov	ax,0f215h
		int	21h			;послать сообщение
selfconnection: inc	connection
		cmp	connection,64h		;max connection number
		jbe	nextmsg
		pop	dx
		inc	dx
		cmp	dl,0
servernumber	=	byte ptr $-1
		jbe	setserver
		mov	dl,0
currentserver	=	byte ptr $-1
		mov	ax,0f000h
		int	21h			;восстановить значение текущего сервера
		mov	dx,offset sentmsg
print:		mov	si,dx
nextprint:	lodsb
		xor	al,0aah
		je	endprint
		int	29h
		jmp	nextprint
endprint:	retn

dbx		macro	string
%		irpc	char,<&string>
		db	'&char' xor 0aah
		endm
		endm

copyright	=	this byte
		db	0ah xor 0aah
		dbx	<PsychodelicMessageSender / v1.02 by Psychomancer,SPS.>
		dw	crlf,0ah xor 0aaaah
noconnect	=	this byte
		db	7 xor 0aah
		dbx	<Network connection is not found.>
		dw	crlf
		db	0aah
help		=	this byte
		dbx	<Usage: PsySend "message">
		dw	crlf
		db	0ah xor 0aah
		dbx	<Send yer msg 2 me on 2:454/5.9@fidonet>
		dw	'!' xor 0aaaah
sentmsg 	=	this byte
		dbx	<Messages is sent successfully.>
		db	0aah

request 	dw	?		;length of sending message
sendmsg 	db	0ah		;send message function
		dw	1		;?
connection	db	1		;connection number
		db	3 dup (0)	;?
lenmsg		db	0		;length of message
lensendmsg	=	$-sendmsg
msg		=	this byte	;message

		end
