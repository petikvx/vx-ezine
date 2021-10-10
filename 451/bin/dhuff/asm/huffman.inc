; Dynamic Huffman compress/decompress library
; 
; (c) 451 2002

DEBUG=0


 SIGN1 	  	 equ	<'[S1]'>
 SIGN2  	 equ	<'[S2]'>

 SIGN11	  	 equ	<'[S11'>
 SIGN22	 	 equ	<'[S22'>

 SIGN111	 equ 	<'S111'>
 SIGN222	 equ 	<'S222'>

;//////////////////////////////////////////////////////////////////////////////
;Init
;//////////////////////////////////////////////////////////////////////////////
;
;dword huffman_init(const byte* in_buf,struct tree_node *htree,dword size)

ifdef DEBUG 
		db  SIGN1
endif

huff_i_inbuf	equ	[ebp+8*4]+4
huff_i_outbuf	equ	[ebp+8*4]+8
huff_i_size	equ	[ebp+8*4]+12

huff_i_stat	equ	[ebp-256*(SIZE tree_sorted)]
huffman_init:

		pusha
		mov ebp,esp
		mov ecx,256*(SIZE tree_sorted)		;size
		sub esp,ecx				;bufer

		lea edi,huff_i_stat                     ;stat
		xor eax,eax				;clear buf
		                                        ;
		push edi				;
		rep stosb                               ;
		pop edx					;edx=stat bufer

;fill stat table
		mov eax,edx
		xor ecx,ecx
@make_0_255:
		mov [eax.sorted_sym],cx
		add eax,SIZE tree_sorted
		
		inc ecx
		cmp cx,256
		jne @make_0_255

		push ecx				;ecx=256

		mov ecx,huff_i_size                     ;coded size
		mov esi,huff_i_inbuf			;edx=input bufer
@get_count:
		xor eax,eax
                lodsb

		imul eax,eax,SIZE tree_sorted
		inc [edx+eax.sorted_count] 
		loop @get_count

		pop ecx					;ecx=256
		;edx=stat table
		mov eax,SORT_MORE
		call sort


;---kill null elemenths---

		xor ebx,ebx				;ebx=hc=0
		mov eax,edx				;ecx=256,eax=bufer
@kill_nulls:
		cmp [eax.sorted_count],0
		je @kill_exit
		
		inc ebx					;hc++

		add eax,SIZE tree_sorted
		loop @kill_nulls

@kill_exit:

		mov edi,huff_i_outbuf			;edi=output bufer
		xor ecx,ecx				;index=0

;=============================================================================
@create_tree:
		
		push ecx
		                                        ;
		mov eax,SORT_LESS			;sort...
		mov ecx,ebx				;ebx=hc
		call sort                               ;
		                                        ;
		pop ecx
		
		xor ebp,ebp     			;t=0

		mov esi,2				;add&kill 2 nodes in out
@add_node:
		push esi

		mov eax,ecx                             ;eax=index

		imul eax,eax,SIZE tree_node
		lea esi,[edi+eax]                       ;out_buf[index]

		add ebp,[edx.sorted_count]		;t+=[0]count

		mov ax,[edx.sorted_sym]			;stat[0]
		mov [esi.sym],ax

		mov ax,[edx.sorted_l]
		mov [esi.l],ax

		mov ax,[edx.sorted_r]
		mov [esi.r],ax
		                                        
		pop esi		

		dec ebx
		jz @create_tree_exit                    ;hc==1?
		inc ebx

		push esi
;--kill node from sort--------------------------------------------------------
		xor eax,eax
@kill_node:
		inc eax					;begin with 2nd elem.

		cmp eax,ebx				;eax==hc-1?
		je @kill_node_exit

		push eax

		mov esi,eax
		imul esi,esi,SIZE tree_sorted
		add esi,edx
		
		mov ax,[esi.sorted_sym]
		mov [(esi-SIZE tree_sorted).sorted_sym],ax
                                                       	;stat[i-1]
		mov ax,[esi.sorted_l]
		mov [(esi-SIZE tree_sorted).sorted_l],ax

		mov ax,[esi.sorted_r]
		mov [(esi-SIZE tree_sorted).sorted_r],ax

		mov eax,[esi.sorted_count]
		mov [(esi-SIZE tree_sorted).sorted_count],eax

		pop eax
		jmp @kill_node
@kill_node_exit:

;--end------------------------------------------------------------------------
		pop esi

		inc ecx					;index++
		dec esi					;interation--
		jnz @add_node

