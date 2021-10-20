; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; DICS pixel by pixel mouse handler + SAR specific code

init_mouse:
check_for_mouse:

	mov byte ptr cs:[stop],1	;driverul este dezactivat !!
	xor ax,ax
	int 33h
	or ax,ax
	jnz mouse_found

	mov mouse, 0
	stc
	retn

mouse_found:
	mov mouse, 1
	push es
	push ds
	xor ax,ax
	mov ds,ax
;	 mov es,word ptr cs:[data1_seg]
	mov al,byte ptr ds:[449h]
	mov es:store_vidmode_bios,al
	mov byte ptr ds:[449h],6
	xor ax,ax
	int 33h
	mov al,es:store_vidmode_bios
	mov byte ptr ds:[449h],al
	pop ds
	pop es

	mov ax,7
	mov cx,0
	mov dx,638
	int 33h

	mov ax,8
	mov cx, 32
	mov dx,398
	int 33h

	mov ax,4
	mov cx, 0
	mov dx, 2*8
	int 33h

	mov ax,0ch
	mov cx,1fh	;toate apasarile si ridicarile + miscare !!!
	push es
	push cs
	pop es
	mov dx,offset event_handler
	int 33h
	pop es

	mov byte ptr cs:[stop],0
	clc
	retn

deinit_mouse:
	push ds
	mov ds,word ptr cS:data1_seg
	cmp byte ptr ds:[mouse],0
	pop ds
	je rrrtt
	mov ax,0ch
	mov cx,0
	push es
	push cs
	pop es
	mov dx,offset event_handler
	int 33h
	pop es
rrrtt:	retn

;================================================================
;in ax vine urmatoarea structura:
;bit 0 - butonul din stanga apasat  ; bit 1 - butonul din stanga lasat liber
;bit 2 - butonul din dreapta apasat ; bit 3 - butonul din dreapta lasat liber
;||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;--------------------
hided		db 0	;este 1 cand mouse-ul este ascuns
stop		db 0	;cand este 1 driverul nu functioneaza
			;(setat pe 1 de hide_mouse !!)
something_new	db 0	;cand se misca mouse-ul se pune pe 1
un_buton	db 0	;cand se apasa orice buton se pune pe 1
coord_x 	db 0
coord_y 	db 0
initial_ax	dw 0
initial_bx	dw 0
initial_cx	dw 0
initial_dx	dw 0

;--------------------
event_handler:
	mov cs:initial_ax, ax
	mov cs:initial_bx, bx
	mov cs:initial_cx, cx
	mov cs:initial_dx, dx

	cmp ax,1
	jne __butoane
__butoane:
	cmp byte ptr cs:[stop],1
	jne mai_departe_cu_spor
	jmp da__afara
mai_departe_cu_spor:
	mov byte ptr cs:[something_new],1
	mov ds,word ptr cs:data1_seg
	mov es,word ptr cs:data1_seg
	cmp ax,1
	je miscare
	jmp butoane
;-----------------------------------------
miscare:
;	mov byte ptr cs:[un_buton],0
;	!!!!!!!!!!!! Trebuie sa scot AX de pe Stiva

	mov ds:save_cx,cx
	mov ds:save_dx,dx
	push ax
;	call print_those
	push dx
	push cx
	xor al,al
	mov flag,al
	mov flag2,al
	mov ax,word ptr mouse_orizontal
	shr cx,3
	cmp cl,al
	je skip_1
	mov byte ptr flag,1
skip_1: shr dx,4
	cmp dl,ah
	je skip_2
	mov byte ptr flag,1
skip_2: mov word ptr mouse_orizontal,ax
	pop cx
;-----------------------------------------
	and cx,7
	mov si,offset cursor_original
	mov di,offset punere_curenta
;	clc
REPT 32 		;cursorul
	lodsw
	ror ax,cl
	stosw
ENDM
	stc
REPT 32 		;si masca
	lodsw
	rcr ax,cl
	stosw
