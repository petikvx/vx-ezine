;
;Example program -compresses file 'huffman.asm' in current directory into
;test.huff without tree and decompresses it in test.unhuff
;

include asm\huffman.ash
include 1.inc

includelib import32.lib

	.586p
	.model flat
	.data

path	db "huffman.asm",0
hpath	db "huffman.huff",0
hpath2	db "huffman.unhuff",0

	.data?
treex   db 513*(SIZE tree_node) dup (?)
	.code

		
_start:
;		int 3

		mov edx,offset path
		call fopen
		
		xchg eax,ebx

		call fsize
		xchg eax,ecx

		call getmem
		push eax

		xchg edx,eax				;inbufer

		call fread				;fill bufer
		call fclose

		call getmem				;output bufer
		push eax

		xchg edi,eax				;outbufer


;dword huffman_init(const byte* in_buf,struct tree_node *out_buf,dword size)

		push ecx
		push offset treex
		push edx
		call huffman_init
		add esp,3*4

;dword huffman_compress(struct tree_node *htable,byte* hin,byte* hout,dword index,dword size)

		xchg eax,esi				;esi-index

		push ecx                                ;size
		push esi				;index
		push edi				;out
		push edx
		push offset treex
		call huffman_compress
		add esp,4*5

;----------------------------------------------------------------------------

		push eax				;size
		push edx				;bufer

		shr eax,3
		inc eax
		xchg ecx,eax				;ecx=byte size

		mov edx,offset hpath
		call fcreate
		
		xchg eax,ebx

		mov edx,edi
		call fwrite

		call fclose

		pop edx					;now it's out buf
		pop ecx					;size in bits


		push ecx
		push esi
		push edx
		push edi
		push offset treex

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov edi,edx                 ;;
		mov ecx,1000                ;;
		mov eax,0                   ;;
		rep stosb                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		call huffman_decompress
		add esp,4*5

;dword huffman_decompress(struct tree_node *tree,byte* hin,byte* hout,dword index,dword size)
		;eax=size
		xchg eax,ecx

		push edx

		mov edx,offset hpath2
		call fcreate

		pop edx
		
		xchg eax,ebx

		;edx=bufer,ecx=size,ebx=handle
		call fwrite

		call fclose

		pop eax
		call freemem

		pop eax
		call freemem
	
	        push    0
	        xcall ExitProcess

include asm\huffman.inc

include io.inc
include system.inc



end	_start
