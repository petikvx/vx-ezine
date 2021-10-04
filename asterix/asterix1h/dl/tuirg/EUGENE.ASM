                .model  tiny
                .code
		org	100h

start:
		push	ax                      ; push 0a000h
 		push	bp                      ; = vga display segment
		mov	bp,sp                   ;
		mov	word ptr [bp+2],0A000h  ;
 		pop	bp                      ;

 		pop	es
 		push	es
		pop	ds
		mov	al,13h                  ; Set Video display in al
		int	10h			; (320x200x256)

		mov	dx,3C8h                 ; Port 3C8h, VGA pel adress
		xor	ax,ax			; ax = 0
		out	dx,al
		inc	dx
		mov	ch,1
 		mov	bl,15h                  ; 256/(4*3) = color = gray
dac:   		out	dx,al			; port 3C9h, VGA pel data reg
		add	bh,bl
		adc	al,ah
		loop	dac

main:   	mov	si,320
 		mov	ch,7Dh
		push	si
		push	cx
 		xor	bx,bx                   ; get rave-effects w/o this line

disp:      	lodsb				; String [si] to al
		mov	bl,[si]
		add	ax,bx
		mov	bl,ds:[si+100]
		add	ax,bx
		mov	bl,[si-2]
		add	ax,bx
		shr	ax,1			; Shift w/zeros fill
		shr	ax,1
		mov	ds:[si-102],al
		loop	disp

 		pop	di                      ; recycle
		pop	cx

rnd:
		mul	word ptr [di]		; ax = data * ax (rnd_numba)
		inc	ax
		stosw				; Store ax to es:[di]
		dec	di
		loop	rnd

		mov	ah,1                    ; if key pressed = exit
		int	16h

		jz	main
		mov	ax,3
		int	10h			; set back video-display
						; (and clear screen) and
		ret                             ; exit

		end	start

