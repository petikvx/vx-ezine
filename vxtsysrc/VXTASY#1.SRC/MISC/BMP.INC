; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; Fade in a bmp file

.386
bmp_intro proc near
	push cs cs		       ; align segments
	pop ds es		       ;
				       ;
	mov ax, 3d02h		       ; open file
	lea dx, bmp_name	       ;
	int 21h 		       ;
	jc exit_intro		       ;
				       ;
	mov bmp_handle, ax	       ; save handle
				       ;
	mov ah, 3fh		       ; read headers
	mov bx, bmp_handle	       ;
	mov cx, HEADERS_LENGTH	       ;
	lea dx, bmp_buffer	       ;
	int 21h 		       ;
				       ;
	lea esi, bmp_buffer	       ; point header
				       ;
	cmp word ptr [esi.bfType], 'XV'; check Windows BMP sign
	jne close_file		       ;
				       ;
	mov eax, dword ptr [esi.bfOffBits]; get offset to data
	mov dword ptr data_offset, eax ;
				       ;
	add esi, SIZE BITMAPFILEHEADER ; skip file header
				       ;
	cmp dword ptr [esi.biCompression], 0;only non-compressed files!
	jne close_file		       ;
				       ;
	mov eax, dword ptr [esi.biWidth]; get X size
	mov x_size, eax 	       ;
				       ;
	mov eax, dword ptr [esi.biHeight]; get Y size
	mov y_size, eax 	       ;
				       ;
	mov eax, dword ptr [esi.biClrUsed]
	mov colors_used, eax	       ;
				       ;
	mov ax, word ptr [esi.biBitCount]; get color type
	mov colors, ax		       ;
				       ;
	cmp ax, 8		       ; be sure it's 8 bit!
	jne close_file		       ;
				       ;
	mov ah, 3fh		       ; read the palette
	mov bx, bmp_handle	       ;
	mov cx, 256*SIZE RGBQuad       ;
	lea dx, palette 	       ;
	int 21h 		       ;
				       ;
	lea si, palette 	       ;
	lea di, palette 	       ;
	add di, 3		       ;
	add si, 4		       ;
	mov cx, 256		       ;
				       ;
loop_move:			       ;
	movsb			       ;
	movsb			       ;
	movsb			       ;
	inc si			       ;
	loop loop_move		       ;
				       ;
	lea si, palette 	       ;
	mov di, si		       ;
	mov ah, 0		       ;
	mov cx, 256		       ;
				       ;
change: 			       ;
	push cx 		       ;
	xor dx, dx		       ;
	mov al, [si]		       ;
	xchg al, byte ptr [si+2]       ;
	mov [si], al		       ;
				       ;
	mov cx, 3		       ;
				       ;
mul_div:			       ;
	push cx 		       ;
				       ;
	lodsb			       ;
	mov cx, 63		       ;
	xor dx, dx		       ;
	mul cx			       ;
	xor dx, dx		       ;
	mov cx, 255		       ;
	div cx			       ;
	stosb			       ;
				       ;
	pop cx			       ;
	loop mul_div		       ;
				       ;
	pop cx			       ;
	loop change		       ;
				       ;
				       ;
	mov ah, 0		       ; switch to 320*200*8bit
	mov al, 13h		       ;
	int 10h 		       ;
				       ;
	call BlackOut		       ;
				       ;
	call read_hunk		       ; read a piece of file
				       ;
	mov ecx, y_size 	       ; start with first line
	mov counter, 0		       ; counter in file
	mov x_counter, 0	       ; counter on line
	mov y_counter, 0	       ; counter on column
				       ;
	mov ax, 0A000h		       ;
	mov es, ax		       ;
	mov di, 0		       ;
				       ;
repeat_line:			       ;
	push cx 		       ; save column counter
				       ;
	mov ecx, x_size 	       ; second loop for lines
				       ;
repeat_column:			       ;
	cmp counter, 1024	       ; did we reach the end of buffer?
	jb ok_for_now		       ;
				       ;
	call read_hunk		       ; if so, read more...
				       ;
ok_for_now:			       ;
	push cx 		       ; save counter
				       ;
	mov cx, 320		       ; and compute:
	xor dx, dx		       ;
	mov ax, 200		       ;
	sub ax, x_counter	       ;   320*(200-x_counter)+y_counter to
	mul cx			       ;
	add ax, y_counter	       ; obtain the memory address of the
	mov di, ax		       ; pixel
				       ;
	mov si, counter 	       ; get the byte from the file!
	mov al, byte ptr bmp_buffer[si];
				       ;
	inc counter		       ; increment the file counter
	mov byte ptr es:[di], al       ; and put it in the video memory
				       ;
	inc y_counter		       ; increment line counter
	pop cx			       ;
	loop repeat_column	       ;
				       ;
	pop cx			       ;
	inc x_counter		       ; increment column counter
	mov y_counter, 0	       ;
	loop repeat_line	       ;
				       ;
