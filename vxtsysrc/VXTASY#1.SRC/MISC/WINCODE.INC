; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; Make windows

makewindow proc near		 ; ax= window nr.
	pusha
	push es
	call hide_mouse

	lea si, windows

search_windows:
	cmp byte ptr [si], al
	je found_window

	cmp si, offset windows_end
	jae not_found

	push ax
	mov cx, 0fffeh
	mov di, si
	mov al, 0FFh
	repnz scasb
	mov si, di
	pop ax

	jmp search_windows

found_window:
	inc si
	lodsb
	mov w_x1, al
	lodsb
	mov w_y1, al
	lodsb
	mov w_x2, al
	lodsb
	mov w_y2, al
	lodsb
	mov bl, al
	lodsb
	mov wintitle_attr, al

	push es
	push si

	mov dl, w_x1
	mov dh, w_y1
	call pos_cursor
	mov al, w_head
	mov ah, 09h
	xor cx, cx
	mov cl, w_x2
	sub cl, w_x1
	add cx, 2
	mov bh, 0
	int 10h

	mov dl, w_x1
	mov dh, w_y1
	inc dh
	call pos_cursor
	mov al, w_l_u
	mov ah, 09h
	mov cx, 1
	int 10h
	inc dl
	call pos_cursor
	mov al, w_h_u
	xor cx, cx
	mov cl, w_x2
	sub cl, w_x1
	inc cx
	int 10h
	mov dl, w_x2
	inc dl
	call pos_cursor
	mov al, w_r_u
	mov cx, 1
	int 10h

	mov dl, w_x1
	mov dh, w_y2
	call pos_cursor
	mov al, w_l_d
	mov ah, 09h
	mov bh, 0
	mov cx, 1
	int 10h
	inc dl
	call pos_cursor
	mov ah, 09h
	mov al, w_h_d
	xor cx, cx
	mov cl, w_x2
	sub cl, w_x1
	int 10h
	mov dl, w_x2
	inc dl
	call pos_cursor
	mov cx, 1
	mov al, w_r_d
	int 10h

	xor cx, cx
	mov cl, w_y2
	sub cl, w_y1
	dec cx
	dec cx
	mov ah, 09h
	mov dl, w_x1
	mov dh, w_y1
	add dh, 2

_30:
	push cx
	mov cx, 1
	call pos_cursor
	mov al, w_v_l
	int 10h
	inc dl
	call pos_cursor
	mov al, ' '
	xor cx, cx
	mov cl, w_x2
	sub cl, w_x1
	int 10h
	mov cx, 1
	mov dl, w_x2
	add dl, 1
	call pos_cursor
	mov al, w_v_r
	int 10h
	mov dl, w_x1
	inc dh
	pop cx
	loop _30

	mov ax, 0b800h
	mov es, ax

	mov dh, w_x1
	mov dl, w_y2
	inc dl
	inc dh
	inc dh
	xor cx, cx
	mov cl, w_x2
	sub cl, w_x1

repeat_window_shadow1:
	push dx
	mov al, 8
	call computeaddress
	inc dx
	mov di, dx
	stosb
	pop dx
	inc dh
	loop repeat_window_shadow1

	mov dh, w_x2
	mov dl, w_y1
	inc dl
	inc dh
	inc dh
	xor cx, cx
	mov cl, w_y2
	sub cl, w_y1
	inc cx

repeat_window_shadow2:
	push dx
	mov al, 8
	call computeaddress
	inc dx
	mov di, dx
	stosb

	inc di
	stosb

	pop dx
	inc dl
	loop repeat_window_shadow2

	pop si
	pop es

	mov ax, 1225h
	int 2fh

	mov dx, cx
	shr dx, 1
	xor ax, ax
	mov al, w_x2
	sub al, w_x1
	shr ax, 1
	add al, w_x1
	sub ax, dx
	mov dh, al
	mov dl, w_y1
	mov bp, si
	mov ax, 1301h
	mov bl, wintitle_attr
	xchg dh, dl
	inc dl
	int 10h

	mov di, si
	mov al, 0
	repnz scasb
	mov si, di
	lodsb
	mov bl, al
	mov dl, w_x1
	mov dh, w_y1
	add dl, 3
	add dh, 3

repeat_window_text:
	mov ax, 1225h
	int 2fh
	mov bp, si
	mov ax, 1301h
	int 10h
	mov di, si
	mov al, 0
	repnz scasb
	mov si, di
	cmp byte ptr [si], 0FFh
	je over_display
	inc dh
	jmp repeat_window_text

over_display:

	clc
	jmp exit_windows

not_found:
	stc

exit_windows:
	call show_mouse
	pop es
	popa
	ret
makewindow endp

waitwindow proc near			; ax = how many buttons
	mov already_captioned, 0
	mov b_current, 1		;
	call makebutton 		; dx = position
	mov cs:keys[KESC], 0
	mov cs:keys[KTAB], 0
	Mov cs:keys[Kenter], 0

rep_xxx:
	cmp cs:[un_buton], 1
	je handle_button
	cmp cs:keys[KESC], 1
	je exit_cancel
	cmp cs:keys[KENTER], 1
	je enter_pressed
	cmp cs:keys[KKEYPADENTER], 1
	je enter_pressed
	cmp cs:keys[KTAB], 1
	jne rep_xxx
	mov cs:keys[KTAB], 0
	mov ax, b_current
	cmp ax, b_style
	jb ok_increase
	mov ax, 1
	jmp redraw

ok_increase:
	inc ax

redraw:
	mov b_current, ax
	mov ax, b_style
	mov dx, b_pos
	call makebutton
	jmp rep_xxx

enter_pressed:
	mov cs:keys[KENTER], 0
	mov cs:keys[KKEYPADENTER], 0
	mov ax, b_current
	cmp ax, 1
	je exit_ok
	cmp ax, 2
	je exit_cancel
	cmp ax, 3
	je exit_help

exit_cancel:
	mov cs:keys[KESC], 0
	stc
	ret

exit_ok:
	stc
	ret

exit_help:
	mov help_flag, 1
	ret

handle_button:
;	 mov cs:[un_buton], 0
	xor cx, cx
	xor dx, dx
	mov cl, coord_x
	mov dl, coord_y
	mov ax, b_pos
	cmp ah, dl
	jne not_same_column
	jmp same_column

not_same_column:
	mov already_captioned, 0
	mov cs:[un_buton], 0
	jmp rep_xxx

same_column:
	mov bx, 1

scan_button:
	cmp cl, al
	jb not_ok_scan_button
	add al, b_length
	dec al
	cmp cl, al
	jb ok_scan_button

	inc bx
	add al, 2
	jmp scan_button

ok_scan_button:
	mov ax, b_current
	cmp bx, ax
	je ok_finally
	mov ax, bx
;	mov cs:[un_buton], 0
	jmp redraw

ok_finally:
;	mov cs:[un_buton], 0
	cmp already_captioned, 1
	je _done_oh_god

rep_wait_but:
	cmp cs:[un_buton], 1
	je rep_wait_but
	mov already_captioned, 1
	jmp handle_button

_done_oh_god:
	cmp bx, 1
	je exit_ok
	cmp bx, 2
	je exit_cancel
	cmp bx, 3
	je exit_help

not_ok_scan_button:
	mov cs:[un_buton], 0
	mov already_captioned, 0
	jmp rep_xxx

	ret
waitwindow endp
