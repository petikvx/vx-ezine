.model small
.386p

.stack 100h

.data

copyleft	db	10,'*DOS2WIN* 0.01 cyrillic file convertor',13,10
		db	'(c) Andrew Basharimov,2:454/2.175@fido.',13,10
		db	'[DOS compatible part is processing]'
crlf		db	13,10,'$'

helpme		db	'Used for convert dos/win russian letters to win/dos.',13,10,10
		db	'Usage: DOS2WIN [/D] inputfile',13,10
		db	'when inputfile - source file,',13,10
		db	'     /D        - convert win to dos letters.',13,10,10
		db	'Please read DOS2WIN.RTF for full information.$'

process		db	'Processing...$'
ok_conv		db	'File successfully converted.$'
err_switch	db	7,'Invalid switch.$'
not_found	db	7,"File isn't found.$"
err_read	db	7,'Error read(write) from(to) file.$'
insuf_mem	db	7,'Insufficient memory.$'

dos2win 	db	'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîï---¦+¦¦¬¬¦¦¬---¬'
		db	'L+T+-+¦¦Lã¦T¦=+¦¦TTLL-ã++----¦¦-ğñòóôõö÷øùúûüışÿ¨¸ªº¯¿¡¢°•·v¹¤¦ '

win2dos 	db	"??'",'?":ÅØ?%?<?????',"''",'""--?T?>????ÿö÷?ı?³ğcò<¿-Rôø+???çúñüó>'
		db	'???õ€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«¬­®¯àáâãäåæçèéêëìíîï'

.data?

filename	db	128 dup (?)

.code

exit:		.exit

bad_switch:	lea	dx,err_switch
		jmp	go_print

get_help:	lea	dx,helpme
go_print:	push	0		;offset exit

print:		push	@data
		pop	ds
		mov	ah,9
		int	21h
		lea	dx,crlf
		int	21h
		retn

not_mem:	lea	dx,insuf_mem
		jmp	go_print

err_open:	lea	dx,not_found
		jmp	go_print

start_code:	cld
		xor	dx,dx		;copyleft
		call	print
		lea	di,filename
		mov	[di],dh
		push	es cs ds
		pop	es ds
		mov	dl,crit_err_here
		mov	ax,2524h
		int	21h
		pop	ds
		mov	si,80h
		lodsb
		cbw
		xchg	cx,ax
		jcxz	get_help
		lea	bp,dos2win
		push	di
scan_cmdline:	lodsb
		cmp	al,' '
		jbe	next_scan
		cmp	al,'/'
		jne	scan_file
		lodsb
		dec	cx
		and	al,not ' '
		cmp	al,'D'
		jne	bad_switch
		lea	bp,win2dos
		jcxz	end_scan
		cmp	al,?
		org	$-1
scan_file:	stosb
next_scan:	loop	scan_cmdline
end_scan:	xchg	cx,ax
		stosb
		push	ds
		pop	es di
		cmp	al,[di]
		je	get_help
		lea	dx,process
		call	print
		mov	bx,@stack
		add	bx,10h
		mov	ah,4ah
		int	21h
		mov	bx,1000h
		mov	ah,48h
		int	21h		;alloc 64k 4 buffer
		jb	not_mem
		mov	es,ax
		mov	dx,di
		mov	ax,3d12h
		int	21h
		jb	err_open
		xchg	bx,ax
		push	ds es
		pop	ds es
next_read:	mov	cx,-1
		xor	dx,dx
		mov	ah,3fh
		int	21h
		jb	close_file
		or	ax,ax
		jz	close_file
		push	bx ax ax
		xchg	dx,ax
		neg	dx
		mov	ax,4201h
		int	21h
		pop	cx
		mov	bx,bp
		xor	si,si
next_xlat:	lodsb
		sub	al,80h
		jb	no_conv
		seges
		xlat
		mov	[si-1],al
no_conv:	loop	next_xlat
		mov	dx,cx
		pop	cx bx
		mov	ah,40h
		int	21h
		jb	close_file
		sub	ax,cx
		jnb	next_read
close_file:	pushf
		mov	ah,3eh
		int	21h
		popf
		lea	dx,ok_conv
		jnb	go_ok
		lea	dx,err_read
go_ok:		jmp	go_print		

crit_err_here	=	$-exit
		mov	al,3
		iret

		end	start_code