ENDM
;------------------------------------------
	pop cx
	and cx,0fh
	pushf		;pentru a pastra direction flag
	push cx
	shl cx,1	;cx*2
	mov si,offset punere_curenta+30
	mov di,si
	add di,cx
	mov cx,16
	std
	rep movsw
	pop cx
	push cx
	xor ax,ax
	rep stosw
	pop cx
	push cx
	shl cx,1
	mov si,offset punere_curenta+94
	mov di,si
	add di,cx
	mov cx,16
	rep movsw
	pop cx
	mov ax,-1
	rep stosw
	popf
;-------------------------------------------------------
aa:	pop ax
	mov bx,ds:save_dx
	shr bx,4
	mov cs:coord_y,bl
	shl bx,1
	mov bx,ds:[bx+offset tabela]
	mov ax,ds:save_cx
	shr ax,3
	mov cs:coord_x,al
	cmp al,79
	jb merge_1
	inc byte ptr ds:flag2
merge_1:
	shl ax,1
	add bx,ax
;_____________________________________________________________
;-------------------------------------------------------------
;	Aici am calculat adresa exacta a cursorului
;si urmeaza sa stocam la loc vechile caractere
	push bx
	mov ds,word ptr cs:video_seg
	mov bx,es:adresa
	mov ax,es:[sus]
	mov byte ptr ds:[bx],al
	mov byte ptr ds:[bx+2],ah
	mov ax,es:[jos]
	mov byte ptr ds:[bx+160],al
	mov byte ptr ds:[bx+162],ah
	pop bx
	mov es:adresa,bx
;___________________________________________________________
;-----------------------------------------------------------
;	Aici am repus vechile caractere
	mov al,byte ptr ds:[bx]
	mov byte ptr ds:[bx],0c6h
	mov ah,byte ptr ds:[bx+2]
	cmp byte ptr es:[flag2],0
	jne sari_peste_1
	mov byte ptr ds:[bx+2],0c7h
sari_peste_1:
	mov es:[sus],ax
	mov al,byte ptr ds:[bx+160]
	mov byte ptr ds:[bx+160],0c8h
	mov ah,byte ptr ds:[bx+162]
	cmp byte ptr es:[flag2],0
	jne sari_peste_2
	mov byte ptr ds:[bx+162],0c9h
sari_peste_2:
	mov es:[jos],ax
	call set_chars
	jmp da__afara
;_________________________________________________
;-------------------------------------------------
set_chars:
	Mov  dx,03c4h
	Mov  ax,0402h
	Out  dx,ax	;CPU writes only to map 2
	Mov  ax,0704h
	Out  dx,ax	;seqvential addressing
	Mov  dx,03ceh
	Mov  ax,0204h	;map 2 for CPU reads
	Out  dx,ax
	Mov  ax,0005h	;disable odd even addressing
	Out  dx,ax
	Mov  ax,0406h	;Map starts at A000:0000 (64 Kb mode---0AFFFh)
	Out  dx,ax
;----------------------------------------------------------------------
	push ds
	push es
	mov ds,word ptr cs:[data1_seg]
	mov ax,0a000h
	mov es,ax
;-----------------
	mov si,offset custfont
	xor ax,ax
	mov al,byte ptr ds:[sus]
	shl ax,4
	add si,ax
	mov di,6336
	mov bx,offset punere_curenta
	call set_them

	mov si,offset custfont
	xor ax,ax
	mov al,byte ptr ds:[sus+1]
	shl ax,4
	add si,ax
	mov di,6368
	mov bx,offset punere_curenta+1
	call set_them

	mov si,offset custfont
	xor ax,ax
	mov al,byte ptr ds:[jos]
	shl ax,4
	add si,ax
	mov di,6400
	mov bx,offset punere_curenta+32
	call set_them

	mov si,offset custfont
	xor ax,ax
	mov al,byte ptr ds:[jos+1]
	shl ax,4
	add si,ax
	mov di,6432
	mov bx,offset punere_curenta+33
	call set_them

	pop es
	pop ds