;=============================================================================
		dec ebx					;hc--

		mov eax,ebx				;
		dec eax                                 ;eax=hc-1
		imul eax,eax,SIZE tree_sorted
		add eax,edx

		mov [eax.sorted_sym],256		;flag-fake
		mov [eax.sorted_count],ebp		;count

		lea esi,[ecx-2]				;was stat[0]
		mov [eax.sorted_l],si
		;---------------------	
		lea esi,[ecx-1]				;was stat[1]
		mov [eax.sorted_r],si

		jmp @create_tree

@create_tree_exit:
;=============================================================================

		add esp,256*(SIZE tree_sorted)

		mov [esp._eax],ecx			;return index
		popa
		ret


;//////////////////////////////////////////////////////////////////////////////
;Bubble sort
;//////////////////////////////////////////////////////////////////////////////
;edx=bufer
;ecx=length
;eax=type
sort:							
		pusha

		xchg ebx,ecx				;size
		dec ebx                        		;ebx=size-1
		jz sort_exit				;1 elem?

		mov ebp,eax				;type
		xor ecx,ecx				;i
sort_for1:
	
		push ebx				;i-1
;------------------------------------------------------------------------------
sort_for2:
		cmp ebx,ecx
		je sort_for2_exit

		push ebx
		mov edi,ebx

		imul edi,edi,(SIZE tree_sorted)	 	;edi=[j]
		lea esi,[edi-(SIZE tree_sorted)] 	;esi=[j-1]

		add edi,edx
		add esi,edx

		mov ebx,[edi.sorted_count]          	;ebx=[j].count
		mov eax,[esi.sorted_count]          	;eax=[j-1].count

		cmp ebp,SORT_LESS
		jne sort_more
sort_less:
		cmp eax,ebx				;[j-1]<=[j]?
		jbe sort_for2_next 

