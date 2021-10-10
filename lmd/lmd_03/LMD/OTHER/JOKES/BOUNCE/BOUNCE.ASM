;(x) by Psychomancer aka Nice /SPS [2:454/5.9@fidonet]

; tasm /m bounce.asm
; tlink /t bounce.obj

.286
model tiny
codeseg
startupcode

		jmp	real_start
get_position:	mov	al,dh
		mul	byte ptr ds:[44ah]
		xor	dh,dh
		add	ax,dx
		shl	ax,1
		add	ax,ds:[44eh]
		xchg	ax,di
		retn
user_timer:	pusha
		push	ds es
		xor	bx,bx
		mov	ds,bx
		mov	al,18h
		cmp	bl,ds:[484h]
		je	cga_rows
		mov	al,ds:[484h]
cga_rows:	mov	cs:store_rows,al
		mov	al,ds:[449h]
		mov	cx,ds:[44eh]
		mov	dx,0b000h
		cmp	al,7
		je	video_text
		mov	dh,0b8h
		cmp	al,3
		jbe	video_text
		jmp	exit_bounce
video_text:	mov	es,dx
		mov	cx,ds:[44eh]
		cmp	al,7fh
store_mode	=	byte ptr $-1
		jne	first_call
		cmp	cx,7fffh
store_address	=	word ptr $-2
		je	was_bounce
first_call:	mov	cs:store_mode,al
		mov	cs:store_address,cx
		mov	al,ds:[44ah]
		dec	ax
		mov	cs:store_columns,al
		mov	ax,101h
		mov	cs:rows_columns,ax
		mov	cs:left_right,ax
		xchg	dx,ax
		jmp	beg_bounce
was_bounce:	mov	dx,507h
rows_columns	=	word ptr $-2
		push	dx
		call	get_position
		pop	dx
		mov	al,cs:store_char
		stosb
beg_bounce:	mov	cx,cs:left_right
		test	dh,dh
		jnz	no_zero_row
		neg	ch
no_zero_row:	cmp	dh,18h
store_rows	=	byte ptr $-1
		jne	no_last_row
		neg	ch
no_last_row:	test	dl,dl
		jnz	no_zero_column
		neg	cl
no_zero_column: cmp	dl,50h
store_columns	=	byte ptr $-1
		jne	no_last_column
		neg	cl
no_last_column: cmp	cx,100h
left_right	=	word ptr $-2
		jne	no_change_column
		mov	al,17h
store_char	=	byte ptr $-1
		and	al,7
		cmp	al,3
		jne	no_change_row
		neg	ch
no_change_row:	cmp	al,5
		jne	no_change_column
		neg	cl
no_change_column:
		add	dh,ch
		add	dl,cl
		cmp	cx,cs:left_right
		je	no_changed
		in	al,61h
		or	al,2
		and	al,0feh
		out	61h,al
no_changed:	mov	cs:left_right,cx
		mov	cs:rows_columns,dx
		call	get_position
		mov	al,7
		xchg	al,es:[di]
		mov	cs:store_char,al
		in	al,61h
		and	al,0fch
		out	61h,al
exit_bounce:	pop	es ds
		popa
		db	0eah
save1ch_off	=	word ptr $
save1ch_seg	=	word ptr $+2
copyright	db	'Bounce by Nice, SPS. Have fun!$'
real_start:	mov	dx,offset copyright
		mov	ah,9
		int	21h
		mov	ax,351ch
		int	21h
		mov	save1ch_off,bx
		mov	save1ch_seg,es
		mov	dx,offset user_timer
		mov	ah,25h
		int	21h
		mov	es,ds:[2ch]
		mov	ah,49h
		int	21h
		mov	dx,offset copyright+4
		int	27h

		end