;----------------------------------------------------------------------
	Mov  dx,03c4h
	Mov  ax,0302h
	Out  dx,ax	;CPU writes to map 0, 1
	Mov  ax,0304h
	Out  dx,ax	;odd-even addressing
	Mov  dx,03ceh
	Mov  ax,0004h
	Out  dx,ax	;select map 0 for CPU reads
	Mov  ax,1005h
	Out  dx,ax	;enable odd even addressing
	Mov  ax,0e06h
	Out  dx,ax	;Map starts at B800:0000h (color text modes)
	Retn
;___________________________________________________________________
;-------------------------------------------------------------------
Set_them:
REPT 16
	lodsb
	and al,byte ptr ds:[bx+64]
	or al,byte ptr ds:[bx]
	stosb
	add bx,2
ENDM
	retn
;------------------------------------------
hide_mouse:
	cmp byte ptr cs:[hided],1
	je gata_223
	mov byte ptr cs:[stop],1
	push ds
	push es
	push bx
	push ax
	mov ds,word ptr cs:video_seg
	mov es,word ptr cs:data1_seg
	cmp byte ptr es:[mouse],0
	je gata_22
	mov byte ptr cS:[hided],1
	mov bx,es:adresa
	mov ax,es:[sus]
	mov byte ptr ds:[bx],al
	mov byte ptr ds:[bx+2],ah
	mov ax,es:[jos]
	mov byte ptr ds:[bx+160],al
	mov byte ptr ds:[bx+162],ah
gata_22:
	pop ax
	pop bx
	pop es
	pop ds
gata_223:
	retn
;------------------------------------------
show_mouse:
	mov byte ptr cs:[stop],1
	push ds
	push es
	pusha
	mov ds,word ptr cs:[data1_seg]
	cmp byte ptr ds:[mouse],0
	je gata_33			;daca nu exista mouse iesim afara

	mov byte ptr ds:[flag2],0
	mov bx,ds:save_dx
	shr bx,4
	shl bx,1
	mov bx,ds:[bx+offset tabela]
	mov ax,ds:save_cx
	shr ax,3
	cmp al,79
	jb merge_11
	inc byte ptr ds:flag2
merge_11:
	shl ax,1
	add bx,ax
;--------------------
	push ds
	pop es
	mov ds,word ptr cs:[video_seg]
	mov al,byte ptr ds:[bx]
	mov byte ptr ds:[bx],0c6h
	mov ah,byte ptr ds:[bx+2]
	cmp byte ptr es:[flag2],0
	jne sari_peste_11
	mov byte ptr ds:[bx+2],0c7h
sari_peste_11:
	mov es:[sus],ax
	mov al,byte ptr ds:[bx+160]
	mov byte ptr ds:[bx+160],0c8h
	mov ah,byte ptr ds:[bx+162]
	cmp byte ptr es:[flag2],0
	jne sari_peste_21
	mov byte ptr ds:[bx+162],0c9h
sari_peste_21:
	mov es:[jos],ax
	call set_chars
gata_33:
	popa
	pop es
	pop ds
	mov byte ptr cs:[hided],0
	mov byte ptr cs:[stop],0

	retn
;___________________________________________________________
;-----------------------------------------------------------
butoane:
	test ax,2
	jz alte
	mov byte ptr cs:[un_buton],1
	jmp short da__afara
alte:	test ax,8
	jz poate_released
	mov byte ptr cs:[un_buton],1
da__afara:
	jmp mouse_handler

poate_released:
	test ax,4
	jz poate_right_released
zzaxx:	mov byte ptr cs:[un_buton],0
	jmp short da__afara
poate_right_released:
	test ax,10h
	jnz zzaxx
	jmp mouse_handler