;exchange elemenths:
sort_exchange:
		push 4 ptr[edi.sorted_count]		;[j](count)
		push 4 ptr[edi.sorted_l]		;[j](l+r)

		push 4 ptr[esi.sorted_count]		;[j-1](sym+count)
		push 4 ptr[esi.sorted_l]		;[j-1](l+r)

		pop 4 ptr[edi.sorted_l]		 	;[j-1](l+r)->[j](l+r)
		pop 4 ptr[edi.sorted_count]		;[j-1](sym+count)->[j](sym+count)

		pop 4 ptr[esi.sorted_l]		 	;[jl (l+r)->[j-1](l+r)
		pop 4 ptr[esi.sorted_count]		;[j] (sym+count)->[j-1](sym+count)


		mov ax,[edi.sorted_sym]			;
		xchg [esi.sorted_sym],ax                ;edi->esi
		mov [edi.sorted_sym],ax                 ;esi->edi

		jmp sort_for2_next 
sort_more:

		cmp eax,ebx				;[j-1]>=[j]?
		jb sort_exchange

sort_for2_next:
		pop ebx

		dec ebx
		jmp sort_for2
;---------------------------------------------------------
sort_for2_exit:
		pop ebx					;ebx=size

		inc ecx
		cmp ecx,ebx
		jne sort_for1

sort_exit:
                popa
                ret

ifdef DEBUG 
		db  SIGN2
endif


;//////////////////////////////////////////////////////////////////////////////
;Compress
;//////////////////////////////////////////////////////////////////////////////
;
;dword huffman_compress(struct tree_node *htree,byte* hin,byte* hout,dword index,dword size)

ifdef DEBUG 
		db  SIGN11
endif

huff_c_tree		equ		[ebp+8*4]+4
huff_c_in		equ		[ebp+8*4]+8
huff_c_out		equ		[ebp+8*4]+12
huff_c_index		equ		[ebp+8*4]+16
huff_c_size		equ		[ebp+8*4]+20

huff_c_hfind		equ		[ebp-257*SIZE hfind]
huff_c_hfind_temp	equ		[ebp-SIZE hfind]
huffman_compress:
		pusha
		mov ebp,esp

		mov ecx,257*SIZE hfind
		sub esp,ecx

;--clear hash table+temp-------------------------------------------------------
		xor eax,eax
		lea edi,huff_c_hfind
		rep stosb		
;------------------------------------------------------------------------------


		lea edx,huff_c_hfind			;hfind out
		mov ebx,huff_c_index                    ;ebx-index(root)
		mov edi,huff_c_tree                     ;edi-tree

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;create hash table:

		mov ecx,256
fill_hash:
		dec ecx

		push edx

		mov eax,ecx
		push eax

		imul eax,eax,SIZE hfind
		add edx,eax				;edx=adress of out

		pop eax                                 ;eax=needed byte
							;ebx=root
							;edi=tree  
		call find_node
		pop edx		 

		or ecx,ecx
		jnz fill_hash
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		mov ecx,huff_c_size			;ecx=size
		push ecx
		mov edi,huff_c_out                      ;
		xor eax,eax                             ;
		rep stosb				;clear out bufer
		pop ecx

		mov esi,huff_c_in   			;esi-in
		;edi=tree  
		;edx=hash table  

		xor ebx,ebx				;p=0
		;mov ecx,huff_c_size			;ecx=size

;------------------------------------------------------------------------------
@@compress:
		push ecx

		xor eax,eax
                lodsb

		pusha

		imul eax,eax,SIZE hfind			;
							;
		lea esi,[edx+eax]                       ;       
		lea edi,huff_c_hfind_temp	        ;copy hfind from
		                                        ;       hash table
		mov ecx,SIZE hfind                      ;
		rep movsb                               ;
		popa

		mov ecx,ebx				;ecx=p
		and ecx,00000111b			;pmod=p%8

		push ecx				;save pmod

		movzx eax,huff_c_hfind_temp.hsize       
		push eax				;save hsize

		and eax,00000111b			;hmod=hsize%8

		add eax,ecx				;eax=hmod+pmod
		mov ecx,16
		sub ecx,eax				;ecx=16-(hmod+pmod)

		pusha
		lea edx,huff_c_hfind_temp		;edx=buf,ecx=size
		call shl33                              ;shift bufer
		popa

		pop eax					;load hsize
		pop ecx					;load pmod

		pusha

		add ecx,eax				;
		shr ecx,3                               ;x=ecx=(pmod+hsize)/8+1
		inc ecx                                 ;

		;eax=hsize
		shr eax,3                               ;
		neg eax   				;hint=eax=31-hsize/8
		add eax,31                              ;
					
		mov edx,ebx                             ;
		shr edx,3				;edx=pint=p/8

		mov esi,huff_c_out			;esi-output[pint+0]
		add esi,edx				;
		mov edi,esi
				

		lea ebx,huff_c_hfind_temp.hprefix       ;
		add ebx,eax				;ebx-hprefix[hint]

		;ecx=size
@@comprs_or:
		lodsb
		or al,1 ptr[ebx]			;complete mask
		stosb
	
		inc ebx
		loop @@comprs_or

		popa

		movzx eax,huff_c_hfind_temp.hsize
		add ebx,eax

		pop ecx
		loop @@compress
;------------------------------------------------------------------------------

		add esp,257*SIZE hfind
		mov [esp._eax],ebx
		popa
		ret


;//////////////////////////////////////////////////////////////////////////////
;Shl33
;//////////////////////////////////////////////////////////////////////////////

;In: 		edx=bufer 
;    		ecx=count
;                  ---
;Out:           eax=cf
shl33:
		pusha

		or ecx,ecx
		jz shl33_exit

		xchg edi,edx				;edi=bufer

		std					;go back
_shl33_1:
		push ecx
		push edi   				;save bufer

		xor edx,edx				;//cf

		shl 1 ptr[edi+32],1			;33th byte
		jnc @no_cf_33 

		inc edx					;cf=1
@no_cf_33: 
		lea esi,[edi+32-4]
		mov edi,esi

		mov ecx,4				;//(32*8/64)
@shl64:
		lodsd
		xchg ebx,eax                    	;//ebx=low
		lodsd                           	;//eax=high

		bswap eax       
		bswap ebx       

		shld eax,ebx,1  			;//shift...

		pushf
		shl ebx,1
		or ebx,edx				;set shifted bit
		popf

		jnc @no_cf

		inc edx					;edx=1
		jmp @a_cf
@no_cf:
		xor edx,edx
@a_cf:

		bswap eax	  			;//convert
		bswap ebx         

	        xchg ebx,eax
		stosd					;//high
	        xchg ebx,eax
		stosd             			;//low

	        dec ecx
	        jnz @shl64

		pop edi
		pop ecx

		dec ecx
		jnz _shl33_1

		cld

		mov [esp._eax],edx
shl33_exit:
		popa
		ret




;//////////////////////////////////////////////////////////////////////////////
; Find_node
;//////////////////////////////////////////////////////////////////////////////
;In: 	edx=adress of out
;   	eax=needed byte
;    	ebx=root
;	edi=tree  
find_node:
		pusha

		mov ecx,SIZE hfind

		sub esp,ecx
		mov ebp,esp				;esp=local out

		push edi

		mov esi,edx				;src=out
		mov edi,ebp				;dst=local
		rep movsb				;copy fout
	
		pop edi

		;------------

		mov ecx,ebx                		;ecx=root
		imul ecx,ecx,SIZE tree_node		;
		add ecx,edi                             ;
		
		cmp [ecx.sym],256			;node?
		jne node_sym

		pusha 					;edx,ecx,eax

;-------------------------------------------------------
;in: 		edx=bufer
;    		ecx=count

		lea edx,[ebp.hprefix]
		mov ecx,1
		call shl33
		
		inc [ebp.hsize]
;-------------------------------------------------------
		popa

		;edx=out
		;eax=sym
		;ebx=root
		;edi=tree

		movzx ebx,[ecx.r]			;go right

		push eax
		push edx

		mov edx,ebp
		call find_node
		pop edx

		or eax,eax
		pop eax
		jz @@find_left


@@its_finded:
		
		mov edi,edx				;edi=out
		mov esi,ebp     	                ;esi=local find
		mov ecx,SIZE hfind
		rep movsb

		xor eax,eax				;mov eax,1
		inc eax                                 ;
		

		jmp @@find_node_exit

@@find_left:

		or 1 ptr[ebp.hprefix+32],1
		movzx ebx,[ecx.l]			;go right

		push eax
		push edx

		mov edx,ebp
		call find_node
		pop edx

		or eax,eax
		pop eax
		jnz @@its_finded

		jmp @@null_node_exit

;------------------------------------------------------------------------------

node_sym:
		cmp [ecx.sym],ax			;needed symbol?
		je @@its_finded

comment #
		push  eax
		mov ax,[ecx.sym]
		mov 1 ptr[esp],al
		mov esi,esp
		mov ecx,1
		call write_char
		pop eax

		mov esi,offset sep_msg
		call write_string
		
		lea esi,[ebp.hprefix+29]
		mov ecx,3
printx:
		lodsb
		call bit_print
		loop printx

		mov esi,offset sep_msg
		call write_string

		movzx eax,[ebp.hsize]
		call write_hex

		mov esi,offset cr
		call write_string

	#
@@null_node_exit:
		xor eax,eax
@@find_node_exit:
		add esp,SIZE hfind
		mov [esp._eax],eax
		popa
		ret
ifdef DEBUG 
		db  SIGN22
endif

;//////////////////////////////////////////////////////////////////////////////
;Decompress
;//////////////////////////////////////////////////////////////////////////////

ifdef DEBUG 
		db  SIGN111
endif

;dword huffman_decompress(struct tree_node *htree,byte* hin,byte* hout,dword index,dword size)
huff_d_tree		equ		[ebp+8*4]+4
huff_d_in		equ		[ebp+8*4]+8
huff_d_out		equ		[ebp+8*4]+12
huff_d_index		equ		[ebp+8*4]+16
huff_d_size		equ		[ebp+8*4]+20
huffman_decompress:
		pusha
		mov ebp,esp

		mov esi,huff_d_in
		mov edi,huff_d_out
		mov edx,huff_d_size
		xor eax,eax                             ;pmod=0 and next_bit

;--------------------------------------------------------------------------
@@decompress:
		push edi

		mov ebx,huff_d_index

;--------------------------------------------------------------------------
decprs_find:

		or ah,ah
		jnz @@d_no_load
		
		lodsb					;get next byte
		mov ah,8
@@d_no_load:

		mov edi,ebx
		imul edi,edi,SIZE tree_node
		add edi,huff_d_tree			;edi=current node

		mov cx,[edi.sym]			;cx=sym
                                                        
		cmp cx,100h                             ;node/point?
		jne d_find_exit

		dec edx					;size--
		dec ah
		
		shl al,1
		jc node_1

node_0:;(right)
		movzx ebx,[edi.r]
		jmp decprs_find

node_1:;(left)
		movzx ebx,[edi.l]
		jmp decprs_find

d_find_exit:
;------------------------------------------------------------------
;cx=sym
		pop edi

		xchg eax,ecx
		stosb					;write in out
		xchg eax,ecx

		or edx,edx
		jnz @@decompress
	
		sub edi,huff_d_out
		mov [esp._eax],edi
		popa
		ret

ifdef DEBUG 
		db  SIGN222
endif


