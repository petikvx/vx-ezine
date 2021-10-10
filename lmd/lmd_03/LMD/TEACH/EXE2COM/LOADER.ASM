comment ■

Loader.Asm, Exe2Com - Загрузчик.

Внимание! Размер должен быть кратен параграфу (10h)!

Текущая длина 128 байт. При изменении длины необходимо
откорректировать константу l_len в основном модуле Exe2Com.Asm

//Scout [SPS] ■

include 	exe_head.inc

		model	tiny
		.code
		org	100h
		jumps

start:		mov	bx,cs
		add	bx,10h
		mov	bp,bx
		add	bp,(old_file-start) shr 4
		mov	si,offset old_file
		add	bp,[si.hdr_size]
		mov	ax,[si.exe_sp]
		push	ax
		mov	cl,4
		shr	ax,cl
		add	ax,[si.relo_ss]
		add	ax,bx
		cmp	ax,ds:[0002h]
		jb	chk_relo
		int	20h
chk_relo:	mov	cx,[si.relo_cnt]
		jcxz	no_relo
		push	si cs
		add	si,[si.tabl_off]
next_relo:	lodsw
		xchg	ax,di
		lodsw
		add	ax,bp
		mov	es,ax
		add	es:[di],bx
		loop	next_relo
		pop	es si
no_relo:	mov	dx,bx
		add	dx,[si.relo_cs]
		push	ds ds bx
		add	bx,[si.relo_ss]
		push	bx
		mov	di,offset start-2*tranzit_len
		push	di
		mov	ax,[si.page_cnt]
		mov	cl,8
		shl	ax,cl
		mov	bx,[si.hdr_size]
		mov	cl,3
		shl	bx,cl
		sub	ax,bx
		mov	bx,[si.exe_ip]
		mov	cl,tranzit_len
		mov	si,offset tranzit
		rep	movsw
		xchg	cx,ax
		mov	ds,bp
		xor	si,si
		xor	di,di
		retn
tranzit:	pop	ax es
		rep	movsw
		pop	es ds
		cli
		pop	sp
		mov	ss,ax
		sti
		push	dx
		push	bx
		retf
		db	'SPS'
tranzit_len	=	($-tranzit+1)/2
old_file:
		end	start