mouse_handler:
	cmp byte ptr cs:[stop], 1
	je exit_for_all

	cmp disable, 1
	je exit_for_all

	mov ax, data_segment
	mov ds, ax
	mov es, ax

	mov ax, cs:initial_ax
	mov bx, cs:initial_bx
	mov cx, cs:initial_cx
	mov dx, cs:initial_dx

	cmp in_gfc, 1
	je handle_gfc

	cmp disable, 1
	je exit_for_all

	cmp ax, 1
	jne buttons

;	 shr cx, 3
;	 shr dx, 3

	mov was_in_buttons, 0
	xor cx, cx
	xor dx, dx
	mov cl, coord_x
	mov dl, coord_y

	mov mouse_oriz, cx
	mov mouse_vert, dx

	mov pressed_like_enter, 0

	cmp dl, menu_bar_row
	jne no_col_found

	mov dx, cx

	mov cx, max_menu_item
	mov bx, 1
	lea si, menu_bar_xcoord

repeat_compare_xcoord:
	lodsw
	mov left_coord, ax
	lodsw
	mov right_coord, ax

	cmp dx, left_coord
	ja maybe_this_col
	jmp no_this_one

maybe_this_col:
	cmp dx, right_coord
	jb sure_this_col

no_this_one:
	inc bx
	loop repeat_compare_xcoord
	jmp no_col_found

sure_this_col:
	cmp current_popup, bx
	je no_movement

	mov current_popup, bx
	mov actualizate, 1
	mov onlyactualize, 0

     pusha
     lea di, pop_pos			;
     mov cx, current_popup		;
     shl cx, 1				;
     add di, cx 			;
     dec di				;
     dec di				;
     mov ax, word ptr [di]		;
     mov current_popit, ax		;
     popa

     mov ax, true
     mov showpopup, ax
     jmp no_movement

no_col_found:

; try for popup:
	cmp showpopup, 0
	je no_movement

	mov actualizate, 0

	mov cx, mouse_oriz
	mov dx, mouse_vert

	lea si, popup_coords
	mov cx, popup_height
	mov bx, 1

repeat_compare_xcoord2:
	push cx
	lodsw
	cmp ax, dx
	jne no_rite_row

	lodsw
	mov left_coord, ax
	lodsw
	mov right_coord, ax

	mov cx, mouse_oriz

	cmp cx, left_coord
	jae maybe_this_col2
	jmp no_this_one2

maybe_this_col2:
	cmp cx, right_coord
	jbe sure_this_col2


no_rite_row:
	lodsw
	lodsw
	inc bx

no_this_one2:
	pop cx
	loop repeat_compare_xcoord2
	jmp no_movement

sure_this_col2:
	pop cx
	mov ax, current_popit
	cmp ax, bx
	je no_movement
	mov current_popit, bx
	mov actualizate, 1
	mov onlyactualize, 1

no_movement:
	retf

buttons:
	cmp was_in_buttons, 1
	je exit_for_all
	or ax, 02h
	cmp ax, 02h
	jne exit_for_all

	mov pressed_like_enter, 0
	mov actualizate, 0

	cmp no_popup, 1
	je already_correct

	mov cx, mouse_oriz
	mov dx, mouse_vert

	lea si, popup_coords
	mov cx, popup_height
	mov bx, 1

repeat_compare_xcoord3:
	push cx
	lodsw
	cmp ax, dx
	jne no_rite_row3

	lodsw
	mov left_coord, ax
	lodsw
	mov right_coord, ax

	mov cx, mouse_oriz

	cmp cx, left_coord
	jae maybe_this_col3
	jmp no_this_one3

maybe_this_col3:
	cmp cx, right_coord
	jbe sure_this_col3


no_rite_row3:
	lodsw
	lodsw
	inc bx

no_this_one3:
	pop cx
	loop repeat_compare_xcoord3
	mov pressed_like_esc, 1
	jmp no_movement

sure_this_col3:
	pop cx

already_correct:
	mov pressed_like_enter, 1

exit_for_all:
	retf

handle_gfc:
	xor cx, cx
	xor dx, dx
	mov cl, coord_x
	mov dl, coord_y

	mov mouse_oriz, cx
	mov mouse_vert, dx
	retf


