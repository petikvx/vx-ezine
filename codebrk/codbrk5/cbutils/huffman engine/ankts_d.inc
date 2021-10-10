; ANKTS_D.INC  -  Huffman Decompression in 32bit ASSEMBLY 
; Ver 1.00
;
; ANAkTOS (c)1999 
; Europe/Greece 
;------------------------------------------------------
;
; Size: 79 bytes


ad_sourcedata		equ	 24h+ 0
ad_destinationdata	equ	 24h+ 4

anaktos_decompress:
	pushad 

	mov ebp,esp

	;load input into regs
	cld
	mov esi,[ebp+ad_destinationdata] ;load  source
	mov edx,esi
	mov edi,[ebp+ad_sourcedata] ;load destination

	lodsw		;mark
	cmp ax,'AC'	
	jnz ad_end

	lodsd		;size
	mov ecx,eax 
	lodsd 		;skip the bitstreamsize
	lodsd		;offset off bitstream	
	add edx,eax

	xor ebx,ebx
	
ad_loop:
	push esi
ad_innerloop:
	lodsb
	cmp al,0FEh
	jz ad_is_FE
	jc ad_is_char
	bt [edx],ebx
	inc ebx
	jnc ad_innerloop
	call ad_dive
	jmp ad_innerloop
ad_is_FE:	
	lodsb
ad_is_char:
	stosb
	pop esi
	loop ad_loop
ad_end:
	popad
	ret 8
		

ad_dive:	
	lodsb
	cmp al,0FEh
	jz ad_dive_is_FE
	jc ad_dive_is_char
	call ad_dive
	call ad_dive
	ret	
ad_dive_is_FE:
	lodsb
ad_dive_is_char:
	ret	