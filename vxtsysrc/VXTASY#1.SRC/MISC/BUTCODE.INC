; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; Create buttons

makebutton proc near  ; dx = row/col ; ax = style
	pusha

	xor bx, bx

	call hide_mouse
	mov b_style, ax
	mov b_pos, dx

	mov cx, ax
	dec cx
	cmp cx, 0
	je no_fix_up

arrange_loop:
	add dl, b_length
	inc dl
	loop arrange_loop

no_fix_up:
	xor cx, cx
	mov cl, b_length
	dec cx

	cmp ax, 3
	ja no_button_to_do
	jne maybe_2

	cmp ax, b_current
	jne no_crt_1
	mov bl, b_sele_attr
	jmp draw_button_1

no_crt_1:
	mov bl, b_norm_attr

draw_button_1:
	lea bp, b_help
	call print_string
	push dx ax
	add dl, b_length
	dec dl
	call pos_cursor
	mov al, 'Ü'
	mov bl, b_shad_attr
	call put_char
	sub dl, b_length
	add dl, 2
	inc dh
	lea bp, b_shadow
	call print_string
	pop ax dx
	sub dl, b_length
	dec dl
	dec ax

maybe_2:
	cmp ax, 2
	jne maybe_1
	cmp ax, b_current
	jne no_crt_2
	mov bl, b_sele_attr
	jmp draw_button_2

no_crt_2:
	mov bl, b_norm_attr

draw_button_2:


	lea bp, b_cancel
	call print_string
	push dx ax
	add dl, b_length
	dec dl
	call pos_cursor
	mov al, 'Ü'
	mov bl, b_shad_attr
	call put_char
	sub dl, b_length
	add dl, 2
	inc dh
	lea bp, b_shadow
	call print_string
	pop ax dx
	sub dl, b_length
	dec dl
	dec ax

maybe_1:
	cmp ax, 1
	jne no_button_to_do
	cmp ax, b_current
	jne no_crt_3
	mov bl, b_sele_attr
	jmp draw_button_3

no_crt_3:
	mov bl, b_norm_attr

draw_button_3:

	lea bp, b_ok
	call print_string
	push dx ax
	add dl, b_length
	dec dl
	call pos_cursor
	mov al, 'Ü'
	mov bl, b_shad_attr
	call put_char
	sub dl, b_length
	add dl, 2
	inc dh
	lea bp, b_shadow
	call print_string
	pop ax dx

no_button_to_do:
	call show_mouse
	popa
	ret
makebutton endp
