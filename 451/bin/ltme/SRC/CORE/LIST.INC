;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;  list_add
;  list_kill
;  list_init
;  list_get
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

list_header 	struc
		list_first		dd		?
		list_last		dd		?

;-----------------------------------------------------------------------------
ifndef DYNAMIC_LIST

		list_mem		dd		?
		list_bufer		dd		?
endif
;-----------------------------------------------------------------------------
		ends

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;LIST_ADD
;
;IN:	EBX=list descriptor
;	EDX=position (FFFFFFFFh if elementh is added to end)
;		     (0 if  first)	
;	EDI=offset to data
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
list_add:
                pusha


;-----------------------------------------------------------------------------
ifdef DYNAMIC_LIST

                push SIZE one                           ;	
		call core__malloc                       ; create element
		add esp,4                               ;
		xchg esi,eax				;
else
;-[Static]--------------------------------------------------------------------
		lea esi,[ebx.list_bufer]		;esi=list_bufer
		opzmov ecx,<SIZE one>

ladd_lookup_empty:

		cmp esi,[ebx.list_mem]			;last in heap?
                je ladd_chain
                                                       
		mov eax,[esi.one_next]			;next = FFFFFFFFh?
		inc eax					;      
                jz ladd_insert

                add esi,ecx				; size one
                jmp ladd_lookup_empty

ladd_chain:
                add 4 ptr[ebx.list_mem],ecx		; size one
endif
;-----------------------------------------------------------------------------


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
ladd_insert:

		;EDI=DATA
		;ESI=MEMORY for new elementh

		push esi
		xchg edi,esi                            ; ESI=src EDI=bufer
		lea edi,[edi.one_data]
                opzmov ecx,ONEDATA_SIZE
                rep movsb				; copy data
                pop esi

                ;REP  ECX=0
		
		cmp [ebx.list_first],ecx		; first = 0?
		jne ladd_0000_add

;-[first in list]------------------------------------------------------------

		mov [ebx.list_last],esi
;		mov [ebx.list_first],esi
		jmp ladd_0000_exit

;-[at begin?]----------------------------------------------------------------
ladd_0000_add:	
		or edx,edx				; add first?
        	jnz ladd_some_add                       ;
		
		mov eax,[ebx.list_first]

                ;EDX = 0
		mov [esi.one_prev],edx			; prev=0
		mov [esi.one_next],eax			; next=prev_first
                mov [eax.one_prev],esi			; prev_first.prev=new_first


ladd_0000_exit:
		mov [ebx.list_first],esi
		jmp ladd_exit

;-[some elementh]------------------------------------------------------------
ladd_some_add:

		;EDX=elementh number(1  FFFFFFFFh)
                mov edi,[ebx.list_first]

ladd_find_need_num:
		cmp edi,[ebx.list_last]
		je ladd_last

		dec edx					; needed?
                jz ladd_link

		mov edi,[edi.one_next]
		jmp ladd_find_need_num

;----------------------------------------------------------------------------
ladd_last:
		mov [esi.one_prev],edi                  ; prev=prev_last
		mov [edi.one_next],esi			; prev_last.next=new_last

		xor eax,eax                             ; next=0
		mov [esi.one_next],eax			;	******

		mov [ebx.list_last],esi
		jmp ladd_exit

;----------------------------------------------------------------------------
ladd_link:

                mov eax,[edi.one_next]

		mov [esi.one_next],eax
		mov [esi.one_prev],edi

		mov [eax.one_prev],esi
		mov [edi.one_next],esi

ladd_exit:
                popa
                ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;LIST_KILL
;
;IN:	EBX=list_desctiptor
;	EDX=position (FFFFFFFF if killed elem is last)
;		     (1 if first)
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

list_kill:
                pusha


		mov edi,[ebx.list_first]

		xor ecx,ecx                             ; ECX = 0

		dec edx                                 ;
		jz lkill_first                          ; first ?
		inc edx					;

;----------------------------------------------------------------------------
lkill_some:
                cmp edi,[ebx.list_last]
		je lkill_last

		dec edx
		jz lkill_link

                mov edi,[edi.one_next]
                jmp lkill_some

;----------------------------------------------------------------------------
lkill_first:

		mov eax,[edi.one_next]
		mov [ebx.list_first],eax

		mov [eax.one_prev],ecx			; = 0
		jmp lkill_free

;----------------------------------------------------------------------------
lkill_last:
		mov eax,[edi.one_prev]
		mov [ebx.list_last],eax

		mov [eax.one_next],ecx                  ; = 0
		jmp lkill_free

;----------------------------------------------------------------------------
lkill_link:

		mov edx,[edi.one_next]
		mov eax,[edi.one_prev]

                mov [eax.one_next],edx
                mov [edx.one_prev],eax

lkill_free:


;-----------------------------------------------------------------------------
ifdef DYNAMIC_LIST
		push edi 				;
		call core__free                         ; release memory
		add esp,4                               ;
else
;-[Static]--------------------------------------------------------------------
		dec ecx					; ECX = FFFFFFFF
                mov [edi.one_next],ecx                  ; free flag
                mov [edi.one_prev],ecx                  ; free flag
endif
;-----------------------------------------------------------------------------

                popa
                ret


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;LIST_INIT
;
;IN:	EBX=bufer
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
list_init:
		push eax

		xor eax,eax
		mov [ebx.list_first],eax
		mov [ebx.list_last],eax

;-----------------------------------------------------------------------------
ifndef DYNAMIC_LIST		

		lea eax,[ebx.list_bufer]
		mov [ebx.list_mem],eax

endif
;-----------------------------------------------------------------------------

		pop eax
		ret



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;LIST_GET
;
;In	:	EBX=list descriptor
;		EDX=position (1FFFFFFFF)
;Out 	: 	EAX=elementh adr
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
list_get:
                pusha

		mov esi,[ebx.list_first]
lg_find:
		dec edx
		jz lg_get

		cmp esi,[ebx.list_last]			;list_last?
		je lg_get

                mov esi,[esi.one_next]
                jmp lg_find
lg_get:
		mov [esp._eax],esi			;esi=adress
                popa
                ret

