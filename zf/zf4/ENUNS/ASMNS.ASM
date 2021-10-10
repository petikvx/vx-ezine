; tiny proggie to insert simple code into dictionary
; as a page. it is not a virus itself, though, there can be created 
; a stamm implementing this idea. so, get aware of it.
;
; (c) Sassa, Apiary Ink
; Dec 2000
; for ZF-4 exclusive
;

.8086
.model	tiny
.code
.startup

	mov	dx,offset help
	mov	si,81h
	mov	di,si
loop1:
	lodsb
	cmp	al,0
	jz	o_loop1

	cmp	al,20h
	jz	loop1

	cmp	al,'-'
	jnz	l1

	or	tear,1
	jmp	short loop1
l1:
	stosb
	cmp	al,0dh
	jnz	loop1

	dec	di
	mov	[di],ah			; [DI] = 0
o_loop1:
	cmp	di,81h
	jz	_msg

	call	check_ns

	mov	dx,offset cannot_update
	jc	_msg

	cmp	tear,0
	jz	sew

	call	tear_page
	mov	dx,offset _could_not_tear
	jc	_msg
	jmp	short __ok
sew:
	call	write_file

__ok:
	mov	dx,offset _ok
_msg:
	mov	ah,9
	int	21h
	ret

check_ns proc
	mov	ax,3d02h
	mov	dx,81h
	int	21h

	jc	c_ret
	xchg	ax,bx

	mov	ax,4202h
	mov	dx,-4
	mov	cx,-1
	int	21h

	mov	ah,3fh
	mov	dx,offset ns
	mov	cx,4
	int	21h

	mov	ah,3eh
	int	21h

	cmp	word ptr ns, 'SN'
	jz	c_ret			; NC

	stc
c_ret:
	ret
check_ns endp

write_file proc
	mov	ax,3d02h
	mov	dx,81h
	int	21h

	xchg	ax,bx

	mov	dx,offset old_bytes	; read the head of COM-file
	mov	cx,3
	mov	ah,3fh
	int	21h

	mov	dx,back_pointer		; position pointer to read the Dictionary
	neg	dx
	mov	cx,-1
	mov	ax,4202h
	int	21h

	push	dx
	push	ax

	add	ax,offset entry_point-offset new_ns-3
	mov	word ptr new_head+1,ax

	add	ax,3+offset end_piece-offset entry_point
	and	ax,0fh			; align to paragraph
	sub	al,10h
	neg	al

	xchg	ax,si			; SI==number of aligning bytes

					; read the whole dictionary
	mov	cx,sp			; my code is shorter, than
	sub	cx,offset buf+16	; dictionary loader, so the dictionary
	lea	dx,[si+offset buf]	; cannot be longer, than that
	mov	ah,3fh
	int	21h

	pop	dx
	pop	cx			; though, CX==0 always
	push	ax

	mov	ax,4200h		; position to the start of the Dictionary
	int	21h

					; i would better write the whole lot,
				; but i hope it won't fail between
				; the writes
	lea	cx,[si+offset end_piece-new_ns]
	add	cx,back_pointer
	pop	bp			; bytes read

	mov	[bp+si+offset buf-2],cx	; correct NS signature

	mov	dx,offset new_ns	; write the first page: ASM language
	mov	ah,40h
	int	21h

	xor	cx,cx
	cwd
	mov	ax,4200h
	int	21h

	mov	dx,offset new_head
	mov	cl,3
	mov	ah,40h
	int	21h

	mov	ah,3eh
	int	21h

	ret
write_file endp

tear_page proc
	mov	ax,3d02h
	mov	dx,81h
	int	21h

	xchg	ax,bx
	mov	dx,offset tear_buf
	mov	cx,sp
	sub	cx,offset tear_buf+16
	mov	ah,3fh
	int	21h

	push	ax
	mov	ah,3eh
	int	21h

	pop	di
	mov	len,di			; length of file read
	add	di,dx			; DX => tear_buf

	lea	bx,[di-2]

	sub	di,[bx]
	mov	si,di
	add	si,[di]
	sub	si,dx
	add	si,0fh
	and	si,0fff0h
	add	si,dx

	mov	ax,[di+8]
	mov	cl,[di+7]
	xchg	word ptr tear_buf+1,ax	; restoring old bytes at the beg of COM
	xchg	tear_buf,cl

	add	[bx],di			; correcting tail signature
	sub	[bx],si			; of this NS-directory

	add	len,di			; updating length of file
	sub	len,si

	cmp	[di+4],'SA'
	jnz	_tp_e

	cmp	byte ptr [di+6],'M'
	jnz	_tp_e

	cmp	cl,0e9h	
	jnz	_tp_e

	mov	cx,sp
	sub	cx,si

	add	ax,dx
	add	ax,3

	cmp	ax,di			; JMP near should hit _somewhere_
	jbe	_tp_e			; between the start of the page
					; and end of it
	cmp	ax,si
	jae	_tp_e

rep	movsb				; move the dictionary up

	push	dx
	mov	dx,81h
	mov	cx,20h
	mov	ax,3c00h
	int	21h
	pop	dx
	jc	_tp_e

	xchg	ax,bx
	mov	cx,len
	mov	ah,40h
	int	21h

	mov	ah,3eh
	int	21h

	ret
_tp_e:
	stc
	ret
tear_page endp

_could_not_tear db 'Could not tear a page: not ASM-page or file-access error$'
_ok	db	'OK$'

len	dw	0

new_head db	0e9h,0,0

ns	db	0, 0
back_pointer dw	0

new_ns	dw	offset end_piece-new_ns
	dw	0			; should it be equal with new_ns?
	db	'ASM'			; my mother tongue ;-)
old_bytes dd	0
	db	'NSZF',0

tear_buf label	byte

greet	db	'East or West ASM is Best',0dh,0ah, '$'

entry_point:
	push	ax
	push	dx
	call	_next
_next:
	pop	bx

	lea	dx,[bx+offset greet-offset _next]
	mov	ah,9
	int	21h

	mov	ax,[bx+offset old_bytes-offset _next]
	mov	dx,[bx+offset old_bytes-offset _next+2]

	mov	bx,100h
	mov	[bx],ax
	mov	[bx+2],dl

	pop	dx
	pop	ax
	push	bx

	mov	bx,ax
	ret
end_piece:
buf:

tear	db	0
help	db	'Program for inserting NS-page into COM-file with dictionary',0dh,0ah
	db	'usage: asmns.com [-] <file-name>',0dh,0ah,'	- - tear the first ASM page from it$'
cannot_update db 'Cannot update this file: is not NS-COM, or file-access error$'

	db	'NS'			; allow insert the page into 
	dw	4			; this executable

	end