close_file:			       ;
	mov ah, 3eh		       ; close file
	mov bx, bmp_handle	       ;
	int 21h 		       ;
				       ;
	call _fadein		       ;
				       ;
_wait:				       ;
	mov ah, 01h		       ; wait for key...
	int 16h 		       ;
	jz _wait		       ;
	mov ah, 00h		       ;
	int 16h 		       ;
				       ;
	mov ah, 0		       ; restore text mode
	mov al, 3		       ;
	int 10h 		       ;
				       ;
exit_intro:			       ;
	ret			       ;
				       ;
read_hunk:			       ;
	pusha			       ; read from file
	mov ah, 3fh		       ;
	lea dx, bmp_buffer	       ;
	mov bx, bmp_handle	       ;
	mov cx, 1024d		       ;
	int 21h 		       ;
	popa			       ;
	mov counter, 0		       ;
	ret			       ;
				       ;
				       ;
_FadeIn PROC NEAR		       ; Fades screen to desired colors
    cli 			       ; Disable interrupts
    lea     bp,_Parray		       ; Load offset Palette array
    mov     cx,64d		       ; Set loopcounter
_loop64dX:			       ;
    xor     bx,bx		       ; Reset bx to 0
_Loop300hX:			       ;
    mov     dl,byte ptr cs:[bp]        ; Store original value in dl
    mov     dh,byte ptr cs:[bp+300h]   ; And fade-up value in dh
    cmp     dl,dh		       ; Compare them
    je	    _NextOne		       ; If they are equal then do the next one
    inc     byte ptr cs:[bp]	       ; Else increase with 1 (second layer)
_NextOne:			       ;
    inc     bp			       ; Point to next arraycel
    inc     bx			       ; Increase counter
    cmp     bx,300h		       ; Have we done all registers?
    jl	    _Loop300hX		       ;
    push    cx			       ; Save first loopcounter
    mov     cx,300h		       ; Do all R,G,B values
    call    WaitVerticalRetrace        ; Wait for a vertical retrace
    call    WaitVerticalRetrace        ; Twice
    call    WaitVerticalRetrace        ; Trice ;-)
				       ;
    mov     dx,03c8h		       ; Write register
    xor     al,al		       ; Start writing at color 0
    out     dx,al		       ; Give info to VGA
    mov     dx,03c9h		       ; Data register
    lea bp, _Parray		       ;
_WritemAll:			       ;
    mov     al,byte ptr cs:[bp]        ; Get the value (bp points to second palette)
    out     dx,al		       ; Write to VGA
    inc     bp			       ; Point to next cel
    loop    _WritemAll		       ; Loop while cx > 0
    sub     bp,300h		       ; Point to start palette again (reached the end)
    pop     cx			       ; Restore loopcounter from stack
    loop    _Loop64dX		       ; Have we done enough?
    sti 			       ; Enable interrupts
    ret 			       ; Return to main program
_FadeIn ENDP			       ;
				       ;
BITMAPFILEHEADER STRUC		       ;
		 bfType    DW ?        ;
		 bfSize    DD ?        ;
		 BfRez1    DW 0        ;
		 bfRez2    DW 0        ;
		 BfOffBits DD ?        ;
		 ENDS		       ;
				       ;
BITMAPINFOHEADER STRUC		       ;
		 biSize 	 DD ?  ;
		 biWidth	 DD ?  ;
		 biHeight	 DD ?  ;
		 biPlanes	 DW ?  ;
		 biBitCount	 DW ?  ;
		 biCompression	 DD ?  ;
		 biSizeImage	 DD ?  ;
		 biXPelsPerMeter DD ?  ;
		 BiYPelsPerMeter DD ?  ;
		 BiClrUsed	 DD ?  ;
		 BiClrImportant  DD ?  ;
		 ENDS		       ;

HEADERS_LENGTH EQU SIZE BITMAPFILEHEADER + SIZE BITMAPINFOHEADER

RGBQuad 	 STRUC		       ;
		 rgbBlue     DB ?      ;
		 rgbGreen    DB ?      ;
		 rgbRed      DB ?      ;
		 rgbReserved DB ?      ;
		 ENDS		       ;
				       ;
bmp_handle    dw 0		       ;
bmp_name      db "vxtasy.dat",0        ;
data_offset   dd 0		       ;
x_size	      dd 0		       ;
y_size	      dd 0		       ;
x_counter     dw 0		       ;
y_counter     dw 0		       ;
colors	      dw 0		       ;
colors_used   dd 0		       ;
				       ;
bmp_buffer    db 1024d dup (0)	       ;
_parray       db 300h dup (0)	       ;
palette       db 400h dup (0)	       ;
				       ;
bmp_intro endp			       ;
.286                                   ;